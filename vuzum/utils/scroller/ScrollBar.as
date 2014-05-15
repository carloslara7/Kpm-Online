package com.vuzum.utils.scroller
{
	import com.caurina.transitions.*;
	
	import flash.display.*;
	import flash.events.*;

	public class ScrollBar extends MovieClip
	{
		// COMPONENTS INSIDE
		public var mcTrack : MovieClip;
		public var mcScrub : MovieClip;
		public var mcBack : MovieClip;
		public var mcStroke : MovieClip;
		
		// HANDLERS VARS
		private var currPressedObject : MovieClip;
		
		// INTERNAL MEMBERS
		private var mcContent : MovieClip;
		private var mcMask : MovieClip;
		//
		private var posProperty : String;
		private var dimProperty : String;
		//
		public var xMin : Number;
		public var yMin : Number;
		public var xMax : Number;
		public var yMax : Number;
						
		// SETTINGS VARS
		private var isVertical : Boolean = false;
		public var offset : Number = 1;
		private var mouseWheelFlag : Boolean;
		private var updateFunction : Function;
		public var releaseExtFunction : Function; 
		//
		private var scrubOverTweenTime : Number = 0.2;
		private var scrubOverAlpha : Number = .7;
		private var scrubNormalAlpha : Number = 1;
		private var tweenTime : Number = .5;
		
		// AUX VARS
		
		

		// CONSTRUCTOR
		public function ScrollBar()
		{
			mcScrub.visible = false;
			mcScrub.cacheAsBitmap = true;
			//mcScrub.mcIcon.visible = false;
		}
		
		/**
		 * bounds the scroller to a content
		 */
		public function init(pMcContent : MovieClip, pMcMask : MovieClip, pOffset : Number = NaN, pIsVertical : Boolean = false, pMouseWheel : Boolean = true, pChange : Boolean = true, 
							 pStrokeColor : Number = NaN, pBackColor : Number = NaN, pTrackColor : Number = NaN, pScrubColor : Number = NaN, pScrubIconColor : Number = NaN) : void
		{
			// read parameters
			mcContent = pMcContent;
			mcMask = pMcMask;
			mcContent.mask = mcMask;
			if(!isNaN(pOffset)) offset = pOffset;
			mouseWheelFlag = pMouseWheel;
			
			// set the colors
			setColors(pStrokeColor, pBackColor, pTrackColor, pScrubColor, pScrubIconColor);
			
			// decide what's the direction
			isVertical = pIsVertical;
            posProperty = (isVertical ? "y" : "x");
            dimProperty = (isVertical ? "height" : "width");
            
            // rotate the icon inside the scrub
            if(isVertical)
            {
            	mcScrub.mcIcon.mcIcon.rotation = 90;
            	mcScrub.mcIcon.mcIcon.x = mcScrub.mcIcon.mcIcon.width;
            	//
            	mcScrub.mcBack.mcBack.rotation = 90;
            	mcScrub.mcBack.mcBack.x = mcScrub.mcBack.mcBack.width;            	 
            }		
			
			// init scrub
			mcScrub.mouseChildren = false;
			//centrateScrub(offset, 0);// move the scrub to the initial pos
			mcScrub.visible = false;
			mcScrub.alpha = scrubNormalAlpha;

			// init trackpad
//			mcTrack.buttonMode = false;
			
			// parent mouse wheel event handler
			if(mouseWheelFlag) stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			// resize scroll bar if is the case
			if(pChange)
			{
				if(isVertical) resize(-1, mcMask.height);
				else resize(mcMask.width, -1);
			}
		}
		
		private function setColors(pStrokeColor : Number = NaN, pBackColor : Number = NaN, pTrackColor : Number = NaN, pScrubColor : Number = NaN, pScrubIconColor : Number = NaN) : void
		{
			mcStroke.setColor(pStrokeColor);
			mcBack.setColor(pBackColor);
			//mcTrack.setColor(pTrackColor);
			mcScrub.mcBack.setColor(pScrubColor);
			mcScrub.mcIcon.setColor(pScrubIconColor);
		}

		/**
		 * resizes the scroller
		 */
		public function resize(pWidth : Number = 0, pHeight : Number = 0) : void
		{
			// calculate the width and height
			pWidth = (pWidth > 0 ? pWidth : mcBack.width);
			pHeight = (pHeight > 0 ? pHeight : mcBack.height);			
			
			// resize the BACKGROUND
			mcBack.width = pWidth;
			mcBack.height = pHeight;
			//
			mcStroke.width = mcBack.width;// - (!isVertical ? 1 : 0);
			mcStroke.height = mcBack.height;// - (!isVertical ? 1 : 0);
			
			// resize TRACK
			mcTrack.width = pWidth;// - 2 * offset;
			mcTrack.height = pHeight - 2 * offset;
			// centrate TRACK
			mcTrack.centerOn(pWidth, pHeight);
			
			// resize SCRUB
			mcScrub.mcBack.width = pWidth - 2 * offset; 
			mcScrub.mcBack.height = mcTrack.height;
			// centrate icon in scrub
			mcScrub.mcIcon.centerOn(mcScrub.mcBack.width, mcScrub.mcBack.height);
			mcScrub.mcIcon.x = Math.ceil(mcScrub.mcIcon.x);
			mcScrub.mcIcon.y = Math.ceil(mcScrub.mcIcon.y);
			// init min
			mcScrub.x = xMin = offset; 
			mcScrub.y = yMin = offset;
			
			// UPDATE THE SCROLL DIMENSION depending on the new dimensions
			update();
		}
		
		/*
		 * updates the scrollbar width / height depending on the new changes appeared meanwhile
		 */
		public function update() : void
		{
			var tempVar : Number;
			var tweenTime : Number = .5;
			
			if(mcContent)
			{
				if(isVertical)
				{
					if(mcContent.height > mcMask.height)
					{
						mcScrub.visible = true;
						mcTrack.buttonMode = true;
						
						tempVar = (mcTrack.height * mcMask.height) / mcContent.height;
						
						if(tempVar < 10) tempVar = 10;
						Tweener.addTween(mcScrub.mcBack, {height: tempVar, time : tweenTime, transition : "easeOutExpo"});
						
						Tweener.addTween(mcScrub.mcIcon, {y: Math.round((tempVar - mcScrub.mcIcon.height)/2), time : tweenTime, transition : "easeOutExpo"});
						yMax = mcTrack.y + mcTrack.height - tempVar; 
						
						if(tempVar < mcScrub.mcIcon.height) mcScrub.mcIcon.visible = false;
						else mcScrub.mcIcon.visible = true;
					}
					else Tweener.addTween(mcScrub.mcBack, {height: mcTrack.height, time : tweenTime, transition : "easeOutExpo"});
				}
				else
				{
					if(mcContent.width > mcMask.width)
					{
						mcScrub.visible = true;
						mcTrack.buttonMode = true;
						
						tempVar = (mcTrack.width * mcMask.width) / mcContent.width;
						if(tempVar < 10) tempVar = 10;
						
						Tweener.addTween(mcScrub.mcBack, {width: tempVar, time : tweenTime, transition : "easeOutExpo"});
						
						Tweener.addTween(mcScrub.mcIcon, {x: Math.round((tempVar - mcScrub.mcIcon.width)/2), time : tweenTime, transition : "easeOutExpo"});
						xMax = mcTrack.x + mcTrack.width - tempVar; 
						
						if(tempVar < mcScrub.mcIcon.width) mcScrub.mcIcon.visible = false;
						else mcScrub.mcIcon.visible = true;
					}
					else Tweener.addTween(mcScrub.mcBack, {width: mcTrack.width, time : tweenTime, transition : "easeOutExpo"});
				}	
			
				
				// enable / disable the scrollbar			
				if(mcContent[dimProperty] < mcMask[dimProperty]) disable();
				else enable();
			
			}
			
		}
		
		
		
		/**
		 * disables the scroller
		 */
		public function disable() : void
		{
			// change alpha
			this.alpha = 0.5;
						
			// init scrub
			mcScrub[posProperty] = this[posProperty+"Min"];
			mcScrub.alpha = scrubNormalAlpha;
			
			// remove events from SCRUB
			mcScrub.removeEvents(this);						
			
			// remove events from TRACK
			mcTrack.removeEvents(this);			
			
			// remove MOUSE WHEEL listener
			if(mouseWheelFlag) stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
//			if(mouseWheelFlag) this.parent.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}		
		
		/**
		 * enables the scroller
		 */
		public function enable() : void
		{
			// change alpha
			this.alpha = 1;
			
			// add events from SCRUB
			mcScrub.addEvents(this);
			
			// add events from TRACK
			mcTrack.addEvents(this);			
			
			// remove the MOUSE WHEEL listener
			if(mouseWheelFlag) stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
//			if(mouseWheelFlag) this.parent.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}		
		
		/*
		* moves the scrub when the content is moved
		*/
        public function updateScrub(contentPosition : Number=NaN, pTweenTime : Number=NaN) : void
        {
        	// calculate the content position
            contentPosition = (isNaN(contentPosition) ? mcContent[posProperty] : contentPosition);
            
            // move the scrub depending the content position
            var tweenObject : Object = new Object();
            tweenObject[posProperty] = this[posProperty + "Max"] * ( (mcMask[posProperty] - contentPosition) / (mcContent[dimProperty] - mcMask[dimProperty]) );
            if(tweenObject[posProperty] > this[posProperty + "Max"]) tweenObject[posProperty] = this[posProperty + "Max"];
            if(tweenObject[posProperty] < this[posProperty + "Min"]) tweenObject[posProperty] = this[posProperty + "Min"];
            tweenObject.time = (!isNaN(pTweenTime) ? pTweenTime : tweenTime);
//			tweenObject.transition = "easeOutExpo";
            Tweener.addTween(mcScrub, tweenObject);
        }
		
		/**
		 * dispatches the moves of the scrub
		 */
		public function sbChange(pProcent : Number=NaN, pTime : Number = NaN) : void
		{
			var goTo : Number;
			var procent : Number = pProcent;
			var tweenTime : Number = !isNaN(pTime) ? pTime : 1;
			
			// call the oposite of the release external function
			if(releaseExtFunction != null) releaseExtFunction(false);
			//mcBack.ttrace("START");	

			// move the content
			if(isVertical)
			{
				goTo = mcMask.y - procent * (mcContent.height - mcMask.height);
				if(goTo + mcContent.height < mcMask.y + mcMask.height) goTo = mcMask.y + mcMask.height - mcContent.height;
				if(goTo > mcMask.y) goTo = mcMask.y;				
			}
			else
			{
				goTo = mcMask.x - procent * (mcContent.width - mcMask.width);
				if(goTo + mcContent.width < mcMask.x + mcMask.width) goTo = mcMask.x + mcMask.width - mcContent.width;
				if(goTo > mcMask.x) goTo = mcMask.x;
			}
            var tweenObject : Object = new Object();
            tweenObject[posProperty] = goTo;
            tweenObject.time = tweenTime;            
            tweenObject.onUpdate = function() : void 
            {
            	if(updateFunction != null) updateFunction();
            };
            // call the external release function after the tween is done
            tweenObject.onComplete = function() : void 
            {
            	if(releaseExtFunction != null) releaseExtFunction();
				//mcBack.ttrace("COMPLETE");
            };
            Tweener.addTween(mcContent, tweenObject);			
		}

		/**
		 * OVER EVENT HANDLER
		 */
		public function overHandler(e : MouseEvent):void
		{
			//mcBack.ttrace("OVER:", e.currentTarget.name);
			// make the action
			switch(e.currentTarget)
			{
				case mcTrack:
				case mcScrub:
					overFunction();
					break;
			}
		}
		
		/**
		 * OUT EVENT HANDLER
		 */
		public function outHandler(e : MouseEvent):void
		{
			// make the action
			switch(e.currentTarget)
			{
				case mcTrack:
				case mcScrub:
					overFunction(false);
					break;
			}
		}
		public function overFunction(flag : Boolean = true) : void
		{
			if(flag) Tweener.addTween(mcScrub, {alpha: scrubOverAlpha, time: scrubOverTweenTime, transition: "easeOutQuad"});
			else if(!mcScrub.pressed) Tweener.addTween(mcScrub, {alpha: scrubNormalAlpha, time: scrubOverTweenTime, transition: "easeOutQuad"});	
		}				

		/**
		 * PRESS EVENT HANDLER
		 */
		public function pressHandler(e : MouseEvent):void
		{
			//mcBack.ttrace("PRESS");
			// retain the pressed object
			currPressedObject = e.currentTarget as MovieClip;
			
			// change the status
			currPressedObject.pressed = true;			
			
			// make the action
			switch(currPressedObject)
			{
				case mcScrub:
				case mcTrack:
					// change status
					mcScrub.pressed = true;
					
					// start mouse move listener
					scrubMoveHandler();
					stage.addEventListener(MouseEvent.MOUSE_MOVE, scrubMoveHandler);
					break;
			}
			
			// add the release outside event handlers
			stage.addEventListener(MouseEvent.MOUSE_UP, releaseOutsideHandler);
			stage.addEventListener(Event.MOUSE_LEAVE, releaseOutsideHandler);	        
		}

		/**
		 * RELEASE OUTSIDE EVENT HANDLER FOR
		 */
		public function releaseOutsideHandler(event : Event) : void 
		{
			// remove the release outside event handlers
			stage.removeEventListener(MouseEvent.MOUSE_UP, releaseOutsideHandler);
			stage.removeEventListener(Event.MOUSE_LEAVE, releaseOutsideHandler);
			
			// make action for the current pressed object if needed
			switch(currPressedObject)
			{
				case mcScrub:
				case mcTrack:
					// call release function
					releaseFunction(currPressedObject);
					
					// make out handler for the scrub
					overFunction(false);					
					break;
			}
		}
		
		/**
		 * RELEASE EVENT HANDLER
		 */
		public function releaseHandler(e : MouseEvent) : void
		{
			var mc : MovieClip = e.currentTarget as MovieClip;
			if(mc == currPressedObject) releaseFunction(mc);
		}
		private function releaseFunction(mc : MovieClip) : void
		{
			// change the status
			mc.pressed = false;
			
			switch(mc)
			{
				case mcScrub:
				case mcTrack:
					// change status
					mcScrub.pressed = false;
					
					// stop the event listener				
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, scrubMoveHandler);
					break;				
			}
		}		
		public function set setUpdateFunction(value : Function) : void
		{
			updateFunction = value;
		}

		public function set setReleaseFunction(value : Function) : void
		{
			releaseExtFunction = value;
		}
		
		/**
		 * MOUSE MOVE EVENT HANDLER
		 */
		public function scrubMoveHandler(event : MouseEvent=null):void
		{
			centrateScrub();
			if(event != null) event.updateAfterEvent();
		}
		
		/*
		 * centrates the scrub on mouseY
		 */
		public function centrateScrub(mousePosition : Number = NaN, pTime : Number = NaN) : void
		{
			var goTo : Number;
			var tweenTime : Number = 0.2;
			if(!isNaN(pTime)) tweenTime = pTime;
			
			// move the scrub
			if(isVertical)
			{
				if(isNaN(mousePosition)) mousePosition = mouseY - mcScrub.mcBack.height / 2;
				
				goTo = mousePosition;
				goTo = Math.round(goTo);
				
				if(goTo < yMin) goTo = yMin;
				if(goTo > yMax) goTo = yMax;
				
				Tweener.addTween(mcScrub, {y: goTo, time : tweenTime});
			}
			else
			{
				if(isNaN(mousePosition)) mousePosition = mouseX - mcScrub.mcBack.width / 2;
				
				goTo = mousePosition;
				goTo = Math.round(goTo);
				
				if(goTo < xMin) goTo = xMin;
				if(goTo > xMax) goTo = xMax;
				
				Tweener.addTween(mcScrub, {x: goTo, time : tweenTime});
			}
			
			// move the content depending on the scrub
			var procent : Number = (goTo - offset) / ((isVertical ? yMax : xMax) - offset); //trace(goTo, xMax, procent);
			sbChange(procent, (isNaN(pTime) ? 1 : tweenTime));
		}
		
		
		/**
		 * Calls when the Mouse Wheel is moved
		 */
	    public function onMouseWheel(e : MouseEvent) : void
	    {
	    	var delta : Number = e.delta;
			//if(mcMask.hitTestPoint(stage.mouseX, stage.mouseY) || this.hitTestPoint(stage.mouseX, stage.mouseY))
			if(MovieClip(this.parent).mcBack.hitTestPoint(stage.mouseX, stage.mouseY))
	    	{
    			mcScrub[posProperty] -= delta;	    		
    			if(mcScrub[posProperty] < this[posProperty + "Min"]) mcScrub[posProperty] = this[posProperty + "Min"];
    			if(mcScrub[posProperty] > this[posProperty + "Max"]) mcScrub[posProperty] = this[posProperty + "Max"];
				
				var procent : Number = (mcScrub[posProperty] - offset) / (this[posProperty + "Max"] - offset);
				sbChange(procent);
	    	}
	    }
	    
	    
	    
	    		
	}// FROM CALSS
}// FROM PACKAGE
