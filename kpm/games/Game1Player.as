package com.kpm.games
{
	import com.kpm.common.*;
	
	import flash.display.*;
	import flash.media.Sound;		
					
	public class Game1Player extends TiledGameComponent {
		
		private var mPath		: MovieClip;			
		var currentTile 		: Point2D;	
		var initialTile 		: Point2D;
		var previousTile		: Point2D;
		var lastDirection		: Point2D;
		var lastArrow			: DisplayObject;
		var numMoves			: uint;
		var arrivedAtTarget 	: Boolean;
		var defaultFacing		: Point2D;
		var currentlyFacing 	: Point2D;
		var defaultCenter		: Point2D;
		var gameTheme			: Object;		
		var distanceToTarget	: uint; 
		
		public static const EAT_ANIMATION_DONE	: String = "EAT_ANIMATION_DONE";

		public function Game1Player(pBoard : Board, pTileSize : Point2D, pPlayerFacing : Point2D) 
		{
			defaultFacing = pPlayerFacing;
			currentlyFacing = defaultFacing;
			super(pBoard, pTileSize);
		}
		
		public function initialize(pTile : Point2D, pMovieName : String, pMoveFrames : uint)
		{				
			
			Tile = pTile.clone();
			currentTile = Tile.clone();	
			initialTile = Tile.clone();	
			previousTile = null;
			arrivedAtTarget = false;
			MovieName = pMovieName;
			mMoveFrames = pMoveFrames;
		}
		
		public override function moveByTile(pDirection : Point2D, pPeriod : Number = 0)
		{
			previousTile = Tile.clone();			
			super.moveByTile(pDirection, pPeriod);
			turn(pDirection);			
			animate(pDirection);

		}
		
		public function turn(pDirection : Point2D)
		{
			Util.debug(previousTile + " " + Tile + " " + pDirection, this);
			if(defaultFacing == GameData.UP)
				return;
				
			if(currentlyFacing == GameData.RIGHT && pDirection.x < 0)
			{
				scaleX *= -1;
				currentlyFacing = GameData.LEFT;
			}
			else if(currentlyFacing == GameData.LEFT && pDirection.x > 0)
			{
				scaleX *= -1;
				currentlyFacing = GameData.RIGHT;
			}
		}
		
		public function animate(pDirection : Point2D)
		{
			Movie.gotoAndPlay("jumpinplace");
		}
		
		public function getDistanceToTarget(pPrevious : Boolean = false) : uint
		{
			if(pPrevious && previousTile)
				return mBoard.logicBoard[previousTile.x][previousTile.y];
			else
				return mBoard.logicBoard[Tile.x][Tile.y];
		}
		
		function setPath()
		{
			if(mPath)
				mPath.graphics.clear();	
			mPath = new MovieClip();
			mPath.graphics.lineStyle(5, 0x23691A,1, true, "normal", "ROUND");
			mPath.graphics.moveTo(
				mBoard.tileToPixel(Tile).x,
				mBoard.tileToPixel(Tile).y);		
			parent.addChild(mPath);



		}
		
		function clearPath()
		{
			if(mPath)
				mPath.graphics.clear();	
		}
			
		function set CurrentTile(pTile : Point2D)
		{
			previousTile = currentTile.clone();
			currentTile = pTile.clone();
		}
		
		function get CurrentTile() : Point2D
		{
			return currentTile;
		}
		
		function pathToCurrentTile()
		{
			mPath.graphics.lineTo(
				mBoard.tileToPixel(currentTile).x, 
				mBoard.tileToPixel(currentTile).y);		
			
		}
		
		function get Path() : MovieClip
		{
			return mPath;	
		}
	}
}