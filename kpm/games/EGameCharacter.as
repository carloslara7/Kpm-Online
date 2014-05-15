package com.kpm.games 
{	
	import com.kpm.common.Util;
	
	public class EGameCharacter
	{
		public var Text :String;
	    {Util.initEnumConstants(EGameCharacter);} // static ctor
	    
	    public static const Frog		: EGameCharacter = new EGameCharacter();
		public static const Animal		: EGameCharacter = new EGameCharacter();
	    public static const Bee			: EGameCharacter = new EGameCharacter();
   	    public static const Mouse		: EGameCharacter = new EGameCharacter();
		public static const Monkey	: EGameCharacter = new EGameCharacter();
		public static const Bird	: EGameCharacter = new EGameCharacter();

		
		public static const Fly			: EGameCharacter = new EGameCharacter();
	    public static const LilyPad		: EGameCharacter = new EGameCharacter();
	    public static const Flower		: EGameCharacter = new EGameCharacter();
	    public static const Cheese		: EGameCharacter = new EGameCharacter();
	    public static const Lake		: EGameCharacter = new EGameCharacter();		    
	    public static const Stone		: EGameCharacter = new EGameCharacter();		    
	    public static const Hole		: EGameCharacter = new EGameCharacter();		
	    public static const Trap		: EGameCharacter = new EGameCharacter();		
	    public static const FlyTrap1	: EGameCharacter = new EGameCharacter();
	    public static const FlyTrap2	: EGameCharacter = new EGameCharacter();
	    public static const BugSpray1	: EGameCharacter = new EGameCharacter();
	    public static const BugSpray2	: EGameCharacter = new EGameCharacter();
        public static const ALL     	: EGameCharacter = new EGameCharacter();
	    
	     
		public function toString() : String
		{
			return ("[Character : " + Text + "]");
		}
		
		public function equals(pString : String) : Boolean
		{
			if(Text == pString)
				return true;
			else
				return false;		
		}		
	}
}