package com.kpm.reporter.pdf{
	import com.kpm.common.Util;
	
	public class AtomsList
	{		
		public var atoms : Object;
		
		//var atom1 : Atom = new Atom("kidsName", "Carlitox", "Primitive")
		//var atom2 : Atom = new Atom("qq", new Array(), "array")
		public function AtomsList() 
		{ 
			atoms = new Object();
		}
		
		//add variable (pName,pObject)
		//or add object pObject to array already defined at pName at index pIndex
		public function addAtom(pName : String, pObject : Object, pIndex : Object = null)
		{
			//Util.debug("AtomList adding : "+ pName + ", " + pObject + ", " + pIndex);
			
			if(!pIndex) 
				atoms[pName] = pObject;
			else
				atoms[pName][pIndex] = pObject;
				
			atoms["lastAtom"] = pObject;
		}
		
		public function getObject(pName : String, index : Object = null) : Object
		{
			var class_str : String = Util.getClassName(atoms[pName]);
			//Util.debug("accessing element " + pName + " with class " + class_str + "and index " + index);
						
			if((class_str != "Array") || (index == null))
				return atoms[pName]; 
			else if(atoms[pName][index])
			{
				//Util.debug("accessing element " + index + " of variable " + pName);	
				return atoms[pName][index];
			}
			else
			{
				//Util.debug("that index is not valid")
				return null;
			}			
		}			
		
		public function get LastAtom() : Object
		{
			return atoms["lastAtom"];
		}
	}
}