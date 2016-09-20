package org.bigbluebutton.air.presentation.views {
	
	import flash.display.StageOrientation;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	import mx.controls.SWFLoader;
	import mx.core.FlexGlobals;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.VideoDisplay;
	
	import org.bigbluebutton.air.video.views.videochat.VideoChatVideoView;
	import org.bigbluebutton.lib.presentation.models.Slide;
	import org.bigbluebutton.lib.whiteboard.views.WhiteboardCanvas;
	
	public class PresentationView extends PresentationViewBase implements IPresentationViewAir {
		private var webcam:VideoChatVideoView;
		
		public function get videoStream():VideoDisplay {
			return videostream;
		}
		
		public function get showSharedCams():Label {
			return showSharedCams0;
		}
		
		public function get showSharedCamsGroup():Group {
			return showSharedCamsGroup0;
		}
		
		public function get content():Group {
			return content0;
		}
		
		public function get viewport():Group {
			return viewport0;
		}
		
		public function get slide():SWFLoader {
			return slide0;
		}
		
		public function get whiteboardCanvas():WhiteboardCanvas {
			return whiteboardCanvas0;
		}
		
		public function setPresentationName(name:String):void {
			FlexGlobals.topLevelApplication.topActionBar.pageName.text = name;
		}
		
		public function setSlide(s:Slide):void {
			if (s != null) {
				var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain, null);
				context.allowCodeImport = true;
				slide.loaderContext = context;
				slide.source = s.SWFFile.source;
			} else {
				slide.source = null;
			}
		}
		
		override public function rotationHandler(rotation:String):void {
			switch (rotation) {
				case StageOrientation.ROTATED_LEFT:
					viewport.rotation = -90;
					viewport.scaleX = viewport.scaleY = slide.height / slide.width;
					break;
				case StageOrientation.ROTATED_RIGHT:
					viewport.rotation = 90;
					viewport.scaleX = viewport.scaleY = slide.height / slide.width;
					break;
				case StageOrientation.UPSIDE_DOWN:
					viewport.rotation = 180;
					viewport.scaleX = viewport.scaleY = 1;
					break;
				case StageOrientation.DEFAULT:
				case StageOrientation.UNKNOWN:
				default:
					viewport.rotation = 0;
					viewport.scaleX = viewport.scaleY = 1;
			}
		}
		
		public function startStream(connection:NetConnection, name:String, streamName:String, userID:String, width:Number, height:Number, screenHeight:Number, screenWidth:Number):void {
			if (webcam) {
				stopStream();
			}
			webcam = new VideoChatVideoView();
			webcam.percentWidth = 100;
			webcam.percentHeight = 100;
			videoStream.addChild(webcam.videoViewVideo);
			this.videoGroup0.addElement(webcam);
			var topActionBarHeight:Number = FlexGlobals.topLevelApplication.topActionBar.height;
			var bottomMenuHeight:Number = FlexGlobals.topLevelApplication.bottomMenu.height;
			webcam.initializeScreenSizeValues(width, height, screenHeight, screenWidth, topActionBarHeight, bottomMenuHeight);
			webcam.startStream(connection, name, streamName, userID);
			webcam.setVideoPosition(name);
		}
		
		public function stopStream():void {
			if (webcam) {
				webcam.close();
				if (this.videoGroup0.containsElement(webcam)) {
					this.videoGroup0.removeElement(webcam);
				}
				webcam = null;
			}
		}
		
		public function get video():Video {
			if (webcam) {
				return webcam.videoViewVideo;
			} else {
				return null;
			}
		}
		
		public function get videoGroup():Group {
			return videoGroup0;
		}
		
		public function dispose():void {
			stopStream();
		}
	}
}
