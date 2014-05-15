package com.nablavector.treemenu{
	
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
    import com.kpm.common.Util;
	
	public dynamic class TreeMenuItem extends MovieClip
	{
		public function TreeMenuItem(){
			txt.autoSize=TextFieldAutoSize.LEFT; //we want the text to automatically resize depending to the data provided in the xml file
			 //button behaviour 
			this.mouseChildren=false;
			this.buttonMode=true;

		}
	}
}