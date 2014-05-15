package com.kpm.games
{
	import com.kpm.common.Util;
	
	public class EState
	{
		
	    public var Text :String;
	    {Util.initEnumConstants(EState);} // static ctor
	
	    public static const NEW_GAME		:EState = new EState();
	    public static const INSTRUCTIONS	:EState = new EState();
	    public static const GOOD_MOVE		:EState = new EState();
	    public static const BAD_MOVE		:EState = new EState();
   	    public static const OK_MOVE			:EState = new EState();
   	    public static const PASS_FLY		:EState = new EState();
	    public static const COLLISION		:EState = new EState();
	    public static const OUT_OF_BOUNDS	:EState = new EState();
	    public static const INVALID_MOVE	:EState = new EState();	    
   	    public static const IDLE			:EState = new EState();
   	    public static const END_ANIMATION	:EState = new EState();
	    public static const OUT_OF_MOVES	:EState = new EState();
	    public static const TOO_MANY_ATTEMPTS:EState = new EState();
	    public static const GOOD_TASK		:EState = new EState();
	    
	    public function toString() : String
		{
			return "[State : " + Text + " ]";
		}
	}
}