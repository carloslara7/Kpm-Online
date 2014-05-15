/**
 * Created with IntelliJ IDEA.
 * User: carloslara
 * Date: 5/6/14
 * Time: 3:43 PM
 * To change this template use File | Settings | File Templates.
 */
package com.kpm.games.game5 {
import com.kpm.common.Counter;
import com.kpm.common.CursorManager;
import com.kpm.common.EColor;
import com.kpm.common.EGame;
import com.kpm.common.ELanguage;
import com.kpm.common.ENumberForm;
import com.kpm.common.ESoundType;
import com.kpm.common.EventManager;
import com.kpm.common.Game;
import com.kpm.common.GameComponent;
import com.kpm.common.GameData;
import com.kpm.common.KpmSound;
import com.kpm.common.Util;
import com.kpm.games.EGameCharacter;
import com.kpm.games.EState;
import com.kpm.kpm.BubbleId;
import com.kpm.kpm.EBName;
import com.kpm.kpm.EBStd;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.media.SoundChannel;

public class Game5 extends Game {

    //*current bubble being played
    private var mBubbleId : BubbleId;
    //*default language
    private const DEFAULT_LANGUAGE: String = "SPA";


    //*whether music is muted or not
    private var mMute: Boolean = false;

    private var mGameObjects : Array = new Array();
    private var mWholes : Array = new Array();
    private var platforms : Array = new Array();
    private var mAnswerBoxCounters : Array = new Array();
    private var mNodes : Array = new Array();


    //Whole_id
    //Piece_id
    //Number_id

    public function Game5(isStandAlone : Boolean) : void
    {
        if(isStandAlone)
            EventManager.addEvent(this, Event.ADDED_TO_STAGE, onInit);
    }

    public function onInit(e : Event)
    {
        initGame();
        EventManager.removeEvent(this, Event.ADDED_TO_STAGE);
    }




    public function initGame (pBubbleId : BubbleId = null, pLanguage: ELanguage = null, pPlayerTheme : EGameCharacter = null){

        if(mBubbleId != null) {
            Util.debug("initgame bubble id not null " + mBubbleId);
            return;
        }

        //Define player kind (monkey or bird)
        /*if(pPlayerTheme == null)
        {
            mPlayerKind = CharQual.MONKEY;
            mPlayerChar = EGameCharacter.Monkey;
        }
        else if (pPlayerTheme == EGameCharacter.Monkey)
            mPlayerKind = CharQual.MONKEY;
        else if (pPlayerTheme == EGameCharacter.Bird)
            mPlayerKind = CharQual.BIRD;

        mPlayerKind = CharQual.BIRD; //SOLO PARA TESTING
        mPlayerWord = CharQual.SPECIES_NAMES[mPlayerKind];
         */

        Util.debug("Game4.initGame" + pBubbleId + " " + mBubbleId);

        //Initialize bubble id
        if(pBubbleId == null)
            mBubbleId = new BubbleId(EBName.PlaceNumeral_20_1,3);
        else mBubbleId = pBubbleId;

        Util.debug("Game4.initGame" + mBubbleId);
        //initialize GameData : which is the interface with the Driver
        if(pLanguage == null)
            pLanguage = ELanguage.SPA;

        mData = new Game5Data(mBubbleId, pLanguage, this, EGameCharacter.ALL);

        startGame();
    }

    private function startGame(event: Event = null) {
        //Esto se hace para dejar que flash renderise todos los elementos del stage y luego inicializar plataformas y demas
        //this.gotoAndStop("background" + mPlayerWord + changePlusString)

        stage.addEventListener( Event.RENDER, populatePlatforms, false, 0, true );
        stage.invalidate();

        Util.debug("start game");
        Util.debug(stage) ;
        Util.debug(parent.stage);
    }

    //$populate platforms (branches, wires)
    //store col points in board (2d array)
    public function populatePlatforms(e : Event){
        Util.debug("Game5.PopulatePlatforms");
        stage.removeEventListener( Event.RENDER, populatePlatforms);
        tInteractionPanel.visible = true;
        setupPiecesAndWholes()

        startRound();
    }


    public override function createMusic() : KpmSound {
        Util.debug("Game5.createMusic");
        if(!mMute)
            return G5Data.createSound("backgroundMusicbird", 1, 0.7, true, false, true);
        else return null;
    }

    public function get Name()		: EGame		{ return EGame.G5;}
    public override function get Data()  		{ return (mData as Game5Data)};
    public function get G5Data() : Game5Data	{ return (mData as Game5Data)}



    //$Start round/task
    private function startRound(event: Event = null) {
        Util.debug("Game4.startRound");
        //
        // G5Data.soundLibrary.playLibSound(ESoundType.Instruction, "1", G5Data.Language, EGame.G5,null, G5Data.Bubble.Name.Standard.Text);


        G5Data.updateTaskVars();
        setCounters();
    }

    private function setupPiecesAndWholes()
    {
        Util.debug("Game5.setupPiecesAndWholes");
        Util.debug("number of pieces " + G5Data.numPieces);
        Util.debug("number of total nodes " + G5Data.numTotalNodes);
        Util.debug("piece percentage" + G5Data.piecePercentage[mBubbleId.Level]);
        Util.debug("first number" + G5Data.firstNumber);

        G5Data.numPieces = G5Data.numTotalNodes*G5Data.piecePercentage[mBubbleId.Level];

        Util.debug("Game5.setupPiecesAndWholes " + G5Data.numPieces);
        //Randomize positions for wholes and pieces
        var j : int = 0;
        /*
        var numPiecesPlacedSoFar : uint;

        for (var i=0; i < mNodes.length ; i++)
        while(true)

            if(i%2)
                numPiecesOrWholesNow = Util.getRandBtw(minAdjacentPieces, maxAdjacentPieces);
            else
                numPiecesOrWholesNow = Util.getRandBtw(minAdjacentWholes, maxAdjacentWholes)

            numPiecesOrWholesSoFar += numPiecesOrWholes;


            if(G5Data.numTotalNodes > numPiecesPlacedSoFar)
                if(i%2)
                    mAdjacentsPieces[i] = numPiecesOrWholesNow;
                else
                    mAdjacentsWholes[i] = numPiecesOrWholesNow;
            else
                numPiecesOrWholesSoFar -= numPiecesOrWholesNow;
                piecesOrWholesNow = Util.getRandBtw(1, G5Data.numTotalNodes - numPiecesOrWholesSoFar);
                numPiecesPlacedSoFar += mAdjacentWholes[i];
            i++;


        else


        */


        //private function placeNodeInPath(pWhole : Boolean, i : int, j : int);
            //create movie clip
            //add it to path





        for (var i = G5Data.firstNumber; i< G5Data.numTotalNodes + G5Data.firstNumber; i++)
        {
            mNodes.push(new Object());
            mNodes[j].whole = (i < (G5Data.numPieces + G5Data.firstNumber));
            mNodes[j].filled = false;
            mNodes[j].index = j;

            //Util.debug("whole is true for " + i + " " + G5Data.numPieces + locationIndeces[j].whole);
            j++;


        }

        mNodes = Util.shuffleArray(mNodes);


        for (var i = 0; i< G5Data.numTotalNodes; i++)
        {

            mNodes[i].numeral = G5Data.firstNumber + i;


            if(mNodes[i].whole)
            {
                Util.printArray(["numeral ", mNodes[i].numeral], "G5.setupPiecesAndWholes.addWhole");
                mGameObjects.push(Util.createMc("BoxWhole"));
                mWholes.push(mNodes[i].numeral);

            }
            else
            {
                Util.printArray(["numeral ", mNodes[i].numeral], "G5.setupPiecesAndWholes.addPiece");
                mNodes[i].whole = false;

                var counter : Counter = new Counter(Counter.getNumberForm(mBubbleId), i+1, stage);

                mGameObjects.push(new GameComponent());
                mGameObjects[i].MovieName = "BoxCoverGray";
                mGameObjects[i].addMovieClip(counter, false, -40);
                mGameObjects[i].ColorAll = EColor.Green;

            }


            mGameObjects[i].x = this["tPath"]["loc"+(i+1)].x + this["tPath"].x;
            mGameObjects[i].y = this["tPath"]["loc"+(i+1)].y + this["tPath"].y;

            addChild(mGameObjects[i]);

        }

        for(var i =0 ; i < mNodes.length ; i++)
            Util.printArray([i , mNodes[i].numeral],"mNodes[i].numeral");

        Util.debug("there are " + mWholes.length + " wholes");
        Util.printArray(mWholes);
        Util.debug("We shuffle mWholes only if the level is > 3")

        if(mBubbleId.Level == 1)
            mWholes = mWholes.reverse();

        if(mBubbleId.Level >= 3)
            mWholes = Util.shuffleArray(mWholes);

        if(mNodes.length != G5Data.numTotalNodes)
            Util.assertFailed(["not same", "mNodes length :: numTotalNodes", "|", mNodes.length, " :: ", G5Data.numTotalNodes]);

    }


    //$Set counters
    //give answer + 4 distractors (distractors should be within 3 of range)
    //example : if answer is 21, possible distractors are 18 - 24
    private function setCounters(){


        //Assert("I dont need to remove counters because when task is succeded no counters are found inside the InteractionPanel = mAnswerBox
        //removeCounters();
        //var numArray  : Array = Util.generateConsecutiveNumbersAround(G4Data.gameGoal.currentGoal as Number, G4Data.maxNumGoals);
        populateCounters();
        addCounterEvents(true);

    }

    private function populateCounters()
    {

        Util.debug("Game5.setupCounters");
        mAnswerBoxCounters = new Array(G5Data.numAnswersToChoose[mBubbleId.Level]);

        Util.debug("G5Data.numAnswersToChoose[mBubbleId.Level]" + G5Data.numAnswersToChoose[mBubbleId.Level]);

        Util.printArray(mAnswerBoxCounters);

        for (var i=0; i < mAnswerBoxCounters.length; i++){
            //Create counter
            //Util.debug("create counter " + i + " " + numArray);

            var counter : Counter = new Counter(Counter.getNumberForm(mBubbleId), getRandomWholeNumeral(), stage);

            mAnswerBoxCounters[i] = new GameComponent();
            mAnswerBoxCounters[i].MovieName = "BoxCoverGray";
            mAnswerBoxCounters[i].addMovieClip(counter, false, -40);
            //mAnswerBoxCounters[i].Movie.visible = false;

            mAnswerBoxCounters[i].x = Game5Data.ANSWER_BOX_POSITION[Util.INDEX_X] + (i* 100);
            mAnswerBoxCounters[i].y = Game5Data.ANSWER_BOX_POSITION[Util.INDEX_Y];
            addChild(mAnswerBoxCounters[i]);



        }
    }

    public function getRandomWholeNumeral()
    {
        var nextWholeNumeral : int =  mWholes.pop();


        Util.debug("G5.getRandomeWHoleNumeral" + nextWholeNumeral)
        Util.printArray(mWholes);


        return nextWholeNumeral;


//        var wholeIndex : int = 0 ;
//
//        for (var i=0; i< mNodes.length; i++)
//        {
//            Util.debug("compare2");
//            Util.printObject(mNodes[i]);
//            Util.debug(" ");
//        }
//
//        do
//        {
//            wholeIndex = Util.getRandBtw(0, mNodes.length-1);
//        }
//        while(!mNodes[wholeIndex].whole);
//
//        //Util.printArray(["wholeIndex :",wholeIndex,"] [filled : ", mPieces[wholeIndex].filled, "] [index : ", mPieces[wholeIndex].index, "]"], "Game5.mPieces");
//
//
//
//        return mNodes[wholeIndex].numeral;
    }



    //*Add or remove events for counter
    private function addCounterEvents (pAdd : Boolean) {
        Util.debug("add counter events " + pAdd)
        for(var i: Number = 0; i < mAnswerBoxCounters.length; i++){
            if(mAnswerBoxCounters[i] != null){
                if (pAdd) {
                    EventManager.addEvent(mAnswerBoxCounters[i], MouseEvent.MOUSE_UP, onGCDrag, i);

                    mAnswerBoxCounters[i].buttonMode = true;
                    mAnswerBoxCounters[i].index = i;
                    if(GameData.driver) CursorManager.addOverEvents(mAnswerBoxCounters[i]);
                }
                else {
                    Util.debug("removing events");
                    EventManager.removeEvent(mAnswerBoxCounters[i], MouseEvent.MOUSE_UP);
                    EventManager.removeEvent(mAnswerBoxCounters[i], MouseEvent.MOUSE_DOWN);
                    mAnswerBoxCounters[i].buttonMode = false;
                    if(GameData.driver) CursorManager.removeOverEvents(mAnswerBoxCounters[i]);
                }
            }
        }

        if(pAdd)
            addEmptyBox();
    }



    private function addEmptyBox () {
        //no need for 'button halo' around frame since the shape is very regular
        //if(mBubbleId.Name.Text.indexOf("5Frame") != -1 && mBubbleId.Level > 3)
        //  return;

        Util.debug("Game5.addEmptyBox to increase drag zone");
        for(var i: Number = 0; i < mAnswerBoxCounters.length; i++){
            if(mAnswerBoxCounters[i] != null)
            {
                //Util.debug("adding box" + i );
                var emptyBox : MovieClip = Util.addButtonBox(mAnswerBoxCounters[i], new EmptyBox())
                var sizeY = mAnswerBoxCounters[i].height;

                mAnswerBoxCounters[i].addChild(emptyBox);
                mAnswerBoxCounters[i].setChildIndex(emptyBox, 0);




            }
        }
    }

    private function onGCDrag(e: Event, pIndex : int)
    {
        Util.debug("G5.onGCDrag");
        EventManager.removeEvent(mAnswerBoxCounters[pIndex],  MouseEvent.MOUSE_UP);
        mAnswerBoxCounters[pIndex].drag();

        EventManager.addEvent(mAnswerBoxCounters[pIndex],  MouseEvent.MOUSE_DOWN, onGCDrop, mAnswerBoxCounters[pIndex]);


    }

    private function onGCDrop(e : Event, pAnswer_Counter : GameComponent)
    {
        if(!pAnswer_Counter.Dragging) return;

        var intersectionIndex : int = -1;
        EventManager.removeEvent(pAnswer_Counter,  MouseEvent.MOUSE_UP);

        Util.debug("G5onGCDrop.pNode.pDragging" + pAnswer_Counter.Dragging);

        if(pAnswer_Counter.Dragging)
        {
            //addChild(Util.createAndPositionMc("dot", pAnswer_Counter.x,  pAnswer_Counter.y));

            var i;
            for(i=0; i < mNodes.length ; i++){

                Util.printArray(["i : ", i,  "mNodes[i].Numeral: ", mNodes[i].numeral, "intersect ", mGameObjects[i].hitTestPoint(mouseX, mouseY, true), "mNodes[i].whole : ", mNodes[i].whole], "G5.OnGCDrop.intersect???")


                if(mGameObjects[i]
                && mNodes[i].whole
                && mGameObjects[i].hitTestPoint(pAnswer_Counter.x, pAnswer_Counter.y, true))
                {
                    Util.printArray(["mNodes[i].Numeral", mNodes[i].numeral, "intersect ", mGameObjects[i].hitTestPoint(pAnswer_Counter.x, pAnswer_Counter.y, true)], "G5OnGCDrop.intersect!!!")
                    intersectionIndex = i;
                    break;
                }
                //DEBUG : Util.printArray(["G5onGCDrop.intersectionIndex",i]);Util.printArray(["mNodes[i].numeral", mNodes[i].numeral]);Util.printArray(["pNode.number",pNode.number]);
            }



            if(intersectionIndex != -1)
            if(mNodes[intersectionIndex].numeral == pAnswer_Counter.secondMovie.number)
            {
                Util.printArray(["intersect cardinality matches index ", intersectionIndex],"Game5.onGCDrop");
                Util.removeChild(mGameObjects[intersectionIndex]);
                mNodes[intersectionIndex].whole = false;
                pAnswer_Counter.drop();
                pAnswer_Counter.ColorAll = EColor.Blue;
                pAnswer_Counter.done = true;

                G5Data.CurrentTaskSuccess = GameData.TASK_SUCCESS;
                G5Data.soundLibrary.playLibSound(ESoundType.Feedback, EState.GOOD_MOVE, G5Data.Language);


                var readyToStartRound : Boolean = true;

                 for each (var counter : GameComponent in mAnswerBoxCounters)
                    if(!counter.done) readyToStartRound = false;

                if(readyToStartRound)
                    startRound();

            }
            else
            {
                Util.debug("onGCDrop.intersect cardinality doesnt match")
                pAnswer_Counter.drop();
                pAnswer_Counter.returnToHoldPosition();
                EventManager.addEvent(pAnswer_Counter, MouseEvent.MOUSE_DOWN, onGCDrag, pAnswer_Counter.secondMovie.index)

            }

        }
    }


    //$Hide counters that are not the solution
    private function removeCounters(pGoalId = -1){
        Util.debug("removeCounters " + pGoalId);
        if(!mAnswerBoxCounters)
            return;

        for(var i: Number = 0; i < mAnswerBoxCounters.length; i++){

            //Se deshabilita el counter que vino como parametro
            EventManager.removeEvent(mAnswerBoxCounters[i], MouseEvent.CLICK);
            mAnswerBoxCounters[i].buttonMode = false;
            if(GameData.driver) CursorManager.removeOverEvents(mAnswerBoxCounters[i]);

            if (i != pGoalId)
            {
                Util.removeChild(mAnswerBoxCounters[i]);
            }



        }
    }



}

}
