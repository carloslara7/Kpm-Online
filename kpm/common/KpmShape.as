﻿package com.kpm.common{	import flash.display.*;	import flash.events.*;	import flash.geom.ColorTransform;			public class KpmShape extends GameComponent {		private var mType 			: String;		public var color			: EColor;		public var tFill			: MovieClip;		public var tStroke			: MovieClip;		public var attempts			: int;		public var shapeInList		: MovieClip;				public function KpmShape()		{			super();					}			public static function makeShape(pStageMovie : MovieClip, pCopyColor : Boolean = false) :  KpmShape		{			var shape : KpmShape = new KpmShape();			shape.attempts = 0;			shape.Type = Util.getClassName(pStageMovie);			shape.MovieName = shape.Type;			Util.debug("making shape of type : " + shape.Type);			//shape.Type = KpmShape.identifyShape(pStageMovie);					if(shape.Type == null || shape.Type == "flash.display::MovieClip")			{				Util.debug(pStageMovie, KpmShape);				Util.debug("not identified", KpmShape);				return null;			}						shape.shapeInList = pStageMovie;				shape.clone(pStageMovie); 			shape.mouseEnabled = false;			shape.Movie.mouseEnabled = false;			shape.Movie.tStroke.mouseEnabled = false;			shape.Movie.tFill.mouseEnabled = false;			if(!pCopyColor) 	shape.paintFill();			//Util.debug("scaleX " + shape.Type + " " + scaleX + " " + scaleY, this);			return shape;							}				public override function clone (pStageMovie : MovieClip)		{			super.clone(pStageMovie);			tStroke = pStageMovie.tStroke;			addChild(tStroke);			tFill = pStageMovie.tFill;			addChild(tFill);		}				public function paintFill(pColor : EColor = null)		{			var myColorTransform : ColorTransform = new ColorTransform();		   		    if(pColor)		    {		    	myColorTransform.color = GameLib.colorsRGB[pColor.Text];		    	color = pColor;		    } 		    else		    {		    	myColorTransform.color = Util.generateColor();		    }			    		    tFill.transform.colorTransform = myColorTransform		}				public function equals(pShape : KpmShape) : Boolean		{			return this.Movie == pShape.Movie; 					}			public function getShortType () : String		{			return KpmShape.getShortType(mType);		}				public function get Text() : String		{			return getShortType();		}				public static function getShortType (s : String) : String		{			if(s.indexOf("Triangle") != -1)				return "Triangle";			if(s.indexOf("Rectangle") != -1)				return "Rectangle";			if(s.indexOf("Trapezoid") != -1)				return "Trapezoid";				else return s;		}				public override function toString() : String		{			return "[KpmShape "+ color + " " + Type +" ]";		}				public function get Type()	   : String	  { return mType;}		public function set Type(pType : String) {mType = pType;}							}}