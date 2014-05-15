package com.kpm.kpm
{	
	import com.kpm.common.Util;
	
	public class EBStatus
	{
		public var Text :String;
	    {Util.initEnumConstants(EBStatus);} // static ctor
	    
	    public static const Enjoy   		:EBStatus = new EBStatus();
		public static const NotComplete		:EBStatus = new EBStatus();
	    public static const Failed   		:EBStatus = new EBStatus();
	    public static const Passed			:EBStatus = new EBStatus();
	    public static const NotPlayed		:EBStatus = new EBStatus();

	    		
	    public function toString() : String
	    {
	    	return Text;	
	    }
	}
}