package com.javierjulio.sparklib.skins
{
	import com.javierjulio.sparklib.components.ImageInput;
	
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import spark.components.supportClasses.SkinnableComponent;
	import spark.skins.spark.ErrorSkin;
	
	public class ImageInputErrorSkin extends ErrorSkin
	{
		//--------------------------------------------------------------------------
		//
		//  Class variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * The difference here from the glowFilter defined in ErrorSkin is that the 
		 * alpha is set to 1 so that way the red border appears normally over the 
		 * Choose Button's border. With default alpha appears a dark red/black.
		 */
		private static var glowFilter:GlowFilter = new GlowFilter(
			0xFF0000, 1, 2, 2, 5, 1, false, true);
		
		/**
		 * @private
		 */
		private static var rect:Rectangle = new Rectangle();
		
		/**
		 * @private
		 */
		private static var filterPt:Point = new Point();
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ImageInputErrorSkin()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override public function set target(value:SkinnableComponent):void 
		{
			var preferredTarget:SkinnableComponent = value;
			
			// we prefer the target to be the "No Image" display box if its 
			// defined (optional skin part) in the ImageInput component 
			// rather than the target be the ImageInput itself
			if (value is ImageInput) 
			{
				var input:ImageInput = value as ImageInput;
				
				if (input.chooseControl) 
					preferredTarget = input.chooseControl;
			}
			
			super.target = preferredTarget;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  @private
		 */
		override protected function processBitmap() : void
		{
			// Apply the glow filter
			rect.x = rect.y = 0;
			rect.width = bitmap.bitmapData.width;
			rect.height = bitmap.bitmapData.height;
			glowFilter.color = target.getStyle("errorColor");
			bitmap.bitmapData.applyFilter(bitmap.bitmapData, rect, filterPt, glowFilter);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			// Early exit if we don't have a target object
			if (!target) 
				return;
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			// Set the size of the bitmap to be the size of the component. This 
			// has the effect of overlaying the error skin on the border of the 
			// component. Reposition the bitmap to the target's x/y coordinate as 
			// in the case of ImageInput its not 0,0.
			bitmap.x = target.x;
			bitmap.y = target.y;
			bitmap.width = target.width;
			bitmap.height = target.height;
		}
	}
}