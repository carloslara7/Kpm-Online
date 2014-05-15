package com.kpm.common
{	
	public class EGame
	{
		private var name;
		
		public static const G1		:	EGame = new EGame("Grid Game");
	    public static const G2		:	EGame = new EGame("Match Game");
	    public static const G3		:	EGame = new EGame("Walk the Walk");
	    public static const G4		:	EGame = new EGame("Branches and Wires");
        public static const G5		:	EGame = new EGame("Birds Place");
	    
	    public function EGame(pName : String)
	    {
	    	name = pName;
	    }
		
		public function get Name () : String 		{ return name ; }
				    
	    public var Text :String;
	    {Util.initEnumConstants(EGame);} // static ctor
	   
	    private static var constList : Array = 
		Util.getConstantsInArray(EGame);
		
		public static function get Consts() : Array 	{ return constList; }
	    
	    
	}
}