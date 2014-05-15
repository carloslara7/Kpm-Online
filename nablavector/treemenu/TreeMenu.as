package com.nablavector.treemenu{
	import com.caurina.transitions.Tweener;
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	
	public class TreeMenu extends MovieClip
	{
		//***********************************
		// PARAMETERS FOR BASIC CUSTOMIZATION
		//***********************************
		private static var FILENAME:String = "menu.xml"; //<- path of xml file for composing the menu
		private static var STEPY:Number=37; //<- height of every menu item
		private static var STEPX:Number=50; //<- Width offset for every menu level referred to the previous level's _x position
		private static var useScale:Boolean=true; //<- if set to on, every menu item scales down consindering its position in the xml tree
		//**************************************		
		private var myxml:XMLDocument; //reference to the xml
		private var positionsArray:Array; //array where I store all the positions of current active menu items
		private var previousSelected : TreeMenuItem;
		public function TreeMenu(pXML : XML = null){ //constructor
		
			if(pXML)
			{
				myxml = new XMLDocument();
				myxml.ignoreWhite = true;
				myxml.parseXML(pXML.toXMLString());
			}
			
			addEventListener(Event.ADDED_TO_STAGE,init);
		}
		private function init(e:Event):void{ //On added to stage handler
			
			removeEventListener(Event.ADDED_TO_STAGE,init);
			
			if(myxml)
				buildMenu(null, myxml)
			else
			{
				var uL:URLLoader=new URLLoader(new URLRequest(FILENAME)); //xml loading...
				uL.addEventListener(Event.COMPLETE,buildMenu); //... and it handling!
			}
		}
		//This function is called as the XML is loaded and we're ready to build our menu!
		private function buildMenu(e:Event, xml : XMLDocument = null):void{
			
			positionsArray=new Array();
			var current:TreeMenuItem;
			
			if(!myxml)
			{
				myxml=new XMLDocument();
				myxml.ignoreWhite=true;
				myxml.parseXML(e.target.data);
			}
			
			//trace("building menu");
			//trace("my xml is ");
			//trace(myxml.toString());
			
			// SmallGroups	current.txt.tine = current.color>

			for(var i:Number=0;i<myxml.firstChild.childNodes.length;i++) //In this cycle i build the 0-level nodes
			{
				current=new TreeMenuItem();
				addChild(current);
				current.name="item_0_"+i; //<- current menu item
				current.y=current.initialY=i*STEPY; //<- initial menu item's position
				current.xml=myxml.firstChild.childNodes[i]; //<- here I store current xml node in a property of the current item
				current.level=0; //<- hey these items are at level 0 of my xml tree
				current.idx=i; //<- here I store current loop index
				current.selected=false; //<-flag which tells me if the current item is selected (clicked) or not
				current.txt.alpha=0;
				Tweener.addTween(current.txt,{alpha:.6,time:.2,transition:"easeOutSine",delay:.05*i}); //just some fireworks for the menu rendering
				current.txt.text=current.xml.attributes.n;
				current.addEventListener(MouseEvent.CLICK,onElementClick); //click handler
			}			

		}
		//This function is the click handler for every element.
		private function onElementClick(e:MouseEvent):void{
            this.stopDrag();
			//now I check the elements in the menu and check their level of xml-depth (stored in .level property)
			var actual:*;
			var garbageArray:Array=new Array();// in this array I will push all the items i will remove because they're already placed on the screen but their "depth" level in the xml tree is greater than the current clicked element's level
			var me:TreeMenuItem=e.target as TreeMenuItem;
			for(var k:Number=0;k<me.parent.numChildren;k++)
			{
				actual=me.parent.getChildAt(k)
				if(actual is TreeMenuItem)
				{
					if(actual.level==me.level || (actual == me && actual.selectionBar.alpha > 0))  //this is what I do with items located in xml with the same xml-depth of current clicked item
					{
						trace("actual text " + actual.txt.text);
						trace("actual kids " + actual.numChildren);
						trace("actual selected" + actual.selectionBar.alpha);
						
						Tweener.addTween(actual,{y:actual.initialY,time:.2,transition:"easeOutSine"});
						Tweener.addTween(actual.selectionBar,{alpha:0,time:.2,transition:"easeOutSine"});
						Tweener.addTween(actual.txt,{alpha:.6,time:.2,transition:"easeOutSine"});
						actual.selected=false;
						
					}
					else if(actual.level>me.level) //if there are any "expanded" menu items of major level than the current's clicked item, I remove them
					{
						actual.selected=false;
						garbageArray.push(actual); //here i push in the garbage array the items i need to remove from the screen
					}
					if(actual==me) //this is was happens on the menu item I've just clicked 
					{
						if(actual.xml.attributes.id!="" && actual.xml.attributes.id!=undefined)
							dispatchEvent(new TreeMenuEvent(actual.xml.attributes.id)); //Dispatching of the main event i will catch in my application to link the click event to any action
						
						if(previousSelected != actual)
						{
							actual.selected=true;
							previousSelected = actual;
							Tweener.addTween(actual.selectionBar,{alpha:1,time:.3,transition:"easeOutSine",onComplete:function():void{
																																	  addLevel(this.parent); //I add (if any) the children of clicked item
																																	  }});
							Tweener.addTween(actual.txt,{alpha:.9,time:.2,transition:"easeOutSine"});
							
						}
						else
							previousSelected = null;
							
					}
					
				}
			}
			//GARBAGE CLEANING UP	
			while(garbageArray.length)
				removeChild(garbageArray.pop());
		}
		//Function for adding child items on the menu considering the item I've just clicked
		private function addLevel(clip:TreeMenuItem):void{
			var current:TreeMenuItem;
			var newLevel:Number=(clip.level+1); //new level of xml-depth for the items I'm rendering
			var itemsNumber:Number=clip.xml.childNodes.length; //number of children in the xml associated to the clicked item
			expand(clip.level,clip.xml,clip.idx) //ok let's go with some movement
			for(var i:Number=0;i<itemsNumber;i++)
			{
				current=new TreeMenuItem();
				addChild(current);
				current.name="item_"+newLevel+"_"+i; //<- current menu item
				current.idx=i;
				current.level=newLevel;
				current.xml=clip.xml.childNodes[i];
				current.txt.alpha=.6;
				current.txt.text=current.xml.attributes.n;
				if(useScale) //if I've set this parameter, the items I'm rendering are scaled down by a factor of 1-(currentLevel*.08).
					current.txt.scaleX=current.txt.scaleY=1-current.level*.06;
				current.alpha=0;
				Tweener.addTween(current,{alpha:1,time:.2,transition:"easeOutSine",delay:.2+.05*current.idx});
				current.y=current.initialY=clip.initialY+STEPY+current.idx*STEPY;
				current.x=newLevel*STEPX; //horiziontal distance of current from the just-clicked element
				current.addEventListener(MouseEvent.CLICK,onElementClick);
			}	
		}
			//chained movement function for handling existing items on the stage
			private function expand(level:Number,xml:XMLNode,beginningIndex:Number):void{
				var itemsNumber:Number=xml.childNodes.length;
				positionsArray[level]=itemsNumber;			
				var actual:*;
				var k:Number;
				var maxY:Number=0;
				for(k=0;k<this.numChildren;k++)
				{
					actual=this.getChildAt(k);
					if(actual is TreeMenuItem)
					{
							if(actual.level==level && actual.idx>beginningIndex)
							{
								actual.newY=actual.initialY+itemsNumber*STEPY;
								Tweener.addTween(actual,{y:actual.newY,time:.4,transition:"easeOutSine"});
							}
						else
							actual.newY=actual.initialY;
					}
				}
				if(level>0) 
				{
				  for(var i:Number=(level-1);i>=0;i--)
				  {
						maxY=0;
						for(k=0;k<this.numChildren;k++)
						{
							actual=this.getChildAt(k);
							if(actual is TreeMenuItem)
							{
								if(actual.level==i+1 && actual.newY>maxY)
									maxY=actual.newY+STEPY;
							}
						}
						var alt:Number=0;
						for(k=0;k<this.numChildren;k++)
						{
							actual=this.getChildAt(k);
							if(actual is TreeMenuItem)
							{
								if(actual.y>actual.initialY && actual.level==i)
								{
								alt=0;
								for(var j:Number=i;j<=level;j++)
									alt+=positionsArray[j]*STEPY;
								actual.newY=actual.newY+alt;
								Tweener.addTween(actual,{y:actual.newY,time:.4,transition:"easeOutSine"});
								}
							}
						}				
				  }
				}
				
			}
	}
}







/*







//chained movement function for existing items on the stage
function expand(level:Number,xml:XMLNode,beginningIndex:Number):Void{
	var itemsNumber=xml.childNodes.length;
	positionsArray[level]=itemsNumber;
	for(var k in menu)
	{
		if(menu[k].level==level && menu[k].idx>beginningIndex)
		{
			menu[k].newY=menu[k].initialY+itemsNumber*STEPY;
			menu[k].ySlideTo(menu[k].newY,.4,"easeOutSine");
		}
		else
			menu[k].newY=menu[k].initialY;
	}
	if(level>0)
	{
	for(var i:Number=(level-1);i>=0;i--)
	{
		var maxY=0;
		for(var k in menu)
			if(menu[k].level==i+1 && menu[k].newY>maxY)
				maxY=menu[k].newY+STEPY;
		for(var k in menu)
			if(menu[k]._y>menu[k].initialY && menu[k].level==i)
			{
			var alt=0;
			for(var j=i;j<=level;j++)
				alt+=positionsArray[j]*STEPY;
				menu[k].newY=menu[k].newY+alt;
			menu[k].ySlideTo(menu[k].newY,.4,"easeOutSine");
			}
		
	}
	}
	
}
//Actions I execute
function executeAction(id:String):Void{
	if(id!="" && id!=undefined)  //just a basic check...
		trace("OK I've just executed some action: "+id); //... and a basic action ;-)
}
*/