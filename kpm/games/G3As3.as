package com.kpm.games
{	
	import com.gskinner.utils.SWFBridgeAS3;
	import com.kpm.kpm.BubbleId;
	import com.kpm.kpm.Driver;
	import com.kpm.common.ELanguage;
	
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	
	public class G3As3 extends MovieClip
	{
		var connnectionCounter 	: int = 0;
		var sb2	 				: SWFBridgeAS3 ;
		var gameLoader			: Loader = new Loader();
		var currentBubbleId		: BubbleId;
		var currentLanguage		: ELanguage;
		var muteVar 			: Boolean;
		
		public function G3As3()
		{
			sb2 = new SWFBridgeAS3("test2",this);
			gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onGameLoaderComplete);
			loadSwf("G3.swf", BubbleId.IdentifyColor0, ELanguage.ENG, false);
			//setChildIndex(tPex, numChildren-1);
			
		}
		
		public function loadSwf(pString : String, pCurrentBubbleId : BubbleId, pLanguage : ELanguage, pMute : Boolean)
		{
			this.addEventListener (Event.REMOVED_FROM_STAGE, onRemove);

			try
			{
				currentBubbleId = pCurrentBubbleId;
				currentLanguage = pLanguage;
				muteVar = pMute;
				
				var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
				var request:URLRequest = new URLRequest(pString);
				gameLoader.load(request, context);
				addChild(gameLoader);
				
			}
			catch(e : Error) {}
		}
		
		function onGameLoaderComplete(e : Event)
		{
			//tPex.tDebug1.text = "sb2 " + sb2.connected;
			sb2.addEventListener(Event.CONNECT, onConnect);	
		}
				
		function onConnect (e:Event)
		{
			//tPex.tDebug2.text = "connected";
			trace("pex connecting" + e.type);
			sb2.send("initGame", currentBubbleId.Name.Text, currentBubbleId.Level, currentLanguage.Text, muteVar);
		}
		
		public function onBubbleFinished(pSuccess : Boolean)
		{
			if(pSuccess)
				this.dispatchEvent(new Event(GameData.BUBBLE_FINISHED));
			else
				this.dispatchEvent(new Event(GameData.BUBBLE_FAILED));
		}
		
		public function returningToDriver()
		{
			this.dispatchEvent(new Event(GameData.RETURN_TO_DRIVER));
		}
		
		
		public function repeatQuestion()
		{
			sb2.send("repeatQuestion");
		}
		
		public function mute()
		{
			sb2.send("mute");
		}

		public function onRemove(e : Event)
		{
			trace("on removeeee");
			try
			{
				sb2.send("closeConnection");
				sb2.removeEventListener(Event.CONNECT, onConnect);
				sb2.close();
				
			}
			catch (e : Error)
			{
				trace(e.message);	
			}
			
			gameLoader.unloadAndStop();
			removeChild(gameLoader);
			
		}
	}
}