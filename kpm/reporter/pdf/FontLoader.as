package com.kpm.reporter.pdf{
		
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	import flash.events.Event;	
	import flash.filesystem.FileStream;
	import flash.filesystem.File;
    import flash.filesystem.FileMode;
	import flash.utils.ByteArray;			
	import flash.display.Sprite;	
	import flash.utils.Dictionary;

	/**
	Clase que carga la información de las fuentes contenidas en un directorio determinado.
	**/
	public class FontLoader extends Sprite{
	
		protected var fontsData:Dictionary;
		protected var loader:URLLoader;
		protected var currentFontPath:String;
		protected var fontCount:int;
		protected var directory:File;
		protected var fontsPath:String;
		protected var fontList:Array;
		
		/**
		Contructor. Recibe el path RELATIVO donde se encuentran las fuentes.
		**/
		public function FontLoader(fontsPath:String){
			this.loader = new URLLoader();
			this.loader.dataFormat = URLLoaderDataFormat.BINARY;
			this.loader.addEventListener(Event.COMPLETE, this.onFontLoadComplete);
			this.fontCount = -1;
			this.fontsPath = fontsPath;
		}
		
		/**
		Método público que retorna las fuentes cargadas.
		El formato de lo retornado es: [fontName,extension,ByteArray].
		**/
		public function getFontsData():Dictionary{
			return this.fontsData;
		}
		
		/**
		Método público que debe invocarse para cargar las fuentes.
		**/
		public function loadFonts():void{
			this.fontsData = new Dictionary();			
			this.directory = new File( File.applicationDirectory.nativePath + "//" + this.fontsPath);
			this.fontList = directory.getDirectoryListing();
			this.loadNextFont();

		}

		/**
		Método protegido que se ejecuta (mediante un evento) luego de la carga de una fuente.
		Guarda la información de esa fuente en fontsData con el formato [fontName,extension,ByteArray].
		**/
		protected function onFontLoadComplete(event:Event):void{			
			var fileNameParts = this.currentFontPath.split(File.separator);
			var fileName:String = fileNameParts[fileNameParts.length-1].toString();			
			var fileNameWithoutExtension:String = fileName.split(".")[0];
			var fileExtension:String = fileName.split(".")[1];
			this.fontsData[fontCount] = [fileNameWithoutExtension.toLocaleLowerCase(),fileExtension.toLocaleLowerCase(),ByteArray(event.target.data)];			
			this.loadNextFont();
		}
	
		
		/**
		Método protegido que carga la siguiente fuente especificada en fontList.
		El método emite el evento "fontsLoaded" cuando se cargaron todas las fuentes del directorio.
		**/
		protected function loadNextFont():void{
			var patternFile:RegExp = /^([a-zA-Z].*|[1-9].* | -.* |_.*)\.((t|T)(t|T)(f|F))$/;
			this.fontCount++;
			for(this.fontCount;this.fontCount<this.fontList.length;this.fontCount++){
				//Se recupera el nombre del archivo (sin el path)
				this.currentFontPath = fontList[fontCount].nativePath.toString();
				var fileNameParts:Array = this.currentFontPath.split(File.separator);
				var fileName:String = fileNameParts[fileNameParts.length-1].toString();
				if(fileName.match(patternFile) != []){
					var replacePattern:RegExp = /\//g;
					this.currentFontPath = this.fontList[this.fontCount].nativePath.toString().replace(replacePattern,"//");
					loader.load(new URLRequest(this.currentFontPath));
					return;
				}
			}
			dispatchEvent (new Event("fontsLoaded"));
		}
	}
}
