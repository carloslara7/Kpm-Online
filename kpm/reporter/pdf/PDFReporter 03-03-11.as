package com.kpm.reporter.pdf{
	
	import com.kpm.reporter.pdf.standard.StandardPdfReport;
	import flash.xml.XMLDocument;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.filesystem.FileStream;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.utils.ByteArray;
	import flash.utils.Dictionary;
		
	/**
	Clase para generar un reporte pdf a partir de un xml de entrada.
	**/
	public class PDFReporter{
		protected var xmlInput:XML;
		protected var parser:Parser;
		protected var loader:URLLoader;
		protected var request:URLRequest;
		protected var xmlPath:String;
		protected var pdfPath:String;
		protected var standardPdfReporter:StandardPdfReport;
		protected var fontLoader:FontLoader;
		protected var atoms:AtomsList;
		
		/**
		Constructor. Recibe como parámetros el path del xml de entrada y el path del pdf de salida.
		**/
		public function PDFReporter(xmlPath:String, pdfPath:String) {			
			//this.atoms = new AtomsList();
			this.atoms = null;
			this.xmlPath = xmlPath;
			this.pdfPath = pdfPath;
			this.loader = new URLLoader();
			this.request = new URLRequest();
			this.fontLoader = new FontLoader("com//fonts/");
			loader.addEventListener(Event.COMPLETE, this.loadFonts);
			this.fontLoader.addEventListener("fontsLoaded", this.parseDynamicData);	
		}
		
		/**
		Método público que debe invocarse para generar el pdf de salida a partir del archivo xml de entrada.
		**/
		public function generate():void{			
			if(this.atoms != null){
				this.request.url = this.xmlPath;
				this.loader.load(request);
			}else{
				trace("The report data (function setReportData) must be set before it can be generated.");
			}		
		}
		
		/**
		Método protegido que se ejecuta (mediante un evento) luego de que la información dinámica del xml
		de entrada fue reemplazada por información estática lista para ser parseada por Parser.
		**/
		protected function parse(e:Event):void{
			this.parser = new Parser(this.standardPdfReporter.getOutput(),this.fontLoader.getFontsData());
			parser.addEventListener("endParse", writePdfOutput);
			this.parser.parse();
		}
		
		/**
		Metodo protegido que carga las fuentes embebidas usadas en el reporte.
		Se ejecuta (mediante un evento) luego de que se ha cargado el xml de entrada.
		**/
		protected function loadFonts(e:Event):void{		
			this.xmlInput = new XML(e.target.data);
			this.fontLoader.loadFonts();
		}
		
		/**
		Método protegido que se ejecuta (mediante un evento) luego de cargar el archivo de entrada xml y las fuentes embebidas.
		Reemplaza la información dinámica del xml de entrada por datos estáticos.
		**/
		protected function parseDynamicData(e:Event):void{
			try{
				//this.standardPdfReporter = new StandardPdfReport(xmlInput,"data/images/reportImages/");
				this.standardPdfReporter = new StandardPdfReport(xmlInput, this.atoms);
				this.standardPdfReporter.addEventListener("endStandard",parse);
				this.standardPdfReporter.generate();
			}
			catch (e:Error) {
				//trace(e.message);
				trace("The content of the input file has not a valid XML format.");
			}						
		}
				
		/**
		Método protegido que se ejecuta (mediante un evento) luego de que se ha generado la información del pdf de salida.
		Escribe la información del pdf de salida en un archivo pdf.
		**/
		protected function writePdfOutput(e:Event):void{
			var fs:FileStream = new FileStream();
			var file: File = File.desktopDirectory;
			//file = file.resolvePath((this.pdfPath));
			file = file.resolvePath((getReportPath()));
			
			//Borra el archivo si ya existe
			if(file.exists)
				file.deleteDirectory(true);
				
			fs.open(file, FileMode.WRITE);
			var pdfBytes:ByteArray = this.parser.getByteArray();
			fs.writeBytes(pdfBytes);
			fs.close();
			
			file.openWithDefaultApplication();
			trace("The report was generated successfully.");
			
		}
		
		
		
		/**
		Método protegido que genera el path y nombre del documento PDF de salida.
		**/
		protected function getReportPath():String{
			var path:String = this.pdfPath;			
			if(path != "" && path.charAt(path.length - 1) != "/")
				path += "/";
			path += this.atoms.getObject("kidLastName") + " " + this.atoms.getObject("kidFirstName") + ".pdf";
			return path;
		}
		
		/**
		Método que carga la estructura atoms con todos los datos necesarios para generar el documento PDF de manera correcta.
		**/
		public function setReportData(atoms:AtomsList){
			
			this.atoms = atoms;
			
			//Código de prueba			
			
//			this.atoms.addAtom("currentAge", "Pre-K");		//La edad debe contener alguno de los siguientes valores: Pre-K, K o 1st.
//			this.atoms.addAtom("kidFirstName", "Carlitox");
//			this.atoms.addAtom("kidLastName", "Lara");
			//this.atoms.addAtom("teacherName", "Juan Perez"); //Actualmente se obtiene de archivo config.xml.
			
						
//			//Valores que deben incluirse para cada Qualifier Line en Part1 (qq1) y Part2 (qq2).
//			var qq1:Array = new Array(4);
//			var qq2:Array = new Array(4);
//			qq1["IdentifyFinger"] = 5;
//			qq1["Identify5Frame"] = 3;
//			qq1["IdentifyDiceDots"] = 10;
//			//qq1["IdentifyNumeral"] = null;	//Si una burbuja no está presente o es nula en qq1, no se incluye en la Part 1 del documento.
//			this.atoms.addAtom("qq1", qq1);
//			qq2["IdentifyFinger"] = 6;
//			qq2["Identify5Frame"] = 4;
//			//qq2["IdentifyDiceDots"] = null;	//Si una burbuja es nula en qq2, se utiliza el mensaje indicado en el atributo 'cano' para la Part 2.
//			qq2["IdentifyNumeral"] = 1;
//			this.atoms.addAtom("qq2", qq2);			
			
		}
	}	
}
