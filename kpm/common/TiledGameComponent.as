package com.kpm.common
{
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
		
	public class TiledGameComponent extends GameComponent {
		public var mBoard			: Board;
		public var mMoveFrames		: uint;
		public var tileSize			: Point2D;
		private var mTile 		: Point2D;
		private var tweenX, tweenY, tweenAlpha : Tween;

		
		public static const POSITION_CHANGED :String = "POSITION_CHANGED";
		
		public function TiledGameComponent(pBoard : Board, pTileSize : Point2D)
		{
			super();
			mBoard = pBoard;
			tileSize = pTileSize;
		}
		
		public function set Tile(pPosition:Point2D):void 
		{
		       mTile = pPosition.clone();  
		       updatePixelPosition();
		}
		
		public function get Tile():Point2D 
		{
		       return mTile;
		}
	
		
		public function moveByTile(pDir: Point2D, pPeriod : Number = 0)
		{		
			var oldPos : Point2D = mBoard.tileToPixel(mTile);
			
			mTile.x += pDir.x;
			mTile.y += pDir.y;
			
			//Util.debug("tween from x " + oldPos.x + " " + Pixel.x, this);
			//Util.debug("tween from y " + oldPos.y + " " + Pixel.y, this);	
					
			if(pPeriod > 0)
			{
				tweenX  = new Tween(this, "x", Strong.easeIn, oldPos.x, Pixel.x, pPeriod, true);
				tweenY  = new Tween(this, "y", Strong.easeIn, oldPos.y, Pixel.y, pPeriod, true);
				tweenAlpha = new Tween(this, "alpha", Strong.easeIn, 100, 100, mMoveFrames, false);
				tweenAlpha.addEventListener(TweenEvent.MOTION_FINISH, onAnimationFinished, false, 0 , true);
			}
			else
			{		
				updatePixelPosition();
				this.dispatchEvent(new Event(POSITION_CHANGED));
			}
		}
		
		public function moveToTile(pTile : Point2D, pPeriod : Number)
		{
			if(!pTile)
				throw new Error("no direction");
				
			var initialPos : Point2D = mTile.clone();
			initialPos.multiply(-1)
			
			var dir : Point2D = pTile.clone();
			dir.add(initialPos);
			
			Util.debug("moving to " + pTile);
			
			moveByTile(dir, pPeriod);
		}
		
		public function onAnimationFinished(e:TweenEvent)
		{
			this.dispatchEvent(new Event(POSITION_CHANGED));
		}
		
		public function updatePixelPosition()
		{
			Position = new Point2D(Pixel.x, Pixel.y);
		}
		
		public function get Pixel(): Point2D
		{
			if(mBoard)
				return mBoard.tileToPixel(mTile);
			else
				return mTile;
		}
		
		public function moveBy( pDir : Point2D, pPeriod : Number)
		{
			mTile.x += pDir.x;
			mTile.y += pDir.y;	
		}
		
		public function intersect(pTile : Point2D) : Boolean
		{
			var start_x = Tile.x - Math.floor((tileSize.x-1)/2);
			var start_y = Tile.y - Math.floor((tileSize.y-1)/2);
 			var startingTile : Point2D = new Point2D( start_x, start_y);
 			var checkingTile : Point2D;
			
			for(var i=0; i<tileSize.x;i++)
				for(var j=0; j<tileSize.y; j++)
				{
					checkingTile = Util.addPoint2D(startingTile, new Point2D(i,j));
					//Util.debug("checking " + checkingTile + " " + pTile, this);
					//Util.debug("starting tile" + startingTile, this);
					if(checkingTile.equals(pTile))
					{
						Util.debug("colision", this);
						return true;
					}
				}
			//Util.debug("", this);	
				
			return false;
		}
	}
}