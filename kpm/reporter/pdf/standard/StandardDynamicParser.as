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
								trace("teacher report is true");								
								for each(var org:String in atoms.getObject("currentOrgs")){
									trace("current orgs");
									if(this.getOrgCode(standard.@name, org) != ""){
										var code:String = "<OrgCode org='" + org + "' code='" + this.getOrgCode(standard.@name, org) + "' />";
										this.dynamicData.Part1.child(category.@name.toString())[0].child(standard.@name.toString())[0].appendChild(new XML(code));
										this.dynamicData.Part2.child(category.@name.toString())[0].child(standard.@name.toString())[0].appendChild(new XML(code));

									}
								}								
							}						
							var qlFormat:String = "";
							//Variable para llevar el conteo de las ql de la parte 2.
							var ql2Count: int = 0;
							var ql1Count : int = 0;
							//Ciclo únicamente en el contenido de la categoría y standard actuales.
							for each( var ql : XML in pdfReportXML.category.(@name==category.@name).standard.(@name==standard.@name).*)
							{								
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
									var qq1 = atoms.getObject("qq1")[ql.@name.toString()];
									var qq2 = atoms.getObject("qq2")[ql.@name.toString()];

                                    imgWithWidth = "";

									if(qq1 != -1)
									{
										if(qq1 != undefined){
											ql1Count++;
											//imgWithWidth = (this.imgData.exists(ql.@name.toString().toLocaleLowerCase() + ".jpg")) ? "img = '" + this.imgData.getImgsPath() + "//" + ql.@name.toString().toLocaleLowerCase() + ".jpg' width = '"+ this.imgData.getWidth(ql.@name.toString().toLocaleLowerCase() + ".jpg") +"'" : "";
											qLine = atoms.getObject("kidFirstName") + " " + qlAttrs["can"]; 
											if(qq1 != "") 				qLine += " " + qq1;
											if(qlAttrs["how"] != "" ) 	qLine+= " " + qlAttrs["how"];
											qLine+= ".";
											
											dynamicData.Part1.child(category.@name.toString())[0].child(standard.@name.toString())[0].appendChild(new XML("<ql text='" + qLine + "'" + String((qlFormat!="")?"format='" + qlFormat + "'":"") + String((ql.hasOwnProperty("@numbering"))?"numbering='" + ql.@numbering + "'":"") + imgWithWidth + "/>"));  
										}
										else if(qq2 != -1 && qlAttrs["cano"] != ""){
											ql1Count++;
											//imgWithWidth = (this.imgData.exists(ql.@name.toString().toLocaleLowerCase() + ".jpg")) ? "img = '" + this.imgData.getImgsPath() + "/// " + ql.@name.toString().toLocaleLowerCase() + ".jpg' width = '"+ this.imgData.getWidth(ql.@name.toString().toLocaleLowerCase() + ".jpg") +"'" : "";
                                            //imgWithWidth = (this.imgData.exists(ql.@name.toString().toLocaleLowerCase() + ".jpg")) ? "img = '" + this.imgData.getImgsPath() + ql.@name.toString().toLocaleLowerCase() + ".jpg' width = '"+ this.imgData.getWidth(ql.@name.toString().toLocaleLowerCase() + ".jpg") +"'" : "";
											qLine = atoms.getObject("kidFirstName") + " " + qlAttrs["cano"];
											if(qlAttrs["how"] != "")
												qLine+= " " + qlAttrs["how"];
											qLine+= ".";
											
											dynamicData.Part1.child(category.@name.toString())[0].child(standard.@name.toString())[0].appendChild(new XML("<ql text='" + qLine + "'" + String((qlFormat!="")?"format='" + qlFormat + "'":"") + String((ql.hasOwnProperty("@numbering"))?"numbering='" + ql.@numbering + "'":"") + imgWithWidth +"/>"));
										}
									}	
																	
									if(qq2 > 0 || qq2 is String){
										ql2Count++;
										//imgWithWidth = (this.imgData.exists(ql.@name.toString().toLocaleLowerCase() + ".jpg")) ? "img = '" + this.imgData.getImgsPath() + "//" + ql.@name.toString().toLocaleLowerCase() + ".jpg' width = '"+ this.imgData.getWidth(ql.@name.toString().toLocaleLowerCase() + ".jpg") +"'" : "";
                                        //imgWithWidth = (this.imgData.exists(ql.@name.toString().toLocaleLowerCase() + ".jpg")) ? "img = '" + this.imgData.getImgsPath() + ql.@name.toString().toLocaleLowerCase() + ".jpg' width = '"+ this.imgData.getWidth(ql.@name.toString().toLocaleLowerCase() + ".jpg") +"'" : "";

                                        qLine = atoms.getObject("kidFirstName") + " " + qlAttrs["cannot"];
										if(qq2 != "") 					qLine += " " + qq2;
										if(qlAttrs["how"] != "")		qLine+= " " + qlAttrs["how"];
										qLine+= ".";
										
										dynamicData.Part2.child(category.@name.toString())[0].child(standard.@name.toString())[0].appendChild(new XML("<ql text='" + qLine + "'" + String((qlFormat!="")?"format='" + qlFormat + "'":"") + String((ql.hasOwnProperty("@numbering"))?"numbering='" + ql.@numbering + "'":"") + imgWithWidth +"/>"));
									}									
									//qlFormat = "";
								}
							}
							//Si el standard no tiene qualifierLines entonces lo borro.
							if (ql2Count == 0)
							{								
								delete dynamicData.Part2.child(category.@name.toString())[0].child(standard.@name.toString())[0];								
							}	
							
							//Si el standard no tiene qualifierLines entonces lo borro.
							if (ql1Count == 0)
							{								
								delete dynamicData.Part1.child(category.@name.toString())[0].child(standard.@name.toString())[0];								
							}							
						}						
					}			
					//Si la category no tiene standard entonces la borro.
					if (dynamicData.Part2.child(category.@name.toString())[0].children().length() == 0)						
						delete dynamicData.Part2.child(category.@name.toString())[0];
					
					if (dynamicData.Part1.child(category.@name.toString())[0].children().length() == 0)						
						delete dynamicData.Part1.child(category.@name.toString())[0];
				}	
			}
		}
		
		/**
		Método protegido que retorna el código correspondiente al standard y organización indicados.
		**/
	   	protected function getOrgCode(standard:String, org:String):String{	   			
			trace("pex");									

			trace(this.atoms.getObject("currentAge") + " " + standard + " " + org);
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
