package com.kpm.kpm 
{	
	import com.kpm.common.Util;
	
	public class EBScoreType
	{
		public var Text :String;
	    {Util.initEnumConstants(EBScoreType);} // static ctor
	    
	    public static const Choice		: EBScoreType = new EBScoreType();
	    public static const Path		: EBScoreType = new EBScoreType();
	    public static const Proximity	: EBScoreType = new EBScoreType();
	    
	    	
	    	
		public function toString() : String
		{
			return ("[BubbleScoreType : " + Text + "]");
		}
	}
}