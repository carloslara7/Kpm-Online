package com.kpm.games.game4 {

  import com.kpm.common.Point2D;
  import com.kpm.common.Util;
  import com.kpm.games.walkthewalk.GCMovement;
  
  import fl.transitions.Tween;
  import fl.transitions.TweenEvent;
  
  import flash.display.MovieClip;
  import flash.events.Event;
  import flash.geom.ColorTransform;
  

  public class Game4Player extends Character {


    private var mGoal: Boolean;
    private var mGCM: GCMovement;
    
    private var level : int;
    private var anchor : int;
    
    private static var board : Array = new Array(); 
    
    private var tail : MovieClip;

	private var gcColor : int;
    
    public function Game4Player(pPlayerKind : int, pColor : Number){

      super();
      
      //to move this game character
      mGCM = new GCMovement();
      mGCM.addEventListener(GCMovement.GC_MOTION_FINISH, rest, false, 0 , true);
      
      setCharacterQuality(CharQual.SPECIES, pPlayerKind);
	  setCharacterQuality(CharQual.COLOR, pColor);
	  
	  gcColor = pColor;
    }
    
    //*set qualities
    public function setCharacterQuality(pQuality: Number, pValue: Number){
	
      switch(pQuality){
        case CharQual.SPECIES: this.Kind = pValue;
                                       this.Speed = pValue;
                                       break;
        case CharQual.SIZE: this.Size = pValue; break;
        case CharQual.COLOR: this.Color = pValue; break;
        case CharQual.MULTIPLICITY: this.Multiplicity = pValue; break;
        default: break;
      }
    }
    
	public function getColor() {
		return gcColor;
	}
    
    //*set the color of the monkey or bird
    public override function set Color(pColor : Number)
    {
    	Util.debug("G4Player.setColor" + pColor);
    	
    	
    	
    	//if the kind is bird, then we need to paint the colors dynamically
    	if(getKindVal() == CharQual.BIRD)
    	{
    		if(!mMovie) 
    			mMovie = CharQual.SPECIES_NAMES[getKindVal()];
    		
    		var vColor: Object = CharQual.COLOR_VALUES[pColor];
    		trace(mMovie + " " + mMovie.transform + " " + vColor);
      		mMovie.transform.colorTransform = new ColorTransform(vColor.ra, vColor.ga, vColor.ba, vColor.aa,
                          			                             vColor.rb, vColor.gb, vColor.bb, vColor.ab);
    	}
    	
    	//otherwise we choose a different movieclip based on the name
    	else if(getKindVal() == CharQual.MONKEY)
    	{
    		mColor = pColor;
    		Util.debug("getKindVal() " + getKindVal() + " color " + pColor);
    		var movieName = CharQual.SPECIES_NAMES[getKindVal()] + CharQual.COLOR_NAMES[pColor]; 
    		Movie =  movieName;
    		//tail = addChild(Util.createMc(movieName + "Tail")) as MovieClip;
    		
    		setChildIndex(mMovie, numChildren-1);
    		
    	}
    }
    
    public override function animate(pLabel : String, pNumAnims : Number = 0)
    {
    	super.animate(pLabel,pNumAnims);
    	if(tail)
    		tail.gotoAndPlay(pLabel);
    }
    
    public function get Speed (): Number {

      return mGCM.Speed;
    }
    
    public function set Speed (pValue: Number) {
      //mGCM.Speed = CharQual.SPEED_VALUES[pValue];
	  mGCM.Speed = pValue;
    }
    

	
    public override function drag()
    {
    	super.drag();
    	animate("normalSelected");
    	buttonMode = true;
    }

	//$Move GC to a destination, possibility to specify scale and traveltime
	//if traveltime is not specified it uses the Speed values of mGCM
    public function gotoDestination(pDest: Point2D, pScale: Number = 1.0, pTravelTime: Number = -1, isJump : Boolean = false): GCMovement {

      mGCM.setupMovement(this.x, this.y, pDest.x, pDest.y,
                         this.scaleX, this.scaleX * pScale);

      mGCM.addEventListener(GCMovement.GC_MOTION_FINISH, faceDefault, false, 0 , true);

      if(pTravelTime > 0)
        mGCM.TravelTime = pTravelTime;


      // Crrection july 9th
      // walk();
      animate("moveLeft");

      mGCM.move(this, isJump);

      return mGCM;
    }
    
    public function moveAway()
    {
    	var y = Util.getRandBtw(-500,-800);
    	var x = Util.getRandBtw(0,1) ? Util.getRandBtw(-300,0) : Util.getRandBtw(1200,1500);
    	Util.debug("FlyAway to " + x + " " + y);
    	gotoDestination(new Point2D(x,y));
    	animate("moveLeft");
    	
    }
    
    //$ go back to default transformation for this player
    private function faceDefault(event: Event){

      this.rotation = 0;
      this.scaleX = Math.abs(this.scaleX);
      this.scaleY = Math.abs(this.scaleY);
      this.removeEventListener(GCMovement.GC_MOTION_FINISH, faceDefault);
    }

  }
}