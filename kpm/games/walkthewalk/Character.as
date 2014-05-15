package com.kpm.games.walkthewalk {

  import flash.display.MovieClip;
  import flash.events.Event;
  import flash.utils.getDefinitionByName;
  import flash.geom.ColorTransform;

  public class Character extends MovieClip {

    private const CHARACTER_SIZE = 60;

    private var mKind: Number;

    private var mSize: Number;

    private var mNumber: Number;

    private var mColor: Number;

    protected var mMovie: MovieClip;
	
    static const PACKAGE_NAME: String = "com.kpm.games.walkthewalk.";

    public function Character () {

      mColor = 0;
      mSize = 0;
      mNumber = 1;
      mKind = -1; // Uninitialized

    }

    public function set Kind(pKind: Number) {

      if(mKind >= 0)
        this.removeChild(mMovie);

      mKind = pKind;

      var ClassReference: Class = getDefinitionByName(PACKAGE_NAME + CharacterQuality.SPECIES_NAMES[pKind]) as Class;
      this.addChild((mMovie = new ClassReference()));

      var vAspectRatio: Number = CHARACTER_SIZE / width;
      width = CHARACTER_SIZE;
      height *= vAspectRatio;

      Size = mSize;
      Color = mColor;
	  
    }
	
    public function set Size(pSize: Number) {

      mSize = pSize;

      scaleX *= CharacterQuality.SIZE_VALUES[pSize];
      scaleY *= CharacterQuality.SIZE_VALUES[pSize];
    }

    public function set Color(pColor: Number) {

      mColor = pColor;

      var vColor: Object = CharacterQuality.COLOR_VALUES[pColor];
      mMovie.transform.colorTransform = new ColorTransform(vColor.ra, vColor.ga, vColor.ba, vColor.aa,
                                                           vColor.rb, vColor.gb, vColor.bb, vColor.ab);
    }

    public function set Multiplicity(pNumber: Number) {

      mNumber = pNumber; // Not much else now, because pNumber = 1
    }

    public function get SizeStr(): String {
      return CharacterQuality.SIZE_NAMES[mSize];
    }
	
    public function get KindStr(): String {
      return CharacterQuality.SPECIES_NAMES[mKind];
    }
	
    public function get ColorStr(): String {
      return CharacterQuality.COLOR_NAMES[mColor];
    }
	
    public function get NumberStr(): String {
      return CharacterQuality.NUMBER_NAMES[mNumber];
    }
	
    public function getSizeVal(): Number {
      return mSize;
    }
	
    public function getKindVal(): Number {
      return mKind;
    }
	
    public function getColorVal(): Number {
      return mColor;
    }

    public function getNumberVal(): Number {
      return mNumber;
    }

    public function walk (event: Event = null) {
      mMovie.gotoAndPlay("walk");
      if(typeof(mMovie.inside) != "undefined")
        mMovie.inside.gotoAndPlay("walk");
    }
    public function rest (event: Event = null) {
      mMovie.gotoAndStop("rest");
      if(typeof(mMovie.inside) != "undefined")
        mMovie.inside.gotoAndStop("rest");
    }
  }
}