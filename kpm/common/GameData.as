package com.kpm.common{	import com.kpm.kpm.BubbleId;import flash.media.SoundTransform;//import com.kpm.kpm.DriverData;	import com.kpm.kpm.EBName;	import com.kpm.kpm.EBScoreType;	import com.kpm.kpm.EBStd;	import com.kpm.kpm.KpmBubble;	import com.kpm.games.*;	import flash.display.MovieClip;	import flash.display.Stage;	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.MouseEvent;	import flash.events.TimerEvent;	import flash.utils.Timer;    import flash.media.SoundMixer;	public class GameData extends EventDispatcher {		public   var gameGoal 			: Goal;		protected 	var state				: EState;		protected 	var feedback			: String;		protected 	var bubble				: BubbleId;		protected 	var gameId				: EGame;		protected 	var lang				: ELanguage		protected 	var kpmSoundPlayer		: KpmSoundPlayer;		protected   var firstTaskSuccess	: int;		protected	var currentTaskSuccess	: int;		public 	var soundLibrary 			: KpmSoundLibrary;		public 	  	var previousState 		: EState;		public 		var firstLevel 			: Boolean = true;		public 		var firstTry			: Boolean = true;		public 		var feedbackSound		: String ;		public 		var keysLocked			: Boolean;		public 		var accompanied			: Boolean;		public 		var bubbleDuration		: Number = 0;		public var updateLevelTimer			: Timer;		protected var playSoundTimer			: Timer;		public var taskTimer				: Timer;		public var taskXML					: XML = new XML(<task></task>);		public var moveFailedXML			: XML = new XML(<failed></failed>);		public static var game 				: Object;		public static var driver			: Object;		//protected 	var taskSuccessCounter	: uint;		//Events constants		public static const INSTRUCTIONS_FINISHED 	: String = "INSTRUCTIONS_FINISHED";		public static const INSTRUCTIONS_IDENTIFY 	: String = "INSTRUCTIONS_Identify";		public static const FEEDBACK_FINISHED		: String = "FEEDBACK_FINISHED";		public static const STATE_CHANGED 			: String = "STATE_CHANGED";		public static const BUBBLE_FINISHED			: String = "BUBBLE_FINISHED";		public static const BUBBLE_FAILED			: String = "BUBBLE_FAILED";		public static const RETURN_TO_DRIVER		: String = "RETURN_TO_DRIVER";		public static const TASK_FINISHED			: String = "TASK_FINISHED";		//Gameplay constants		public static const NUM_IDLE_TO_BLINK		: uint = 1;		public static const BLINK_PERIOD			: uint = 400;		public static const NUM_TIMES_BLINK			: uint = 8;		public static const MAX_IDLE_TIME			: uint = 30000;		public static const MOVE_TO_TARGET_TIME     : uint = 1;		public static const TASK_TIMEOUT			: uint	= 250;		public static const SCORE_PRECISION			: uint = 4;		public static const NUM_STANDARDS			: Number = 8;		public static const TASK_SUCCESS			: uint = 1;		public static const TASK_FAILURE			: uint = 2;		//Directions		public static var UP 			: Point2D = new Point2D( 0,-1);		public static var DOWN 			: Point2D = new Point2D( 0, 1);		public static var RIGHT 		: Point2D = new Point2D( 1, 0);		public static var LEFT 			: Point2D = new Point2D(-1, 0);		public static const arrows : Array = new Array(UP, DOWN, RIGHT, LEFT);		//Sounds		public static const INSTRUCTIONS_INITIAL 	: String = "INSTRUCTIONS_INITIAL_";		public static const INSTRUCTIONS		 	: String = "INSTRUCTIONS_";		public static const GAME_PLAY 			 	: String = "GAME_PLAY";		public static const TRY_AGAIN 	 			: String = "TRY_AGAIN";		public static const INVALID_MOVE  			: String = "INVALID_MOVE";		public static const FEEDBACK_CLICK			: String = "FEEDBACK_Click";		public static const FEEDBACK_CLICK_ONE		: String = "FEEDBACK_Click_One";        public static const SOUNDS_IN_LIBRARY		: Boolean = true;		public static const MUTE_ALL				: Boolean = false;		public static var colorTransforms, colorsRGB , ecolors  : Array;		public static var enumbers5, enumbers3, enumbers2, esizes, sizesNumber : Array ;		//GamePlay variables		public var lvl_NumInstructions		: uint;		public var lvl_LockForInstructions 	: Boolean;		public var lvl_Prompt				: String;		public var lvl_InstructionsSoundName: String;		public var lvl_MaxAttempts			: uint;		public var lvl_TargetMovieNames		: Array;		public var lvl_OptionsMovieNames	: Array;		public var lvl_DifferentScales		: Boolean;		public var lvl_DifferentColors		: Boolean;		public var lvl_HidePlayer			: Boolean;		public var lvl_ClickOnGrid 			: Boolean;		//Numbers		public var lvl_MaxCorrectTargets 	: uint = 2;		public var lvl_MinCorrectTargets 	: uint = 1;		public var lvl_DistractorList		: Array;		public var lvl_ClickTarget			: Boolean;		public var lvl_NumTasks				: uint;		public var lvl_MinTargetValue		: int;		public var lvl_MaxTargetValue		: int;		public var lvl_MiddleTargetValue	: int;		public var lvl_NumOptions			: int;		public var lvl_SubsetValue 			: int;		public var lvl_SubjectsList			: Array;		//Game1 variables		public var lvl_TargetVertical		: Boolean;		public var lvl_TargetHorizontal		: Boolean;		public var lvl_EatTarget			: Boolean;		//Spatial Sense variables		public var lvl_ShowSmallArrows		: Boolean;		public var lvl_AnimateEachTask		: Boolean;		public var lvl_SpatialSense			: Boolean;		public var lvl_MinDistPlayerTarget	: uint;		public var lvl_MaxDistPlayerTarget	: uint;		public var lvl_Obstacles			: Boolean;		public var lvl_NumObstacles			: int = 0;		public var lvl_ObstacleError		: int = 0;		public var lvl_ShowPath				: Boolean;		public var lvl_HoldPosition			: Boolean;		public var lvl_MaxTurnsInPath		: uint;		public var lvl_MaxPerAxe		 	: Number;		public var lvl_SpatialDifference	: uint;		public var lvl_SpaceToCorner		: uint;		// GEOMETRY Variables		public var lvl_DistractorType	: int;		public var lvl_DistractorRotation	: Boolean;		public var lvl_PuzzleIndex 			: int;		public var lvl_ClickShape			: Boolean;		public var lvl_MatchShape			: Boolean;		public var lvl_PlaceShape			: Boolean;		public var lvl_ClickColor			: Boolean;		public var lvl_ClickNumber			: Boolean;		//Board variables		public var board_TileSize			:uint;		public var board_NumCols			:uint;		public var board_NumRows			:uint;		public var board_PixelOffset		:Point2D;        public var lvl_DefaultColor         : Boolean;        public var lvl_TargetScale          : Number;        public static var parameters : Array;        public static const PARAMETER_PANEL : String = "parametersPanel";        function GameData(pBubble : BubbleId, pLanguage : ELanguage, pGame : Object)		{			//Dynamic			bubble = pBubble;			if(!bubble)				GameData.reportError("no bubble in gamedata!");			game = pGame;			currentTaskSuccess = 0;			gameId = game.Name;			updateGoal();			soundLibrary = new KpmSoundLibrary([ELanguage.ENG, ELanguage.SPA, ELanguage.OBI, ELanguage.ALL]);			if(!gameGoal)				GameData.reportError("no GameGoal!");            Util.debug("peeeexx" + pGame.parent + " " + pGame.parent.parent);			if(pGame.parent.parent.parent)			{				driver = pGame.parent;			}            else                driver = null;			lang = pLanguage;			kpmSoundPlayer = KpmSoundPlayer.getInstance(true);			taskTimer = new Timer(250 ,  GameData.TASK_TIMEOUT);			if(driver)			{				taskTimer.addEventListener(TimerEvent.TIMER, driver.updateTaskTimer, false, 0 , true);				accompanied = driver.Accompanied;			}			//list of colors and numbers used for IdentifyColor, IdentifyNumeral, Finger, 5Frame			ecolors = [EColor.Red, EColor.Blue, EColor.Yellow, EColor.Green, EColor.Orange];			esizes = [ESize.Big, ESize.Small];			//Colortransforms stores the amount of red, green, blue needed to multiply a grayed valued			//MovieClip for each color			colorTransforms = new Array(ecolors.length + 1);			colorTransforms[EColor.Red.Text] 	= {ra: 1, rb: 0.5, ga: 0, gb: 0, ba: 0, bb: 0};			colorTransforms[EColor.Blue.Text] 	= {ra: 0, rb: 0, ga: 0.3, gb: 0, ba: 1, bb: 0};		    colorTransforms[EColor.Yellow.Text] = {ra: 1.3, rb: 0, ga: 1, gb: 0, ba: 0, bb: 0};		    colorTransforms[EColor.Green.Text] 	= {ra: 0, rb: 0, ga: 0.8, gb: 0.5, ba: 0, bb: 0};			colorTransforms[EColor.Orange.Text] = {ra: 1, rb: 1, ga: 0.5, gb: 0.5, ba: 0, bb: 0};	   	   	colorTransforms[EColor.Brown.Text] 	= {ra: 0.4, rb: 0, ga: 0.2, gb: 0, ba: 0.05, bb: 0};	   	    colorTransforms[EColor.Purple.Text]	= {ra: 0.5, rb: 0, ga: 0, gb: 0, ba: 0.65, bb: 0};	   	    colorTransforms[EColor.Black.Text]	= {ra: 0.5, rb: 0.5, ga: 0.5, gb: 0, ba: 0, bb: 0};			//colorsRGB stores the RGB representation of that color	   	    colorsRGB = new Array(ecolors.length + 1);	   	    colorsRGB[EColor.Red.Text] 		= 0xFF0000;			colorsRGB[EColor.Blue.Text] 	= 0x0000FF;		    colorsRGB[EColor.Yellow.Text] 	= 0xFFFF00;		    colorsRGB[EColor.Green.Text] 	= 0x00FF00;	   	   	colorsRGB[EColor.Brown.Text] 	= 0x664411;			colorsRGB[EColor.Orange.Text] 	= 0xFF7700;	   	    colorsRGB[EColor.Purple.Text]	= 0x6600CC;	   	    colorsRGB[EColor.Black.Text]	= 0x444444;			sizesNumber = new Array(esizes.length)			sizesNumber[ESize.Big.Text] = 1;			sizesNumber[ESize.Medium.Text] = 0.75;			sizesNumber[ESize.Small.Text] = 0.5;			//Events			if(gameId == EGame.G1 || gameId == EGame.G2)			{				soundLibrary.addEventListener(KpmSound.INSTRUCTIONS_FINISHED, onInstructionsFinished);				soundLibrary.addEventListener(GameData.FEEDBACK_FINISHED, pGame.onFeedbackFinished);				addEventListener (GameData.STATE_CHANGED, pGame.onStateChanged);				addEventListener (GameData.TASK_FINISHED, pGame.onTaskFinished);				addEventListener (GameData.BUBBLE_FINISHED, pGame.onBubbleFinished);			}			if(gameId == EGame.G4)			{				Util.debug("GameData.adding events for G4");				soundLibrary.addEventListener(GameData.TASK_FINISHED, pGame.onTaskFinished);				soundLibrary.addEventListener(GameData.FEEDBACK_FINISHED, pGame.onFeedbackFinished);			}			pGame.addEventListener (Event.REMOVED_FROM_STAGE, onRemove);		}		public static function generateENumbers(pMin : int, pMiddle : int, pMax : int)		{			var enumbers : Array = new Array();			for (var i= pMin; i <= pMax ; i++)			{				enumbers.push(ENumber.getEnum(i));				if(pMiddle > 0 && i >= pMiddle)					enumbers.push(ENumber.getEnum(i));			}			return enumbers;		}		public function onTaskFinished(e:Event)		{			Util.debug("task finished", this);			if(game is Game)				initializeMusic();			if(driver)			{				Util.debug("starting task timer");				taskTimer.start();				simulateMouseMoving();			}		}		public function updateTask(pTime : int)		{			if(isBubbleFinished())			{				Util.debug("returning to driver", this);				updateLevelTimer = new Timer(pTime , 1);				updateLevelTimer.start();				updateLevelTimer.addEventListener(TimerEvent.TIMER, returnToDriver);			}			else			{				Util.debug("task finished", this);				this.dispatchEvent(new Event(TASK_FINISHED));			}		}		public function returnToDriver(e: Event)		{			Util.debug("returning to driver", this);			if(driver)				this.dispatchEvent(new Event(RETURN_TO_DRIVER));			else				this.dispatchEvent(new Event(BUBBLE_FINISHED));		}		public function recordMove(pSuccess : uint, pCurrentGoal : Object = null, pCurrentMove : String = null)		{			if(pCurrentGoal)	CurrentGoal = pCurrentGoal;			if(pCurrentMove)	gameGoal.currentMove = pCurrentMove;			CurrentTaskSuccess = pSuccess;		}		public function get DistanceFromTarget() : uint { return gameGoal.distanceFromTarget; }		public function get CurrentGoal() : Object { return gameGoal.currentGoal; }		public function set DistanceFromTarget(pDist : uint)		{			Util.debug("set dist " + gameGoal.distanceFromTarget);			if(gameGoal.distanceFromTarget == 0)			{				gameGoal.distanceFromTarget = pDist;				Util.debug("set dist " + gameGoal.distanceFromTarget);			}		}		public function set CurrentGoal(pCurrentGoal : *)		{			Util.debug("setting current goal" + pCurrentGoal, this);			if(!pCurrentGoal)	return;			gameGoal.currentGoal = pCurrentGoal;			if(pCurrentGoal is String || pCurrentGoal is Number)				gameGoal.currentGoalText = pCurrentGoal;			else				gameGoal.currentGoalText = pCurrentGoal.Text;		}		public function set CurrentTaskSuccess(pSuccess : uint)		{			Util.debug("setting task success to" + pSuccess + "if its the first task" + firstTaskSuccess);			gameGoal.attemptCounter++;			currentTaskSuccess = pSuccess;			if(tooManyAttempts() && currentTaskSuccess != GameData.TASK_SUCCESS)				State = EState.TOO_MANY_ATTEMPTS;			Util.debug("first task success ? " + firstTaskSuccess);			if(firstTaskSuccess == 0)			{				gameGoal.taskCounter++;				firstTaskSuccess = currentTaskSuccess;                Util.debug("updating task counter to " + gameGoal.taskCounter)				FirstMove = 0;				if(Bubble.Name.ScoreType == EBScoreType.Choice)				{					computeScore_CHOICE();					if(driver) driver.updateBubbleFeedback();				}				if(Bubble.Name.ScoreType == EBScoreType.Proximity)				{					if(currentTaskSuccess == GameData.TASK_SUCCESS)						DistanceFromTarget = game.getDistanceToTarget(false);					else						DistanceFromTarget = game.getDistanceToTarget(true);				}			}            if(Bubble.Name.ScoreType != EBScoreType.Choice)			if(currentTaskSuccess == GameData.TASK_SUCCESS || State == EState.TOO_MANY_ATTEMPTS)			{				if(Bubble.Name.ScoreType == EBScoreType.Path)				{					computeScore_PATH();					if(driver) driver.updateBubbleFeedback();				}				if(Bubble.Name.ScoreType == EBScoreType.Proximity)				{					computeScore_PROXIMITY();					if(driver) driver.updateBubbleFeedback();				}                if(currentTaskSuccess == GameData.TASK_SUCCESS)                    gameGoal.succededTaskCounter++;            }			if(driver)			{				logTask();				driver.addToLog(taskXML);			}			Util.debug("GameData.tasks : " + gameGoal.succededTaskCounter + " " + gameGoal.taskCounter + " " + gameGoal.totalTasks);			if(isBubbleFinished() && (Bubble.Name.ScoreType == EBScoreType.Choice || currentTaskSuccess == GameData.TASK_SUCCESS))			{				if(driver)					this.dispatchEvent(new Event(BUBBLE_FINISHED));			}		}		public function isBubbleFinished() : Boolean		{			Util.debug("task counter " + gameGoal.taskCounter + " totalTasks " + gameGoal.totalTasks);			if(gameGoal.taskCounter >= gameGoal.totalTasks)				return true;			return false;		}		public function tooManyAttempts() : Boolean		{			if(State == EState.TOO_MANY_ATTEMPTS)				return false;			Util.debug("max attempts " + lvl_MaxAttempts, this);			Util.debug("attempts " + gameGoal.attemptCounter, this);			Util.debug("length path " +gameGoal.lengthPath);			Util.debug("length optimal path"+ gameGoal.lengthOptimalPath*2);			var tooMany : Boolean =			lvl_MaxAttempts > 0 && gameGoal.attemptCounter >= lvl_MaxAttempts;			return tooMany;		}		public function computeScore_CHOICE()		{			// sqrt [(n-m)/m]   if  the answer is correct  			// sqrt [m/(n-m)]   if  the answer is wrong (yes, sqrt is sqaure root).  			if(gameGoal.quality == EGoal.COUNT && gameId == EGame.G1)  			{  				gameGoal.numOptions = Math.min(5, lvl_MaxTargetValue);  				gameGoal.numCorrectOptions = 1;  			}  			var n : Number = gameGoal.numOptions;  			var m : Number = gameGoal.numCorrectOptions;  			Util.debug("computing score", this);  			Util.debug(" n " + n + " m " + m , this);  			if(firstTaskSuccess == GameData.TASK_SUCCESS)  			{  				gameGoal.succededTaskCounter++;  				gameGoal.taskScore = Util.round(Math.sqrt((n-m)/(n+m)), GameData.SCORE_PRECISION);  				if (gameGoal.taskScore == 0)  					gameGoal.taskScore+= 0.2;  			}  			else if (firstTaskSuccess == GameData.TASK_FAILURE)  			{  				gameGoal.taskScore = Util.round(-Math.sqrt((n+m)/(n-m)), GameData.SCORE_PRECISION);  			}  			gameGoal.globalScore += gameGoal.taskScore;  			gameGoal.globalScore = Util.round(gameGoal.globalScore, GameData.SCORE_PRECISION);  			Util.debug(gameGoal, this);		}		function computeScore_PATH()		{			//opt/clicks			if(DistanceFromTarget != 0)				gameGoal.taskScore = 0;			else			{				var opt : Number = gameGoal.lengthOptimalPath;				var clicks : Number = gameGoal.lengthPath;				Util.debug("computing score", this);  				Util.debug(" opt" + opt + " clicks " + clicks , this);				gameGoal.taskScore = Util.round(opt/clicks, GameData.SCORE_PRECISION);  			}  			Util.debug(" taskScore " + gameGoal.taskScore, this);  			gameGoal.globalScore += gameGoal.taskScore;  			gameGoal.globalScore = Util.round(gameGoal.globalScore, GameData.SCORE_PRECISION);  			Util.debug(gameGoal, this);		}		function computeScore_PROXIMITY()		{			//opt/clicks			var L : Number = gameGoal.lengthOptimalPath;			var d : Number = DistanceFromTarget;			Util.debug("computing score", this);  			Util.debug(" L " + L + " distanceFromTarget " + d , this);			gameGoal.taskScore = Util.round(((L - d)/L) * ((L - d)/L), GameData.SCORE_PRECISION);			if((L-d) < 0)		gameGoal.taskScore*= -1;  			Util.debug(" taskScore " + gameGoal.taskScore, this);  			gameGoal.globalScore += gameGoal.taskScore;  			gameGoal.globalScore = Util.round(gameGoal.globalScore, GameData.SCORE_PRECISION);  			Util.debug(gameGoal, this);		}		function logTask()		{			var success : Boolean ;			if(firstTaskSuccess == GameData.TASK_SUCCESS)            {					success = true;                    taskXML.@success = 1;            }			else            {                success = false;                taskXML.@success = 0;            }			if (currentTaskSuccess == GameData.TASK_SUCCESS || State == EState.TOO_MANY_ATTEMPTS)			{				taskXML.@taskScore = gameGoal.taskScore;				taskXML.@globalScore = gameGoal.globalScore;				taskXML.@timeOfClick = String(taskTimerNumber());				taskXML.@timeFirstMove = String(gameGoal.timeFirstMove);				taskXML.@goal = gameGoal.currentGoalText;				taskXML.@badMoveCounter = gameGoal.attemptCounter-1;				bubbleDuration += taskTimerNumber();                taskXML.@TaskID = Util.getSecondsFrom1970();                //taskXML.@KidName = DriverData.currentKidXML.FIRST_NAME + " " + DriverData.currentKidXML.LAST_NAME;                if(Bubble.Name.ScoreType == EBScoreType.Choice)				{					taskXML.@numberOfObjects = gameGoal.numOptions;					taskXML.@numberOfGoal = gameGoal.numCorrectOptions;				}				else if(Bubble.Name.ScoreType == EBScoreType.Path || Bubble.Name.ScoreType == EBScoreType.Proximity)				{					taskXML.@numBackTracks = gameGoal.backtrackCounter;					taskXML.@lengthOfOptimalPath = gameGoal.lengthOptimalPath;					taskXML.@lengthOfPath = gameGoal.lengthPath;					taskXML.@distanceFromTarget = DistanceFromTarget;				}			}			else			{				//moveFailedXML.@taskScore = gameGoal.taskScore;				//failedObject.@globalScore = gameGoal.globalScore;                moveFailedXML.@goal = gameGoal.currentGoalText;				moveFailedXML.@timeOfClick = String(taskTimerNumber());				moveFailedXML.@failedMove = gameGoal.currentMove;				taskXML.appendChild(moveFailedXML);				moveFailedXML = new XML(<failed></failed>);			}		}		public function startTask(pNumObjects : int, pNumGoals : int)		{			gameGoal.numOptions = pNumObjects;	  		gameGoal.numCorrectOptions = pNumGoals;	  		resetTask();	  		onTaskFinished(null);		}		public function resetTask()		{			taskTimer.reset();			soundLibrary.forceStop();		    resetSuccess();			taskXML = new XML(<task></task>);			gameGoal.attemptCounter = 0;			gameGoal.backtrackCounter = 0;			gameGoal.timeFirstMove = 0;		}		public function resetSuccess()		{			Util.debug("resetting success", this);			currentTaskSuccess = 0;			firstTaskSuccess = 0;		}		public function stopTaskTimer()		{			taskTimer.stop();		}		public function taskTimerNumber() : Number		{			return (taskTimer.currentCount*taskTimer.delay)/1000;		}		public function onRemove(e : Event)		{			Util.debug("GameData.onRemove", this);			if(SoundPlayer)				SoundPlayer.stopSounds(false);            SoundMixer.stopAll();            if(soundLibrary)            {                soundLibrary.forceStop();                soundLibrary.soundManager.soundTransform = new SoundTransform(0,0);                if(game.Name != EGame.G3)                {                    soundLibrary.removeEventListener(KpmSound.INSTRUCTIONS_FINISHED, onInstructionsFinished);                    soundLibrary.removeEventListener(GameData.FEEDBACK_FINISHED, game.onFeedbackFinished);                    soundLibrary.removeEventListener(GameData.TASK_FINISHED, game.onTaskFinished);                }			    game.onRemove(null);            }		}		public function mute()		{			SoundPlayer.toggleMute();		}		public function simulateMouseMoving()		{			if(driver)				driver.stage.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE));		}		public function repeatQuestion(idleCounter : uint = 0)		{			if(idleCounter == GameData.NUM_IDLE_TO_BLINK)			{				game.blinkSolution();			}		}		public function updateGoal()		{			Util.debug("define gameGoal", this);			var tempTotalTasks : uint;			var goalType : EGoal;			if(!Bubble.Name)				GameData.reportError("no bubble name");			if(gameId == EGame.G1 || gameId == EGame.G3)			{				if(Bubble.Name.Text.indexOf("Identify") != -1 )				{					if(Bubble.Level >= 0)					{						tempTotalTasks = 7;						goalType = EGoal.NUMBER;					}					if(Bubble.Level >= 2)					{						tempTotalTasks = 6;					}					if(Bubble.Level >= 3)					{						tempTotalTasks = 5;					}				}				if(Bubble.Name == EBName.SpatialSense || Bubble.Name == EBName.VirtualPath)				{					tempTotalTasks = 5;					goalType = EGoal.SPATIAL;				}				else if (Bubble.Name == EBName.IdentifySpatial)				{					tempTotalTasks = 4;					goalType = EGoal.SPATIAL;				}				else if (Bubble.Name == EBName.IdentifyColor)				{					tempTotalTasks = 6;					goalType = EGoal.COLOR;				}				else if (Bubble.Name == EBName.IdentifySize)				{					tempTotalTasks = 6;					goalType = EGoal.SIZE;				}				else if (Bubble.Name.Standard == EBStd.Numbers_Count ||						 Bubble.Name.Standard == EBStd.Numbers_Subset)				{					if(Bubble.Name.Text.indexOf("_3") != -1)						tempTotalTasks = 7;					else						tempTotalTasks = 6;					goalType = EGoal.COUNT;				}			}			else if (gameId == EGame.G2)			{				if (Bubble.Name == EBName.MatchShape)				{					goalType = EGoal.SHAPE;				}				if (Bubble.Name == EBName.IdentifyShape)				{					goalType = EGoal.SHAPE;				}				else if (Bubble.Name == EBName.IdentifyColor)				{					goalType = EGoal.COLOR;				}			}			else if(gameId == EGame.G4)			{				if (Bubble.Name.Standard == EBStd.Numbers_Count ||				 Bubble.Name.Standard == EBStd.Numbers_Subset)				{					tempTotalTasks = 5;					goalType = EGoal.COUNT;				}				if (Bubble.Name.Standard == EBStd.Numbers_Identify)				{					tempTotalTasks = 5;					goalType = EGoal.NUMBER;				}				if(Bubble.Name.Standard == EBStd.Addition){					//Múltiplico el verdadero numTask de la especificación porque cada task tiene ahora dos question. Es la forma más sencilla de					//implementar esta bubble					var firsPart   : String = Bubble.Name.Text.split("_")[0]; //ChangePlus1 or ChangePlus2 or ChangePlusU					var secondPart : String = Bubble.Name.Text.split("_")[1]; //3 or 4 or 5 or ...					switch (firsPart) {						case "ChangePlus1":											switch (secondPart) {												case "3": tempTotalTasks = 3; break;												case "4":												case "5":												case "7":												//case "10": tempTotalTasks = 5; break;												case "10": tempTotalTasks = 3; break;											}											break;						case "ChangePlus2":											switch (secondPart) {												case "4": tempTotalTasks = 3; break;												//case "5": tempTotalTasks = 5; break;												case "5": tempTotalTasks = 3; break;											}											break;						case "ChangePlusU": tempTotalTasks = 5; break;					}					goalType = EGoal.ADDITION;				}				if (Bubble.Name.Standard == EBStd.Comparison)				{					tempTotalTasks = 5;					goalType = EGoal.COMPARISON;				}			}            else if(gameId == EGame.G5)            {                if (Bubble.Name.Standard == EBStd.PlaceNumber)                {                    goalType = EGoal.PLACE_NUMBER;                    if(Bubble.Level == 1)                        tempTotalTasks = 3;                    else if (Bubble.Level > 1)                        tempTotalTasks = 5;                }            }			else			{				Util.debug("no gameGoal!", this);			}			Util.debug("game goaltype " + goalType + " " + gameId.Text + " " + Bubble.Name.Standard);			if(Bubble.TotalTasks > 0)				tempTotalTasks = Bubble.TotalTasks;			gameGoal = new Goal(tempTotalTasks, goalType);			Util.debug(gameGoal, this);		}		public function createSound(pName : String, pRandomOptions : Number = 1,									pVolume : Number = 1, pGame : Boolean = false,									pLanguage :Boolean = true,pLibrarySound : Boolean = false) : KpmSound		{			var randomNum 	: uint;			var path 		: String;			var separator 	: String;			if(SOUNDS_IN_LIBRARY)			{				path = "";				separator = ".";				pLibrarySound = true;			}			else			{				path = "data/sounds/";				separator = "/";			}			if(pLanguage)	path += Language.Text + separator;			if(pGame) 		path += GameId.Text + separator;			if(pRandomOptions > 1)			{				randomNum = Util.getRandBtw(1,pRandomOptions);				pName += randomNum;			}			Util.debug("name is " + path + pName, this);			if(pLibrarySound)			{				return new KpmSound(null, null, pVolume, null, null, Util.createSound(path + pName))			}			else			{				return new KpmSound(path, pName, pVolume);			}		}		function onInstructionsFinished(e: Event)		{			//simulateMouseMoving();			Util.debug("on instructions finished", this);			if(game is Game)            {                game.unLockKeys(null);            }			//driver.updateBubbleFeedback();			firstLevel = false;		}		public function initializeMusic()		{			Util.debug("GameData.initializeMusic" + SoundPlayer.musicChannel + " " + SoundPlayer.musicSound, this);            if(!SoundPlayer.musicChannel)            {                var ks: KpmSound = game.createMusic();                if(ks)                {                    ks.loop = 100;                    ks.isMusic = true;                    SoundPlayer.playSound(ks);                }            }		}//		public function playSound(pLang : ELanguage, pGame : EGame, pChar : EGameCharacter, pBubbleName : EBName, pSoundType : ESoundType, pAttribute : Object = null)//		{//			soundLibrary.playSound(pLang, pGame, pChar, pBubbleName, pSoundType, pAttribute);//		}		public function set State(pState : EState)		{			Util.debug("setting state to " + pState.Text, this);			state = pState;			this.dispatchEvent(new Event(STATE_CHANGED));		}		public static function reportError(pString : String)		{			throw new Error (pString);		}		public function get State()		{			return state;		}		public function set FirstMove(pTime : Number)		{			if(gameGoal.timeFirstMove == 0)				if(pTime == 0)					gameGoal.timeFirstMove = taskTimerNumber();				else					gameGoal.timeFirstMove = pTime;		}		public function get Bubble() : BubbleId  			{return bubble;}		public function get SoundPlayer() : KpmSoundPlayer 	{ return kpmSoundPlayer }		public function get GameId () : EGame 			{ return gameId; }		public function get Language () : ELanguage 		{ return lang; }	}}