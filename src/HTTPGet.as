package {
	import flash.text.*;
	import flash.external.*;
	import mx.core.*;
	import mx.utils.*;
	import mx.events.*;
	import flash.utils.Timer;
	import flash.ui.*;
	import flash.events.*;
	import flash.display.Sprite;
	import flash.display.LoaderInfo;
	import flash.system.Security;
	import flash.system.SecurityPanel;
    import flash.net.*;

	public class HTTPGet extends Sprite {

		public static function log(msg:String):void {
			// TODO - come up with something that works on firefox...
			//ExternalInterface.call("function(msg) { if(typeof(console) != 'undefined' && console.log) { console.log(msg); } else { alert(msg); } }", msg);
			ExternalInterface.call("console.log", msg);
		}
		public static function callJs(functionName:String, ...args):void {
			// Debugging js is easier if our js code doesn't have
			// to run in the context of the flash applet. I imagine
			// things will also be a bit faster.
			// Since this is nonblocking, we can't read a return
			// value from js.
			ExternalInterface.call("function(args) { setTimeout(function() { " + functionName + ".apply(null, args); }, 0); }", args);
		}
		public static function assert(expression:Boolean):void {
			if(!expression) {
				throw new Error("Assertion failed!");
			}
		}

		private static var updateCallback:String;
		private static var errorCallback:String;
        private static var jsCallbackFunctionName:String;
        private var loader:URLLoader = new URLLoader();

		public function HTTPGet() {
			try {
                configureListeners(loader);
				var font:TextFormat = new TextFormat();
				font.font = "Arial";
				font.size = 40;

				var micState:UITextField = new UITextField();
				micState.y += 20;
				micState.width = 500; // TODO - magic number
				micState.wordWrap = true;
				micState.autoSize = TextFieldAutoSize.LEFT;
				micState.setTextFormat(font);
				addChild(micState);

				var params:Object = LoaderInfo(this.root.loaderInfo).parameters;
				updateCallback = params.updateCallback;
				errorCallback = params.errorCallback;

				ExternalInterface.addCallback("get", function(url:String, functionName:String):void {
                    Security.allowDomain('google.com');
                    var request:URLRequest = new URLRequest(url);
                    try {
                        jsCallbackFunctionName = functionName;
                        loader.load(request);
                    } catch (error:Error) {
                        callJs(jsCallbackFunctionName, "unable to load requested doc");
                        trace("Unable to load requested document.");
                    }
                    callJs(functionName, url);
				});
				ExternalInterface.addCallback("ping", function():Boolean {
					return true;
				});
                callJs('HTTPGetLoadedCallback', 'true');
			} catch(e:Error) {
                callJs('HTTPGetLoadedCallback', 'false');
				handleError(this, e);
			}
		}

        private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }

        private function completeHandler(event:Event):void {
            var loader:URLLoader = URLLoader(event.target);
            trace("completeHandler: " + loader.data);
            callJs("foo", loader.data);
        }

        private function openHandler(event:Event):void {
            trace("openHandler: " + event);
            callJs("foo", "openHandler: " + event);
        }

        private function progressHandler(event:ProgressEvent):void {
            trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
            trace("securityErrorHandler: " + event);
            callJs("foo", "securityErrorHandler: " + event);
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
            trace("httpStatusHandler: " + event);
            callJs("foo", "httpStatusHandler: " + event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event);
            callJs("foo", "ioErrorHandler: " + event);
        }

		public static function handleError(source:Object, e:Error):void {
			try {
				var objError:Object = {};
				objError.message = e.message;
				objError.stackTrace = e.getStackTrace();
				objError.source = source.toString();
				callJs(errorCallback, objError);
			} catch(ee:Error) {
				var msg:String = "Error calling " + errorCallback + ".";
				msg += " " + e.message;
				log(msg);
				log('    ' + ee.message);
			}
		}
	}
}
