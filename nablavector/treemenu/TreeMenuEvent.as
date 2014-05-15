package com.nablavector.treemenu{
	import flash.events.Event;
	//Customized event fired as you click on a node.
	//NOTE: the event BUBBLES so you can catch it even in the Main class
	public class TreeMenuEvent extends Event{
		public static const NODE_SELECTED="nodeSelected";
		public var id:String;
		public function TreeMenuEvent(id:String){
			super(NODE_SELECTED,true,true); //Event bubbling: true; cancelabling: true
			this.id=id;//Event payload: id of the clicked node
			trace("TreeMenuEvent fired; id:"+this.id);
		}
	}
}
