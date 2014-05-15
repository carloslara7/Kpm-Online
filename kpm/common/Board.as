package com.kpm.common 
{
	import com.as3collections.ArrayQueue;
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	public class Board 
	{
		public static const TILE_OBSTACLE	: int = -2;
		public static const TILE_DISTRACTOR	: int = -3;
		public static const TILE_EMPTY		: int = -1;
		public static const TILE_TARGET		: int = 0;
		public static const TILE_PLAYER		: int = 100;
		
		public static const ONE_TILE		: Point2D = new Point2D(1,1);
		public static const NULL_POINT		: Point2D = new Point2D(-1,-1);					
		
				private var mTileSize 	: uint;
		private var mNumRows 	: uint;
		private var mNumCols 	: uint;
		public var  Offset 		: Point2D;
		public var logicBoard	: Array;
		public var npcArray 	: Array;
		private var queue		: ArrayQueue;
		
		public function Board(pBoard : Object)
		{
			mNumRows = pBoard.numRows;
			mNumCols = pBoard.numCols;
			mTileSize = pBoard.tileSize;
			Offset = pBoard.Offset;
			queue = new ArrayQueue();
			
			npcArray = new Array();
			emptyLogicBoard();
			
		}
		
		
		
		public function emptyLogicBoard()
		{	
			logicBoard = new Array(NumCols);
			for (var i=0; i < NumCols; i++)
			{
				logicBoard[i] = new Array(NumRows);
				for (var j=0 ; j < NumRows; j++)
					logicBoard[i][j] = TILE_EMPTY;
			}
		}
		
		public function addObject( pObject : TiledGameComponent , pType :int)
		{
			for(var i=0; i< pObject.tileSize.x; i++)
				for(var j=0; j < pObject.tileSize.y; j++)
				{
					var x = pObject.Tile.x;
					var y = pObject.Tile.y;
					logicBoard[x + i][y + j] = pType;
				}
		}
		
		public function resetObject(pObject : TiledGameComponent, pTarget : Point2D)
		{
			for(var i=0; i< pObject.tileSize.x; i++)
				for(var j=0; j < pObject.tileSize.y; j++)
				{
					var x = pObject.Tile.x;
					var y = pObject.Tile.y;
					var dist = Util.manhDistance(pTarget, new Point2D(x,y)); 
					logicBoard[x + i][y + j] = dist;
				}
		}


		public function isEmptyPath(pInit : Point2D, pEnd : Point2D) : Boolean
		{
			var steps : Array = Util.makePathFrom(pInit, pEnd, 1);
			
			Util.debug("empty path ");
			var currentPoint : Point2D = pInit.clone();
			
			for(var i=0; i< steps.length; i++)
			{ 
				currentPoint.add(steps[i]);
				Util.debug(currentPoint);
				
				if(!isEmptyPoint(currentPoint))
				{
					Util.debug("path is not empty" + currentPoint);
					return false;
				}
			}
			
			return true;
		}
		
		public function isEmptyArray(pArray : Array) : Boolean
		{
			for(var i=0; i< pArray.length; i++)
			{
				if(!isEmptyPoint(pArray[i]))
					return false;
			}
			
			return true;
		}
		
		public function isEmpty(pObject : TiledGameComponent, pSpecialTiles : Array = null) : Boolean
		{			
			if(!pObject.Tile)
				return true;
			
			for(var i=0; i< pObject.tileSize.x; i++)
				for(var j=0; j < pObject.tileSize.y; j++)
				{
					if(!inBounds(new Point2D(pObject.Tile.x + i, pObject.Tile.y + j)))
					{	
						Util.debug("not in bounds" + pObject.Tile + " i " + i + " j " + j, this);				
						return false;
					}
						
					if(logicBoard[pObject.Tile.x + i][pObject.Tile.y + j] != Board.TILE_EMPTY)
					{
						Util.debug("tile not empty" + pObject.Tile + " i " + i + " j " + j + " logic board " + logicBoard[pObject.Tile.x + i][pObject.Tile.y + j], this);
						return false;
					}
					
					if(pSpecialTiles)
					{
						for(var item in pSpecialTiles)
						{
							if(pObject.Tile.x + i == pSpecialTiles[item].x && 
							   pObject.Tile.y + j == pSpecialTiles[item].y)
							   return false;
						}
					}
				}
			
			return true;
		}
		
		public function isEmptyPoint(pPoint : Point2D)
		{
			var pObject : TiledGameComponent = new TiledGameComponent(this, Board.ONE_TILE);
			pObject.Tile = pPoint;
			
			return isEmpty(pObject);	
		}
		
		public function bringIn(pObject : TiledGameComponent) : Point2D
		{
			if(pObject.Tile.x + pObject.tileSize.x - 1 >= NumCols)
				pObject.Tile.x = NumCols - pObject.tileSize.x;
			if(pObject.Tile.y + pObject.tileSize.y - 1 >= NumRows)
				pObject.Tile.y = NumRows - pObject.tileSize.y;	 
			
			return pObject.Tile;
		}
	
		public function initLogicBoard(pTarget : Point2D)
		{
			var done : Boolean = false;
			var currentTile : Point2D;
			var currentDistance : uint = 0;
			
			
//			if(logicBoard[pTarget.x][pTarget.y] != TILE_TARGET)
//			{
//				Util.debug("target is not set to target in board", this);
//				return;
//			}

			logicBoard[pTarget.x][pTarget.y] = Board.TILE_TARGET;
			
			queue.enqueue(pTarget);
				
			while(!queue.isEmpty)
			{
				currentTile = queue.dequeue() as Point2D;
				
				for (var i in GameData.arrows)
				{
					var x = currentTile.x + GameData.arrows[i].x;
					var y = currentTile.y + GameData.arrows[i].y
					currentDistance = logicBoard[currentTile.x][currentTile.y]+1;
					if(inBounds(new Point2D(x,y)) && logicBoard[x][y] == TILE_EMPTY)
					{
						logicBoard[x][y] = currentDistance;
						queue.enqueue(new Point2D(x,y));
						//Util.debug(" storing " + currentDistance + " in " + x + " " + y, this);
					}
				}
				
			}
			
			//Util.printArray(logicBoard);
		}
		
		
		public function get TileSize() : uint  {	return mTileSize;	}
		public function get NumRows() : uint   {	return mNumRows;	}
		public function get NumCols() : uint   { 	return mNumCols;	}
		public function get NpcArray() : Array {	return npcArray; 	}
		
		public function draw(pThickness : uint, parent : MovieClip)
		{
			var i,j: uint;
			parent.graphics.lineStyle(pThickness);
			
			for(i=0; i <= NumCols; i++)
			{
				parent.graphics.moveTo
				(xyToPixelCorner(i,0).x, xyToPixelCorner(i,0).y);
				parent.graphics.lineTo
				(xyToPixelCorner(i,NumRows).x, xyToPixelCorner(i,NumRows).y);	
			}
			
			for(j=0; j <= NumRows; j++)				
			{
				parent.graphics.moveTo
				(xyToPixelCorner(0,j).x, xyToPixelCorner(0,j).y);
				parent.graphics.lineTo
				(xyToPixelCorner(NumCols,j).x, xyToPixelCorner(NumCols,j).y);	
			}
		}
		
		public function drawMcGrid(parent : MovieClip, gridMc : String)
		{
			var i,j: uint;
			var tempSquare : MovieClip;
			
			for(i=0; i <= NumCols-1; i++)
			{
				for(j=0; j <= NumRows-1; j++)				
				{
					tempSquare = Util.createMc(gridMc);
					tempSquare.scaleX = mTileSize/50;
					tempSquare.scaleY = mTileSize/50;
					tempSquare.x = xyToPixelCorner(i,j).x;
					tempSquare.y = xyToPixelCorner(i,j).y
					parent.addChild(tempSquare);
				}		
			}
			
			
			
		}
		
		public function getQuadrantPoint( pPoint : Point2D) : Point2D
		{
			var x,y : int;
			if(pPoint.x < (NumCols-1)/2) 	x = -1;
			else							x = 1;
			if(pPoint.y < (NumRows-1)/2)	y = -1;
			else							y = 1;
			
			return new Point2D(x,y); 
			
		}

		
		public function  inBounds(pPosition : Point2D)
		{
			if(pPosition.x >= 0 && pPosition.x < mNumCols)
				if(pPosition.y >= 0 &&  pPosition.y < mNumRows)
					return true;
			
			return false;	
			 
		}
		
		public function tileToPixel(pTile:Point2D) : Point2D
		{
			return new Point2D
				   (pTile.x*mTileSize + mTileSize/2 + Offset.x, 
 				    pTile.y*mTileSize + mTileSize/2 + Offset.y);
		}
		
		public function xyToPixelCorner(px:uint, py:uint) : Point2D
		{
			return new Point2D
				   (px*mTileSize + Offset.x, 
 				    py*mTileSize + Offset.y);
		}
		
		public function get PixelWidth()
		{
			//Util.debug("pixel width " +mTileSize*mNumCols, this);
			return mTileSize*mNumCols;
		}
		
		public function getRandomPoint(pTileSize : Point2D = null) : Point2D
		{
			var x,y ;
			var object : TiledGameComponent = new TiledGameComponent(this, pTileSize);
		
			if(pTileSize == null)
				pTileSize = Board.ONE_TILE;
				
			Util.debug( " tile size " + pTileSize);
			Util.debug(" max " + (NumCols - pTileSize.x));
			
			var a : uint = 0;
			do
			{
				a++;
				x = Util.getRandBtw(0, NumCols - pTileSize.x);
				y = Util.getRandBtw(0, NumRows - pTileSize.y);
				object.Tile = new Point2D(x,y);
			}
			while(!isEmpty(object) && a < 30);
			
			if(a == 30)
			{
				printLogicBoard();
				GameData.reportError("could not find random point");
			}
			
			
			return new Point2D(x,y);
			
		}
		
		public function printLogicBoard()
		{
			var str : String;
				
			for(var i=0; i < NumRows; i++)
			{
				str = "";
				for (var j=0; j < NumCols; j++)
					str += logicBoard[j][i] + " ";
					
				Util.debug(str + "\n");
			}
			
		}
		
		public function getTilesInLine(pStart : Point2D, pNumTiles : uint, 
									   pNumRows : uint, pNumCols : uint) : Array
		{
			var pointArray = new Array();
			var point  : Point2D;
			var numLimited : uint;
			
			var m : int = 0;
			var n : int = 0;
			
			if(pNumRows != 0)
				numLimited = pNumRows;
			else
				numLimited = pNumCols;
			
			Util.debug("Will loop to add all targets in line ");			
			for(var k=0; k < pNumTiles; k++)
			{
				if(pNumRows !=0)
					point = new Point2D(pStart.x + n, pStart.y + m);
				else
					point = new Point2D(pStart.x + m, pStart.y + n);
				
				pointArray.push(point);
				
				n++;
				
				if(n%numLimited == 0)
				{
					n = 0;
					m++;
				}
			}
			
			return pointArray;
			
			
		}
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
	}
}