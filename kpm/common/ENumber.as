package com.kpm.common
{
	public class ENumber
	{
         public static const zero : String = "zero";
         public static const one   	: String ="one";
         public static const two	  	: String ="two";
         public static const three	:  String ="three";
         public static const four	: String = "four";
         public static const five	: String = "five";
         public static const six		: String = "six";
         public static const seven	: String = "seven";
         public static const eight	: String = "eight";
         public static const nine	: String = "nine";

         public static const ten		: String = "ten";
         public static const eleven 		: String = "eleven";
         public static const twelve 		: String = "twelve";
         public static const thirteen	: String = "thirteen";
         public static const fourteen	: String = "fourteen";
         public static const fifteen		: String = "fifteen";
         public static const sixteen		: String = "sixteen";
         public static const seventeen	: String = "seventeen";
         public static const eighteen	: String = "eighteen";
         public static const nineteen	: String = "nineteen";

         public static const twenty		: String = "twenty";
         public static const twentyone : String = "twentyone";
         public static const twentytwo 	: String = "twentytwo";
         public static const twentythree	  	: String = "twentythree";
         public static const twentyfour	: String = "twentyfour";
         public static const twentyfive	: String = "twentyfive";
         public static const twentysix	: String = "twentysix";
         public static const twentyseven		: String = "twentyseven";
        public static const twentyeight	: String = "thirtyeight";
        public static const twentynine	: String = "thirtynine";


        public static const thirty		: String = "thirty";
        public static const thirtyone : String = "thirtyone";
        public static const thirtytwo 	: String = "thirtytwo";
        public static const thirtythree	  	: String = "thirtythree";
        public static const thirtyfour	: String = "thirtyfour";
        public static const thirtyfive	: String = "thirtyfive";
        public static const thirtysix	: String = "thirtysix";
        public static const thirtyseven		: String = "thirtyseven";
        public static const thirtyeight	: String = "thirtyeight";
         public static const thirtynine	: String = "thirtynine";


        public static const numbers : Array =
            ["zero","one","two","three","four","five","six", "seven", "eight","nine",
                "ten","eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen",
                "twenty","twenty-one","twenty-two","twenty-three","twenty-four","twenty-five","twenty-six", "twenty-seven", "twenty-eight","twenty-nine",
                "thirtyone","thirtytwo","thirtythree","thirtyfour","thirtyfive","thirtysix", "thirtyseven", "thirtyeight","thirtynine","forty"]

		public var englishText : String;

		public function ENumber(pEnglish : String)
		{
			englishText = pEnglish;
		}
	    
	}
}

