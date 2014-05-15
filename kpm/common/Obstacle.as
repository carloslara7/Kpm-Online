package com.kpm.common
{
	import flash.display.MovieClip;
		
	public class Obstacle extends TiledGameComponent {
		
		public function Obstacle(pBoard : Board, pTileSize : Point2D, pMovieName : String) 
		{
			super(pBoard, pTileSize);
			MovieName = pMovieName;
		}
		
		
	}
}