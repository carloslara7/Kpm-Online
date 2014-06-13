package com.kpm.common
{
	import com.kpm.common.Util;

	public class Goal
	{
		
		public var quality				: EGoal;	//COUNT, ADDITION
		//for some bubbles like subset (how many green/big monkeys do you see)		
		public var subquality 			: EGoal;	//SIZE, COLOR
		
		//number of correct options the user is given among the number of options 
		public var numOptions 			: uint;
		public var numCorrectOptions	: uint;
		
		//currentGoal can be a string, a number, a movieclip
		public var currentGoal			: Object;
				
		//currentGoalText is the Texual representation
		public var currentGoalText		: String;
		
		//currentMove is text for when the user clicks on a wrong answer
		public var currentMove			: String;
		
		public var globalScore			: Number = 0;
		public var taskScore			: Number = 0;
		public var currentQuality		: Object;		
		public var pastGoals			: Array;
		public var pastQualities		: Array;
		public var pastGoal				: Object;
		public var pastpastGoal 		: Object;
		public var attemptCounter		: uint;
		public var backtrackCounter		: uint;
		public var taskCounter			: uint;
		public var succededTaskCounter  : uint;
		public var totalTasks			: uint;
		public var timeFirstMove		: Number;
		public var correctTargetIndex	: int;
		public var differentGoals		: Boolean;
		public var writtenPrompt		: String;
		public var achievedGoals		: Array;
		public var allGoals				: Array;
		public var lengthPath			: int;
		public var lengthOptimalPath	: int;
		public var distanceFromTarget	: int;
		
		//Count Variables
			
		//Count variables
		public var maxNumGoals				: uint;
		public var maxNumNonGoals			: uint;
		
		public function Goal(pTotalTasks, pGoal : EGoal = null) 
		{
			var tempGoal : Object;
			quality = pGoal;
			allGoals = new Array();
			achievedGoals = new Array();
			totalTasks = pTotalTasks;
			succededTaskCounter = taskCounter = attemptCounter = distanceFromTarget = backtrackCounter = timeFirstMove = 0;


            Util.printArray([ "TotalTasks",totalTasks, "Goal ", pGoal],"new Goal");
            allGoals.push(tempGoal);
		}
	
		public function answerEndsTask() : Boolean
		{
			if(taskCounter == totalTasks-1)
			{
				//Util.debug(" success " + goalCounter + " " + totalSuccess, this);
				return true;
			}
			
			return false;
		}
		
		public function taskCompleted(pSuccess : uint)
		{
			taskCounter++;
			attemptCounter = 0;
			backtrackCounter = 0;
			
			if(pSuccess == 1) 
			{	
				if(differentGoals)
				{
					achievedGoals.push(currentGoal);
				}
			}
		}
				
		public function toString() : String
		{
			//Util.printArray(allGoals);
			return ("[Goal : quality= " + quality + ", total tasks =" + totalTasks + ", taskScore " + taskScore + ", globalScore " + globalScore + "]");
			
		}
	}
}