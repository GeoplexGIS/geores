
var cityobjects = new Array();
var expandables = new Array();

//Declaring CityGML Objects and methods
function CityObject(name){
    this.name = name;
    this.parts = new Array();
    this.boundedBy = new Array();
    this.outerInstallations = new Array();
    this.constructions = new Array();
    this.openings = new Array();
    this.trafficareas = new Array();
    this.isLoD1Solid = false;
    this.isLoD2Solid = false;
    this.isLoD3Solid = false;
    this.isLoD4Solid = false;
}



function addChild(co,name){
    //alert("in addChhild, with " + co.name + " and Child" + name);
    if(name.indexOf("BuildingPart") != -1 || name.indexOf("TunnelPart") != -1 || name.indexOf("BridgePart") != -1){
        var part = new CityObject(name);
        addPartCityObject(co, part);
    }else if(name.indexOf("WallSurface") != -1 || name.indexOf("GroundSurface") != -1 || name.indexOf("RoofSurface") != -1 || name.indexOf("FloorSurface") != -1
            || name.indexOf("ClosureSurface") != -1 || name.indexOf("CeilingSurface") != -1 || name.indexOf("WaterSurface") != -1 || name.indexOf("WaterGroundSurface") != -1){
        var bound = new CityObject(name);
        addBoundedBySite(co, bound);
     }else if(name.indexOf("BuildingInstallation") != -1 || name.indexOf("BridgeInstallation") != -1 || name.indexOf("TunnelInstallation") != -1){
         var inst = new CityObject(name);
         addInstallationSite(co,inst);
     }else if(name.indexOf("BridgeConstructionElement") != -1 ){
        var constr = new CityObject(name);
        addConstructionCityObject(co, constr);
     }else if(name.indexOf("Door") != -1 || name.indexOf("Window") != -1 ){
         var op = new CityObject(name);
         addOpeningCityObject(co,op);
     }else if(name.indexOf("TrafficArea") != -1){
         var ta = new CityObject(name);
         addTrafficAreas(co,ta);
     }
}

function setLoD1Solid(co, isSolid){
    co.isLoD1Solid = isSolid;
}
function setLoD2Solid(co, isSolid){
    co.isLoD2Solid = isSolid;
}
function setLoD3Solid(co, isSolid){
    co.isLoD3Solid = isSolid;
}
function setLoD4Solid(co, isSolid){
    co.isLoD4Solid = isSolid;
}

 function addPartCityObject(site, p){
        //alert("add New Part" + p.name + " to Element " + site.name);
        site.parts.push(p);
}
function addBoundedBySite(site, b){
        //alert("add New Boundary" + b.name + " to Element " + site.name);
        site.boundedBy.push(b);
}
function addInstallationSite(site, i){
        site.outerInstallations.push(i);
}

function addOpeningCityObject(site, o){
        site.openings.push(o);
}

function addConstructionCityObject(co, o){
    co.constructions.push(o);
}
function addTrafficAreas(co, o){
    co.trafficareas.push(o);
}
//end of CityGML methodes


//declaring interface methods

function createMainObject(elementname, isLoD1, isLoD2, isLoD3, isLoD4)
{
    co = new CityObject(elementname);
    setLoD1Solid(co, isLoD1);
    setLoD2Solid(co, isLoD2);
    setLoD3Solid(co, isLoD3);
    setLoD4Solid(co, isLoD4);
    //alert("add New Site Element " + elementname);
    cityobjects.push(co);
}

function addPart(parentname, elementname, isLoD1, isLoD2, isLoD3, isLoD4){
    //alert("in addPart with " + elementname + " " + parentname);
    for(var i = 0 ; i < cityobjects.length; ++i){
        var co = cityobjects[i];
        //alert("Parentname is " + parentname + "co.name is " + co.name);
        if(parentname == co.name){
            var newCo = new CityObject(elementname);
            setLoD1Solid(newCo, isLoD1);
            setLoD2Solid(newCo, isLoD2);
            setLoD3Solid(newCo, isLoD3);
            setLoD4Solid(newCo, isLoD4);
            addPartCityObject(co, newCo);
        }else{
            checkparts(co.parts, parentname, elementname, isLoD1, isLoD2, isLoD3, isLoD4 );
        }
    }
}

function addBoundary(parentname, elementname){
   //alert("in addBoundary with " + elementname + " " + parentname);
     for(var i = 0 ; i < cityobjects.length; ++i){
        var co = cityobjects[i];
        if(parentname == co.name){
            addBoundedBySite(co,new CityObject(elementname));
        }else{
           if(!checkPartBoundaries(co.parts, parentname, elementname)){
               checkInstallationBoundaries(co.outerInstallations, parentname, elementname);
            }
        }
    }
}
function checkInstallationBoundaries(installations, parentname, elementname){
    for(var i = 0; i < installations.length; ++i){
        var part1 = installations[i];
        if(part1.name == parentname){
             addBoundedBySite(part1,new CityObject(elementname));
            return;
        }
    }
}
function checkPartBoundaries(parts, parentname, elementname){
    //alert("in checkPartBoundaries with " + elementname + " " + parentname);
    for(var i = 0; i < parts.length; ++i){
        var part1 = parts[i];
        //alert("Current partname is " + part1.name)
        if(part1.name == parentname){
            //alert(elementname + " dem Objekt " + part1.name + " zugeordnet");
            addBoundedBySite(part1,new CityObject(elementname));
            return true;
        }else{
            if(checkPartBoundaries(part1.parts, parentname, elementname)){
                return true;
            }
        }
    }
    return false;
}
function checkparts(parts, parentname, elementname,isLoD1, isLoD2, isLoD3, isLoD4 ){
    for(var i = 0; i < parts.length; ++i){
        var part1 = parts[i];
        if(part1.name == parentname){
            var newCo = new CityObject(elementname);
            setLoD1Solid(newCo, isLoD1);
            setLoD2Solid(newCo, isLoD2);
            setLoD3Solid(newCo, isLoD3);
            setLoD4Solid(newCo, isLoD4);
            addPartCityObject(part1, newCo);
            return;
        }
        checkparts(part1.parts, parentname, elementname,isLoD1, isLoD2, isLoD3, isLoD4 );
    }
}

function addInstallation(parentname, elementname){
   // alert("in addInstallation with " + elementname + " " + parentname);
    for(var i = 0 ; i < cityobjects.length; ++i){
        var co = cityobjects[i];
        //alert("Parentname is " + parentname + "co.name is " + co.name);
        if(parentname == co.name){
            addInstallationSite(co, new CityObject(elementname));
        }else{
            checkPartsInstallation(co.parts, parentname, elementname);
        }
    }
}

function checkPartsInstallation(parts, parentname, elementname){
    for(var i = 0; i < parts.length; ++i){
        var part1 = parts[i];
        if(part1.name == parentname){
            addInstallationSite(part1, new CityObject(elementname));
            return;
        }
        checkPartsInstallation(part1.parts, parentname, elementname);
    }
}

function addConstruction(parentname, elementname){
    //alert("in addConstruction with " + elementname + " " + parentname);
    for(var i = 0 ; i < cityobjects.length; ++i){
        var co = cityobjects[i];
       // alert("Parentname is " + parentname + "co.name is " + co.name);
        if(parentname == co.name){
            addConstructionCityObject(co, new CityObject(elementname));
        }else{
            checkPartsConstructions(co.parts, parentname, elementname);
        }
    }
}

function checkPartsConstructions(parts, parentname, elementname){
    for(var i = 0; i < parts.length; ++i){
        var part1 = parts[i];
        if(part1.name == parentname){
            addConstructionCityObject(part1, new CityObject(elementname));
            return;
        }
        checkPartsConstructions(part1.parts, parentname, elementname);
    }
}

function addOpening(parentname, elementname){
    //alert("in addOpening with " + elementname + " " + parentname);
     for(var i = 0 ; i < cityobjects.length; ++i){
        var co = cityobjects[i];
        var boundaries = co.boundedBy
        for(var j = 0; j < boundaries.length; ++j){
           var boundary = boundaries[j];
            if(parentname == boundary.name){
                  addOpeningCityObject(boundary,new CityObject(elementname));
                  return;
              }
        }
        checkPartOpenings(co.parts,parentname, elementname);
        checkInstallationBoundaryOpenings(co.outerInstallations, parentname, elementname);
    }
}

function checkPartOpenings(parts, parentname, elementname){
    for(var i = 0 ; i < parts.length; ++i){
        var co = parts[i];
        var boundaries = co.boundedBy
        for(var j = 0; j < boundaries.length; ++j){
            var boundary = boundaries[j];
            if(parentname == boundary.name){
                  addOpeningCityObject(boundary,new CityObject(elementname));
                  return;
              }
        }
        checkPartOpenings(co.parts,parentname, elementname);
        checkInstallationBoundaryOpenings(co.outerInstallations, parentname, elementname);
    }
}

function checkInstallationBoundaryOpenings(installations, parentname, elementname){
    for(var i = 0 ; i < installations.length; ++i){
        var co = installations[i];
        var boundaries = co.boundedBy
        for(var j = 0; j < boundaries.length; ++j){
           var boundary = boundaries[j];
            if(parentname == boundary.name){
                  addOpeningCityObject(boundary,new CityObject(elementname));
                  return;
              }
        }
    }
}

function addTrafficArea(parentname, elementname){
    for(var i = 0 ; i < cityobjects.length; ++i){
        var co = cityobjects[i];
        if(parentname == co.name){
            addTrafficAreas(co,new CityObject(elementname));
            return;
        }
    }
}




function fillListWithCurrentObjects(){
     
     for(var i = 0 ; i < cityobjects.length; ++i){
         var cityobject = cityobjects[i];
          fillListWithCurrentObject(cityobject, "", "");
     }
     var selectionList = document.getElementById("cityobjects");
     selectionList.selectedIndex = 0;

     
}
function fillListWithCurrentObject(cityobject, hierarchy, parentname){
          var selectionList = document.getElementById("cityobjects");
           // alert("in fillListWithCurrentObject with " + cityobject.name);
          var option = document.createElement("OPTION");
          var newparentname = parentname + "@" + cityobject.name;
          if(parentname == ""){
              newparentname = cityobject.name ;
          }
          var newhierarchy = hierarchy + "";


          option.name =  cityobject.name;
          option.label = hierarchy + cityobject.name;
          option.id = newparentname;
          selectionList.add(option);
          if(cityobject.isLoD1Solid){
              var optionL1 = document.createElement("OPTION");
              optionL1.name = cityobject.name + "@lod1Solid";
              optionL1.label = newhierarchy + "lod1Solid";
              optionL1.id = cityobject.name + "@lod1Solid";
              optionL1.style.color = 'green';
              selectionList.add(optionL1);
          }
          if(cityobject.isLoD2Solid){
              var optionL2 = document.createElement("OPTION");
              optionL2.name = cityobject.name + "@lod2Solid";
              optionL2.label = newhierarchy + "lod2Solid";
              optionL2.id = cityobject.name + "@lod2Solid";
              optionL2.style.color = 'green';
              selectionList.add(optionL2);
          }
         if(cityobject.isLoD3Solid){
              var optionL3 = document.createElement("OPTION");
              optionL3.name = cityobject.name + "@lod3Solid";
              optionL3.label = newhierarchy + "lod3Solid";
              optionL3.id = cityobject.name + "@lod3Solid";
              optionL3.style.color = 'green';
              selectionList.add(optionL3);
          }
          if(cityobject.isLoD4Solid){
              var optionL4 = document.createElement("OPTION");
              optionL4.name = cityobject.name + "@lod4Solid";
              optionL4.label = newhierarchy + "lod4Solid";
              optionL4.id = cityobject.name + "@lod4Solid";
              optionL4.style.color = 'green';
              selectionList.add(optionL4);
          }


          if(cityobject.parts.length > 0){
              var optionConsists = document.createElement("OPTION");
              optionConsists.name = cityobject.name + "@consistsOf";
              optionConsists.label = newhierarchy + "+consistsOf";
              optionConsists.id = cityobject.name + "@consistsOf";
              optionConsists.style.color = 'blue';
              selectionList.add(optionConsists);
              if(checkExpandables(optionConsists.name) == true){
                   optionConsists.label = newhierarchy + "-consistsOf";
                  for(var i = 0; i < cityobject.parts.length; ++i){
                      var newhierarchy_1 = newhierarchy + "     ";
                      fillListWithCurrentObject(cityobject.parts[i], newhierarchy_1,newparentname);
                  }
              }
          }
          if(cityobject.boundedBy.length > 0){
              var optionBB = document.createElement("OPTION");
              optionBB.name = cityobject.name + "@boundedBy";
              optionBB.label = newhierarchy + "+boundedBy";
              optionBB.id = cityobject.name + "@boundedBy";
              optionBB.style.color = 'blue';
              //alert("in call boundedby");
              selectionList.add(optionBB);
              if(checkExpandables(optionBB.name) == true){
                  optionBB.label = newhierarchy + "-boundedBy";
                  
                  for(var i1 = 0; i1 < cityobject.boundedBy.length; ++i1){
                      var newhierarchy2 = newhierarchy + "     ";
                      fillListWithCurrentObject(cityobject.boundedBy[i1], newhierarchy2,newparentname);
                  }
              }
          }
          if(cityobject.outerInstallations.length > 0){
              var optionI= document.createElement("OPTION");
              optionI.name = cityobject.name + "@outerInstallation";
              optionI.label = newhierarchy + "+outerInstallation";
              optionI.id = cityobject.name + "@outerInstallation";
               optionI.style.color = 'blue';
              selectionList.add(optionI);
               if(checkExpandables(optionI.name) == true){
                   optionI.label = newhierarchy + "-outerInstallation";
                  for(var i2 = 0; i2 < cityobject.outerInstallations.length; ++i2){
                      var newhierarchy3 = newhierarchy + "     ";
                      fillListWithCurrentObject(cityobject.outerInstallations[i2], newhierarchy3,newparentname);
                  }
              }
          }
          if(cityobject.constructions.length > 0){
              var optionI1= document.createElement("OPTION");
              optionI1.name = cityobject.name + "@outerConstruction";
              optionI1.label = newhierarchy + "+outerConstruction";
              optionI1.id = cityobject.name + "@outerConstruction";
               optionI1.style.color = 'blue';
              selectionList.add(optionI1);
               if(checkExpandables(optionI1.name) == true){
                   optionI1.label = newhierarchy + "-outerConstruction";
                  for(var i3 = 0; i3 < cityobject.constructions.length; ++i3){
                      var newhierarchy4 = newhierarchy + "     ";
                      fillListWithCurrentObject(cityobject.constructions[i3], newhierarchy4,newparentname);
                  }
              }
          }
            if(cityobject.trafficareas.length > 0){
              var optionJ= document.createElement("OPTION");
              optionJ.name = cityobject.name + "@trafficArea";
              optionJ.label = newhierarchy + "+trafficArea";
              optionJ.id = cityobject.name + "@trafficArea";
              optionJ.style.color = 'blue';
              selectionList.add(optionJ);
              if(checkExpandables(optionJ.name) == true){
                   optionJ.label = newhierarchy + "-trafficArea";
                  for(var i4 = 0; i4 < cityobject.trafficareas.length; ++i4){
                       var newhierarchy5 = newhierarchy + "     ";
                      fillListWithCurrentObject(cityobject.trafficareas[i4], newhierarchy5,newparentname);
                  }
              }
          }
          if(cityobject.openings.length > 0){
              var optionK= document.createElement("OPTION");
              optionK.name = cityobject.name + "@opening";
              optionK.label = newhierarchy + "+opening";
              optionK.id = cityobject.name + "@opening";
              optionK.style.color = 'blue';
              selectionList.add(optionK);
              if(checkExpandables(optionK.name) == true){
                  optionK.label = newhierarchy + "-opening";
                  for(var i5 = 0; i5 < cityobject.openings.length; ++i5){
                       var newhierarchy6 = newhierarchy + "     ";
                      fillListWithCurrentObject(cityobject.openings[i5], newhierarchy6,newparentname);
                  }
              }
          }
}

function checkExpandables(name)
{
    for(var i = 0; i < expandables.length;++i){
        if(expandables[i] == name){
            return true;
        }
    }
    return false;
}


function handleLoDClick(input_check)
    {
      var lod = 0;
	  if(input_check.name == "lod1_cb"){
	  	lod = 1;
	  }
	  if(input_check.name == "lod2_cb"){
	  	lod = 2;
	  }
	  if(input_check.name == "lod3_cb"){
	  	lod = 3;
	  }
	  if(input_check.name == "lod4_cb"){
	  	lod = 4;
	  }
      window.location = "skp:showlod@" + lod + "&" + input_check.checked;
      //fillCityObject("test2")
   }

   function handleselectionobserver(input_check)
   {
       window.location = "skp:handleobserver@"  + input_check.checked;
   }

function trydelete(event)
{
    return;
    var keynum;
    return;
    event = event || window.event
    keynum = event.keyCode;
   var keynumString = keynum.toLocaleString();
    //alert(keynumString);
    if(keynum == "46")
    {
        alert("delete gefunden");
        var selectionList = document.getElementById("cityobjects");
       if(selectionList.selectedIndex == -1)
            {
                return;
         }
        var optionToDelete = selectionList.options[selectionList.selectedIndex];
        if(isExpandableObjectName(optionToDelete.id) ){
            alert("Dieser Eintrag kann nicht entfernt werden!");
            return;
        }
        for(var i = 0; i < cityobjects.length; ++i){
            if(optionToDelete.name == cityobjects[i].name){
                alert("Entfernen eines Hauptobjektes nicht m&ouml;glich");
                return;
            }
        }

        var retVal = confirm("Wollen Sie das Objekt " + optionToDelete.name + " wirklich entfernen?");
        if(retVal == true){
            window.location = "skp:delete@" + optionToDelete.id;
            selectionList.remove(selectionList.selectedIndex);
            var arrSplit = optionToDelete.id.split("@");
            var mainObjectName = arrSplit[0];
            var parentObject = getCityObjectWithName(mainObjectName);
            for(var j = 1; j < arrSplit.length-1;++j){
                parentObject = getCityObjectChildFromParent(parentObject, arrSplit[j]);
            }
            deleteChildFromParentWithName(parentObject, arrSplit[arrSplit.length-1], selectionList);
        }
    }
}

function isExpandableObjectName(name){
    //alert ("in isExpandableObjectName with " + name);
    if(name.indexOf("@consistsOf") != -1 || name.indexOf("@boundedBy") != -1 || name.indexOf("@outerInstallation") != -1 || name.indexOf("@outerConstruction") != -1 || name.indexOf("@trafficArea") != -1 || name.indexOf("@opening") != -1){
        //alert("true");
        return true;
    }
    //alert("false");
    return false;
}

function getCityObjectWithName(name){
    for(var i = 0; i < cityobjects.length;++i){
        if(name == cityobjects[i].name){
            return cityobjects[i];
        }
    }
    return null;
}

function deleteChildFromParentWithName(parentObject, name, selectionList){

    for(var i = 0; i < parentObject.parts.length; ++i){
       var pname = parentObject.parts[i].name;
       if(pname == name){
           var deletedObject = parentObject.parts.splice(i,1);
           var NameToDelete = "";
           if(parentObject.parts.length == 0){
               NameToDelete = parentObject.name + "@consistsOf";
           }
            for(var z = 0; z < selectionList.options.length; ++z)
            {
                var o = selectionList.options[z];
                if(o.name == name){
                    selectionList.remove(z);
                    --z;
                }else if(NameToDelete != "" && NameToDelete == o.name){
                    selectionList.remove(z);
                    --z;
                }
             }
       }
   }
   for(var j = 0; j < parentObject.boundedBy.length; ++j){
       var pnameJ = parentObject.boundedBy[j].name;
       if(pnameJ == name){
          
       }
   }
   for(var k = 0; k < parentObject.outerInstallations.length; ++k){
       var pnameK = parentObject.outerInstallations[k].name;
       if(pnameK == name){
           
       }
   }
   for(var l = 0; l < parentObject.constructions.length; ++l){
       var pnameL = parentObject.constructions[l].name;
       if(pnameL == name){
           
       }
   }
   for(var m = 0; m < parentObject.openings.length; ++m){
       var pnameM = parentObject.openings[m].name;
       if(pnameM == name){
           
       }
   }
   for(var n = 0; n < parentObject.trafficareas.length; ++n){
       var pnameN = parentObject.trafficareas[n].name;
       if(pnameN == name){
           
       }
   }
}


function getCityObjectChildFromParent(parentObject, name){
   for(var i = 0; i < parentObject.parts.length; ++i){
       var pname = parentObject.parts[i].name;
       if(pname == name){
           return parentObject.parts[i];
       }
   }
   for(var j = 0; j < parentObject.boundedBy.length; ++j){
       var pnameJ = parentObject.boundedBy[j].name;
       if(pnameJ == name){
           return parentObject.boundedBy[j];
       }
   }
   for(var k = 0; k < parentObject.outerInstallations.length; ++k){
       var pnameK = parentObject.outerInstallations[k].name;
       if(pnameK == name){
           return parentObject.outerInstallations[k];
       }
   }
   for(var l = 0; l < parentObject.constructions.length; ++l){
       var pnameL = parentObject.constructions[l].name;
       if(pnameL == name){
           return parentObject.constructions[l];
       }
   }
   for(var m = 0; m < parentObject.openings.length; ++m){
       var pnameM = parentObject.openings[m].name;
       if(pnameM == name){
           return parentObject.openings[m];
       }
   }
   for(var n = 0; n < parentObject.trafficareas.length; ++n){
       var pnameN = parentObject.trafficareas[n].name;
       if(pnameN == name){
           return parentObject.trafficareas[n];
       }
   }
   return null;
}


   function refresh()
    {
       //alert("called refresh ");
      window.location = "skp:refresh";
      //fillCityObject("test2")
   }

       function fillCityObject(name, parent)
       {
           // alert("in fillCityObject with " + name);
           var element = document.getElementById("cityobjects");
           //alert("options " + element.options.toString())
           if(parent != null)
           {
               var arr_string = parent.split(".");
               for(var i = 0; i < arr_string.length; ++i){
                   alert("String is " + arr_string[i]);
                   parent = arr_string[i];
                   var group = element.getElementsByTagName(parent)[0];
                   if(group == null)
                   {
                       alert("Group is null. Create Optgroup " + parent);
                       var optgroup = document.createElement("OPTGROUP")
                       optgroup.name = parent;
                       optgroup.label = parent;
                       element.add(optgroup);
                       element = optgroup;
                   }
               }
           }else{
               var optgroup = document.createElement("OPTGROUP");
                  optgroup.name = parent;
                  optgroup.label = parent;
                  element.add(optgroup);
           }
                  
        }

        function clearOptionGroup()
        {
            // alert("called clearOptionGroup");
            var element = document.getElementById("cityobjectgroup");
            element.parentNode.removeChild(element);
            var selectionList = document.getElementById("cityobjects");
            var optgroup = document.createElement("OPTGROUP");
            optgroup.id = "cityobjectgroup";
            optgroup.label = "CityObjects";
            optgroup.name = "cos";
            selectionList.add(optgroup);


        }

        function clear(){
            cityobjects = new Array();
            expandables = new Array();
            clearAttributeList();
        }

        function clearAttributeContentList(){
            var element = document.getElementById("attribute_content");
            element.value = "";

        }

          function clearAttributeList()
        {
            // alert("called clearOptionGroup");
            var element = document.getElementById("att_list_group");
            element.parentNode.removeChild(element);
            var selectionList = document.getElementById("att_list");
            var optgroup = document.createElement("OPTGROUP");
            optgroup.id = "att_list_group";
            optgroup.label = "CityObject Attributes";
            optgroup.name = "attlist";
            selectionList.add(optgroup);
            clearAttributeContentList();
        }

        function selectioncall(parentname, elementname, hierarchy)
        {
           // alert("called selectioncall");
           var element = document.getElementById("cityobjectgroup");
           var hiddenList = document.getElementById("hidden_cityobjects");
           var option = document.createElement("OPTION");
           option.name = elementname;
           var labelname = "";
           for(var i = 0; i < hierarchy; ++i){
               labelname += "   ";
           }
           option.label = labelname + elementname;
           
           if(elementname.toLocaleString().indexOf("BuildingPart", 0) != -1 || elementname.toLocaleString().indexOf("BridgePart", 0) != -1
                   || elementname.toLocaleString().indexOf("TunnelPart", 0) != -1){
                   //alert ("found a Part");
                   var consistof = document.getElementById(parentname + "@consistsof");
                   if(consistof == null)
                    {
                           alert (parentname + "@consistsof does not exist");
                           var optionC = document.createElement("OPTION");
                           optionC.name = "consistsOf";
                           var labelnameC = "";
                           for(var i = 0; i < hierarchy; ++i){
                               labelnameC += "   ";
                           }
                           optionC.label = labelnameC + "+consistsOf";
                           optionC.id = parentname + "@consistsof"
                          // alert("add option " + optionC.name + "to cityObjectsGroup");
                           element.appendChild(optionC);

                           option.id = elementname + "@" + optionC.id
                           hiddenList.add(option);
                     }

            }else if(elementname.toLocaleString().indexOf("RoofSurface", 0) != -1 || elementname.toLocaleString().indexOf("WallSurface", 0) != -1
                || elementname.toLocaleString().indexOf("FloorSurface", 0) != -1 || elementname.toLocaleString().indexOf("CeilingSurface", 0) != -1
                || elementname.toLocaleString().indexOf("GroundSurface", 0) != -1 || elementname.toLocaleString().indexOf("WaterSurface", 0) != -1
                || elementname.toLocaleString().indexOf("WaterGroundSurface", 0) != -1 || elementname.toLocaleString().indexOf("ClosureSurface", 0) != -1){


            }else{
                element.appendChild(option);
            }
        
        }
        
        function addchild(elementname)
        {
           // alert("called selectioncall");
           var selectionList = document.getElementById("cityobjects");
          var selectIndex = selectionList.selectedIndex + 1
          if(selectIndex == 0){
              ++selectIndex;
          }
          // alert("current selectIndex is " + selectIndex);

           var element = document.getElementById("cityobjectgroup");
           var option = document.createElement("option");
           option.name = elementname;
           option.label = "       " + elementname;
           selectionList.add(option,selectIndex );
        }

        function addchildNew(elementname, parentname)
        {
            //alert ("Parentname is " + parentname);
            var parents = parentname.split("@");
            //alert("Parent array after split is " + parents.toLocaleString());
            var parentObject = getCityObjectWithName(parents[0]);
            if(parentObject == null){
                //alert("ParentObject" + parents[0] + " null");
                return;
            }
            for(var j = 1; j < parents.length;++j){
                parentObject = getCityObjectChildFromParent(parentObject, parents[j]);
            }
            //alert("ParentObject " + parentObject.name);
            addChild(parentObject, elementname);
            clearOptionGroup();
            fillListWithCurrentObjects();

        }

        function removechild(tagname)
        {
             var selectionList = document.getElementById("cityobjects");
              for (var i=0; i<selectionList.length; i++){
                  if (selectionList.options[i].name == tagname )
                     selectionList.remove(i);
             }
        }



         function selection_attributecall(elementname)
        {
         //alert("called selection_attributecall");
           var element = document.getElementById("att_list_group");
           var option = document.createElement("OPTION");
           option.name = elementname;
           var labelname = "";
           //for(var i = 0; i < hierarchy; ++i){
              // labelname += "&nbsp;&nbsp;&nbsp;";
           //}
           option.label = labelname + elementname;
           element.appendChild(option);
        }

        function selection_attribute_contentcall(value){
            //alert ("try to put value in textarea: " + value);
            var element = document.getElementById("attribute_content");
            element.value += "\n" + value;
        }

   function itemselected(){
           clearAttributeList();

            var selectionList = document.getElementById("cityobjects");
            var option = selectionList.options[selectionList.selectedIndex];
            var oldIndex = selectionList.selectedIndex;
            //alert("itemselected " + option.name);
            var indexToPutIn = selectionList.selectedIndex + 1;
            if(isExpandableObjectName(option.name)){
                if(option.label.indexOf("+") != -1){
                   // alert("add " + option.name + " to expandables")
                    expandables.push(option.name);
                }else{
                    var indToDelete = -1;
                    for(var i = 0; i < expandables.length; ++i){
                        if(expandables[i] == option.name){
                            indToDelete = i;
                        }
                    }
                    if(indToDelete != -1){
                        //alert (indToDelete + " zu löschender Index");
                        var newexpandables = new Array();
                        for(var k = 0; k < expandables.length; ++k){
                            if(k != indToDelete){
                                newexpandables.push(expandables[k]);
                            }
                        }
                        expandables = newexpandables;
                    }
                }
                clearOptionGroup();
                fillListWithCurrentObjects();
                selectionList.selectedIndex = oldIndex;
                return;
            }

            var optionMainObject = selectionList.options[0];
            if(option != null)
             {
                 //alert("call: skp:get_attributes@" + option.id );
                  window.location = "skp:get_attributes@" + option.id ;
             }
        }

        function item_att_selected(){

            var selectionListATT = document.getElementById("att_list");
            var selectionListOBJ = document.getElementById("cityobjects");
            var optionAtt = selectionListATT.options[selectionListATT.selectedIndex];
            var optionOBJ = selectionListOBJ.options[selectionListOBJ.selectedIndex];
            if(optionAtt != null && optionOBJ != null)
             {
                 //alert("skp:get_attribute_content@" + optionOBJ.name + "&" + optionAtt.name);
                  window.location = "skp:get_attribute_content@" + optionOBJ.name + "&" + optionAtt.name;

             }
        }

        function saveatt(){
            var selectionListATT = document.getElementById("att_list");
            var selectionListOBJ = document.getElementById("cityobjects");
            var optionAtt = selectionListATT.options[selectionListATT.selectedIndex];
            var optionOBJ = selectionListOBJ.options[selectionListOBJ.selectedIndex];
            var element = document.getElementById("attribute_content");
           
            if(optionAtt != null && optionOBJ != null)
             {
                 //alert("skp:get_attribute_content@" + optionOBJ.name + "&" + optionAtt.name);
                  window.location = "skp:save_attribute_content@" + optionOBJ.name + "&" + optionAtt.name + "&" + element.value;

             }
        }

