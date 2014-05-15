package com.kpm.games.walkthewalk {

  import flash.display.MovieClip;
  import flash.text.TextField;
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.utils.getDefinitionByName;

  public class GameMessage extends EventDispatcher {

    // private var mBeginQuestion: Number;
    private var mDesc: Array;
    // private var mEndQuestion: Number;

    private var mMessageType: Number;
    private var mQuestionType: Number;

    private var mLanguage: String;

    private var mText: String;
    private var mSound: Sound;
    private var mSoundArray: Array;
    private var mSoundChannel: SoundChannel;

    private var mCurrentSound: Number;
    private var mSoundComplete: Boolean;

    static public const MESSAGE_SOUND_PLAYED: String = "MESSAGE_SOUND_PLAYED";

    static public const LANG_ENG: String = "ENG";
    static public const LANG_SPA: String = "SPA";

    private const BAD_MOVE_BOING: String = "boing";

    static public const MSG_QUESTION: Number = 0;
    static public const MSG_SUCCESS: Number = 1;
    static public const MSG_FAILURE: Number = 2;
    static public const MSG_TRYAGAIN: Number = 3;
    static private const MSG_FEEDBACK_CLICK: Number = 4;
    static private const MSG_FEEDBACK_CLICK_ONE: Number = 5;
    static public const MSG_FEEDBACK: Number = 6;
    static public const MSG_WELCOME: Number = 10;

    static public var MSG_BEGIN_QUESTION: Array = new Array();

    static public const MSG_BEGIN_QUESTION_COUNTING: Number =
                        MSG_BEGIN_QUESTION[UniformGameLevelSpec.LEVELTYPE_COUNTING] = MSG_WELCOME + 1;
    static public const MSG_BEGIN_QUESTION_IDENTIFY_COLOR: Number =
                        MSG_BEGIN_QUESTION[UniformGameLevelSpec.LEVELTYPE_IDENTIFY_COLOR] = MSG_WELCOME + 2;
    static public const MSG_BEGIN_QUESTION_IDENTIFY_SIZE: Number =
                        MSG_BEGIN_QUESTION[UniformGameLevelSpec.LEVELTYPE_IDENTIFY_SIZE] = MSG_WELCOME + 3;                    
    static public const MSG_BEGIN_QUESTION_IDENTIFY_NUMBER: Number =
                        MSG_BEGIN_QUESTION[UniformGameLevelSpec.LEVELTYPE_IDENTIFY_NUMBER] = MSG_WELCOME + 4;

    static public var MSG_END_QUESTION: Array = new Array();

    static public const MSG_END_QUESTION_COUNTING: Number =
                        MSG_END_QUESTION[UniformGameLevelSpec.LEVELTYPE_COUNTING] = MSG_WELCOME + 5;
    static public const MSG_END_QUESTION_IDENTIFY_COLOR: Number =
                        MSG_END_QUESTION[UniformGameLevelSpec.LEVELTYPE_IDENTIFY_COLOR] = MSG_WELCOME + 6;
	static public const MSG_END_QUESTION_IDENTIFY_SIZE: Number =
                        MSG_END_QUESTION[UniformGameLevelSpec.LEVELTYPE_IDENTIFY_SIZE] = MSG_WELCOME + 7;                        
    static public const MSG_END_QUESTION_IDENTIFY_NUMBER: Number =
                        MSG_END_QUESTION[UniformGameLevelSpec.LEVELTYPE_IDENTIFY_NUMBER] = MSG_WELCOME + 8;


    static public var NUM_SOUNDS: Array = new Array();
    NUM_SOUNDS[LANG_ENG] = new Array();
    NUM_SOUNDS[LANG_SPA] = new Array();

    NUM_SOUNDS[LANG_ENG][MSG_SUCCESS] = 3;
    NUM_SOUNDS[LANG_ENG][MSG_FAILURE] = 3;
    NUM_SOUNDS[LANG_ENG][MSG_TRYAGAIN] = 2;
    NUM_SOUNDS[LANG_ENG][MSG_FEEDBACK_CLICK] = 2;
    NUM_SOUNDS[LANG_ENG][MSG_FEEDBACK_CLICK_ONE] = 2;
    NUM_SOUNDS[LANG_ENG][MSG_WELCOME] = 1;
    NUM_SOUNDS[LANG_ENG][MSG_BEGIN_QUESTION_COUNTING] = 2;
    NUM_SOUNDS[LANG_ENG][MSG_BEGIN_QUESTION_IDENTIFY_COLOR] = 1;
    NUM_SOUNDS[LANG_ENG][MSG_BEGIN_QUESTION_IDENTIFY_SIZE] = 1;
    NUM_SOUNDS[LANG_ENG][MSG_BEGIN_QUESTION_IDENTIFY_NUMBER] = 1;
    NUM_SOUNDS[LANG_ENG][MSG_END_QUESTION_COUNTING] = 2;
    NUM_SOUNDS[LANG_ENG][MSG_END_QUESTION_IDENTIFY_COLOR] = 0;
    NUM_SOUNDS[LANG_ENG][MSG_END_QUESTION_IDENTIFY_SIZE] = 0;
    NUM_SOUNDS[LANG_ENG][MSG_END_QUESTION_IDENTIFY_NUMBER] = 0;

    NUM_SOUNDS[LANG_SPA][MSG_SUCCESS] = 3;
    NUM_SOUNDS[LANG_SPA][MSG_FAILURE] = 3;
    NUM_SOUNDS[LANG_SPA][MSG_TRYAGAIN] = 3;
    NUM_SOUNDS[LANG_SPA][MSG_FEEDBACK_CLICK] = 3;
    NUM_SOUNDS[LANG_SPA][MSG_FEEDBACK_CLICK_ONE] = 2;
    NUM_SOUNDS[LANG_SPA][MSG_WELCOME] = 1;
    NUM_SOUNDS[LANG_SPA][MSG_BEGIN_QUESTION_COUNTING] = 1;
    NUM_SOUNDS[LANG_SPA][MSG_BEGIN_QUESTION_IDENTIFY_COLOR] = 2;
    NUM_SOUNDS[LANG_SPA][MSG_BEGIN_QUESTION_IDENTIFY_NUMBER] = 2;
    NUM_SOUNDS[LANG_SPA][MSG_BEGIN_QUESTION_IDENTIFY_SIZE] = 2;
    NUM_SOUNDS[LANG_SPA][MSG_END_QUESTION_COUNTING] = 0;
    NUM_SOUNDS[LANG_SPA][MSG_END_QUESTION_IDENTIFY_COLOR] = 0;
    NUM_SOUNDS[LANG_SPA][MSG_END_QUESTION_IDENTIFY_SIZE] = 0;
    NUM_SOUNDS[LANG_SPA][MSG_END_QUESTION_IDENTIFY_NUMBER] = 0;

    static public var MSG_SOUND: Array = new Array();
    MSG_SOUND[LANG_ENG] = new Array();
    MSG_SOUND[LANG_SPA] = new Array();

    MSG_SOUND[LANG_ENG][MSG_SUCCESS] = new Array("Excellent", "VeryGood", "GoodJob");
    MSG_SOUND[LANG_ENG][MSG_FAILURE] = new Array("HmmAreYouSure", "AreYouSure", "Hmm");
    MSG_SOUND[LANG_ENG][MSG_TRYAGAIN] = new Array("TryAgain", "PleaseTryAgain");
    MSG_SOUND[LANG_ENG][MSG_FEEDBACK_CLICK] = new Array("YouClickedOn", "Thats");
    MSG_SOUND[LANG_ENG][MSG_FEEDBACK_CLICK_ONE] = new Array("YouClickedOnA", "ThatsA");
    MSG_SOUND[LANG_ENG][MSG_WELCOME] = new Array("ZooWelcome1");

    MSG_SOUND[LANG_ENG][MSG_BEGIN_QUESTION_COUNTING] = new Array("HowMany", "ShowHowMany");
    MSG_SOUND[LANG_ENG][MSG_BEGIN_QUESTION_IDENTIFY_COLOR] = new Array("ClickOn");
    MSG_SOUND[LANG_ENG][MSG_BEGIN_QUESTION_IDENTIFY_NUMBER] = new Array("ClickOn");
    MSG_SOUND[LANG_ENG][MSG_BEGIN_QUESTION_IDENTIFY_SIZE] = new Array("ClickOn");

    MSG_SOUND[LANG_ENG][MSG_END_QUESTION_COUNTING] = new Array("AreThere", "DoYouSee");

    MSG_SOUND[LANG_SPA][MSG_SUCCESS] = new Array("GoodMove1", "GoodMove2", "GoodMove3");
    MSG_SOUND[LANG_SPA][MSG_FAILURE] = new Array("Hmm1", "Hmm2", "Hmm3");
    MSG_SOUND[LANG_SPA][MSG_TRYAGAIN] = new Array("TryAgain1", "TryAgain2", "TryAgain3");
    MSG_SOUND[LANG_SPA][MSG_FEEDBACK_CLICK] = new Array("YouClickedOn1", "YouClickedOn2", "YouClickedOn3");
    MSG_SOUND[LANG_SPA][MSG_FEEDBACK_CLICK_ONE] = new Array("YouClickedOnA1", "YouClickedOnA2");
    MSG_SOUND[LANG_SPA][MSG_WELCOME] = new Array("ZooWelcome1");

    MSG_SOUND[LANG_SPA][MSG_BEGIN_QUESTION_COUNTING] = new Array("HowMany");
    MSG_SOUND[LANG_SPA][MSG_BEGIN_QUESTION_IDENTIFY_COLOR] = new Array("ClickOn1", "ClickOn2");
    MSG_SOUND[LANG_SPA][MSG_BEGIN_QUESTION_IDENTIFY_NUMBER] = new Array("ClickOn1", "ClickOn2");
    MSG_SOUND[LANG_SPA][MSG_BEGIN_QUESTION_IDENTIFY_SIZE] = new Array("ClickOn1", "ClickOn2");

    MSG_SOUND[LANG_SPA][MSG_END_QUESTION_COUNTING] = new Array("AreThere", "DoYouSee");

    static public var MSG_TEXT: Array = new Array();
    MSG_TEXT[MSG_SUCCESS] = "Well Done!";
    MSG_TEXT[MSG_FAILURE] = "This is not correct!";
    MSG_TEXT[MSG_TRYAGAIN] = "Try Again!";
    MSG_TEXT[MSG_FEEDBACK_CLICK] = "You clicked on";
    MSG_TEXT[MSG_FEEDBACK_CLICK_ONE] = "You clicked on a";
    MSG_TEXT[MSG_WELCOME] = "Welcome to Kid's Zoo!";
    MSG_TEXT[MSG_BEGIN_QUESTION_COUNTING] = "Show how many";
    MSG_TEXT[MSG_BEGIN_QUESTION_IDENTIFY_COLOR] = "Please click on a";
    MSG_TEXT[MSG_BEGIN_QUESTION_IDENTIFY_NUMBER] = "Please click on";
    MSG_TEXT[MSG_BEGIN_QUESTION_IDENTIFY_SIZE] = "Please click on";
    MSG_TEXT[MSG_END_QUESTION_COUNTING] = "are displayed!";
    MSG_TEXT[MSG_END_QUESTION_IDENTIFY_COLOR] = "";
    MSG_TEXT[MSG_END_QUESTION_IDENTIFY_SIZE] = "";
    MSG_TEXT[MSG_END_QUESTION_IDENTIFY_NUMBER] = "";

    public function GameMessage (pLanguage: String, pMessageType: Number, pDesc: Array = null,
                                 pLevelSpec: UniformGameLevelSpec = null) {

      mLanguage = pLanguage;

      mMessageType = pMessageType;

      mSoundArray = null;

      if(mMessageType == MSG_QUESTION){
        mQuestionType = pLevelSpec.LevelType;

        mDesc = pDesc;
        
		/*
		if((mQuestionType == UniformGameLevelSpec.LEVELTYPE_COUNTING && mLanguage == LANG_ENG) ||
           (mQuestionType != UniformGameLevelSpec.LEVELTYPE_COUNTING && mLanguage == LANG_SPA)){
          mSoundArray = new Array();
          createSoundSequence();
        }
        else {
          mSound = createSingleSound();
        }
		*/
		
      }
      else if(mMessageType == MSG_FEEDBACK){
        mDesc = pDesc;
       
		
		if(pLevelSpec.LevelType == UniformGameLevelSpec.LEVELTYPE_IDENTIFY_COLOR ||
           pLevelSpec.LevelType == UniformGameLevelSpec.LEVELTYPE_IDENTIFY_SIZE )
          mMessageType = MSG_FEEDBACK_CLICK_ONE;
        else
          mMessageType = MSG_FEEDBACK_CLICK;

		/*
        mSoundArray = new Array();
        createSoundSequence();
		*/
      }
      else
        //createSoundSequence();

      mSoundComplete = true;

      mText = createTextMessage();

    }

    public function writeMessageTo(pTextBox: TextField){
        pTextBox.text = mText;
    }

    public function get MsgText(): String {

      return mText;
    }

    public function playSound() {

      mSoundComplete = false;

      if(mSoundArray){
        mCurrentSound = 0;
        mSoundChannel = mSoundArray[0].play();
        if(mSoundArray.length > 1)
          mSoundChannel.addEventListener(Event.SOUND_COMPLETE, playNextSound, false, 0 , true);
        else
          mSoundChannel.addEventListener(Event.SOUND_COMPLETE, soundDone, false, 0 , true);
      }
      else {
        mSoundChannel = mSound.play();
        mSoundChannel.addEventListener(Event.SOUND_COMPLETE, soundDone, false, 0 , true);
      }
    }

	/* Carlos */
	public function stopSound()
	{
		if(!mSoundChannel) 
			return; 
			
		mSoundChannel.stop();
		mSoundChannel.removeEventListener(Event.SOUND_COMPLETE, soundDone);
		mSoundChannel.removeEventListener(Event.SOUND_COMPLETE, playNextSound);
	}
	/* Carlos */
	
    private function playNextSound(event: Event) {
	//trace("PLAY NEXT SOUND!");
      mCurrentSound++;
      if(mCurrentSound < mSoundArray.length){
        mSoundChannel = mSoundArray[mCurrentSound].play();
      }
      if(mCurrentSound < mSoundArray.length - 1)
        mSoundChannel.addEventListener(Event.SOUND_COMPLETE, playNextSound, false, 0 , true);
      else
        mSoundChannel.addEventListener(Event.SOUND_COMPLETE, soundDone, false, 0 , true);
    }

    private function soundDone(event: Event) {
	  //trace("SOUND DONE!");
	  mSoundComplete = true;
      dispatchEvent(new Event(MESSAGE_SOUND_PLAYED));
    }

    private function createTextMessage(): String {

      if(mMessageType == MSG_QUESTION)
        return MSG_TEXT[MSG_BEGIN_QUESTION[mQuestionType]] + " " + getGCQualitiesList(" ", " ") + " " +
               MSG_TEXT[MSG_END_QUESTION[mQuestionType]];
      else if(mMessageType == MSG_FEEDBACK_CLICK || mMessageType == MSG_FEEDBACK_CLICK_ONE)
        return MSG_TEXT[mMessageType] + " " + getGCQualitiesList(" ", " ");

      return MSG_TEXT[mMessageType];
    }

    private function createSingleSound(): Sound {

      if(mMessageType == MSG_QUESTION){

        var vBeginQuestion: String = getRandomSoundName(MSG_BEGIN_QUESTION[mQuestionType]);
        var vGoalsList: String = getGCQualitiesList("-", "");
        var vEndQuestion: String = getRandomSoundName(MSG_END_QUESTION[mQuestionType]);

        return getSoundClass(vBeginQuestion + vGoalsList + vEndQuestion, mLanguage);
      }
	  
      return null;
    }

    private function createSoundSequence(){

      if(mSoundArray == null)
        mSoundArray = new Array();

      var vGoalsList: Array;
      var i: Number;
	  
      if(mMessageType == MSG_QUESTION){

        var vBeginQuestion: String = getRandomSoundName(MSG_BEGIN_QUESTION[mQuestionType]);

        if(mLanguage == LANG_ENG) // Word-by-word for English - this is temporary
          vGoalsList = (getGCQualitiesList("", "-")).split("-");
        else
          vGoalsList = (getGCQualitiesList("", "")).split("-"); // Whole sequence for others, i.e. SPA

        var vEndQuestion: String = getRandomSoundName(MSG_END_QUESTION[mQuestionType]);

        mSoundArray[0] = getSoundClass(vBeginQuestion, mLanguage);

        for(i = 1; i < 1 + vGoalsList.length; i++)
          mSoundArray[i] = getSoundClass(vGoalsList[i - 1], mLanguage);

        if(vEndQuestion != null && vEndQuestion != "")
          mSoundArray[vGoalsList.length + 1] = getSoundClass(vEndQuestion, mLanguage);
      }
      else if(mMessageType == MSG_FEEDBACK_CLICK ||
              mMessageType == MSG_FEEDBACK_CLICK_ONE){

        mSoundArray[0] = getSoundClass(BAD_MOVE_BOING);
		
        mSoundArray[1] = getSoundClass(getRandomSoundName(mMessageType), mLanguage);

        if(mLanguage == LANG_ENG)
          vGoalsList = (getGCQualitiesList("", "-")).split("-");
        else
          vGoalsList = (getGCQualitiesList("", "")).split("-");

        for(i = 2; i < 2 + vGoalsList.length; i++){
          mSoundArray[i] = getSoundClass(vGoalsList[i - 2], mLanguage);
        }
      }
      else {
        mSoundArray[0] = getSoundClass(getRandomSoundName(mMessageType), mLanguage);
      }
    }

    static public function getSoundClass(pSoundName: String, pLanguage: String = null): Sound {

      var vLangSuffix: String;

      if(pLanguage == null)
        vLangSuffix = "";
      else
        vLangSuffix = "_" + pLanguage;

      var ClassReference: Class = getDefinitionByName(Character.PACKAGE_NAME + pSoundName + vLangSuffix) as Class;
      return new ClassReference();
    }

    public function getGCQualitiesList(pSeparator1: String, pSeparator2: String): String { // Can add a parameter for a separator symbol

      var vQualsList: String = "";
      for(var i: Number = CharacterQuality.NUM_QUALITIES - 1; i >= 0; i--){

        if(mQuestionType == UniformGameLevelSpec.LEVELTYPE_COUNTING){
          if(i == 0 || mDesc[i].length > 0)
            vQualsList += CharacterQuality.getQualityNames(i, mDesc[i],
                            CharacterQuality.PLURAL, pSeparator1) + pSeparator2;
        }
        else if(mQuestionType == UniformGameLevelSpec.LEVELTYPE_IDENTIFY_COLOR || 
                mQuestionType == UniformGameLevelSpec.LEVELTYPE_IDENTIFY_SIZE){
          if(i == 0 || mDesc[i].length > 0)
          {
            vQualsList += CharacterQuality.getQualityNames(i, mDesc[i],
                            CharacterQuality.SINGULAR, pSeparator1) + pSeparator2;
          }
        }
        else if(mQuestionType == UniformGameLevelSpec.LEVELTYPE_IDENTIFY_NUMBER && mDesc[i].length > 0)
          vQualsList += CharacterQuality.getQualityNames(i, mDesc[i],
                          CharacterQuality.SINGULAR, pSeparator1) + pSeparator2;
        else if(mMessageType == MSG_FEEDBACK_CLICK_ONE){
         	
          if(i == 0 || mDesc[i].length > 0)
            vQualsList += CharacterQuality.getQualityNames(i, mDesc[i],
                            CharacterQuality.SINGULAR, pSeparator1) + pSeparator2;
                                      
        }
        else if(mMessageType == MSG_FEEDBACK_CLICK && mDesc[i].length > 0 )
        {
          if(i == 3)
          	vQualsList += CharacterQuality.getQualityNames(i, mDesc[i],
                          CharacterQuality.SINGULAR, pSeparator1) + pSeparator2;
          trace(i + " " + vQualsList);                 
        }

                          
                            
      }

      if(vQualsList.charAt(vQualsList.length - 1) == pSeparator2.charAt(0))
        return vQualsList.substr(0, vQualsList.length - 1);

      return vQualsList;
    }

    private function getRandomSoundName(pSoundType: Number): String {
	  trace(NUM_SOUNDS[mLanguage][pSoundType]);
	  trace(MSG_SOUND[mLanguage][pSoundType]);
	  
      if(NUM_SOUNDS[mLanguage][pSoundType] > 0)
        return MSG_SOUND[mLanguage][pSoundType][Math.floor(Math.random() * NUM_SOUNDS[mLanguage][pSoundType])];
      else
        return "";
    }

    public function get SoundComplete (): Boolean {

      return mSoundComplete;
    }
  }

}