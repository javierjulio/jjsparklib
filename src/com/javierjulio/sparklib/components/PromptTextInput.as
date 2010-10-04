package com.javierjulio.sparklib.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	
	import flashx.textLayout.edit.SelectionState;
	import flashx.textLayout.operations.DeleteTextOperation;
	
	import mx.core.mx_internal;
	
	import spark.components.TextInput;
	import spark.components.supportClasses.ButtonBase;
	import spark.components.supportClasses.TextBase;
	import spark.events.TextOperationEvent;
	import spark.primitives.BitmapImage;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 * Name of the class to use as the default icon. 
	 * Setting any other icon style overrides this setting.
	 * 
	 * @default null
	 */
	[Style(name="icon", type="Class", inherit="no")]
	
	//--------------------------------------
	//  Skin states
	//--------------------------------------
	
	/**
	 * Prompted State
	 */
	[SkinState("prompted")]
	
	/**
	 * TextEntered State
	 */
	[SkinState("textEntered")]
	
	/**
	 * The PromptTextInput component displays a prompt message if no text has been 
	 * entered. There are is optional icon that can be displayed that is supported 
	 * by the default skin. When text has been entered a button will appear allowing 
	 * the user to easily clear the input with one click. The icon and clear button 
	 * are optional skin parts so a custom skin can be provided without either one 
	 * or both.
	 */
	public class PromptTextInput extends TextInput
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function PromptTextInput()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  clearButton
		//----------------------------------
		
		[SkinPart(required="false")]
		/**
		 * A skin part that defines the clear button to clear the entered text 
		 * when clicked.
		 */
		public var clearButton:ButtonBase;
		
		//----------------------------------
		//  iconDisplay
		//----------------------------------
		
		[SkinPart(required="false")]
		/**
		 * A skin part that displays an optional icon.
		 */
		public var iconDisplay:BitmapImage;
		
		//----------------------------------
		//  promptDisplay
		//----------------------------------
		
		[SkinPart(required="false")]
		/**
		 * A skin part that displays the prompt label.
		 */
		public var promptDisplay:TextBase;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  prompt
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _prompt:String = "";
		
		[Bindable(event="promptChanged")]
		
		/**
		 * The prompt that is displayed when no text is entered.
		 * 
		 * @default ""
		 */
		public function get prompt():String 
		{
			return _prompt;
		}
		
		/**
		 * @private
		 */
		public function set prompt(value:String):void 
		{
			if (value == _prompt) 
				return;
			
			_prompt = value;
			
			if (promptDisplay) 
				promptDisplay.text = value;
			
			dispatchEvent(new Event("promptChanged"));
		}
		
		//----------------------------------
		//  prompted
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _prompted:Boolean = false;
		
		/**
		 * Indicates whether the user is being prompted to enter a value. Used to 
		 * determine the skin state.
		 * 
		 * @default false
		 */
		public function get prompted():Boolean 
		{
			return _prompted;
		}
		
		/**
		 * @private
		 */
		protected function setPrompted(value:Boolean):void 
		{
			if (value == _prompted) 
				return;
			
			_prompted = value;
			
			invalidateSkinState();
		}
		
		//----------------------------------
		//  promptOnFocus
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _promptOnFocus:Boolean = false;
		
		/**
		 * If <code>true</code> the prompt will appear when the input has focus and 
		 * no text has been entered. Once a character is entered though the prompt 
		 * will disappear.
		 * 
		 * @default false
		 */
		public function get promptOnFocus():Boolean
		{
			return _promptOnFocus;
		}
		
		/**
		 * @private
		 */
		public function set promptOnFocus(value:Boolean):void
		{
			if (_promptOnFocus == value) 
				return;
			
			_promptOnFocus = value;
		}
		
		//----------------------------------
		//  text
		//----------------------------------
		
		[Bindable("change")]
		[Bindable("textChanged")]
		
		/**
		 * @private
		 */
		override public function set text(value:String):void 
		{
			if (value == null) 
				value = "";
			
			setText(value);
		}
		
		//----------------------------------
		//  textEntered
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _textEntered:Boolean = false;
		
		/**
		 * Indicates whether the user has entered a value. Used to determine the 
		 * skin state.
		 * 
		 * @default false
		 */
		protected function get textEntered():Boolean 
		{
			return _textEntered;
		}
		
		/**
		 * @private
		 */
		protected function set textEntered(value:Boolean):void 
		{
			if (value == _textEntered) 
				return;
			
			_textEntered = value;
			invalidateSkinState();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function getCurrentSkinState():String 
		{
			var result:String = super.getCurrentSkinState();
			
			if (textEntered) 
				result = "textEntered";
			
			if (prompted) 
				result = "prompted";
			
			return result;
		}
		
		/**
		 * @private
		 */
		override protected function partAdded(partName:String, instance:Object):void 
		{
			super.partAdded(partName, instance);
			
			if (instance == clearButton) 
			{
				clearButton.addEventListener(MouseEvent.CLICK, clearButton_clickHandler);
			} 
			else if (instance == promptDisplay) 
			{
				promptDisplay.text = prompt;
			} 
			else if (instance == textDisplay) 
			{
				setText(text);
				textDisplay.addEventListener(TextOperationEvent.CHANGE, textDisplay_changeHandler);
			}
		}
		
		/**
		 * @private
		 */
		override protected function partRemoved(partName:String, instance:Object):void 
		{
			super.partRemoved(partName, instance);
			
			if (instance == clearButton) 
			{
				clearButton.removeEventListener(MouseEvent.CLICK, clearButton_clickHandler);
			} 
			else if (instance == textDisplay) 
			{
				textDisplay.removeEventListener(TextOperationEvent.CHANGE, textDisplay_changeHandler);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 
		 */
		protected function setText(value:String):void 
		{
			// when programmatically setting text to "" the expected behavior 
			// is to just show the prompt, only when the component is focused in 
			// do we want to remove the prompt
			if (value == "") 
			{
				setPrompted(true);
				textEntered = false;
			} 
			else 
			{
				setPrompted(false);
				textEntered = true;
			}
			
			super.text = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * When the user clicks the clear button, as long as the input is not in a 
		 * prompting state, the inputed value is cleared out. An event of type 
		 * <code>TextOperationEvent.CHANGE</code> is dispatched as this is a user 
		 * initiated change but instead of using the keyboard to delete or add text 
		 * the user clicked a button. The event operation will be of type 
		 * <code>DeleteTextOperation</code>. Focus is maintained on the input after 
		 * it has been cleared.
		 * 
		 * @param event The event object.
		 */
		protected function clearButton_clickHandler(event:MouseEvent):void 
		{
			if (!prompted && text) 
			{
				var lastCharIndex:int = text.length - 1;
				
				super.text = "";
				textEntered = false;
				
				// since the user initiates a real text change, except instead of 
				// deleting text, they hit the clear button which in turn we reset 
				// the text property but we want to maintain the same behavior as 
				// if they used the delete key so manually dispatch the change event
				var selectionState:SelectionState = new SelectionState(getTextFlow(), 0, lastCharIndex);
				var operation:DeleteTextOperation = new DeleteTextOperation(selectionState);
				
				textDisplay.dispatchEvent(new TextOperationEvent(TextOperationEvent.CHANGE, false, true, operation));
				
				// when clicking the clear button the text input loses focus but 
				// we always want the input to retain focus after clearing
				setFocus();
			}
		}
		
		/**
		 * @private
		 */
		override protected function focusInHandler(event:FocusEvent):void 
		{
			super.focusInHandler(event);
			
			// there's no text so hide the prompt (default)
			if (text == null || text == "") 
			{
				textEntered = false;
				
				// override and continue to show prompt if desired, 
				// otherwise default behavior hides it
				setPrompted(promptOnFocus);
			}
		}
		
		/**
		 * @private
		 */
		override protected function focusOutHandler(event:FocusEvent):void 
		{
			super.focusOutHandler(event);
			
			// the user has set focus outside the text input so if no text 
			// is currently entered, then display the prompt
			if (text == null || text == "") 
			{
				textEntered = false;
				setPrompted(true);
			}
		}
		
		/**
		 * When the user has made any change in the text input, whether inserting 
		 * or removing text, update the <code>textEntered</code> flag to reflect 
		 * that state.
		 * 
		 * @param event The event object.
		 */
		protected function textDisplay_changeHandler(event:TextOperationEvent):void 
		{
			setPrompted(false);
			textEntered = (text != "");
		}
	}
}