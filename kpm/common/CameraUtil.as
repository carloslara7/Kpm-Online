/**
 * Created with IntelliJ IDEA.
 * User: carloslara
 * Date: 10/31/13
 * Time: 10:11 AM
 * To change this template use File | Settings | File Templates.
 */
package com.kpm.common {


import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MediaEvent;
import flash.filesystem.File;
import flash.media.CameraRoll;
import flash.media.CameraUI;
import flash.media.MediaPromise;
import flash.media.MediaType;

[Event(name = "fileReady", type = "events.CameraEvent")]
public class CameraUtil extends EventDispatcher
{
    protected var camera:CameraUI;
    protected var loader:Loader;
    public var file:File;
    public var bitmapData:BitmapData;

    public function CameraUtil()
    {
        if (CameraUI.isSupported)
        {
            Util.debug("CameraUtil.CameraUtil : Camera is supported")
            camera = new CameraUI();
            camera.addEventListener(MediaEvent.COMPLETE, mediaEventComplete);
        }
    }

    public function takePicture():void
    {
        if (camera)
            camera.launch(MediaType.IMAGE);
    }

    protected function mediaEventComplete(event:MediaEvent):void
    {
        Util.debug("media event complete")

        var mediaPromise:MediaPromise = event.data;

        if (mediaPromise.file == null)
        {
            // For iOS we need to load with a Loader first
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleted);
            loader.loadFilePromise(mediaPromise);

            return;
        }
        else
        {
            // Android we can just dispatch the event that it's complete
            file = new File(mediaPromise.file.url);
            dispatchEvent(new Event("BMPDATA_READY", file));
        }
    }

    protected function loaderCompleted(event:Event):void
    {
        camera.launch(MediaType.IMAGE);
        dispatchEvent(new Event("BMPDATA_READY"));

        var loaderInfo:LoaderInfo = event.target as LoaderInfo;
        if (CameraRoll.supportsAddBitmapData)
        {
            Util.debug("camera roll supports bitmapdata");
            bitmapData = new BitmapData(loaderInfo.width, loaderInfo.height);
            bitmapData.draw(loaderInfo.loader);
            dispatchEvent(new Event("BMPDATA_READY"));

            //file = File.applicationStorageDirectory.resolvePath("qrCode" + new Date().time + ".jpg");
            //var stream:FileStream = new FileStream()
            //stream.open(file, FileMode.WRITE);
            //var j:JPEGEncoder = new JPEGEncoder();
            //var bytes:ByteArray = j.encode(bitmapData);
            //stream.writeBytes(bytes, 0, bytes.bytesAvailable);
            //stream.close();
            //trace(file.url);

        }
    }

}
}