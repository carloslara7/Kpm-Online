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


        public static var parametersPanel : MovieClip;

        public function Game() {


        }

        public function addParameterPanelAndEvent(pAdd : Boolean,  pFunc : Function, pX : int, pY : int)
        {
            Util.debug("addParameterPanel");

            if(!parametersPanel)
            {
                parametersPanel = Util.createMc("parametersPanel");

                addChild(parametersPanel);

                parametersPanel.x = pX;

                parametersPanel.y = pY;

                GameData.parameters = new Array();

                for(var i=0; i < 7; i ++)
                {
                    GameData.parameters.push((parametersPanel["p" + i]).text);
                    Util.debug("adding parameter " + GameData.parameters[i]);
                }

            }

            if(pAdd)
                EventManager.addEvent(parametersPanel.tGoButton, MouseEvent.CLICK, pFunc);
            else
                EventManager.removeEvent(parametersPanel.tGoButton, MouseEvent.CLICK);

        }
	
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


