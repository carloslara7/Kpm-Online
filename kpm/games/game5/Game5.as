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
import com.kpm.common.EGoal;
import com.kpm.common.ELanguage;
import com.kpm.common.ENumber;
import com.kpm.common.ESoundType;
import com.kpm.common.EventManager;
import com.kpm.common.Game;
import com.kpm.common.GameComponent;
import com.kpm.common.GameData;
import com.kpm.common.KpmSound;
import com.kpm.common.Util;
import com.kpm.games.EGameCharacter;
import com.kpm.games.EState;
import com.kpm.games.game5.G5ns;
import com.kpm.kpm.BubbleId;
import com.kpm.kpm.EBName;
import com.kpm.kpm.EBStd;

import flash.display.MovieClip;
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
    private var mMute: Boolean = true;

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

        Util.debug("Game5.initGame" + pBubbleId + " " + mBubbleId);

        if(pBubbleId == null)
            mBubbleId = new BubbleId(EBName.PlaceNumeral_20_1,3);
        else mBubbleId = pBubbleId;


        if(pLanguage == null) pLanguage = ELanguage.SPA;

        //initialize GameData : which is the interface with the Driver
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
        Util.debug("Game5.startRound");
        // Instructions
        // G5Data.soundLibrary.playLibSound(ESoundType.Instruction, "1", G5Data.Language, EGame.G5,null, G5Data.Bubble.Name.Standard.Text);
        setCounters();
    }

    private function setupPiecesAndWholes()
    {
        Util.debug("Game5.setupPiecesAndWholes");

        Util.debug("PARAMETERS : ");
        Util.debug("first number" + G5Data.mpPathInitialValue);
        Util.debug("number of total nodes " + G5Data.mpNumTotalNodesInPath);
        Util.debug("G5Data.numAnswersToChoose" + G5Data.mpNumAnswersToChoose);


        var numNodesAssigned : int;

        while(numNodesAssigned < G5Data.mpNumTotalNodesInPath)
        {
            numNodesAssigned += G5Data.addNodesToPath(G5Data.generateGroup(numNodesAssigned, EG5PieceType.PIECE, Util.getRandBtw(G5Data.mpMinRandomNumAdjacentPieces, G5Data.mpMaxRandomNumAdjacentPieces)));
            numNodesAssigned += G5Data.addNodesToPath(G5Data.generateGroup(numNodesAssigned, EG5PieceType.WHOLE, Util.getRandBtw(G5Data.mpMinRandomNumAdjacentWholes, G5Data.mpMaxRandomNumAdjacentWholes)));
        }


        while(G5Data.mNodes.length != G5Data.mpNumTotalNodesInPath)
            G5Data.mNodes.pop();

        if(G5Data.mNodes.length != G5Data.mpNumTotalNodesInPath)
            Util.assertFailed(["not same", "G5Data.mNodes length : ", G5Data.mNodes.length,  "numTotalNodes : ", G5Data.mpNumTotalNodesInPath]);


        for (var i = 0; i< G5Data.mpNumTotalNodesInPath; i++)
        {
            addChild(addToGameObjects(G5Data.mNodes[i], i));
        }



    }

    public function addToGameObjects(pNode : Object, index : int) : MovieClip
    {
        var counter : Counter;

        if(pNode.whole)
        {
            Util.printArray(["numeral ", pNode.numeral], "G5.addToGameObjects.addWhole");

            G5Data.mGameObjects.push(Util.createMc("BoxWhole"));

            G5Data.mWholes.push(G5Data.mNodes[index].numeral);

        }
        else
        {
            Util.printArray(["numeral ", pNode.numeral], "G5.addToGameObjects.addPiece");

            G5Data.mGameObjects.push(new GameComponent());

            G5Data.mGameObjects[index].MovieName = "BoxCoverGray";

            G5Data.colorPiece(G5Data.mGameObjects[index], EColor.Blue);

            counter = new Counter(Counter.getNumberForm(mBubbleId), G5Data.mNodes[index].numeral, stage);
            G5Data.mGameObjects[index].addMovieClip(counter, false, -40);

        }

        G5Data.mGameObjects[index].x = this["tPath"]["loc"+(index+1)].x + this["tPath"].x;
        G5Data.mGameObjects[index].y = this["tPath"]["loc"+(index+1)].y + this["tPath"].y;

        addChild(G5Data.mGameObjects[index]);

        if(G5Data.mGameObjects.length != index+1)
            Util.assertFailed(["Game5.addGameObjects", "not same", "G5Data.mGameObjects.length-1 :: index", "|", G5Data.mNodes.length, " :: ", index]);

        return G5Data.mGameObjects[index];
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
        G5Data.mAnswerBoxCounters = new Array(G5Data.mpNumAnswersToChoose);


        Util.printArray(G5Data.mAnswerBoxCounters);

        for (var i=0; i < G5Data.mAnswerBoxCounters.length && i < G5Data.mWholes.length ; i++){
            //Create counter
            //Util.debug("create counter " + i + " " + numArray);

            var counter : Counter = new Counter(Counter.getNumberForm(mBubbleId), getRandomWholeNumeral(), stage);

            G5Data.mAnswerBoxCounters[i] = new GameComponent();
            G5Data.mAnswerBoxCounters[i].MovieName = "BoxCoverGray";
            G5Data.mAnswerBoxCounters[i].addMovieClip(counter, false, -40);

            Util.debug("Creating counter "  + G5Data.mAnswerBoxCounters[i].secondMovie.numeral);
            G5Data.mAnswerBoxCounters[i].feedbackSound = ENumber.getEnum(G5Data.mAnswerBoxCounters[i].secondMovie.numeral).Text;
            //G5Data.mAnswerBoxCounters[i].Movie.visible = false;

            G5Data.mAnswerBoxCounters[i].x = Game5Data.ANSWER_BOX_POSITION[Util.INDEX_X] + (i* 100);
            G5Data.mAnswerBoxCounters[i].y = Game5Data.ANSWER_BOX_POSITION[Util.INDEX_Y];
            addChild(G5Data.mAnswerBoxCounters[i]);
        }
    }

    public function getRandomWholeNumeral()
    {
        var nextWholeNumeral : int =  G5Data.mWholes.pop();


        Util.debug("G5.getRandomeWHoleNumeral" + nextWholeNumeral)
        Util.printArray(G5Data.mWholes);


        return nextWholeNumeral;


//        var wholeIndex : int = 0 ;
//
//        for (var i=0; i< G5Data.mNodes.length; i++)
//        {
//            Util.debug("compare2");
//            Util.printObject(G5Data.mNodes[i]);
//            Util.debug(" ");
//        }
//
//        do
//        {
//            wholeIndex = Util.getRandBtw(0, G5Data.mNodes.length-1);
//        }
//        while(!G5Data.mNodes[wholeIndex].whole);
//
//        //Util.printArray(["wholeIndex :",wholeIndex,"] [filled : ", mPieces[wholeIndex].filled, "] [index : ", mPieces[wholeIndex].index, "]"], "Game5.mPieces");
//
//
//
//        return G5Data.mNodes[wholeIndex].numeral;
    }



    //*Add or remove events for counter
    private function addCounterEvents (pAdd : Boolean) {
        Util.debug("add counter events " + pAdd)
        for(var i: Number = 0; i < G5Data.mAnswerBoxCounters.length; i++){
            if(G5Data.mAnswerBoxCounters[i] != null){
                if (pAdd) {
                    EventManager.addEvent(G5Data.mAnswerBoxCounters[i], MouseEvent.MOUSE_UP, onGCDrag, i);

                    G5Data.mAnswerBoxCounters[i].buttonMode = true;
                    G5Data.mAnswerBoxCounters[i].index = i;
                    if(GameData.driver) CursorManager.addOverEvents(G5Data.mAnswerBoxCounters[i]);
                }
                else {
                    Util.debug("removing events");
                    EventManager.removeEvent(G5Data.mAnswerBoxCounters[i], MouseEvent.MOUSE_UP);
                    EventManager.removeEvent(G5Data.mAnswerBoxCounters[i], MouseEvent.MOUSE_DOWN);
                    G5Data.mAnswerBoxCounters[i].buttonMode = false;
                    if(GameData.driver) CursorManager.removeOverEvents(G5Data.mAnswerBoxCounters[i]);
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
        for(var i: Number = 0; i < G5Data.mAnswerBoxCounters.length; i++){
            if(G5Data.mAnswerBoxCounters[i] != null)
            {
                //Util.debug("adding box" + i );
                var emptyBox : MovieClip = Util.addButtonBox(G5Data.mAnswerBoxCounters[i], new EmptyBox())
                var sizeY = G5Data.mAnswerBoxCounters[i].height;

                G5Data.mAnswerBoxCounters[i].addChild(emptyBox);
                G5Data.mAnswerBoxCounters[i].setChildIndex(emptyBox, 0);

            }
        }
    }

    private function onGCDrag(e: Event, pIndex : int)
    {
        Util.debug("G5.onGCDrag");
        EventManager.removeEvent(G5Data.mAnswerBoxCounters[pIndex],  MouseEvent.MOUSE_UP);
        G5Data.mAnswerBoxCounters[pIndex].drag();

        EventManager.addEvent(G5Data.mAnswerBoxCounters[pIndex],  MouseEvent.MOUSE_DOWN, onGCDrop, G5Data.mAnswerBoxCounters[pIndex]);
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
            for(i=0; i < G5Data.mNodes.length ; i++){

                Util.printArray(["i : ", i,  "G5Data.mNodes[i].Numeral: ", G5Data.mNodes[i].numeral, "intersect ", G5Data.mGameObjects[i].hitTestPoint(mouseX, mouseY, true), "G5Data.mNodes[i].whole : ", G5Data.mNodes[i].whole], "G5.OnGCDrop.intersect???")


                if(G5Data.mGameObjects[i]
                && G5Data.mNodes[i].whole
                && G5Data.mGameObjects[i].hitTestPoint(pAnswer_Counter.x, pAnswer_Counter.y, true))
                {
                    Util.printArray(["G5Data.mNodes[i].Numeral", G5Data.mNodes[i].numeral, "intersect ", G5Data.mGameObjects[i].hitTestPoint(pAnswer_Counter.x, pAnswer_Counter.y, true)], "G5OnGCDrop.intersect!!!")
                    intersectionIndex = i;
                    break;
                }
                //DEBUG : Util.printArray(["G5onGCDrop.intersectionIndex",i]);Util.printArray(["G5Data.mNodes[i].numeral", G5Data.mNodes[i].numeral]);Util.printArray(["pNode.numeral",pNode.numeral]);
            }



            if(intersectionIndex != -1)
            {
                if(G5Data.mNodes[intersectionIndex].numeral == pAnswer_Counter.secondMovie.numeral)
                {
                    Util.printArray(["intersect cardinality matches index ", intersectionIndex],"Game5.onGCDrop");
                    Util.removeChild(G5Data.mGameObjects[intersectionIndex]);
                    G5Data.mNodes[intersectionIndex].whole = false;
                    pAnswer_Counter.drop();
                    pAnswer_Counter.x = G5Data.mGameObjects[intersectionIndex].x;
                    pAnswer_Counter.y = G5Data.mGameObjects[intersectionIndex].y;
                    G5Data.colorPiece(pAnswer_Counter, EColor.Blue);
                    pAnswer_Counter.done = true;

                    G5Data.CurrentTaskSuccess = GameData.TASK_SUCCESS;
                    G5Data.soundLibrary.playLibSound(ESoundType.Feedback, EState.GOOD_MOVE, G5Data.Language);


                    var readyToStartRound : Boolean = true;

                     for each (var counter : GameComponent in G5Data.mAnswerBoxCounters)
                        if(!counter.done) readyToStartRound = false;

                    if(readyToStartRound)
                        startRound();

                }
                else
                {
                    pAnswer_Counter.drop();

                    pAnswer_Counter.returnToHoldPosition();

                    clickedTarget = new MovieClip();
                    clickedTarget.feedbackObject = G5Data.mNodes[intersectionIndex].numeral ;

                    Util.debug("onGCDrop.intersect cardinality doesnt match" + clickedTarget.feedbackObject + " " + ENumber.getEnum(clickedTarget.feedbackObject).Text + " " + clickedTarget.feedbackSound);

                    EventManager.addEvent(pAnswer_Counter, MouseEvent.MOUSE_UP, onGCDrag, pAnswer_Counter.index)

                    G5Data.CurrentTaskSuccess = GameData.TASK_FAILURE;

                    tryAgainSound();


                }
            }
        }
    }

    function tryAgainSound()
    {
        Util.debug("Game5.tryAgainSound" + clickedTarget.feedbackSound);
        G5Data.firstTry = false;
        G5Data.soundLibrary.forceStop();


        if(	G5Data.gameGoal.quality == EGoal.PLACE_NUMBER)
        {
            G5Data.soundLibrary.playLibSound(ESoundType.Feedback, EState.BAD_MOVE);
            G5Data.soundLibrary.playLibSound(ESoundType.Feedback, "Silence1");
            G5Data.soundLibrary.playLibSound(ESoundType.FeedbackClick, clickedTarget.feedbackObject, G5Data.Language, null, null, null, GameData.FEEDBACK_FINISHED);
            G5Data.feedbackSound = clickedTarget.feedbackObject+"";
        }
    }


    //$Hide counters that are not the solution
    private function removeCounters(pGoalId = -1){
        Util.debug("removeCounters " + pGoalId);
        if(!G5Data.mAnswerBoxCounters)
            return;

        for(var i: Number = 0; i < G5Data.mAnswerBoxCounters.length; i++){

            //Se deshabilita el counter que vino como parametro
            EventManager.removeEvent(G5Data.mAnswerBoxCounters[i], MouseEvent.CLICK);
            G5Data.mAnswerBoxCounters[i].buttonMode = false;
            if(GameData.driver) CursorManager.removeOverEvents(G5Data.mAnswerBoxCounters[i]);

            if (i != pGoalId)
            {
                Util.removeChild(G5Data.mAnswerBoxCounters[i]);
            }



        }
    }
  }

}



/*
 var numPiecesPlacedSoFar : uint;

 for (var i=0; i < G5Data.mNodes.length ; i++)
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


 //private function placeNodeInPath(pWhole : Boolean, i : int, j : int);
 //create movie clip
 //add it to path



 /*


 //Randomize positions for wholes and pieces
 var j : int = 0;


 for (var i = G5Data.mpPathInitialValue; i< G5Data.mpNumTotalNodesInPath + G5Data.mpPathInitialValue; i++)
 {
 G5Data.mNodes.push(new Object());
 G5Data.mNodes[j].whole = (i < (G5Data.mpNumTotalNodesInPath + G5Data.mpPathInitialValue));
 G5Data.mNodes[j].filled = false;
 G5Data.mNodes[j].index = j;

 //Util.debug("whole is true for " + i + " " + G5Data.mpNumTotalNodesInPath + locationIndeces[j].whole);
 j++;


 }

 G5Data.mNodes = Util.shuffleArray(G5Data.mNodes);


 for (var i = 0; i< G5Data.mpNumTotalNodesInPath; i++)
 {

 G5Data.mNodes[i].numeral = G5Data.mpPathInitialValue + i;


 if(G5Data.mNodes[i].whole)
 {
 Util.printArray(["numeral ", G5Data.mNodes[i].numeral], "G5.setupPiecesAndWholes.addWhole");
 G5Data.mGameObjects.push(Util.createMc("BoxWhole"));
 G5Data.mWholes.push(G5Data.mNodes[i].numeral);

 }
 else
 {
 Util.printArray(["numeral ", G5Data.mNodes[i].numeral], "G5.setupPiecesAndWholes.addPiece");
 G5Data.mNodes[i].whole = false;

 var counter : Counter = new Counter(Counter.getNumberForm(mBubbleId), i+1, stage);

 G5Data.mGameObjects.push(new GameComponent());
 G5Data.mGameObjects[i].MovieName = "BoxCoverGray";
 G5Data.mGameObjects[i].addMovieClip(counter, false, -40);
 G5Data.mGameObjects[i].ColorAll = EColor.Green;

 }


 G5Data.mGameObjects[i].x = this["tPath"]["loc"+(i+1)].x + this["tPath"].x;
 G5Data.mGameObjects[i].y = this["tPath"]["loc"+(i+1)].y + this["tPath"].y;

 addChild(G5Data.mGameObjects[i]);

 }

 for(var i =0 ; i < G5Data.mNodes.length ; i++)
 Util.printArray([i , G5Data.mNodes[i].numeral],"G5Data.mNodes[i].numeral");

 Util.debug("there are " + G5Data.mWholes.length + " wholes");
 Util.printArray(G5Data.mWholes);
 Util.debug("We shuffle G5Data.mWholes only if the level is > 3")

 if(mBubbleId.Level == 1)
 G5Data.mWholes = G5Data.mWholes.reverse();

 if(mBubbleId.Level >= 3)
 G5Data.mWholes = Util.shuffleArray(G5Data.mWholes);


 */