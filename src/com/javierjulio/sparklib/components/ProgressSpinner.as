package com.javierjulio.sparklib.components
{
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	
	//--------------------------------------
	//  Styles
	//--------------------------------------
	
	/**
	 *  The background alpha value (0-1).
	 *  @default 1
	 */
	[Style(name="backgroundAlpha", type="Number", format="Length", inherit="no")]
	
	/**
	 *  The background color.
	 *  @default NaN (no background)
	 */
	[Style(name="backgroundColor", type="uint", format="Color", inherit="no")]
	
	/**
	 *  The spinner alpha value (0-1).
	 *  @default 1
	 */
	[Style(name="spinnerAlpha", type="Number", format="Length", inherit="no")]
	
	/**
	 *  The normal spinner color.
	 *  @default #829AD1
	 */
	[Style(name="spinnerColor", type="uint", format="Color", inherit="no")]
	
	/**
	 *  The normal spinner color.
	 *  @default #829AD1
	 */
	[Style(name="spinnerHighlightColor", type="uint", format="Color", inherit="no")]
	
	/**
	 *  The thickness of the spinner when the lines type is used.
	 *  @default 2
	 */
	[Style(name="spinnerLineThickness", type="Number", format="Length", inherit="no")]
	
	/**
	 *  The thickness of the spinner when the default type is used.
	 *  @default 3
	 */
	[Style(name="spinnerThickness", type="Number", format="Length", inherit="no")]
	
	/**
	 *  The type of spinner - "circles", "lines", "gradientlines", or "gradientcircle".
	 *  @default "gradientcircle"
	 */
	[Style(name="spinnerType", type="String", enumeration="gradientcircle,circles,lines,gradientlines", inherit="no")]
	
	/**
	 * The ProgressSpinner class draws an animated spinner in the shape of a circle. 
	 * Various types can be set that will enable up to 4 different spinner styles. A 
	 * timer is used to animate the spinner. The timer is always stopped when the 
	 * component is removed from its parent. To manually stop call the 
	 * <code>stop()</code> method or set the <code>spinning</code> property to 
	 * <code>false</code>. Whenever the component is disabled, the animation will 
	 * stop but if it was visible before it was disabled, the component in its last 
	 * animated state will remain visible. If the <code>visible</code> property is 
	 * set to <code>false</code> the component will be hidden and the animation 
	 * timer will stop.
	 * 
	 * <p>The original Spinner class was written by Chris Callendar but Javier 
	 * Julio has made various changes to improve the class so styles can be 
	 * changed at runtime, default measurement in place, the use of invalidation 
	 * and various code optimizations.</p>
	 * 
	 * @mxml
	 * 
	 * <p>The <code>&lt;nms:ProgressSpinner&gt;</code> tag inherits all of the tag 
	 * attributes of its superclass and adds the following tag attributes:</p>
	 * 
	 *  <pre>
	 *  &lt;nms:Spinner
	 *   <strong>Properties</strong>
	 *      delay="100"
	 *      keepOnTop="true|false"
	 * 
	 *   <strong>Styles</strong>
	 *   	backgroundAlpha="1"
	 *   	backgroundColor="NaN"
	 * 	 	spinnerAlpha="1"
	 *   	spinnerColor="#829AD1"
	 * 		spinnerHighlightColor="#001A8E"
	 * 		spinnerLineThickness="2"
	 * 		spinnerThickness="3"
	 * 		spinnerType="gradientcircle"
	 * /&gt;
	 * </pre>
	 */
	public class ProgressSpinner extends UIComponent
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		protected static const GRADIENT_CIRCLE:String = "gradientcircle";
		
		/**
		 * @private
		 */
		protected static const GRADIENT_LINES:String = "gradientlines";
		
		/**
		 * @private
		 */
		protected static const CIRCLES:String = "circles";
		
		/**
		 * @private
		 */
		protected static const LINES:String = "lines";
		
		/**
		 * @private
		 * 360 degrees
		 */
		private static const MAX_ANGLE:Number = 2 * Math.PI;
		
		/**
		 * @private
		 */
		private static const POSITIONS:int = 8;
		
		/**
		 * @private
		 * 45 degrees
		 */
		private static const ANGLE_INCREMENT:Number = MAX_ANGLE / POSITIONS;
		
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Combines the red, green, and blue color components into one 24 bit uint.
		 */
		public static function combine(r:uint, g:uint, b:uint):uint 
		{
			return (Math.min(Math.max(0, r), 255) << 16) | 
				(Math.min(Math.max(0, g), 255) << 8) | 
				Math.min(Math.max(0, b), 255);
		}
		
		/**
		 * Returns the average of the two colors. Doesn't look at alpha values.
		 */
		public static function average(c1:uint, c2:uint):uint 
		{
			var r:uint = Math.round((getRed(c1) + getRed(c2)) / 2);
			var g:uint = Math.round((getGreen(c1) + getGreen(c2)) / 2);
			var b:uint = Math.round((getBlue(c1) + getBlue(c2)) / 2);
			return combine(r, g, b);
		}
		
		/**
		 * Returns the blue values of an RGB color.
		 */
		public static function getBlue(rgb:uint):uint 
		{
			return (rgb & 0xFF);
		}
		
		/**
		 * Returns the red values of an RGB color.
		 */
		public static function getRed(rgb:uint):uint 
		{
			return ((rgb >> 16) & 0xFF);
		}
		
		/**
		 * Returns the green values of an RGB color.
		 */
		public static function getGreen(rgb:uint):uint 
		{
			return ((rgb >> 8) & 0xFF);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ProgressSpinner() 
		{
			super();
			
			timer = new Timer(defaultDelay);
			
			addEventListener(Event.REMOVED, removedHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * The current position of the highlighted area in the progress spinner 
		 * determined during the timer events.
		 * 
		 * @default 0
		 */
		protected var currentPosition:int = 0;
		
		/**
		 * The default delay value for the animation timer.
		 * 
		 * @default 100
		 */
		protected var defaultDelay:int = 100;
		
		/**
		 * A matrix object used to create gradients.
		 * 
		 * @default null
		 */
		protected var matrix:Matrix;
		
		/**
		 * The timer used to animate the spinner. A Timer object is created in 
		 * the Constructor when instantiated.
		 * 
		 * @default null
		 */
		protected var timer:Timer;
		
		//--------------------------------------------------------------------------
		//
		//  Overridden properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  enabled
		//----------------------------------
		
		/**
		 * @private
		 * If true, stop the animation.
		 */
		override public function set enabled(value:Boolean):void 
		{
			super.enabled = value;
			
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  visible
		//----------------------------------
		
		/**
		 * @private
		 * If true, hide the spinner and stop the animation.
		 */
		override public function set visible(value:Boolean):void 
		{
			super.visible = value;
			
			invalidateDisplayList();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  delay
		//----------------------------------
		
		[Bindable(event="delayChanged")]
		[Inspectable(category="General", defaultValue="100")]
		
		/**
		 * The delay in milliseconds between timer events. The default is set in 
		 * the constructor where the Timer object is created. To override simply 
		 * provide a new delay value and the timer object will be updated directly.
		 * 
		 * @default 100
		 */
		public function get delay():Number 
		{
			return timer.delay;
		}
		
		/**
		 * @private
		 */
		public function set delay(value:Number):void 
		{
			if (value == timer.delay || value < 0 || isNaN(value)) 
				return;
			
			timer.delay = value;
			
			dispatchEvent(new Event("delayChanged"));
		}
		
		//----------------------------------
		//  keepOnTop
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _keepOnTop:Boolean = false;
		
		/**
		 * @private
		 */
		private var keepOnTopChanged:Boolean = false;
		
		[Inspectable(category="General", defaultValue="false")]
		
		/**
		 * 
		 */
		public function get keepOnTop():Boolean 
		{
			return _keepOnTop;
		}
		
		/**
		 * @private
		 */
		public function set keepOnTop(value:Boolean):void 
		{
			if (value == _keepOnTop) 
				return;
			
			_keepOnTop = value;
			keepOnTopChanged = true;
			invalidateDisplayList();
		}
		
		//----------------------------------
		//  spinning
		//----------------------------------
		
		/**
		 * Indicates whether the progress animation is being played. Based on 
		 * whether the internal timer is running.
		 */
		public function get spinning():Boolean 
		{
			return (timer && timer.running);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Overridden methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		override protected function measure():void 
		{
			super.measure();
			
			// default size is 16 by 16
			measuredMinWidth = 16;
			measuredMinHeight = 16;
			measuredWidth = 16;
			measuredHeight = 16;
		}
		
		/**
		 * @private
		 */
		override public function styleChanged(styleProp:String):void 
		{
			super.styleChanged(styleProp);
			
			if (styleProp == null || styleProp == "styleName" 
				|| styleProp == "backgroundColor" || styleProp == "backgroundAlpha" 
				|| styleProp == "spinnerAlpha" || styleProp == "spinnerColor" 
				|| styleProp == "spinnerHighlightColor" || styleProp == "spinnerLineThickness" 
				|| styleProp == "spinnerThickness" || styleProp == "spinnerType")
			{
				// wholesale change, need to update all styles
				invalidateDisplayList();
			}
		}
		
		/**
		 * @private
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (visible && enabled) 
			{
				var g:Graphics = graphics;
				g.clear();
				fillBackground(g, unscaledWidth, unscaledHeight);
				drawSpinner(g, unscaledWidth, unscaledHeight);
				
				start();
			} 
			else if (visible == false || enabled == false) 
			{
				stop();
			}
			
			if (keepOnTopChanged && _keepOnTop && parent) 
			{
				parent.setChildIndex(this, parent.numChildren - 1);
				
				keepOnTopChanged = false;
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Draws a small circle at the given position.
		 */
		protected function drawCircle(g:Graphics, color:uint, midX:Number, 
									  midY:Number, radius:Number, circleAlpha:Number=1):void 
		{
			if ((radius > 0) && (circleAlpha > 0)) 
			{
				g.lineStyle(0, 0, 0); // no border
				g.beginFill(color, circleAlpha);
				g.drawCircle(midX, midY, radius);
				g.endFill();
			}
		}
		
		/**
		 * Draws a gradient circle.
		 */
		protected function drawGradientCircle(g:Graphics, color:uint, highlight:uint, 
											  midX:Number, midY:Number, radius:Number, 
											  thickness:Number=3, circleAlpha:Number=1):void 
		{
			if ((radius > 0) && (thickness > 0) && (circleAlpha > 0)) 
			{
				// draw the circle - the matrix rotation value changes to 
				// give the impression that the circle is spinning
				g.lineStyle(thickness);
				
				if (matrix == null) 
					matrix = new Matrix();
				
				var angle:Number = currentPosition * ANGLE_INCREMENT;
				
				matrix.createGradientBox(2 * radius, 2 * radius, angle, midX - radius, midY - radius);
				
				g.lineGradientStyle(GradientType.LINEAR, [highlight, color], [circleAlpha, circleAlpha], [0, 96], matrix);
				g.drawCircle(midX, midY, radius);
			}
		}
		
		/**
		 * Draws a circle of lines with a gradient style.
		 */
		protected function drawGradientLines(g:Graphics, color:uint, highlight:uint, 
											 midX:Number, midY:Number, radius:Number, 
											 thickness:Number=2, lineAlpha:Number=1):void 
		{
			if ((radius > 0) && (thickness > 0) && (lineAlpha > 0)) 
			{
				// draw the gradient lines - the matrix rotation 
				// value changes to give the spinning appearance
				g.lineStyle(thickness);
				
				if (matrix == null) 
					matrix = new Matrix();
				
				var gradientAngle:Number = currentPosition * ANGLE_INCREMENT;
				var avg:uint = average(highlight, color); 
				
				matrix.createGradientBox(2 * radius, 2 * radius, gradientAngle, midX - radius, midY - radius);
				
				g.lineGradientStyle(GradientType.LINEAR, [color, avg, highlight], 
					[lineAlpha, lineAlpha, lineAlpha], [0, 128, 255], matrix);
				
				var angle:Number = 0;
				var incr:Number = MAX_ANGLE / 12;
				
				while (angle < MAX_ANGLE) 
				{
					// figure out the position around the outer circle
					// also adjust keep the small lines inside the bounds
					var x1:Number = midX + (radius * Math.sin(angle)) - (1 * Math.sin(angle));
					var y1:Number = midY - (radius * Math.cos(angle)) + (1 * Math.cos(angle));
					
					// make a hole in the center?
					var x2:Number = midX + (3 * Math.sin(angle));
					var y2:Number = midY - (3 * Math.cos(angle));
					g.moveTo(x1, y1);
					g.lineTo(x2, y2);
					
					angle += incr;
				}
			}
		}
		
		/**
		 * Draws a small line from the given points.
		 */
		protected function drawLine(g:Graphics, color:uint, x1:Number, 
									y1:Number, x2:Number, y2:Number, 
									thickness:int = 2, lineAlpha:Number = 1):void 
		{
			if ((thickness > 0) && (lineAlpha > 0)) 
			{
				// draw the line
				g.lineStyle(thickness, color, lineAlpha, true);
				g.moveTo(x1, y1);
				g.lineTo(x2, y2);
			}
		}
		
		/**
		 * Draws the spinner depending on the spinner styles 
		 * and the spinner type.
		 */
		protected function drawSpinner(g:Graphics, w:Number, h:Number):void 
		{
			var spinnerAlpha:Number = getNumberStyle("spinnerAlpha", 1);
			
			if (spinnerAlpha == 0) 
				return;
			
			var normal:uint = uint(getStyle("spinnerColor"));
			var highlight:uint = uint(getStyle("spinnerHighlightColor"));
			var thickness:Number = getNumberStyle("spinnerThickness", 3);
			var lineThickness:Number = getNumberStyle("spinnerLineThickness", 2);
			
			var midX:Number = Math.floor(w / 2);
			var midY:Number = Math.floor(h / 2);
			var diameter:Number = Math.min(w, h);
			var radius:int = Math.floor(diameter / 2);
			
			var spinnerType:String = getStyle("spinnerType");
			
			if (spinnerType == null) 
				spinnerType = GRADIENT_CIRCLE;
			
			var drawLines:Boolean = (spinnerType == LINES);
			var drawCircles:Boolean = (spinnerType == CIRCLES);
			
			if (drawLines || drawCircles) 
			{
				var smallRadius:int = int(Math.min(w, h) / 8);
				var angle:Number = 0;
				var count:int = 0;
				
				while (angle < MAX_ANGLE) 
				{
					// figure out the position around the outer circle
					// also adjust for the small radius to keep the small circles/lines inside the bounds
					var x1:Number = midX + (radius * Math.sin(angle)) - (smallRadius * Math.sin(angle));
					var y1:Number = midY - (radius * Math.cos(angle)) + (smallRadius * Math.cos(angle));
					var color:uint = (count == currentPosition ? highlight : normal);
					
					if (drawLines) 
					{
						var x2:Number = midX;
						var y2:Number = midY;
						
						// make a hole in the center?
						x2 = x2 + (3 * Math.sin(angle));
						y2 = y2 - (3 * Math.cos(angle));
						
						drawLine(g, color, x1, y1, x2, y2, lineThickness, spinnerAlpha);
					} 
					else if (drawCircles) 
					{
						drawCircle(g, color, x1, y1, smallRadius, spinnerAlpha);
					}
					
					angle += ANGLE_INCREMENT;
					count++;
				}
			} 
			else if (spinnerType == GRADIENT_LINES) 
			{
				drawGradientLines(g, normal, highlight, midX, midY, radius, lineThickness, spinnerAlpha);
			} 
			else 
			{
				// draw a large solid spinning circle
				radius = Math.floor(diameter - thickness - 1) / 2; // keep the circle inside the bounds
				drawGradientCircle(g, normal, highlight, midX, midY, radius, thickness, spinnerAlpha);
			}
		}
		
		/**
		 * Fills the background using the backgroundAlpha and backgroundColor styles.
		 */
		protected function fillBackground(g:Graphics, w:Number, h:Number):void 
		{
			var bgAlpha:Number = getNumberStyle("backgroundAlpha", 1);
			var color:Number = Number(getStyle("backgroundColor"));
			
			if (!isNaN(color) && (bgAlpha > 0) && (bgAlpha <= 1)) 
			{
				g.lineStyle(0, 0, 0);
				g.beginFill(uint(color), bgAlpha);
				g.drawRect(0, 0, w, h);
				g.endFill();
			}
		}
		
		/**
		 * Returns a numeric style value as a Number type.
		 * 
		 * @param styleProp Name of the style property.
		 * 
		 * @param defaultValue The default value to be returned if no style 
		 * exists under the styleProp name.
		 */
		protected function getNumberStyle(styleProp:String, defaultValue:Number):Number 
		{
			var num:Number = getStyle(styleProp);
			
			if (isNaN(num)) 
				num = defaultValue;
			
			return num;
		}
		
		/**
		 * Starts the progess spinning animation by using a timer.
		 */
		public function start():void 
		{
			if (!timer.running) 
			{
				timer.addEventListener(TimerEvent.TIMER, timer_timerHandler);
				timer.start();
			}
		}
		
		/**
		 * Stops the progess spinning animation by stopping a timer.
		 */
		public function stop():void 
		{
			if (timer.running) 
			{
				timer.removeEventListener(TimerEvent.TIMER, timer_timerHandler);
				timer.stop();
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * Just a safeguard to make sure the timer is always stopped if this 
		 * component has been removed from the display list.
		 */
		private function removedHandler(event:Event):void 
		{
			stop();
		}
		
		/**
		 * @private
		 */
		private function timer_timerHandler(event:TimerEvent):void 
		{
			currentPosition = (currentPosition + 1) % POSITIONS;
			invalidateDisplayList();
		}
	}
}