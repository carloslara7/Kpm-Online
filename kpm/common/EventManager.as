package com.kpm.common
{
    
    /**
     * @author Duncan Hall
     */

    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.utils.Dictionary;     

    public class EventManager

    {
        private static var targetMap:Dictionary = new Dictionary();

        /** PUBLIC METHODS ************************************************************************/
        /**
         * Adds an event listener of the specified type, to the object given, and
         * allows for an undefined number of arguments to be passed to the listener
         * 
         * @param target    The object to listen to
         * @param type        The type of event to listen for
         * @param listener    The function to call when the event is dispatched
         * @param args        [Optional] list of arguments to pass to listener
         */
        public static function addEvent ( 
            target:IEventDispatcher, type:String, listener:Function, ...args ) : void
        {
            var targetEventMap:Dictionary;
                targetEventMap = targetMap[target] == undefined ? new Dictionary : targetMap[target];
                targetEventMap[type] = { listener:listener, args:args };

            targetMap[target] = targetEventMap;
            
            target.addEventListener( type, onEvent, false, 0 , true);
        }
        
        /**
         * Remove an event add by the EventManager and destroys any associated keys
         * in the targets event map
         * 
         * @param target    The object to remove the listener from
         * @param type        The type of listener to remove
         */
        public static function removeEvent ( target:IEventDispatcher, type:String ) : void
        {
            var targetEventMap:Dictionary = targetMap[target];
            if(target && targetEventMap && targetEventMap[type])
            {
            	delete targetEventMap[type];
            	target.removeEventListener( type, onEvent );	
            }
            
            
        }
        
        /** EVENT HANDLERS ************************************************************************/
        /**
         * Handles all events dispatched through the EventManager. 
         * Calls the associated listener, and applies the given arguments 
         * (with the event object prepended to the start of the array)
         * 
         * @param e    The Event that was dispatched
         */
        private static function onEvent ( e:Event ) : void
        {
            var target:IEventDispatcher        =     e.currentTarget as IEventDispatcher;
            var targetEventMap:Dictionary     =     targetMap[target];
            var eventType:String            =    e.type;
            
            var listener:Function    =     targetEventMap[eventType].listener;
            var args:Array            =     targetEventMap[eventType].args;
            
            if (args[0] is Event) args.shift();
            
            args.unshift( e );

            listener.apply( target, args );
        }
    }
}
