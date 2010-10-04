package com.javierjulio.sparklib.components.supportClasses
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import spark.components.CheckBox;
	
	public class NonInteractiveCheckBox extends CheckBox
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function NonInteractiveCheckBox()
		{
			super();
			
			focusEnabled = false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * <p>This method gets called to handle <code>MouseEvent.ROLL_OVER</code>, 
		 * <code>MouseEvent.ROLL_OUT</code>, <code>MouseEvent.MOUSE_DOWN</code>, 
		 * <code>MouseEvent.MOUSE_UP</code>, and <code>MouseEvent.CLICK</code> 
		 * events.</p>
		 * 
		 * <p>On the <code>MouseEvent.MOUSE_DOWN</code>, 
		 * <code>MouseEvent.MOUSE_UP</code>, and <code>MouseEvent.CLICK</code> 
		 * events we cancel out so the implementation of this method in our base 
		 * class is not called.</p>
		 * 
		 * <p>Used in conjuction with CheckBoxList as its base class (List) will 
		 * handle the necessary mouse events and set the selected items. If we left 
		 * a CheckBox to work normally it would toggle its selected property on the 
		 * click event by calling the buttonReleased() method which we don't want. 
		 * The selected property is set whenever the ItemRenderer's selected 
		 * property changes.
		 * 
		 * @param event The Event object associated with the event.
		 */
		override protected function mouseEventHandler(event:Event):void 
		{
			if (event.type == MouseEvent.CLICK || 
				event.type == MouseEvent.MOUSE_DOWN || 
				event.type == MouseEvent.MOUSE_UP) 
			{
				return;
			}
			
			super.mouseEventHandler(event);
		}
	}
}