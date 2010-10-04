package com.javierjulio.sparklib.components
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import flashx.textLayout.operations.CopyOperation;
	import flashx.textLayout.operations.CutOperation;
	import flashx.textLayout.operations.DeleteTextOperation;
	import flashx.textLayout.operations.FlowOperation;
	
	import mx.collections.ICollectionView;
	import mx.core.mx_internal;
	
	import spark.components.TextInput;
	import spark.components.supportClasses.DropDownListBase;
	import spark.core.NavigationUnit;
	import spark.events.DropDownEvent;
	import spark.events.TextOperationEvent;
	import spark.utils.LabelUtil;
	
	use namespace mx_internal;
	
	/**
	 *  Bottom inset, in pixels, for the text in the 
	 *  prompt area of the control.  
	 * 
	 *  @default 3
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="paddingBottom", type="Number", format="Length", inherit="no")]
	
	/**
	 *  Left inset, in pixels, for the text in the 
	 *  prompt area of the control.  
	 * 
	 *  @default 3
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="paddingLeft", type="Number", format="Length", inherit="no")]
	
	/**
	 *  Right inset, in pixels, for the text in the 
	 *  prompt area of the control.  
	 * 
	 *  @default 3
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="paddingRight", type="Number", format="Length", inherit="no")]
	
	/**
	 *  Top inset, in pixels, for the text in the 
	 *  prompt area of the control.  
	 * 
	 *  @default 5
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="paddingTop", type="Number", format="Length", inherit="no")]
	
	public class AutoComplete extends DropDownListBase
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function AutoComplete()
		{
			super();
			
			addEventListener(KeyboardEvent.KEY_DOWN, capture_keyDownHandler, true);
			allowCustomSelectedItem = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		protected var isTextInputInFocus:Boolean = false;
		
		protected var actualProposedSelectedIndex:Number = NO_SELECTION;
		
		protected var userTypedIntoText:Boolean = false;
		
		/**
		 * The current text that has been typed into the TextInput control.
		 * 
		 * @default null
		 */
		protected var typedText:String;
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Optional skin part that holds the input text or the selectedItem text.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		[SkinPart(required="true")]
		public var textInput:TextInput;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  baselinePosition
		//----------------------------------
		
		/**
		 * @private
		 */
		override public function get baselinePosition():Number
		{
			return getBaselinePositionForPart(textInput);
		}
		
		//----------------------------------
		//  selectedIndex
		//----------------------------------
		
		/**
		 * @private
		 */
		override public function set selectedIndex(value:int):void
		{
			super.selectedIndex = value;
			actualProposedSelectedIndex = value;
		}
		
		//----------------------------------
		//  typicalItem
		//----------------------------------
		
		/**
		 * @private
		 */
		private var typicalItemChanged:Boolean = false;
		
		/**
		 * @private
		 */
		override public function set typicalItem(value:Object):void
		{   
			if (value == typicalItem)
				return;
			
			super.typicalItem = value;
			
			typicalItemChanged = true;
			invalidateProperties();
		}
		
		//----------------------------------
		//  userProposedSelectedIndex
		//----------------------------------
		
		/**
		 * @private
		 */
		override mx_internal function set userProposedSelectedIndex(value:Number):void
		{
			super.userProposedSelectedIndex = value;
			actualProposedSelectedIndex = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  filterFunction
		//----------------------------------
		
		/**
		 * @private
		 */
		private var filterFunctionChanged:Boolean = false;
		
		/**
		 * @private
		 * Storage for the filterFunction property.
		 */
		private var _filterFunction:Function;
		
		[Bindable("filterFunctionChanged")]
		[Inspectable(category="General")]
		
		/**
		 * A function that the view will use to eliminate items that do not
		 * match the function's criteria. A filterFunction is expected to 
		 * have the following signature:
		 * 
		 * <pre>myFilterFunc(item:Object):Boolean</pre>
		 * 
		 * where the return value is <code>true</code> if the specified item
		 * should remain in the view.
		 * 
		 * <p>If a filter is unsupported, Flex throws an error when accessing
		 * this property. You must call <code>refresh()</code> after setting the
		 * <code>filterFunction</code> property for the view to update.</p>
		 * 
		 * <p>Note: The Flex implementations of ICollectionView retrieve all
		 * items from a remote location before executing the filter function.
		 * If you use paging, apply the filter to the remote collection before
		 * you retrieve the data.</p>
		 * 
		 * @see #refresh()
		 */
		public function get filterFunction():Function 
		{
			return (_filterFunction == null) 
			? dataProvider_defaultFilterFunction 
				: _filterFunction;
		}
		
		/**
		 * @private
		 */
		public function set filterFunction(value:Function):void 
		{
			_filterFunction = value;
			filterFunctionChanged = true;
			invalidateProperties();
			dispatchEvent(new Event("filterFunctionChanged"));
		}
		
		//----------------------------------
		//  labelToItemFunction
		//----------------------------------
		
		private var _labelToItemFunction:Function;
		private var labelToItemFunctionChanged:Boolean = false;
		
		/**
		 *  Specifies a callback function to convert a new value entered 
		 *  into the prompt area to the same data type as the data items in the data provider.
		 *  The function referenced by this properly is called when the text in the prompt area 
		 *  is committed, and is not found in the data provider. 
		 * 
		 *  <p>The callback function must have the following signature: </p>
		 * 
		 *  <pre>
		 *    function myLabelToItem(value:String):Object</pre>
		 * 
		 *  <p>Where <code>value</code> is the String entered in the prompt area.
		 *  The function returns an Object that is the same type as the items 
		 *  in the data provider.</p>
		 * 
		 *  <p>The default callback function returns <code>value</code>. </p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */ 
		public function set labelToItemFunction(value:Function):void
		{
			if (value == _labelToItemFunction)
				return;
			
			_labelToItemFunction = value;
			labelToItemFunctionChanged = true;
			invalidateProperties();
		}
		
		/**
		 * @private
		 */
		public function get labelToItemFunction():Function
		{
			return _labelToItemFunction;
		}
		
		//----------------------------------
		//  maxChars
		//----------------------------------
		
		private var _maxChars:int = 0;
		private var maxCharsChanged:Boolean = false;
		
		/**
		 *  The maximum number of characters that the prompt area can contain, as entered by a user. 
		 *  A value of 0 corresponds to no limit.
		 * 
		 *  @default 0
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function set maxChars(value:int):void
		{
			if (value == _maxChars)
				return;
			
			_maxChars = value;
			maxCharsChanged = true;
			invalidateProperties();
		}
		
		/**
		 * @private
		 */
		public function get maxChars():int
		{
			return _maxChars;
		}
		
		//----------------------------------
		//  openOnInput
		//----------------------------------
		
		/**
		 *  If <code>true</code>, the drop-down list opens when the user edits the prompt area.
		 * 
		 *  @default true 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public var openOnInput:Boolean = true;
		
		//----------------------------------
		//  restrict
		//----------------------------------
		
		private var _restrict:String;
		private var restrictChanged:Boolean;
		
		/**
		 *  Specifies the set of characters that a user can enter into the prompt area.
		 *  By default, the user can enter any characters, corresponding to a value of
		 *  an empty string.
		 * 
		 *  @default ""
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function set restrict(value:String):void
		{
			if (value == _restrict)
				return;
			
			_restrict = value;
			restrictChanged = true;
			invalidateProperties();
		}
		
		/**
		 * @private
		 */
		public function get restrict():String
		{
			return _restrict;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function commitProperties():void
		{
			// Keep track of whether selectedIndex was programmatically changed
			var selectedIndexChanged:Boolean = _proposedSelectedIndex != NO_PROPOSED_SELECTION;
			
			// If selectedIndex was set to CUSTOM_SELECTED_ITEM, and no selectedItem was specified,
			// then don't change the selectedIndex
			if (_proposedSelectedIndex == CUSTOM_SELECTED_ITEM && 
				!_pendingSelectedItem)
			{
				_proposedSelectedIndex = NO_PROPOSED_SELECTION;
			}
			
			super.commitProperties();
			
			if (textInput)
			{
				if (maxCharsChanged)
				{
					textInput.maxChars = _maxChars;
					maxCharsChanged = false;
				}
				
				if (restrictChanged)
				{
					textInput.restrict = _restrict;
					restrictChanged = false;
				}
				
				if (typicalItemChanged)
				{
					if (typicalItem != null)
					{
						var itemString:String = LabelUtil.itemToLabel(typicalItem, labelField, labelFunction);
						textInput.widthInChars = itemString.length;
					}
					else
					{
						// Just set it back to the default value
						textInput.widthInChars = 10; 
					}
					
					typicalItemChanged = false;
				}
			}
			
			
			
			// Clear the TextInput because we were programmatically set to NO_SELECTION
			// We call this after super.commitProperties because commitSelection might have
			// changed the value to NO_SELECTION
			if (selectedIndexChanged && selectedIndex == NO_SELECTION) 
			{
				textInput.text = "";
				
				// when a selection is cleared, the dataProvider must be refreshed 
				// so the drop down list shows the full unfiltered data, ComboBox's 
				// commitProperties() already clears textInput if no selection exists
				if (dataProvider is ICollectionView) 
				{
					ICollectionView(dataProvider).filterFunction = filterFunction;
					ICollectionView(dataProvider).refresh();
				}
			}
		}
		
		/**
		 * @private
		 */
		override mx_internal function updateLabelDisplay(displayItem:* = undefined):void
		{
			super.updateLabelDisplay();
			
			if (textInput)
			{
				if (displayItem == undefined) 
					displayItem = selectedItem;
				
				if (displayItem != null && displayItem != undefined)
				{
					textInput.text = LabelUtil.itemToLabel(displayItem, labelField, labelFunction);
				}
				
			}
		}
		
		/**
		 * @private
		 */
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == textInput)
			{
				updateLabelDisplay();
				textInput.addEventListener(TextOperationEvent.CHANGE, textInput_changeHandler);
				textInput.addEventListener(FocusEvent.FOCUS_IN, textInput_focusInHandler, true);
				textInput.addEventListener(FocusEvent.FOCUS_OUT, textInput_focusOutHandler, true);
				textInput.maxChars = maxChars;
				textInput.restrict = restrict;
				textInput.focusEnabled = false;
				
				textInput.textDisplay.batchTextInput = false;
			}
		}
		
		/**
		 * @private
		 */
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			if (instance == textInput)
			{
				textInput.removeEventListener(TextOperationEvent.CHANGE, textInput_changeHandler);
				textInput.removeEventListener(FocusEvent.FOCUS_IN, textInput_focusInHandler, true);
				textInput.removeEventListener(FocusEvent.FOCUS_OUT, textInput_focusOutHandler, true);
			}
		}
		
		/**
		 * @private
		 */
		override mx_internal function changeHighlightedSelection(newIndex:int, scrollToTop:Boolean = false):void
		{
			super.changeHighlightedSelection(newIndex, scrollToTop);
			
			if (newIndex >= 0)
			{
				var item:Object = dataProvider ? dataProvider.getItemAt(newIndex) : undefined;
				if (item)
				{
					var itemString:String = itemToLabel(item);
					textInput.selectAll();
					textInput.insertText(itemString);
					textInput.selectAll();
					
					userTypedIntoText = false;
				}
			}
		}
		
		/**
		 * @private
		 */
		override mx_internal function findKey(eventCode:int):Boolean
		{
			return false;
		}
		
		// If the TextInput is in focus, listen for keyDown events in the capture phase so that 
		// we can process the navigation keys (UP/DOWN, PGUP/PGDN, HOME/END). If the ComboBox is in 
		// focus, just handle keyDown events in the bubble phase
		
		/**
		 * @private
		 */
		protected function capture_keyDownHandler(event:KeyboardEvent):void
		{        
			if (isTextInputInFocus)
				keyDownHandler(event);
		}
		
		/**
		 * @private
		 */
		override protected function keyDownHandler(event:KeyboardEvent):void
		{
			if (!enabled)
				return;
			
			if (!dropDownController.processKeyDown(event))
			{
				// If rtl layout, need to swap Keyboard.LEFT and Keyboard.RIGHT.
				var navigationUnit:uint = mapKeycodeForLayoutDirection(event);
				
				if (!NavigationUnit.isNavigationUnit(navigationUnit))
					return;
				
				var proposedNewIndex:int = NO_SELECTION;
				var currentIndex:int;
				
				if (isDropDownOpen)
				{
					// Normalize the proposed index for getNavigationDestinationIndex
					currentIndex = userProposedSelectedIndex < NO_SELECTION ? NO_SELECTION : userProposedSelectedIndex;
					proposedNewIndex = layout.getNavigationDestinationIndex(currentIndex, navigationUnit, arrowKeysWrapFocus);
					
					if (proposedNewIndex != NO_SELECTION)
					{
						changeHighlightedSelection(proposedNewIndex);
						event.preventDefault();
					}
				}
				else if (dataProvider)
				{
					var maxIndex:int = dataProvider.length - 1;
					
					// Normalize the proposed index for getNavigationDestinationIndex
					currentIndex = caretIndex < NO_SELECTION ? NO_SELECTION : caretIndex;
					
					switch (navigationUnit)
					{
						case NavigationUnit.DOWN:
						{
							if (!isDropDownOpen) 
								openDropDown();
							event.preventDefault();
							break;
						}
							
						case NavigationUnit.PAGE_UP:
						{
							proposedNewIndex = currentIndex == NO_SELECTION ? 
								NO_SELECTION : Math.max(currentIndex - PAGE_SIZE, 0);
							event.preventDefault();
							break;
						}
							
						case NavigationUnit.PAGE_DOWN:
						{    
							proposedNewIndex = currentIndex == NO_SELECTION ?
								PAGE_SIZE : (currentIndex + PAGE_SIZE);
							event.preventDefault();
							break;
						}
							
						case NavigationUnit.HOME:
						{
							proposedNewIndex = 0;
							event.preventDefault();
							break;
						}
							
						case NavigationUnit.END:
						{
							proposedNewIndex = maxIndex;
							event.preventDefault();
							break;
						}
					}
					
					proposedNewIndex = Math.min(proposedNewIndex, maxIndex);
					
					if (proposedNewIndex >= 0)
						setSelectedIndex(proposedNewIndex, true);
				}
			}
			else
			{
				event.preventDefault();
			}
			
			if (event.keyCode == Keyboard.ENTER) 
			{
				// commit the current text
				applySelection();
				textInput.text = "";
			} 
			else if (event.keyCode == Keyboard.ESCAPE) 
			{
				// restore the previous text entry made by the user
				textInput.text = typedText;
				changeHighlightedSelection(selectedIndex);
				
				// always maintain the cursor at the end of the text entered
				var newPosition:int = (typedText) ? typedText.length : 0;
				
				textInput.selectRange(newPosition, newPosition);
			}
		}
		
		/**
		 * @private
		 */
		override public function setFocus():void
		{
			if (stage)
			{            
				stage.focus = textInput.textDisplay;            
			}
		}
		
		/**
		 * @private
		 */
		override protected function isOurFocus(target:DisplayObject):Boolean
		{
			return target == textInput.textDisplay;
		}
		
		/**
		 * @private
		 */
		override protected function itemRemoved(index:int):void
		{
			if (index == selectedIndex)
				updateLabelDisplay("");
			
			super.itemRemoved(index);       
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * The default filter function if a custom filter is not defined that does 
		 * a case insensitive search anywhere through each item label. For each 
		 * item its label is determined using <code>LabelUtil.itemToLabel()</code>.
		 * 
		 * @param item The data item object.
		 */
		protected function dataProvider_defaultFilterFunction(item:Object):Boolean 
		{
			// if no content has been entered then every item is visible
			if (!textInput.text) 
				return true;
			
			var label:String = LabelUtil.itemToLabel(item, labelField, labelFunction);
			
			if (label == null) 
				label = "";
			
			return (label.toLowerCase().indexOf(textInput.text.toLowerCase()) >= 0);
		}
		
		/**
		 * @private
		 */
		protected function getCustomSelectedItem():*
		{
			// Grab the text from the textInput and process it through labelToItemFunction
			var input:String = textInput.text;
			if (input == "") 
				return undefined;
			else if (labelToItemFunction != null) 
				return _labelToItemFunction(input);
			else 
				return input;
		}
		
		/**
		 * @private
		 * Helper function to apply the textInput text to selectedItem
		 */
		protected function applySelection():void
		{
			if (actualProposedSelectedIndex == CUSTOM_SELECTED_ITEM)
			{
				var itemFromInput:* = getCustomSelectedItem();
				if (itemFromInput != undefined)
					setSelectedItem(itemFromInput, true);
				else
					setSelectedIndex(NO_SELECTION, true);
			}
			else
			{
				setSelectedIndex(actualProposedSelectedIndex, true);
			}
			
			userTypedIntoText = false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override mx_internal function dropDownController_openHandler(event:DropDownEvent):void
		{
			super.dropDownController_openHandler(event);
			
			// If the user typed in text, start off by not showing any selection
			// If this does match, then processInputField will highlight the match
			userProposedSelectedIndex = userTypedIntoText ? NO_SELECTION : selectedIndex;
		}
		
		/**
		 * @private
		 */
		override protected function dropDownController_closeHandler(event:DropDownEvent):void
		{
			super.dropDownController_closeHandler(event);      
			
			// Commit the textInput text as the selection
			if (!event.isDefaultPrevented())
			{
				applySelection();
				typedText = "";
			}
		}
		
		/**
		 * @private
		 */
		override protected function focusInHandler(event:FocusEvent):void
		{
			super.focusInHandler(event);
			
			// Since the API ignores the visual editable and selectable 
			// properties make sure the selection should be set first.
			if (textInput && 
				(textInput.editable || textInput.selectable))
			{
				// Workaround RET handling the mouse and performing its own selection logic
				callLater(textInput.selectAll);
			}
			
			userTypedIntoText = false;
		}
		
		/**
		 * @private
		 */
		override protected function focusOutHandler(event:FocusEvent):void
		{
			// always commit the selection if we focus out        
			if (!isDropDownOpen)
			{
				if (textInput.text != itemToLabel(selectedItem))
					applySelection();
			}
			
			super.focusOutHandler(event);
		}
		
		/**
		 * @private
		 */
		protected function textInput_changeHandler(event:TextOperationEvent):void
		{
			userTypedIntoText = true;
			
			var operation:FlowOperation = event.operation;
			
			// track the latest input so if the user cancels out (hits ESC key) 
			// we can reset the input back to their last entry
			typedText = event.operation.textFlow.getText();
			
			var resultsFound:Boolean = false;
			
			// since the user has modified the text entered, if our dataProvider 
			// has the ability to filter we need refresh the collection to show 
			// the results based on what the user just typed
			if (dataProvider is ICollectionView) 
			{
				var collection:ICollectionView = dataProvider as ICollectionView;
				
				collection.filterFunction = filterFunction;
				collection.refresh();
				
				if (collection.length >= 1) 
					resultsFound = true;
			}
			
			// close the dropDown if we press delete, cut, or copy the selected text
			if (operation is DeleteTextOperation 
				|| operation is CutOperation 
				|| operation is CopyOperation) 
			{
				super.changeHighlightedSelection(CUSTOM_SELECTED_ITEM);
			} 
			else 
			{
				if (openOnInput && resultsFound) 
				{
					openDropDown();
				} 
				else 
				{
					closeDropDown(false);
				}
			}
		}
		
		/**
		 * @private
		 */
		protected function textInput_focusInHandler(event:FocusEvent):void
		{
			isTextInputInFocus = true;
		}
		
		/**
		 * @private
		 */
		protected function textInput_focusOutHandler(event:FocusEvent):void
		{
			isTextInputInFocus = false;
		}
	}
}