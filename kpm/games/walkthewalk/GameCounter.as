package com.kpm.games.walkthewalk {

  import com.kpm.common.ENumber;
  import com.kpm.common.Util;
  
  import flash.display.MovieClip;
  import flash.utils.getDefinitionByName;
  
  public class GameCounter extends MovieClip {

    private var mMovie: MovieClip;

    private var mCounterType: Number;
    private var mCounterTypes : Array;

    private var mValue: Number;

    private var mGoal: Boolean;

    static private var COUNTER_MOVIES: Array = new Array();
    COUNTER_MOVIES[UniformGameLevelSpec.COUNTING_FINGERS] = "Finger";
    COUNTER_MOVIES[UniformGameLevelSpec.COUNTING_DICES] = "DiceDots";
    COUNTER_MOVIES[UniformGameLevelSpec.COUNTING_5FRAMES] = "FiveFrame";
    COUNTER_MOVIES[UniformGameLevelSpec.COUNTING_NUMERALS] = "Numeral";
    COUNTER_MOVIES[UniformGameLevelSpec.COUNTING_MIXED] = "Mixed";
    

    public function GameCounter(pCountingMethod: Number, pValue: Number, pGoal :Boolean = false) {
      
      if(pCountingMethod == UniformGameLevelSpec.COUNTING_MIXED)
      	mCounterTypes = [0,1,2,3];	
      else
      	mCounterType = pCountingMethod;
      
      mValue = pValue;
      mGoal = pGoal;
      
      

      switch(pCountingMethod){
			
		  case UniformGameLevelSpec.COUNTING_NONE: return;
		  default:  createMovieByCounterType();
		  			  
//        case UniformGameLevelSpec.COUNTING_FINGERS_OR_5FRAMES:
//
//                                  if(Math.random() < 0.5)
//                                    mCounterType = UniformGameLevelSpec.COUNTING_FINGERS;
//                                  else
//                                    mCounterType = UniformGameLevelSpec.COUNTING_5FRAMES;
//
//        case UniformGameLevelSpec.COUNTING_FINGERS:
//        case UniformGameLevelSpec.COUNTING_5FRAMES:
//        case UniformGameLevelSpec.COUNTING_NUMERALS:
//        case UniformGameLevelSpec.COUNTING_MIXED:   
                                                                   

      }

    }

    private function createMovieByCounterType(){
	  
	  if(mCounterTypes)
	  	mCounterType = Util.getRandBtw(0,mCounterTypes.length-1);
	  	
	 
	  	
      var ClassReference: Class = getDefinitionByName(Character.PACKAGE_NAME +
                                                     COUNTER_MOVIES[mCounterType] + mValue) as Class;
      this.addChild((mMovie = new ClassReference()));

    }

	static public function createCounters(pGoal : Number, pLevelSpec: UniformGameLevelSpec): Array {
	  
      var vCounters: Array = new Array();
      var numberArray : Array ;
      
      Util.debug("total objects code " + pLevelSpec.NumTotalObjects);
      Util.debug("max objects " + GameLevel.MAX_TOTAL_OBJECTS);
      Util.debug("max goals " + GameLevel.MAX_GOAL_OBJECTS);
      Util.debug("num goal objects " + pLevelSpec.NumGoalObjects);
      
      
	  numberArray = Util.generateNumberArray(pGoal , GameLevel.MAX_GOAL_OBJECTS);
	  
	  for(var k=0; k < numberArray.length; k++)
	  {
	  	vCounters[k] = new GameCounter(pLevelSpec.CountingMethod, numberArray[k].Text);
	  	if(numberArray[k].Text == pGoal)
	  		vCounters[k].Goal = true;
	  		
	  	Util.debug("goal " + pGoal + " " + vCounters[k].Value + " " + vCounters[k].Goal , GameCounter);
	  }
	  
	  
      return vCounters;
    }
	
    public function get CounterType (): Number {
      return mCounterType;
    }
    public function get Value (): Number {
      return mValue;
    }
    public function get Goal (): Boolean {
      return mGoal;
    }
    public function set Goal (pGoal: Boolean) {
      mGoal = pGoal;
    }
  }
}