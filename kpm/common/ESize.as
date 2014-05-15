package com.kpm.common
{
	import com.kpm.common.Util;
	
	public class ESize
	{
	    public var Text :String;
	    {Util.initEnumConstants(ESize);} // static ctor
	
	    public static const Big			: ESize = new ESize();
	    public static const Small		: ESize = new ESize();
	    public static const Medium		: ESize = new ESize();
	    
   	    public function equals(pSize : ESize) : Boolean
   	    {
   	    	if(Text == pSize.Text)
   	    		return true;
   	    	return false;
   	    } 
   	    
   	    public function toString()
   	    {
   	    	return "[Size : " + Text + " ]";
   	    }

	}
}