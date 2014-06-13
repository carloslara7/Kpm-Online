/**
 * Created with IntelliJ IDEA.
 * User: carloslara
 * Date: 10/30/13
 * Time: 5:42 PM
 * To change this template use File | Settings | File Templates.
 */
package com.kpm.kpm {

import com.kpm.ui.UIConst;
import com.kpm.ui.UIGod;
import com.kpm.ui.UIPage;
import com.kpm.common.Util;
import com.adobe.images.JPGEncoder;

import flash.events.ErrorEvent;

import flash.events.MediaEvent;
import flash.events.MouseEvent;
import flash.media.Camera;
import flash.media.CameraUI;
import flash.media.MediaType;
import flash.media.Video;
import com.kpm.common.CameraUtil;

import flash.system.Capabilities;

import flash.utils.ByteArray;

//import mx.controls.Image;
import com.google.zxing.common.BitMatrix;
//import mx.core.BitmapAsset;
import com.google.zxing.common.flexdatatypes.HashTable;
import flash.net.FileReference;

import flash.display.Bitmap;
import flash.display.*;
import flash.events.Event;

import com.google.zxing.common.GlobalHistogramBinarizer;
import com.google.zxing.common.ByteMatrix;
import com.google.zxing.client.result.ParsedResult;
import com.google.zxing.client.result.ResultParser;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.BinaryBitmap;
import com.google.zxing.BufferedImageLuminanceSource;
import com.google.zxing.MultiFormatReader;
import com.google.zxing.MultiFormatWriter;
import com.google.zxing.Result;


public class ZxingClient extends UIPage
{


    private var fileRef:FileReference;
    private var myReader:MultiFormatReader;
    private var myWriter:MultiFormatWriter;
    private var cam : CameraUtil;
    private var camera : Camera;
    private var video : Video;



    public function ZxingClient() {
        super(UIConst.QRCodePage);


    }



    public override function showPage(e : Event = null)
    {
        super.showPage();
        init();
    }


        public function init():void
        {
            Util.debug("ZXingClient.init");
            // initialise the generic reader
            myReader = new MultiFormatReader();
            loadCamera(null);


        }

        function loadCamera(e : Event)
        {
            Util.debug("camera loaded")
            camera = getCamera("front");
            var cameraUI : CameraUI;

            this.addEventListener(MouseEvent.CLICK, takePicture)
            //camera.addEventListener(ActivityEvent.ACTIVITY, cameraActivityHandler);


            if (camera != null)
            {
                Util.debug("camera is not null" + camera)
                camera.setMode(400, 300, 25);
                camera.setQuality(0, 100);

                video = new Video(400, 300);
                video.attachCamera(camera);
                video.x = 318;
                video.y = 188;

                addChild(video);

//            }

//            if( CameraUI.isSupported )
//            {
//                cameraUI.addEventListener(MediaEvent.COMPLETE, imageSelected);
//                cameraUI.launch(MediaType.IMAGE);
            } else {
                Util.debug("This device does not support Camera functions.");
            }
        }

        public function takePicture(e : Event)
        {
            var bitmapData:BitmapData = new BitmapData(400, 300);
            bitmapData.draw(video);

            Util.debug("ZxingClient.takePicture " + bitmapData.height + " " + bitmapData.width)

            var encoder:JPGEncoder = new JPGEncoder();
            var byteArray:ByteArray = encoder.encode(bitmapData);

            var fileReference:FileReference = new FileReference();
            fileReference.save(byteArray);

            //var bitmap1:Bitmap = new Bitmap(bitmapData);
            //this.addChild(bitmap1);

            //decodeBitmapData(bitmapData, bitmapData.width, bitmapData.height);

        }

        // Get the requested camera. If it cannot be found,
        // return the device's default camera instead.
        private function getCamera(position:String):Camera
        {


            /*var iOS : Boolean = (Capabilities.manufacturer.indexOf("iOS") != -1)
            var Android : Boolean = (Capabilities.manufacturer.indexOf("Android") != -1)


            if(iOS || Android)
            for (var i:uint = 0; i < Camera.names.length; ++i)
            {
                var cam:Camera = Camera.getCamera(String(i));
                Util.debug("cam" + cam);

                if (cam && cam.position != null)
                    if(cam.position == position)
                        return cam;
            } */

            return Camera.getCamera();
        }


        function pictureTaken(e : Event)
        {

            decodeBitmapData(cam.bitmapData, cam.bitmapData.width, cam.bitmapData.height);

        }


        public function decodeBitmapData(bmpd:BitmapData, width:int, height:int):void
        {
            // create the container to store the image data in
            var lsource:BufferedImageLuminanceSource = new BufferedImageLuminanceSource(bmpd);
            // convert it to a binary bitmap
            var bitmap:BinaryBitmap = new BinaryBitmap(new GlobalHistogramBinarizer(lsource));
            // get all the hints
            var ht:HashTable = null;

            var res:Result = null;
            try
            {
                // try to decode the image
                res = myReader.decode(bitmap,ht);
            }
            catch(e:Error)
            {
                // failed
            }

            // did we find something?
            if (res == null)
            {
                // no : we could not detect a valid barcode in the image
                Util.debug("<<No decoder could read the barcode>>");
            }
            else
            {
                // yes : parse the result
                var parsedResult:ParsedResult = ResultParser.parseResult(res);
                // get a formatted string and display it in our textarea
                Util.debug(parsedResult.getDisplayResult());
            }
        }

/*
        public function getAllHints():HashTable
        {
            // get all hints from the user
            var ht:HashTable = new HashTable();
            if (this.bc_QR_CODE.selected)    { ht.Add(DecodeHintType.POSSIBLE_FORMATS,BarcodeFormat.QR_CODE); }
            return ht;
        }


        public function clearImage():void
        {
            // remove the image
            this.img.source = null;
            this.resulttextarea.text = "";
        }

        public function selectFile():void
        {
            // file open menu
            fileRef = new FileReference();
            var fileFilter4:FileFilter = new FileFilter('JPG','*.jpg');
            var fileFilter1:FileFilter = new FileFilter('PNG','*.png');
            var fileFilter2:FileFilter = new FileFilter('GIF','*.gif');
            var fileFilter3:FileFilter = new FileFilter('All files','*.*');
            fileRef.addEventListener(Event.SELECT, selectHandler);
            fileRef.addEventListener(Event.COMPLETE,completeHandler);
            fileRef.browse([fileFilter4,
                fileFilter1,
                fileFilter2,
                fileFilter3]);
        }

        public function selectHandler(event:Event):void
        {
            // try to load the image
            fileRef.removeEventListener(Event.SELECT, selectHandler);
            fileRef.load();
        }

        public function completeHandler(event:Event):void
        {
            // image loaded succesfully
            fileRef.removeEventListener(Event.COMPLETE,completeHandler);
            img.load(fileRef.data);
        }

        public function selectNone():void
        {
            // remove all hints (except the try harder hint)
            this.bc_QR_CODE.selected = false;
            this.bc_DATAMATRIX.selected = false;
            this.bc_UPC_E.selected = false;
            this.bc_UPC_A.selected = false;
            this.bc_EAN_8.selected = false;
            this.bc_EAN_13.selected = false;
            this.bc_CODE_128.selected = false;
            this.bc_CODE_39.selected = false;
            this.bc_ITF.selected = false;
        }

        private function videoDisplay_creationComplete():void
        {
            // try to attach the webcam to the videoDisplay
            var camera:Camera = Camera.getCamera();
            if (camera)
            {
                if ((camera.width == -1) && ( camera.height == -1))
                {
                    // no webcam seems to be attached -> hide videoDisplay
                    videoDisplay.width  = 0;
                    videoDisplay.height = 0;
                    this.videoDisplayLabel.visible = true;
                    this.buttonBox.visible = false;
                }
                else
                {
                    // webcam detected

                    // change the default mode of the webcam
                    camera.setMode(350,350,5,true);
                    videoDisplay.width  = camera.width;
                    videoDisplay.height = camera.height;
                    this.videoDisplayLabel.visible = false;
                    this.buttonBox.visible = true;

                    videoDisplay.attachCamera(camera);
                }
            } else {
                UIGod.feedback("You don't seem to have a webcam.");
            }
        }
        */

    }

}
