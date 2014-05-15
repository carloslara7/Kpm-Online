package com.kpm.reporter.pdf{
	
	public class XmlTagGenerator{
		
		protected var tag:XML;
				
		public function XmlTagGenerator(){
			this.tag = null;
		}
		
		/**
		Método protegido que retorna el nombre del nodo root actual.
		**/
		protected function tagName():String{
			if(this.tag != null)
				return this.tag.name().toString().toLowerCase();
			else return "";
		}
		
		/**
		Método protegido que inserta el argumento en tag XML que se está procesando actualmente.
		**/
		protected function appendTag(newTag:XML){
			if(this.tagName() == "paragraph"){
				this.tag.appendChild(newTag);
			}else{
				if(this.tagName() == "table"){
					var currentRow:XML = this.tag.children()[this.tag.children().length() - 1];
					var currentCell:XML = currentRow.children()[currentRow.children().length() - 1];
					//this.tag.row[currentRow].cell[currentCell].appendChild(newTag);
					currentCell.appendChild(newTag);
				}
			}				
		}
		
		/**
		Método público que crea un tag <text>, lo inserta en la estructura actual si corresponde y lo retorna.
		**/
		public function text(txt:String):XML{
			var txtTag:XML = new XML("<text txt=\"" + txt + "\" />");
			this.appendTag(txtTag);
			return txtTag;
		}
		
		/**
		Método público que crea un tag <setFormat>, lo inserta en la estructura actual si corresponde y lo retorna.
		**/
		public function setFormat(name:String):XML{
			var formatTag:XML = new XML("<setFormat name=\""+name+"\"/>");
			this.appendTag(formatTag);
			return formatTag;
		}
		
		/**
		Método público que crea un tag <paragraph> y lo establece como nodo root del XML global (tag).
		**/
		public function paragraph(){
			this.tag = new XML(<paragraph/>);
		}
		
		/**
		Método público que crea un tag <br />, lo inserta en la estructura actual si corresponde y lo retorna.
		**/
		public function br(){
			var brTag:XML = new XML(<br />);
			this.appendTag(brTag);
			return brTag;
		}
		
		/**
		Método público que crea un tag <format /> y lo retorna.
		**/
		public function format(name:String=null, tabindex:Number=NaN, size:Number=NaN, font:String=null, style:String=null, underlined:String=null){
			var format:String = "<format ";
			if(name != null) format += "name=\"" + name + "\" ";
			if(!isNaN(size)) format += "size=\"" + size + "\" ";
			if(font != null) format += "font=\"" + font + "\" ";
			if(style != null) format += "style=\"" + style + "\" ";
			if(underlined != null) format += "underlined=\"" + underlined + "\" ";
			if(!isNaN(tabindex)) format += "tabindex=\"" + tabindex + "\" ";
			format += " />";
			return new XML(format);
		}
		
		/**
		Método público que crea un tag <table> y lo establece como nodo root del XML global (tag).
		**/
		public function table(border:Number=NaN, halign:String=null, valign:String=null, hposition:String=null, width:Number=NaN){
			var table:String = "<table ";
			if(!isNaN(border)) table += "border=\"" + border + "\" ";
			if(halign != null) table += "halign=\"" + halign + "\" ";
			if(valign != null) table += "valign=\"" + valign + "\" ";
			if(hposition != null) table += "hposition=\"" + hposition + "\" ";
			if(!isNaN(width)) table += "width=\"" + width + "\" ";
			table += "></table>";
			this.tag = new XML(table);			
		}		
		
		/**
		Método público que crea un tag <row> y lo inserta en el XML actual, el cual debe ser una tabla.
		**/
		public function row(halign:String=null, valign:String=null, minheight:Number=NaN){
			var row:String = "<row ";
			if(halign != null) row += "halign=\"" + halign + "\" ";
			if(valign != null) row += "valign=\"" + valign + "\" ";
			if(!isNaN(minheight)) row += "min-height=\"" + minheight + "\" ";
			row += "></row>";
			this.tag.appendChild(XML(row));
		}
		
		/**
		Método público que crea un tag <cell> de tipo imagen y lo inserta en el XML actual, el cual debe ser una tabla con al menos una row.
		**/
		public function imageCell(path:String=null, width:Number=NaN, fit:String=null, halign:String=null, valign:String=null){
			var cell:String = "<cell type=\"image\" ";
			if(path != null) cell += "path=\"" + path + "\" ";
			if(!isNaN(width)) cell += "width=\"" + width + "\" ";
			if(fit != null) cell += "fit=\"" + fit + "\" ";
			if(halign != null) cell += "halign=\"" + halign + "\" ";
			if(valign != null) cell += "valign=\"" + valign + "\" ";
			cell += "></cell>";
			this.tag.children()[this.tag.children().length() - 1].appendChild(XML(cell));
		}
		
		/**
		Método público que crea un tag <cell> de tipo text y lo inserta en el XML actual, el cual debe ser una tabla con al menos una row.
		**/
		public function textCell(width:Number=NaN, halign:String=null, valign:String=null){
			var cell:String = "<cell type=\"text\" ";
			if(!isNaN(width)) cell += "width=\"" + width + "\" ";
			if(halign != null) cell += "halign=\"" + halign + "\" ";
			if(valign != null) cell += "valign=\"" + valign + "\" ";
			cell += "></cell>";
			this.tag.children()[this.tag.children().length() - 1].appendChild(XML(cell));			
		}
		
		/**
		Método que retorna el tag XML actual y lo reinicia para futuras utilizaciones.
		**/
		public function currentTag():XML{
			var ret:XML = this.tag;
			this.tag = null;
			return ret;
		}
	}	
}
