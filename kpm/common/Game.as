/******************************************
/* Author : Carlos Lara 
/* variables : 
/* m: member, p: parameters, t : timeline
/*****************************************/

package com.kpm.common {

import flash.display.MovieClip;
	import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Mouse;


public class Game extends MovieClip{
		
		protected var mData	 			: GameData;
        protected var clickedTarget   : MovieClip;

        public function Game() {


        }
//
//        public function addParameterPanelAndEvent(pAdd : Boolean,  pFunc : Function, pX : int, pY : int, pNumParameters : int)
//        {//
//            if(!GameData.parameters) GameData.parameters = new Array(pNumParameters);
//

//
//            //Save the parameters
//            for(var i=0; i < pNumParameters; i ++)
//            {
//
//                //Util.debug("i " + i + "parametersPanel[p + i]" + parametersPanel["p" + i];
//                GameData.parameters[i] = (parent.parametersPanel["p" + i]).text;
//                Util.debug("GameData.parameters[i]" + GameData.parameters[i]);
//
//            }
//
//            if(pAdd)
//                EventManager.addEvent(parent.parametersPanel.tGoButton, MouseEvent.CLICK, pFunc);
//            else
//                EventManager.removeEvent(parent.parametersPanel.tGoButton, MouseEvent.CLICK);
//
//
//
//        }
	
		public function onBubbleFinished(e:Event)
		{
			if(parent == stage)
			{
				Data.Level = Data.Bubble.Level + 1 ;	 
			}
		}
		
		public function onInstructionsFinished(e: Event) {}

        public function createMusic() : KpmSound
		{
			return null;
		}
		
		
		public function onStateChanged(e:Event) {}
		
		public function onRemove(e:Event) {}
		public function onFeedbackFinished(e:Event) {}
		public function unLockKeys(e:Event) {}
		public function blinkSolution() {}
		
		public function get Data() 			{ 	return mData ; 				}
		public function get Score() : uint 	{ 	return Data.gameGoal.globalScore; }
				
	}
}


