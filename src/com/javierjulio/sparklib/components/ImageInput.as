package com.javierjulio.sparklib.components
{
	import com.adobe.net.MimeTypeMap;
	import com.adobe.serialization.json.JSON;
	import com.adobe.utils.StringUtil;
	import com.javierjulio.mxlib.utils.LogUtil;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	import mx.controls.Image;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.logging.ILogger;
	import mx.managers.IFocusManagerComponent;
	import mx.rpc.xml.SimpleXMLDecoder;
	
	import spark.components.supportClasses.ButtonBase;
	import spark.components.supportClasses.SkinnableComponent;
	import spark.components.supportClasses.TextBase;
	
	[Event(name="cancel", type="flash.events.Event")]
	
	[Event(name="complete", type="flash.events.Event")]
	
	[Event(name="httpStatus", type="flash.events.HTTPStatusEvent")]
	
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	
	[Event(name="open", type="flash.events.Event")]
	
	[Event(name="progress", type="flash.events.Event")]
	
	[Event(name="securityError", type="flash.events.SecurityErrorEvent")]
	
	[Event(name="select", type="flash.events.Event")]
	
	[Event(name="uploadCompleteData", type="flash.events.DataEvent")]
	
	//--------------------------------------
	//  Skin states
	//--------------------------------------
	
	/**
	 * Normal State of the ImageInput
	 */
	[SkinState("normal")]
	
	/**
	 * Disabled State of the ImageInput
	 */
	[SkinState("disabled")]
	
	/**
	 * Choosing State of the ImageInput
	 */
	[SkinState("choosing")]
	
	/**
	 * Selected State of the ImageInput
	 */
	[SkinState("selected")]
	
	/**
	 * Uploading State of the ImageInput
	 */
	[SkinState("uploading")]
	
	/**
	 * The ImageInput control defines a button that when clicked the user can 
	 * select an image file to upload. The name of the selected file and a preview 
	 * of the image are displayed.
	 * 
	 * @mxml <p>The <code>&lt;s:ButtonBar&gt;</code> tag inherits all of the tag 
	 * attributes of its superclass and adds the following tag attributes:</p>
	 * 
	 * <pre>
	 * &lt;components:ImageInput
	 * 	 <strong>Properties</strong>
	 *   allowedTypes="*.gif;*.jpeg;*.jpg;*.png;"
	 *   file="null"
	 *   label=""
	 *   maxImageHeight="NaN"
	 *   maxImageWidth="NaN"
	 *   minImageHeight="NaN"
	 *   minImageWidth="NaN"
	 *   result="null"
	 *   resultFormat=""
	 *   source=""
	 *   url=""
	 *   urlRequestFunction="null"
	 * /&gt;
	 * </pre>
	 * 
	 * @see com.ninem.spark.skins.ImageInputSkin
	 */
	public class ImageInput extends SkinnableComponent implements IFocusManagerComponent
	{
		//--------------------------------------------------------------------------
		//
		//  Class constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 */
		private static const LOGGER:ILogger = LogUtil.getLogger(ImageInput);
		
		/**
		 * @private
		 */
		private static const MIME_TYPES:MimeTypeMap = new MimeTypeMap();
		
		/**
		 * The result format "e4x" specifies that the value returned is an XML 
		 * instance, which can be accessed using ECMAScript for XML (E4X) 
		 * expressions.
		 * 
		 * @default "e4x"
		 */
		public static const RESULT_FORMAT_E4X:String = "e4x";
		
		/**
		 * The result format "json" specifies that the value returned is JSON, 
		 * which is parsed into an ActionScript object.
		 * 
		 * @default "json"
		 */
		public static const RESULT_FORMAT_JSON:String = "json";
		
		/**
		 * The result format "object" specifies that the value returned is XML 
		 * but is parsed as a tree of ActionScript objects. This is the default.
		 * 
		 * @default "object"
		 */
		public static const RESULT_FORMAT_OBJECT:String = "object";
		
		/**
		 * The result format "text" specifies that the HTTPService result text 
		 * should be an unprocessed String.
		 * 
		 * @default "text"
		 */
		public static const RESULT_FORMAT_TEXT:String = "text";
		
		/**
		 * The result format "xml" specifies that results should be returned as 
		 * an flash.xml.XMLNode instance pointing to the first child of the 
		 * parent flash.xml.XMLDocument.
		 * 
		 * @default "xml"
		 */
		public static const RESULT_FORMAT_XML:String = "xml";
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function ImageInput()
		{
			super();
			
			hasFocusableChildren = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Skin Parts
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  chooseControl
		//----------------------------------
		
		[SkinPart(required="true")]
		/**
		 * The Choose File button to select the desired image.
		 */
		public var chooseControl:ButtonBase;
		
		//----------------------------------
		//  noImageDisplay
		//----------------------------------
		
		[SkinPart(required="false")]
		/**
		 * The display label when no image is selected.
		 */
		public var noImageDisplay:TextBase;
		
		//----------------------------------
		//  previewDisplay
		//----------------------------------
		
		[SkinPart(required="false")]
		/**
		 * The image control to preview the image.
		 */
		public var previewDisplay:Image;
		
		//----------------------------------
		//  statusIndicator
		//----------------------------------
		
		[SkinPart(required="false")]
		/**
		 * The progress indicator control to show that the file is being uploaded.
		 */
		public var statusIndicator:UIComponent;
		
		//----------------------------------
		//  textDisplay
		//----------------------------------
		
		[SkinPart(required="false")]
		/**
		 * The text control to display the name of the selected file.
		 */
		public var textDisplay:TextBase;
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  allowedTypes
		//----------------------------------
		
		/**
		 * A list of allowed file types that can be selected when browsing.
		 * 
		 * @default "*.gif;*.jpeg;*.jpg;*.png;"
		 */
		public var allowedTypes:String = "*.gif;*.jpeg;*.jpg;*.png;";
		
		//----------------------------------
		//  choosing
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _choosing:Boolean = false;
		
		/**
		 * Indicates whether the browse window is open so the user can choose a 
		 * file. Used to determine the skin state.
		 * 
		 * @default false
		 */
		protected function get choosing():Boolean 
		{
			return _choosing;
		}
		
		/**
		 * @private
		 */
		protected function set choosing(value:Boolean):void 
		{
			if (value == _choosing) 
				return;
			
			_choosing = value;
			invalidateSkinState();
		}
		
		//----------------------------------
		//  file
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _file:FileReference;
		
		/**
		 * The FileReference object used to allow the user to select and upload a 
		 * file.
		 * 
		 * <p>Only when the <code>url</code> property is set will an upload happen 
		 * on selecting a file. Otherwise if not provided it is expected that the 
		 * upload is handled manually.</p>
		 */
		public function get file():FileReference 
		{
			return _file;
		}
		
		//----------------------------------
		//  label
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _label:String = "";
		
		/**
		 * The label that is displayed when no text is entered.
		 * 
		 * @default ""
		 */
		public function get label():String 
		{
			return _label;
		}
		
		/**
		 * @private
		 */
		public function set label(value:String):void 
		{
			if (value == _label) 
				return;
			
			_label = value;
			
			if (textDisplay) 
			{
				textDisplay.text = value;
			}
		}
		
		//----------------------------------
		//  maxImageHeight
		//----------------------------------
		
		/**
		 * The maximum allowed height of the selected image. If only this property 
		 * is set and the selected image is greather than the maximum height, the 
		 * component is reset to disallow the chosen image.
		 * 
		 * <p>If both <code>maxImageHeight</code> and <code>maxImageWidth</code> 
		 * properties are set, any size that meets both those values and smaller 
		 * are allowed and vice versa for the max related properties. To have the 
		 * selected image only be one allowed size, e.g. 1024x768, then set both 
		 * <code>maxImageWidth</code> and <code>minImageWidth</code> to 1024 and 
		 * both <code>minImageHeight</code> <code>minImageHeight</code> to 768.</p>
		 * 
		 * <p>Tip: Use the <code>label</code> property to display a small message 
		 * within the preview display box that states the required size.</p>
		 * 
		 * @default NaN
		 */
		public var maxImageHeight:Number;
		
		//----------------------------------
		//  maxImageWidth
		//----------------------------------
		
		/**
		 * The maximum allowed width of the selected image. If only this property 
		 * is set and the selected image is greather than the maximum width, the 
		 * component is reset to disallow the chosen image.
		 * 
		 * <p>If both <code>maxImageHeight</code> and <code>maxImageWidth</code> 
		 * properties are set, any size that meets both those values and smaller 
		 * are allowed and vice versa for the max related properties. To have the 
		 * selected image only be one allowed size, e.g. 1024x768, then set both 
		 * <code>maxImageWidth</code> and <code>minImageWidth</code> to 1024 and 
		 * both <code>minImageHeight</code> <code>minImageHeight</code> to 768.</p>
		 * 
		 * <p>Tip: Use the <code>label</code> property to display a small message 
		 * within the preview display box that states the required size.</p>
		 * 
		 * @default NaN
		 */
		public var maxImageWidth:Number;
		
		//----------------------------------
		//  minImageHeight
		//----------------------------------
		
		/**
		 * The minimum allowed height of the selected image. If only this property 
		 * is set and the selected image is smaller than the minimum height, the 
		 * component is reset to disallow the chosen image.
		 * 
		 * <p>If both <code>minImageHeight</code> and <code>minImageWidth</code> 
		 * properties are set, any size that meets both those values and greater 
		 * are allowed and vice versa for the max related properties. To have the 
		 * selected image only be one allowed size, e.g. 1024x768, then set both 
		 * <code>maxImageWidth</code> and <code>minImageWidth</code> to 1024 and 
		 * both <code>minImageHeight</code> <code>minImageHeight</code> to 768.</p>
		 * 
		 * <p>Tip: Use the <code>label</code> property to display a small message 
		 * within the preview display box that states the required size.</p>
		 * 
		 * @default NaN
		 */
		public var minImageHeight:Number;
		
		//----------------------------------
		//  minImageWidth
		//----------------------------------
		
		/**
		 * The minimum allowed width of the selected image. If only this property 
		 * is set and the selected image is smaller than the minimum height, the 
		 * component is reset to disallow the chosen image.
		 * 
		 * <p>If both <code>minImageHeight</code> and <code>minImageWidth</code> 
		 * properties are set, any size that meets both those values and greater 
		 * are allowed and vice versa for the max related properties. To have the 
		 * selected image only be one allowed size, e.g. 1024x768, then set both 
		 * <code>maxImageWidth</code> and <code>minImageWidth</code> to 1024 and 
		 * both <code>minImageHeight</code> <code>minImageHeight</code> to 768.</p>
		 * 
		 * <p>Tip: Use the <code>label</code> property to display a small message 
		 * within the preview display box that states the required size.</p>
		 * 
		 * @default NaN
		 */
		public var minImageWidth:Number;
		
		//----------------------------------
		//  result
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _result:Object;
		
		/**
		 * 
		 */
		public function get result():Object 
		{
			return _result;
		}
		
		/**
		 * @private
		 */
		public function set result(value:Object):void 
		{
			_result = value;
		}
		
		//----------------------------------
		//  resultFormat
		//----------------------------------
		
		[Inspectable(enumeration="e4x,json,none,object,text,xml", defaultValue="text", category="General")]
		
		/**
		 * 
		 */
		public var resultFormat:String;
		
		//----------------------------------
		//  source
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _source:String = "";
		
		/**
		 * 
		 */
		public function get source():String 
		{
			return _source;
		}
		
		/**
		 * @private
		 */
		public function set source(value:String):void 
		{
			if (value == null) 
				value = "";
			
			_source = value;
			
			if (_source) 
			{
				//trace('source set');
				setSelected(true);
				setUploaded(true);
				setUploading(false);
				choosing = false;
				//trace('hasPreview?',(previewDisplay!= null));
				if (previewDisplay) 
				{
					previewDisplay.source = _source;
					previewDisplay.toolTip = "";
				}
			} 
			else 
			{
				setSelected(false);
				setUploaded(false);
				setUploading(false);
				choosing = false;
				
				if (previewDisplay) 
				{
					previewDisplay.toolTip = "";
					previewDisplay.unloadAndStop();
				}
			}
		}
		
		//----------------------------------
		//  selected
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _selected:Boolean = false;
		
		[Bindable("selectedChanged")]
		
		/**
		 * Indicates whether a file has been selected from the browse window. Used 
		 * to determine the skin state.
		 * 
		 * @default false
		 */
		public function get selected():Boolean 
		{
			return _selected;
		}
		
		/**
		 * @private
		 */
		protected function setSelected(value:Boolean):void 
		{
			if (value == _selected) 
				return;
			
			_selected = value;
			
			invalidateSkinState();
			
			dispatchEvent(new Event("selectedChanged"));
			
			// trigger validation
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		//----------------------------------
		//  testUpload
		//----------------------------------
		
		/**
		 * Proxied to FileReference when uploading a file.
		 * 
		 * <p>A setting to request a test file upload. If <code>testUpload</code> 
		 * is <code>true</code>, for files larger than 10 KB, Flash Player attempts 
		 * a test file upload <code>POST</code> with a Content-Length of 0. The 
		 * test upload checks whether the actual file upload will be successful and 
		 * that server authentication, if required, will succeed. A test upload is 
		 * only available for Windows players.</p>
		 * 
		 * @default false
		 */
		public var testUpload:Boolean = false;
		
		//----------------------------------
		//  uploadDataField
		//----------------------------------
		
		/**
		 * Proxied to FileReference when uploading a file.
		 * 
		 * <p>The field name that precedes the file data in the upload 
		 * <code>POST</code> operation. The <code>uploadDataFieldName</code> value 
		 * must be non-null and a non-empty String. By default, the value of 
		 * <code>uploadDataFieldName</code> is "<code>Filedata</code>".</p>
		 * 
		 * @default "Filedata"
		 */
		public var uploadDataField:String = "Filedata";
		
		//----------------------------------
		//  uploaded
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _uploaded:Boolean = false;
		
		[Bindable("uploadedChanged")]
		
		/**
		 * Indicates whether a file has been uploaded successfully.
		 * 
		 * @default false
		 */
		public function get uploaded():Boolean 
		{
			return _uploaded;
		}
		
		/**
		 * @private
		 */
		private function setUploaded(value:Boolean):void 
		{
			if (value == _uploaded) 
				return;
			
			_uploaded = value;
			
			dispatchEvent(new Event("uploadedChanged"));
			
			// trigger validation
			dispatchEvent(new FlexEvent(FlexEvent.VALUE_COMMIT));
		}
		
		//----------------------------------
		//  uploading
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _uploading:Boolean = false;
		
		[Bindable("uploadingChanged")]
		
		/**
		 * Indicates whether the selected file is being uploaded. Used to 
		 * determine the skin state.
		 * 
		 * @default false
		 */
		public function get uploading():Boolean 
		{
			return _uploading;
		}
		
		/**
		 * @private
		 */
		protected function setUploading(value:Boolean):void 
		{
			if (value == _uploading) 
				return;
			
			_uploading = value;
			
			invalidateSkinState();
			
			dispatchEvent(new Event("uploadingChanged"));
		}
		
		//----------------------------------
		//  url
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _url:String = "";
		
		/**
		 * The URL to where the selected file should be uploaded to. Only when the 
		 * <code>url</code> property is set will an upload happen on selecting a 
		 * file. Otherwise if neither are provided it is expected that the parent 
		 * will take the file reference object using the <code>file</code> 
		 * property to perform the upload manually.
		 * 
		 * @default ""
		 */
		public function get url():String 
		{
			return _url;
		}
		
		/**
		 * @private
		 */
		public function set url(value:String):void 
		{
			if (value == _url) 
				return;
			
			_url = value;
		}
		
		//----------------------------------
		//  urlRequestFunction
		//----------------------------------
		
		/**
		 * @private
		 */
		private var _urlRequestFunction:Function;
		
		/**
		 * A user-supplied function to modify an upload request to determine 
		 * the necessary data for the request such as request headers, content 
		 * type, etc. Only the <code>url</code> property is necessary to perform 
		 * an upload on selecting a file. This is optional as it just allows 
		 * further control over how the URLRequest is constructed.
		 * 
		 * <p>You can supply a <code>urlRequestFunction</code> that determines 
		 * how to construct and populate a <code>URLRequest</code> instance.</p>
		 * 
		 * <p>The function takes a single argument which is the URLRequest instance 
		 * created by this component beforehand and populated with the provided URL, 
		 * the appropriate content type (mime type) and a method of "POST". The 
		 * same instance must be returned but with any user changes:</p>
		 * <pre>
		 * myURLRequestFunction(request:URLRequest):URLRequest</pre>
		 * 
		 * @default null
		 */
		public function get urlRequestFunction():Function 
		{
			return _urlRequestFunction;
		}
		
		/**
		 * @private
		 */
		public function set urlRequestFunction(value:Function):void 
		{
			if (value == _urlRequestFunction) 
				return;
			
			_urlRequestFunction = value;
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
			//trace(!enabled, uploading, selected, choosing);
			if (!enabled) 
				return "disabled";
			
			if (uploading) 
				return "uploading";
			
			if (selected) 
				return "selected";
			
			if (choosing) 
				return "choosing";
			
			return "normal";
		}
		
		/**
		 * @private
		 */
		override protected function partAdded(partName:String, instance:Object):void 
		{
			super.partAdded(partName, instance);
			
			if (instance == chooseControl) 
			{
				chooseControl.addEventListener(MouseEvent.CLICK, chooseControl_clickHandler);
			} 
			else if (instance == textDisplay) 
			{
				textDisplay.text = label;
			} 
			else if (instance == previewDisplay) 
			{
				if (_source && _result) 
				{
					setSelected(true);
					setUploaded(true);
					setUploading(false);
					choosing = false;
					
					previewDisplay.source = _source;
					previewDisplay.toolTip = "";
				}
			}
		}
		
		/**
		 * @private
		 */
		override protected function partRemoved(partName:String, instance:Object):void 
		{
			super.partRemoved(partName, instance);
			
			if (instance == chooseControl) 
			{
				chooseControl.removeEventListener(MouseEvent.CLICK, chooseControl_clickHandler);
			}
		}
		
		/**
		 * @private
		 * Focus should always be on the internal Button that allows file browsing.
		 */
		override public function setFocus():void 
		{
			chooseControl.setFocus();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Resets component by setting all flags to false, any skin part values if 
		 * they exist and lastly invalidating the skin state.
		 */
		public function reset():void 
		{
			if (_file) 
			{
				// just in case cancel anything going on, note that calling cancel 
				// does not clear out the name, size, etc. FileReference properties 
				// so we'll nullify the file ref instance
				_file.cancel();
				_file = null;
			}
			
			if (previewDisplay) 
			{
				previewDisplay.toolTip = "";
				previewDisplay.unloadAndStop();
			}
			
			choosing = false;
			setSelected(false);
			setUploading(false);
			setUploaded(false);
		}
		
		/**
		 * Starts the file uploading process only if a <code>url</code> and 
		 * <code>urlRequestFunction</code> have been provided.
		 */
		protected function upload():void 
		{
			if (url) 
			{
				// determine the mimetype based on the extension in the file name
				var extIndex:int = file.name.lastIndexOf(".") + 1;
				var mimeType:String = MIME_TYPES.getMimeType(file.name.substring(extIndex));
				
				// prepare the URL request and allow any developer specific modifications
				var urlRequest:URLRequest = new URLRequest(url);
				urlRequest.contentType = mimeType;
				urlRequest.method = URLRequestMethod.POST;
				
				// providing a url request function is optional, allows consumer 
				// to customize the url request anyway they like
				if (urlRequestFunction != null) 
					urlRequest = urlRequestFunction(urlRequest);
				
				file.addEventListener(Event.COMPLETE, file_uploadCompleteHandler);
				file.addEventListener(IOErrorEvent.IO_ERROR, file_ioErrorHandler);
				file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, file_securityErrorHandler);
				file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, file_uploadCompleteDataHandler);
				
				// UPLOAD!
				try 
				{
					file.upload(urlRequest, uploadDataField, testUpload);
				} 
				catch (error:Error) {}
				
				LOGGER.info('Uploading image "{0}" ({1}).', file.name, file.size);
				
				setUploading(true);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		/**
		 * When the user clicks the Choose button we set the <code>choosing</code> 
		 * flag to true, invalidate the skin state and setup our FileReference 
		 * object so the user can browse and select an image file.
		 * 
		 * @param event The event object.
		 */
		protected function chooseControl_clickHandler(event:MouseEvent):void 
		{
			choosing = true;
			setUploading(false);
			
			_file = new FileReference();
			_file.addEventListener(Event.SELECT, file_selectHandler);
			_file.addEventListener(Event.CANCEL, file_cancelHandler);
			_file.browse([new FileFilter("Images", allowedTypes)]);
		}
		
		/**
		 * If the user closes or cancels out of the file selection window we set 
		 * the <code>choosing</code> flag to false and invalidate the skin state.
		 * 
		 * @param event The event object.
		 */
		protected function file_cancelHandler(event:Event):void 
		{
			file.removeEventListener(Event.CANCEL, file_cancelHandler);
			file.removeEventListener(Event.SELECT, file_selectHandler);
			
			choosing = false;
			
			dispatchEvent(event);
		}
		
		/**
		 * On successfully loading the selected image the preview display control 
		 * is updated to display it and if a <code>url</code> was provided we 
		 * start the file uploading process.
		 * 
		 * @param event The event object.
		 */
		protected function file_completeHandler(event:Event):void 
		{
			file.removeEventListener(Event.COMPLETE, file_completeHandler);
			
			// we have a preview display skin part so show the image as a 
			// preview and handle when the Image control finishes loading 
			// it so we can verify that it meets any max and/or min image 
			// height and width requirements
			if (previewDisplay) 
			{
				previewDisplay.source = file.data;
				previewDisplay.addEventListener(Event.COMPLETE, previewDisplay_completeHandler);
			} 
			else // otherwise just start the upload process
			{
				upload();
			}
			
			dispatchEvent(event);
		}
		
		/**
		 * This component is reset on an IO error. The event that came 
		 * from the FileReference object is redispatched.
		 * 
		 * @param event The event object.
		 */
		protected function file_ioErrorHandler(event:IOErrorEvent):void 
		{
			file.removeEventListener(IOErrorEvent.IO_ERROR, file_ioErrorHandler);
			
			LOGGER.error('Image upload for "{0}" failed due to an IO error. Details: {1}', _file.name, event.text);
			
			reset();
			
			dispatchEvent(event);
		}
		
		/**
		 * This component is reset on a security error. The event that came 
		 * from the FileReference object is redispatched.
		 * 
		 * @param event The event object.
		 */
		protected function file_securityErrorHandler(event:SecurityErrorEvent):void 
		{
			file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, file_securityErrorHandler);
			
			LOGGER.error('Image upload for "{0}" failed due to a security error. Details: {1}', _file.name, event.text);
			
			reset();
			
			dispatchEvent(event);
		}
		
		/**
		 * On the user selecting a file, the text display is updated with the 
		 * name of the file, the flag <code>choosing</code> is set to false, 
		 * <code>fileSelected</code> is set to true, and then a load() call 
		 * is made on the FileReference object so we can display a preview.
		 * 
		 * @param event The event object.
		 */
		protected function file_selectHandler(event:Event):void 
		{
			file.removeEventListener(Event.SELECT, file_selectHandler);
			file.removeEventListener(Event.CANCEL, file_cancelHandler);
			
			setUploaded(false);
			
			choosing = false;
			setSelected(true);
			
			// load the file so we can display a preview
			if (previewDisplay) 
			{
				previewDisplay.toolTip = file.name;
				
				// we'll perform the upload once the image preview is loaded
				file.addEventListener(Event.COMPLETE, file_completeHandler);
				file.load();
			} 
			else 
			{
				// otherwise since the preview is an optional skin part, if 
				// its not defined just start the file uploading process
				upload();
			}
			
			dispatchEvent(event);
		}
		
		/**
		 * 
		 */
		protected function file_uploadCompleteDataHandler(event:DataEvent):void 
		{
			var body:Object = event.data;
			
			LOGGER.info('Data available from uploading image "{0}".', _file.name);
			
			if ((body == null) || ((body != null) && (body is String) && (StringUtil.trim(String(body)) == ""))) 
			{
				result = body;
			} 
			else if (body is String) 
			{
				if (resultFormat == RESULT_FORMAT_XML || resultFormat == RESULT_FORMAT_OBJECT) 
				{
					//old XML style
					var tmp:Object = new XMLDocument();
					XMLDocument(tmp).ignoreWhite = true;
					
					try 
					{
						XMLDocument(tmp).parseXML(String(body));
					} 
					catch (parseError:Error) 
					{
						throw new Error("Client.CouldNotDecode");
					}
					
					if (resultFormat == RESULT_FORMAT_OBJECT) 
					{
						var decoded:Object;
						var msg:String;
						var decoder:SimpleXMLDecoder = new SimpleXMLDecoder();
						
						decoded = decoder.decodeXML(XMLNode(tmp));
						
						if (decoded == null)
						{
							throw new Error("Client.CouldNotDecode");
						}
						
						result = decoded;
					} 
					else 
					{
						if (tmp.childNodes.length == 1)
						{
							tmp = tmp.firstChild;
						}
						
						result = tmp;
					}
				} 
				else if (resultFormat == RESULT_FORMAT_E4X) 
				{
					try 
					{
						result = new XML(String(body));
					}
					catch(error:Error) 
					{
						throw new Error("Client.CouldNotDecode");
					}
				} 
				else if (resultFormat == RESULT_FORMAT_JSON) 
				{
					result = JSON.decode(String(body));
				} 
				else //if only we could assert(theService.resultFormat == "text")
				{
					result = body;
				}
			}
			
			dispatchEvent(event);
		}
		
		/**
		 * On the file being uploaded successfully the <code>uploaded</code> 
		 * and <code>uploading</code> properties are updated. This is the 
		 * second event handler added for the <code>Event.COMPLETE</code> 
		 * dispatched from the FileReference as the other is used for when 
		 * loading the image (preview display) after selection.
		 * 
		 * @param event The event object.
		 */
		protected function file_uploadCompleteHandler(event:Event):void 
		{
			LOGGER.info('Image "{0}" uploaded successfully.', _file.name);
			
			setUploaded(true);
			setUploading(false);
			
			dispatchEvent(event);
		}
		
		/**
		 * When the preview image finishes loading check its width and height 
		 * against the set max and/or min width/height and allow the upload to 
		 * proceed if the size requirements are met. If not, the component is 
		 * reset by calling its <code>reset()</code> method.
		 * 
		 * @param event The event object.
		 */
		protected function previewDisplay_completeHandler(event:Event):void 
		{
			if (previewDisplay) 
			{
				if (previewDisplay.contentHeight > maxImageHeight 
					|| previewDisplay.contentWidth > maxImageWidth 
					|| previewDisplay.contentHeight < minImageHeight 
					|| previewDisplay.contentWidth < minImageWidth) 
				{
					LOGGER.info("The image ({0}x{1}) is not the required size of min {2}x{3} and max {4}x{5}.", 
						previewDisplay.contentWidth, previewDisplay.contentHeight, 
						minImageWidth, minImageHeight, maxImageWidth, maxImageHeight);
					
					reset();
				} 
				else 
				{
					LOGGER.info("The image size {0}x{1} meets the set requirements of min {2}x{3} and max {4}x{5}.", 
						previewDisplay.contentWidth, previewDisplay.contentHeight, 
						minImageWidth, minImageHeight, maxImageWidth, maxImageHeight);
					
					upload();
				}
			}
		}
	}
}