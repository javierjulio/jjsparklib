package com.javierjulio.sparklib.components
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import spark.components.TextArea;
	import spark.components.supportClasses.TextBase;
	import spark.events.TextOperationEvent;
	
	//--------------------------------------
	//  Skin states
	//--------------------------------------
	
	/**
	 * Prompted State
	 */
	[SkinState("prompted")]
	
	/**
	 * The PromptTextArea component displays a prompt message if no text has been 
	 * entered.
	 */
	public class PromptTextArea extends TextArea
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function PromptTextArea()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
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
			
			// when programmatically setting text to "" the expected behavior 
			// is to just show the prompt, only when the component is focused in 
			// do we want to remove the prompt
			setPrompted((value == ""));
			
			super.text = value;
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
			
			if (instance == promptDisplay) 
			{
				promptDisplay.text = prompt;
			} 
			else if (instance == textDisplay) 
			{
				// when programmatically setting text to "" the expected behavior 
				// is to just show the prompt, only when the component is focused in 
				// do we want to remove the prompt
				setPrompted((text == ""));
				
				textDisplay.addEventListener(TextOperationEvent.CHANGE, textDisplay_changeHandler);
			}
		}
		
		/**
		 * @private
		 */
		override protected function partRemoved(partName:String, instance:Object):void 
		{
			super.partRemoved(partName, instance);
			
			if (instance == textDisplay) 
			{
				textDisplay.removeEventListener(TextOperationEvent.CHANGE, textDisplay_changeHandler);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function focusInHandler(event:FocusEvent):void 
		{
			super.focusInHandler(event);
			
			// there's no text so hide the prompt (default)
			if (text == null || text == "") 
			{
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
				setPrompted(true);
			}
		}
		
		/**
		 * Whenever a change has been made, the input is in a normal 
		 * state.
		 * 
		 * @param event The event object.
		 */
		protected function textDisplay_changeHandler(event:TextOperationEvent):void 
		{
			setPrompted(false);
		}
	}
}