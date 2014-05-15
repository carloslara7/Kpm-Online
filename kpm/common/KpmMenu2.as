package com.kpm.common
{
	//Import TweenMax for animation
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	import com.kpm.kpm.BubbleId;
	import com.kpm.kpm.EBName;
	
	import flash.display.Stage;
		 
		 
	public class KpmMenu
	{
		TweenPlugin.activate([GlowFilterPlugin]);
		
		const ITEM_HEIGHT	: Number = 50;
		var limitLeft, limitRight, limitUp, limitDown	: Number ;
		var menuItemMovieString : String = "MenuItemMovie"; 
		//We want to know which menu array is currently selected
		var selectedMenu:Array;
		var menuItems : Array;
		 
		//We want to keep track how many menus have been created
		var menuCounter:uint = 0;
		
		var sortedStandards : Array;
		var menus : Array;
		var stage : Stage;
		 
		 
		 
		public function KpmMenu(pStage : Stage) 
		{
			stage = pStage;
			
			limitRight = stage.stageWidth - 20;
			limitDown = stage.stageHeight - 20;
			limitUp = 50;
			limitLeft = 50;
			
		}
		function init() : void
		{
			sortedStandards = new Array(10);
			
			sortedStandards[EHSStandard.Geometry.Text] = new Array(30);
			sortedStandards[EHSStandard.NumbersAndOperations.Text] = new Array(30);
			sortedStandards[EHSStandard.Spatial.Text] = new Array(30);
			
			sortedStandards[EHSStandard.Geometry.Text][EBName.MatchShape.Text] = new Array();
			sortedStandards[EHSStandard.Spatial.Text][EBName.SpatialSense.Text] = new Array();
			sortedStandards[EHSStandard.NumbersAndOperations.Text][EBName.IdentifyFinger.Text] = new Array();
			
//			sortedStandards[EHSStandard.Geometry.Text][EBName.MatchShape.Text].push(BubbleId.MatchShape1);
//			sortedStandards[EHSStandard.Geometry.Text][EBName.MatchShape.Text].push(BubbleId.MatchShape2);
//			sortedStandards[EHSStandard.Geometry.Text][EBName.MatchShape.Text].push(BubbleId.MatchShape3);
//			sortedStandards[EHSStandard.Geometry.Text][EBName.MatchShape.Text].push(BubbleId.MatchShape4);
//			
//			sortedStandards[EHSStandard.Spatial.Text][EBName.SpatialSense.Text].push(BubbleId.SpatialSense1);
//			sortedStandards[EHSStandard.Spatial.Text][EBName.SpatialSense.Text].push(BubbleId.SpatialSense2);
//			sortedStandards[EHSStandard.Spatial.Text][EBName.SpatialSense.Text].push(BubbleId.SpatialSense3);
//			sortedStandards[EHSStandard.Spatial.Text][EBName.SpatialSense.Text].push(BubbleId.SpatialSense4);
		}
		
		//This function creates the menus
		function createMenus():void {
		
			menuItems = new Array();
			var standardMenu : KpmMenuItem;
			var bubbleNameMenu : KpmMenuItem;
			var bubbleLevelMenu : KpmMenuItem;
			
			
			
			for each(var oneStandard : Array in sortedStandards)
			{
				standardMenu = new KpmMenuItem(menuItemMovieName);
				
				for each (var onEBName : Array in oneStandard)
				{
					bubbleNameMenu = new KpmMenuItem(menuItemMovieName);
					standardMenu.subMenus.push(bubbleNameMenu);
					
					for each (var oneBubbleId : BubbleId in onEBName)
					{
							
						
					}
					
				}
			}
			
			//Loop through the menus found in the XML file
			for each (var menu:XML in xml.menu) {
		 
				//We create a menu for each menu found in the xml.
				//We pass the "menu" xml data as a parameter to the function.
				var menuItems:Array = createMenu(menu);
		 
				//Position the menu items that are in the menuItems
				for (var i= 0; i< menuItems.length; i++) {
		 
					//Set the x and y coordinates
					menuItems[i].y = limitRight;
					menuItems[i].x = -30 + menuCounter * 80;
		 
					//Add the item to stage
					addChild(menuItems[i]);
				}
			}
		}
		 
		//This function creates a single menu (= one vertical menu).
		//It returns all the menu items which belong to the created menu.
		function createMenu(menu:XML):Array {
		 
			//Create an array which contains all the items in this menu
			var menuItems:Array = new Array();
		 
			//Loop through the items found in the menu
			for each (var item:XML in menu.item) {
		 
				//Create a new menu item
				var menuItem:MenuItem = new MenuItem();
		 
				//Set the item text
				menuItem.menuText.text = item.toString();
		 
				//Set the menuItem to have no mouseChildres
				menuItem.mouseChildren = false;
		 
				//Add the item to the menuArray
				menuItems.push(menuItem);
			}
		 
			//We also need to create the main MenuItem for the menu
			var mainItem:MenuItem = new MenuItem();
		 
			//Set the mainItem to have no mouseChildren
			mainItem.mouseChildren = false;
		 
			//Add the main item to menuArray
			menuItems.push(mainItem);
		 
			//Save the array to which this mainItem belongs to.
			//We need this in the animation later on.
			mainItem.belongsToMenu = menuItems;
		 
			//Set the "id" attribute to be the main item's text
			mainItem.menuText.text = menu. @ id;
		 
			//Add CLICK listener for the mainItem
			mainItem.addEventListener(MouseEvent.CLICK, mainItemClicked, false, 0 , true);
		 
			//Update the menuCounter since we just created a new menu
			menuCounter++;
		 
			//Return the menuArray that contains all the items in this menu
			return menuItems;
		}
		 
		//This function is called when a menu's mainItem is clicked
		function mainItemClicked(e:Event):void {
		 
			//Animate the previous menu down if there is one
			if (selectedMenu) {
				for (var i =0; i<  selectedMenu.length-1; i++) {
					TweenMax.to(selectedMenu[i], 0.5 , {y:limitRight, glowFilter:{color:0x324df, alpha:0, blurX:0, blurY:0}});
				}
			}
		 
			//Get the menu where the mainItem is located
			var clickedMenu:Array = e.target.belongsToMenu;
		 
			//Set the clickedMenu to be our selectedMenu
			selectedMenu = clickedMenu;
		 
			//Loop through the items except for the last one which is the mainItem.
			//We don't animate the mainItem
			for (var j =0; j<  selectedMenu.length-1; j++) {
		 
				//Save the item to a local variable
				var item = selectedMenu[j];
		 
				//Calcute the target y coordinate for the item.
				var targetY:Number = limitRight - ITEM_HEIGHT*1.2*(1 + j);
		 
				//Tween an item up.
				TweenMax.to(item, 0.5 , {y:targetY, glowFilter:{color:0xffffff, alpha:1, blurX:20, blurY:20}});
			}
		}

	}
}