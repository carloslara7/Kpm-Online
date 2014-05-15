package com.kpm.common
{
	public class ENumber
	{
		
  	    public static const zero : ENumber = new ENumber("zero");
   	    public static const one   	: ENumber = new ENumber("one");
	    public static const two	  	: ENumber = new ENumber("two");
	    public static const three	: ENumber = new ENumber("three");
		public static const four	: ENumber = new ENumber("four");	    	    	    
		public static const five	: ENumber = new ENumber("five");
		public static const six		: ENumber = new ENumber("six");
		public static const seven	: ENumber = new ENumber("seven");
		public static const eight	: ENumber = new ENumber("eight");
		public static const nine	: ENumber = new ENumber("nine");
		public static const ten		: ENumber = new ENumber("ten");
		public static const eleven 		: ENumber = new ENumber("eleven");
	    public static const twelve 		: ENumber = new ENumber("twelve");
	    public static const thirteen	: ENumber = new ENumber("thirteen");
		public static const fourteen	: ENumber = new ENumber("fourteen");	    	    	    
		public static const fifteen		: ENumber = new ENumber("fifteen");
		public static const sixteen		: ENumber = new ENumber("sixteen");
		public static const seventeen	: ENumber = new ENumber("seventeen");
		public static const eighteen	: ENumber = new ENumber("eighteen");
		public static const nineteen	: ENumber = new ENumber("nineteen");
		public static const twenty		: ENumber = new ENumber("twenty");
		
		public var englishText : String;
		
		public function ENumber(pEnglish : String)
		{
			englishText = pEnglish;
		}
		
		public function toString() : String
		{
			return ("NUMBER" + Text);
		}
	
		public function get Text() : uint
		{
			switch (this)
			{
				case one 	: return 1; break;
				case two 	: return 2; break;
				case three 	: return 3; break;
				case four 	: return 4; break;
				case five 	: return 5; break;
				
				case six 	: return 6; break;
				case seven 	: return 7; break;
				case eight 	: return 8; break;
				case nine 	: return 9; break;
				case ten 	: return 10; break;
				
				case eleven 	: return 11; break;
				case twelve		: return 12; break;
				case thirteen	: return 13; break;
				case fourteen	: return 14; break;
				case fifteen	: return 15; break;
				
				case sixteen	: return 16; break;
				case seventeen	: return 17; break;
				case eighteen	: return 18; break;
				case nineteen	: return 19; break;
				case twenty	 	: return 20; break;
			}
			
			return 0;
		}	
		
		
		
		public static function getEnum(pNumber : uint) : ENumber
		{
			switch (pNumber)
			{
				case 1 	: return one; break;
				case 2 	: return two; break;
				case 3 	: return three; break;
				case 4 	: return four; break;
				case 5 	: return five; break;
				
				case 6 	: return six; break;
				case 7 	: return seven; break;
				case 8 	: return eight; break;
				case 9 	: return nine; break;
				case 10 : return ten; break;
				
				case 11	: return eleven; break;
				case 12	: return twelve; break;
				case 13	: return thirteen; break;
				case 14	: return fourteen; break;
				case 15 : return fifteen; break;
				
				case 16	: return sixteen; break;
				case 17	: return seventeen; break;
				case 18	: return eighteen; break;
				case 19	: return nineteen; break;
				case 20 : return twenty; break;
			}
			
			return one;
		}	
		
		public function equals(pNumber : ENumber)
		{
			if(Text == pNumber.Text)
				return true;
				
			return false;
		}
	    
	}
}