package com.kpm.games
{	
	import com.kpm.common.Util;

	public class EPuzzle
	{
	    public var Text :String;
	    {Util.initEnumConstants(EPuzzle);} // static ctor
	
	    public static const BicyclePuzzle	:EPuzzle = new EPuzzle();
	    public static const BirdPuzzle		:EPuzzle = new EPuzzle();
	    public static const BoatPuzzle		:EPuzzle = new EPuzzle();
	    public static const BunnyPuzzle		:EPuzzle = new EPuzzle();
   	    public static const ButterflyPuzzle	:EPuzzle = new EPuzzle();
   	    public static const CastlePuzzle	:EPuzzle = new EPuzzle();
	    public static const CatPuzzle		:EPuzzle = new EPuzzle();
	    public static const DogPuzzle		:EPuzzle = new EPuzzle();
	    public static const ElephantPuzzle	:EPuzzle = new EPuzzle();
	    public static const FlowerPuzzle	:EPuzzle = new EPuzzle();	    
	    public static const FoxPuzzle		:EPuzzle = new EPuzzle();
   	    public static const IceCreamPuzzle	:EPuzzle = new EPuzzle();
   	    public static const LadybugPuzzle	:EPuzzle = new EPuzzle();
	    public static const LionPuzzle		:EPuzzle = new EPuzzle();
	    public static const LizardPuzzle	:EPuzzle = new EPuzzle();
	    public static const MousePuzzle		:EPuzzle = new EPuzzle();
	    public static const PandaPuzzle		:EPuzzle = new EPuzzle();	    
	    public static const PearPuzzle		:EPuzzle = new EPuzzle();
   	    public static const PenguinPuzzle	:EPuzzle = new EPuzzle();
   	    public static const PlanePuzzle		:EPuzzle = new EPuzzle();
	    public static const RocketPuzzle	:EPuzzle = new EPuzzle();	    
   	    public static const SealPuzzle		:EPuzzle = new EPuzzle();
   	    public static const TrainPuzzle		:EPuzzle = new EPuzzle();
	    public static const TreePuzzle		:EPuzzle = new EPuzzle();	    	    
	    public static const TurtlePuzzle	:EPuzzle = new EPuzzle();	 
		public static const OwlPuzzle		:EPuzzle = new EPuzzle();	       	    
		public static const ClownPuzzle		:EPuzzle = new EPuzzle();
		public static const BarnPuzzle		:EPuzzle = new EPuzzle();
		public static const HorsePuzzle		:EPuzzle = new EPuzzle();
		public static const AngelFishPuzzle	:EPuzzle = new EPuzzle();
									    
	    public function toString() : String { return "[EPuzzle : " + Text + " ] " } ;
	    public function equals(p : EPuzzle) : Boolean  
	    {
	    	if(Text == p.Text)
	    		return true;
	    		
	    	return false; 
	    }


	    	
	}
}
