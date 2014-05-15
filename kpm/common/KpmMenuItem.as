package com.kpm.common
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class KpmMenuItem extends GameComponent
	{
		var subMenus  : Array;
		
		public function KpmMenuItem(pMovieName : String)
		{
			subMenus = new Array(KpmMenu.MAX_NUM_ITEMS);
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0 , true)
			movieName = pMovieName;
		}
		
		function onAddedToStage(e : Event)
		{
			MovieName = movieName;
		}
	}
}