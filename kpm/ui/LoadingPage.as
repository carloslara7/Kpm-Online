package kpm.ui
{
	import com.kpm.ui.UIPage;
	import flash.display.MovieClip;

	public class LoadingPage extends UIPage
	{
		public function LoadingPage(pClassName:String, pPage_mc:MovieClip=null, pX:Number=0, pY:Number=0)
		{
			super(pClassName, pPage_mc, pX, pY);
		}
		
		public function deactivate()
		{
		
		}
		
	}
}