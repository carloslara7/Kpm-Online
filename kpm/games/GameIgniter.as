/**
 * Created with IntelliJ IDEA.
 * User: carloslara
 * Date: 5/26/14
 * Time: 12:45 PM
 * To change this template use File | Settings | File Templates.
 */
package com.kpm.games {

import com.kpm.common.EventManager;
import com.kpm.common.Game;
import com.kpm.common.GameLib;
import com.kpm.common.Util;
import com.kpm.kpm.EBScoreType;
import com.kpm.kpm.KpmBubble;

import flash.system.System;

//import com.kpm.kpm.KpmLogTool;

import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.getDefinitionByName;


    public class GameIgniter extends MovieClip{

        private var _paramsPanel : MovieClip
        private var _bubble : KpmBubble

        public static const ANIMATION_OVER : String = "ANIMATION_OVER";

        var interfacePanel : MovieClip;
        var _accompanied : Boolean;


        var game : Game;
        var gameName : String;
        var back_Bt : SimpleButton;
        //var logTool : KpmLogTool;
        var allBubblesUnlocked = false;



        public function GameIgniter(pGameName : String) {
            Util.printArray(["GameName : ", pGameName], "GameIgniter()")

            gameName = pGameName;
            initParamsPanel();
            addInterfacePanel();

        }

        private function initParamsPanel()
        {

            _paramsPanel = Util.createAndPositionMc("ParametersPanel", 100, 20);
            interfacePanel = Util.createAndPositionMc("InterfacePanel", 1000, 600);

            EventManager.addEvent(_paramsPanel.tGoButton, MouseEvent.CLICK, initializeGame) ;


            addChild(_paramsPanel);



        }

        public function addInterfacePanel()
        {

        }

        public function updateTaskTimer(e : Event)
        {
            if(game)
                interfacePanel.tTaskTimer.text = game.Data.taskTimerNumber();
        }

        public function finishGame(e : Event = null){

            if(game){

                game.Data.onRemove(null);
                game = null;
                Util.removeChild(game);
            }

            _paramsPanel.visible = true;
            System.gc();

        }

        private function initializeGame(e : Event) {

            if(game)
                finishGame();

            _paramsPanel.visible = false;


            var newGame5:Class = getDefinitionByName(gameName) as Class;
            Util.printArray(["newGame5", newGame5], "initalizeGame");

            game = new newGame5(true);
            addChild(game);

            back_Bt = Util.addButton("BackButton", this, 1280 - 40, 800 - 40, finishGame) as SimpleButton;
            back_Bt.visible = true;

            EventManager.addEvent(game, ANIMATION_OVER, finishGame);


        }

        public function get Accompanied():Boolean {
            return _accompanied;
        }

        public function set Accompanied(value:Boolean):void {
            _accompanied = value;
        }

        public function get paramsPanel():MovieClip {
            return _paramsPanel;
        }


        public function addToLog(pXml : XML)
        {
            //logTool.addToLog(pXml);
        }

        public function updateBubbleFeedback()
        {
            /*
            Util.debug("updating bubble feedback" + game.mBubbleId + " " + game.Data.CurrentGoal, this);
            var xmlLogString : String ;

            if(game.mBubbleId)
                interfacePanel.tBubbleText.text = game.mBubbleId.Text;
            else
                interfacePanel.tBubbleText.text = "";

            var statsString : String = "";
            var separator : String = " - ";

            statsString += "Score : " + (game.Data.gameGoal.globalScore) + separator;
            statsString += "TaskScore : " + (game.Data.gameGoal.taskScore) + separator;
            statsString += "Threshold : " + game.Data.CurrentScoreToEnjoy + " / " + game.Data.CurrentScoreToPass + separator;

            if(game.mBubbleId.Name.ScoreType == EBScoreType.Choice)
            {
                statsString += "m/n	: " + game.Data.gameGoal.numCorrectOptions + " / " + game.Data.gameGoal.numOptions + separator;
            }
            else
                statsString += "opt/clicks/dfromTarget	: " + game.Data.gameGoal.lengthOptimalPath + " / " + game.Data.gameGoal.lengthPath + " / " + game.Data.gameGoal.distanceFromTarget + separator;

            statsString += "Score Type : " + game.mBubbleId.Name.ScoreType.Text + " FPS : " + stage.frameRate;

            interfacePanel.tTaskCounter.text = " Tasks: " + game.Data.gameGoal.succededTaskCounter + " / " + game.Data.gameGoal.taskCounter + " / " + game.Data.gameGoal.totalTasks + " . ";

            Util.debug(" Tasks: " + game.Data.gameGoal.succededTaskCounter + " / " + game.Data.gameGoal.taskCounter + " / " + game.Data.gameGoal.totalTasks + " . ");
            interfacePanel.tTaskStats.text = statsString;


            //xmlLogString = currentGame.Data.taskXML.toXMLString();

            if(allBubblesUnlocked)
                return;

            //xmlLogString = logTool.BubbleSessionXML.toXMLString()
            xmlLogString = xmlLogString.split("=").join(":");
            xmlLogString = xmlLogString.split("\"").join(" ");

            interfacePanel.tStats.tLog.text = xmlLogString;
            */
        }

        public function get bubble():KpmBubble {
            return _bubble;
        }

        public function set bubble(value:KpmBubble):void {
            _bubble = value;
        }
    }
}
