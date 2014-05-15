package com.kpm.joinswf
{
	import flash.media.SoundTransform;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Loader;
	import flash.utils.getTimer;
	import flash.system.System;
	import flash.display.Bitmap;
		
	public final class Globals {

		private var lastGCcall:int;
		private static var muteTransform:SoundTransform = new SoundTransform(0.0);
		
		private static var _instance:Globals;
		public static function get instance():Globals{
			if(!_instance){
				_instance = new Globals();
			}
			return _instance;
		}
		
		public function removeDisplayObject(obj:DisplayObject):void{
			trace("REMOVING DisplayObject "+obj);
			if(obj==null) return;
			
			var child:DisplayObject;
			var i:uint;
			
			if(obj.parent) obj.parent.removeChild(obj);
			
			if(obj is DisplayObjectContainer){
				if(obj is MovieClip){
					(obj as MovieClip).stop();
					(obj as MovieClip).soundTransform = muteTransform;
				}
				for (i=0; i< (obj as DisplayObjectContainer).numChildren; i++){
					child = (obj as DisplayObjectContainer).getChildAt(i);
					if(child){
						if(child.parent) {
							child.parent.removeChild(child);
							i--;
						}
						if(child is MovieClip){
							removeDisplayObject((child as DisplayObjectContainer));
						} else if(child is Shape){
							//trace("releasing shape" +child);
							(child as Shape).graphics.clear();
						} else if(child is Bitmap){
							//trace("releasing bitmap" +child);
							//bmd = Bitmap.bitmapData;
							//if(bmd) bmd.dispose();
						} else if(child is Loader){
							Loader(child).unload();
						}
					} else {
						trace("!!!!!!!!!!! "+obj+" "+(obj as DisplayObjectContainer).getChildAt(i));
					}
				}
			} else if(obj is Shape){
				//trace("releasing shape2" +mov);
				(obj as Shape).graphics.clear();
			} 
			var time:int = getTimer();
			if((time - lastGCcall) > 10000) {
				lastGCcall = time;
				System.gc();
				trace("GC---------------------------------------------------------");
			}
		}
	
	}
	
}
