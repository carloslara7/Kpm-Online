package com.kpm.common
{
	import com.kpm.common.Util;
	
	public class EColor
	{
	    public var Text :String;
	    {Util.initEnumConstants(EColor);} // static ctor
	
	    public static const Red			: EColor = new EColor();
	    public static const Blue		: EColor = new EColor();
	    public static const Yellow		: EColor = new EColor();
	    public static const Green		: EColor = new EColor();
   	    public static const Orange		: EColor = new EColor();
		
		public static const Grey		: EColor = new EColor();
		public static const Purple		: EColor = new EColor();
		public static const Brown		: EColor = new EColor();
   	    public static const Black		: EColor = new EColor();
        public static const BlueGray	: EColor = new EColor();
   	    
   	    public function equals(pColor : EColor) : Boolean
   	    {
   	    	if(Text == pColor.Text)
   	    		return true;
   	    	return false;
   	    } 
   	    
   	    public function toString()
   	    {
   	    	return "[Color : " + Text + " ]";
   	    }

	}
}