/**
 * Created with IntelliJ IDEA.
 * User: carloslara
 * Date: 10/4/13
 */


package com.kpm.kpm
{

import com.kpm.common.EventManager;
import com.kpm.common.KpmIO;
import com.kpm.common.Util;
import com.kpm.ui.UIGod;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoaderDataFormat;
import flash.net.URLVariables;

import flash.net.URLVariables;
import flash.net.URLRequest;
import flash.net.URLLoader;
import flash.net.URLRequestMethod;
import flash.sampler.getSavedThis;


public class KpmDB extends EventDispatcher{

        var bbLoader : URLLoader ;
        var bbParams : URLVariables;
        var internetLoader = new URLLoader();
        var internetRequest : URLRequest = new URLRequest("http://kidsplaymath.org/data/profiles/checkInternet.php");
        var dbProfileXML : XML ;

        var requestPhpFile : URLRequest;
        public var loaderPhpFile : URLLoader;
        var paramsPhpFile  : URLVariables;

        public static var NO_INTERNET : String = "NO_INTERNET";
        public static var INTERNET : String = "INTERNET";
        public static var FIRST_TIME : String = "FIRST_TIME";
        public static var SYNC_PROFILE_DB_TO_LOCAL : String = "SYNC_PROFILE_DB_TO_LOCAL";
        public static var LOAD_LOCAL_PROFILE : String = "LOAD_LOCAL_PROFILE";
        public static var SYNC_PROFILE_LOCAL_TO_DB : String = "SYNC_PROFILE_LOCAL_TO_DB";
        public static var PHP_SEARCH_FILENAME : String = "search.php";

        public function KpmDB() { }


        public function uploadBubbleChangesFromLog(pArray : Array)
        {
            Util.debug("KpmDB.uploadBubbleChangesFromLog");
            Util.debug("pexxx");

            //  <bubble_status_changed id="IdentifyDiceDots_1" NowIsActive="false" Outcome="Passed"/>
            var bubblesXML : XML = new XML(<BUBBLE_STATUS></BUBBLE_STATUS>);

            for (var i=0; i < pArray.length; i ++)
            {
                var child : XML = new XML();
                child.BUBBLE_ID = pArray[i].id;
                child.ACTIVE = pArray[i].NowIsActive;
                child.STATUS = pArray[i].Outcome;

                bubblesXML.appendChild(child);
            }

            uploadBubbleChanges1(bubblesXML);
            Util.debug(bubblesXML.toXMLString());

        }


        function uploadBubbleStatusFirstTime()
        {
            //2014 : if successful, create kid, otherwise post message to user
            Util.debug("KpmDB.uploadBubbleStatusFirstTime" + DriverData.currentKidXML.toXMLString());
            uploadBubbleChanges2(null, XML(DriverData.currentKidXML.BUBBLE_STATUS));
        }

        function uploadBubbleChanges1(pBubbleChangesXML : XML)
        {
            //2014: in case wireless or db is offline, call SaveBubbleChanges (which doesnt do anything for now)
            isDBOnline();
            EventManager.addEvent(this, KpmDB.INTERNET, uploadBubbleChanges2, pBubbleChangesXML);
            //EventManager.addEvent(this, KpmDB.NO_INTERNET, saveBubbleChanges, pBubbleChangesXML);
        }

        function uploadBubbleChanges2(e : Event,  pBubbleChangesXML : XML)
        {

            // create a URLLoader to POST data to the server

            bbLoader  = new URLLoader();
            bbParams  = new URLVariables();
            var profileRequest:URLRequest = new URLRequest("http://kidsplaymath.org/data/profiles/uploadBubbleChanges.php");
            bbParams.data = pBubbleChangesXML;
            bbParams.UID = DriverData.currentGamerId;
            bbParams.SYNC_DB_DATE = Util.getSecondsFrom1970();

            profileRequest.data = bbParams;
            profileRequest.method = URLRequestMethod.POST;

            Util.debug("KpmDB.uploadBubbleChanges" + profileRequest.data)

            try
            {
                bbLoader.dataFormat = URLLoaderDataFormat.TEXT;
                bbLoader.load(profileRequest);
            }
            catch(error : Error)
            {
                Util.debug("Internet is offline")
                return false;
            }

            bbLoader.addEventListener(Event.COMPLETE, bbLoader_Complete);


        }

        function saveBubbleChanges(e : Event, pBubbleChanges : XML)
        {

        }

        function bbLoader_Complete(e : Event)
        {
            Util.debug("bbloader Complete" + bbLoader.data)
        }

        public function isDBOnline()
        {
            Util.debug("KpmDB.isDBOnline");
            internetLoader = new URLLoader();
            internetRequest = new URLRequest("http://kidsplaymath.org/data/profiles/checkInternet.php");

            try
            {
                internetLoader.dataFormat = URLLoaderDataFormat.TEXT;
                internetLoader.load(internetRequest);
            }
            catch(error : Error)
            {
                Util.debug("Internet is offline")
                UIGod.feedback("There is no internet connection");
                this.dispatchEvent(new Event(KpmDB.NO_INTERNET));
            }

            internetLoader.addEventListener(Event.COMPLETE, internetLoader_Complete);
            internetLoader.addEventListener(IOErrorEvent.IO_ERROR,internetLoader_Failed);


        }

        public function internetLoader_Complete(e : Event)
        {

            Util.debug("internet is online" + internetLoader.data)
            if(internetLoader.data == "true")
                this.dispatchEvent(new Event(KpmDB.INTERNET));
            else
                this.dispatchEvent(new Event(KpmDB.NO_INTERNET));

        }

        public function internetLoader_Failed(e : Event)
        {
            this.dispatchEvent(new Event(KpmDB.NO_INTERNET));

        }

        //IF Connected to the internet
        //Download profile, else call Populate kid Profile
        function downloadProfile( e : Event)
        {
            Util.debug("KpmDB.downloading profile for " + DriverData.currentGamerId);
            var retrieveProfileURL : String = "http://kidsplaymath.org/data/profiles/retrieveProfile.php";
            connectToPHP(retrieveProfileURL, DriverData.currentGamerId, profileLoader_Complete);

        }

        public function loadPhpFile(pPhpProcessFile : String, pAttributes : String,
                                    pHandlerComplete : Function = null, pHandlerFailed : Function = null)
        {
            Util.debug("KpmDB.loadPhpFile " + pPhpProcessFile + " " + pAttributes);

            if(pPhpProcessFile == "")
                Util.debug("no file to process");

            loaderPhpFile = new URLLoader();
            requestPhpFile = new URLRequest("http://kidsplaymath.org/data/profiles/" + pPhpProcessFile +"?" + pAttributes);
            paramsPhpFile  = new URLVariables(pAttributes);
            requestPhpFile.data = paramsPhpFile;
            requestPhpFile.method = URLRequestMethod.POST;


                try
                {
                   Util.debug("trying to open " + requestPhpFile.url);

                   loaderPhpFile.dataFormat = URLLoaderDataFormat.TEXT;
                   loaderPhpFile.load(requestPhpFile);
                }
                catch(error : Error)
                {
                    Util.debug("Internet is offline")
                    UIGod.feedback("There is no internet connection");
                    this.dispatchEvent(new Event(KpmDB.NO_INTERNET));
                }

                loaderPhpFile.addEventListener(Event.COMPLETE, pHandlerComplete);
                loaderPhpFile.addEventListener(IOErrorEvent.IO_ERROR,pHandlerFailed);
        }

        //Search for all kids that have (first + lastname) similar to (pSearch : String)
        //Download their profile image.
        public function searchKidNames(pAttributes : String)
        {
            Util.debug("KpmDB.searchKidNames" + pAttributes)
            loadPhpFile("searchNames.php", pAttributes , searchKidNames_Complete, searchKidNames_Failed);
        }

        // Search for (first+lastname) completes
        public function searchKidNames_Complete(e : Event)
        {
            Util.debug("search kid complete" + loaderPhpFile.data);

            if(loaderPhpFile.data == "false")
                UIGod.feedback("No Kids Found!")

            else
            {
                this.dispatchEvent(new Event("searchKidNames_Complete"));
                var foundKidIds : String = loaderPhpFile.data;



            }

            //KidLoginPage.searchContentsXML = loaderPhpFile.data;

        }

        public function searchKidNames_Failed(e : Event)
        {
            Util.debug("There was an error connecting to KidsPlayMath server.");
            UIGod.feedback("There was an error connecting to KidsPlayMath server");

            this.dispatchEvent(new Event(KpmDB.PHP_SEARCH_FILENAME + KpmIO.READ_ERROR));
        }


        function profileLoader_Complete(evt:Event):void {

            Util.debug("KpmDb.profileLoader_Complete");
            Util.debug(evt.target.data);

            if(evt.target.data == "false")
            {
                DriverData.kidsBubblesNotInServer = true;
                Util.debug("no data for kid in server");
                //there is internet, but the kid is not initialized in the server so we must run local copy.
                this.dispatchEvent(new Event(KpmDB.FIRST_TIME));



            }
            else
            {
                dbProfileXML = new XML(evt.target.data);
                Util.debug(dbProfileXML.toXMLString());

                //Either sync local date is similar or later than synd db date, use local profile (dont do anything)
                if(Util.compareDates(dbProfileXML.SYNC_LOCAL_DATE, dbProfileXML.SYNC_DB_DATE) == 0)
                {
                    Util.debug("using local profile, local date is similar db date");
                    this.dispatchEvent(new Event(KpmDB.LOAD_LOCAL_PROFILE));
                    this.dispatchEvent(new Event(KpmDB.SYNC_PROFILE_LOCAL_TO_DB));

                }
                else if (Util.compareDates(dbProfileXML.SYNC_LOCAL_DATE, dbProfileXML.SYNC_DB_DATE) == 1)
                {
                    Util.debug("using local profile, local date is after db date");
                    this.dispatchEvent(new Event(KpmDB.LOAD_LOCAL_PROFILE));
                    this.dispatchEvent(new Event(KpmDB.SYNC_PROFILE_LOCAL_TO_DB));

                }
                //sync local date is before sync db date,
                else
                {
                    this.dispatchEvent(new Event(KpmDB.SYNC_PROFILE_DB_TO_LOCAL)) ;
                    Util.debug("using db profile, local date is before db date");

                }


                //if database sync date is after local sync date
                //  Sync DriverData Profile!
            }
        }

        public function createQRCode(pUID : String)
        {
            Util.debug("KpmDB.createQRCode " + pUID);
            var qrCreatorScriptURL : String = "http://kidsplaymath.org/data/profiles/createQRCode.php";
            connectToPHP(qrCreatorScriptURL, pUID, qrCodeComplete);

        }

        function qrCodeComplete( e : Event)
        {
            Util.debug("QrCodeCreation complete" + e.target.data)
        }


        //IF Connected to the internet
        //Download profile, else call Populate kid Profile
        public function connectToPHP(pURL : String, pData : Object, pHandlerFunc : Function)
        {
            Util.debug("KpmDB.downloading profile for " + DriverData.currentGamerId);
            // create a URLLoader to POST data to the server
            var profileLoader : URLLoader = new URLLoader();
            var urlParams : URLVariables = new URLVariables();

            var request:URLRequest = new URLRequest(pURL);
            urlParams.data = pData;
            request.data = urlParams;
            request.method = URLRequestMethod.POST;

            try
            {
                profileLoader.dataFormat = URLLoaderDataFormat.TEXT;
                profileLoader.load(request);
            }
            catch(error : Error)
            {
                Util.debug("Internet is offline")
            }

            profileLoader.addEventListener(Event.COMPLETE, pHandlerFunc);

        }




        public function getDBProfileXML()
        {
            return dbProfileXML;
        }
    }
}
