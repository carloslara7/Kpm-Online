package com.kpm.games.walkthewalk {

  import com.kpm.common.*;
  import flash.display.MovieClip;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import fl.transitions.Tween;
  import fl.transitions.TweenEvent;

  public class InteractionPanel extends EventDispatcher {

    public var mCornerX: Number;
    public var mCornerY: Number;
    public var mSizeX: Number;
    public var mSizeY: Number;

    static public const DEFAULT_XDIST: Number = 800;
    static public const DEFAULT_YDIST: Number = 0;

    static public const DEFAULT_TIME_TO_APPEAR: Number = 24;

    static public const X_OFFSET: Number = 0.35;
    static public const Y_OFFSET: Number = 0.3;

    static public const X_AREA: Number = 0.6;
    static public const Y_AREA: Number = 0.3;

    static public const GCS_PER_LINE: Number = 5;

    static public const H_GAP: Number = 0.35;
    static public const V_GAP: Number = 0.2;

    static private const MAX_RANDOM_PLACEMENTS: Number = 100;
    static private const SCALE_STEP: Number = 0.02;
    static private const FIVEFRAME_SLANT: Number = -35;

    static private const COUNTER_NAME: String = "hand";
    static private const NUM_COUNTERS: Number = 5;

    static public const MOTION_TO_STAGE_COMPLETE: String = "MOTION_TO_STAGE_COMPLETE";

    private var mCounterPos: Array;

    private var mGCs: Number;
    private var mGCsOnStage: Number;

    private var mGCMove: Array;

    private var mGameCounters: Array;
    private var mMovie: MovieClip;

    public function InteractionPanel(pPanel: MovieClip){

      mMovie = pPanel;
	  Util.debug("initializing", this);
	  Util.debug(mMovie.x + " " + X_OFFSET + " " + mMovie.width, this);
	  Util.debug(mMovie.y + " " + Y_OFFSET + " " + mMovie.height, this);
	  
      mCornerX = mMovie.x - X_OFFSET * mMovie.width;
      mCornerY = mMovie.y - Y_OFFSET * mMovie.height;

      mSizeX = X_AREA * mMovie.width;
      mSizeY = Y_AREA * mMovie.height;
      
      Util.debug(mCornerX + " " + mSizeX, this);
      Util.debug(mCornerY + " " + mSizeY, this);

      mGCMove = new Array();

      hideDefaultCounters();
      setDefaultCounterPos();

    }

    public function moveCharactersToIP(pGameCharacters: Array, pXDist: Number = DEFAULT_XDIST,
                                       pYDist: Number = DEFAULT_YDIST, pTime: Number = DEFAULT_TIME_TO_APPEAR){

      mGCs = pGameCharacters.length;
      mGCsOnStage = 0;
      for(var i: Number = 0; i < pGameCharacters.length; i++){
        mGCMove[i] = pGameCharacters[i].gotoDestination(new Point2D(pGameCharacters[i].x - pXDist,
                                                                    pGameCharacters[i].y - pYDist), 1.0, pTime);
        mGCMove[i].addEventListener(GCMovement.GC_MOTION_FINISH, gcOnStage);
      }

    }

    private function gcOnStage(event: Event){

      mGCsOnStage++;

      if(mGCsOnStage >= mGCs){
        for(var i: Number = 0; i < mGCs; i++)
          mGCMove[i].removeEventListener(GCMovement.GC_MOTION_FINISH, gcOnStage);
        dispatchEvent(new Event(MOTION_TO_STAGE_COMPLETE));
      }
    }

    public function placeCharactersLinear(pGameCharacters: Array, pXDist: Number = DEFAULT_XDIST,
                                          pYDist: Number = DEFAULT_YDIST){

      var vMaxHeight: Number;
      var vMaxWidth: Number;
      var vNumGCS: Number = 0;

      var vBeginX: Number;
      var vBeginY: Number = mCornerY + pYDist;

      var i: Number;
	  
      do {

        vMaxHeight = vMaxWidth = 0;

        for(i = 0; vNumGCS + i < pGameCharacters.length && i < GCS_PER_LINE; i++){
          if(pGameCharacters[vNumGCS + i].height > vMaxHeight)
            vMaxHeight = pGameCharacters[vNumGCS + i].height;
          if(pGameCharacters[vNumGCS + i].width > vMaxWidth)
            vMaxWidth = pGameCharacters[vNumGCS + i].width;
        }

        vBeginX = mCornerX + 0.3 * vMaxWidth + pXDist;

        for(i = 0; vNumGCS + i < pGameCharacters.length && i < GCS_PER_LINE; i++){

          pGameCharacters[vNumGCS + i].x = vBeginX;
          pGameCharacters[vNumGCS + i].y = vBeginY + vMaxHeight / 2 - pGameCharacters[vNumGCS + i].height / 2;

          vBeginX += (pGameCharacters[vNumGCS + i].width / 2) * (1 + H_GAP);
          if(vNumGCS + i + 1 < pGameCharacters.length)
            vBeginX += (pGameCharacters[vNumGCS + i + 1].width / 2) * (1 + H_GAP);
        }

        vBeginY += vMaxHeight * (1 + V_GAP);

        vNumGCS += i;

      } while(vNumGCS < pGameCharacters.length);

    }

    public function placeCharactersRandom(pGameCharacters: Array, pXDist: Number = DEFAULT_XDIST,
                                          pYDist: Number = DEFAULT_YDIST){

      for(var i: Number = 0; i < pGameCharacters.length; i++){

        var vPlacementCount: Number = 0;
        var j: Number;
		
		var k = 0;
		
        while(k < 50){
          k++;
          
          pGameCharacters[i].x = mCornerX + Math.random() * mSizeX + pXDist;
          pGameCharacters[i].y = mCornerY + Math.random() * mSizeY + pYDist;

          vPlacementCount++;
			
		  Util.debug("i " + i  + " " + pGameCharacters[i].x + " " + pGameCharacters[i].y, this);
          Util.debug(" ", this);
		  	
          for(j = 0; j < i; j++)
          {
          	Util.debug("j " + j + " " +  pGameCharacters[j].x + " " + pGameCharacters[j].y, this)
          	Util.debug(" ", this);
          	if(Util.intersect(pGameCharacters[i].parent, pGameCharacters[j].parent, mMovie))
            //if(pGameCharacters[i].hitTestObject(pGameCharacters[j])) 
            {
            	break;
            }
          }

          if(j >= i)
            break;

          if(vPlacementCount >= MAX_RANDOM_PLACEMENTS){
            for(j = 0; j < pGameCharacters.length; j++){
              pGameCharacters[j].scaleX -= SCALE_STEP;
              pGameCharacters[j].scaleY -= SCALE_STEP;
            }
            vPlacementCount = 0;
          }
        }

      }
    }

    public function placeCounters(pGameCounters: Array){

      var i: int;
	  
      if(pGameCounters.length >= NUM_COUNTERS){ // Place the first NUM_COUNTERS of pGameCounters
        for(i = 0; i < NUM_COUNTERS; i++){
          pGameCounters[i].x = mCounterPos[i].x;
          pGameCounters[i].y = mCounterPos[i].y;
        }
      }
      else { // Distribute empty spaces evenly

        var vNumEmpties: int = NUM_COUNTERS - pGameCounters.length;
        var vNumPerGroup: int = pGameCounters.length / (vNumEmpties + 1);
        var vNumLastGroup: int = vNumPerGroup + pGameCounters.length - vNumPerGroup * (vNumEmpties + 1);

        var j: int = 0;

        for(i = 0; i < pGameCounters.length; i++, j++){
          pGameCounters[i].x = mCounterPos[j].x;
          pGameCounters[i].y = mCounterPos[j].y;
          if( (i < pGameCounters.length - vNumLastGroup) &&
              (vNumPerGroup == 1 || (i + 1) % vNumPerGroup == 0) ){
            j++;
          }
        }
      }
	  
      mGameCounters = pGameCounters;

      for(i = 0; i < mGameCounters.length; i++){
        mMovie.addChild(mGameCounters[i]);
        if(mGameCounters[i].CounterType == UniformGameLevelSpec.COUNTING_5FRAMES)
          mGameCounters[i].rotation = FIVEFRAME_SLANT;
	  }
    }

    private function removeCounters(){
      for(var i: int = 0; i < mGameCounters.length; i++)
        mMovie.removeChild(mGameCounters[i]);
	}

    private function hideDefaultCounters() {

      for(var i: Number = 1; i <= NUM_COUNTERS; i++)
        mMovie[COUNTER_NAME + i].visible = false;
    }

    private function setDefaultCounterPos() {

      mCounterPos = new Array();

      for(var i: Number = 0; i < NUM_COUNTERS; i++)
        mCounterPos[i] = new Point2D(mMovie[COUNTER_NAME + (i + 1)].x, mMovie[COUNTER_NAME + (i + 1)].y);
    }
  }
}