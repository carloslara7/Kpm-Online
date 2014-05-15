package com.kpm.common
{
	import flash.display.MovieClip;
	import flash.events.Event;
		
	public class MovieList extends MovieClip {


		protected var MovieListRows: Array ;
		protected var counter 		: uint = 0;
		private   var fixedHeight	: uint ;
		protected var betweenDist 	: uint ;
		protected var numRows		: uint;
		private   var min 	   		: Point2D ;
		protected var max			: Point2D;
		protected var vertical		: Boolean;
		
		
			
		public function MovieList(pVertical 	: Boolean = true,
								  pBetweenDist	: uint = 0, 
								  pFixedHeight	: uint = 0, 
								  pMin 		: Point2D = null,
								  pMax 		: Point2D = null,
								  pNumRows	: uint = 0 )
		{
			betweenDist = pBetweenDist;
			fixedHeight = pFixedHeight;
			min = pMin;
			max = pMax;
			vertical = pVertical;
			numRows = pNumRows
		}
		
		public function init()
		{
			counter = 0;
			for each (var p in MovieListRows)
			{
				if(p.parent == this)
					removeChild(p);	
			}
			MovieListRows = new Array();
		}
		
		public function add(pMovie : MovieClip)
		{
			var prev : MovieClip;
			
			Util.debug("MovieList.add");
			if(!MovieListRows) MovieListRows = new Array();
			if(!pMovie) throw new Error("no movie to add");
			
			if(MovieListRows.length == 0)
			{
				MovieListRows = new Array();
				pMovie.y = 0;
				pMovie.x = 0;
			}
			else if(numRows > 0 && MovieListRows.length > numRows)
			{
				Util.debug("passed limit of the movielist", this);
				return;
			}
			else
			{
				
				if(fixedHeight > 0)  
				{
					if(vertical) pMovie.y = MovieListRows.length*fixedHeight;
					else		 pMovie.x = MovieListRows.length*fixedHeight;
					//pMovie.x = MovieListArray.length*fixed.x;	
				}  
				
				else
				{
					Util.debug("between dist " + betweenDist);
					prev = MovieListRows[MovieListRows.length-1];
					if(vertical) 	pMovie.y = prev.y + prev.height + betweenDist;
					else			pMovie.x = prev.x + prev.width + betweenDist;
						
					//pMovie.x = prev.x + prev.width + between.x;
				}
			}
			
			//Util.debug("adding " + pMovie + " at location " + pMovie.x + ", " + pMovie.y );
			MovieListRows.push(addChild(pMovie));
			

						
		}
		
		public function hitPoint(pPoint : Point2D) : MovieClip
		{
			for (var i=0; i< MovieListRows.length; i++)
			{
				if(MovieListRows[i].hitTestPoint(pPoint.x, pPoint.y, true))
				{
					//Util.debug("hit true", this);
					return MovieListRows[i];
				}	
				
			}
			
			return null;
		}
		
				
		public function hitMovie(pMovie : MovieClip) : MovieClip
		{
			for (var i=0; i< MovieListRows.length; i++)
			{
				if(MovieListRows[i].hitTestObject(pMovie))
				{
					//Util.debug("hit true movie", this);
					return MovieListRows[i];
				}	
				
			}
			
			return null;
		}
		
		public function hitMovies(pMovie : MovieClip) : Array
		{
			var movieArray : Array = new Array();
			Util.debug("MovieList.hitMovies");
			Util.printArray(MovieListRows);

			for (var i=0; i< MovieListRows.length; i++)
			{
				//Util.debug(pMovie.parent, this);
				//Util.debug(mMovieListArray[i].parent, this);
				if(Util.hitBitmapData(MovieListRows[i], pMovie, pMovie.parent as MovieClip))
				//if(mMovieListArray[i].hitTestObject(pMovie))
				{
					Util.debug("hit true movies", this);
					movieArray.push(MovieListRows[i]);
				}	
				
			}
			return movieArray;
		}
		
		protected function shuffleMovieList()
		{		
			Util.shuffleArray(MovieListRows);
			var prev : MovieClip;
			
			for (var i=0; i< MovieListRows.length; i++)
			{
				if(fixedHeight > 0)
				{			
					MovieListRows[i].y = i*fixedHeight;
					//MovieListArray[i].x = i*fixed.x;	
				}	
				else
				{
					Util.debug("", this);
					Util.debug("scale " + MovieListRows[i].scaleY , this);
					var movieSize = new Point2D(MovieListRows[i].width, MovieListRows[i].height);
					if(movieSize.y < min.y)		movieSize.y = min.y;
					if(movieSize.y > max.y) 	movieSize.y = max.y;
					if(movieSize.x < min.x)  	movieSize.y = min.y;
					if(movieSize.x > max.x) 	movieSize.y = max.y;
					
					Util.debug(MovieListRows[i] + " " + movieSize, this);
					
					if(i > 0)
					{
						prev = MovieListRows[i-1];
						var prevSize : Point2D = new Point2D(prev.width, prev.height);
						
						if(prevSize.y > max.y) prevSize.y = max.y;
						if(prevSize.x > max.x) prevSize.x = max.x; 
						
						//MovieListArray[i].x = 
						//prev.x + prevSize.x/2 + movieSize.x/2 + between.x;
						MovieListRows[i].y = 
						prev.y + prevSize.y/2 + movieSize.y/2 + betweenDist;
						
						
					}
					else
					{
						//MovieListArray[i].x = movieSize.x/2;
						MovieListRows[i].y = movieSize.y/2;
						
					}
				
				}							
			}
		}
		
		public function distributeEvenly(pFixedHeight : uint)
		{
			
			if(pFixedHeight > 0)
			{
				Util.debug("movie list height " + height + " desired height " + pFixedHeight);
				//if(height < pFixedHeight)
				//{
					var add = (pFixedHeight - height)/MovieArray.length;
					
					for (var j = 0 ; j < MovieArray.length ; j++)
					{
						Util.debug("new y is " + MovieListRows[j].y);
						MovieListRows[j].y += add*j;
						Util.debug("new y is " + MovieListRows[j].y);
						Util.debug("");
					}
				//}
				
				Util.debug("movie list height " + height + " desired height " + pFixedHeight);

			}
		}
		
		public function remove(pMovie : MovieClip)
		{
			Util.removeChild(pMovie);
		}
		
		public function removeCurrent()
		{
			Util.removeChild(NextMc);
		}
		
		public function get Rows()  			{ return MovieListRows;}
		public function get MovieArray() 		{ return MovieListRows;}
		
		public function set FixedHeight(pFixed : uint) 	
		{	
			fixedHeight = pFixed;
		} 	
		
		public function get NextMc() : MovieClip
		{
			if(MovieListRows[counter] != null)
				return MovieListRows[counter++];	
			else 
				return null	
		}
		
		public function getMiddleMc() : MovieClip
		{
			return MovieListRows[MovieListRows.length/2];
		}
		
		public function getCurrentMovie() : MovieClip
		{
			Util.debug(counter, this);
			if(MovieListRows[counter] != null)
				return MovieListRows[counter];
			else 
				return null	
		}
		
		public function getArrayAttribute(pAttribute : String) : Array
		{
			var attributeArray : Array = new Array;
			
			for(var i =0; i < MovieListRows.length; i++)
			{
				Util.debug("adding " + MovieListRows[i][pAttribute], this);
				attributeArray.push(MovieListRows[i][pAttribute]);
			}
			
			return attributeArray;
		}
		
		public function getNumMoviesLeft() : Number
		{
			return MovieListRows.length - counter;
		}
		
		public function setSize( pWidth : uint, pHeight : uint)
		{
			for (var i=0; i< MovieListRows.length; i++)
			{
				MovieListRows[i].height = pHeight;
				MovieListRows[i].width = pWidth;
			}
		}
		
		public function get Counter() : uint 
		{
			return counter;
		}
		
		public function resetCounter() 
		{
			counter = 0;
		}

	}
}