package  com.kpm.reporter.pdf.standard{
	import com.kpm.reporter.pdf.AtomsList;
	import com.kpm.reporter.pdf.ImgData;
	
	public class StandardDynamicParser{
		protected var pdfReportXML : XML;
		protected var atoms : AtomsList;
		protected var orgs : Array;
		protected var dynamicData : XML;
		protected var imgData: ImgData;		
		protected var orgCodes : XML;
				
		public function StandardDynamicParser(pReportXML:XML, orgCodes:XML, imgData:ImgData, atoms:AtomsList) {
			this.orgCodes = orgCodes;
			this.atoms = atoms;
			this.dynamicData = new XML(<Root><Part1/><Part2/></Root>);
			this.imgData = imgData;	
			this.pdfReportXML = pReportXML;			
		}
		
		/**
		Método publico que dado una key (kidFirstName,kidLastName,etc) retorna el valor asociado.
		**/
		public function getDataByKey(key:String): String{			
			return String(this.atoms.getObject(key));
		}
		
		/**
		Método publico que retorna el objeto XML que contiene la información dinamica.
		**/
		public function getDynamicData():XML{
			return this.dynamicData;
		}
		
		
		/**
		Método público que parsea el XML correspondiente al tag Loop del archivo original y genera un nuevo XML (dynamicData)
		con los datos necesarios para generar el documento PDF.
		**/		
		public function parseDynamicData(){	 
			var categoryFormat:String = "";
			var qlAttrs = new Array();
						
			for each( var category : XML in pdfReportXML.*)
			{
				//Category : Numbers and Operations
								
				if(category.name().toString().toLowerCase() == "setformat"){
					categoryFormat = category.@name.toString().toLowerCase();					
				}else{
					this.atoms.addAtom("category", category.@text);
					
					var categoryTag:String = "<" + category.@name.toString() + " text='" + category.@text + "' " + String((categoryFormat!="")?"format='" + categoryFormat + "'":"") + String((category.hasOwnProperty("@numbering"))?"numbering='" + category.@numbering + "'":"") + " />";
					this.dynamicData.Part1.appendChild(new XML(categoryTag));
					this.dynamicData.Part2.appendChild(new XML(categoryTag));										
				
					var standardFormat:String = "";
					//Ciclo únicamente en el contenido de la categoría actual.
					for each(var standard : XML in pdfReportXML.category.(@name==category.@name).*)
					{
						//Standard : IdentifyNumber												
						if(standard.name().toString().toLowerCase() == "setformat"){
							standardFormat = standard.@name.toString().toLowerCase();
						}else{							
							this.atoms.addAtom("standard", standard.@text)														
							var standardTag:String = "<" + standard.@name.toString() + " text='" + standard.@text + "'" + String((standardFormat!="")?"format='" + standardFormat + "'":"") + String((standard.hasOwnProperty("@numbering"))?"numbering='" + standard.@numbering + "'":"") + "/>";
							this.dynamicData.Part1.child(category.@name.toString())[0].appendChild(new XML(standardTag));							
							this.dynamicData.Part2.child(category.@name.toString())[0].appendChild(new XML(standardTag));																					
							
							//Organization Code
							if(atoms.getObject("isTeacherReport")){								
								for each(var org:String in atoms.getObject("currentOrgs")){
									if(this.getOrgCode(standard.@name, org) != ""){
										var code:String = "<OrgCode org='" + org + "' code='" + this.getOrgCode(standard.@name, org) + "' />";
										this.dynamicData.Part1.child(category.@name.toString())[0].child(standard.@name.toString())[0].appendChild(new XML(code));
										this.dynamicData.Part2.child(category.@name.toString())[0].child(standard.@name.toString())[0].appendChild(new XML(code));									

									}
								}								
							}						
							var qlFormat:String = "";				
							//Ciclo únicamente en el contenido de la categoría y standard actuales.
							for each( var ql : XML in pdfReportXML.category.(@name==category.@name).standard.(@name==standard.@name).*)
							{			
								trace("processing ql " + ql.@name.toString());					
								if(ql.name().toString().toLowerCase() == "setformat"){
									qlFormat = ql.@name.toString().toLowerCase();
								}else{
									var structString : String;
									var structArray : Array;
									var currentStruct : String;
									
									//struct is a state, if struct is not defined, use old struct
									if(ql.@struct[0])
										currentStruct = ql.@struct;										
									
									structArray = currentStruct.split(".")	
									
									for each (var var_name : String in structArray)
									{
										//if attribute var_name (ex : letter) exists in the tag
										if(ql.@[var_name][0])
										{
											qlAttrs[var_name] = ql.@[var_name];
											atoms.addAtom(var_name, ql.@[var_name]);
										}
										//else it has to be defined already in the atoms array
										else
										{
											var index : String = ql.@name;
										}
									}
									
									var imageNames: Array = (atoms.getObject("imagesName") as Array);
									var qLine, imgWithWidth:String;
									var qlAttrsHow = qlAttrs["how"];
									
									if(qlAttrsHow == "")
										qlAttrs = ".";
									else
										qlAttrs = " " + qlAttrs["how"] + ".";
										
									
									if(atoms.getObject("qq1")[ql.@name.toString()] != undefined){
										imgWithWidth = (this.imgData.exists(ql.@name.toString().toLocaleLowerCase() + ".jpg")) ? "img = '" + this.imgData.getImgsPath() + "//" + ql.@name.toString().toLocaleLowerCase() + ".jpg' width = '"+ this.imgData.getWidth(ql.@name.toString().toLocaleLowerCase() + ".jpg") +"'" : "";
										qLine = atoms.getObject("kidFirstName") + " " + qlAttrs["can"] + " " + atoms.getObject("qq1")[ql.@name.toString()] + qlAttrsHow;
										dynamicData.Part1.child(category.@name.toString())[0].child(standard.@name.toString())[0].appendChild(new XML("<ql text='" + qLine + "'" + String((qlFormat!="")?"format='" + qlFormat + "'":"") + String((ql.hasOwnProperty("@numbering"))?"numbering='" + ql.@numbering + "'":"") + imgWithWidth + "/>"));  
									}
									else if(atoms.getObject("qq2")[ql.@name.toString()] != undefined){
										imgWithWidth = (this.imgData.exists(ql.@name.toString().toLocaleLowerCase() + ".jpg")) ? "img = '" + this.imgData.getImgsPath() + "///" + ql.@name.toString().toLocaleLowerCase() + ".jpg' width = '"+ this.imgData.getWidth(ql.@name.toString().toLocaleLowerCase() + ".jpg") +"'" : "";
										qLine = atoms.getObject("kidFirstName") + " " + qlAttrs["cano"] + qlAttrsHow;
										dynamicData.Part1.child(category.@name.toString())[0].child(standard.@name.toString())[0].appendChild(new XML("<ql text='" + qLine + "'" + String((qlFormat!="")?"format='" + qlFormat + "'":"") + String((ql.hasOwnProperty("@numbering"))?"numbering='" + ql.@numbering + "'":"") + imgWithWidth +"/>"));
									}									
									if(atoms.getObject("qq2")[ql.@name.toString()] != undefined){
										imgWithWidth = (this.imgData.exists(ql.@name.toString().toLocaleLowerCase() + ".jpg")) ? "img = '" + this.imgData.getImgsPath() + "//" + ql.@name.toString().toLocaleLowerCase() + ".jpg' width = '"+ this.imgData.getWidth(ql.@name.toString().toLocaleLowerCase() + ".jpg") +"'" : "";
										qLine = atoms.getObject("kidFirstName") + " " + qlAttrs["cannot"] + " " + atoms.getObject("qq2")[ql.@name.toString()] + qlAttrsHow;
										dynamicData.Part2.child(category.@name.toString())[0].child(standard.@name.toString())[0].appendChild(new XML("<ql text='" + qLine + "'" + String((qlFormat!="")?"format='" + qlFormat + "'":"") + String((ql.hasOwnProperty("@numbering"))?"numbering='" + ql.@numbering + "'":"") + imgWithWidth +"/>"));
									}									
									qlFormat = "";
								}				
							}
						}
					}
				}	
			}
		}
		
		/**
		Método protegido que retorna el código correspondiente al standard y organización indicados.
		**/
	   	protected function getOrgCode(standard:String, org:String):String{	   			
			return this.orgCodes.organization.(@name == org).standard.(@name == standard).age.(@level == String(this.atoms.getObject("currentAge"))).toString();
		}
	   	
		/**
		Método protegido que retorna el conjunto organizaciones seleccionados en pares de la forma [iniciales, nombre completo].
		**/
		public function getSelectedOrgs():Array{
			var orgs:Array = new Array();
			if(atoms.getObject("isTeacherReport")){	
				for each(var org:String in this.atoms.getObject("currentOrgs")){
					orgs.push([org, this.orgCodes.organization.(@name == org).@description]);
				}
			}
			return orgs;
		}

	}	

	
	
}
