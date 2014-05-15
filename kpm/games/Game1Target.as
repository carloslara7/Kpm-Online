package com.kpm.games
{
	import flash.display.*;
	import com.kpm.common.*;	
				
	public class Game1Target extends TiledGameComponent {

		public function Game1Target(pBoard : Board, pTileSize : Point2D, pMovieName : String) 
		{
			super(pBoard, pTileSize);
			initMovie(pMovieName);
		}
		
		public function initMovie(pMovieName : String)
		{
			if(!Movie)
			{
				MovieName = pMovieName;
			}
		}
	}
}