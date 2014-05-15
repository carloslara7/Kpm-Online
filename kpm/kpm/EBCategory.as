package com.kpm.kpm
{
	import com.kpm.common.Util;
	
	public class EBCategory
	{
		private var index : uint ;
	
		public static const NumbersAndOperation	 	: EBCategory = new EBCategory(0, "Numbers and Operations");
		public static const GeometryAndSpatialSense	: EBCategory = new EBCategory(1, "Geometry and Spatial Sense");
	    public static const DataAndMeasurements		: EBCategory = new EBCategory(2, "Data And Measurements");
		
		public static var Consts : Array = 
		Util.getConstantsInArray(EBCategory);
		
		public var Text :String;
	    
		public function EBCategory(pIndex : int, pName : String)
		{
			index = pIndex;
			Text = pName;	
		}
		
		public function get Index() : Number
		{
			return index;
		}

	}
}