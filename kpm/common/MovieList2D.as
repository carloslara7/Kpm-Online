package com.kpm.common
{
	import flash.display.MovieClip;

	public class MovieList2D extends MovieClip
	{
		public var MovieListCols 	: Array;
		public var numCols			: uint;
		public var fixedWidth		: int;
		public var betweenWidth		: int;
		public var currentCol		: int;
		
		public function MovieList2D(pNumCols : uint, pNumRows : uint, pFixed : Point2D = null, pBetween: Point2D = null)
		{
			numCols = pNumCols;
			fixedWidth = pFixed 	? 	pFixed.x 	: 0;
		 	betweenWidth = pBetween ?	pBetween.x 	: 0;
		 	
			MovieListCols = new Array(pNumCols);
			
			for (var i = 0 ; i < numCols; i++)
			{
				MovieListCols[i] = new MovieList(true, 0, pFixed.y, null, null, pNumRows);
				addChild(MovieListCols[i]);
				MovieListCols[i].x = i*betweenWidth;
				MovieListCols[i].init();
			}
		}
		
		public function shuffleMovieList()
		{
			for(var item in MovieListCols)
				MovieListCols[item].shuffleMovieList();
		}
		
		public function add(pMovie : MovieClip)
		{
			if(MovieListCols[currentCol].Rows.lenght > 5)
				currentCol++;
				
			MovieListCols[currentCol].add(pMovie);
				
		}
		

	
		
		public function get Cols() : Array
		{
			return MovieListCols;
		}
	}
}