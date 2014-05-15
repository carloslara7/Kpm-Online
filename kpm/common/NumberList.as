package com.kpm.games
{
	import flash.display.*;
	import com.kpm.common.MovieList;
	import com.kpm.common.Util;
	
	public class NumberList extends MovieList 
	{
		public var numbers					: Array;
		protected var maxDistractorHeight	: Number;

		
		public function NumberList(pObject : Object)
		{
			super(pObject.betweenDistance, pObject.minHeight);
			maxDistractorHeight = pObject.maxDistractorHeight;			
			mShapeTypes = new Array();
			
			Util.debug(maxDistractorHeight, this);			
		}		
		
		public function generateNumbers(pNumberForm  : ENumberForm, pNumberForm : ENumberForm = null,
										pRotation : Boolean = false)
		{
			init();
			
			
		}
		
		public function hitShape(pShape : MovieClip, pSameType : Boolean) : MovieClip
		{
			addChild(pShape);
			var movieArray 	: Array = hitMovies(pShape);
			removeChild(pShape);
			
			for(var i=0; i < movieArray.length; i++)
			{
				//Util.debug("model type " + Util.getClassName(movieArray[i]), this);
				//Util.debug("type " + Util.getClassName(pShape), this);
				if(pSameType)
				{
					if(Util.getClassName(movieArray[i]) == Util.getClassName(pShape))
						return movieArray[i];
				}
				else
					return movieArray[i];
			}
			
			return null;
		}
		
		public function addShape(pShape : MovieClip)
		{
			add(pShape);
			pShape.Type = Util.getClassName(pShape);
		}
		
	}
}


