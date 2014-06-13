package com.kpm.kpm
{
	import com.de.polygonal.ds.TreeNode;
	import com.kpm.common.*;
	import com.kpm.games.*;
	
	import fl.controls.ComboBox;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.StageDisplayState;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.system.System;
	import flash.system.fscommand;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	
	/*
	
	com.kpm.kpm.Driver - Document Class for Driver.fla
	F Loads booths with games
	F keeps track of mute, repeat question, full screen, back, exit
	F manage the available bubbles, find successor, predecessor bubbles
	
	com.kpm.kpm.DriverData
	V list of initial active bubbles 
	F populate bubble requirements
	F populate bubbles per game
	F populate kids
	
	com.kpm.games.GameData
	variables and functions that could be used for other games
	V State, GameGoal, Bubble management
	V sound instructions, written instructions, Language, SoundPLayer
	V Events and sound name constants
	F complete bubble, fail bubble, return to driver
	  
	com.kpm.games.GameDataX 
	keeps all gameplay and level variables and constants specific to GameX
	V Level management
	F set the game theme
	F Choose appropriate written feedback depending on State
	F update all lvl vars to the appropriate lvl
	
	com.kpm.games.Game1 - Document class for Game1.fla
	F keeps all the functionality for the 'Froggy Game"
	V bubbles : SpatialSense, IdentifyColor, Numbers_Identifys
	
	com.kpm.games.Game2 - Document class for Game2.fla
	F keeps all the functionality for the 'Disassemble Game'
	V bubbles : MatchShape, IdentifyColor, IdentifyShape
	
	com.kpm.common.GameComponent
	V Scale, Position, Color,
	V Movie, which is the graphical representation of the game component
	F Drag and drop functionality, Blinking functionality
	
	com.kpm.common.Util
	F static methods to manage movieclip resizing, coloring, 
	F static methods to manage arrays, get random elements 
	
	com.kpm.common.KpmSound
	V contains a single sound and some properties
	
	com.kpm.common.KpmSoundPlayer
	F manages a list of sounds to play, enqueueing sounds, 
	F fires events after the sound finishes if specified so 
	
	*/
	
		
	public class DriverWeb extends MovieClip
	{
		var boothLoader		: Loader = new Loader();
		var gameLoader		: Loader = new Loader();
		var pictureLoader 	: Loader;
	
		var pausePoint		: Number;
		var musicChannel, soundChannel 				: SoundChannel;
		var musicSound, languageSound, welcomeSound	: Sound;
		
		var mActiveBubbles, mPossibleGames, boothArray: Array;
		var boothList		: Array;
		var languageButtons	: Array;
		var driverData			: DriverData;
			
		var currentBooth	: MovieClip;
		var currentGame 	: Object;
		var currentLanguage	: ELanguage;
		var currentTheme	: EGameCharacter;
		var currentKidId	: String;
		var currentKid		: Kid;
		
		var customCursor 	: CursorManager;
		var idleCounter		: uint = 0;
		var mouseIdle		: MouseIdleMonitor;
		var boothClicked	: Boolean = false;
		var bubbleFinished	: Boolean = false;
		//var menu 			: ContextMenu;
		
		var languagePlaying	: Boolean;
		
		public var currentBubbleId : BubbleId;
		public var currentBubbleComplete = false;
		public var mute		: Boolean = false;
		var connCounter		: int = 0;
		
		//Sets the stage elements to show the UiDriver
		public function DriverWeb()
		{	
			tDriver.visible = false;
			tElements.visible = false;
			tUiDriver.visible = true;
			tUiDriver.tStartKids_Button.addEventListener(MouseEvent.CLICK, initializeDriver);
			tUiDriver.tStartTeachers_Button.addEventListener(MouseEvent.CLICK, initializeDriver);
			tUiDriver.tStartTeachers_Button.addEventListener(MouseEvent.CLICK, initializeDriver)
			tUiDriver.tResetProfile_Button.addEventListener(MouseEvent.CLICK, resetProfile)
			//addEventListener(Event.ACTIVATE, resizeWindow);  
						
		}
		
//		public function resizeWindow(e : Event)
//		{
//			var window = NativeApplication.nativeApplication.activeWindow;
//			
//			if(!window) return;
//			//Windows vars
//			var osMenuHeight = 28;
//			var applicationMenuHeight = 22;
//			
//			trace(Capabilities.os);
//			if(Capabilities.os.indexOf("Mac OS") == -1)
//			{
////				trace("WINDOWS");	
//				osMenuHeight = 32;
//				applicationMenuHeight = 26;
//			}
//			
////			trace("menu height " + osMenuHeight + " app menu height " + applicationMenuHeight);
//				
//			var aspectRatio : Number = Number(Capabilities.screenResolutionX)/Capabilities.screenResolutionY;
//			window.height = Capabilities.screenResolutionY - osMenuHeight;
//			window.width = uint(aspectRatio*(window.height-applicationMenuHeight)); 
//			window.x = (Capabilities.screenResolutionX - window.width)/2;
//			window.y = 0;
//			
//			removeEventListener(Event.ACTIVATE, resizeWindow);  
//		}
//		
		function resetProfile(e : MouseEvent)
		{
			var pResetKidId : String = tUiDriver.tKidId.text;
			var kidsProfilePath : String = DriverData.FOLDER_KIDS + pResetKidId;
			KpmIO.deleteFromKpmStorage(kidsProfilePath);
			
		}
		
		
		function initializeDriver(e : MouseEvent)
		{
			//Mute = true;
			tDriver.visible = true;
			tElements.visible = true;
			tUiDriver.visible = false;
			initMouse();
			trace(currentKidId);	
			
			mActiveBubbles = new Array();
			mPossibleGames = new Array();
			boothList = new Array();
			
			driverData = DriverData.getInstance();
			
			//driverData.IPAddress = Application.application.parameters.flashIPAddress
			if(e.target == tUiDriver.tStartKids_Button)
			{
				trace("kids");
				driverData.allBubblesUnlocked = false;
				driverData.randomBubble = true;
				currentKidId = tUiDriver.tKidId.text;
			}
			else if(e.target == tUiDriver.tStartTeachers_Button)
			{
				trace("teachers");
				driverData.allBubblesUnlocked = true;
				driverData.randomBubble = false;
				currentKidId = DriverData.TEACHER_ID;
			}
			
			driverData.startProcessingProfile(currentKidId);
			driverData.addEventListener(Event.COMPLETE, initializeBubblesDone);
			driverData.addEventListener(DriverData.CYCLE_FOUND, exitApplication);
			
			if (stage.displayState == StageDisplayState.NORMAL)
		        fscommand("fullscreen", "true");
		
		}
		
		
		//gets called when bubbles and kids are done loading from XML
		function initializeBubblesDone(e : Event)
		{
			var firstTime : Boolean = false;
			
			
			if("BUBBLE_STATUS" in DriverData.currentKidXML)
				firstTime = false;
			else
				firstTime = true;
			
			currentKid = Kid.makeKidFromXML(DriverData.currentKidXML, true, firstTime);
			
			if(driverData.allBubblesUnlocked)
				currentKid.changeBubbleOutcome(driverData.allBubbles, EBStatus.Passed, true);
			
			driverData.bubbleStatus = currentKid.bubbleStatus;

						
			currentLanguage = ELanguage.ENG;
			welcomeSound = new WelcomeSound();
			soundChannel = welcomeSound.play();
			
			initBooths();
			initLanguages();
			initElements();
			initDriverMusic(true);
			
			addEventListener(ContextMenuEvent.MENU_SELECT, onRightClick); 
//			NativeApplication.nativeApplication.addEventListener(Event.EXITING, onClosingEvent);
			gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onGameLoaderComplete);
			gameLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onGameLoaderProgress);
		}
		
		function initMouse()
		{
			CursorManager.init(this.stage);
			CursorManager.setCursor(new CursorIdle());
			
			mouseIdle  = new MouseIdleMonitor(stage, GameLib.MAX_IDLE_TIME);
			mouseIdle.addEventListener(MouseIdleMonitorEvent.MOUSE_ACTIVE, onMouseActive);
			mouseIdle.addEventListener(MouseIdleMonitorEvent.MOUSE_IDLE, onMouseIdle);
			mouseIdle.start();
		}
		
		function setIdleMouse()
		{
			
		}
		
		function onClosingEvent(e : Event)
		{
			mouseIdle.removeEventListener(MouseIdleMonitorEvent.MOUSE_ACTIVE, onMouseActive);
			mouseIdle.removeEventListener(MouseIdleMonitorEvent.MOUSE_IDLE, onMouseIdle);
			
			if(driverData.logToFtp)
			{
				e.preventDefault();
				driverData.ftpFile.removeEventListener(DriverData.DATA_SENT, exitApplication);
				driverData.ftpFile.addEventListener(DriverData.DATA_SENT, DriverData.logTool.openFilesToUpload);
				DriverData.logTool.addEventListener(DriverData.FILES_UPLOADING, uploadingFiles);
				DriverData.logTool.closeSession();
				DriverData.logTool.uploadSessionFtp();
				
				initDriverMusic(false);
			}
			else
			{
				DriverData.logTool.closeSession();
			}
		}
		
		function uploadingFiles(e : Event)
		{
			trace("adding event exit application");
			DriverData.logTool.addEventListener(DriverData.FILES_UPLOADED, exitApplication)
		}
	
	
		function onRightClick(e : MouseEvent)
		{			
//			trace("right click detected");
			this.dispatchEvent(new MouseEvent(MouseEvent.DOUBLE_CLICK));
		}
		
		function initBooths()
		{
			
			initBooth(EGame.G1.Text, new Point2D(120, 480), 1, EGameCharacter.Frog);
			initBooth(EGame.G1.Text, new Point2D(370, 550), 3, EGameCharacter.Bee);
			initBooth(EGame.G1.Text, new Point2D(600, 470), 2, EGameCharacter.Mouse);
			initBooth(EGame.G2.Text, new Point2D(870, 560), 4);
			initBooth(EGame.G3.Text, new Point2D(1160, 540), 5);
			populateDropdowns();
			
		}
		
		function initLanguages()
		{
			languageButtons = new Array();
			tDriver.tSPA.lang = ELanguage.SPA;
			tDriver.tENG.lang = ELanguage.ENG;
			languageButtons.push(tDriver.tSPA);
			languageButtons.push(tDriver.tENG);
			
			for(var item in languageButtons)
			{
				languageButtons[item].addEventListener(MouseEvent.ROLL_OVER, onRollOverLanguage);
				languageButtons[item].addEventListener(MouseEvent.CLICK, onLanguageClick);
				languageButtons[item].buttonMode = true;
				languageButtons[item].mouseCursor = true;
				languageButtons[item].played = false;
			}
		}
		
		function onRollOverLanguage(e : Event)
		{
			languageSound = Util.createSound((e.target).lang.Text);
			if (!languagePlaying)
			{
				languagePlaying = true;
				soundChannel = languageSound.play();
				soundChannel.addEventListener(Event.SOUND_COMPLETE, onLanguageSoundComplete);
			}
		}
		
		function onLanguageSoundComplete(e : Event)
		{
			languagePlaying = false;
		}
		
		function onLanguageClick(e : Event)
		{
			for(var item in languageButtons)
				languageButtons[item].gotoAndPlay("normal");
				
			currentLanguage = (e.target).lang;
			e.target.gotoAndPlay("pushed"); 
		}

		function initBooth(pItem : String, pPos : Point2D, pBoothNum : int, pTheme : EGameCharacter = null) 
		{
			
			var tempBooth : MovieClip = Util.createMc("Booth" + pBoothNum);
			var themeString : String;
			boothLoader = new Loader();
			tempBooth.scaleX = tempBooth.scaleY =  0.85;
			tempBooth.game = pItem;
			tempBooth.gameTheme = pTheme;
					
			
			if(pTheme)
				themeString = pTheme.Text;
			else
				themeString = "";
					
			var request:URLRequest = 
			new URLRequest(DriverData.FOLDER_IMAGE + tempBooth.game + themeString + ".jpg");
			
			addChild(tempBooth);
			boothLoader.load(request);
			tempBooth.tImage.buttonMode = true;
			tempBooth.tImage.addChild(boothLoader);
			tempBooth.tImage.addEventListener(MouseEvent.CLICK, onBoothClick);
			tempBooth.tBooth.addEventListener(MouseEvent.CLICK, onBoothClick);
			tempBooth.tBooth.addEventListener(MouseEvent.ROLL_OVER, CursorManager.setOverCursor);
			tempBooth.tBooth.addEventListener(MouseEvent.ROLL_OUT, CursorManager.setIdleCursor);
			tempBooth.tImage.addEventListener(MouseEvent.ROLL_OVER, CursorManager.setOverCursor);
			tempBooth.tImage.addEventListener(MouseEvent.ROLL_OUT, CursorManager.setIdleCursor);
			
			tempBooth.tBooth.buttonMode = true;
			tempBooth.x = pPos.x;
			tempBooth.y = pPos.y;
			
			var my_tf:TextFormat = new TextFormat();
			my_tf.size = 16;
			my_tf.font = "Calibri";
			
			
			tempBooth.cb_bubble = tempBooth.addChild(new KpmComboBox());
		
			with (tempBooth.cb_bubble)
			{
			 	setSize(220,27);
				y = tempBooth.height/2 + 50;
				x = -220/2;
				
				textField.setStyle("textFormat", my_tf);
				textField.setStyle("embedFonts", true);
				dropdown.setRendererStyle("textFormat", my_tf);
				dropdown.setRendererStyle("embedFonts", true);
				textField.textField.embedFonts = true;
				setStyle("textFormat", my_tf);
				setStyle("embedFonts", true);
				addEventListener(MouseEvent.CLICK, CursorManager.bringToFront);
				
				 
			}
			
		
			boothList.push(tempBooth);

		}
		
		function populateDropdowns()
		{
			for ( var item in boothList)
				populateBoothBubbles(boothList[item]);					
		}
		
		function populateBoothBubbles(pBooth : MovieClip)
		{
			pBooth.visible = false;
			pBooth.cb_bubble.removeAll();
			pBooth.cb_bubble.focusEnabled = false;
			var bId : BubbleId;
			var bStatus : EBStatus;
			//Populate active bubbles on top
			for (var j in driverData.BubblesPerGame[pBooth.game])
			{
				bId  = driverData.BubblesPerGame[pBooth.game][j] as BubbleId;
				bStatus  = currentKid.bubbleStatus[bId.Text] ;
				//trace("bid status " + bId.Text + " " + bStatus.Text);
				
				if(bStatus == EBStatus.Active || bStatus == EBStatus.Enjoy)
				{
					pBooth.cb_bubble.addItem({label:bId.Text + " - " + bStatus.Text, data : bId});
					pBooth.visible = true;
				}
			}
			
			//Populate other bubbles at bottom
			for (var k in driverData.BubblesPerGame[pBooth.game])
			{
				bId  = driverData.BubblesPerGame[pBooth.game][k] as BubbleId;
				bStatus = currentKid.bubbleStatus[bId.Text] ;
				//trace("bid status " + bId.Text + " " + bStatus.Text);
				
				if(bStatus != EBStatus.InActive && bStatus != EBStatus.Active)
				{
					pBooth.cb_bubble.addItem({label:bId.Text + " - " + bStatus.Text, data : bId});
					pBooth.visible = true;
				}
			}
			
			
			if(currentBubbleId)
			{
				var index : int = findItemIndex(pBooth.cb_bubble, currentBubbleId);
				//trace("selected Index " + index);
				if(index != -1)
				{
					pBooth.cb_bubble.selectedIndex = index;
				}
			}				
		}

		function findItemIndex (cb:ComboBox, element: Object):int {
			var index:int = -1;
			for (var i = 0; i < cb.length; i++) 
				if (element.equals(cb.getItemAt(i).data)) 
				{
					index = i;
					break;
				}
			
			return index;
		}
		

		//init Stage elements		
		function initElements()
		{
			pictureLoader = new Loader();
			var request : URLRequest = 
			new URLRequest(DriverData.FOLDER_KIDS + currentKid.id + "/" 
											   + currentKid.id + ".jpg");							   
			trace(request.url);
			//pictureLoader.x = 20;					
			

		   	var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);  
			pictureLoader.load(request, context);
			
			tElements.tKidPicture.addChild(pictureLoader);
			tElements.tKidPicture.height = 50;
			tElements.tKidPicture.width = 50;
			tDriver.tKidGreeting.text = "Welcome to \n KIDS PLAY MATH \n" + currentKid.firstName + "!";			
		
			pictureLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, pictureLoaderComplete);
			tElements.tRepeat_Button.addEventListener(MouseEvent.CLICK, repeatQuestion);
			tElements.tMute_Button.addEventListener(MouseEvent.CLICK, toggleMute);
			tElements.tFullScreen_Button.addEventListener(MouseEvent.CLICK, toggleFullScreen);
			tElements.tBack_Button.addEventListener(MouseEvent.CLICK, ontBackClick);
			tElements.tWin_Button.addEventListener(MouseEvent.CLICK, ontWinClick);
			tElements.tLoose_Button.addEventListener(MouseEvent.CLICK, ontLooseClick);
			tElements.tExit_Button.addEventListener(MouseEvent.CLICK, onClosingEvent);
			
			tElements.tNumSuccess.visible = tElements.tTaskTimer.visible = DriverData.SCORE_VISIBLE;
			tElements.tGoodMoves.visible = tElements.tBadMoves.visible = DriverData.SCORE_VISIBLE;
			tElements.tWin_Button.visible = tElements.tLoose_Button.visible = DriverData.SCORE_VISIBLE
			
			setBackVisible(false);
			
			setChildIndex(tElements, numChildren-1);
			
			//tElements.tNextLevel.visible = false;
			tElements.tLoading.visible = false;
			tElements.tPreloader.visible = false;
			tElements.tBlack.visible = false;	
			tDriver.tENG.gotoAndPlay("pushed");
			tElements.tRepeat_Button.visible = false;
			tElements.tRepeat_Button.buttonMode = true;
			tElements.tMute_Button.buttonMode = true;
			tElements.tFullScreen_Button.buttonMode = true;
		}
		
		function setBackVisible(pBack : Boolean)
		{
			tElements.tBack_Button.visible = pBack;
			tElements.tExit_Button.visible = !pBack;
		}
		
		function onBoothClick(evt : MouseEvent)
		{
			if(boothClicked) return;
			
			boothClicked = true;
			currentBooth  = evt.currentTarget.parent as MovieClip;	
			tElements.tLoading.visible = true;
			tElements.tPreloader.visible = true;
			tElements.tBlack.visible = true;
			
			var ct : Object = DriverData.selectedObject;
			currentBooth.transform.colorTransform = 
			new ColorTransform(ct.ra, ct.ga, ct.ba, 1, ct.rb, ct.gb, ct.bb, 1); 			
		   	
		   	currentTheme 	= currentBooth.gameTheme;
		   	
			if(driverData.randomBubble)
				currentBubbleId = chooseRandomBubbleId(currentBooth.game);
			else
				currentBubbleId = currentBooth.cb_bubble.selectedItem.data as BubbleId;
				
			
			DriverData.getInstance().logTool.createBubbleSession(EGame[currentBooth.game], currentBubbleId);
			
			trace(currentBubbleId);
			trace(currentLanguage);
			trace(currentTheme);
			loadGame(DriverData.FOLDER_SWF + currentBooth.game + ".swf");
		}
		
		function loadGame(pUrl : String)
		{
			tDriver.tWheel.stop();
			var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			var request:URLRequest = new URLRequest(pUrl);
			gameLoader.load(request, context);
			addChild(gameLoader);
			
			bubbleFinished = false;
			
			if(musicChannel)
				musicChannel.stop();
			if(soundChannel)
				soundChannel.stop();
		}
		
		
		function ontBackClick(e : Event)
		{
			//onBubbleFailed();
			if(currentGame)
			{
				returnToDriver();
			}
		}
		
		function ontWinClick(e : Event)
		{
			onBubbleCompleted();
			if(currentGame)
			{
				returnToDriver();
			}
		}
		
		function ontLooseClick(e : Event)
		{
			ontBackClick(null);
		}
		
		function exitApplication(e : Event)
		{
//			trace("exiting");
//			try
//			{
//				NativeApplication.nativeApplication.exit(0);
//			}
//			catch (e : Error) {
//				trace(e);
//			}
		}
		
		function unloadGame (e:Event)
		{			
			if(currentGame)
			{
				if(currentGame is Game)
				{
					if(currentGame.onAnimationProgress)
						currentGame.removeEventListener(Event.ENTER_FRAME, currentGame.onAnimationProgress);
					if(currentGame.Data.updateLevelTimer)
						currentGame.Data.updateLevelTimer.removeEventListener(TimerEvent.TIMER, currentGame.Data.updateLevel);
				}
					
				if(currentGame.Data.taskTimer)
					currentGame.Data.taskTimer.removeEventListener(TimerEvent.TIMER, updateTaskTimer);
						
				addBubbleEvents(currentGame, (currentGame is com.kpm.games.Game));
				currentBooth.transform.colorTransform = new ColorTransform();
				gameLoader.unloadAndStop();
				//gameLoader.unload();
				removeChild(gameLoader);
				currentGame = null;
			}
		}
		
		function onGameLoaderProgress(e : ProgressEvent)
		{
			var percent:Number = Math.floor( (e.bytesLoaded*100)/e.bytesTotal );
			Util.debug("precent " + percent , this);
			tElements.tPreloader.gotoAndStop(percent);
			tElements.tPreloader.tPercent.text = percent+" %";
		}
		
		
		function onGameLoaderComplete(e : Event)
		{
		    currentGame = e.target.content;
			tElements.tLoading.visible = false;
			//tElements.tPreloader.gotoAndStop(1);
			tElements.tPreloader.visible = false;
			tElements.tBlack.visible = false;
			tElements.tRepeat_Button.visible = true;
			//tElements.tNextLevel.visible = false;
			setBackVisible(true);
			
			if(currentGame is com.kpm.games.Game)
			{
				currentGame.height = 800;
				currentGame.width = 1280;
				currentGame.initGame(currentBubbleId, currentLanguage, currentTheme);
				addBubbleEvents(currentGame.Data, true);
				updateBubbleFeedback();
			}
			else //if(currentGame is com.kpm.games.walkthewalk.Game)
			{
				//(currentGame as G3As3).loadSwf("swf/G3.swf", currentBubbleId, currentLanguage, mute);
				currentGame.initGame(currentBubbleId, currentLanguage.Text, mute);
				addBubbleEvents(currentGame.GameRoad, true);
				tElements.tBubbleSuccess.text = "";
				tElements.tNumSuccess.text = "";

			}

			tElements.tBubbleText.text = currentBubbleId.Text;
			setChildIndex(tElements, numChildren-1);
			
		
		}
		
		function addBubbleEvents(currentGame : Object, add : Boolean)
		{
			if(add)
			{
				currentGame.addEventListener (GameLib.RETURN_TO_DRIVER, returningToDriver);
				currentGame.addEventListener (GameLib.BUBBLE_FINISHED, onBubbleFinished);
				//currentGame.addEventListener (GameData.BUBBLE_FAILED, onBubbleFailed);
			}
			else
			{
				currentGame.removeEventListener (GameLib.RETURN_TO_DRIVER, returningToDriver);
				currentGame.removeEventListener(GameLib.BUBBLE_FINISHED, onBubbleFinished);
				//currentGame.removeEventListener(GameData.BUBBLE_FAILED, onBubbleFailed);
			}
			
		}
		
		function pictureLoaderComplete(e : Event)
		{ 
			tElements.tKidPicture.height = 50;
			tElements.tKidPicture.width = 50;
		}
		
		
		public function onBubbleFinished (e:Event)
		{
			if(bubbleFinished)
				return;
			else
				bubbleFinished = true;
				
			var currentBubble : KpmBubble = driverData.BubbleList[currentBubbleId.Text];
			var score : uint = currentGame.Score;
			
			Util.debug("finishing bubble", this);
			Util.debug(bubbleFinished, this);
			Util.debug(currentBubble, this);
			Util.debug(score, this);
			
			
			if(currentGame.Score >= currentBubble.scoreToComplete)
				onBubbleCompleted();
			else if (currentGame.Score < currentBubble.scoreToEnjoy)
				onBubbleFailed();
			else
				onBubbleEnjoyed(); 
					
		}
		
		
		public function onBubbleCompleted()
		{
			trace("success bubble " + currentBubbleId);
			
			currentBubbleComplete = true;
			tElements.tBubbleSuccess.text = "Success!";
			
			if(currentKid.bubbleStatus[currentBubbleId.Text] != EBStatus.Passed)
			{
				currentKid.changeBubbleOutcome([currentBubbleId], EBStatus.Passed);				
				currentKid.writeBStatus();
			}							
		}
		
		public function onBubbleFailed ()
		{
			currentBubbleComplete = false;
			trace("bubble fail " + currentBubbleId);
			inactivateBubbleFailed(currentBubbleId); 
			currentBubbleId = recomputEBStatus(currentBubbleId, currentBooth.game);
			currentKid.writeBStatus();
		
		}
		
		public function onBubbleEnjoyed()
		{
			currentKid.changeBubbleOutcome([currentBubbleId], EBStatus.Enjoy);
			currentKid.writeBStatus();	
		}
		
		public function returningToDriver(e : Event)
		{
			if(e != null)
				setTimeout(returnToDriver, 2200);
			else
				returnToDriver();
			
		}
		
		function returnToDriver()
		{
			var successors : Array;
			if(currentKid.bubbleStatus[currentBubbleId.Text] == EBStatus.Passed)
			{
				successors = activateSuccessors(currentBubbleId, currentBooth.game);	
				if(successors.length != 0)
					currentBubbleId = Util.getRandomFrom(successors) as BubbleId;
			}	
			
			unloadGame(null); 
			DriverData.logTool.closeBubbleSession(currentBubbleComplete);			
						
			if(!driverData.bubbleProgression || !Util.searchInArray(driverData.BubblesPerGame[currentBooth.game], currentBubbleId))
			{
				loadDriver(); 
				populateDropdowns();
				
			}
			else
			{
				tElements.tLoading.visible = tElements.tPreloader.visible = false;
				tElements.tBlack.visible = false;
				var loadingTimer : Timer = new Timer(1000 , 1);
				loadingTimer.start();				
				loadingTimer.addEventListener(TimerEvent.TIMER, loadSameGame);
				
			}
		}
		
		function chooseRandomBubbleId(game : String)
		{
			var activeGameArray : Array = new Array();
			
			//make an array with active bubbles, and populate x bubbles in the 
			//active game array, where x is the weight of the bubble
			for each (var bId : BubbleId in driverData.BubblesPerGame[game])
				if (currentKid.bubbleStatus[bId.Text] == EBStatus.Active)
				{
					trace("adding bid" + bId)
					trace("weight " + driverData.BubbleList[bId.Text])
					//trace("weight " + driverData.BubbleDef[bId.Text].weight)
					for(var i=0; i < driverData.BubbleList[bId.Text].weight; i++)
					{
						trace("adding bid" + bId)
						activeGameArray.push(bId);
					}
				}
		
			bId = Util.getRandomFrom(activeGameArray) as BubbleId;
				
			trace("chose at random" + bId);
			return bId;
		}
		
		function loadDriver()
		{
			boothClicked = false;
			tDriver.tWheel.play();
			trace("playing wheel");
			setBackVisible(false);
			tElements.tRepeat_Button.visible = false;
			initDriverMusic(!mute);
			currentBooth.transform.colorTransform = new ColorTransform();
			
			for(var item in languageButtons)
				languageButtons[item].played = false;
				
			//welcomeSound = Util.createSound("WelcomeBack"+Util.getRandomNumberBetween(1,2));
			//welcomeChannel = welcomeSound.play();	
			
		}
		
		
		function loadSameGame(e: Event)
		{
			trace("loading same game!");
			loadGame(currentBooth.game + ".swf");
			var request:URLRequest = new URLRequest("app-storage:/" + currentBooth.game + ".swf");
			if(currentGame is Game)
				currentGame.initGame(currentBubbleId, currentLanguage, currentTheme);
		}
		

		public function activateSuccessors(pBubbleId : BubbleId, pGame : String) : Array
		{
			var bubble : KpmBubble = driverData.BubbleList[pBubbleId.Text];
			var newBubbles : Array = new Array();
			//trace("successor List");
			//trace(bubble);	
			
			if(!bubble || !bubble.successorList)
				return newBubbles;
					
			if(bubble.successorList.length == 0)
				trace("activate successors : no successors");
				 
			for (var i in bubble.successorList)
			{
				var bId : BubbleId = bubble.successorList[i];

				if (isActive(bId))
				{
					trace("bid is active");
					trace("found " + bId);
					currentKid.changeBubbleOutcome([bId], EBStatus.Active);
					newBubbles.push(bId);
				}
			}
			
			//trace("find successor did not find anything");
			return newBubbles;
		}
		
		function inactivateBubbleFailed(pBubbleId : BubbleId)
		{
			if(driverData.BubbleList[pBubbleId.Text].initialStatus != EBStatus.Active
			   && !driverData.allBubblesUnlocked)
			   currentKid.changeBubbleOutcome([pBubbleId], EBStatus.InActive);
//			
//			if(!driverData.allBubblesUnlocked 
//			  && currentBubbleId.Name != EBName.IdentifyFinger
//			  && currentBubbleId.Name != EBName.Count3Finger
//			  && currentBubbleId.Name != EBName.Count5Finger)
//				currentKid.setBubblesStatus([pBubbleId], EBStatus.InActive);
//				
//			if(driverData.BubbleDef[pBubbleId.Text].initial)
//			   currentBubbleId == BubbleId.IdentifyNumeral0 || 
//			   currentBubbleId == BubbleId.IdentifyFinger0)
//			   	currentKid.setBubblesStatus([pBubbleId], EBStatus.InActive); 
			
		}

		//Activates all predecessors of the bubble id
		function recomputEBStatus(pBubbleId : BubbleId, pGame : String = null) : BubbleId
		{
			var bubble : KpmBubble = driverData.BubbleList[pBubbleId.Text];
			
			currentKid.predecessorsMarked = new Array();
			KpmBubble.postOrder(bubble.predecessorGraph, markPredecessors);
			
			for each (var bId in driverData.topographicallySortedBubbleList)
			{
				updateStatus(bId);
			}
			
			if(currentKid.predecessorsMarked.length > 0)
				return Util.getRandomFrom(currentKid.predecessorsMarked) as BubbleId;
			else
				return null;
							
			//if(pGame && Util.searchInArray(driverData.GameBubbles[pGame], bId))
			
		}
		
		
		function markPredecessors(pNode : TreeNode)
		{
			trace(pNode.data);
			if(pNode.data is BubbleId)
			{
				currentKid.predecessorsMarked.push(pNode.data);
				currentKid.changeBubbleOutcome([pNode.data], EBStatus.NotComplete);
			}
		}
		
		public function isActive(pBubbleId : BubbleId) : Boolean
		{
			var bubble : KpmBubble = driverData.BubbleList[pBubbleId.Text];
			var predecessorId : String;
			
			if(currentKid.bubbleStatus[pBubbleId.Text] == EBStatus.Passed)
				return false;
			
			if(!bubble) trace("bubble not found")
			
			trace("checking if " + pBubbleId + " is active");
			
			if(bubble.predecessorGraph == null)
				return true;
				
			if(bubble.predecessorGraph.children == null)
				return true;
				
			trace("checking if " + pBubbleId + " is active");
			
			return KpmBubble.areChildComplete(driverData.BubbleList[pBubbleId.Text].predecessorList);
			
		}		
		
		public function updateStatus(pBubbleId : BubbleId)
		{
			var bubble : KpmBubble = driverData.BubbleList[pBubbleId.Text];
			var predecessorId : String;
			var currentStatus : EBStatus = currentKid.bubbleStatus[pBubbleId.Text];
						
			if(!bubble) trace("bubble not found")
			
			trace("updating " + pBubbleId ); 
			trace("currentStatus " + currentStatus.Text);
			
			if(currentStatus == EBStatus.NotComplete)
			{
				currentKid.changeBubbleOutcome([pBubbleId], EBStatus.Active);
				trace("changing " + pBubbleId + " to Active");
			}
			
			if(bubble.predecessorGraph == null)
				return;
			if(bubble.predecessorGraph.children == null)
				return;
			
			if(currentStatus != EBStatus.InActive && !bubble.initialStatus == EBStatus.Active)
			if(!KpmBubble.areChildComplete(driverData.BubbleList[pBubbleId.Text].predecessorList))
			{
				currentKid.changeBubbleOutcome([pBubbleId], EBStatus.InActive);
				trace("changing " + pBubbleId + " to InActive");
			}
			
		}	
		
		
		public function initDriverMusic (pPlay : Boolean)
		{	
			if(pPlay)
			{
				tElements.tMute_Button.gotoAndPlay("on");
				musicSound = new DriverMusicSound();
				musicChannel = musicSound.play(	0, 10, new SoundTransform(0.5));
				
			}
			else
			{
				tElements.tMute_Button.gotoAndPlay("off");
				if(musicChannel)
					musicChannel.stop();
				if(soundChannel)
					soundChannel.stop();
				
			}
		}
		
		
		
		public function getCompleteBubbles() : Array
		{
			var completeArray = new Array();
			
			for (var item in currentKid.bubbleStatus)
				if(currentKid.bubbleStatus[item] == EBStatus.Passed)
					completeArray.push(item);
					
			return completeArray;
		}
		
		public function toggleMute(e:Event)
		{	
			Mute = !mute;
		}
		
		public function set Mute(pMute : Boolean)
		{
			
			mute = pMute;
			
			trace("setting mute to " + mute);
			
			if(mute)
				tElements.tMute_Button.gotoAndPlay("off");
			else 
				tElements.tMute_Button.gotoAndPlay("on");
					
			if(currentGame)
			{
				if(currentGame is com.kpm.games.Game)
					currentGame.Data.mute();
				else 
					currentGame.mute(mute);		
			}
			else
			{
				initDriverMusic(!mute);
			}
		}
		
		public function repeatQuestion(e: Event)
		{
			if(currentGame)
			{
				if(currentGame is Game)
					currentGame.Data.repeatQuestion();
				else
					currentGame.repeatQuestion();
			}
		}
		public function toggleFullScreen(e:Event)
		{	
			trace("toggle fullscreen " + stage.displayState);
		    if (stage.displayState == StageDisplayState.NORMAL) 
		        fscommand("fullscreen", "true");
		    else
		        fscommand("fullscreen", "false");
		}
		
		public function updateBubbleFeedback()
		{			
			trace("updating bubble feedback");
			
			
			var gameGoal : Goal = currentGame.Data.gameGoal;
			
			if (gameGoal.isBubbleComplete())
			{
				tElements.tBubbleSuccess.text = "Success!";
			}
			else
				tElements.tBubbleSuccess.text = "";
				
			tElements.tBubbleText.text = currentBubbleId.Text;	
			var score : String = gameGoal.successCounter + " / " + gameGoal.totalTasks;
			tElements.tNumSuccess.text = score;
			
			
		}
		
		public function updateTaskTimer(e: Event)
		{
			tElements.tTaskTimer.text = String(currentGame.Data.taskTimerNumber());
			
			//trace(" pex " + currentGame.Data.gameGoal.BadMoves);
			//tElements.tBadMoves.text = "- " + currentGame.Data.gameGoal.BadMoves;
		}
		
		function onMouseIdle(e : MouseIdleMonitorEvent)
		{
			if(currentGame)
			{
				idleCounter++;
				if(currentGame is Game)
					currentGame.Data.repeatQuestion(idleCounter);
				else
					currentGame.repeatQuestion();
			}
			else
			{
				if(tDriver.visible && !tElements.tPreLoader.visible)
				{
					welcomeSound = new WelcomeSound();
					soundChannel = welcomeSound.play();
				}
			}
		}
		
		function onMouseActive(e : MouseIdleMonitorEvent)
		{
			if(currentGame)
			{
				idleCounter = 0;
			}
		}
		
		public function addMoveToLog(pLogObject : Object)
	 	{
	 		DriverData.logTool.addMoveToLog(pLogObject);
	 	}	
		
	}

}
		
		
		    
