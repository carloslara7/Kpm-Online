package com.kpm.reporter.pdf{
	import flash.xml.XMLDocument;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLLoaderDataFormat;
	import flash.events.Event;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filesystem.FileStream;
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.utils.ByteArray;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	
	import org.purepdf.pdf.PdfDocument;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.pdf.PdfViewPreferences;	
	import org.purepdf.pdf.PdfPTable;
	import org.purepdf.pdf.PdfPCell;
	import org.purepdf.pdf.PdfLine;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.Font;
	import flash.text.Font;
	import org.purepdf.resources.BuiltinFonts;
    import org.purepdf.elements.Element;
    import org.purepdf.elements.Paragraph;
	import org.purepdf.elements.Phrase;
	import org.purepdf.elements.Chunk;
	import org.purepdf.elements.images.ImageElement;
	import org.purepdf.elements.RectangleElement;
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.utils.Dictionary;


	public class Parser extends DefaultPdf{		
		protected var xmlInput:XML;
		protected var env:Environment;
		protected var currentChild:int;
		protected var imgLoader:URLLoader;
		protected var tableImgLoader:URLLoader;
		protected var imgTabIndex:int;
		protected var imgBorder:int;
		protected var currentRow:int;		
		protected var currentCell:int;
		protected var columnWidths:Vector.<Number>;
		protected var currentTable:PdfPTable;
		protected var error:Boolean;		
		
		protected const SPACING = 6; 
		
		//Arreglo asociativo que mantiene los valores de los atributos seteados para la tabla.
		protected var tableAttrs:Object;
		
		//Formats es un hash que mantiene los formatos de las diferentes bloques del pdf de salida 
		//especificados en el xml de entrada.
		private var formats:Object;
		
		//Hash que mantiene los valores actuales para los atributos de formato de texto.
		private var currentFormat:Object;		
		
		//Párrafo que almacena el texto encerrado entre tags <paragraph>
		private var openParagraph:Paragraph = null;
		
		//Documento externo en el que se agregan los mismo elementos (sirve para realizar el 'merging' de reportes).
		public var externalReport:DefaultPdf = null;
		
		/**
		Constructor
		**/
		public function Parser(xmlInput:XML, embedFontsData:Dictionary, externalReport:DefaultPdf = null){
			super(embedFontsData);			
			this.externalReport = externalReport;		
			this.error = false;
			this.xmlInput = xmlInput;
			this.env = new Environment(this.embedFonts);			
			this.formats = new Object();	
			this.currentFormat = new Object();
			this.currentChild = 0;			
			this.setupDocument();
		}						
		
		/**
		Método protegido para inicializar el hash de valores de los atributos de la tabla.
		**/
		protected function initCurrentTable():void{
			this.tableAttrs = new Object();
			this.tableAttrs["border"] = 1;
			this.tableAttrs["hposition"] = this.env.getHAlign("center");
			this.tableAttrs["halign"] = this.env.getHAlign("left");
			this.tableAttrs["valign"] = this.env.getVAlign("middle");
			this.tableAttrs["width"] = this.document.pageSize.width - this.document.marginLeft - this.document.marginRight;
		}
		
		/**
		Método protegido para setear el hash de valores de los atributos de la tabla.
		**/
		protected function setCurrentTableAttrs(node:XML){
			var contentWidth:int = this.document.pageSize.width - this.document.marginLeft - this.document.marginRight;	
			
			if(this.env.existAttribute("border",node)) 
				this.tableAttrs["border"] = int(this.env.validate("number", node.attribute("border").toString()));				
			if(this.env.existAttribute("hposition",node))
				this.tableAttrs["hposition"] = int(this.env.getHAlign(String(this.env.validate("hposition", node.attribute("hposition").toString()))));
			if(this.env.existAttribute("halign",node))
				this.tableAttrs["halign"] = int(this.env.getHAlign(String(this.env.validate("halign", node.attribute("halign").toString()))));
			if(this.env.existAttribute("valign",node))
				this.tableAttrs["valign"] = int(this.env.getVAlign(String(this.env.validate("valign", node.attribute("valign").toString()))));
			if(this.env.existAttribute("width", node)){
				this.tableAttrs["width"] = int(this.env.validate("number", node.attribute("width").toString()));
				if(this.tableAttrs["width"] > contentWidth)
					throw new Error("The table width exceeds the content area of the document.");
			}
		}
		
		/**
		Metodo protegido que crea el documento pdf. Crea el objeto PdfDocument provisto por la libreria PurePdf.
		**/
		protected function createPdfDocument(){			
			try{
				//Se crea el documento para posibilitar el parseo en caso de existir un error en el tag 'pdf'.
				this.createDocument("Reporte pdf.");
				this.env.validateRoot(this.xmlInput);
				
				if(this.env.existAttribute("page-size", this.xmlInput))
					this.createDocument("Reporte pdf.", this.env.getPageSize(String(this.env.validate("page-size", this.xmlInput.attribute("page-size").toString().toLocaleLowerCase()))));
								
				var marginLeft:int = (this.env.existAttribute("margin-left", this.xmlInput)) ? int(this.env.validate("number", this.xmlInput.attribute("margin-left"))) : 36;
				var marginRight:int = (this.env.existAttribute("margin-right", this.xmlInput)) ? int(this.env.validate("number", this.xmlInput.attribute("margin-right"))) : 36;
				var marginTop:int = (this.env.existAttribute("margin-top", this.xmlInput)) ? int(this.env.validate("number", this.xmlInput.attribute("margin-top"))) : 36;
				var marginBottom:int = (this.env.existAttribute("margin-bottom", this.xmlInput)) ? int(this.env.validate("number", this.xmlInput.attribute("margin-bottom"))) : 36;
				
				if(marginLeft + marginRight >= this.document.pageSize.width) throw new Error("The horizontal margins exceed the page width.");
				if(marginTop + marginBottom >= this.document.pageSize.height) throw new Error("The vertical margins exceed the page height.");
				
				this.document.setMargins(marginLeft, marginRight, marginTop, marginBottom);
				if(this.externalReport != null)
					this.externalReport.document.setMargins(marginLeft, marginRight, marginTop, marginBottom);
			}
			catch(e:Error){
				this.error = true;
				trace(e.message);
			}			
		}
		
		/**
		Método que inicializa valores por default para la generación del pdf.
		**/
		protected  function setupDocument():void{			
			this.createPdfDocument();			
			//this.document.open();
			//this.document.setViewerPreferences( PdfViewPreferences.HideWindowUI | PdfViewPreferences.FitWindow );
			
			this.loadDefaultFormats();
			this.initCurrentTable();
			
			this.imgLoader = new URLLoader();
			this.imgLoader.addEventListener(Event.COMPLETE, this.onImageLoadComplete);
			this.imgLoader.dataFormat = URLLoaderDataFormat.BINARY;
			
			this.tableImgLoader = new URLLoader();
			this.tableImgLoader.addEventListener(Event.COMPLETE, this.onImageTableLoadComplete);
			this.tableImgLoader.dataFormat = URLLoaderDataFormat.BINARY;			
			
			this.tableImgLoader.addEventListener( flash.events.IOErrorEvent.IO_ERROR,this.onIoError);
			this.imgLoader.addEventListener( flash.events.IOErrorEvent.IO_ERROR,this.onIoError);
		}		
				
		/**
		Método público para realizar el parsing del xml de entrada y generar el pdf de salida.
		**/
		public function parse():void{
			var childrenList:XMLList;
			childrenList = xmlInput.children();
			for(currentChild;currentChild<childrenList.length();currentChild++){
				try{			
					switch(childrenList[currentChild].name().toString().toLowerCase()){
						case "head": 		break;
						case "format":  	this.addFormat(childrenList[currentChild]);
											break;
						case "addimage": 	this.addImage(childrenList[currentChild]);
											return;
						case "br"	:		this.br(childrenList[currentChild]);
											break;
						case "paragraph":	this.writeParagraph(childrenList[currentChild]);
											break;											
						case "text"	:		this.writeText(childrenList[currentChild]);
											break;
						case "date"	:		this.writeDate(childrenList[currentChild]);
											break;											
						case "table":		this.currentRow = 0;
											this.table(childrenList[currentChild]);
											return;
						case "setformat":	this.setFormat(childrenList[currentChild]);
											break;
						case "line":		this.writeLine(childrenList[currentChild]);
											break;						
						default:			trace("Default");
					}
				}
				catch(e:Error){
					trace(e.toString());
					error = true;
				}
			}
			
			if(!error){
				document.close();
				dispatchEvent (new Event("endParse"));
			}
	}
		
		/**
		Método protegido que setea el formato establecido en el nodo xml.
		Puede setearse de dos maneras: 
			1)Un formato ya almacenado con el atributo name="formatName", donde 
				formatName es un formato ya definido.
			2)Un fomato "inmediato" mediante los atributos: font, size, style, tabindex, underlined.
		**/
		protected function setFormat(node:XML):void{
			try{
				if(node.attribute("name").length()!=0){
					this.setStoredFormat(node);
				}else{
					this.setInmediateFormat(node);
				}
			}
			catch(e:Error){
					throw(new Error(e.message+" (Tag SetFormat)."));
			}
		}
		
		/**
		Método protegido que agrega un formato (tag Format) a la tabla hash de formatos.
		**/
		protected function addFormat(node:XML):void{
			var error:Boolean = false;
			
			//Se recupera el nombre del campo usado como clave de la tabla hash formats.
			var name:String = node.attribute("name").toString().toLowerCase();
			//Recupero la lista de atributos del tag format.
			var attributes: XMLList = node.attributes();
			
			//Se crea una instancia de un arreglo asociativo.
			var attArray:Object = new Object();
			
			//Se recorre la lista de atributos y se agrega el mapeo nombreAtributo->valor al arreglo
			//asociativo attArray.
			for each(var value:XML in attributes){
				var valueStr:String = value.name().toString();
				//Caso en el cual el atributo no es válido.
				if(!this.env.isValidAttribute("setFormat",valueStr)){
					throw new Error("The attribute "+ valueStr +" is not valid in a Format tag.");
				}
				//Se saltea el nombre. No se necesita porque ya se tiene para usarlo como clave de hash.
				if(valueStr!="name"){
					attArray[valueStr] = value.toString().toLocaleLowerCase();
				}
			}
			formats[name] = attArray;			
		}	
		
		/**
		Método protegido que setea los atributos de formato de texto indicados en el nodo.
		**/
		protected function setInmediateFormat(node:XML):void{			
			if(node.attribute("font").length()!=0) currentFormat["font"] = this.env.validate("Font",node.attribute("font").toString().toLowerCase());
			if(node.attribute("size").length()!=0) currentFormat["size"] = this.env.validate("Number",node.attribute("size").toString());
			if(node.attribute("style").length()!=0) currentFormat["style"] = this.env.validate("Style",node.attribute("style").toString().toLowerCase());
			if(node.attribute("tabindex").length()!=0) currentFormat["tabindex"] = this.env.validate("Number",node.attribute("tabindex").toString());
			if(node.attribute("underlined").length()!=0) currentFormat["underlined"] = this.env.validate("Boolean",node.attribute("style").toString().toLowerCase());			
		}
		
		/**
		Método protegido que setea los atributos de formato de texto según un formato previamente almacenado.
		**/
		protected function setStoredFormat(node:XML):void{
			var formatName:String = node.attribute("name").toString().toLocaleLowerCase(); //por ejemplo: "title"
			if (this.formats[formatName] != undefined){
				var attArray : Object = this.formats[formatName];
				loadDefaultFormats();
				if (attArray["font"] != undefined) currentFormat["font"] = this.env.validate("Font",attArray["font"]);
				if (attArray["size"] != undefined) currentFormat["size"] = this.env.validate("Number",attArray["size"]);
				if (attArray["style"] != undefined) currentFormat["style"] = this.env.validate("Style",attArray["style"]);
				if (attArray["tabindex"] != undefined) currentFormat["tabindex"] = this.env.validate("Number",attArray["tabindex"]);
				if (attArray["underlined"] != undefined) currentFormat["underlined"] = this.env.validate("Boolean",attArray["underlined"]);							
			}else 
				throw new Error("SetFormat name attribute '" + formatName + "' was not found.");
		}
		
		/**
		Metodo que se ejecuta cuando se produce un error de IO a causa de la inexistecia de algun archivo.
		**/
		protected function onIoError(e:Event):void
		{
			this.error = true;
			var imgNode:XML;
			if(e.target == imgLoader)
				 imgNode = (this.xmlInput.children())[this.currentChild];
			else{
				var tableNode:XML = (this.xmlInput.children())[this.currentChild];
				var rowNode:XML = tableNode.children()[this.currentRow];
				imgNode = rowNode.children()[this.currentCell];
			}

			trace("The file '"+imgNode.attribute("path").toString()+" does not exist.");
            trace(e.toString());
		}
		
		/**
		Método protegido que agrega una imagen en el pdf según el contenido del nodo xml.
		**/
		protected function addImage(node:XML):void{

			this.imgTabIndex = 0;
			this.imgBorder = 0;
			var pathImg:String;
			
			if(node.attribute("path").length()==0) 
				throw new Error("The content of the text tag is not valid. (addImage Tag).");
			else
				pathImg = node.attribute("path").toString();


			var attributes: XMLList = node.attributes();
			for each(var value:XML in attributes){
				var valueStr:String = value.name().toString();
				//Caso en el cual el atributo no es válido.
				if(!this.env.isValidAttribute("addImage",valueStr)){
					throw new Error("The attribute "+ valueStr +" is not valid in a addImage tag. (addImage Tag).");
				}
			}
			
			if(node.attribute("tabindex").length()!=0)
					this.imgTabIndex = int(this.env.validate("number",node.attribute("tabindex").toString()));
					
			if(node.attribute("border").length()!=0) 
					this.imgBorder = int(this.env.validate("number",node.attribute("border").toString()));
			
			imgLoader.load(new URLRequest(pathImg));
		}
		
		/**
		Metodo que inserta una imagen.
		**/			
	 	private function onImageLoadComplete(event:Event):void{			
			var tableWidth:int = PageSize.A4.width - this.document.marginLeft - this.document.marginRight;
			var image: ImageElement = ImageElement.getInstance(ByteArray(event.target.data));
			var table:PdfPTable = new PdfPTable(Vector.<Number>([this.imgTabIndex,image.width]));
			var tabCell:PdfPCell = new PdfPCell();
			
			tabCell.borderWidth = 0;
			table.widthPercentage = ((this.imgTabIndex + image.width)*100)/tableWidth;
			
			table.addCell(tabCell);
			table.horizontalAlignment=0;
			var cell:PdfPCell = PdfPCell.fromImage(image,false);
			cell.borderWidth = this.imgBorder;
			if(this.imgBorder!=0){
				cell.border = RectangleElement.BOX;
			}
			cell.padding = cell.borderWidth / 2.0 + 1;

			table.addCell(cell);
			
			table.spacingBefore = SPACING;
			this.document.add(table);
			if(this.externalReport != null)
				this.externalReport.document.add(table);
			this.currentChild++;
			this.parse();
    	}	
		
		/**
		Método protegido que agrega una linea en blanco al documento pdf.
		**/
		protected function br(node:XML){
			if(node.attributes().length()==0){				
				var phrase:Phrase = new Phrase(null, null);
				phrase.add(Chunk.NEWLINE);
				this.addPhrase(phrase);
			}else{
				throw new Error("The content of the 'br' tag is not valid.");
			}
		}
		
		/**
		Metodo protegido que agrega un parrafo parseado al documento pdf.	
		**/
		protected function writeParagraph(node:XML):void{
			var paragraph:Paragraph = this.parseParagraph(node);
			this.document.add(paragraph);
			if(this.externalReport != null)
				this.externalReport.document.add(paragraph);
		}
		
		/**
		Metodo protegido que parsea un parrafo del XML y retorna un objeto Paragraph.
		**/
		protected function parseParagraph(node:XML):Paragraph{
			var retParagraph:Paragraph = null;
			if(node.attributes().length() == 0){
				this.openParagraph = new Paragraph("");
				this.openParagraph.indentationLeft = currentFormat["tabindex"];
				var childrenList:XMLList = node.children();
				var currentChild = 0;
				for(currentChild; currentChild<childrenList.length(); currentChild++){					
					switch(childrenList[currentChild].name().toString().toLowerCase()){
						case "text"	:		this.writeText(childrenList[currentChild]);
											break;
						case "format":  	this.addFormat(childrenList[currentChild]);
											break;
						case "setformat":	this.setFormat(childrenList[currentChild]);
											break;				
						case "br"	:		this.br(childrenList[currentChild]);
											break;						
						case "date"	:		this.writeDate(childrenList[currentChild]);
											break;
						case "line"	:		this.writeLine(childrenList[currentChild]);
											break;
						default:			throw new Error("The '" + childrenList[currentChild].name().toString().toLowerCase() + "' tag is not valid inside a paragraph.");
					}					
				}
				this.openParagraph.leading = this.getCurrentLeading();
				retParagraph = this.openParagraph;
				this.openParagraph = null;				
			}else{
				throw new Error("The content of the 'paragraph' tag is not valid.");
			}
			return retParagraph;
		}
		
		/**
		Método protegido que dado un texto retorna un párrafo con el formato actual.
		**/
		protected function createFormattedParagraph(txt:String):Paragraph{
			var paragraph:Paragraph= new Paragraph(txt, getCurrentFont());
			paragraph.indentationLeft = currentFormat["tabindex"];
			//Setea el interlineado dentro de un parrafo.
			paragraph.leading = this.getCurrentLeading();			
			return paragraph;
		}
		
		/**
		Método protegido que dado un texto retorna una frase con el formato actual.
		**/
		protected function createFormattedPhrase(txt:String):Phrase{			
			var phrase:Phrase = new Phrase(txt, getCurrentFont(), this.getCurrentLeading());
			return phrase;
		}
				
		/**
		Método protegido que escribe en el pdf el texto contenido en el nodo xml.
		**/
		protected function writeText(node:XML):void{
			if(node.attribute("txt").length()!=0 && node.attributes().length()==1){
				var txt:String = node.attribute("txt").toString(); 
				var phrase:Phrase = this.createFormattedPhrase(txt);
				this.addPhrase(phrase);
			}else{
				throw new Error("The content of the text tag is not valid.");
			}
		}		
		
		/**
		Método protegido que imprime la frase en el documento PDF o el párrafo actual, según sea el caso.
		**/
		protected function addPhrase(phrase:Phrase){
			if(this.openParagraph != null){
				this.openParagraph.add(phrase);
			}else{
				this.document.add(phrase);
				if(this.externalReport != null)
					this.externalReport.document.add(phrase);
			}
		}
		
		/**
		Método protegido que escribe en el pdf la fecha actual con el formato actual.
		**/
		protected function writeDate(node:XML):void{
			if(node.attributes().length() == 0){				
				var phrase:Phrase = new Phrase(this.getCurrentDate(), getCurrentFont(), this.getCurrentLeading());
				this.addPhrase(phrase);				
			}else{
				throw new Error("The 'date' tag has an invalid attribute.");
			}
		}
		
		/**
		Método protegido que agrega una tabla en el documento pdf.
		**/
		protected function table(node:XML){
			
			var rowList:XMLList = node.children();			
			//Si es la primera fila de la tabla, se chequea la validéz de los atributos.
			if(currentRow == 0){
				this.env.validateAttributes("table", node);
				this.setCurrentTableAttrs(node);
			}					
			if(currentRow<rowList.length()){
				switch(rowList[currentRow].name().toString().toLowerCase()){
					
				case "row" 			: 	this.columnWidths = new Vector.<Number>();
										this.currentCell = 0;										
										this.currentTable = new PdfPTable((XML(rowList[currentRow])).child("cell").length());
										this.row(rowList[currentRow]);
										return;
										
				case "setformat"	:	this.setFormat(rowList[currentRow]);
										this.currentRow++;
										this.table(this.xmlInput.children()[this.currentChild]);
										return;
										
										//No se genera una excepción porque no siempre table se ejecuta desde el flujo de
										//ejecución principal. 
										//Puede ejecutarse a partir de un evento: evento de carga de imagen-> onImageTableLoadComplete -> row -> table
				default				:	trace("'"+rowList[currentRow].name().toString()+ "' is not a valid tag inside a table.")
										this.error = true;
				}
			}			
			this.initCurrentTable();
			this.currentChild++;
			this.parse();
		}
		
		/**
		Método protegido que agrega una fila a una tabla en el documento pdf.
		**/
		protected function row(node:XML){
			var width:Number;
			try{
				this.env.validateAttributes("row", node);
				var cellList:XMLList = node.children();
				for(this.currentCell;this.currentCell<cellList.length();this.currentCell++){										
					switch(cellList[this.currentCell].name().toString().toLocaleLowerCase()){
						case "cell"			: 	this.env.validateCell(cellList[currentCell]);												
												var type:String=cellList[currentCell].attribute("type").toString();
												if(type=="text"){						
													var cell:PdfPCell = new PdfPCell();			
													cell.borderWidth = tableAttrs["border"];
													cell.border = RectangleElement.BOX;
													cell.padding = cell.borderWidth / 2.0 + 1;																										
													width = Number(cellList[currentCell].attribute("width").toString());
													var xmlParagraph:XML = new XML(<paragraph/>);
													xmlParagraph.setChildren(cellList[currentCell].children());
													var cellParagraph:Paragraph = this.parseParagraph(xmlParagraph);													
													
													this.setCellAlignment(cell, cellParagraph);													
													this.setCellHeight(cell);													
													cell.addElement(cellParagraph);
													this.currentTable.addCell(cell);															
													this.columnWidths.push(width + this.tableAttrs["border"]);													
								
												}else{													
													var path:String = cellList[currentCell].attribute("path").toString();
                                                    tableImgLoader.load(new URLRequest(path));
													return;
												}
												break;
						case "setformat"	:	this.setFormat(cellList[this.currentCell]);
												break;
												
						default				:	trace("'" + cellList[this.currentCell].name().toString() + "' is a not valid tag inside a row");
												this.error = true;
					}					
				}
				
				var contentWidth:int = this.document.pageSize.width - this.document.marginLeft - this.document.marginRight;			
				var currentRowWidth:int = 0;
				var tableWidth = this.tableAttrs["width"] + this.columnWidths.length * this.tableAttrs["border"];
				var i:int = 0;
				
				for(i; i<this.columnWidths.length; i++)
					currentRowWidth += this.columnWidths[i];
								
				if(currentRowWidth > tableWidth)
					throw new Error("The total width of row " + (this.currentRow + 1) + " exceeds the table declared width.");				
				else					
					this.columnWidths[this.columnWidths.length - 1] += tableWidth - currentRowWidth;
				
				if(currentRow == 0){
					this.currentTable.extendLastRow = false;
					this.currentTable.spacingBefore = this.tableAttrs["border"] / 2 + 1 + SPACING;
				}
				//Para introducir el 'spacing' después de la última fila (tabla).				
				if(node.parent().children().length()-1 == currentRow)
					this.currentTable.spacingAfter = this.tableAttrs["border"] / 2 + 1 + SPACING;					
				
				this.currentTable.widthPercentage = tableWidth * 100 / contentWidth;
				this.currentTable.setNumberWidths(this.columnWidths);
				this.currentTable.horizontalAlignment = tableAttrs["hposition"];
				
				this.document.add(this.currentTable);
				if(this.externalReport != null)
					this.externalReport.document.add(this.currentTable);
			}
			//Captura excepciones generadas por la función 'row'.
			catch(e:Error){			
				error = true;
				trace(e.toString());				
			}
			this.currentRow++;
			this.table(this.xmlInput.children()[this.currentChild]);
		}
				
		/**
		Metodo que inserta una imagen en una celda de una tabla.
		**/			
		private function onImageTableLoadComplete(event:Event):void{			
			
				var image: ImageElement = ImageElement.getInstance(ByteArray(event.target.data));
				var fit:Boolean = false;
				var width:Number = image.width;
				var cell:PdfPCell;
				
				var tableNode:XML = (this.xmlInput.children())[this.currentChild];
				var rowNode:XML = tableNode.children()[this.currentRow];
				var imageNode:XML = rowNode.children()[this.currentCell];
				if(imageNode.attribute("fit").length()!=0) fit = (imageNode.attribute("fit").toString() == "true");
				if(imageNode.attribute("width").length()!=0) {
					width = Number(imageNode.attribute("width").toString());				
					if(!fit && image.width > width){
						trace("The cell width can't be smaller than the image width when de fit property is false.");
						this.error = true;
					}
				}			
				this.columnWidths.push(width +  this.tableAttrs["border"]); //Sumo el borde al ancho de la celda para que la imagen no se superponga con el mismo.
				
				cell = PdfPCell.fromImage(image, fit);
				cell.border = RectangleElement.BOX;
				cell.borderWidth = tableAttrs["border"];
				cell.padding = (cell.borderWidth / 2.0);
				this.setCellAlignment(cell);
				this.setCellHeight(cell);
				this.currentTable.addCell(cell);
				
				this.currentCell++;
				this.row(rowNode);		
    	}
			
		/**
		Metodo protegido que inserta una Línea en el documento PDF.
		**/			
		protected function writeLine(node:XML){
			if(node.attributes().length() == 0){
				var table:PdfPTable = new PdfPTable(1);
				var cell:PdfPCell = new PdfPCell();
				table.widthPercentage = 100;				
				cell.fixedHeight = 1;
				cell.borderWidth = 0;				
				cell.borderWidthTop = 0.8;
				table.addCell(cell);
				table.spacingAfter = SPACING;
				table.spacingBefore = 0;
				var phrase:Phrase = new Phrase(null, null);
				phrase.add(table);			
				this.addPhrase(phrase);
			}else{
				throw new Error("The 'line' tag has an invalid attribute.");
			}
		}			
			
		/**
		Método protegido que copia los valores por default del formato de texto en la configuración de 
		formato actual.
		**/
		protected function loadDefaultFormats(){
			currentFormat["font"] = this.env.getDefaultFormatValue("font");
			currentFormat["size"] = this.env.getDefaultFormatValue("size");
			currentFormat["style"] = this.env.getDefaultFormatValue("style");
			currentFormat["tabindex"] = this.env.getDefaultFormatValue("tabindex");
			currentFormat["underlined"] = this.env.getDefaultFormatValue("underlined");
		}
		
		/**
		Metodo protegido que setea la alineacion para una dada celda y un parrafo.
		**/
		protected function setCellAlignment(cell:PdfPCell,paragraph:Paragraph = null){
				var tableNode:XML = (this.xmlInput.children())[this.currentChild];
				var rowNode  :XML = tableNode.children()[this.currentRow];
				var cellNode :XML = rowNode.children()[this.currentCell];
			
			if (this.env.existAttribute("valign",cellNode))
				cell.verticalAlignment = this.env.getVAlign(String(this.env.validate("valign", cellNode.attribute("valign").toString())));
			else
				if (this.env.existAttribute("valign",rowNode))
					cell.verticalAlignment = this.env.getVAlign(String(this.env.validate("valign", rowNode.attribute("valign").toString())));
				else
					cell.verticalAlignment = this.tableAttrs["valign"];
						
			
			if (this.env.existAttribute("halign", cellNode))
				paragraph != null ? paragraph.alignment = this.env.getHAlign(String(this.env.validate("halign", cellNode.attribute("halign").toString()))) 
				: cell.horizontalAlignment = this.env.getHAlign(String(this.env.validate("halign", cellNode.attribute("halign").toString())));
			else
				if (this.env.existAttribute("halign",rowNode))
					paragraph != null ? paragraph.alignment = this.env.getHAlign(String(this.env.validate("halign", rowNode.attribute("halign").toString())))
					: cell.horizontalAlignment = this.env.getHAlign(String(this.env.validate("halign", rowNode.attribute("halign").toString())));
				else
					paragraph != null ? paragraph.alignment = this.tableAttrs["halign"]
					: cell.horizontalAlignment = this.tableAttrs["halign"];
		}
		
		/**
		Metodo protegido que setea el min-height de una celda en caso de que exista el atributo en el XML de entrada.
		**/
		protected function setCellHeight(cell:PdfPCell){
			var tableNode:XML = (this.xmlInput.children())[this.currentChild];
			var rowNode:XML = tableNode.children()[this.currentRow];
			if(this.env.existAttribute("min-height", rowNode))
				cell.minimumHeight = int(this.env.validate("number", rowNode.attribute("min-height").toString()));					
		}
		
		/**
		Método público que retorna el documento PDF en formato ByteArray.
		**/
		public function getByteArray():ByteArray{
			return this.buffer;
		}
		
		/**
		Metodo protegido que retorna el objeto Font a ser usado dependiendo del formato actual.
		**/
		protected function getCurrentFont(): Font{
			var font:Object = this.env.getFont(currentFormat["font"]);
			var style:int = this.env.getStyle(currentFormat["style"]);
			var size:int = currentFormat["size"];			
			var underlined:Boolean = currentFormat["underlined"];
			if (!(font is BaseFont)){
				return new Font((font as int),size,underlined ? Font.UNDERLINE | style : style);
			}
			else{ 				
				return new Font(-1,size,underlined ? Font.UNDERLINE | style : style,null,(font as BaseFont));				
			}
		}
		
		/**
		Metodo protegido que retorna la fecha actual con el formato: "NombreMes NumeroDia, Año". Por ejemplo
		**/
		protected function getCurrentDate():String{
			var months: Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
			var currentDate:Date = new Date();
			var day:String = (currentDate.getDate() < 10) ? "0" + currentDate.getDate() : String(currentDate.getDate());			
			return  months[currentDate.getMonth()] + " " +  day + ", " + currentDate.getFullYear();							
		}
		
		/**
		Método protegido que retorna el leading (interlineado) dependiendo de la fuente seteada actualmente."
		**/
		protected function getCurrentLeading():int{
			var extraLeading:int = (this.currentFormat["font"] == "kristen itc") ? 6 : 2;
			return this.currentFormat["size"] + extraLeading;			
		}
	}	
}