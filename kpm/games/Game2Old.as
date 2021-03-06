    /******************************************
     /* Author : Carlos Lara
     /* variables :
     /* m: member, p: parameters, t : timeline
     /*****************************************/

    package com.kpm.games {
    import com.kpm.common.*;
    import com.kpm.kpm.BubbleId;
    import com.kpm.kpm.EBName;

    import fl.transitions.Tween;
    import fl.transitions.TweenEvent;

    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Point;
    import flash.utils.Timer;
    import flash.utils.getTimer;

    public class Game2 extends Game implements IGame{
        // Game Components
        // Shapes : named Shape1 ... Shape2

        //Player
        private var shapeMovieList		: Game2ShapeList;
        private var numbersList			: MovieList2D	;
        public var CurrentPuzzle		: Game2Puzzle;
        private var PreviousShape		: KpmShape;
        private var CurrentShape		: KpmShape;
        private var CurrentNumber		: Counter;
        private var ShapeHit			: MovieClip;
        private var dragTimer			: Number;
        private var clickedBlankOnce	: Boolean = false;

        private var negativeScoreCounter		: int = 0;
        private var needAnimationCounter		: int = 0;

        public var tweenX, tweenY, tweenRotation, tweenScaleX, tweenScaleY: Tween;
        public var chosenShape 			: KpmShape;
        public var chosenShapeInList 	: KpmShape;
        public var failedTargetShape : MovieClip;

        public var extraShapes : Array;
        private var similarShapesInPuzzleAndList : Boolean;


        public function Game2(isStandAlone : Boolean = false) : void
        {
            Util.debug("Game2Constructor " + isStandAlone);
            if(isStandAlone)
                EventManager.addEvent(this, Event.ADDED_TO_STAGE, onInit);
        }

        public function onInit(e : Event)
        {
            initGame();
            EventManager.removeEvent(this, Event.ADDED_TO_STAGE);
        }


        public function initGame(pBubble : BubbleId = null, pLanguage : ELanguage = null, pGameTheme : EGameCharacter = null)
        {
            if(pBubble != null)
                mData = new Game2Data(pBubble, pLanguage, this);
            else
                mData = new Game2Data(new BubbleId(EBName.IdentifyShape, 1), ELanguage.SPA, this);

            //Util.debug("DIMENSIONS " + parent.height + " " + parent.width, this);

            setPuzzle();
        }

        public function initialize(e : Event)
        {
            G2Data.keysLocked = false;
            G2Data.firstShape = true;
            G2Data.shapeSuccessCounter = 0;
            G2Data.gameGoal.totalTasks = CurrentPuzzle.Puzzle.numChildren;
            extraShapes = new Array();


            if(G2Data.lvl_ClickColor)
            {
                CurrentPuzzle.paintPuzzleShapes(GameLib.colorsRGB);
            }

            if(G2Data.lvl_ClickNumber)
                setNumbersList();

            if(G2Data.lvl_MatchShape || G2Data.lvl_PlaceShape)
                setOptionsList();


            if(G2Data.lvl_PlaceShape)
            {
                CurrentPuzzle.paintPuzzleShapes(GameLib.colorsRGB);
                beginTaskPlaceShapeHelper(null);


            }

            if(G2Data.lvl_ClickShape)
            {
                setRandomGoalFromPuzzle();
                if(G2Data.gameGoal.quality == EGoal.COLOR)
                    G2Data.gameGoal.numCorrectOptions = CurrentPuzzle.countShapes(G2Data.gameGoal.currentGoal, EGoal.COLOR);
                else
                    G2Data.gameGoal.numCorrectOptions = CurrentPuzzle.countShapes(G2Data.gameGoal.currentGoal, EGoal.SHAPE);
                G2Data.gameGoal.numOptions = CurrentPuzzle.Puzzle.numChildren;
            }

            G2Data.setInstructions();
            //G2Data.SoundPlayer.forcePlaySoundFromQueue();
            G2Data.onTaskFinished(null);


        }

        public override function onRemove(e:Event)
        {
            stage.removeEventListener( Event.RENDER, initialize);
            removeEventListener (Event.REMOVED_FROM_STAGE, onRemove);
        }

        public override function unLockKeys(e : Event)
        {
            G2Data.keysLocked = false;
            G2Data.State = EState.IDLE;
        }

        function setPuzzle()
        {
            if(G2Data.lvl_PlaceShape)
            {
                gotoAndStop("left");
                G2Data.puzzlePosition = new Point2D(550, 310);
                G2Data.optionsList.position = new Point2D(140, G2Data.options_y)
            }
            else
            {
                gotoAndStop("right");
                G2Data.puzzlePosition = new Point2D(350, 310);
            }

            stage.addEventListener( Event.RENDER, initialize, false, 0, true );
            stage.invalidate();

            Util.removeChild(CurrentPuzzle);
            CurrentPuzzle = new Game2Puzzle(G2Data.puzzlePosition, G2Data.getNextPuzzle());
            addChild(CurrentPuzzle);
            CurrentPuzzle.initialize();

            if(G2Data.lvl_ClickShape || G2Data.lvl_MatchShape)
                addPuzzleEvents();
        }



        public function addPuzzleEvents()
        {
            var stageShape : MovieClip;

            for(var i=0; i < CurrentPuzzle.Puzzle.numChildren; i++)
            {
                stageShape = CurrentPuzzle.Puzzle.getChildAt(i)  as MovieClip;
                stageShape.addEventListener(MouseEvent.MOUSE_DOWN, onShapeClick, false, 0 , true);
                if(GameLib.driver) CursorManager.addOverEvents(stageShape);
                stageShape.buttonMode = true;

                if(G2Data.lvl_MatchShape)
                {
                    stageShape.addEventListener(MouseEvent.MOUSE_UP , currentShapeDrop, false, 0 , true);
                }
            }

        }

        public function onTaskFinished(e : Event)
        {

        }

        public function beginTaskPlaceShapeHelper(e : Event)
        {
            var i =0;

            do
            {
                Util.debug("begin place Shape");
                beginTaskPlaceShape()
                i++;
            }
            while((similarShapesInPuzzleAndList || G2Data.lvl_DistractorType == Game2ShapeList.DISTRACTORS_IN_PUZZLE) && i < 1)

            Util.debug("at the end similar shape is " + similarShapesInPuzzleAndList);
        }

        public function beginTaskPlaceShape()
        {
            similarShapesInPuzzleAndList = false;

            CurrentPuzzle.resetUsedShapes();
            Util.removeChild(chosenShapeInList);

            chosenShape = CurrentPuzzle.getRandomShape();
            shapeMovieList.visible = true;
            var numOptions = 3;

            G2Data.gameGoal.numCorrectOptions = 1;
            G2Data.gameGoal.numOptions = CurrentPuzzle.Puzzle.numChildren;

            if(G2Data.lvl_DistractorType == Game2ShapeList.DISTRACTORS_IN_PUZZLE)
                numOptions = Math.min(CurrentPuzzle.Puzzle.numChildren, 3);

            G2Data.onTaskFinished(null);

            Util.debug("generating shapes " + chosenShape);
            shapeMovieList.init();
            shapeMovieList.generateShapes(chosenShape, numOptions);

            if(G2Data.lvl_DistractorType != Game2ShapeList.DISTRACTORS_IN_PUZZLE)
            {
                chosenShapeInList = KpmShape.makeShape(this.shapeMovieList.chosenShape as MovieClip, true);

                addChild(chosenShapeInList);
                chosenShapeInList.x = shapeMovieList.chosenShape.x + shapeMovieList.x;
                chosenShapeInList.y = shapeMovieList.chosenShape.y + shapeMovieList.y;
                chosenShapeInList.addEventListener(MouseEvent.MOUSE_DOWN, onPlaceShapeClick, false, 0 , true);
                if(GameLib.driver) CursorManager.addOverEvents(chosenShapeInList);
                chosenShapeInList.buttonMode = true;

            }


            negativeScoreCounter = 0;
            needAnimationCounter = 0;

            for(var i=0; i< shapeMovieList.Rows.length; i++)
            {
                shapeMovieList.Rows[i].addEventListener(MouseEvent.MOUSE_DOWN, onPlaceShapeClick, false, 0 , true);
                if(GameLib.driver) CursorManager.addOverEvents(shapeMovieList.Rows[i]);
                shapeMovieList.Rows[i].buttonMode = true;
            }



            for(var j=0 ; j < extraShapes.length; j++)
            {
                Util.removeChild(extraShapes[j]);
            }

            //G2Data.setInstructions();
            if(tCurtain.currentLabel != "open")
                tCurtain.gotoAndPlay("open");

            setChildIndex(tCurtain, numChildren-1);

            for(var k=0; k < CurrentPuzzle.Puzzle.numChildren; k++)
            {
                for (var l=0; l < shapeMovieList.Rows.length; l++)
                {
                    Util.debug("checking automatically " + shapeMovieList.Rows[l] + " " + shapeMovieList.Rows[l].height + " " + shapeMovieList.Rows[l].width);
                    var c = CurrentPuzzle.Puzzle.getChildAt(k);
                    var p = shapeMovieList.Rows[l];

                    if(Util.sameClass(p, c.Movie) && Util.checkSimilarScales(p, c, 8) != 0)
                    {
                        similarShapesInPuzzleAndList = true;
                        Util.debug("match " + c + " " + p);
                    }


                }
            }

        }

        function setOptionsList()
        {
            tCurtain.visible = true;
            tCurtain.gotoAndPlay("close");

            Util.removeChild(shapeMovieList);
            //shapeMovieList = new Game2ShapeList(G2Data.optionsList, Util.generateSetFromMc(CurrentPuzzle.Puzzle));
            shapeMovieList = new Game2ShapeList(G2Data.optionsList, Game2Data.game2Shapes, this);
            addChild(shapeMovieList);



            Util.debug("adding shape list " + G2Data.optionsList.position, this);

            shapeMovieList.x = G2Data.optionsList.position.x;
            shapeMovieList.y = G2Data.optionsList.position.y;
            //optionsList.populateTypesInMovie(mCurrentPuzzle.Puzzle);

            Util.shuffleArray(shapeMovieList.puzzleShapeTypes);
            addChild(CurrentPuzzle);

        }

        function setNumbersList()
        {
            tCurtain.visible = false;

            numbersList = new MovieList2D(1, G2Data.gameGoal.numOptions, G2Data.numbersList.fixed);
            addChild(numbersList);


            for(var j =0; j < G2Data.gameGoal.numOptions; j++)
            {
                numbersList.Cols[0].add(new Counter(G2Data.lvl_TargetMovieNames[0], j + 1, stage));
                numbersList.Cols[0].Rows[j].addEventListener(MouseEvent.CLICK, onNumberClick, false, 0 , true);
                numbersList.Cols[0].Rows[j].buttonMode = true;
            }

            numbersList.Cols[0].x = G2Data.numbersList.position.x;
            numbersList.Cols[0].y = G2Data.numbersList.position.y;
        }

        function onShapeClick(e:Event)
        {
            // buggg

            Util.debug("shape click " + G2Data.keysLocked + " " +  CurrentShape + " " + tCurtain.currentLabel);
            if(G2Data.keysLocked ||
                    CurrentShape != null ||
                    G2Data.State == EState.END_ANIMATION ||
                    (tCurtain.currentLabel != "close" && PreviousShape && PreviousShape.attempts == 0)
            // || (G2Data.State == EState.INSTRUCTIONS && G2Data.firstLevel && G2Data.Bubble.Level == 1)
                    )
                return;

            else
            {
                G2Data.State = EState.IDLE;
            }

            CurrentShape = e.target.parent as KpmShape;

            if(G2Data.lvl_MatchShape)
            {
                Util.debug("dragging ", this);
                G2Data.taskTimer.start();
                currentShapeDrag();
            }
            else if(G2Data.lvl_ClickShape)
            {
                Util.debug("clicking", this);
                currentShapeClick();
            }


        }

        function onPlaceShapeClick(e:Event)
        {

            Util.debug("shape click " + G2Data.keysLocked + " " +  CurrentShape + " " + tCurtain.currentLabel);

            if(G2Data.keysLocked ||
                    CurrentShape != null ||
                    G2Data.State == EState.END_ANIMATION)
            // || (G2Data.State == EState.INSTRUCTIONS && G2Data.firstLevel && G2Data.Bubble.Level == 1)

                return;

            else
            {
                G2Data.State = EState.IDLE;
            }

            var shapeMovie = e.currentTarget;

            Util.debug("selecting shape of type " + e.currentTarget.Type);

            if(Util.getClassName(shapeMovie) == "KpmShape")
            {
                CurrentShape = shapeMovie
            }
            else
            {
                CurrentShape = KpmShape.makeShape(shapeMovie as MovieClip, true);
                CurrentShape.x = shapeMovie.x + shapeMovie.parent.x;
                CurrentShape.y = shapeMovie.y + shapeMovie.parent.y;
            }


            currentPlaceShapeDrag();

            CurrentShape.buttonMode = true;
            CurrentShape.addEventListener(MouseEvent.MOUSE_UP , onPlaceShapeDrop, false, 0 , true);



            extraShapes.push(addChild(CurrentShape));

            Util.debug("setting current shape as " + CurrentShape);


        }


        function onNumberClick(e:Event)
        {
    //			var currentCounter : Counter = e.currentTarget as Counter;
    //			var numShapes =  CurrentPuzzle.countShapes(G2Data.gameGoal.currentGoal, EGoal.SHAPE);
    //
    //			Util.debug("numbers", this);
    //			Util.debug(currentCounter.number, this);
    //
    //			if(currentCounter.number == G2Data.gameGoal.answer)
    //			{
    //				CurrentPuzzle.eraseShapesOfType(G2Data.gameGoal.shape);
    //				G2Data.State = EState.GOOD_MOVE;
    //			}
    //			else
    //			{
    //				G2Data.State = EState.BAD_MOVE;
    //			}

        }

        function currentShapeClick()
        {
            Util.debug("currentshape " + CurrentShape.getShortType(), this);
            var currentShapeQuality;
            G2Data.soundLibrary.forceStop();


            if(G2Data.gameGoal.quality == EGoal.SHAPE)
            {
                currentShapeQuality = CurrentShape.getShortType();
                Util.debug("num correct shapes " + G2Data.gameGoal.numCorrectOptions, this);
            }

            else if(G2Data.gameGoal.quality == EGoal.COLOR)
            {
                currentShapeQuality = CurrentShape.color.Text;

            }

            if(currentShapeQuality == G2Data.gameGoal.currentGoal.Text)
            {
                G2Data.State = EState.GOOD_MOVE;

            }
            else
            {
                if(G2Data.gameGoal.quality == EGoal.SHAPE)
                    G2Data.feedbackSound = CurrentShape.getShortType();
                else if(G2Data.gameGoal.quality == EGoal.COLOR)
                    G2Data.feedbackSound = CurrentShape.color.Text;

                G2Data.State = EState.BAD_MOVE;


            }
        }

        function currentShapeDrag()
        {

            G2Data.CurrentGoal = CurrentShape;
            dragTimer = getTimer();
            //G2Data.SoundPlayer.playSound(G2Data.createSound("Drag"));
            setChildIndex(tCurtain, numChildren-1);

            if(CurrentShape.attempts == 0 || CurrentShape != PreviousShape)
            {
                tCurtain.gotoAndPlay("open");
                shapeMovieList.visible = true;
                negativeScoreCounter = 0;
                shapeMovieList.generateShapes(CurrentShape, G2Data.gameGoal.numOptions);
                makeSoundShape();

            }

            CurrentPuzzle.Puzzle.setChildIndex(CurrentShape,CurrentPuzzle.Puzzle.numChildren-1);
            CurrentShape.drag();

        }

        function currentPlaceShapeDrag()
        {

            G2Data.CurrentGoal = CurrentShape;
            dragTimer = getTimer();
            CurrentShape.tFill.alpha = 50;

            //G2Data.SoundPlayer.playSound(G2Data.createSound("Drag"));
            setChildIndex(tCurtain, numChildren-1);

            if(CurrentShape.attempts == 0 || CurrentShape != PreviousShape)
            {
                //tCurtain.gotoAndPlay("open");
                makeSoundShape();

            }

    //			var debugPoint : MovieClip = new DebugPoint();
    //			debugPoint.x = CurrentShape.x;
    //			debugPoint.y = CurrentShape.y;
    //			addChild(debugPoint);

            //CurrentShape.visible = false;
            CurrentShape.drag();
        }

        function makeSoundShape()
        {
            G2Data.soundLibrary.forceStop();
            G2Data.soundLibrary.playLibSound(ESoundType.FeedbackClick, CurrentShape.getShortType()+"Name", G2Data.Language)

    //			if(G2Data.Language == ELanguage.ENG)
    //			{
    //				G2Data.SoundPlayer.pushSound(G2Data.createSound(CurrentShape.getShortType(), 3, 1, true, true));
    //			}
    //			else
    //			{
    //				G2Data.SoundPlayer.pushSound(G2Data.createSound(CurrentShape.getShortType()+"1", 1, 1, true, true));
    //			}
    //
    //			G2Data.SoundPlayer.forcePlaySoundFromQueue();
        }

        function currentShapeDrop(e:MouseEvent)
        {

            if(CurrentShape == null || !G2Data.lvl_MatchShape)
                return;

            if(CurrentShape && !CurrentShape.mDragging)
                return;


            var localShape : MovieClip = Util.cloneMovie(CurrentShape.Type,
                    CurrentShape);
            var coord : Point2D 	   = changeCoordToParent(CurrentShape, shapeMovieList);
            localShape.x = coord.x;
            localShape.y = coord.y;

            Util.debug("localShape " + coord);

            if(getTimer() - dragTimer < 500)
                return;

            if(!Util.intersect(CurrentShape, tDropRegion, this))
            {
                Util.debug("not intersecting region", this);
                return;
            }
            //if(coord.x < -125)
            //	return;

            Util.debug("accepted drop", this);
            if(GameLib.driver) CursorManager.setIdleCursor(null);

            ShapeHit = shapeMovieList.hitShape(localShape);

            var debugPoint : MovieClip = new DebugPoint();
            debugPoint.x = coord.x;
            debugPoint.y = coord.y;
            shapeMovieList.addChild(debugPoint);

            if(!ShapeHit)
            {
                if(!clickedBlankOnce)
                {
                    G2Data.soundLibrary.playLibSound(ESoundType.Feedback, GameLib.TRY_AGAIN);
                    //G2Data.SoundPlayer.playSound(G2Data.createSound(GameData.TRY_AGAIN, 3));
                }

                clickedBlankOnce = true;
            }
            else
            {
                Util.debug("local shape class " + Util.getClassName(localShape), this);
                Util.debug("shape hit class " + ShapeHit, this);

                if(GameLib.driver) CursorManager.setIdleCursor(null);

                if(Util.sameClass(ShapeHit, localShape))
                {

                    CurrentShape.removeEventListener(MouseEvent.MOUSE_DOWN, onShapeClick);
                    CurrentShape.removeEventListener(MouseEvent.MOUSE_UP , currentShapeDrop);
                    if(GameLib.driver) CursorManager.removeOverEvents(CurrentShape);
                    CurrentShape.drop();
                    animateShape(null, CurrentShape, ShapeHit);
                    clickedBlankOnce = false;

                }
                else
                {
                    CurrentShape.returnToHoldPosition();
                    CurrentShape.dropShadow(false);
                    CurrentShape.drop();
                    G2Data.feedbackSound = KpmShape.getShortType(Util.getClassName(ShapeHit));
                    //				shapeMovieList.remove(shapeMovieList.hitShape(localShape));
                    shapeMovieList.remove(ShapeHit);
                    G2Data.State = EState.BAD_MOVE;
                    clickedBlankOnce = false;
                    negativeScoreCounter++;


                    //Util.debug(CurrentShape.x + " " + CurrentShape.y);

                }
            }

        }

        function onPlaceShapeDrop(e:MouseEvent)
        {

            if(CurrentShape == null || !G2Data.lvl_PlaceShape)
                return;

            if(CurrentShape && !CurrentShape.mDragging)
                return;

            Util.debug("Game2.currentPlaceShapeDrop " + CurrentShape + " " + G2Data.lvl_PlaceShape + " " + CurrentShape.mDragging);
            var originShape : MovieClip;

            //var localShape : MovieClip = Util.cloneMovie(CurrentShape.Type,
            // CurrentShape);
            var cord : Point 	   = CurrentShape.parent.localToGlobal(new Point(CurrentShape.x, CurrentShape.y));
            var coord : Point2D = new Point2D(cord.x, cord.y);

            //Util.debug("dropping" + (getTimer() - dragTimer), this);
            if(getTimer() - dragTimer < 500)
            {
                //localShape.x = coord.x;
                //localShape.y = coord.y;

                return;
                //if(coord.x < -125)
                //	return;

            }


            if(Util.intersect(CurrentShape, tDropRegion, this))
            {
                CurrentShape.drop();
                CurrentShape.dropShadow(false);
                CurrentShape.addEventListener(MouseEvent.MOUSE_DOWN, onPlaceShapeClick, false, 0 , true);
                CurrentShape = null;

                return;
            }

            Util.debug("accepted drop", this);
            if(GameLib.driver) CursorManager.setIdleCursor(null);


    //				var debugPoint : MovieClip = new DebugPoint();
    //				debugPoint.x = coord.x;
    //				debugPoint.y = coord.y;
    //				addChild(debugPoint);
    //
            //localShape.x = coord.x;
            //localShape.y = coord.y;

            var radio : int;

            if(CurrentShape.height > 40 && CurrentShape.width > 40)
                radio = 15;
            else
                radio = 10;
            ShapeHit = CurrentPuzzle.intersect(coord, radio, CurrentShape);



            if(ShapeHit)
            {
                Util.debug("local shape class " + CurrentShape.Movie, this);
                Util.debug("shape hit class " + ShapeHit.Movie, this);

                if(GameLib.driver) CursorManager.setIdleCursor(null);

                Util.debug("scales " + ShapeHit.scaleX + " " + CurrentShape.scaleX + " " +  ShapeHit.scaleY + " " + CurrentShape.scaleY);

                //if success

                Util.debug("rotations " + ShapeHit.rotation +  " " + CurrentShape.rotation);

                //if((G2Data.lvl_DistractorRotation || ShapeHit.rotation - CurrentShape.rotation < 2) &&
                if (Util.sameClass(ShapeHit.Movie, CurrentShape.Movie) && Util.checkSimilarScales(ShapeHit, CurrentShape, 3) != 0)
                {
                    Util.debug("same class");
                    G2Data.gameGoal.numOptions = CurrentPuzzle.Puzzle.numChildren;
                    CurrentShape.removeEventListener(MouseEvent.MOUSE_DOWN, onPlaceShapeClick);
                    CurrentShape.removeEventListener(MouseEvent.MOUSE_UP , onPlaceShapeDrop);
                    if(GameLib.driver) CursorManager.removeOverEvents(CurrentShape);
                    CurrentShape.drop();
                    animateShape(null, CurrentShape, ShapeHit);

                }
                //if failure
                else
                {
                    Util.debug("different class");


                    CurrentShape.addEventListener(MouseEvent.MOUSE_DOWN, onPlaceShapeClick, false, 0 , true);

                    if(G2Data.lvl_DistractorType != Game2ShapeList.DISTRACTORS_IN_PUZZLE)
                        if(!Util.sameClass(CurrentShape.Movie, chosenShape.Movie))
                            CurrentShape.visible = false;

                    CurrentShape.returnToHoldPosition();
                    CurrentShape.dropShadow(false);
                    CurrentShape.drop();

                    G2Data.feedbackSound = KpmShape.getShortType(Util.getClassName(ShapeHit.Movie));

                    negativeScoreCounter++;

                    if((G2Data.Bubble.Name != EBName.PlaceShapeA && CurrentShape == chosenShapeInList) || G2Data.Bubble.Name == EBName.PlaceShapeA)
                        needAnimationCounter++;

                    CurrentShape.tFill.alpha = 100;


                    if(needAnimationCounter == 3)
                    {
                        originShape = CurrentShape;
                        if(G2Data.Bubble.Name == EBName.PlaceShapeB)
                        {
                            //extraShapes.push(CurrentShape);

                            Util.debug("creating new shape" + CurrentShape);
                            //Util.removeChild(this.shapeMovieList.chosenShape);
                            addChild(chosenShapeInList);
                            originShape = chosenShapeInList;
                        }

                        Util.debug("failed too many times. last try with" + CurrentShape);
                        Util.debug("origin shape is " + originShape);

                        failedTargetShape = (G2Data.Bubble.Name == EBName.PlaceShapeA) ? findTargetShape(CurrentShape) : chosenShape as MovieClip;

                        //originShape.addChild(new DebugPoint());
                        //failedTargetShape.addChild(new DebugPoint());

                        var myDelay:Timer = new Timer(2000, 1);
                        //Util.blink(failedTargetShape);
                        EventManager.addEvent(myDelay, TimerEvent.TIMER, animateShape, originShape, failedTargetShape, 5);

                        myDelay.start();

                    }

                    G2Data.State = EState.BAD_MOVE;


                }
            }

        }

        function findTargetShape(pShape : KpmShape)
        {

            for(var i=0; i < CurrentPuzzle.Puzzle.numChildren; i++)
            {
                var tempShape : MovieClip = CurrentPuzzle.Puzzle.getChildAt(i) as MovieClip;
                Util.debug("find target for " + pShape.Type + " " + tempShape.Type);
                if(pShape.Type ==  tempShape.Type && Util.checkSimilarScales(pShape, tempShape, 10) != 0)
                {
                    return tempShape;
                }
            }

            throw new Error("couldnt find target shape");

        }

        function animateShape(pEvent : Event, pOriginShape : KpmShape, pTargetShape : MovieClip, pTime : Number = 0)
        {
            Util.debug("failedCounter animate shape " + needAnimationCounter);

            var tweenObj : Object = new Object();
            var shapePositionTarget : Point2D = getCurrentShapeTargetPosition(pOriginShape, pTargetShape);

    //			var debugPoint : MovieClip = new DebugPoint();
    //			debugPoint.x = shapePositionTarget.x;
    //			debugPoint.y = shapePositionTarget.y;
    //			addChild(debugPoint);

            tweenObj.ease = -1;

            Util.debug("animation " + pOriginShape + " " + pOriginShape.x + " " + pOriginShape.y + " to " + pTargetShape + " " + pTargetShape.x + " " + pTargetShape.y);

            if(G2Data.lvl_PlaceShape && pTime != 0)
                tweenObj.time = pTime;

            if(pOriginShape.rotation != pTargetShape.rotation)
            {
                tweenObj.tween = "rotation";
                tweenObj.initial = pOriginShape;
                tweenObj.target = pTargetShape;

                if(tweenObj.time == null)
                    tweenObj.time = 1.6;


                tweenRotation = pOriginShape.execTween(tweenObj);
            }

            //need to pTime...
            if(tweenObj.time == null)
                tweenObj.time = 0.8;



            tweenObj.tween = "x";
            tweenObj.initial = pOriginShape;
            tweenObj.target = shapePositionTarget;
            tweenX = pOriginShape.execTween(tweenObj);
            tweenX.addEventListener(TweenEvent.MOTION_FINISH, onGoodMove, false, 0 , true);

            tweenObj.tween = "y";
            tweenObj.initial = pOriginShape;
            tweenObj.target = shapePositionTarget;
            tweenY = pOriginShape.execTween(tweenObj);

            tweenObj.tween = "scaleX";
            tweenObj.initial = pOriginShape;
            tweenObj.target = pTargetShape;
            tweenObj.time = 0.2;
            tweenScaleX = pOriginShape.execTween(tweenObj);

            tweenObj.tween = "scaleY";
            tweenObj.initial = pOriginShape;
            tweenObj.target = pTargetShape;
            tweenScaleY = pOriginShape.execTween(tweenObj);


        }

        function getCurrentShapeTargetPosition(pOriginShape, pShapeHit) : Point2D
        {

            var mCurrentShapePoint : Point2D = Util.getGlobalCoordinates(pOriginShape);
            var hitShapePoint : Point2D = Util.getGlobalCoordinates(pShapeHit);
            var point : Point2D = new Point2D(pOriginShape.x,pOriginShape.y);


            if(G2Data.lvl_MatchShape)
                point.x += (-mCurrentShapePoint.x + hitShapePoint.x)*1/pOriginShape.parent.scaleX*G2Data.SCREEN_SIZE.x/parent.width;
            else
                point.x += (-mCurrentShapePoint.x + hitShapePoint.x)*1/pOriginShape.parent.scaleX;

            if(G2Data.lvl_MatchShape)
                point.y += (-mCurrentShapePoint.y + hitShapePoint.y)*1/pOriginShape.parent.scaleY*G2Data.SCREEN_SIZE.y/parent.height;
            else
                point.y += (-mCurrentShapePoint.y + hitShapePoint.y)*1/pOriginShape.parent.scaleY;

            return point;

        }


        function changeCoordToParent(pMovie : MovieClip, pParent : MovieClip) : Point2D
        {
            var coord : Point2D = Util.getGlobalCoordinates(pMovie);
            Util.debug("changing coord " + parent + " " + parent.width + " " + parent.height, this);
            coord.x = coord.x /(parent.width/G2Data.SCREEN_SIZE.x) - pParent.x;
            coord.y = coord.y /(parent.height/G2Data.SCREEN_SIZE.y) - pParent.y;
            return coord;
        }

        function onGoodMove(e:TweenEvent)
        {
            tweenX.removeEventListener(TweenEvent.MOTION_FINISH, onGoodMove);
            G2Data.State = EState.GOOD_MOVE;

            if(G2Data.lvl_PlaceShape)
            {
                if(needAnimationCounter == 3 )
                {
                    Util.removeChild(failedTargetShape);
                    Util.removeChild(chosenShapeInList);
                    Util.removeChild(CurrentShape);
                }

                else
                {
                    Util.removeChild(CurrentShape);
                    Util.removeChild(ShapeHit);
                }

                if(CurrentPuzzle.numChildren > 0)
                {
                    setChildIndex(tCurtain, numChildren-1);
                    tCurtain.gotoAndPlay("close");
                    CurrentShape = null;


                    if(!G2Data.isBubbleFinished())
                    {
                        var myDelay:Timer = new Timer(2000, 1);
                        EventManager.addEvent(myDelay, TimerEvent.TIMER, beginTaskPlaceShapeHelper);
                        myDelay.start();
                    }


                }

            }
        }

        public function repeatQuestion(e : Event = null)
        {
            G2Data.repeatQuestion();
        }

        public override function onInstructionsFinished (e:Event)
        {
            if(G2Data.lvl_ClickShape)
                G2Data.taskTimer.start();
        }

        public override function initializeAudio() : KpmSound
        {
            return G2Data.createSound(GameLib.GAME_PLAY, 1, 0.3, true, false);
        }

        public override function onStateChanged(e:Event)
        {

            if(G2Data.State == EState.GOOD_MOVE)
            {
                //G2Data.gameGoal.addMoves(true);
                G2Data.taskXML.@shapeAttempts = negativeScoreCounter;
                if(G2Data.taskXML.children().length() == 1)
                    G2Data.taskXML.@puzzleName = CurrentPuzzle.MovieName;
                G2Data.CurrentTaskSuccess = GameLib.TASK_SUCCESS;

                if(G2Data.lvl_ClickShape || G2Data.lvl_MatchShape || G2Data.lvl_PlaceShape)
                {
                    CurrentShape.dropShadow(false);
                    G2Data.shapeSuccessCounter++;
                    G2Data.stopTaskTimer();
                }

                G2Data.soundLibrary.forceStop();

                //if(G2Data.shapeSuccessCounter == 1)
                if(G2Data.shapeSuccessCounter == CurrentPuzzle.NumTotalShapes)
                {
                    G2Data.soundLibrary.playLibSound(ESoundType.Feedback, EState.GOOD_MOVE, G2Data.Language, null, null, null, GameLib.FEEDBACK_FINISHED);

                    //G2Data.SoundPlayer.pushSound
                    //!!(G2Data.createSound(EState.GOOD_MOVE.Text,3), GameData.FEEDBACK_FINISHED);
                    //G2Data.SoundPlayer.forcePlaySoundFromQueue();

                }
                else
                {
                    G2Data.soundLibrary.playLibSound(ESoundType.Feedback, EState.GOOD_TASK, null, null, null, null, GameLib.FEEDBACK_FINISHED);
                    //!!G2Data.SoundPlayer.stopCurrentSound(false);
                    //G2Data.SoundPlayer.playSound(G2Data.createSound(EState.GOOD_TASK.Text, 3, 1, false, false), GameData.FEEDBACK_FINISHED);
                }


            }

            if(G2Data.State == EState.END_ANIMATION)
            {
                addEventListener(Event.ENTER_FRAME, onAnimationProgress, false, 0 , true);
            }

            if(G2Data.State == EState.BAD_MOVE)
            {
                //G2Data.gameGoal.addMoves(false);
                G2Data.gameGoal.currentMove = G2Data.feedbackSound;


                if(G2Data.lvl_MatchShape || G2Data.lvl_ClickShape)
                    G2Data.CurrentTaskSuccess = GameLib.TASK_FAILURE;

                else if(G2Data.lvl_PlaceShape)
                    failPlaceShape();


                //G2Data.SoundPlayer.stopCurrentSound(false);
                //G2Data.SoundPlayer.pushSound(G2Data.createSound(EState.BAD_MOVE.Text, 1, 0.5, false, false));
                //Try Again!
                G2Data.soundLibrary.forceStop();
                G2Data.soundLibrary.playLibSound(ESoundType.Feedback, EState.BAD_MOVE);
                //G2Data.soundLibrary.playLibSound(ESoundType.Feedback, "Silence1");


                if(needAnimationCounter == 3)
                //G2Data.SoundPlayer.pushSound(G2Data.createSound("HelpPlaceShape", 1));
                    G2Data.soundLibrary.playLibSound(ESoundType.Feedback, "HelpPlaceShape", G2Data.Language, EGame.G2);
                else if(((G2Data.lvl_MatchShape || G2Data.lvl_PlaceShape) && G2Data.feedbackSound == CurrentShape.getShortType())
                        || Util.getRandBtw(0,5) < 1)
                {
                    G2Data.soundLibrary.playLibSound(ESoundType.Feedback, GameLib.TRY_AGAIN, G2Data.Language)
                    //G2Data.SoundPlayer.pushSound(G2Data.createSound(GameData.TRY_AGAIN, 2));

                }
                else
                {
                    G2Data.soundLibrary.playLibSound(ESoundType.FeedbackClick, G2Data.feedbackSound, G2Data.Language);

                    if(G2Data.lvl_ClickColor || G2Data.lvl_ClickShape)
                        G2Data.setInstructions();





    //						//G2Data.SoundPlayer.pushSound(G2Data.createSound(GameData.FEEDBACK_CLICK, 2));
    //						//G2Data.SoundPlayer.pushSound(G2Data.createSound(G2Data.feedbackSound));

    //					}
    //					else
    //					{
    //						if(G2Data.Language == ELanguage.SPA)
    //						{
    //							G1Data.soundLibrary.playLibSound(ESoundType.FeedbackClick, G2Data.feedbackSound, G1Data.Language, null, null, G1Data.Bubble.Name);
    //
    //							//G2Data.SoundPlayer.pushSound(G2Data.createSound(GameData.FEEDBACK_CLICK_ONE+"1"));
    //							//G2Data.SoundPlayer.pushSound(G2Data.createSound(G2Data.feedbackSound+"1", 1, 1, true, true));
    //						}
    //						else
    //						{
    //							if(G2Data.lvl_ClickShape)
    //							{
    //								G2Data.SoundPlayer.pushSound(G2Data.createSound(GameData.FEEDBACK_CLICK, 2));
    //								G2Data.SoundPlayer.pushSound(G2Data.createSound(G2Data.feedbackSound+"0"));
    //							}
    //							else
    //							{
    //								G2Data.SoundPlayer.pushSound(G2Data.createSound(GameData.FEEDBACK_CLICK_ONE+"1"));
    //								G2Data.SoundPlayer.pushSound(G2Data.createSound(G2Data.feedbackSound));
    //
    //							}
    //						}
    //					}

                }


                updateAfterMove();

                //G2Data.SoundPlayer.forcePlaySoundFromQueue();

            }

            Util.debug("feedback ? " + tFeedbackText + " " + G2Data.Feedback);
            tFeedbackText.text = G2Data.Feedback+"";

        }

        public function failPlaceShape()
        {
            if(negativeScoreCounter == 2)
            {
                if(G2Data.lvl_DistractorType == Game2ShapeList.DISTRACTORS_IN_PUZZLE)
                {
                    G2Data.gameGoal.numOptions = CurrentPuzzle.Puzzle.numChildren;
                }
                else
                {
                    if(Util.sameClass(CurrentShape.Movie, chosenShape.Movie))
                    {
                        G2Data.gameGoal.numOptions = CurrentPuzzle.Puzzle.numChildren;
                    }
                    else
                    {
                        G2Data.gameGoal.numOptions = 3;
                    }
                }

                G2Data.CurrentTaskSuccess = GameLib.TASK_FAILURE;
            }
        }

        public function updateAfterMove()
        {

            if(G2Data.lvl_MatchShape || G2Data.lvl_ClickShape || G2Data.lvl_PlaceShape)
            {
                PreviousShape = CurrentShape;

                if(G2Data.State == EState.GOOD_MOVE)
                {
                    Util.debug("removing currentShape" + CurrentShape, this);
                    Util.removeChild(CurrentShape);
                }
                else if (CurrentShape)
                {
                    CurrentShape.attempts++;
                }

                if(needAnimationCounter != 3)
                    CurrentShape = null;
            }


        }


        public override function onFeedbackFinished(e:Event)
        {
            Util.debug(tCurtain.currentLabel, this);
            Util.debug(G2Data.State, this);

            if(G2Data.State == EState.END_ANIMATION)
                return;

            updateAfterMove();

            Util.debug("success " + G2Data.shapeSuccessCounter, this);
            Util.debug("needed " + CurrentPuzzle.NumTotalShapes, this);

            //if(G2Data.shapeSuccessCounter == 1)
            if(G2Data.shapeSuccessCounter == CurrentPuzzle.NumTotalShapes)
                finishBubble();
            else
            {
                if(G2Data.State == EState.GOOD_MOVE)
                {
                    G2Data.resetTask();
                }

                if(G2Data.lvl_ClickShape)
                {
                    Util.debug(G2Data.State.Text, this);
                    Util.debug(G2Data.shapeSuccessCounter+ " " + CurrentPuzzle.NumTotalShapes, this);

                    setRandomGoalFromPuzzle();
                    if(G2Data.gameGoal.quality == EGoal.COLOR)
                        G2Data.gameGoal.numCorrectOptions = CurrentPuzzle.countShapes(G2Data.gameGoal.currentGoal, EGoal.COLOR);
                    else
                        G2Data.gameGoal.numCorrectOptions = CurrentPuzzle.countShapes(G2Data.gameGoal.currentGoal, EGoal.SHAPE);

                    G2Data.gameGoal.numOptions = CurrentPuzzle.Puzzle.numChildren;
                    G2Data.setInstructions();
                    //G2Data.SoundPlayer.forcePlaySoundFromQueue();
                    G2Data.State = EState.INSTRUCTIONS;
                }
                else if (G2Data.lvl_MatchShape)
                {
                    tCurtain.gotoAndPlay("close");
                    shapeMovieList.visible = false;
                }
            }

        }

        public function finishBubble()
        {
            Util.debug("ENDING", this);
            Util.debug("parent width " + parent.width);

            var parentWidth : int = GameLib.driver ? 1280 : 1000;
            var maskSize : Point2D =
                    new Point2D(G2Data.SHAPES_SIZE.x*(parentWidth/G2Data.SCREEN_SIZE.x) - G2Data.options_y,
                            G2Data.SHAPES_SIZE.y*(parent.height/G2Data.SCREEN_SIZE.y) - 96);
            var maskPosition : Point2D;

            if(G2Data.lvl_PlaceShape)
                maskPosition = new Point2D(291*(parentWidth/G2Data.SCREEN_SIZE.x),G2Data.options_y);
            else
                maskPosition = new Point2D(25 ,G2Data.options_y);

            Util.debug("mask position " +  maskPosition + "  size  " + maskSize, this);
            Util.setMask(CurrentPuzzle, new Mask(), maskSize, maskPosition);

            tCurtain.gotoAndPlay("close");
            CurrentPuzzle.Puzzle.gotoAndPlay(2);

            G2Data.State = EState.END_ANIMATION;
        }

        public function onAnimationProgress(e:Event)
        {
            Util.debug(CurrentPuzzle.Puzzle.currentFrame, this);
            if(CurrentPuzzle.Puzzle.currentFrame == CurrentPuzzle.Puzzle.totalFrames)
            {
                Util.debug("updating level", this);
                G2Data.updateTask(3);
                this.removeEventListener(Event.ENTER_FRAME, onAnimationProgress);
            }
        }

        public function setRandomGoalFromPuzzle()
        {
            var dShape		: MovieClip;
            var i , j: uint;
            var selected  : Boolean = false;
            j = 0;

            do
            {
                i = Util.getRandBtw(0, CurrentPuzzle.Puzzle.numChildren-1);
                dShape = CurrentPuzzle.Puzzle.getChildAt(i) as MovieClip;

                //Util.debug("past Goal " + G2Data.gameGoal.pastGoal.Text, this);

                if(G2Data.gameGoal.quality == EGoal.COLOR)
                {
                    //Util.debug("past Goal " + G2Data.gameGoal.pastGoal.Text, this);

                    if(!G2Data.gameGoal.pastGoal || !(dShape.color.equals(G2Data.gameGoal.pastGoal)))
                    {
                        G2Data.CurrentGoal = dShape.color;
                        G2Data.gameGoal.pastGoal = G2Data.gameGoal.currentGoal;
                        selected =  true;
                    }
                    else
                        j++;

                }
                else if(G2Data.gameGoal.quality == EGoal.SHAPE)
                {
                    if(!G2Data.gameGoal.pastGoal || dShape.getShortType().indexOf(G2Data.gameGoal.pastGoal.Text) == -1)
                    {
                        G2Data.CurrentGoal = dShape;
                        G2Data.gameGoal.pastGoal = G2Data.gameGoal.currentGoal;
                        selected =  true;
                    }
                    else
                        j++;

                }
            }
            while (!selected && j < 4);
        }

        public override function blinkSolution()
        {
            var dShape : MovieClip;

            for(var j=0; j < CurrentPuzzle.Puzzle.numChildren; j++)
            {
                dShape = CurrentPuzzle.Puzzle.getChildAt(j)  as MovieClip;
                if(G2Data.gameGoal.quality == EGoal.COLOR
                        && dShape.color.equals(G2Data.gameGoal.currentGoal))
                    dShape.startBlink(GameLib.BLINK_PERIOD, GameLib.NUM_TIMES_BLINK)
                else
                if (G2Data.gameGoal.quality == EGoal.SHAPE &&
                        dShape.Text.indexOf(G2Data.gameGoal.currentGoal.Text) != -1)
                    dShape.startBlink(GameLib.BLINK_PERIOD, GameLib.NUM_TIMES_BLINK)

            }
        }

        public function get Name()
        {
            return EGame.G2;
        }

        public function get G2Data() : Game2Data
        {
            return (mData as Game2Data);
        }

        public override function get Data()
        {
            return (mData as Game2Data);
        }
    }
    }


