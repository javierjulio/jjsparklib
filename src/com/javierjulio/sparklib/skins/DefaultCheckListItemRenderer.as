package com.javierjulio.sparklib.skins
{
	import com.javierjulio.sparklib.components.supportClasses.NonInteractiveCheckBox;
	
	import flash.events.MouseEvent;
	
	import mx.controls.listClasses.*;
	import mx.core.IDataRenderer;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	
	import spark.components.IItemRenderer;
	import spark.components.supportClasses.ToggleButtonBase;
	
	use namespace mx_internal;
	
	//--------------------------------------
	//  Events
	//--------------------------------------
	
	/**
	 *  Dispatched when the <code>data</code> property changes.
	 *
	 *  <p>When you use a component as an item renderer,
	 *  the <code>data</code> property contains the data to display.
	 *  You can listen for this event and update the component
	 *  when the <code>data</code> property changes.</p>
	 * 
	 *  @eventType mx.events.FlexEvent.DATA_CHANGE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	[Event(name="dataChange", type="mx.events.FlexEvent")]
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	/*
	include "../../styles/metadata/BasicInheritingTextStyles.as"
	include "../../styles/metadata/AdvancedInheritingTextStyles.as"
	include "../../styles/metadata/SelectionFormatTextStyles.as"
	*/
	/**
	 *  The colors to use for the backgrounds of the items in the list. 
	 *  The value is an array of two or more colors. 
	 *  The backgrounds of the list items alternate among the colors in the array. 
	 * 
	 *  @default undefined
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	[Style(name="alternatingItemColors", type="Array", arrayType="uint", format="Color", inherit="yes", theme="spark")]
	
	/**
	 *  Color of focus ring when the component is in focus
	 *   
	 *  @default 0x70B2EE
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	[Style(name="focusColor", type="uint", format="Color", inherit="yes", theme="spark")]
	
	/**
	 *  Color of the highlights when the mouse is over the component
	 *   
	 *  @default 0xCEDBEF
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	[Style(name="rollOverColor", type="uint", format="Color", inherit="yes", theme="spark")]
	
	/**
	 *  Color of any symbol of a component. Examples include the check mark of a CheckBox or
	 *  the arrow of a scroll button
	 *   
	 *  @default 0x000000
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */ 
	[Style(name="symbolColor", type="uint", format="Color", inherit="yes", theme="spark")]
	
	//--------------------------------------
	//  Excluded APIs
	//--------------------------------------
	
	[Exclude(name="focusBlendMode", kind="style")]
	[Exclude(name="focusThickness", kind="style")]
	
	/**
	 *  The DefaultItemRenderer class defines the default item renderer
	 *  for a List control. 
	 *  The default item renderer just draws the text associated
	 *  with each item in the list.
	 *
	 *  <p>You can override the default item renderer
	 *  by creating a custom item renderer.</p>
	 *
	 *  @see spark.components.List
	 *  @see mx.core.IDataRenderer
	 *  @see spark.components.IItemRenderer
	 *  @see spark.components.supportClasses.ItemRenderer
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 9
	 *  @playerversion AIR 1.1
	 *  @productversion Flex 3
	 */
	public class DefaultCheckListItemRenderer extends UIComponent
		implements IDataRenderer, IItemRenderer
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Constructor.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function DefaultCheckListItemRenderer()
		{
			super();
			
			addHandlers();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Flag that is set when the mouse is hovered over the item renderer.
		 */
		private var hovered:Boolean = false;
		
		/**
		 * Storage for the selection indicator instance which is a toggle button 
		 * control base. Most likely a CheckBox control.
		 */
		protected var selectionIndicator:ToggleButtonBase;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties: UIComponent
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  baselinePosition
		//----------------------------------
		
		/**
		 *  @private
		 */
		override public function get baselinePosition():Number
		{
			if (!selectionIndicator || !validateBaselinePosition())
				return super.baselinePosition;
			
			return selectionIndicator.y + selectionIndicator.baselinePosition;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public Properties 
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  data
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the data property.
		 */
		private var _data:Object;
		
		[Bindable("dataChange")]
		
		/**
		 *  The implementation of the <code>data</code> property
		 *  as defined by the IDataRenderer interface.
		 *  When set, it stores the value and invalidates the component 
		 *  to trigger a relayout of the component.
		 *
		 *  @see mx.core.IDataRenderer
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 9
		 *  @playerversion AIR 1.1
		 *  @productversion Flex 3
		 */
		public function get data():Object
		{
			return _data;
		}
		
		/**
		 *  @private
		 */
		public function set data(value:Object):void
		{
			_data = value;
			
			dispatchEvent(new FlexEvent(FlexEvent.DATA_CHANGE));
		}
		
		//----------------------------------
		//  dragging
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the dragging property. 
		 */
		private var _dragging:Boolean = false;
		
		/**
		 *  @inheritDoc  
		 */
		public function get dragging():Boolean
		{
			return _dragging;
		}
		
		/**
		 *  @private  
		 */
		public function set dragging(value:Boolean):void
		{
			if (value == _dragging)
				return;
			
			_dragging = value;
		}
		
		//----------------------------------
		//  itemIndex
		//----------------------------------
		
		/**
		 *  @private
		 *  storage for the itemIndex property 
		 */    
		private var _itemIndex:int;
		
		/**
		 *  @inheritDoc 
		 *
		 *  @default 0
		 */    
		public function get itemIndex():int
		{
			return _itemIndex;
		}
		
		/**
		 *  @private
		 */    
		public function set itemIndex(value:int):void
		{
			if (value == _itemIndex)
				return;
			
			_itemIndex = value;
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  label
		//----------------------------------
		
		/**
		 *  @private 
		 *  Storage var for label
		 */ 
		private var _label:String = "";
		
		/**
		 *  @inheritDoc 
		 *
		 *  @default ""    
		 */
		public function get label():String
		{
			return _label;
		}
		
		/**
		 *  @private
		 */ 
		public function set label(value:String):void
		{
			if (value == _label)
				return;
			
			_label = value;
			
			// push the label down into the selectionIndicator if it exists
			if (selectionIndicator) 
				selectionIndicator.label = _label;
		}
		
		//----------------------------------
		//  showsCaret
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the showsCaret property 
		 */
		private var _showsCaret:Boolean = false;
		
		/**
		 *  @inheritDoc 
		 *
		 *  @default false  
		 */    
		public function get showsCaret():Boolean
		{
			return _showsCaret;
		}
		
		/**
		 *  @private
		 */    
		public function set showsCaret(value:Boolean):void
		{
			if (value == _showsCaret)
				return;
			
			_showsCaret = value;
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  selected
		//----------------------------------
		/**
		 *  @private
		 *  storage for the selected property 
		 */    
		private var _selected:Boolean = false;
		
		/**
		 *  @inheritDoc 
		 *
		 *  @default false
		 */    
		public function get selected():Boolean
		{
			return _selected;
		}
		
		/**
		 *  @private
		 */    
		public function set selected(value:Boolean):void
		{
			if (value == _selected) 
				return;
			
			_selected = value;
			
			if (selectionIndicator) 
				selectionIndicator.selected = value;
			
			invalidateDisplayList();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods: UIComponent
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function createChildren():void
		{
			super.createChildren();
			
			if (!selectionIndicator) 
			{
				selectionIndicator = new NonInteractiveCheckBox();
				selectionIndicator.label = _label;
				selectionIndicator.selected = _selected;
				
				addChild(selectionIndicator);
			}
		}
		
		/**
		 *  @private
		 */
		override protected function measure():void
		{
			super.measure();
			
			// label has padding of 3 on left and right and padding of 2 on top and bottom.
			measuredWidth = selectionIndicator.getPreferredBoundsWidth() + 6;
			measuredHeight = selectionIndicator.getPreferredBoundsHeight() + 4;
			
			measuredMinWidth = selectionIndicator.getMinBoundsWidth() + 6;
			measuredMinHeight = selectionIndicator.getMinBoundsHeight() + 4;
		}
		
		/**
		 *  @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			graphics.clear();
			
			var backgroundColor:uint;
			var drawBackground:Boolean = true;
			
			if (selected) 
			{
				backgroundColor = getStyle("selectionColor");
			}
			else if (hovered) 
			{
				backgroundColor = getStyle("rollOverColor");
			}
			else
			{
				var alternatingColors:Array = getStyle("alternatingItemColors");
				
				if (alternatingColors && alternatingColors.length > 0)
				{
					// translate these colors into uints
					styleManager.getColorNames(alternatingColors);
					
					backgroundColor = alternatingColors[itemIndex % alternatingColors.length];
				}
				else
				{
					// don't draw background if it is the contentBackgroundColor. The
					// list skin handles the background drawing for us.
					drawBackground = false;
				}
			}
			
			graphics.beginFill(backgroundColor, drawBackground ? 1 : 0);
			
			if (showsCaret)
			{
				graphics.lineStyle(1, getStyle("selectionColor"));
				graphics.drawRect(0.5, 0.5, unscaledWidth-1, unscaledHeight-1);
			}
			else 
			{
				graphics.lineStyle();
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			}
			
			graphics.endFill();
			
			// make sure our width/height is in the min/max for the label
			var childWidth:Number = unscaledWidth - 6;
			childWidth = Math.max(selectionIndicator.getMinBoundsWidth(), Math.min(selectionIndicator.getMaxBoundsWidth(), childWidth));
			
			var childHeight:Number = unscaledHeight - 4;
			childHeight = Math.max(selectionIndicator.getMinBoundsHeight(), Math.min(selectionIndicator.getMaxBoundsHeight(), childHeight));
			
			// set the label's position and size
			selectionIndicator.setLayoutBoundsSize(childWidth, childHeight);
			selectionIndicator.setLayoutBoundsPosition(3, 2);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handling
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 *  Attach the mouse events.
		 */
		private function addHandlers():void
		{
			addEventListener(MouseEvent.ROLL_OVER, itemRenderer_rollOverHandler);
			addEventListener(MouseEvent.ROLL_OUT, itemRenderer_rollOutHandler);
		}
		
		/**
		 *  @private
		 */
		private function anyButtonDown(event:MouseEvent):Boolean
		{
			var type:String = event.type;
			
			return (event.buttonDown 
				|| (type == "middleMouseDown") 
				|| (type == "rightMouseDown")); 
		}
		
		/**
		 *  @private
		 *  Mouse rollOver event handler.
		 */
		protected function itemRenderer_rollOverHandler(event:MouseEvent):void
		{
			if (!anyButtonDown(event))
			{
				hovered = true;
				invalidateDisplayList();
			}
		}
		
		/**
		 *  @private
		 *  Mouse rollOut event handler.
		 */
		protected function itemRenderer_rollOutHandler(event:MouseEvent):void
		{
			hovered = false;
			invalidateDisplayList();
		}
	}
}