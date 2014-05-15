package com.kpm.reporter.pdf{
import com.kpm.common.Util;
import com.kpm.reporter.pdf.standard.StandardPdfReport;
	import flash.xml.XMLDocument;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.*;
	import flash.events.IOErrorEvent;
	import flash.filesystem.FileStream;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import org.purepdf.elements.List;
	import mx.utils.ObjectUtil;
	/**
	Clase para generar reportes pdf a partir de un xml de entrada.
	**/
	public class PDFReporter extends Sprite{
		protected var xmlInput:XML;
		protected var parser:Parser;
		protected var loader:URLLoader;
		protected var request:URLRequest;
		protected var xmlPath:String;
		protected var pdfPath:String;
		protected var standardPdfReporter:StandardPdfReport;
		protected var fontLoader:FontLoader;
		protected var atoms:AtomsList;
		protected var generating:int;
		protected var dataLoaded:Boolean;
		protected var reportData:Array; //Lista de pares (AtomsList, Boolean) El boolean indica si se debe mergear o no el reporte.		
		protected var currentAtom:AtomsList;
		protected var processing:Boolean;

        protected var kidNames : String = "";

		//Documento que sirve para realizar el 'merging' de reportes.
		protected var mergeReport:DefaultPdf;
		protected var mergeReportPath;
		
		/**
		Constructor. Recibe como parámetros el path del xml de entrada y el path del pdf de salida.
		**/
		public function PDFReporter(xmlPath:String, pdfPath:String){			
			this.generating = 0;
			this.atoms = null;			
			this.xmlPath = xmlPath;
			this.pdfPath = pdfPath;
			this.currentAtom = null;			
			this.processing = false;
			this.resetMerging();
			this.loader = new URLLoader();
			this.request = new URLRequest();
			this.dataLoaded = false;
			this.fontLoader = new FontLoader("data//fonts/");
            //this.fontLoader = new FontLoader("data/fonts/");
			loader.addEventListener(Event.COMPLETE, this.loadFonts);
			this.fontLoader.addEventListener("fontsLoaded", this.scheduler);	
		}
		
		public function resetMerging(){
			this.mergeReport = null;
			this.reportData = new Array();
		}
		
		/**
		Método que carga la estructura atoms con todos los datos necesarios para generar el documento PDF de manera correcta.
		**/
		public function setReportData(atoms:AtomsList){			
			this.currentAtom = atoms;			
		}
		
		/**
		Método público que debe invocarse para generar el pdf de salida a partir del archivo xml de entrada.
		**/
		public function generate(mergeReport:Boolean = true, openReport:Boolean = false):void{
			trace("PdfReporter.generate, merging " + mergeReport);
			
			if(this.currentAtom != null){
				this.reportData.push(new Array(this.currentAtom, mergeReport, openReport));
				if(!this.dataLoaded){
					this.dataLoaded = true;
					this.processing = true;
					this.request.url = this.xmlPath;
					this.loader.load(request);
				}else{
					if(!this.processing)
						this.scheduler(null);						
				}
			}
			else{
				trace("The report data (function setReportData) must be set before the report can be generated.");
			}	
		}
		
		
		/**
		Método protegido que procesa cada pedido de manera secuencial.
		**/
		protected function scheduler(e:Event):void{
			if(this.reportData.length==0){
				this.processing = false;
			}
			else{
				this.processing = true;
				this.parseDynamicData();
			}
			
		}
		
		/**
		Método protegido que se ejecuta (mediante un evento) luego de que la información dinámica del xml
		de entrada fue reemplazada por información estática lista para ser parseada por Parser.
		**/
		protected function parse(e:Event):void{
			var merge:Boolean = this.reportData[0][1];
			if(merge) //Se debe mergear el reporte
				if(this.mergeReport == null){ //Es el primero (el objeto no ha sido creado)
					this.mergeReport = new DefaultPdf(this.fontLoader.getFontsData());
					this.setMergeReportPath();
				}else{
					this.mergeReport.pageBreak();
				}
			this.parser = new Parser(this.standardPdfReporter.getOutput(), this.fontLoader.getFontsData(), (merge ? this.mergeReport : null));
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
		//Método protegido que procesa el primer atoms de la lista de pedidos.
		**/
		protected function parseDynamicData():void{
			//try{
				this.standardPdfReporter = new StandardPdfReport(ObjectUtil.copy(xmlInput) as XML, this.reportData[0][0]);
				this.standardPdfReporter.addEventListener("endStandard", parse);
				this.standardPdfReporter.generate();
			//}
			//catch (e:Error) {
				//trace("The content of the input file has not a valid XML format.");
			//}						
		}
				
		/**
		Método protegido que se ejecuta (mediante un evento) luego de que se ha generado la información del pdf de salida.
		Escribe la información del pdf de salida en un archivo pdf.
		**/
		protected function writePdfOutput(e:Event):void{
			var path:String = this.getReportPath();

            //if merging report dont email result
            if(this.mergeReport != null)
                this.parser.save(path, this.reportData[0][2]);
            else
			    this.parser.save(path, this.reportData[0][2], this.reportData[0][0].getObject("emailToSendReport"), kidNames);
			
			if(this.reportData[0][1]) //El reporte en [0] fue mergeado.
				this.mergeReport = this.parser.externalReport;
			this.reportData.splice(0,1);
			this.scheduler(null);			
			
			dispatchEvent(new Event("reportGenerated"));
			trace("The report was generated successfully.");
		}
		
		/**
		Método protegido que genera el path y nombre del documento PDF de salida.
		**/
		protected function getReportPath():String{
			this.generating++;
			var path:String = this.pdfPath;			
			if(path != "" && path.charAt(path.length - 1) != "/")
				path += "/";
			
			path+= reportData[0][0].getObject("class");
			
			if(reportData[0][0].getObject("isTeacherReport"))
				path += "t_";
			else
				path += "f_";
				
			path += this.reportData[0][0].getObject("kidLastName") + " " + this.reportData[0][0].getObject("kidFirstName");
			path += " " + this.reportData[0][0].getObject("todayDate")+".pdf";
			return path;
		}
		
		protected function getMergeReportPath():String{
			return this.mergeReportPath;
		}
		
		protected function setMergeReportPath(){
			var path:String = this.pdfPath;
			if(path != "" && path.charAt(path.length - 1) != "/")
				path += "/";
			
			path += "CombinedReport ";
			var teacherName:String = this.reportData[0][0].getObject("teacherName");
			path += teacherName.charAt(0).toUpperCase();			
			path += " " + this.reportData[0][0].getObject("todayDate") + ".pdf";
			this.mergeReportPath = path;
		}
		
		public function getMergeReport():DefaultPdf{
			return this.mergeReport;
		}

        public function setKidName (pString)  : void
        {
            kidNames = pString;
        }
				
		public function saveMergeReport(openReport:Boolean = true){			
			if(this.mergeReport == null){ //Para el caso en que no se haya mergeado ningún reporte.
				trace("PdfReporter.saveMergeReport, the report is empty and cannot be generated.");
			}else{
                var email : String =  currentAtom.getObject("emailToSendReport") as String;
                trace("save merge report email "+ email);
				this.mergeReport.save(this.getMergeReportPath(), openReport, email);
				this.resetMerging();
			}
		}
	}	
}
