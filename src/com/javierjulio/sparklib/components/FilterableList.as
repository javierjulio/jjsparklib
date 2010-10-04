package com.javierjulio.sparklib.components
{
	import flash.events.Event;
	
	import flashx.textLayout.operations.CopyOperation;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.collections.XMLListCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.List;
	import spark.events.TextOperationEvent;
	import spark.utils.LabelUtil;
	
	/**
	 * 
	 */
	public class FilterableList extends List
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function FilterableList()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  textInput
		//----------------------------------
		
		[SkinPart(required="true")]
		/**
		 * The text input control that as typed in filters the data in this List.
		 */
		public var textInput:PromptTextInput;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  dataProvider
		//----------------------------------
		
		/**
		 * @private
		 */
		private var dataProviderChanged:Boolean = false;
		
		/**
		 * @private
		 */
		protected var unfilteredDataProvider:IList;
		
		/**
		 * @private
		 */
		override public function set dataProvider(value:IList):void 
		{
			// a new ICollectionView instance is created thus the filtering 
			// only affects the items in this control as its going to be 
			// common that the dataProvider given here will be used elsewhere, 
			// this is done as a convenience
			if (value && value is ICollectionView) 
			{
				// hold on to the original data provider, we'll be creating a new one 
				// so any filters don't modify the original
				unfilteredDataProvider = value;
				
				// the first time this property is set and thus the first time this 
				// method is called, dataProvider doesn't exist so a new collection 
				// is created, otherwise its source is updated
				value = updateDataProviderFrom(unfilteredDataProvider);
				
				// any changes on the original collection we need to propgate to 
				// the dataProvider which has a new collection instance to keep in sync
				unfilteredDataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, unfilteredDataProvider_collectionChangeHandler);
			}
			
			super.dataProvider = value;
			dataProviderChanged = true;
			invalidateProperties();
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
			return _filterFunction;
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
		//  prompt
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _prompt:String = "Filter...";
		
		/**
		 * The prompt that is displayed when no text is entered.
		 * 
		 * @default "Filter..."
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
			_prompt = value;
			
			if (textInput) 
				textInput.prompt = value;
		}
		
		//----------------------------------
		//  text
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _text:String = "";
		
		/**
		 * @private
		 */
		private var textChanged:Boolean = false;
		
		[Bindable("textChanged")]
		
		/**
		 * 
		 */
		public function get text():String 
		{
			return (textInput) ? textInput.text : _text;
		}
		
		/**
		 * @private
		 */
		public function set text(value:String):void 
		{
			if (_text == value) 
				return;
			
			_text = value;
			textChanged = true;
			
			invalidateProperties();
			
			dispatchEvent(new Event("textChanged"));
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
			super.commitProperties();
			
			if (dataProviderChanged || filterFunctionChanged || textChanged) 
			{
				// only ICollectionView's can be filtered
				if (dataProvider && dataProvider is ICollectionView) 
				{
					var collection:ICollectionView = ICollectionView(dataProvider);
					
					if (filterFunction == null) 
					{
						collection.filterFunction = dataProvider_defaultFilterFunction;
					} 
					else 
					{
						collection.filterFunction = filterFunction;
					}
					
					if (textInput) 
					{
						textInput.text = _text;
						
						// if the dataProvider has been reset after this component has 
						// been created, check if their is an entry in the text input 
						// and if so run the filter as the list would otherwise show 
						// the full unfiltered list
						if (!textInput.prompted && textInput.text) 
							refresh();
					}
				}
				
				textChanged = false;
				filterFunctionChanged = false;
				dataProviderChanged = false;
			}
		}
		
		/**
		 * @private
		 */
		override protected function partAdded(partName:String, instance:Object):void 
		{
			super.partAdded(partName, instance);
			
			if (textInput) 
			{
				textInput.prompt = prompt;
				textInput.addEventListener(TextOperationEvent.CHANGE, textInput_changeHandler);
			}
		}
		
		/**
		 * @private
		 */
		override protected function partRemoved(partName:String, instance:Object):void 
		{
			super.partRemoved(partName, instance);
			
			if (textInput) 
			{
				textInput.removeEventListener(TextOperationEvent.CHANGE, textInput_changeHandler);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Updates the dataProvider with a copy of the source from the provided 
		 * unfiltered list. If the dataProvider doesn't exist yet a new 
		 * ICollectionView instance is created. Only ArrayCollection and 
		 * XMLListCollection is supported.
		 * 
		 * @param unfilteredList The unfiltered list originally given to this 
		 * component as the dataProvider but won't be the instance used. A new 
		 * instance will be created from a copy of its source.
		 * 
		 * @returns The instance that should be set on the dataProvider property.
		 */
		protected function updateDataProviderFrom(unfilteredList:IList):IList 
		{
			var collection:ICollectionView;
			
			// careful! sources are passed by reference since they are objects 
			// (Array and XMLList) so make sure to always create a copy
			if (unfilteredList is ArrayCollection) 
			{
				var source:Array = ArrayCollection(unfilteredList).source.concat();
				
				// we have a dataProvider so just update its source 
				// rather than creating a new collection
				if (dataProvider) 
				{
					ArrayCollection(dataProvider).source = source;
				} 
				else 
				{
					collection = new ArrayCollection(source);
				}
			} 
			else if (unfilteredList is XMLListCollection) 
			{
				// copy the source if one exists, otherwise create an empty one
				var xmlSource:XMLList = XMLListCollection(unfilteredList).source.copy();
				
				// we have a dataProvider so just update its source 
				// rather than creating a new collection
				if (dataProvider) 
				{
					XMLListCollection(dataProvider).source = xmlSource;
				} 
				else 
				{
					collection = new XMLListCollection(xmlSource);
				}
			}
			
			// we have an ICollectionView so preserve the sort and refresh
			if (collection) 
			{
				collection.sort = ICollectionView(unfilteredList).sort;
				collection.refresh();
			}
			
			return collection as IList;
		}
		
		/**
		 * The default filter function if a custom filter is not defined that does 
		 * a case insensitive search anywhere through each item label. For each 
		 * item its label is determined using <code>LabelUtil.itemToLabel()</code>.
		 * 
		 * @param item The data item object.
		 */
		protected function dataProvider_defaultFilterFunction(item:Object):Boolean 
		{
			// if prompted or no content has been entered (when input receives focus 
			// prompted is false and text is set to "") then every item is visible
			if (textInput && (textInput.prompted || !textInput.text)) 
				return true;
			
			var label:String = LabelUtil.itemToLabel(item, labelField, labelFunction);
			
			if (label == null) 
				label = "";
			
			return (label.toLowerCase().indexOf(textInput.text.toLowerCase()) >= 0);
		}
		
		/**
		 * Refresh the dataProvider if its an ICollectionView instance only. IList 
		 * implementations aren't required to have a refresh() method.
		 * 
		 * @return <code>true</code> if the dataProvider.refresh() was complete, 
		 * <code>false</code> if the dataProvider.refresh() is incomplete.
		 */
		public function refresh():Boolean 
		{
			var result:Boolean = false;
			
			if (dataProvider && dataProvider is ICollectionView) 
			{
				result = ICollectionView(dataProvider).refresh();
			}
			
			return result;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * When the content has changed, refresh the collection so the filter is 
		 * run based on the input entered. If the operation is of type 
		 * <code>CopyOperation</code> then the collection is not refreshed as that 
		 * action does not change the content.
		 * 
		 * @param event The event object.
		 */
		protected function textInput_changeHandler(event:TextOperationEvent):void 
		{
			// copying text doesn't change the contents so ignore it, pasting does 
			// but that is a separate operation (PasteOperation)
			if (event.operation is CopyOperation) 
				return;
			
			// refresh to run the collection filter based on input entered 
			refresh();
		}
		
		/**
		 * Syncs any changes from the unfiltered collection to the dataProvider 
		 * collection instance. 
		 * 
		 * <p>Note: the dataProvider set is always the unfiltered one and is 
		 * stored separately. The dataProvider is actually a new collection 
		 * instance created from a copy of the unfiltered source.</p>
		 * 
		 * @param event The event object.
		 */
		protected function unfilteredDataProvider_collectionChangeHandler(event:CollectionEvent):void 
		{
			var collection:ICollectionView = unfilteredDataProvider as ICollectionView;
			var numItems:int;
			var i:int;
			var index:int;
			
			switch (event.kind) 
			{
				case CollectionEventKind.ADD:
					numItems = event.items.length;
					
					for (i = 0; i < numItems; i++) 
					{
						dataProvider.addItem(event.items[i]);
					}
					break;
				
				case CollectionEventKind.REFRESH:
					ICollectionView(dataProvider).sort = collection.sort;
					refresh();
					break;
				
				case CollectionEventKind.REMOVE:
					numItems = event.items.length;
					
					for (i = 0; i < numItems; i++) 
					{
						index = ListCollectionView(dataProvider).list.getItemIndex(event.items[i]);
						
						if (index >= 0 && index < ListCollectionView(dataProvider).list.length) 
							ListCollectionView(dataProvider).list.removeItemAt(index);
					}
					refresh();
					break;
				
				case CollectionEventKind.REPLACE:
					numItems = event.items.length;
					
					for (i = 0; i < numItems; i++) 
					{
						var prop:PropertyChangeEvent = event.items[i] as PropertyChangeEvent;
						index = int(prop.property);
						
						if (index >= 0 && index < dataProvider.length) 
							dataProvider.setItemAt(prop.newValue, index);
					}
					break;
				
				case CollectionEventKind.RESET:
					dataProvider = unfilteredDataProvider;
					break;
			}
		}
	}
}