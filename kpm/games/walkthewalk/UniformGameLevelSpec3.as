package com.kpm.games.walkthewalk {

  public class UniformGameLevelSpec {

    private var mSpeciesChoice: Number;
    private var mSizeChoice: Number;
    private var mColorChoice: Number;
    private var mNumberChoice: Number;

    private var mSpeciesInv: Number;
    private var mSizeInv: Number;
    private var mColorInv: Number;
    private var mNumberInv: Number;

    private var mPlacement: Number;

    private var mNumRounds: Number;
    private var mNumGoalObjects: Number;
    private var mTotalObjects: Number;

    private var mCountingMethod: Number;
    private var mLevelType: Number;

    static private const RANDOM_CHOICE: Number = 0;

    static public const PLACEMENT_RANDOM: Number = 0;
    static public const PLACEMENT_LINEAR: Number = 1;

    static public const COUNTING_NONE: Number = -1;
    static public const COUNTING_FINGERS: Number = 0;
    static public const COUNTING_5FRAMES: Number = 1;
    static public const COUNTING_NUMERALS: Number = 2;
    static public const COUNTING_FINGERS_OR_5FRAMES: Number = 3;
    static public const COUNTING_MIXED: Number = 4;

    static public const LEVELTYPE_COUNTING: Number = 0;
    static public const LEVELTYPE_IDENTIFY_COLOR: Number = 1;
    static public const LEVELTYPE_IDENTIFY_NUMBER: Number = 2;

    public function UniformGameLevelSpec(pActivity: String, pLevel: Number, pNumRounds: Number){

      mNumRounds = pNumRounds;

      switch(pActivity){

        case "IdentifyColor":
                                              mSpeciesChoice = 0;
                                              mSizeChoice = 0;
                                              mColorChoice = -1;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 1; 
                                              mNumberInv = -1;
                                              mPlacement = PLACEMENT_LINEAR;
                                              mNumGoalObjects = 4;
                                              mTotalObjects = GameLevel.TOTALGCS_ATLEASTONEPLUSGOALS;
                                              mCountingMethod = COUNTING_NONE;
                                              mLevelType = LEVELTYPE_IDENTIFY_COLOR;
                                              
                                              switch(pLevel){

                                                case 0:
                                                         mSizeInv = 1;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 1:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                              }
                                              
                                              break;
                                              

        case "IdentifyFinger":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = -1;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mSizeInv = 1;
                                              mColorInv = 0;
                                              mNumberInv = -1;
                                              mPlacement = PLACEMENT_LINEAR;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_FINGERS;
                                              mLevelType = LEVELTYPE_IDENTIFY_NUMBER;

                                              switch(pLevel){

                                                case 0:
                                                         mNumGoalObjects = 3;
                                                         break;
                                                case 1:
                                                         mNumGoalObjects = 5;
                                                         break;
                                                         
                                                case 2:
                                                         mNumGoalObjects = 7;
                                                         break;
                                                case 3:
                                                         mNumGoalObjects = 10;
                                                         break;
                                              }

                                              break;

        case "Identify5Frame":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = -1;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mSizeInv = 1;
                                              mColorInv = 0;
                                              mNumberInv = -1;
                                              mPlacement = PLACEMENT_LINEAR;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_5FRAMES;
                                              mLevelType = LEVELTYPE_IDENTIFY_NUMBER;

                                              switch(pLevel){

                                                case 0:
                                                         mNumGoalObjects = 3;
                                                         break;
                                                case 1:
                                                         mNumGoalObjects = 5;
                                                         break;
                                              }

                                              break;

        case "IdentifyNumeral":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = -1;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mSizeInv = 1;
                                              mColorInv = 0;
                                              mNumberInv = -1;
                                              mPlacement = PLACEMENT_LINEAR;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_NUMERALS;
                                              mLevelType = LEVELTYPE_IDENTIFY_NUMBER;
                                              mNumGoalObjects = 5;

                                              break;

        case "IdentifyMixed":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = -1;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mSizeInv = 1;
                                              mColorInv = 0;
                                              mNumberInv = -1;
                                              mPlacement = PLACEMENT_LINEAR;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_MIXED;
                                              mLevelType = LEVELTYPE_IDENTIFY_NUMBER;
                                              mNumGoalObjects = 5;

                                              break;

        case "IdentifyCombined":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = -1;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mSizeInv = 1;
                                              mColorInv = 0;
                                              mNumberInv = -1;
                                              mPlacement = PLACEMENT_LINEAR;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_MIXED;
                                              mLevelType = LEVELTYPE_IDENTIFY_NUMBER;
                                              mNumGoalObjects = 5;

                                              break;

        case "Count3Mixed":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = 0;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mNumberInv = -1;
                                              mNumGoalObjects = 3;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_FINGERS_OR_5FRAMES;
                                              mLevelType = LEVELTYPE_COUNTING;

                                              switch(pLevel){

                                                case 0:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 1:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 2:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;
                                                case 3:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;

                                              }

                                              break;

        case "Count5Mixed":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = 0;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mNumberInv = -1;
                                              mNumGoalObjects = 5;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_FINGERS_OR_5FRAMES;
                                              mLevelType = LEVELTYPE_COUNTING;

                                              switch(pLevel){

                                                case 0:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 1:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 2:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;
                                                case 3:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;

                                              }

                                              break;

        case "Count3Finger":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = 0;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mNumberInv = -1;
                                              mNumGoalObjects = 3;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_FINGERS;
                                              mLevelType = LEVELTYPE_COUNTING;

                                              switch(pLevel){

                                                case 0:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 1:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 2:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;
                                                case 3:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;

                                              }

                                              break;

        case "Count5Finger":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = 0;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mNumberInv = -1;
                                              mNumGoalObjects = 5;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_FINGERS;
                                              mLevelType = LEVELTYPE_COUNTING;

                                              switch(pLevel){

                                                case 0:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 1:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 2:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;
                                                case 3:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;

                                              }

                                              break;

        case "Count3Numeral":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = 0;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mNumberInv = -1;
                                              mNumGoalObjects = 3;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_NUMERALS;
                                              mLevelType = LEVELTYPE_COUNTING;

                                              switch(pLevel){

                                                case 0:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 1:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 2:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;
                                                case 3:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;

                                              }

                                              break;

        case "Count5Numeral":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = 0;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mNumberInv = -1;
                                              mNumGoalObjects = 5;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_NUMERALS;
                                              mLevelType = LEVELTYPE_COUNTING;

                                              switch(pLevel){

                                                case 0:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 1:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 2:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;
                                                case 3:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;

                                              }

                                              break;

        case "Count35Frame":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = 0;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mNumberInv = -1;
                                              mNumGoalObjects = 3;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_5FRAMES;
                                              mLevelType = LEVELTYPE_COUNTING;

                                              switch(pLevel){

                                                case 0:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 1:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 2:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;
                                                case 3:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;

                                              }

                                              break;

        case "Count55Frame":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = 0;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mNumberInv = -1;
                                              mNumGoalObjects = 5;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_5FRAMES;
                                              mLevelType = LEVELTYPE_COUNTING;

                                              switch(pLevel){

                                                case 0:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 1:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 2:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;
                                                case 3:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;

                                              }

                                              break;

        case "Count5Combined":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = 0;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mNumberInv = -1;
                                              mNumGoalObjects = 5;
                                              mTotalObjects = GameLevel.TOTALGCS_SAMEASGOALOBJS;
                                              mCountingMethod = COUNTING_MIXED;
                                              mLevelType = LEVELTYPE_COUNTING;

                                              switch(pLevel){

                                                case 0:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 1:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 2:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;
                                                case 3:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;

                                              }

                                              break;

        case "SubsetShape55Frame":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = 0;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 0;
                                              mNumberInv = -1;
                                              mNumGoalObjects = 5;
                                              mTotalObjects = GameLevel.TOTALGCS_FIXEDATMAX;
                                              mCountingMethod = COUNTING_5FRAMES;
                                              mLevelType = LEVELTYPE_COUNTING;

                                              switch(pLevel){

                                                case 0:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 1:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 2:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;
                                                case 3:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;

                                              }

                                              break;

        case "SubsetColor5Finger":
                                              mSpeciesChoice = -1;
                                              mSizeChoice = 0;
                                              mColorChoice = -1;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 1;
                                              mNumberInv = -1;
                                              mNumGoalObjects = 5;
                                              mTotalObjects = GameLevel.TOTALGCS_ATLEASTONEPLUSGOALS;
                                              mCountingMethod = COUNTING_FINGERS;
                                              mLevelType = LEVELTYPE_COUNTING;

                                              switch(pLevel){

                                                case 0:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 1:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_LINEAR;
                                                         break;
                                                case 2:
                                                         mSizeInv = 1;
                                                         mColorInv = 1;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;
                                                case 3:
                                                         mSizeInv = 0;
                                                         mColorInv = 0;
                                                         mPlacement = PLACEMENT_RANDOM;
                                                         break;

                                              }

                                              break;

        default:
                                              mSpeciesChoice = 0;
                                              mSizeChoice = 0;
                                              mColorChoice = -1;
                                              mNumberChoice = 0;
                                              mSpeciesInv = 1;
                                              mSizeInv = 1;
                                              mColorInv = 0;
                                              mNumberInv = -1;
                                              mPlacement = PLACEMENT_LINEAR;
                                              mNumGoalObjects = 4;
                                              mTotalObjects = GameLevel.TOTALGCS_ATLEASTONEPLUSGOALS;
                                              mCountingMethod = COUNTING_NONE;
                                              mLevelType = LEVELTYPE_IDENTIFY_COLOR;

                                              break;

      }

    }

    public function get SpeciesChoice (): Number {
      return mSpeciesChoice;
    }

    public function get SizeChoice (): Number {
      return mSizeChoice;
    }
    public function get ColorChoice (): Number {
      return mColorChoice;
    }
    public function get NumberChoice (): Number {
      return mNumberChoice;
    }

    public function get SpeciesInv (): Number {
      return mSpeciesInv;
    }
    public function get SizeInv (): Number {
      return mSizeInv;
    }
    public function get ColorInv (): Number {
      return mColorInv;
    }
    public function get NumberInv (): Number {
      return mNumberInv;
    }

    public function get Placement (): Number {
      return mPlacement;
    }
    public function get NumRounds (): Number {
      return mNumRounds;
    }
    public function get NumGoalObjects (): Number {
      return mNumGoalObjects;
    }
    public function get NumTotalObjects (): Number {
      return mTotalObjects;
    }
    public function get CountingMethod (): Number {
      return mCountingMethod;
    }
    public function get LevelType (): Number {
      return mLevelType;
    }
  }

}