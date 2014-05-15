package com.kpm.common
{	
	public class EGoal
	{
		public var Text :String;
	    {Util.initEnumConstants(EGoal);} // static ctor

   	    public static const COLOR  			: EGoal = new EGoal();
   	    public static const SIZE  			: EGoal = new EGoal();
   	    public static const SHAPE	  		: EGoal = new EGoal();
   	    
	    public static const SPATIAL	  		: EGoal = new EGoal();
		public static const ADDITION 		: EGoal = new EGoal();
		
		public static const COMPARISON 		: EGoal = new EGoal();
		
		public static const NUMBER	  		: EGoal = new EGoal();
	    public static const COUNT			: EGoal = new EGoal();
        public static const PLACE_NUMBER			: EGoal = new EGoal();
			    	    	    
		 
		public function toString() : String
		{
			return ("[EGoal : " + Text + "]");
		}
		
	    
	}
}