package com.kpm.games
{
	import flash.display.MovieClip;
	import com.kpm.common.GameComponent;
	import com.kpm.common.Point2D;	
	import com.kpm.common.GameData;	
				
	public class Game1SmallArrow extends GameComponent {
		
		public var direction : Point2D;
		public function Game1SmallArrow(pDirection : Point2D) 
		{
			super();
			direction = pDirection.clone();
			
			if(pDirection.equals(GameData.UP))
				gotoAndStop("up");
			else if(pDirection.equals(GameData.DOWN))
				gotoAndStop("down");
			else if(pDirection.equals(GameData.RIGHT))
				gotoAndStop("right");
			else if(pDirection.equals(GameData.LEFT))
				gotoAndStop("left");
			else
			{
				Util.debug("no direction", this);
				pDirection.print();
			}
		}
		
	}
}