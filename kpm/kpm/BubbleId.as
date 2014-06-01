package com.kpm.kpm 
{	
	import com.kpm.common.EGame;
	import com.kpm.common.Util;
	import com.kpm.common.GameLib;
	
	public class BubbleId
	{
		private var bubbleName 		: EBName;
		private var level			: int;
		private var totalTasks		: uint = 0;
		private var counter			: uint = 0;
		static var globalCounter	: uint = 0;
		
		
		public function BubbleId(pName : EBName, pLevel : int)
		{
			bubbleName = pName;
			level = pLevel;
			
			//if(pLevel > pName.MaxLevel || pLevel < pName.MinLevel)
			//	GameData.reportError("bubble id not recognized " + pName.Text + "_" + pLevel);
			
			
			counter = globalCounter;
			globalCounter++;


		}
		
		public function equalsString(pString : String) : Boolean
		{
			if(Text == pString)
				return true;
			else
				return false;		
		}
		
		public function equals(pId : Object) : Boolean
		{
			
			if(pId is String)
			{
				//Util.debug("comparing " + Text  + " to " + pId, this);
				if(Text == pId)
					return true;
			}
			else if (pId is BubbleId)
			{
				//Util.debug("comparing " + Text  + " to " + pId.Text, this);
				if(Text == pId.Text)
					return true;
			}
			
			return false;		
		}
		
		static function makeBIdFromString(pBubbleStr : String) : BubbleId
		{
			var bIdArray : Array = pBubbleStr.split("_");
			var name : String;
			var level : int;
			
			if(bIdArray.length == 3)
			{
				name = bIdArray[0] + "_" + bIdArray[1];
				level = Number(bIdArray[2]);
			}
			if(bIdArray.length == 2)
			{
				name = bIdArray[0];
				level = Number(bIdArray[1]);
			}
			
			Util.debug("making bubble " + name);
			
			if(EBName[name] == null)
				GameLib.reportError("EBName " + name + " is not a bubble name");
			return new BubbleId(EBName[name], level);
			
		}
		
		public function get Text()
		{
			return (bubbleName.Text + "_" + level);
		}
		
		public function toString()
		{
			return ("[ id : " + Text + " ]");
		}
		
		
		public function get Level()					{ return level; }
		public function set Level(pLevel : uint)	{ level = pLevel; }
		
		public function get Counter () : uint		{ return counter; }
		public function set Counter(pCounter : uint) { counter = pCounter;}
		public function get Name()	 : EBName  { return bubbleName; }
		
		
		public function set TotalTasks(pT : uint)	{ totalTasks = pT; }
		public function get TotalTasks()			{ return totalTasks; }
		
			
	}
}