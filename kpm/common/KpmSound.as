package com.kpm.common 
{
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.net.URLRequest;
   
   	public class KpmSound extends EventDispatcher
   	{
   		public var sound : Sound;
   		public var volume : Number;
   		public var loop : uint;
   		public var lowerVolume : Boolean;
   		public var isMusic : Boolean;
   		public var duration : uint;
   		public var eventString : String;
   		public var name : String;
   		public var lang	: ELanguage;
   		public var game : EGame;
   		public var path : String;
   		public var numOptions : uint;

		public static const INSTRUCTIONS_FINISHED 	 : String = "INSTRUCTIONS_FINISHED";		public static const SUCCESS_SOUND_FINISHED	 : String = "SUCCESS_SOUND_FINISHED";
		
   		public function KpmSound
   		(pPath : String, pName: String, pVolume : Number, pLang : ELanguage = null, pGame : EGame = null,  
   		 pSound : Sound = null, pLoop : uint = 0, pLowerVolume : Boolean = false, pIsMusic : Boolean = false, 
   		 pDuration : uint = 0, pEventString : String = null)
   		{
   			lang = pLang;
   			game = pGame;
   			path = pPath;	
   			
   			
//   		name = pPath + pName;
//   		sound = Util.createSound(name);
   			
   			
   			if(pName == null)
   			{
	   			sound = pSound;
	   			name = Util.getClassName(pSound);
   			}
	   		else 
	   		{	
	   			name = pName;
	   			loadSound();
	   		}
	   		
   			volume = pVolume;
   			loop = pLoop;
   			lowerVolume = pLowerVolume;
   			isMusic = pIsMusic;
   			duration = pDuration;
   			eventString = pEventString;
   		}
   		
   		function loadSound()
   		{
   			sound = new Sound();
	    	sound.addEventListener(IOErrorEvent.IO_ERROR, function() { return null}, false, 0 , true);
	    	var url : URLRequest = new URLRequest(path + name +".mp3") 
			sound.load(url);
			Util.debug("trying to load " + url.url, this);
   		}

   		public override function toString() : String
   		{
   			return ("[KpmSound : " + name + ", is Music : " + isMusic + 
   					 ", loops " + loop + ", volume : " + volume  + " ] ");
   		}
   			
   	}
   	
   	
   	
}