package com.kpm.games.walkthewalk {

  import com.kpm.common.*;
  
  import fl.transitions.Tween;
  import fl.transitions.TweenEvent;
  import fl.transitions.easing.*;
  
  import flash.display.Graphics;
  import flash.display.MovieClip;
  import flash.display.Shape;
  import flash.events.Event;
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.utils.getDefinitionByName;
  
  public class Road extends MovieClip{

    private var mRoad: Array;
    private var mRoadLength1: Number;
    private var mRoadLength2: Number;
    private var mBeginRoadLength: Number;

    private var mNumRoadPoints: Number;

    private var mAnchors: Array;

    private var mCurrAnchor: Number;

    private var mScaleFactor: Number;

    private const SCALE_STEP: Number = 0.02;
    private const ENDING_TIME: Number = 12;

    private var mEndingSound: Sound;
    private var mSoundChannel: SoundChannel;

    private var mAnchorsExist: Boolean;

    private var mMovie: MovieClip;

    private var mPeds: Array;
    private var mNumPeds: Number;

    private var mBus: MovieClip;
    private var mLoading: Boolean;

    private var mEndTween: Tween;
    private var mEndTweenDelta: Number;

    private const NUM_ROADPOINTS: Number = 27;
    private const NAME_ROADPOINTS: String = "loc";

    public function Road(pMovie: MovieClip) {

      addChild(mMovie = pMovie);

      mRoad = new Array();
      mNumRoadPoints = NUM_ROADPOINTS;

      for(var i:Number = 1; i <= mNumRoadPoints; i++){
        mRoad[i - 1] = new Point2D(pMovie[NAME_ROADPOINTS + i].x, pMovie[NAME_ROADPOINTS + i].y);
      }

      computeRoadLength();

      mAnchorsExist = false;

      mNumPeds = 0;
      mPeds = new Array();
    }

    public function drawRoad(pColor: Number, pThickness: Number, pOpacity: Number): Shape {

      var roadShape: Shape = new Shape();
	  
      roadShape.graphics.lineStyle(pThickness, pColor, pOpacity);
      roadShape.graphics.moveTo(mRoad[0].x, mRoad[0].y);
      for(var i:Number = 1; i < mRoad.length; i++){
        roadShape.graphics.lineTo(mRoad[i].x, mRoad[i].y);
      }
	  
      return roadShape;
    }

    private function computeRoadLength() {

      mRoadLength1 = 0;
      var i: Number = 1;

      for(; i < mRoad.length - 2; i++){

        mRoadLength1 += Math.sqrt((mRoad[i + 1].x - mRoad[i].x) *
                                  (mRoad[i + 1].x - mRoad[i].x) +
                                  (mRoad[i + 1].y - mRoad[i].y) *
                                  (mRoad[i + 1].y - mRoad[i].y));
      }

      mRoadLength2 = mRoadLength1 + Math.sqrt((mRoad[i + 1].x - mRoad[i].x) *
                                              (mRoad[i + 1].x - mRoad[i].x) +
                                              (mRoad[i + 1].y - mRoad[i].y) *
                                              (mRoad[i + 1].y - mRoad[i].y));
      mBeginRoadLength = Math.sqrt((mRoad[1].x - mRoad[0].x) *
                                   (mRoad[1].x - mRoad[0].x) +
                                   (mRoad[1].y - mRoad[0].y) *
                                   (mRoad[1].y - mRoad[0].y));

    }

    public function addPed(pPed: GameCharacter){

      this.addChild(mPeds[mNumPeds] = pPed);
      mNumPeds++;
    }

    public function createAnchors(pSizes: Array,
                                  pMinimumPadding: Number) {

      var vTotalRealEstate: Number = 0;
      var vPaddingSpace: Number;
      var vPrevSize: Number;
      var vRemainderLength: Number;
      var vObjectSize: Number;
	  
      if(mAnchorsExist)
        mAnchors.splice(0, mAnchors.length);
      else
        mAnchors = new Array();
		
      mCurrAnchor = 0;

      mScaleFactor = 1.0;

      var i: Number = 0;

      while(true){

        mAnchors[0] = 0;
        vTotalRealEstate = 0;

        // First, compute the total required length for actual "real estate"
        for(i = 0; i < pSizes.length; i++){
          if(i > 0){
            mAnchors[i] = mAnchors[i - 1] + vPrevSize / 2;
          }

          vObjectSize = pSizes[i] * mScaleFactor;
          vTotalRealEstate += vObjectSize;
          mAnchors[i] += (vObjectSize / 2);
          vPrevSize = vObjectSize;
        }

        vRemainderLength = mRoadLength1 - vTotalRealEstate;
        if(vRemainderLength < (pSizes.length - 1) * pMinimumPadding){
          mScaleFactor -= SCALE_STEP;
        }
        else break;
      }

      vPaddingSpace = vRemainderLength / (pSizes.length - 1);

      for(i = 1; i < mAnchors.length; i++)
        mAnchors[i] += i * vPaddingSpace;

      mAnchorsExist = true;
    }

    public function get RoadLength(): Number {

      return mRoadLength1;
    }

    public function get ScaleFactor(): Number {
      if(mAnchorsExist)
        return mScaleFactor;
      else
        return 0;
    }

    public function get NextAnchor(): Point2D {

      if(! mAnchorsExist)
        return null;

      if(mCurrAnchor < mAnchors.length)
        mCurrAnchor += 1;

      return getAnchor(mCurrAnchor - 1);
    }

    public function resetNextAnchor() {

      mCurrAnchor = 0;
    }

    public function getAnchor(pAnchorId: Number): Point2D {

      if(! mAnchorsExist)
        return null;

      var vAnchor: Point2D = computeAnchorPos(pAnchorId);

      return new Point2D(vAnchor.x + mMovie.x, vAnchor.y + mMovie.y);
    }

    private function computeAnchorPos(pAnchorId: Number): Point2D {

      return computeAnchorPos2(mAnchors[pAnchorId]);
    }

    private function computeAnchorPos2(pAnchor: Number): Point2D {

      if(! mAnchorsExist)
        return null;

      var vLength: Number = 0;
      var vNewLength: Number = pAnchor;
      var vPrevLength: Number = 0;

      var i: Number = 1;

      for(; vLength < vNewLength && i < mRoad.length - 1; i++){

        vPrevLength = vLength;
        vLength += Math.sqrt((mRoad[i + 1].x - mRoad[i].x) *
                             (mRoad[i + 1].x - mRoad[i].x) +
                             (mRoad[i + 1].y - mRoad[i].y) *
                             (mRoad[i + 1].y - mRoad[i].y));
      }

      var t: Number;

      if(vNewLength == 0){
        return mRoad[1];
      }
      else if(vNewLength < 0){

        vNewLength += mBeginRoadLength;
        vLength = mBeginRoadLength;
      }

      t = (vNewLength - vPrevLength) / (vLength - vPrevLength);

      return new Point2D( (1 - t) * mRoad[i - 1].x + t * mRoad[i].x,
                          (1 - t) * mRoad[i - 1].y + t * mRoad[i].y );

    }

    private function onEndTweenChange1(event: TweenEvent){

      var vNewPos: Point2D;

/*
      var vNumPeds: Number = mNumPeds;

      if(mEndTweenDelta > mPeds[mNumPeds].width){
        vNumPeds += 1;
        if(! mPeds[mNumPeds].visible){
          mPeds[mNumPeds].visible = true;
          mSoundChannel = mEndingSound.play(0, 2);
        }
      }
*/

      for(var i: Number = 0; i < mNumPeds; i++){
        if(mAnchors[i] + mEndTweenDelta >= mRoadLength2){
          //mPeds[i].rest();
          if(mPeds[i].visible){
            this.removeChild(mPeds[i]);
            mPeds[i].visible = false;
          }
        }
        else {
          vNewPos = computeAnchorPos2(mAnchors[i] + mEndTweenDelta);
          mPeds[i].rotation = 180 * Math.atan2(mMovie.y + vNewPos.y - mPeds[i].y,
                                               mMovie.x + vNewPos.x - mPeds[i].x) / Math.PI;
/*
          if(mPeds[i].rotation < -90 ||
             mPeds[i].rotation > 90){
            if(mPeds[i].scaleY > 0)
              mPeds[i].scaleY *= -1;
          }
          else
            mPeds[i].scaleY = Math.abs(mPeds[i].scaleY);
*/

          mPeds[i].x = mMovie.x + vNewPos.x;
          mPeds[i].y = mMovie.y + vNewPos.y;
        }
      }
    }

    private function onEndTweenChange2(event: TweenEvent){

      var vNewPos: Point2D;

      for(var i: Number = 0; i < mNumPeds - 1; i++){

        if(mAnchors[i] - mEndTweenDelta <= mPeds[i].width - mBeginRoadLength && (! mLoading)){
          mPeds[mNumPeds - 1].gotoAndPlay("load");
          mLoading = true;
        }
        if(mAnchors[i] - mEndTweenDelta <= -mBeginRoadLength){
          if(mPeds[i].visible){
            this.removeChild(mPeds[i]);
            mPeds[i].visible = false;
            mLoading = false;
            mPeds[mNumPeds - 1].gotoAndPlay("open");
          }
        }
        else {
          vNewPos = computeAnchorPos2(mAnchors[i] - mEndTweenDelta);
          mPeds[i].rotation = 180 + 180 * Math.atan2(mMovie.y + vNewPos.y - mPeds[i].y,
                                                     mMovie.x + vNewPos.x - mPeds[i].x) / Math.PI;
          mPeds[i].x = mMovie.x + vNewPos.x;
          mPeds[i].y = mMovie.y + vNewPos.y;
        }
      }

    }

    private function onEndTweenChange2a(event: TweenEvent){

      var vNewPos: Point2D;
	  
      vNewPos = computeAnchorPos2(mAnchors[mNumPeds - 1] + mEndTweenDelta);
      mPeds[mNumPeds - 1].rotation = 180 * Math.atan2(mMovie.y + vNewPos.y - mPeds[mNumPeds - 1].y,
                                                      mMovie.x + vNewPos.x - mPeds[mNumPeds - 1].x) / Math.PI;

      mPeds[mNumPeds - 1].x = mMovie.x + vNewPos.x;
      mPeds[mNumPeds - 1].y = mMovie.y + vNewPos.y;
	}

    private function onEndTweenFinish1(event: TweenEvent){
      Util.debug("Done1!", this);
      mSoundChannel.stop();
      this.dispatchEvent(new Event(GameData.RETURN_TO_DRIVER));
    }
    
    private function onEndTweenFinish2(event: TweenEvent){

      mSoundChannel = mEndingSound.play(0, 2);
      mPeds[mNumPeds - 1].gotoAndPlay("walk");
      mEndTween = new Tween(this, "EndTweenDelta", None.easeNone, 0, mRoadLength2 + mBeginRoadLength, ENDING_TIME, true);
      mEndTween.addEventListener(TweenEvent.MOTION_CHANGE, onEndTweenChange2a, false, 0 , true);
      mEndTween.addEventListener(TweenEvent.MOTION_FINISH, onEndTweenFinish2a, false, 0 , true);
	}

    private function onEndTweenFinish2a(event: TweenEvent){
      Util.debug("Done2", this);
      this.removeChild(mPeds[mNumPeds - 1]);
      mPeds[mNumPeds - 1].visible = false;
	  mSoundChannel.stop();
	  this.dispatchEvent(new Event(GameData.RETURN_TO_DRIVER));
    }
	
    public function startEndSequence(pObjName: String, pSequence: Number){

      var ClassReference: Class = getDefinitionByName(Character.PACKAGE_NAME + pObjName) as Class;
      this.addChild((mPeds[mNumPeds] = new ClassReference()));
      ClassReference = getDefinitionByName(Character.PACKAGE_NAME + pObjName + "Sound") as Class;
      mEndingSound = new ClassReference();

      mPeds[mNumPeds].x = mMovie.x + mRoad[0].x;
      mPeds[mNumPeds].y = mMovie.y + mRoad[0].y;
      mPeds[mNumPeds].rotation = 180 * Math.atan2(mRoad[1].y - mRoad[0].y,
                                                  mRoad[1].x - mRoad[0].x) / Math.PI;

      mAnchors[mNumPeds] = -mBeginRoadLength;
      mPeds[mNumPeds].visible = true;
      var maskBus : MovieClip = new RoadMask1();
      maskBus.x = 562;
      maskBus.y = 582;
      mPeds[mNumPeds].mask = maskBus;
          	
      mLoading = false;
		
      for(var i: Number = 0; i < mNumPeds; i++){
        if(pSequence == 1)
        {
        	var mask1 : MovieClip = new RoadMask1();
          	mask1.x = 562;
          	mask1.y = 582;
          	mPeds[i].mask = mask1;
          	mPeds[i].scaleX *= -1;
          	 
        }
        else if(pSequence == 2)
        {
        	var mask2 : MovieClip = new RoadMask2();
          	mask2.x = 602;
          	mask2.y = 425;
          	mPeds[i].mask = mask2;
        	mPeds[i].parent.setChildIndex(mPeds[i], mPeds[i].parent.numChildren-1);
        	
        	
        }
        
        
        mPeds[i].walk();
      }
      
      mNumPeds++;

      if(pSequence == 1){
        mEndTween = new Tween(this, "EndTweenDelta", None.easeNone, 0, mRoadLength2 + mBeginRoadLength, ENDING_TIME, true);
        mEndTween.addEventListener(TweenEvent.MOTION_CHANGE, onEndTweenChange1, false, 0 , true);
        mEndTween.addEventListener(TweenEvent.MOTION_FINISH, onEndTweenFinish1, false, 0 , true);
        mSoundChannel = mEndingSound.play(0, 2);
      }
      else if(pSequence == 2){
        mPeds[mNumPeds - 1].gotoAndPlay("open");
        mEndTween = new Tween(this, "EndTweenDelta", None.easeNone, 0, mRoadLength1 + mBeginRoadLength, ENDING_TIME, true);
        mEndTween.addEventListener(TweenEvent.MOTION_CHANGE, onEndTweenChange2, false, 0 , true);
        mEndTween.addEventListener(TweenEvent.MOTION_FINISH, onEndTweenFinish2, false, 0 , true);
      }
    }
    
    public function stopEndingSound()
    {
    	if(mSoundChannel) 		mSoundChannel.stop();
    }

    public function get EndTweenDelta (): Number {

      return mEndTweenDelta;
    }
    public function set EndTweenDelta (pValue: Number) {

      mEndTweenDelta = pValue;
    }

  }
}