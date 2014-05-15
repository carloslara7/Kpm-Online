package com.kpm.common
{	
	
	public class ELanguage
	{
		public var Text :String;
	    {Util.initEnumConstants(ELanguage);} // static ctor

   	    public static const ENG   :ELanguage = new ELanguage();
	    public static const SPA	  :ELanguage = new ELanguage();
		public static const OBI	  :ELanguage = new ELanguage();
		public static const ALL	  :ELanguage = new ELanguage();
		
		public function toString() : String
		{
			return ("[Language : " + Text + "]");
		}
		
	    
	}
}