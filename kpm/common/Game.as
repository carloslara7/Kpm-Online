/******************************************
/* Author : Carlos Lara 
/* variables : 
/* m: member, p: parameters, t : timeline
/*****************************************/

package com.kpm.common {
	import com.kpm.kpm.BubbleId;
	import flash.display.MovieClip;
	import flash.events.Event;	


	public class Game extends MovieClip{
		
		protected var mData	 			: GameData;	
		
		public function Game() {}
	
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


