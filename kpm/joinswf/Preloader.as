package com.kpm.joinswf {

import com.kpm.common.Util;

import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.utils.getDefinitionByName;
	import com.kpm.joinswf.Globals;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	
	public class Preloader extends MovieClip {

		//public var logo:MovieClip;
		public var mainGame:Sprite;
		public var startCounter:int=-1;
		public var $:Globals;
		
		public function Preloader() {
			// constructor code
			Util.debug("preloading...");
			$ = Globals.instance;
			addEventListener(Event.ADDED_TO_STAGE, onInit, false, 0, true);
		}
		
		private function onInit(e:Event):void{
			//stage.scaleMode = StageScaleMode.NO_SCALE;

            //stage.align  = StageAlign.LEFT;

            //if(Capabilities.manufacturer.indexOf("iOS") != -1)
              //  this.y = (800 - (1024*10/16))/2;

            addEventListener(Event.ENTER_FRAME,onframe);
		}

		private function onframe(e:Event):void{
			if ( ApplicationDomain.currentDomain.hasDefinition("com.kpm.kpm.Driver") ) {
				removeEventListener(Event.ENTER_FRAME,onframe);
				stop();
				startCounter=4; //wait startCounter frames before real start
				addEventListener(Event.ENTER_FRAME,onframeStart);
			}
		}
		private function onframeStart(e:Event):void{
			startCounter--;
			if(startCounter <= 0) {
				var GameClass:Class = getDefinitionByName( "com.kpm.kpm.Driver" ) as Class;
				mainGame = new GameClass() as Sprite;
				removeEventListener(Event.ENTER_FRAME,onframeStart);
                startGame(null)
			}
		}
		
		private function startGame(e:MouseEvent):void{
			//removeEventListener(MouseEvent.MOUSE_DOWN, startGame);
			addChildAt(mainGame,0);
		}
	}
}
