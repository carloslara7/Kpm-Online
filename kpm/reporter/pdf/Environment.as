package com.kpm.reporter.pdf{
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
	import org.purepdf.pdf.PdfViewPreferences;
	import org.purepdf.pdf.PageSize;
	import org.purepdf.Font;
	import org.purepdf.pdf.fonts.BaseFont;
	import org.purepdf.pdf.fonts.FontsResourceFactory;
    import org.purepdf.resources.BuiltinFonts;
	import flash.text.Font;	
    import org.purepdf.elements.Element;
	import org.purepdf.elements.RectangleElement;
		
	public class Environment {
		
		//Arreglo que mantiene los nombres de los atributos válidos para el tag Pdf.
		protected var validAttributesPdf:Array;
		
		//Arreglo que mantiene los nombres de los atributos válidos para el tag Format.
		protected var validAttributesFormats:Array;
		
		//Arreglo que mantiene los nombres de los atributos válidos para el tag addImage.
		protected var validAttributesImage:Array;
		
		//Arreglo que mantiene los nombres de los atributos válidos para el tag table.
		protected var validAttributesTable:Array;
		
		//Arreglo que mantiene los nombres de los atributos válidos para el tag row.
		protected var validAttributesRow:Array;
		
		//Arreglo que mantiene los nombres de los atributos válidos para el tag cell de type=image.
		protected var validAttributesImageCell:Array;
		
		//Arreglo que mantiene los nombres de los atributos válidos para el tag cell de type=text.
		protected var validAttributesTextCell:Array;
		
		//Hash que dada una cadena retorna el código de una font (purepdf).
		protected var fonts:Object;
		
		//Hash que dada una cadena retorna el código de un style (purepdf).
		protected var styles:Object;
		
		//Hash que dada una cadena retorna el código de una alineación vertical (purepdf).
		protected var vAligns:Object;
		
		//Hash que dada una cadena retorna el código de una alineación horizontal (purepdf).
		protected var hAligns:Object;
		
		//Hash que dada una cadena retorna el código de un formato de página (purepdf).
		protected var pageSizes:Object;
		
		//Hash que mantiene los valores por default para los atributos de formato de texto.
		protected var defaultFormat:Object;
		
		/**
		Constructor
		**/
		public function Environment(embedFonts:Object = null) {			
			this.initValidAttrValues();
			this.initDefaultFormatValues();
			this.initFontsValues();
			this.initStylesValues();
			this.initHAlignValues();
			this.initVAlignValues();
			this.initPageSizesValues();
			this.initEmbedFonts(embedFonts);
		}
		
		/**
		Metodo protegido que inicializa el hash con las fuentes embebidas.
		**/
		protected function initEmbedFonts(embedFonts:Object): void{			
			for each (var f: Object in embedFonts){				
				this.fonts[f[0]] = f[1]; //this.fonts[nombre de la fuente] = BaseFont de la fuente.
			}											
		}
		
		
		/**
		Método público que valida la correctitud del tag raiz.
		**/
		public function validateRoot(root:XML):void{
			if(root.name().toString().toLocaleLowerCase()=="pdf")
				this.validateAttributes("pdf", root);
			else
				throw(new Error("The root name must be 'pdf'."));
		}
		/**
		Metodo público que valida la correctitud de los atributos de un dado tag.
		**/
		public function validateAttributes(tag:String, node:XML):void{
			var attributes: XMLList = node.attributes();
			for each(var value:XML in attributes){
				var valueStr:String = value.name().toString();
				//Caso en el cual el atributo no es válido.
				if(!this.isValidAttribute(tag ,valueStr)){
					throw new Error("The attribute '"+ valueStr +"' is not valid in a '" + tag + "' tag.");
				}
			}
		}
		
		/**
		Metodo público que valida la correctitud de los atributos de un tag 'cell'.
		**/
		public function validateCell(node:XML):void{
			
			if(node.attribute("type").length()==0) 
				throw new Error("The attribute 'type' was not found in 'cell' tag.");
			
			var type = node.attribute("type").toString();
			switch(type){
				case	"image"	:{
									this.validateAttributes("cell:image", node);
									if(node.attribute("fit").length()!=0) 
										this.validate("boolean", node.attribute("fit").toString());
									if(node.attribute("width").length()!=0) 
										this.validate("number", node.attribute("width").toString());
									break;
								  }
				case	"text"	: {
									this.validateAttributes("cell:text", node);									
									if(node.attribute("width").length()!=0) 
										this.validate("number", node.attribute("width").toString());
									else 
										throw new Error("Attribute 'width' must be declared in cells of type text.");
									break;
								   }
				default			:	throw new Error(type +" is not a valid value for attribute type. (cell Tag).");
			}			
		}
		
		/**
		Método protegido que inicializa los arreglos de atributos validos para cada tag del xml de entrada.
		**/
		protected function initValidAttrValues():void{
			this.validAttributesPdf = new Array("page-size","margin-left","margin-right","margin-top","margin-bottom");
			this.validAttributesFormats = new Array("size","font","style","underlined","name","tabindex");
			this.validAttributesImage = new Array("path","border","tabindex");
			this.validAttributesTable = new Array("border", "halign", "valign", "hposition", "width");
			this.validAttributesRow = new Array("halign","valign", "min-height");
			this.validAttributesImageCell = new Array("type", "path", "width", "fit","halign","valign");
			this.validAttributesTextCell = new Array("type", "width","halign","valign");
		}
		
		/**
		Método protegido que inicializa lo valores de formato por default. 
		**/
		protected function initDefaultFormatValues():void{
			this.defaultFormat = new Object();
			//Font se codifica con un valor entero.
			this.defaultFormat["font"] = Font.HELVETICA;
			//Size se codifica con un valor entero.
			this.defaultFormat["size"] = 10;
			//Style se codifica con una cadena.
			this.defaultFormat["style"] = Font.NORMAL;
			//Tabindex se codifica con un valor entero.
			this.defaultFormat["tabindex"] = 0;
			//Underlined se codifica con un valor booleano.
			this.defaultFormat["underlined"] = false;
		}
		
		/**
		Método público que dado el nombre de un atributo de formato, retorna su valor por default.
		**/
		public function getDefaultFormatValue(attr:String){
			return this.defaultFormat[attr];
		}
		
		/**
		Método público que dado un tag determina si el atributo es válido para ese tag.
		**/
		public function isValidAttribute(tag:String, attr:String):Boolean{
			switch (tag){
				case "pdf"			:	return (this.validAttributesPdf.indexOf(attr)!=-1);
				
				case "setFormat"	:	return (this.validAttributesFormats.indexOf(attr)!=-1);
										
				case "addImage"		:	return (this.validAttributesImage.indexOf(attr)!=-1);

				case "cell:image"	:	return (this.validAttributesImageCell.indexOf(attr)!=-1);
				
				case "cell:text"	:	return (this.validAttributesTextCell.indexOf(attr)!=-1);
				
				case "table"		:	return (this.validAttributesTable.indexOf(attr)!=-1);
				
				case "row"			:	return (this.validAttributesRow.indexOf(attr)!=-1);
				
				default				: 	trace("isValidAttribute: default case");
										return false;
			}
		}
		
		/**
		Método protegido para inicializar el hash que retorna los valores de estilos de purepdf.
		**/
		protected function initStylesValues(){
			this.styles = new Object();
			this.styles["normal"] = Font.NORMAL;
			this.styles["bold"] = Font.BOLD;
			this.styles["italic"] = Font.ITALIC;
			this.styles["bold-italic"] = Font.BOLDITALIC;
			this.styles["italic-bold"] = Font.BOLDITALIC;
		}
		
		/**
		Método público que dado el nombre de un estilo retorna la constante correspondiente a dicho estilo según purepdf. 
		**/
		public function getStyle(style:String):int{
			return this.styles[style];
		}
		
		/**
		Método protegido para inicializar el hash que retorna los valores de fonts de purepdf.
		**/
		protected function initFontsValues():void{
			this.fonts = new Object();
			this.fonts["courier"]	= Font.COURIER;
			this.fonts["times_roman"]	= Font.TIMES_ROMAN;
			this.fonts["helvetica"]	= Font.HELVETICA;			
		}
		
		
		/**
		Método público que dado el nombre de una font retorna la constante correspondiente a dicha font según purepdf. 
		**/
		public function getFont(font:String):Object{
			return this.fonts[font];
		}
		
		/**
		Método protegido para inicializar el hash que retorna los valores de alineación horizontal de purepdf.
		**/
		protected function initHAlignValues(){
			this.hAligns = new Object();
			this.hAligns["left"] = Element.ALIGN_LEFT;
			this.hAligns["center"] = Element.ALIGN_CENTER;
			this.hAligns["right"] = Element.ALIGN_RIGHT; 
		}
		
		/**
		Método público que dado el nombre de una align retorna la constante correspondiente a dicha align horizontal según purepdf. 
		**/
		public function getHAlign(align:String):int{
			return this.hAligns[align];
		}
		
		/**
		Método protegido para inicializar el hash que retorna los valores de alineación vertical de purepdf.
		**/
		protected function initVAlignValues(){
			this.vAligns = new Object();
			this.vAligns["top"] = Element.ALIGN_TOP;
			this.vAligns["middle"] = Element.ALIGN_MIDDLE;
			this.vAligns["bottom"] = Element.ALIGN_BOTTOM; 
		}
		
		/**
		Método público que dado el nombre de una align retorna la constante correspondiente a dicha align vertical según purepdf. 
		**/
		public function getVAlign(align:String):int{
			return this.vAligns[align];
		}		
		
		/**
		Método protegido para inicializar el hash que retorna los valores de ancho de página de purepdf.
		**/
		protected function initPageSizesValues():void{
			this.pageSizes = new Object();
			this.pageSizes["a4"] = PageSize.A4;
			this.pageSizes["letter"] = PageSize.LETTER;
		}
				
		/**
		Método público que dado el nombre de una font retorna la constante correspondiente a dicha font según purepdf. 
		**/
		public function getPageSize(page:String):RectangleElement{
			return this.pageSizes[page];
		}
		
		/**
		Método público que permite determinar si un valor es válido para un determinar tipo de objeto.
		**/
		public function validate(type:String,str:String):Object{
			type = type.toLocaleLowerCase();
			switch (type){
				case "number"	:	if(!isNaN(Number(str)))
										return Number(str);
									else
										throw new Error("'"+str+"' is not a Number.");
									break;
				case "boolean"	: 	if((str=="true") || (str=="false"))
										return (str=="true");
									else
										throw new Error("'"+str+"' is not a Boolean value.");
									break;
				case "style"	:	if(styles[str.toLocaleLowerCase()]!=undefined)
										return str;
									else
										throw new Error("'"+str+"' is not a valid style.");
				case "font"	:		if(fonts[str.toLocaleLowerCase()]!=undefined)
										return str;
									else
										throw new Error("'"+str+"' is not a valid font.");
				case "halign"	:	
				case "hposition": 	if(hAligns[str.toLocaleLowerCase()]!=undefined)
										return str;
									else
										throw new Error("'"+str+"' is not a valid horizontal alignment.");
				case "valign":		if(vAligns[str.toLocaleLowerCase()]!=undefined)
										return str;
									else
										throw new Error("'"+str+"' is not a valid vertical alignment.");
				case "page-size":	if(pageSizes[str.toLocaleLowerCase()]!=undefined)
										return str;
									else
										throw new Error("'"+str+"' is not a valid page size.");
				default			:	return null;
			}
		}
		
		/**
		Metodo publico que dado el nombre de un atributo y un nodo, retorna TRUE si el atributo pertenece al nodo 
		y FALSE en caso contrario.
		**/
		public function existAttribute(attr:String, node:XML):Boolean{
			return (node.attribute(attr).length() != 0);
		}				
	}	
}