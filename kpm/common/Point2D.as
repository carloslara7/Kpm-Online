package com.kpm.common{	public class Point2D 	{		public var x : int;		public var y : int;				public function Point2D(newx:int, newy:int)		{			x = newx;			y = newy;		}		public function clone() : Point2D		{			return new Point2D(x,y);		}
		
		public function add(pPoint : Point2D)
		{
			x+= pPoint.x;
			y+= pPoint.y;
		}
		
		public function multiply(pMult : Number)
		{
			x*=pMult;
			y*=pMult;
		}
		
		public function print()
		{
			Util.debug(" x " + x + " y " + y , this);
		}				public function get Text() : String		{			return "[ x : " + x + " y : " + y + " ] ";
		}
		
		public function toString() : String
		{
			return (" [ Point2D : x " + x + " y " + y + " ] " );
		}
		public function equals(p1 : Point2D) : Boolean
		{
			if(x == p1.x && y == p1.y)
				return true;
			return false;	
		}	}	
	
		}