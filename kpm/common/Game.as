/******************************************
 /* Author : Carlos Lara
 /* variables :
 /* m: member, p: parameters, t : timeline
 /*****************************************/

package com.kpm.common {

import com.kpm.games.GameIgniter;
import com.kpm.kpm.BubbleId;
import flash.display.MovieClip;
import flash.events.Event;

public class Game extends MovieClip{

    protected var mData	 			: GameLib;
    protected var clickedTarget   : MovieClip;
    protected var backButton : MovieClip;
    //*current bubble being played
    private var _mBubbleId : BubbleId;
    //*whether music is muted or not
    private var _mMute: Boolean = false;
    private var _world : MovieClip ;



    public function Game(pStandAlone : Boolean) {
        if(pStandAlone) EventManager.addEvent(this, Event.ADDED_TO_STAGE, sendEvent, GameLib.BUBBLE_BEGIN);

    }


    public function sendEvent(e : Event, pEventName : String){

        EventManager.removeEvent(this, Event.ADDED_TO_STAGE);
        dispatchEvent(new Event(pEventName));
        //Util.addButton("parametersPanel", parent as MovieClip,  height-20, width-20, sendEvent, GameData.BEGIN_GAME+"")
    }

    public function parameterPanel() : MovieClip { return (parent as GameIgniter).paramsPanel}

    public function onBubbleFinished(e:Event)
    {
        Util.debug("game.onBubbleFinished");
        if(parent == stage)
        {
            Data.Level = Data.Bubble.Level + 1 ;
        }
    }


    public function goBackToParamsPanel(e : Event)
    {
        GameLib.driver.dispatchEvent(new Event(GameIgniter.ANIMATION_OVER));
    }

    public function onInstructionsFinished(e: Event) {}

    public function initializeAudio() : KpmSound
    {
        return null;
    }


    public function onStateChanged(e:Event) {}

    public function onRemove(e:Event) {}
    public function onFeedbackFinished(e:Event) {}
    public function unLockKeys(e:Event) {}
    public function blinkSolution() {}

    public function get Data() 			{ 	return mData ; 				}
    public function get Score() : uint 	{ 	return Data.gameGoal.globalScore; }

    public function get mBubbleId():BubbleId {
        return _mBubbleId;
    }

    public function set mBubbleId(value:BubbleId):void {
        _mBubbleId = value;
    }

    public function get mMute():Boolean {
        return _mMute;
    }

    public function set mMute(value:Boolean):void {
        _mMute = value;
    }

    public function get world():MovieClip {
        return _world;
    }

    public function set world(value:MovieClip):void {
        _world = value;
    }
}
}


