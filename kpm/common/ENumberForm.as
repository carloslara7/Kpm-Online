package com.kpm.common
{
	import com.kpm.kpm.BubbleId;
	import com.kpm.kpm.EBName;
		
	public class ENumberForm
	{
	    public var Text :String;
	    {Util.initEnumConstants(ENumberForm);} // static ctor
	
	    public static const Finger		:ENumberForm = new ENumberForm();
	    public static const FiveFrame	:ENumberForm = new ENumberForm();
	    public static const Numeral		:ENumberForm = new ENumberForm();
		public static const DiceDots	:ENumberForm = new ENumberForm();	    
		
   	    public function equals(pForm : ENumberForm) : Boolean
   	    {
   	    	if(Text == pForm.Text)
   	    		return true;
   	    	return false;
   	    } 

		public static function generateSimilarBubble(pBubbleId : BubbleId, pNumberForm : ENumberForm) : BubbleId
		{
			var bname : String = pBubbleId.Name.Text;
			var level : int = pBubbleId.Level;
			
			var numberFormString : String = ENumberForm.getNumberForm(bname);
			
			Util.debug("generateBubble");
			Util.debug("bname" + bname);
			bname.split(numberFormString).join(pNumberForm.Text);
			Util.debug("bname" + bname);
			
			return new BubbleId(EBName[bname], level);
			
			
			
		}
				
		public static function getNumberForm(pName : String)
		{
			var indexFirstUnderscore : int = pName.indexOf("_");
			var numberForm : String = pName.slice(6,indexFirstUnderscore);
			
			Util.debug("get number form " + numberForm);
			
			return numberForm;	
		}

	
	}
}