package com.kpm.common {
	import com.kpm.kpm.BubbleId;
	import com.kpm.common.ELanguage;
	import com.kpm.games.EGameCharacter;
	
	import flash.display.*;
	import flash.events.*;

	public interface IGame {
		
		function initGame(pBubble : BubbleId = null, pLanguage : ELanguage = null, pGameTheme : EGameCharacter = null);
		function onStateChanged(e:Event);
		function onBubbleFinished(e:Event);	
		function onRemove(e: Event);
		function onInstructionsFinished(e: Event);

	}
}
