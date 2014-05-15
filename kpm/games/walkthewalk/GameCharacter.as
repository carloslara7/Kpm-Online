package com.kpm.games.walkthewalk {

  import flash.display.MovieClip;
  import fl.transitions.Tween;
  import fl.transitions.TweenEvent;
  import flash.events.Event;
  import com.kpm.common.Point2D;

  public class GameCharacter extends Character {

    private var mGoal: Boolean;

    private var mGCM: GCMovement;

    public function GameCharacter(pGoal: Boolean){

      super();

      mGoal = pGoal;

      mGCM = new GCMovement();
      mGCM.addEventListener(GCMovement.GC_MOTION_FINISH, rest, false, 0 , true);

    }

    public function setCharacterQuality(pQuality: Number, pValue: Number){
	
      switch(pQuality){
        case CharacterQuality.SPECIES: this.Kind = pValue;
                                       this.Speed = pValue;
                                       break;
        case CharacterQuality.SIZE: this.Size = pValue; break;
        case CharacterQuality.COLOR: this.Color = pValue; break;
        case CharacterQuality.MULTIPLICITY: this.Multiplicity = pValue; break;
        default: break;
      }
    }

    public function get Goal (): Boolean {
      return mGoal;
    }

    public function set Goal (pGoal: Boolean) {
      mGoal = pGoal;
    }

    public function get Speed (): Number {

      return mGCM.Speed;
    }
    public function set Speed (pValue: Number) {

      mGCM.Speed = CharacterQuality.SPEED_VALUES[pValue];
    }

    public function stayInPlace(pDelay: Number): Tween {

      return mGCM.stay(this, pDelay);
    }

    private function faceDefault(event: Event){

      this.rotation = 0;
      this.scaleX = Math.abs(this.scaleX);
      this.scaleY = Math.abs(this.scaleY);
      this.removeEventListener(GCMovement.GC_MOTION_FINISH, faceDefault);
    }

    public function gotoDestination(pDest: Point2D, pScale: Number = 1.0, pTravelTime: Number = -1): GCMovement {

      mGCM.setupMovement(this.x, this.y, pDest.x, pDest.y,
                         this.scaleX, this.scaleX * pScale);

      mGCM.addEventListener(GCMovement.GC_MOTION_FINISH, faceDefault, false, 0 , true);

      if(pTravelTime > 0)
        mGCM.TravelTime = pTravelTime;

      walk();

      mGCM.move(this);

      return mGCM;
    }

  }

}