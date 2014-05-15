package com.kpm.common
{
    import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Mouse;

    public class CursorManager
    {
        private static var _cursor		: MovieClip;
        private static var _xOffset		: Number;
        private static var _yOffset		: Number;
        private static var _root		: Stage;
       
        public function CursorManager():void
        {
            throw new Error("no need to call constructor, use static methods CursorManager.init(), CursorManager.setCursor(),CursorManager.removeCursor(),CursorManager.destroy() " );
        }
        /**
         * sets stage path
         * @param   pRoot
         */
        public static function init(pRoot:Stage):void
        {
            _root = pRoot;
        }
        /**
         *  sets display object as cursor ( removes prev cursor automatically)
         * @param   pCursor  new cursor
         * @param   pXoffset x offset from mouse position
         * @param   pYoffset y offset from mouse position
         */
        public static function setCursor(pCursor:MovieClip, pXoffset:Number = 0, pYoffset:Number = 0):void
        {
            if (!_root)
            {
                throw new Error("set root using init(pRoot)");
            }
            if (_cursor)
            {
                removeCursor();
            }
            
			//Mouse.hide();
            _cursor = pCursor;
            if (_cursor is InteractiveObject)
            {
                InteractiveObject(_cursor).mouseEnabled = false;
                if (_cursor is DisplayObjectContainer)
                {
                    DisplayObjectContainer(_cursor).mouseChildren = false;
                }
            }
           
            _xOffset = pXoffset;
            _yOffset = pYoffset;
            _cursor.x = _root.mouseX + _xOffset;
            _cursor.y = _root.mouseY + _yOffset;
            _root.addChild(_cursor);
            _root.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0 , true);
           
        }
        /**
         * update cursor position
         * @param   e
         */
        private static function onMouseMove(e:MouseEvent):void
        {
            _cursor.x = _root.mouseX + _xOffset;
            _cursor.y = _root.mouseY + _yOffset;
			//Mouse.hide();
            e.updateAfterEvent();

        }
        /**
         * brings cursor on top of display list in case u add another displayobjext on stage
         */
        public static function bringToFront(e : Event):void
        {
            if (_cursor)
            {
                _root.addChild(_cursor);
            }
        }

		public static function setOverCursor(e : Event): void
		{
			if(_cursor)
			{
				_cursor.gotoAndStop("over");
			}
		}
		
		public static function setIdleCursor(e : Event): void
		{
			if(_cursor)
			{
				_cursor.gotoAndStop("idle");
			}
		}
		
		public static function hide(e : Event): void
		{
			if(_cursor)
			{
				_cursor.visible = false;
			}
		}
		
		public static function show(e : Event): void
		{
			if(_cursor)
			{
				_cursor.visible = true;
			}
		}
		
		
        /**
         * removes cursor created by last setCursor() method, resotres original system cursor
         */
        public static function removeCursor():void
        {
           
            if (!_cursor)
            {
                return;
            }
            _root.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            _root.removeChild(_cursor);
            _cursor = null;
            //Mouse.show();
           
        }

		public static function addOverEvents(pTargetMc : DisplayObject)
		{
			
			
			if(!pTargetMc)
				return;
				
			if(pTargetMc is MovieClip)
				(pTargetMc as MovieClip).buttonMode = true;
			
			if(!_root)
				return;
				
			EventManager.addEvent(pTargetMc, MouseEvent.ROLL_OVER, CursorManager.setOverCursor)
			EventManager.addEvent(pTargetMc, MouseEvent.ROLL_OUT, CursorManager.setIdleCursor)
		}
		
		public static function removeOverEvents(pTargetMc : DisplayObject)
		{
			EventManager.removeEvent(pTargetMc, MouseEvent.ROLL_OVER)
			EventManager.removeEvent(pTargetMc, MouseEvent.ROLL_OUT)
		}
		
		
        /**
         * works exactly same way as removeCursor()
         */
        public static function destroy():void
        {
            if (_cursor)
            {
                removeCursor();
            }
        }
       
    }
   
}