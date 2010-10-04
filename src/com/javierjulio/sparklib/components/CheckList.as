package com.javierjulio.sparklib.components
{
	import flash.events.KeyboardEvent;
	
	import spark.components.List;
	
	public class CheckList extends List
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function CheckList()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  allowMultipleSelection
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _allowMultipleSelection:Boolean = true;
		
		[Inspectable(category="General", enumeration="true,false", defaultValue="true")]
		
		/**
		 * If <code>true</code> multiple selection is enabled. When switched at run 
		 * time, the current selection is cleared.
		 * 
		 * @default true
		 */
		override public function get allowMultipleSelection():Boolean
		{
			return _allowMultipleSelection;
		}
		
		/**
		 * @private
		 */
		override public function set allowMultipleSelection(value:Boolean):void 
		{
			if (value == _allowMultipleSelection)
				return;     
			
			// we don't call super here as there is no need too, the setter does 
			// nothing else but store its value locally and we want to make sure 
			// that by default its true rateher than false, unless changed
			_allowMultipleSelection = value; 
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Force calculation to always assume that the shiftKey is false and that 
		 * the ctrlKey is true. By default a List treats multiple selection of 
		 * individual elements by holding down the ctrlKey as you click on items. 
		 * In the case with CheckBoxes we don't want that as you can select as many 
		 * as you like by simply clicking on them thus we just always pass in true 
		 * for the ctrlKey argument.
		 * 
		 * @param index The index of the item that has been clicked.
		 * @param shiftKey True when the shift key is pressed.
		 * @param ctrlKey True when the control key is pressed.
		 * @return The updated item indices that the new selection will be committed to.
		 * 
		 * @see #selectedIndices
		 */
		override protected function calculateSelectedIndices(index:int, shiftKey:Boolean, ctrlKey:Boolean):Vector.<int>
		{
			return super.calculateSelectedIndices(index, false, true);
		}
		
		/**
		 * When the user navigates using the keyboard to select another item it 
		 * works fine for single selection but on multiple selection when using 
		 * CheckBoxes it will remove the previous selection if you navigate to 
		 * another item because it treats multiple selection depending on either 
		 * the shiftKey or ctrlKey being true. In this case we could overwrite 
		 * the event values for shiftKey and ctrlKey but that is considered illegal 
		 * and we can simply get by just not calling the parent implementation of 
		 * this method if allowing multiple selection.
		 * 
		 * @param event The Keyboard Event encountered.
		 */
		override protected function adjustSelectionAndCaretUponNavigation(event:KeyboardEvent):void 
		{
			if (allowMultipleSelection) 
				return;
			
			super.adjustSelectionAndCaretUponNavigation(event);
		}
	}
}