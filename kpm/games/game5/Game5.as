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
import com.kpm.games.GameIgniter;
import com.kpm.kpm.BubbleId;
import com.kpm.kpm.EBName;
import com.kpm.kpm.EBStd;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;


//com.kpm.games.game5.Game5
// com.kpm.games.game5.Game5Data
// --> skeleton of the code
public class Game5 extends Game {
    //Whole_id
    //Piece_id
    //Number_id

    public function Game5(pStandAlone : Boolean) : void{
        super(pStandAlone);
        EventManager.addEvent(this, GameData.GAME_BEGIN, initStandAlone);
    }

    public function initStandAlone(e : Event)
    {
        GameData.driver = false;
        initGame(null);
    }

    public function initGame (pBubbleId : BubbleId = null, pLanguage: ELanguage = null, pPlayerTheme : EGameCharacter = null){


        if(mBubbleId != null) {
            Util.debug("initgame bubble id null " + mBubbleId);
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


        if(pLanguage == null) pLanguage = ELanguage.ENG;

        //initialize GameData : which is the interface with the Driver
        mData = new Game5Data(mBubbleId, pLanguage, this, EGameCharacter.ALL);


        //onRemove(null);
        startGame();
    }

    private function startGame(event: Event = null) {
        //Esto se hace para dejar que flash renderise todos los elementos del stage y luego inicializar plataformas y demas
        //this.gotoAndStop("background" + mPlayerWord + changePlusString)

        stage.addEventListener( Event.RENDER, startGameHelper, false, 0, true );
        stage.invalidate();
    }

    //$populate platforms (branches, wires)
    //store col points in board (2d array)
    public function startGameHelper(e : Event){
        stage.removeEventListener( Event.RENDER, startGameHelper);

        Util.debug("Game5.StartGameHelper");
        initializeParameters()
        G5D.outputParameters();
        initializePath();
        startRound();
    }


    public override function createMusic() : KpmSound {
        Util.debug("Game5.createMusic");
        if(!mMute)
            return G5D.createSound("G5_backgroundMusic", 1, 0.7, true, false, true);
        else return null;
    }

    public function get Name()		: EGame		{ return EGame.G5;}
    public override function get Data()  		{ return (mData as Game5Data)};
    public function get G5D() : Game5Data	{ return (mData as Game5Data)}


    private function initializeParameters()
    {
        var numParameters : int = 9;

        GameData.params = new Array(numParameters);


        for(var i=0; i < numParameters; i ++)
        {
            GameData.params[i] = parameterPanel()["p" + i].text;
            Util.debug("GameData.parameters " + i + " " + GameData.params[i]);
        }
    }

    //
    public override function onRemove(e : Event)
    {
        Util.removeChildsOf(this);
        G5D.removeLists(e);
        removeCounters();

        //Util.removeChild(this);
    }





    private function initializePath()
    {
        Util.debug("Game5.setupPiecesAndWholes");

        Util.debug("PARAMETERS : ");
        Util.debug("first number" + GameData.params[G5D.mpPathInitialValue]);
        Util.debug("number of total nodes " + GameData.params[G5D.mpNumTotalNodesInPath]);
        Util.debug("G5Data.numAnswersToChoose" +  GameData.params[G5D.mpNumAnswersToChoose]);

        var firstNumber : int = GameData.params[G5D.mpPathInitialValue] ;
        var lastNumber : int = int(GameData.params[G5D.mpNumTotalNodesInPath]) + firstNumber;
        var i = firstNumber;

        while( i < lastNumber)
        {
            i += G5D.addNodesToPath(G5D.generateGroup(i, EG5PieceType.PIECE, Util.getRandBtw(GameData.params[G5D.mpMinRandomAdjacentPieces], GameData.params[G5D.mpMaxRandomNumAdjacentPieces])));
            i += G5D.addNodesToPath(G5D.generateGroup(i, EG5PieceType.WHOLE, Util.getRandBtw(GameData.params[G5D.mpMinRandomNumAdjacentWholes], GameData.params[G5D.mpMaxRandomNumAdjacentWholes])));

            Util.debug("generating groups with cardinality so far : " + i + " up to : " + lastNumber);
        }


        while(G5D.mNodes.length != GameData.params[G5D.mpNumTotalNodesInPath])
            G5D.mNodes.pop();

        if(G5D.mNodes.length != GameData.params[G5D.mpNumTotalNodesInPath])
            Util.assertFailed(["not same", "G5Data.mNodes length : ", G5D.mNodes.length,  "numTotalNodes : ", GameData.params[G5D.mpNumTotalNodesInPath]]);


        for (var i = 0; i< GameData.params[G5D.mpNumTotalNodesInPath]; i++)
        {
            addChild(addToGameObjects(G5D.mNodes[i], i));
        }
    }

    public function addToGameObjects(pNode : Object, index : int) : MovieClip
    {
        var counter : Counter;

        if(pNode.whole)
        {
            Util.printArray(["numeral ", pNode.numeral], "G5.addToGameObjects.addWhole");

            G5D.mGameObjects.push(GameComponent.createGCFromMc("BoxWhole", ["numeral", G5D.mNodes[index].numeral]));
            G5D.colorPiece(G5D.mGameObjects[index], EColor.Blue);

            G5D.mWholes.push(G5D.mNodes[index].numeral);

        }
        else
        {
            Util.printArray(["numeral ", pNode.numeral], "G5.addToGameObjects.addPiece");

            G5D.newCounter(index , G5D.mNodes[index].numeral , stage, G5D.mGameObjects);
            G5D.mGameObjects[index].addMovieBelow("BoxWhole");
            G5D.colorPiece(G5D.mGameObjects[index], EColor.Blue);


            //counter = new Counter(Counter.getNumberForm(mBubbleId), G5D.mNodes[index].numeral, stage);
            //G5D.mGameObjects[index].addMovieClip(counter, false, -100);
        }

        G5D.mGameObjects[index].x = this["tPath"]["loc"+(index+1)].x + this["tPath"].x;
        G5D.mGameObjects[index].y = this["tPath"]["loc"+(index+1)].y + this["tPath"].y;


        Util.debug("params[G5D.mpOrder]" + GameData.params[G5D.mpOrder]);

        if(GameData.params[G5D.mpOrder] == 1)
            {trace("case1"); G5D.mWholes.reverse();}

        else if(GameData.params[G5D.mpOrder] == 0)
            {trace("case0"); Util.shuffleArray(G5D.mWholes);}


        //if(G5Data.mGameObjects.length != index+1)
        //    Util.assertFailed(["Game5.addGameObjects", "not same", "G5Data.mGameObjects.length-1",(G5Data.mGameObjects.length-1), "G5Data.mNodes.length",G5Data.mNodes.length, "index", index]);

        return G5D.mGameObjects[index];
    }


    //////////////END POPULATE PIECES AND WHOLES


    //$Start AudioVisualTask
    private function startRound(event: Event = null) {
        Util.debug("Game5.startRound");
        // Instructions Sound
        G5D.soundLibrary.playLibSound(ESoundType.Instruction, "1", G5D.Language, null,null, G5D.Bubble.Name.Standard);

        //tInteractionPanel.visible = true;
        populateCounters();
        addCounterEvents(true);



    }

    private function populateCounters()
    {

        Util.printArray([GameData.params[G5D.mpNumAnswersToChoose], G5D.mWholes.length ], "Game5.setupCounters");


        G5D.mAnswerBoxCounters = new Array(GameData.params[G5D.mpNumAnswersToChoose]);

        for (var i=0; i < GameData.params[G5D.mpNumAnswersToChoose] && i < G5D.mWholes.length ; i++){
            //Create counter

            G5D.newCounter(i, G5D.mWholes.pop(), stage, G5D.mAnswerBoxCounters);
            G5D.colorPiece(G5D.mAnswerBoxCounters[i], EColor.Blue);

            Util.debug("create counter " + i + G5D.mAnswerBoxCounters[i]);

            addChild(G5D.mAnswerBoxCounters[i]);
        }
    }



    //*Add or remove events for counter
    private function addCounterEvents (pAdd : Boolean) {
        Util.debug("add counter events " + pAdd)
        for(var i: Number = 0; i < G5D.mAnswerBoxCounters.length; i++){
            if(G5D.mAnswerBoxCounters[i] != null){
                if (pAdd) {
                    EventManager.addEvent(G5D.mAnswerBoxCounters[i], MouseEvent.MOUSE_UP, onGCDrag, i);

                    G5D.mAnswerBoxCounters[i].buttonMode = true;
                    G5D.mAnswerBoxCounters[i].index = i;
                    if(GameData.driver) CursorManager.addOverEvents(G5D.mAnswerBoxCounters[i]);
                }
                else {
                    Util.debug("removing events");
                    EventManager.removeEvent(G5D.mAnswerBoxCounters[i], MouseEvent.MOUSE_UP);
                    EventManager.removeEvent(G5D.mAnswerBoxCounters[i], MouseEvent.MOUSE_DOWN);
                    G5D.mAnswerBoxCounters[i].buttonMode = false;
                    if(GameData.driver) CursorManager.removeOverEvents(G5D.mAnswerBoxCounters[i]);
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
        for(var i: Number = 0; i < G5D.mAnswerBoxCounters.length; i++){
            if(G5D.mAnswerBoxCounters[i] != null)
            {
                //Util.debug("adding box" + i );
                var emptyBox : MovieClip = Util.addButtonBox(G5D.mAnswerBoxCounters[i], new EmptyBox())
                var sizeY = G5D.mAnswerBoxCounters[i].height;

                G5D.mAnswerBoxCounters[i].addChild(emptyBox);
                G5D.mAnswerBoxCounters[i].setChildIndex(emptyBox, 0);

            }
        }
    }



    private function onGCDrag(e: Event, pIndex : int)
    {
        Util.debug("G5.onGCDrag");
        EventManager.removeEvent(G5D.mAnswerBoxCounters[pIndex],  MouseEvent.MOUSE_UP);
        G5D.mAnswerBoxCounters[pIndex].drag();

        //IMPORTANT
        Data.startTask(GameData.params[G5D.mpNumAnswersToChoose], 1);

        G5D.CurrentGoal = G5D.mAnswerBoxCounters[pIndex].numeral;

        EventManager.addEvent(G5D.mAnswerBoxCounters[pIndex],  MouseEvent.MOUSE_DOWN, onGCDrop, G5D.mAnswerBoxCounters[pIndex]);
    }

    private function onGCDrop(e : Event, pAnswerCounter : GameComponent)
    {
        if(!pAnswerCounter.Dragging) return;

        var intersectionIndex : int = -1;
        EventManager.removeEvent(pAnswerCounter,  MouseEvent.MOUSE_UP);

        Util.debug("G5onGCDrop.pNode.pDragging" + pAnswerCounter.Dragging);

        if(pAnswerCounter.Dragging)
        {
            //addChild(Util.createAndPositionMc("dot", pAnswer_Counter.x,  pAnswer_Counter.y));

            var i; for(i=0; i < G5D.mNodes.length ; i++){

                Util.printArray(["i : ", i,  "G5Data.mNodes[i].Numeral: ", G5D.mNodes[i].numeral, "intersect ", G5D.mGameObjects[i].hitTestPoint(mouseX, mouseY, true), "G5Data.mNodes[i].whole : ", G5D.mNodes[i].whole], "G5.OnGCDrop.intersect???")

                if(G5D.mGameObjects[i] && G5D.mNodes[i].whole &&
                   G5D.mGameObjects[i].hitTestPoint(pAnswerCounter.x, pAnswerCounter.y, true)){

                    intersectionIndex = i; break;

                    Util.printArray(["G5Data.mNodes[i].Numeral", G5D.mNodes[i].numeral, "intersect ", G5D.mGameObjects[i].hitTestPoint(pAnswerCounter.x, pAnswerCounter.y, true)], "G5OnGCDrop.intersect!!!")


                }

                //DEBUG : Util.printArray(["G5onGCDrop.intersectionIndex",i]);Util.printArray(["G5Data.mNodes[i].numeral", G5Data.mNodes[i].numeral]);Util.printArray(["pNode.numeral",pNode.numeral]);
            }



            if(intersectionIndex != -1)
            {
                if(G5D.mNodes[intersectionIndex].numeral == pAnswerCounter.numeral)
                {
                    collideSuccess(intersectionIndex, pAnswerCounter);

                    checkStartRound();
                }
                else
                {
                    collideFailure(intersectionIndex, pAnswerCounter);

                    tryAgainSound();
                }
            }
        }
    }



    function collideSuccess(intersectionIndex : int,  pAnswerCounter : GameComponent)
    {
        Util.printArray(["intersect cardinality matches index ", intersectionIndex],"Game5.onGCDrop");

        //Util.removeChild(G5D.mGameObjects[intersectionIndex]);

        G5D.mNodes[intersectionIndex].whole = false;

        G5D.colorPiece(pAnswerCounter, EColor.Blue);

        pAnswerCounter.drop();
        pAnswerCounter.x = G5D.mGameObjects[intersectionIndex].x;
        pAnswerCounter.y = G5D.mGameObjects[intersectionIndex].y;

        pAnswerCounter.done = true;

        G5D.CurrentTaskSuccess = GameData.TASK_SUCCESS;
        G5D.soundLibrary.playLibSound(ESoundType.Feedback, EState.GOOD_MOVE, G5D.Language);
    }



    function collideFailure(intersectionIndex : int, pAnswerCounter : GameComponent)
    {

        pAnswerCounter.drop();

        pAnswerCounter.returnToHoldPosition();

        clickedTarget = new MovieClip();
        clickedTarget.feedbackObject = G5D.mNodes[intersectionIndex].numeral ;

        Util.debug("onGCDrop.intersect cardinality doesnt match" + clickedTarget.feedbackObject + " " + ENumber.getEnum(clickedTarget.feedbackObject).Text + " " + clickedTarget.feedbackSound);

        EventManager.addEvent(pAnswerCounter, MouseEvent.MOUSE_UP, onGCDrag, pAnswerCounter.index)

        G5D.CurrentTaskSuccess = GameData.TASK_FAILURE;
    }


    function checkStartRound()
    {
        var readyToStartRound : Boolean = true;

        if(Data.isBubbleFinished())
        {
            (parent as GameIgniter).finishGame();
        }

        for each (var counter : GameComponent in G5D.mAnswerBoxCounters)
            if(!counter.done) readyToStartRound = false;

        if(readyToStartRound)
            startRound();

    }

    function tryAgainSound()
    {
        Util.debug("Game5.tryAgainSound" + clickedTarget.feedbackSound);

        G5D.firstTry = false;

        G5D.soundLibrary.forceStop();


        if(	G5D.gameGoal.quality == EGoal.PLACE_NUMBER)
        {
            G5D.soundLibrary.playLibSound(ESoundType.Feedback, EState.BAD_MOVE);

            G5D.soundLibrary.playLibSound(ESoundType.Feedback, "Silence1");

            G5D.soundLibrary.playLibSound(ESoundType.FeedbackClick, clickedTarget.feedbackObject, G5D.Language, null, null, null, GameData.FEEDBACK_FINISHED);

            G5D.feedbackSound = clickedTarget.feedbackObject+"";
        }
    }


    //$Hide counters that are not the solution
    private function removeCounters(pGoalId = -1){
        Util.debug("removeCounters " + pGoalId);
        if(!G5D.mAnswerBoxCounters)
            return;

        for(var i: Number = 0; i < G5D.mAnswerBoxCounters.length; i++){

            //Se deshabilita el counter que vino como parametro
            EventManager.removeEvent(G5D.mAnswerBoxCounters[i], MouseEvent.CLICK);
            G5D.mAnswerBoxCounters[i].buttonMode = false;
            if(GameData.driver) CursorManager.removeOverEvents(G5D.mAnswerBoxCounters[i]);

            if (i != pGoalId)
            {
                Util.removeChild(G5D.mAnswerBoxCounters[i]);
            }



        }
    }

    public function returnToDriver(e : Event){
        G5D.dispatchEvent(new Event(GameData.RETURN_TO_DRIVER));
    }


    //*Check if total tasks have been done
    public function onTaskFinished(e : Event){

        Util.debug(["G5Data.gameGoal.taskCounter", G5D.gameGoal.taskCounter, "G5Data.gameGoal.totalTasks", G5D.gameGoal.totalTasks], "OnTaskFinished");
        if(G5D.gameGoal.taskCounter >= G5D.gameGoal.totalTasks)
            this.gotoAndPlay(1);
        else startRound();
    }

}


}