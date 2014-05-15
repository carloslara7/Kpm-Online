package com.kpm.kpm
{
import com.kpm.common.ELanguage;
	import com.kpm.common.KpmFtp;
	import com.kpm.common.KpmIO;
	import com.kpm.common.Util;
	import com.kpm.games.walkthewalk.Character;
import com.kpm.kpm.Kid;
import com.kpm.kpm.Kid;
import com.kpm.reporter.excel.Kid;
	import com.kpm.ui.*;

import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

import flash.system.Capabilities;
    //import com.freshplanet.ane.AirImagePicker.AirImagePicker;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.*;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	import fl.controls.RadioButtonGroup;
	import flash.text.TextFormat;
	import com.kpm.common.KpmComboBox;
	
	
	
	public class KidCreatorPage extends UIPage
	{
		var kidProfileFile 			: KpmIO;
		var kidsNamesFile			: KpmIO;
		var kidProfileXML			: XML;
		var firstName, lastName 	: String;
		var age 					: uint;
		var primaryLanguage		 	: ELanguage;
		var gameLanguage			: ELanguage;
		var ftp1, ftp2				: KpmFtp; 
		var kidId					: String;
		var picSource				: File;
		var newPicSource			: File;
        var pictureIpad             : KpmIO = new KpmIO();
		var picDest					: KpmIO;
        var imageName               : String;
		var inputValid				: Boolean ;
		var imageLoader : Loader = new Loader();
		var currentTimeoutId		: uint;
		var newPicture 				: Boolean = false;
		var levelRadioGroup			:RadioButtonGroup;
		var tf : TextFormat = new TextFormat(); 
		
		
		public static const KID_CREATED : String = "KID_CREATED";
		public static const CANCEL : String = "CANCEL";
        var profileLoader : URLLoader = new URLLoader();
        var urlParams : URLVariables = new URLVariables();
		
		public function KidCreatorPage() {
			super(UIConst.KidCreatorPage);
			setComboBoxStyle();
			
		}
		
		public override function showPage(e : Event = null)
		{
			//populateKidProfile;
			//addEventListener(send init event. readyToFill)
			readyToFill();
			
			super.showPage();
		}

		//Set default all fields, add Events
		public function readyToFill()
		{
			//Security.loadPolicyFile("http://www.kidsplaymath.org/crossdomain.xml");
			tFirstName.stage.focus = tFirstName;
			doEditPlayer_Bt.visible = !DriverData.createKid;
			doCreatePlayer_Bt.visible = DriverData.createKid;
			if(imageLoader)
				Util.removeChild(imageLoader);
				
			imageLoader = new Loader();
				
			if(DriverData.createKid)
				fillCreateFields();
			else
				DriverData.getInstance().populateKidProfileFromXML1(container.pages[UIConst.ClassPage].getSelectedKids()[0], fillEditFields);
				
			//doCreatePlayer_Bt.enabled = false;
			//doCreatePlayer_Bt.buttonMode = true;

			tBrowse_Bt.addEventListener(MouseEvent.CLICK, onBrowseButton_Click);

			
			kidProfileFile = new KpmIO();
			kidsNamesFile = new KpmIO();
			picDest = new KpmIO();
				
			ftp1 = new KpmFtp();
			ftp2 = new KpmFtp();
			//ftpFile.downloadFromFtp(DriverData.FTP_SERVER, DriverData.FTP_PROFILE_PATH, DriverData.FTP_PROFILE_FILE);
			
			//downloadRegisterInfo();
		}
		
		function fillCreateFields()
		{	
			setRadioButtonStyle(false);
			
			tFirstName.text = "";
			tFirstName.tabIndex = 1;
			tLastName.text = "";
			tLastName.tabIndex = 2;
			tAge.text = "";
			tAge.tabIndex = 3;
			tPrimaryLanguage_Cb.selectedIndex = 0; 
			tPrimaryLanguage_Cb.tabIndex = 4
			tGameLanguage_Cb.selectedIndex = 0;
			tGameLanguage_Cb.tabIndex = 5;
			
			
			
			
			doCreatePlayer_Bt.addEventListener(MouseEvent.CLICK, doCreatePlayer);
			cancel_Bt.addEventListener(MouseEvent.CLICK, cancelCreatePlayer);
		}
		
		function fillEditFields(e : Event)
		{
			DriverData.getInstance().kidFile.removeEventListener(KpmIO.READ_COMPLETE, fillEditFields);
			DriverData.getInstance().kidFile.removeEventListener(KpmIO.READ_ERROR, fillEditFields);
						
						
			if(e.type == KpmIO.READ_COMPLETE)
			{
				setRadioButtonStyle(true);
				
				kidProfileXML = XML(DriverData.getInstance().kidFile.readContents);
				
				tFirstName.text = kidProfileXML.FIRST_NAME;
				tFirstName.tabIndex = 1;
				tLastName.text =  kidProfileXML.LAST_NAME;
				tLastName.tabIndex = 2;
				tAge.text =  kidProfileXML.AGE;
				tAge.tabIndex = 3;
				tPrimaryLanguage_Cb.selectedIndex = kidProfileXML.PRIMARY_LANGUAGE == "ENG" ? 0 : 1;
				//tPrimaryLanguage.text =  ;
				tPrimaryLanguage_Cb.tabIndex = 4
				tGameLanguage_Cb.selectedIndex = kidProfileXML.GAME_LANGUAGE == "ENG" ? 0 : 1;
				tGameLanguage_Cb.tabIndex = 5;
				
				Util.debug("fill edit fields " + tPrimaryLanguage_Cb.selectedIndex + " "  + tGameLanguage_Cb.selectedIndex);
				
				
				if("LEVEL" in kidProfileXML)
				{
					Util.debug("level in kidprofileXML");
						
					switch (int(kidProfileXML.LEVEL))
					{
						case 3  : levelRadioGroup.selection = rb_1; break;
						case 4  : levelRadioGroup.selection = rb_2; break;
						case 5  : levelRadioGroup.selection = rb_3; break;
					}
				}
				else 
					levelRadioGroup.selection = rb_1;
				
				
				Util.debug(kidProfileXML.LEVEL + " " + levelRadioGroup.selection)
				
				Util.debug("KpmCreatorPage.FillEditFields picture path" + container.pages[UIConst.ClassPage].getSelectedKids()[0]);
				Util.printArray(container.pages[UIConst.ClassPage].getSelectedKids());
				
				picSource = File.applicationStorageDirectory.resolvePath(DriverData.getKidFolder(container.pages[UIConst.ClassPage].getSelectedKids()[0]) + ".jpg");
				onKidIconSelected(null);
				newPicture = false;
			}	
			else if(e.type == KpmIO.READ_ERROR)
			{
				DriverData.logTool.reportError ("error could not read profile file when editing");
			}
			
			doEditPlayer_Bt.addEventListener(MouseEvent.CLICK, doCreatePlayer);
			cancel_Bt.addEventListener(MouseEvent.CLICK, cancelCreatePlayer);
		}
		
		function setRadioButtonStyle(pVisible : Boolean = false)
		{
			tDefaultProgress.visible = rb_1.visible = rb_2.visible = rb_3.visible = pVisible;
			
			levelRadioGroup = new RadioButtonGroup("Group 2");
			
			var tf : TextFormat = new TextFormat(); 
			tf.color = 0x660066; 
			tf.font = "GROBOLD"; 
			tf.size = 16; 
			
				
			rb_1.group= levelRadioGroup; rb_2.group= levelRadioGroup; rb_3.group= levelRadioGroup;
			rb_1.setStyle("textFormat", tf);rb_2.setStyle("textFormat", tf); rb_3.setStyle("textFormat", tf);
			rb_1.value = 3; rb_2.value = 4; rb_3.value = 5;
			rb_1.width				 = 300; rb_2.width				 = 300; rb_3.width   			 = 300; 
			rb_1.textField.width     = 300;	rb_2.textField.width     = 300; rb_3.textField.width     = 300;
			
			
			rb_1.label = "Beginner (average 3 years old)";
			rb_2.label = "Intermediate (average 4 years old)";
			rb_3.label = "Advanced (average 5 years old)";
		}
		
		function setComboBoxStyle()
		{
			var my_tf:TextFormat = new TextFormat();
			my_tf.size = 26;
			my_tf.font = "Calibri";
			
			UIGod.setDropdownStyle(tPrimaryLanguage_Cb, my_tf, 235,45);
			UIGod.setDropdownStyle(tGameLanguage_Cb, my_tf, 235,45);

            tPrimaryLanguage_Cb.dropdown.rowHeight = 40;
            tGameLanguage_Cb.dropdown.rowHeight = 40;
			
			tPrimaryLanguage_Cb.addItem({label:"English", data : "ENG"});
			tPrimaryLanguage_Cb.addItem({label:"Spanish", data : "SPA"});
			tPrimaryLanguage_Cb.addItem({label:"Objiwe", data : "OBI"});
			
			tGameLanguage_Cb.addItem({label:"English", data : "ENG"});
			tGameLanguage_Cb.addItem({label:"Spanish", data : "SPA"});
			tGameLanguage_Cb.addItem({label:"Objiwe", data : "OBI"});
			
		}
	
    	
		function onBrowseButton_Click( e : Event)
		{
			Util.debug("KidCreatorPage.onBrowseButtonClick");
            tValidPic.text = "";


            if(Capabilities.manufacturer.indexOf("iOS") != -1)
            {
//                var imagePicker : AirImagePicker = AirImagePicker.getInstance();
//                imagePicker.displayImagePicker(function(status:String, ...mediaArgs):void {
//                    Util.debug("image selected " + status) ;
//                    onPicSelectedIpad(mediaArgs);
//
//                });


                var kidsFolder:File = File.documentsDirectory.resolvePath("KidsPlayMath/Icons");
                var files:Array = kidsFolder.getDirectoryListing();
                var random = Util.getRandBtw(0, files.length);

                Util.debug("Got a random icon" + kidsFolder.url)

                //Read the file.

                imageName = Util.getFileName(files[random].name);

                pictureIpad.setFilePath("KidsPlayMath/Icons/" + files[random].name, "documents");
                pictureIpad.addEventListener(KpmIO.READ_COMPLETE, onPicSelectedIpad, false, 0 , true);
                pictureIpad.addEventListener(KpmIO.READ_ERROR, onPicSelectedIpad, false, 0 , true);
                pictureIpad.read();

                Util.debug("reading file " + kidsFolder.url + files[random].name);

//                for (var i:uint = 0; i < files.length; i++)
//                {
//                    trace(files[i].nativePath); // gets the path of the files
//                    trace(files[i].name);// gets the name
//
//                }


            }
            else
            {
                var imagesFilter:FileFilter = new FileFilter("Images", "*.jpg;*.gif;*.png");
                newPicSource = File.documentsDirectory.resolvePath("KidsPlayMath/Icons");
                newPicSource.browse([imagesFilter]);
                newPicSource.addEventListener(Event.SELECT, onKidIconSelected);

            }
			
			
		}

        function onPicSelectedIpad(e : Event)
        {
            Util.debug("KidCreatorPage.onPicSelectedIpad " + e.toString());

            newPicture = true;

            var request:URLRequest = new URLRequest(pictureIpad.mFile.url);

            Util.debug("requesting pictureIpad.mFile.Url " + pictureIpad.mFile.url);

            Util.removeChild(imageLoader);
            imageLoader.load(request);
            imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
            tImage.addChild(imageLoader);

            if(DriverData.createKid)
                kidId = getLastKidId();
            else
                kidId = container.pages[UIConst.ClassPage].getSelectedKids()[0];

            picDest.setFilePath(DriverData.getKidFolder(kidId) + ".jpg");
            picSource = pictureIpad.mFile;


        }
		
		function onKidIconSelected( e : Event)
		{
			newPicture = true;
            Util.debug("onKidIconSelected");
            if(e)
				picSource = newPicSource;

            var picSourceURL : String = picSource.url;


            imageName = Util.getFileName(picSource.url);

            //Validation only needed when browsing for pic
            if(picSourceURL.indexOf(".jpg") == -1 && picSourceURL.indexOf(".png") == -1 && picSourceURL.indexOf(".gif") == -1)
            {
                reportError("Format not recognized, pic try again");
                return;
            }

            if(picSource && picSource.size > 400000)
                reportError("picture too large. Try smaller than 400 KBs", false);

            if(DriverData.createKid)
                kidId = getLastKidId();
            else
                kidId = container.pages[UIConst.ClassPage].getSelectedKids()[0];

            picDest.setFilePath(DriverData.getKidFolder(kidId) + ".jpg");
			
			var request:URLRequest = new URLRequest(picSource.url);
			Util.removeChild(imageLoader);
			imageLoader.load(request);
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
			tImage.addChild(imageLoader);
			

			
		}
		
		function imageLoaded(e : Event)
		{
			var bm : Bitmap = Bitmap(imageLoader.content);
			bm.smoothing = true;
			
			tImage.height = 100;
			tImage.width = 100;	
		}


		function getLastKidId() : String
		{
			var kidFolder : KpmIO = new KpmIO();
			/*
            var id : String = DriverData.configXML.classes.@currentId + DriverData.FIRST_KID_ID;

            var i = 0;

			do
			{
				
				kidFolder.setFilePath(DriverData.getKidFolder() + id);
				
				if(kidFolder.exists())
					id = getNextKidId(id);
				else
					break;
				i++;
				Util.debug( id + " exists ?");
			}
			while(i < 100);
			
			*/

			kidId =  DriverData.configXML.classes.@currentId + (Util.getSecondsFrom1970() % 1000000000);
			picDest.setFilePath(DriverData.getKidFolder(kidId) + ".jpg");
			
			return kidId;
		}
		
		function getNextKidId(pKidId : String) : String
		{
			var lastIdInt : int = Number(pKidId);
			lastIdInt++;
			
			//Util.debug("lastId" + lastIdInt)
			
			var newIdStr : String = String(lastIdInt);
			var length : uint = 9 - newIdStr.length;
			
			//Util.debug("new id " + newIdStr);
			//Util.debug("new id " + length);
			
			for(var i=0; i < length ; i++)
			{
				//Util.debug("adding 0");
				newIdStr = "0" + newIdStr;
			}
			
			Util.debug("new id " + newIdStr);
			trace("");
			
			return newIdStr;
		}
		
		function onProfileError( e : Event)
		{
			reportError("Could not copy file", false);
		}
		
		function onProfilePicCopied( e : Event)
		{
			tBrowse_Bt.addEventListener(MouseEvent.CLICK, onBrowseButton_Click)
			
			Util.debug("image height " + tImage.height);
			tImage.height = 100;
			tImage.width = 100; 
			
			if(!picDest.exists())
				reportError("profile picture does not exist (?)", false);
		}
		
		function cancelCreatePlayer(e : Event)
		{
			container.goBack(null);
		}

        // NOT CREATING QR CODE FOR NOW.
        // BASIC FUNCTIONALITY : IM RESEARCHING HOW IT WORKS JUST SEARCHING THE NAME.
        function doCreatePlayer(e : Event)
		{
            Util.debug("KidCreatorPage.doCreatePlayer");
            //Check for valid input
			if(!checkErrors())
				return;

            //Fill the xml object with all the data
			fillKidProfileXML();

            //Try to upload it to the database
            if(!uploadKid())
                return;

            //Perform file operations.
            kidProfileFile.setFilePath(DriverData.getKidFolder(kidId) + "_profile.xml");
			kidProfileFile.write(kidProfileXML, true);
						
			if(newPicture)
				KpmIO.copyToAsync(picSource, picDest, onProfilePicCopied, onProfileError);
				
			tImage.removeChild(imageLoader);
			
			if(DriverData.createKid)
				UIGod.feedback("Kid " + kidProfileXML.FIRST_NAME + " " + kidProfileXML.LAST_NAME + " was created successfully");
			else
                UIGod.feedback("Kid " + kidProfileXML.FIRST_NAME + " " + kidProfileXML.LAST_NAME + " was edited successfully");
			
			DriverData.getInstance().reloadKidsProfileInfo1(true);
			currentTimeoutId = setTimeout(kidCreated, 1000);

            //NOT CREATING QR CODE FOR NOW
            //DriverData.kpmDb.createQRCode(kidProfileXML.UID);

		}
		
		function fillKidProfileXML()
		{
			if(DriverData.createKid)
				kidProfileXML = new XML(<KID></KID>);
				
			kidProfileXML.UID = kidId; 
			kidProfileXML.FIRST_NAME = firstName;
			kidProfileXML.LAST_NAME = lastName;
            kidProfileXML.IMAGE_NAME = imageName;
            kidProfileXML.PROFILE_VERSION = com.kpm.kpm.Kid.PROFILE_VERSION;


            Util.debug("KidCreatorPage.fillKidProfileXML " + kidProfileXML.UniqueRandomID + " " + kidProfileXML.LEVEL + " peeeex");
			
			if(DriverData.createKid)
			{
				(age < 3 || age > 5) ? kidProfileXML.LEVEL = 3 : kidProfileXML.LEVEL = age; 	
			}
			else
			{
				if(!levelRadioGroup.selection.value)
					DriverData.logTool.reportError("no selection for level");
					
				if(kidProfileXML.LEVEL != levelRadioGroup.selection.value)
			 	{
			 		Util.debug("renewing profile");
					delete kidProfileXML.BUBBLE_STATUS;
					kidProfileXML.LEVEL = levelRadioGroup.selection.value;
				}
			}

			//Util.debug("KidCreatorPage.fillKidProfileXML " + kidProfileXML.LEVEL);

			kidProfileXML.AGE = age;
			
			kidProfileXML.CLASS = DriverData.currentClass;
			kidProfileXML.PRIMARY_LANGUAGE = primaryLanguage.Text;
			kidProfileXML.GAME_LANGUAGE = gameLanguage.Text;
			
			if(DriverData.createKid)
				kidProfileXML.FIRST_TIME = "true";
			
			tFirstName.text = tLastName.text = tAge.text = "";
		}


        function uploadKid()
        {

            Util.debug("KidCreatorPage.uploadKid");

            // create a URLLoader to POST data to the server

            profileLoader  = new URLLoader();
            urlParams  = new URLVariables();
            var profileRequest:URLRequest = new URLRequest("http://kidsplaymath.org/data/profiles/uploadProfile.php");

            kidProfileXML.SYNC_DB_DATE = Util.getSecondsFrom1970();
            urlParams.data = kidProfileXML;

            profileRequest.data = urlParams;
            profileRequest.method = URLRequestMethod.POST;

            Util.debug("KidCreatorPage.profileRequest" + profileRequest.data)

            try
            {
                profileLoader.dataFormat = URLLoaderDataFormat.TEXT;
                profileLoader.load(profileRequest);
                return true;
            }
            catch(error : Error)
            {
                Util.debug("Profile successfully uploaded data from page :")
                UIGod.feedback("There is no internet connection");
                return false;
            }

            profileLoader.addEventListener(Event.COMPLETE, profileLoader_Complete);
            profileLoader.addEventListener(IOErrorEvent.IO_ERROR, profileLoader_Failed);


        }

        function profileLoader_Complete(e : Event = null)
        {
            Util.debug("Profile successfully uploaded data from page :")
            UIGod.feedback("There is no internet connection");
            Util.debug(profileLoader.data);
        }

        function profileLoader_Failed(e : Event = null)
        {
            Util.debug("Profile could not be uploaded to page :")
            Util.debug(profileLoader.data);
        }
		
		function kidCreated(e : Event = null)
		{
            Util.debug("KidCreatorPage.KidCreated, uploading Kid");
			readyToFill();
			clearTimeout(currentTimeoutId);
		}
		
		function readError(e : Event)
		{
			reportError("ERROR???" + kidsNamesFile.mFile.nativePath);
			DriverData.logTool.reportError ("Error could not read config file" + e.type + kidsNamesFile.mFile.nativePath);
		}

		//Todo isolate function (duplicate in driver)
		//TEST
		function findKidByName(pName : String) : String
		{
			for each (var kid : com.kpm.reporter.excel.Kid in DriverData.kidsInfo)
			{
				//Util.debug(name.toXMLString());
				Util.debug("looping names to delete" + pName, "now at " + (kid.firstName() + " " + kid.lastName()));
				if((kid.firstName() + " " + kid.lastName()) == pName)
					return pName;
			}
			
			return null;
		}
		
		function checkErrors() : Boolean
		{	
			inputValid = true;
			primaryLanguage = null;
			gameLanguage = null; 
			
			firstName = tFirstName.text;
			if(firstName == null || firstName == "") 
				return reportError("First name");

			lastName = tLastName.text;
			if(lastName == null || lastName == "") 	 
				return reportError("Last name");

			age = Number(tAge.text);
			if(tAge.text == "" || age <= 0)  
				return reportError("Age");
						
			//headStartSite = EHSSite[tHeadStartSite.text];
			//if(headStartSite == null) 		
				//return reportError("Head Start Site");
			
			var pLang : String;
			var gLang : String;
			
//			pLang = tPrimaryLanguage.text.toLowerCase();
//			gLang = tGameLanguage.text.toLowerCase();
//			
//			if(pLang == "english" || pLang == "eng" || pLang == "ingles") 
//				primaryLanguage = ELanguage.ENG;
//			else if (pLang == "spanish" ||  pLang == "esp" || pLang == "spa" || pLang == "espanol" || pLang == "espaniol" || pLang == "español") 
//				primaryLanguage = ELanguage.SPA;
//			
//			if(primaryLanguage == null) 	
//				return reportError("Primary language");
//				
//			if(gLang == "english" || gLang == "eng" || gLang == "ingles") 
//				gameLanguage = ELanguage.ENG;
//			else if (gLang == "spanish" ||  gLang == "esp" || gLang == "spa" || gLang == "espanol" || gLang == "espaniol" || gLang == "español") 
//				gameLanguage = ELanguage.SPA;

			primaryLanguage = DriverData.languageList[tPrimaryLanguage_Cb.selectedIndex];
			gameLanguage = DriverData.languageList[tGameLanguage_Cb.selectedIndex];
			
			if(gameLanguage == null) 	
				return reportError("Game language");
			
			else if(DriverData.createKid && findKidByName(firstName + " " + lastName) != null)
				return reportError("Cannot add a player with same name as another player", false);
			
			Util.debug("pic num children" + tImage.numChildren);
			if(tImage.numChildren == 0)
			{
				tValidPic.text = "You need to supply a valid picture";
				return false;
			}
			
			return inputValid;	
		}
		
		function reportError(pField : String = "", pNotRecognized : Boolean = true) : Boolean
		{
			//Util.debug("leaving " + pField + " feedback in " + tError, this);
			inputValid = false;
			if(pNotRecognized)
			{
				UIGod.feedback(pField + " is missing or not recognized ");
			}
			else
				UIGod.feedback(pField);
			
			return false;
		}
	}	
}