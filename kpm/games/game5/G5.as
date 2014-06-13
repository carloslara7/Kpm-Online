/**
 * G5       ->  implementa el juego 5
 * Game     ->  base class de G5, funciones de todos los juegos
 *
 * G5Lib    ->  libreria de parametros, variables y rutinas
 *              para el G5
 *
 * GameLib  ->   libreria de parametros, variables y rutinas
 *              para todos los juegos de KidsPlayMath
 *
 * User: carloslara
 * Date: 5/6/14
 */
package com.kpm.games.game5 {


import com.kpm.common.Counter;
import com.kpm.common.EColor;
import com.kpm.common.EGame;
import com.kpm.common.EGoal;
import com.kpm.common.ELanguage;
import com.kpm.common.ENumber;
import com.kpm.common.ESoundType;

import com.kpm.common.EventManager;
import com.kpm.common.Game;
import com.kpm.common.GameComponent;
import com.kpm.common.GameLib;

import com.kpm.common.KpmSound;
import com.kpm.common.Util;
import com.kpm.games.EGameCharacter;
import com.kpm.games.EState;
import com.kpm.common.CursorManager;

import com.kpm.kpm.BubbleId;
import com.kpm.kpm.EBName;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.MouseEvent;


//com.kpm.games.game5.Game5
// com.kpm.games.game5.Game5Data
// --> skeleton of the code
public class G5 extends Game {


    // INICIALIZACION //
    public function G5(pStandAlone : Boolean) : void{
        super(pStandAlone);
        EventManager.addEvent(this, GameLib.BUBBLE_BEGIN, initStandAlone);
    }

    public function initStandAlone(e : Event)
    {
        GameLib.driver = false;
        initGame(null);
    }

    public function initGame (pBubbleId : BubbleId = null, pLanguage: ELanguage = null, pPlayerTheme : EGameCharacter = null){
        if(mBubbleId != null) {
            Util.debug("initgame bubble id null " + mBubbleId);
            return;}

        Util.debug("Game5.initGame" + pBubbleId + " " + mBubbleId);

        if(pBubbleId == null)
            mBubbleId = new BubbleId(EBName.PlaceNumeral_20_1,3);
        else mBubbleId = pBubbleId;


        if(pLanguage == null) pLanguage = ELanguage.ENG;

        //initialize GameData : which is the interface with the Driver
        mData = new G5Lib(mBubbleId, pLanguage, this, EGameCharacter.ALL);

        //onRemove(null);
        startGame();
    }

    private function startGame(event: Event = null) {
        //Esto se hace para dejar que flash renderise todos los elementos del stage y luego inicializar plataformas y demas
        //this.gotoAndStop("background" + mPlayerWord + changePlusString)
        stage.addEventListener( Event.RENDER, startGame2, false, 0, true );
        stage.invalidate();
    }












    //$Comienza el juego, desde aqui pueden empezar a editar
    //store col points in board (2d array)
    public function startGame2(e : Event){
        stage.removeEventListener( Event.RENDER, startGame2);

        Util.debug("Game5.StartGame");

        //ParametersPanel
        G5L.initializeParameters()

        //Inicializa el objetivo con el numero de tasks y el tipo que es PLACE NUMBER.
        G5L.initGameGoal
        (
            Math.min(GameLib.params[G5L.mpNumPresentations],
                    1000),
            EGoal.PLACE_NUMBER
        );

        //Creating the World
        world = Util.createAndPositionMc(
				"Background_" + G5L.chooseSkin(), 
				100, 
				100);

        addChild(world);

        //and the path
        initializeG5Path();

        //Wiiiii!
        startRound();
    }



    public function returnToDriver(e : Event){
        G5L.dispatchEvent(new Event(GameLib.RETURN_TO_DRIVER));
    }


    //*Check if total tasks have been done
    public function onTaskFinished(e : Event){

        /*Util.debug(["G5Data.gameGoal.taskCounter", G5L.gameGoal.taskCounter, "G5Data.gameGoal.totalTasks", G5L.gameGoal.totalTasks], "OnTaskFinished");
        if(G5L.gameGoal.taskCounter >= G5L.gameGoal.totalTasks)
            this.gotoAndPlay(1);
        else startRound();*/
    }


    public function get Name()		: EGame		{ return EGame.G5;}
    public override function get Data()  		{ return (mData as com.kpm.games.game5.G5Lib)};
    public function get G5L() : G5Lib	{ return (mData as com.kpm.games.game5.G5Lib)}


    public override function initializeAudio() : KpmSound {
        Util.debug("Game5.createMusic");

        G5L.initializeAudio();

        if(!mMute)
            return G5L.createSound("G5_backgroundMusic", 1, 0.7, true, false, true);
        else return null;
    }

    private function initializeG5Parameters()
    {

        GameLib.params = new Array(G5Lib.NUM_PARAMETERS);


        for(var i=0; i < G5Lib.NUM_PARAMETERS; i ++)
        {
            GameLib.params[i] = parameterPanel()["p" + i].text;
            Util.debug("GameData.parameters " + i + " " + GameLib.params[i]);
        }
    }

    //
    public override function onRemove(e : Event)
    {
        Util.removeChildsOf(this);
        G5L.removeLists(e);
        removeCounters();

        //Util.removeChild(this);
    }





    private function initializeG5Path()
    {
        Util.debug("Game5.setupPiecesAndWholes");

        Util.debug("PARAMETERS : ");
        Util.debug("first number" + GameLib.params[G5L.mpInitialNumeral]);
        Util.debug("number of total nodes " + GameLib.params[G5L.mpNumTotalNodesInPath]);
        Util.debug("G5Data.numAnswersToChoose" +  GameLib.params[G5L.mpNumAnswersToChoose]);

        var firstNumber : int = GameLib.params[G5L.mpInitialNumeral] ;
        var lastNumber : int = int(GameLib.params[G5L.mpNumTotalNodesInPath]) + firstNumber;
        var i = firstNumber;

        while( i < lastNumber)
        {
            i += G5L.addNodesToPath(G5L.generateGroup(i, EG5PieceType.PIECE, Util.getRandBtw(GameLib.params[G5L.mpMinRandomAdjacentPieces], GameLib.params[G5L.mpMaxRandomNumAdjacentPieces])));
            i += G5L.addNodesToPath(G5L.generateGroup(i, EG5PieceType.WHOLE, Util.getRandBtw(GameLib.params[G5L.mpMinRandomNumAdjacentWholes], GameLib.params[G5L.mpMaxRandomNumAdjacentWholes])));

            Util.debug("generating groups with cardinality so far : " + i + " up to : " + lastNumber);
        }


        while(G5L.mNodes.length != GameLib.params[G5L.mpNumTotalNodesInPath])
            G5L.mNodes.pop();

        if(G5L.mNodes.length != GameLib.params[G5L.mpNumTotalNodesInPath])
            Util.assertFailed(["not same", "G5Data.mNodes length : ", G5L.mNodes.length,  "numTotalNodes : ", GameLib.params[G5L.mpNumTotalNodesInPath]]);


        for (var i = 0; i< GameLib.params[G5L.mpNumTotalNodesInPath]; i++)
        {
            addChild(addToGameObjects(G5L.mNodes[i], i));
        }
    }

    public function addToGameObjects(pNode : Object, index : int) : MovieClip
    {
        var counter : Counter;

        Util.debug("G5.addToGameObjets " + index);

        if(pNode.whole)
        {
            Util.printArray(["numeral ", pNode.numeral], "G5.addToGameObjects.addWhole");

            G5L.mPiecesList.push(GameComponent.createGCFromMc("BoxWhole", ["numeral", G5L.mNodes[index].numeral]));
            G5L.colorPiece(G5L.mPiecesList[index], EColor.BlueGray);

            G5L.mHoles.push(G5L.mNodes[index].numeral);

        }
        else
        {
            Util.printArray(["numeral ", pNode.numeral], "G5.addToGameObjects.addPiece");

            G5L.newCounter(index , G5L.mNodes[index].numeral , stage, G5L.mPiecesList);

            G5L.mPiecesList[index].addMovieBelow("BoxWhole");

            G5L.colorPiece(G5L.mPiecesList[index], EColor.BlueGray);


            //counter = new Counter(Counter.getNumberForm(mBubbleId), G5D.mNodes[index].numeral, stage);
            //G5D.mGameObjects[index].addMovieClip(counter, false, -100);
        }


        Util.debug(world);
        Util.debug(world["loc"+(index+1)].x + world.x);

        G5L.mPiecesList[index].x = world["loc"+(index+1)].x + world.x;
        G5L.mPiecesList[index].y = world["loc"+(index+1)].y + world.y;


        Util.debug("params[G5D.mpOrder]" + GameLib.params[G5L.mpOrder]);

        if(GameLib.params[G5L.mpOrder] == 1)
            {trace("case1"); G5L.mHoles.reverse();}

        else if(GameLib.params[G5L.mpOrder] == 0)
            {trace("case0"); Util.shuffleArray(G5L.mHoles);}


        //if(G5Data.mGameObjects.length != index+1)
        //    Util.assertFailed(["Game5.addGameObjects", "not same", "G5Data.mGameObjects.length-1",(G5Data.mGameObjects.length-1), "G5Data.mNodes.length",G5Data.mNodes.length, "index", index]);

        return G5L.mPiecesList[index];
    }


    //////////////END POPULATE PIECES AND WHOLES


    //$Start AudioVisualTask
    private function startRound(event: Event = null) {
//        if(Util.unitTest(funcTest_startRound))
//            throw "G5.startRound : numPresentations < taskCounter";
//        else
//            Util.debug("Game5.startRound");
//        // Instructions Sound
        G5L.soundLibrary.playLibSound(ESoundType.Instruction, "1", G5L.Language, null,null, G5L.Bubble.Name.Standard);

        //tInteractionPanel.visible = true;
        populateCounters();
        addCounterEvents(true);



    }

    /*
    private function funcTest_startRound() {
        if(GameData.params[G5D.mpNumPresentations] <= G5D.gameGoal.taskCounter)
            return true;
    }
     */



    private function populateCounters()
    {

        Util.printArray([GameLib.params[G5L.mpNumAnswersToChoose], G5L.mHoles.length ], "Game5.setupCounters");

        //Lista de Contadores para que el chico escoja alguno, lo lleve hacia una casilla con un agujero
        G5L.mAnswerBoxCounters = new Array(GameLib.params[G5L.mpNumAnswersToChoose]);

        //Loop que crea un counter
        for (var i=0; i < GameLib.params[G5L.mpNumAnswersToChoose] && i < G5L.mHoles.length ; i++){
            //Create counter

            G5L.newCounter(i, G5L.mHoles.pop(), stage, G5L.mAnswerBoxCounters);
            G5L.colorPiece(G5L.mAnswerBoxCounters[i], EColor.Blue);

            Util.debug("create counter " + i + G5L.mAnswerBoxCounters[i]);

            addChild(G5L.mAnswerBoxCounters[i]);
        }
    }



    //*Add or remove events for counter
    private function addCounterEvents (pAdd : Boolean) {
        Util.debug("add counter events " + pAdd)
        for(var i: Number = 0; i < G5L.mAnswerBoxCounters.length; i++){
            if(G5L.mAnswerBoxCounters[i] != null){
                if (pAdd) {
                    EventManager.addEvent(G5L.mAnswerBoxCounters[i], MouseEvent.MOUSE_UP, onGCDrag, i);

                    G5L.mAnswerBoxCounters[i].buttonMode = true;
                    G5L.mAnswerBoxCounters[i].index = i;
                    if(GameLib.driver) CursorManager.addOverEvents(G5L.mAnswerBoxCounters[i]);
                }
                else {
                    Util.debug("removing events");
                    EventManager.removeEvent(G5L.mAnswerBoxCounters[i], MouseEvent.MOUSE_UP);
                    EventManager.removeEvent(G5L.mAnswerBoxCounters[i], MouseEvent.MOUSE_DOWN);
                    G5L.mAnswerBoxCounters[i].buttonMode = false;
                    if(GameLib.driver) CursorManager.removeOverEvents(G5L.mAnswerBoxCounters[i]);
                }
            }
        }

        if(pAdd)
            addEmptyBoxes();
    }



    private function addEmptyBoxes () {
        //no need for 'button halo' around frame since the shape is very regular
        //if(mBubbleId.Name.Text.indexOf("5Frame") != -1 && mBubbleId.Level > 3)
        //  return;

        Util.debug("Game5.addEmptyBox to increase drag zone");
        for(var i: Number = 0; i < G5L.mAnswerBoxCounters.length; i++){
            Util.addEmptyBox(G5L.mAnswerBoxCounters[i]) ;


        }
    }



    private function onGCDrag(e: Event, pIndex : int)
    {
        Util.debug("G5.onGCDrag");
        EventManager.removeEvent(G5L.mAnswerBoxCounters[pIndex],  MouseEvent.MOUSE_UP);
        G5L.mAnswerBoxCounters[pIndex].drag();

        //IMPORTANT
        Data.startTask(GameLib.params[G5L.mpNumAnswersToChoose], 1);

        G5L.CurrentGoal = G5L.mAnswerBoxCounters[pIndex].numeral;

        EventManager.addEvent(G5L.mAnswerBoxCounters[pIndex],  MouseEvent.MOUSE_DOWN, onGCDrop, G5L.mAnswerBoxCounters[pIndex]);
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

            var i; for(i=0; i < G5L.mNodes.length ; i++){

                Util.printArray(["i : ", i,  "G5Data.mNodes[i].Numeral: ", G5L.mNodes[i].numeral, "intersect ", G5L.mPiecesList[i].hitTestPoint(mouseX, mouseY, true), "G5Data.mNodes[i].whole : ", G5L.mNodes[i].whole], "G5.OnGCDrop.intersect???")

                if(G5L.mPiecesList[i] && G5L.mNodes[i].whole &&
                   G5L.mPiecesList[i].hitTestPoint(pAnswerCounter.x, pAnswerCounter.y, true)){

                    intersectionIndex = i; break;

                    Util.printArray(["G5Data.mNodes[i].Numeral", G5L.mNodes[i].numeral, "intersect ", G5L.mPiecesList[i].hitTestPoint(pAnswerCounter.x, pAnswerCounter.y, true)], "G5OnGCDrop.intersect!!!")


                }

                //DEBUG : Util.printArray(["G5onGCDrop.intersectionIndex",i]);Util.printArray(["G5Data.mNodes[i].numeral", G5Data.mNodes[i].numeral]);Util.printArray(["pNode.numeral",pNode.numeral]);
            }



            if(intersectionIndex != -1)
            {
                if(G5L.mNodes[intersectionIndex].numeral == pAnswerCounter.numeral)
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

        G5L.mNodes[intersectionIndex].whole = false;

        G5L.colorPiece(pAnswerCounter, EColor.Blue);

        pAnswerCounter.drop();
        pAnswerCounter.x = G5L.mPiecesList[intersectionIndex].x;
        pAnswerCounter.y = G5L.mPiecesList[intersectionIndex].y;

        pAnswerCounter.done = true;

        G5L.CurrentTaskSuccess = GameLib.TASK_SUCCESS;
        G5L.soundLibrary.playLibSound(ESoundType.Feedback, EState.GOOD_MOVE, G5L.Language);
    }



    function collideFailure(intersectionIndex : int, pAnswerCounter : GameComponent)
    {

        pAnswerCounter.drop();

        pAnswerCounter.returnToHoldPosition();

        clickedTarget = new MovieClip();
        clickedTarget.feedbackObject = G5L.mNodes[intersectionIndex].numeral ;

        Util.debug("onGCDrop.intersect cardinality doesnt match" + clickedTarget.feedbackObject + " " + ENumber.numbers[clickedTarget.feedbackObject] + " " + clickedTarget.feedbackSound);

        EventManager.addEvent(pAnswerCounter, MouseEvent.MOUSE_UP, onGCDrag, pAnswerCounter.index)

        G5L.CurrentTaskSuccess = GameLib.TASK_FAILURE;
    }


    function checkStartRound()
    {
        Util.debug("check start round ");
        var readyToStartRound : Boolean = true;

        if(Data.isBubbleFinished())
        {
            endAnimation();

        }

        for each (var counter : GameComponent in G5L.mAnswerBoxCounters)
            if(!counter.done) readyToStartRound = false;

        if(readyToStartRound)
            startRound();

    }



    function endAnimation()
    {

        //Creating an aniation timer through the Util function
        var i =0;
        var animationIndex = 0; G5L.endAnimationTimer = Util.createTimer(200, GameLib.params[G5L.mpNumTotalNodesInPath], addTimedCharacter, animationComplete);
        var restOfNodesCovered_List : Array = new Array(G5L.mPiecesList.length)

        world.tWave.visible = true;

        Util.debug("G5.endAnimation" + G5L.endAnimationTimer);


        function addTimedCharacter(e : Event)
        {
            G5L.mAnimations_List = new Array();

            if(G5L.mNodes[animationIndex].numeral % 5 == 0){
                G5L.mAnimations_List[i] = G5L.setupEndAnimation(animationIndex, stage);

            }
            else{

                restOfNodesCovered_List[i] = G5L.newCounter(i, G5L.mPiecesList[animationIndex].numeral,  stage, restOfNodesCovered_List);
                world.addChild(restOfNodesCovered_List[i]);

            }

            animationIndex++;
            i++;

            Util.debug("G5.endAnimation.addCharacterAndVoice " + animationIndex );

        }

        function animationComplete(e : Event)
        {
            G5L.wait(1.5, 1, null, goBackToParamsPanel)
        }


    }


    function tryAgainSound()
    {
        Util.debug("Game5.tryAgainSound" + clickedTarget.feedbackObject + " " + G5L.gameGoal.quality);



        //FOR ALL GAMES
        G5L.feedbackSound = clickedTarget.feedbackObject+"";
        G5L.firstTry = false;
        G5L.soundLibrary.forceStop();

        //For this game...
        G5L.soundLibrary.playLibSound(ESoundType.Feedback, EState.BAD_MOVE);
        G5L.soundLibrary.playLibSound(ESoundType.FeedbackClick, clickedTarget.feedbackObject, G5L.Language, null, null, null, GameLib.FEEDBACK_FINISHED);


    }


    //$Hide counters that are not the solution
    private function removeCounters(pGoalId = -1){
        Util.debug("removeCounters " + pGoalId);
        if(!G5L.mAnswerBoxCounters)
            return;

        for(var i: Number = 0; i < G5L.mAnswerBoxCounters.length; i++){

            //Se deshabilita el counter que vino como parametro
            EventManager.removeEvent(G5L.mAnswerBoxCounters[i], MouseEvent.CLICK);
            G5L.mAnswerBoxCounters[i].buttonMode = false;
            if(GameLib.driver) CursorManager.removeOverEvents(G5L.mAnswerBoxCounters[i]);

            if (i != pGoalId)
            {
                Util.removeChild(G5L.mAnswerBoxCounters[i]);
            }



        }
    }
}


}