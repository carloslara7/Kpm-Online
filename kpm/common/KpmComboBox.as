package com.kpm.common
{
	import fl.controls.ComboBox;
	import flash.geom.Point;

	public class KpmComboBox extends fl.controls.ComboBox
	{
		override protected function positionList():void {
			var p:Point = localToGlobal(new Point(0,0));
			list.x = p.x;
			list.y = p.y - list.height;
		}
		
	}
}