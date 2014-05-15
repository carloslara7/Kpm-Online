package com.kpm.reporter.pdf{
import com.kpm.common.Util;

import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filesystem.FileStream;
	import flash.filesystem.File;
    import flash.filesystem.FileMode;
	import flash.utils.ByteArray;		
	import flash.events.Event;
	import org.purepdf.elements.images.ImageElement;
	import flash.display.Sprite;
	import flash.net.URLRequestDefaults;
	import flash.utils.Dictionary;

	/**
	Clase que carga la información de las imágenes contenidas en un directorio determinado.
	Posee métodos para obtener información de una imágen dada contenida en ese directorio.
	**/
	public class ImgData extends Sprite{
	
		protected var imgData:Dictionary;
		protected var imgLoader:URLLoader;
		protected var currentImgPath:String;
		protected var imgCount:int;
		protected var directory:File;
		protected var imgsPath:String;
		protected var imgList:Array;
		
		/**
		Contructor. Recibe el path RELATIVO donde se encuentran las imágenes.
		**/
		public function ImgData(imgsPath:String){
			this.imgLoader = new URLLoader();
			this.imgLoader.dataFormat = URLLoaderDataFormat.BINARY;
			this.imgLoader.addEventListener(Event.COMPLETE, this.onImageLoadComplete);
			this.imgCount = -1;
			this.imgsPath = imgsPath;		
		}
		
		/**
		Método público que debe invocarse para cargar las imágenes.
		**/
		public function loadImages():void{
			this.imgData = new Dictionary();
			this.directory = new File(File.applicationDirectory.nativePath + "//" + this.imgsPath);			
			this.imgList = directory.getDirectoryListing();
			this.loadNextImg();

		}
		
		/**
		Método público que retorna el path (relativo) de las imágenes.
		**/
		public function getImgsPath():String{
			return this.imgsPath;
		}
		
		/**
		Método público que dado el nombre de una imágen, retorna el width asociado a ella.
		**/
		public function getWidth(img:String):Number{
			return this.imgData[img];
		}
		
		/**
		Método público que dado el nombre de una imágen, retorna true si la misma existe o false en caso contrario.
		**/
		public function exists(img:String):Boolean{
			return this.imgData[img] != undefined;
		}
		
		/**
		Método protegido que se ejecuta (mediante un evento) luego de la carga de una imágen.
		Guarda la información de esa fuente en fontsData con el formato [ByteArray].
		**/
		protected function onImageLoadComplete(event:Event):void{
			var image: ImageElement = ImageElement.getInstance(ByteArray(event.target.data));
			var fileNameParts = this.currentImgPath.split(File.separator);
			var fileName:String = fileNameParts[fileNameParts.length-1].toString();

            Util.debug("loading image " + fileName);

            this.imgData[fileName.toLocaleLowerCase()] = image.width;
			this.loadNextImg();
		}
	
		
		/**
		Método protegido que carga la siguiente imágen especificada en imgList.
		El método emite el evento "imgsLoaded" cuando se cargaron todas las imágenes del directorio.
		**/
		protected function loadNextImg():void{
			var patternFile:RegExp = /^([a-zA-Z].*|[1-9].* | -.* |_.*)\.((j|J)(p|P)(g|G))$/;
			this.imgCount++;
			for(this.imgCount;this.imgCount<this.imgList.length;this.imgCount++){
				//Se recupera el nombre del archivo (sin el path)
				this.currentImgPath = imgList[imgCount].nativePath.toString();
				var fileNameParts:Array = this.currentImgPath.split(File.separator);
				var fileName:String = fileNameParts[fileNameParts.length-1].toString();
				if(fileName.match(patternFile) != []){
					var replacePattern:RegExp = /\//g;
					this.currentImgPath = this.imgList[this.imgCount].nativePath.toString().replace(replacePattern,"//");
					imgLoader.load(new URLRequest(this.currentImgPath));
					//imgLoader.load(new URLRequest("//Users//Pancho//Documents//Projects//KPM//pdfReporter//data//images//reportImages//Identify5Frame.jpg"));

					return;
				}
			}
			dispatchEvent (new Event("imgsLoaded"));
		}


	}
}