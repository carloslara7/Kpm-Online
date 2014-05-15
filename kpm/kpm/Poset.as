/**
 * Created with IntelliJ IDEA.
 * User: carloslara
 * Date: 12/17/13
 * Time: 12:05 AM
 * To change this template use File | Settings | File Templates.
 */
package com.kpm.kpm {

import com.de.polygonal.ds.Array2;
import com.de.polygonal.ds.DListNode;
import com.de.polygonal.ds.Graph;
import com.de.polygonal.ds.GraphArc;
import com.de.polygonal.ds.GraphNode;
import com.de.polygonal.ds.TreeNode;
import com.kpm.common.EGame;
import com.kpm.common.KpmIO;
import com.kpm.common.Util;
import com.kpm.kpm.KpmBubble;

import flash.events.Event;
import flash.events.EventDispatcher;

import flash.sampler.getSavedThis;

public class Poset extends EventDispatcher
{
    static const PRIMARY : String = "PRIMARY";
    static const FULL : String = "FULL";
    static const FWD : String = "FWD";
    static const BWD : String = "BWD";
    static const GEOMETRY : String = "GEOMETRY"
    static const ADVANCED_POSET : String = "ADVANCED_POSET";
    static const POSITIVE_INFINITY : int = 100;


    //Identifiers for Full, Fwd, Geometry...
    var id                                  : String;
    var bubbleList                          : Array;
    var fwdPoset                            : Poset;
    var bwdPoset                            : Poset;

    //Lista de GraphArcs y GraphNodes para el full graph podemos usar DriverData.dag)
    // luego hay que crear los otros a partir del full Poset incidence matrix
    var dag: Graph;
    var tempIncidenceMatrix : Array2;
    var list_IncidenceMatrices : Array = new Array();


    //List of bubbles indexed by Game ("G1", "G2", "G3", "G4");
    private var bubblesPerGame 		        : Array = new Array();

    //List of bubbles indexed by Game ("G1", "G2", "G3", "G4");
    public var gamEBNames 			        : Array = new Array();

    //Topographical Sorted list of bubbles
    public var topographicallySortedBubbleList	: Array ;
    public static var bubbleAtNode : Array ;

    private var nodeCounter = 0;

    private var predecessorGraph 	        : TreeNode;
    private var _posetProgressionXML   : XMLList;


    //the current bubble's weight, scores, totaltasks and pass/fail counters
    var curWeight 			: Number;
    var curCompleteScore 	: Number;
    var curEnjoyScore 		: Number;
    var curTotalTasks 		: int;
    var curPassCounter 		: int;
    var curFailedCounter 	: int;
    var belongsToFwdPoset, belongsToBwdPoset : Boolean;



    public function Poset(pFileName : String , pId : String, numVertices : int = 300)
    {
        Util.debug("Creating a poset " + pId);
        id = pId;
        bubbleList = new Array(800);
        dag = new Graph(numVertices);

    }



    //BEGIN populating bubble graph. This function is the entry point for PosetProgression.xml
    //Loop through all children of BGProgression and make a bubble

    function populatePosetFromXML(pPosetId : String)
    {
        Util.debug("Poset.populatePosetFromXML" + pPosetId);
        Util.debug("poset xml " + _posetProgressionXML.toXMLString());

        var bubble : KpmBubble;
        DriverData.getInstance().noPredecessorBubbles = new Array();

        for each (var standardXML : XML in _posetProgressionXML.*)
        {
            Util.debug("looping standard XML " + standardXML.@index + " " + standardXML.@active);

            for each(var bubbleGroupXML : XML in standardXML.*)
            {
                Util.debug("bubbleGroup" + bubbleGroupXML.toXMLString());
                saveKpmBubbleVarsFromBubbleGroupXML1(bubbleGroupXML, standardXML.@index);
            }
        }

        for each(var std1 : XML in _posetProgressionXML.*)
        {
            Util.debug("index " + std1.@index + " weight " + std1.@weight);
            DriverData.standards[std1.@index].Weight = std1.@weight;
        }


        populateGames();
        computeDagAndAuxPosets();

        if(DriverData.allBubblesUnlocked)
            DriverData.getInstance().populateTreeMenus();

        this.dispatchEvent(new Event(Event.COMPLETE));

    }

    // BEGIN Create kpmBubble from the XML BubbleGroup it belongs
    public function saveKpmBubbleVarsFromBubbleGroupXML1(pBubbleGroupXML : XML, pStdIndex : int)
    {
        var bubbleNameStr	: String;
        var bId 			: BubbleId;
        var bubbleName 		: EBName
        var equivalenceNum : int ;

        equivalenceNum = pBubbleGroupXML.@equivalenceNum;
        if(equivalenceNum == 0) equivalenceNum = 1;

        for(var i=0; i< equivalenceNum; i++)
        {

            bubbleNameStr = pBubbleGroupXML["name"][i];
            Util.debug("Poset.saveKpmBubbleVarsFromBubbleGroupXML1 " + bubbleNameStr + " " + i)
            bubbleName = EBName[bubbleNameStr];

            curWeight 			= DriverData.DEFAULT_WEIGHT;
            curEnjoyScore 		= DriverData.DEFAULT_ENJOY_SCORE;
            curCompleteScore 	= DriverData.DEFAULT_COMPLETE_SCORE;
            curTotalTasks 		= DriverData.DEFAULT_TOTAL_TASKS;
            curPassCounter 		= DriverData.DEFAULT_PASS_COUNTER;
            curFailedCounter 	= DriverData.DEFAULT_FAILED_COUNTER;
            bubbleName.MinLevel = DriverData.DEFAULT_MIN_LEVEL;
            bubbleName.MaxLevel = DriverData.DEFAULT_MAX_LEVEL;
            belongsToFwdPoset   = false;
            belongsToBwdPoset   = false;

            EBName.bubbleGroupList[bubbleName.Text] = pBubbleGroupXML;

            if("minLevel" in pBubbleGroupXML)
                bubbleName.MinLevel = pBubbleGroupXML.minLevel;
            if("maxLevel" in pBubbleGroupXML)
                bubbleName.MaxLevel = pBubbleGroupXML.maxLevel;

            if(pBubbleGroupXML.@active == "true")
                bubbleName.Active = true;
            else
                bubbleName.Active = false;

            bubbleName.Standard = DriverData.standards[pStdIndex];


            //list of standards. Each standard in the array contains a series of bubbleNames
            //the index is provided to the Enum EBName.
            Util.debug("saving bubbleNamesPerStd " + bubbleName.Text + " in std index " + pStdIndex)
            DriverData.bubbleNamesPerStd[pStdIndex].push(bubbleName);

            Util.debug("making equivalent bubbles for " + pBubbleGroupXML.name + " " + bubbleName.MinLevel + " " + bubbleName.MaxLevel);
            Util.debug("bubbleName " + bubbleNameStr + pBubbleGroupXML.BUBBLE_ID[0]);


            var bubbleIndex : int = pBubbleGroupXML.BUBBLE_ID[0].LEVEL;
            var currentLevel : int = 1;
            var bubbleXML : XML = pBubbleGroupXML.BUBBLE_ID[0];

            for(var j = 1 ; j <= bubbleName.MaxLevel; j++)
            {
                //if another level is specified, and j is already at that level
                if(pBubbleGroupXML.BUBBLE_ID[bubbleIndex+1] && pBubbleGroupXML.BUBBLE_ID[bubbleIndex+1].LEVEL == j)
                {
                    currentLevel = pBubbleGroupXML.BUBBLE_ID[bubbleIndex+1].LEVEL;
                    bubbleXML = pBubbleGroupXML.BUBBLE_ID[bubbleIndex+1];
                    bubbleIndex++;
                }

                bId = BubbleId.makeBIdFromString(bubbleName.Text + "_" + currentLevel);

                Util.debug("will save bubbleId " + bId);
                Util.debug("using index " + bubbleIndex );

                saveKpmBubbleVarsFromBubbleGroupXML2(bId, bubbleXML);
                currentLevel++;
                bubbleXML = new XML();
            }
        }
    }

    public function saveKpmBubbleVarsFromBubbleGroupXML2(pBubbleId : BubbleId, pBubbleXML : XML) : KpmBubble
    {
        Util.debug("Poset.saveKpmBubbleFromBubbleGroupXML")
        var bubbleGroup		: EBName;
        var pBubbleId 		: BubbleId;
        var pReportStr 		: String;

        var pPredecessorList, pSuccessorList : Array;
        var pInitialStatus 	: Boolean;

        //Checking bubbleID to be saved to 'digital format', to be saved in an array that is accessible all the time
        //this is to avoid reading from file all the time.

        if(pBubbleId == null || !(pBubbleId is BubbleId))
        {
            DriverData.logTool.reportError ("error making bubble " + pBubbleXML.BUBBLE_ID + " from XML");
        }

        if(pBubbleXML == null)
        {
            pBubbleXML = new XML();
            Util.debug("bubble XML is null for bid " + pBubbleId);
            return null;
        }

        pSuccessorList = new Array();

        Util.debug("levels " + pBubbleXML.LEVEL + " " + pBubbleId.Level + " " + pBubbleId.Name.MinLevel);
        Util.debug((int(pBubbleXML.LEVEL) == pBubbleId.Level == pBubbleId.Name.MinLevel) + " " + ("LEVEL" in pBubbleXML));



        //if the bubble group has 'initial_status' in the xml, then set the active parameter for the bubble with level 1 of this bubble group
        if("INITIAL_STATUS" in pBubbleXML && pBubbleXML.INITIAL_STATUS == "Active")
            if(!("LEVEL" in pBubbleXML) || ("LEVEL" in pBubbleXML && (int(pBubbleXML.LEVEL) == pBubbleId.Level && pBubbleId.Level == pBubbleId.Name.MinLevel)))
            {
                Util.debug("initial status true for " + pBubbleId)
                pInitialStatus = true;
            }
            else
                pInitialStatus = false;

        //By default if predecessors are not specified, then the predecesosor is the level before this one
        if(!("PREDECESSORS" in pBubbleXML) || pBubbleXML.PREDECESSORS.children().length() == 0)
        {
            var previousBId : BubbleId = new BubbleId(pBubbleId.Name, pBubbleId.Level-1);
            predecessorGraph = new TreeNode("AND");
            predecessorGraph.children.append(new TreeNode(previousBId));
        }
        //If predecessors are specified to None, then save this bubbleId with the bubbles that have no predecessors
        else if(pBubbleXML.PREDECESSORS == "none")
        {
            //Util.debug("predecessors are none");
            predecessorGraph = null;
            DriverData.getInstance().noPredecessorBubbles.push(pBubbleId);
        }
        //Otherwise, loop each one of its children,
        else
        {
            predecessorGraph = new TreeNode("AND");

            for each ( var xmlPredecessor : XML in pBubbleXML.PREDECESSORS.children())
            {
                //if the node is "AND" or "OR", use processPredecessors function to compute the graph of the predecessors
                if (xmlPredecessor.name() == "OR" || xmlPredecessor.name() == "AND")
                {
                    predecessorGraph = new TreeNode(xmlPredecessor.name());
                    createPredecessorsGraph(xmlPredecessor, predecessorGraph);

                    Util.debug(predecessorGraph.dump(), this);
                }

                //otherwise, if the node is a "BUBBLE_ID" then insert it as a predecessor for the current bubble being processed
                else if (xmlPredecessor.name() == "BUBBLE_ID")
                {
                    Util.debug("inserting predecessor" + xmlPredecessor, this);
                    predecessorGraph.children.append(new TreeNode(BubbleId.makeBIdFromString(xmlPredecessor)));
                }
            }
        }

        //Util.debug("current bubble " + pBubbleId);
        //Util.debug("enjoy score xml " + pBubbleXML["ENJOY_SCORE"]);
        //Util.debug("curEnjoyScore " + curEnjoyScore);
        //Util.debug("curWeight " + curWeight);
        //Util.debug("weight xml " + pBubbleXML["WEIGHT"]);

        //if the weight is defined by the xml, then use that
        if("WEIGHT" in pBubbleXML) 				curWeight 		 = pBubbleXML["WEIGHT"];
        if("ENJOY_SCORE" in pBubbleXML)			curEnjoyScore 	 = pBubbleXML["ENJOY_SCORE"];
        if("COMPLETE_SCORE" in pBubbleXML)  	curCompleteScore = pBubbleXML["COMPLETE_SCORE"];
        if("PASS_COUNTER" in pBubbleXML)		curPassCounter 	 = pBubbleXML["PASS_COUNTER"];
        if("FAIL_COUNTER" in pBubbleXML)		curFailedCounter = pBubbleXML["FAIL_COUNTER"];


        //This is specially for Spatial Sense bubbles,
        if(pBubbleId.Name == EBName.SpatialSense)
        {
            curEnjoyScore = 0.6;
            curCompleteScore = 0.8;
        }

        //TO CHECK : Total Tasks : this should go with the bubble!
        pBubbleId.TotalTasks = curTotalTasks;

        if(curTotalTasks > 0 )
            Util.debug("total tasks " + pBubbleId + " " + curTotalTasks, this);

        if("FWD_POSET" in pBubbleXML && pBubbleXML["FWD_POSET"] == "true")
            belongsToFwdPoset = true;

        if("BWD_POSET" in pBubbleXML && pBubbleXML["BWD_POSET"] == "true")
            belongsToBwdPoset = true;



        if(belongsToFwdPoset)
            Util.debug("bubble " + pBubbleId + " belongs to fwd poset");

        //Create a new bubble
        var newBubble : KpmBubble = new KpmBubble(pBubbleId, curWeight, pInitialStatus, predecessorGraph, pSuccessorList,
                curEnjoyScore, curCompleteScore, curPassCounter, curFailedCounter, pReportStr, belongsToFwdPoset, belongsToBwdPoset);


        belongsToFwdPoset = false;

        //Add new kpm Bubble to the array of KpmBubbles
        bubbleList[pBubbleId.Text] = newBubble;
        Util.debug("adding " + newBubble + " to index " + pBubbleId.Text);

        return newBubble;

    }

    // Creating predecessorsGraph
    public function createPredecessorsGraph(pPredecessors : XML, pParent : TreeNode)
    {
        var child : DListNode;

        for each ( var xmlPredecessor : XML in pPredecessors.children())
        {
            Util.debug("processing " + xmlPredecessor, this);

            if (xmlPredecessor.name() == "OR" || xmlPredecessor.name() == "AND")
            {
                child = pParent.children.append(new TreeNode(xmlPredecessor.name()));
                createPredecessorsGraph(xmlPredecessor, TreeNode(child.data));

            }
            else if (xmlPredecessor.name() == "BUBBLE_ID")
            {
                //Util.debug("appending " + xmlPredecessor, this);
                pParent.children.append(new TreeNode(BubbleId.makeBIdFromString(xmlPredecessor)));
            }
        }
    }

    public function computeDagAndAuxPosets()
    {
        Util.debug("Poset.computeDagAndAuxPosets")
        computeSuccessors1fromPredecessors();
        populateDAG();

        if(DriverData.CREATE_FWD_AND_BWD_POSET)
            createFwdORBwdPoset(Poset.FWD);

        topologicalSort();


    }





    // END Create kpmBubble from the XML BubbleGroup it belongs




    // The list of kpm bubbles created from the xml bubble group from the PosetProgression.xml file
    // gets saved as a Directed Acyclic Graph (list of vertices or nodes and edges)
    function populateDAG() //: Graph
    {
        Util.debug("Poset.populateDag");
        //Add nodes (all bubbles)
        for each (var bubble : KpmBubble in bubbleList)
        {

            if(isActive(bubble.Id))
            {
                Util.debug("adding to DAG " + bubble.Id + " " + nodeCounter, this);
                dag.addNode(bubble.Id, nodeCounter);
                bubble.nodeIndex = nodeCounter;
                nodeCounter++;

            }
        }


        //add two arcs whenever an edge is found (one from b1 to b2 one from b2 to b1)
        for each (var b1 : KpmBubble in bubbleList)
        {
            if(isActive(b1.Id))
            {
                Util.debug("considering b1 for adding arc " + b1.Id);

                dag.addArc(b1.nodeIndex,b1.nodeIndex,1);

                Util.debug("successor list length : " + b1.successorList.length + " " + PosetManager.CurrentPoset + " s ");

                Util.printArray(b1.successorList[PosetManager.CurrentPoset]);

                for each (var bId : BubbleId in b1.successorList[PosetManager.CurrentPoset])
                {
                    var b2 : KpmBubble = bubbleList[bId.Text];
                    dag.addArc(b1.nodeIndex, b2.nodeIndex, 1);
                    dag.addArc(b2.nodeIndex,b1.nodeIndex, -1);


                    Util.debug("adding arc " + b1.Id + " " + b1.nodeIndex + " " + b2.Id + " " + b2.nodeIndex, this);
                    Util.debug("getting arc at " + b1.nodeIndex + " " + b2.nodeIndex + " " + dag.getArc(b1.nodeIndex, b2.nodeIndex));
                }
            }

        }

        //return dag;

    }

    public static function isActive(pBId : BubbleId) {
        Util.debug("Poset.isActive" + pBId + " : " + pBId.Name.Standard.Active + " " + pBId.Name.Active + " s" + DriverData.isBubbleGroupSubsetEnabled);

        if(DriverData.isBubbleGroupSubsetEnabled)
            return  (pBId.Name.Standard.Active || pBId.Name.Active);

        return true;

    }


    // Topological Sorting

    function topologicalSort()
    {
        Util.debug("Poset.topographicalSort");
        //        L ← Empty list that will contain the sorted elements (a.k.a. topographicallySortedBubbleList)
        //        S ← Set of all nodes with no incoming edges

        topographicallySortedBubbleList = new Array();

        var S : Array = DriverData.getInstance().noPredecessorBubbles;

        Util.debug("starting topological sort", this);

        //while S is non-empty do
        while (S.length != 0)
        {
            i++;
            var i : int = Util.getRandBtw(0, S.length-1);
            var bId : BubbleId;

            // remove a node n with index i from S
            bId = (S.splice(i,1))[0];

            //TODO
            if(isActive(bId))
                return;


            // if the element is already in the topographicallySortedBubbleList
            if(Util.searchInArray(topographicallySortedBubbleList, bId))
            {
                DriverData.getInstance().errorStr = bId + " is already in sortedBubbles. Cycle found !";
                DriverData.logTool.reportError(DriverData.getInstance().errorStr);
                this.dispatchEvent(new Event(DriverData.CYCLE_FOUND));
                return;
            }

            // insert n into L
            topographicallySortedBubbleList.push(bId);
            var node1  : int = bubbleList[bId.Text].nodeIndex;

            //Util.debug(dag);
            //Util.debug(dag.nodes);
            //Util.debug(dag.nodes[node1]);
            //Util.debug(dag.nodes[node1].OutgoingNodes);


            //Outgoing nodes from dag
            if(dag.nodes[node1])
            {

                Util.debug("topsort bid " + bId , this);
                Util.debug(dag.nodes[node1]);
                Util.debug(dag.nodes[node1].OutgoingNodes);
                Util.debug("pexxx");


                var outgoingEdges : Array = dag.nodes[node1].OutgoingNodes;

                Util.debug("topsort bid " + bId + " " + node1 + " " + dag.nodes[node1].data, this);

                //for each node m with an edge e from n to m do
                //   remove edge e from the graph
                //        if m has no other incoming edges then
                //        insert m into S

                for each (var node2 : GraphNode in outgoingEdges)
                {
                    //Util.debug("removing " + dag.nodes[node1].data + " " + node2.data, this);
                    dag.nodes[node1].removeArc(node2);
                    node2.removeArc(dag.nodes[node1]);

                    if(node2.IncomingNodes.length == 0)
                    {
                        //Util.debug("adding " + node2.data, this);
                        S.push(node2.data);
                    }
                }
            }
        }

        // if graph has edges then
        //     return error (graph has at least one cycle)
        DriverData.getInstance().errorStr = "";
        for each (var node : GraphNode in dag.nodes)
        {
            for each( var arc : GraphArc in node.arcs)
            {
                DriverData.getInstance().errorStr = "graph has cycles, or some components are not connected : ";
                DriverData.getInstance().errorStr += node.data + " ";
                DriverData.getInstance().errorStr += arc.node.data;

                Util.debug(DriverData.getInstance().errorStr, this);
            }
        }

        if(DriverData.getInstance().errorStr != "")
        {
            DriverData.logTool.reportError(DriverData.getInstance().errorStr);
            this.dispatchEvent(new Event(DriverData.CYCLE_FOUND));
        }


    }

    //BEGIN COMPUTING SUCCESSORS
    //Schedule a PostOrder operation on the graph predecessorList
    public function computeSuccessors1fromPredecessors()
    {
        Util.debug("computeSuccessors1fromPredecessors" + PosetManager.CurrentPoset, this);

        for each (var bubble : KpmBubble in bubbleList)
        {
            if(bubble.predecessorGraph[PosetManager.CurrentPoset])
            {
                //Util.debug("populating successors for " +  bubble, this);
                com.kpm.kpm.Kid.postOrder(bubble.predecessorGraph[PosetManager.CurrentPoset], computeSuccessors2fromPredecessors, bubble);
            }

        }
        //Util.debug("end populating successors", this);
    }

    // Post order operation
    public function computeSuccessors2fromPredecessors(pNode : TreeNode, pParentBubble : KpmBubble)
    {
        //Util.debug(pNode.data, this);
        if(pNode.data is BubbleId)
        {
            Util.debug("adding successor " + pParentBubble.Id + " to " + pNode.data, this);
            Util.debug("poset manager current poset : " + PosetManager.CurrentPoset);

            if(!bubbleList[pNode.data.Text])
                Util.debug(pNode.data.Text + " does not exist");
            else
                bubbleList[pNode.data.Text].successorList[PosetManager.CurrentPoset].push(pParentBubble.Id)
        }
    }

    // END POPULATE DAG AND TOPOGRAPHIC SORTING



    // CREATE FWD POSET, BWD POSET

    public function createFwdORBwdPoset(pPosetId : String)
    {
        Util.debug("poset.createFwdORBwdPoset" + pPosetId + dag.size);

        var m1 : Array2 = new Array2(dag.size, dag.size);

            for (var i=0; i < dag.size; i++)
                for(var j=0 ; j< dag.size; j++)
                {
                    if(i==j)
                        m1.set(i,j,0);

                    else
                    {
                        if(dag.getArc(i,j))
                            m1.set(i,j,dag.getArc(i,j).weight);
                        else
                            m1.set(i,j,Poset.POSITIVE_INFINITY);
                    }
                }

        var m2 : Array2 = createTransitiveClosure(pPosetId);


        for (var i=0; i < m2.width; i++)
            for (var j=0 ; j < m2.height; j++)
            {
                if(m2.get(i,j))
                if(m2.get(i,j) != Poset.POSITIVE_INFINITY)
                {
                    var b1 : KpmBubble = Poset.bubbleAtNode[i];
                    var b2 : KpmBubble = Poset.bubbleAtNode[j];


                    if(i == j)
                    {
                        Util.debug("i is equal to j");
                        //dag.addArc(i,j,0);
                    }

                    //Util.debug('considering bubbleNodes to fwd Poset ' + b1.Id.Text + " " + b2.Id.Text  + " " + m2.get(i,j));
                    //get equivalences out of graph!
                    else if(b1 && b2)
                    {
                        if(b1.belongsToFwdPoset && b2.belongsToFwdPoset)
                        {
                            Util.debug("FWD Poset : edge from ij" + i + " " + j + b1.Id.Text + " to " + b2.Id.Text + " : " + m2.get(i,j));
                            dag.addNode(b1, i);
                            dag.addNode(b2, j);
                            dag.addArc(i,j, m2.get(i,j));

                        }
                    }
                }

            }


        parseEdgesIntoXml(Poset.FWD);

        //Util.debug("multiplying m1 and m2");
        //var m3 : Array2 = Util.matrixmult(m1, m2);

        //Util.debug("printing m3");
        //Util.printArray2(m3);
    }



    //Poset.parseGraphIntoXML(Poset.FWD, list_IncidenceMatrices[k], fwdPoset);

    public function parseEdgesIntoXml (posetId : String)
    {
        Util.debug("Poset.parseGraphIntoXML")
        Util.debug( "name of file is " + PosetManager.POSET_PROGRESSION_FILENAME + posetId);
        //input is a set of edges, ij, for each edge, write on the xml for fwd poset
        //posetProgressionXML.children().(@posetId=="FWD").(@bgname==bId.Name).(@level;

        //var fwdPosetXML,bgNameXML, bubbleXML : XML;
        //fwdPoset = posetProgressionXML.appendChild(<POSET posetId="FWD"></POSET>);
        //bgNameXML = fwdPosetXML.appendchild(<BUBBLE_GROUP name== bubbleAtNode[i].Id.Name></BUBBLE_GROUP>)
        //bubbleXML = bgNameXML.appendChild(<BUBBLE level== bubbleAtNode[i].Id.Level></BUBBLE>);
        //bubbleXML.appendChild(<predecessor>bubbleAtNode[i].Id.Text</predecessor>


        /*<BUBBLE_GROUP active="false">
            <name>Count5Frame_15</name>
            <BUBBLE_ID>
                <PREDECESSORS>
                    <BUBBLE_ID>Count5Frame_10_1</BUBBLE_ID>
                    <BUBBLE_ID>Identify5Frame_5</BUBBLE_ID>
                </PREDECESSORS>
            </BUBBLE_ID>
        </BUBBLE_GROUP>
        */

        var fwdPosetXML,bgNameXML, bubbleXML : XML;
        fwdPosetXML = posetProgressionXML.appendChild(<POSET posetId="FWD"></POSET>);


        for (var i=0; i < dag.size ; i++)
        {
            for (var j=0; j < dag.size ; j++)
            {
                //Util.debug("looking at edge ij " + i + " " + j + Poset.bubbleAtNode[i] + " " + Poset.bubbleAtNode[j]);
                if(dag.getArc(i,j))
                {
                    if(i==j)    dag.getArc(i,j).weight = 0;

                    bgNameXML = fwdPosetXML.appendchild(new XML("<BUBBLE_GROUP name='"+bubbleAtNode[i].Id.Name+"'></BUBBLE_GROUP>"));
                    bubbleXML = bgNameXML.appendChild(new XML("<BUBBLE level='"+bubbleAtNode[i].Id.Level+"'></BUBBLE>"));
                    bubbleXML.appendChild(new XML("<predecessor>"+bubbleAtNode[i].Id.Text+"</predecessor>"));

                    /*
                    if(dag.getArc(i,j).weight > 0)
                    {
                        Util.debug(bubbleAtNode[i].Id + " is predecessor of " + bubbleAtNode[j].Id + " " + dag.getArc(i,j).weight);
                        posetProgressionXML.children().(@id=="FWD");
                    }

                    else if(dag.getArc(i,j).weight < 0)
                    {
                        Util.debug(bubbleAtNode[i].Id + " is successor of " + bubbleAtNode[j].Id + " " + dag.getArc(i,j).weight);
                    }
                    */

                }



            }
        }

        Util.debug("fwd poset xml");
        Util.debug(fwdPosetXML.toXMLString);
    }




    public function createTransitiveClosure(pPosetId : String)   : Array2
    {
        trace("Poset.createTransitiveClosure : poset Size " + dag.size);

        //INITIALIZE list of Incidence Matrices
        for (var i=0; i < dag.size; i++)
        {
            tempIncidenceMatrix = new Array2(dag.size, dag.size);
            list_IncidenceMatrices.push(tempIncidenceMatrix);
        }



        Poset.bubbleAtNode = new Array(bubbleList.length);
        for each (var bubble : KpmBubble in bubbleList)
        {
           if(bubble.nodeIndex >= 0)
            Poset.bubbleAtNode[bubble.nodeIndex] = bubble;
        }

        //Should i start with i=0 and j=0 ?
        Util.debug("START INITIALIZING incidence Matrices");
        for (var i = 0; i < dag.size; i++)
            for (var j= 0 ; j < dag.size ; j++)
            {
                if(i == j)
                    list_IncidenceMatrices[0].set(i,j,0);

                else if(dag.getArc(i,j) != null)
                {
                    Util.debug("arc between " + i + " " + j + " " +  Poset.bubbleAtNode[i].Id + " & " + Poset.bubbleAtNode[j].Id);
                    Util.debug(dag.getArc(i,j).weight + " " + dag.getArc(j,i).weight)
                    list_IncidenceMatrices[0].set(i,j,dag.getArc(i,j).weight);
                    list_IncidenceMatrices[0].set(j,i,dag.getArc(j,i).weight);
                }
                else
                {
                    list_IncidenceMatrices[0].set(i,j, Poset.POSITIVE_INFINITY);
                    list_IncidenceMatrices[0].set(i,j, Poset.POSITIVE_INFINITY);
                }

                Util.debug("setting matrixList iteration 0 "  + Poset.bubbleAtNode[i].Id + " to " + Poset.bubbleAtNode[j].Id  + " = " + list_IncidenceMatrices[0].get(i,j));
            }



        Util.debug("recursive step incidence Matrices");
        for (var k = 1; k < dag.size; k++)
        {
            list_IncidenceMatrices[k] = new Array2(dag.size,  dag.size);

            for (var i = 0; i < dag.size; i++)
                for (var j= 0 ; j < dag.size ; j++)
                {
                   if(i!= j)
                   {
                       Util.debug("setting matrixList iteration : " + k + " from " + Poset.bubbleAtNode[i].Id + " to " + Poset.bubbleAtNode[j].Id + " " + " testing going through node " + k + " " + Poset.bubbleAtNode[k].Id);

                       var bestDistanceSoFar =  list_IncidenceMatrices[k-1].get(i,j);
                       var testDistance = list_IncidenceMatrices[k-1].get(i,k) + list_IncidenceMatrices[k-1].get(k, j);

                       if(list_IncidenceMatrices[k-1].get(i,k) == Poset.POSITIVE_INFINITY || list_IncidenceMatrices[k-1].get(k,j) == Poset.POSITIVE_INFINITY)
                            testDistance = 100;

                       Util.debug("testDistance = " + list_IncidenceMatrices[k-1].get(i,k) + " + " + list_IncidenceMatrices[k-1].get(k,j));
                       Util.debug("bestdistance so far " + bestDistanceSoFar + " considering` candidate " + testDistance);

                       var distance : Number;

                        distance = Math.min(bestDistanceSoFar, testDistance);

                       list_IncidenceMatrices[k].set(i, j, distance);

                       Util.debug("= " + list_IncidenceMatrices[k].get(i,j));

                   }
                }


            s+= "k is " + k
            var s : String;
            for (var i=0; i < list_IncidenceMatrices[k].width; i++)
            {
                s= i + "|" + Poset.bubbleAtNode[i].Id;


                for (var j=0; j < list_IncidenceMatrices[k].height; j++)
                {
                    //if(list_IncidenceMatrices[k].get(i,j) < 15)
                    //s+= "Dist from " + Poset.bubbleAtNode[i].Id + " to " + Poset.bubbleAtNode[j].Id + "is ";
                    s+= j + "|";
                    s+=list_IncidenceMatrices[k].get(i,j) + " " ;

                    if(list_IncidenceMatrices[k].get(i,j) < 10 || list_IncidenceMatrices[k].get(i,j) >= 0)
                        s+= ""

                }

                Util.debug(s);
            }
        }





        // TODO : PosetProgression.xml : allow BG to be active or inactive
            //** Add tag to all BG in PP.xml
            //** add super group Standard, grouping different BubbleGroups
            //** Parse the XML and use it everywhere to limit the processing required.
            //** posetProgressionXML.*.@active
            //** posetProgressionXML.* (EBSTD).* (EBNAME).* (BUBBLEID)

            //Check game works with only Spatial Sense and MatchShape


        return list_IncidenceMatrices[dag.size-1];

    }


    //POSET FUNCTION
    //Each game gets a list of bubbles that can be implemented by that game
    //Each element of posetList[Poset.PRIMARY].bubbleList gets added a list of games that can implement that bubble

    private function populateGames()
    {
        Util.debug("Poset.populateGames");

        //HardCode Data Entry to answer the question, which bubbles can be implemented by which games
        gamEBNames = new Array(DriverData.NUM_GAMES);
        gamEBNames[EGame.G1.Text] = [EBStd.SpatialSense, EBName.IdentifyColor, EBName.IdentifySize, EBStd.Numbers_Count, EBStd.Numbers_Identify, EBStd.Numbers_Subset];
        gamEBNames[EGame.G2.Text] = [EBName.IdentifyShape, EBName.IdentifyColor, EBName.MatchShape, EBName.PlaceShapeA, EBName.PlaceShapeB, EBName.PlaceShapeC];
        gamEBNames[EGame.G3.Text] = [EBName.IdentifyColor, EBName.IdentifySize, EBStd.Numbers_Count, EBStd.Numbers_Subset, EBStd.Numbers_Identify];
        gamEBNames[EGame.G4.Text] = [EBStd.Numbers_Count, EBStd.Numbers_Subset, EBStd.Addition, EBStd.Comparison, EBStd.Numbers_Identify];
        gamEBNames[EGame.G4.Text] = [EBStd.PlaceNumber];
        var exceptionsBubblesPerGame : Array = new Array(4);
        exceptionsBubblesPerGame[EGame.G3.Text] = [ new BubbleId(EBName.Identify5Frame, 5), new BubbleId(EBName.Identify5Frame, 6), new BubbleId(EBName.IdentifyNumeral, 5), new BubbleId(EBName.IdentifyNumeral, 6)];


        //Maximum number of elements allowed per game for different bubbles
        //compared to the maximum number of elements for different bubbles
        var maxArrayCount = new Array(DriverData.NUM_GAMES);
        maxArrayCount[EGame.G1.Text] = 10;
        maxArrayCount[EGame.G2.Text] = 0;
        maxArrayCount[EGame.G3.Text] = 10;
        maxArrayCount[EGame.G4.Text] = 20;

        var maxArraySubset = new Array(DriverData.NUM_GAMES);
        maxArraySubset[EGame.G1.Text] = 10;
        maxArraySubset[EGame.G2.Text] = 0;
        maxArraySubset[EGame.G3.Text] = 7;
        maxArraySubset[EGame.G4.Text] = 20;

        var maxArrayIdentify = new Array(DriverData.NUM_GAMES);
        maxArrayIdentify[EGame.G1.Text] = 6;
        maxArrayIdentify[EGame.G2.Text] = 0;
        maxArrayIdentify[EGame.G3.Text] = 4;
        maxArrayIdentify[EGame.G4.Text] = 6;


        bubblesPerGame = new Array(EGame.Consts.length);

        for each (var egame : EGame in EGame.Consts)
            bubblesPerGame[egame.Text] = new Array();


        for (var game : String in gamEBNames)
        {
            Util.debug("PopulatingGames " + game );
            for each ( var bubbleGroup in gamEBNames[game])
            {
                Util.debug("Considering BG " + bubbleGroup.Text);
                if(bubbleGroup is BubbleId)
                {
                    var bId : BubbleId = bubbleGroup as BubbleId;
                    if(bubbleList[bId.Text])
                        bubbleList[bId.Text].addGame(game);
                    Util.debug("bubbleGroup: adding " + bId.Text + " to game " + game, this);
                    bubblesPerGame[game].push(bId);
                }

                else if(bubbleGroup is EBName)
                {
                    var bName1 : EBName = bubbleGroup as EBName;
                    for (var i = 1; i <= bName1.MaxLevel; i++)
                    {
                        var bId2 = new BubbleId(bName1, i);

                        if(!Util.searchInArray(exceptionsBubblesPerGame[game], bId2))
                        {
                            Util.debug("bubbleGroup: adding " + (bName1.Text+"_"+i) + " to game " + game, this);
                            if(bubbleList[bName1.Text+"_"+i])
                                bubbleList[bName1.Text+"_"+i].addGame(game);

                            bubblesPerGame[game].push(bId2);
                        }
                    }
                }

                else if(bubbleGroup is EBStd)
                {
                    var standard : EBStd = bubbleGroup as EBStd;
                    var bubbleNames : Array = BubbleNamesPerStd[standard.Index];

                    Util.debug("bubblegroup is EBStd" + standard.Text + " index " + standard.Index) ;
                    Util.printArray(bubbleNames);

                    for each (var bName2 : EBName in bubbleNames)
                    {
                        Util.debug("pex1");
                        if((standard == EBStd.Numbers_Count && maxArrayCount[game] < EBName.countNumber(bName2)) ||
                                (standard == EBStd.Numbers_Subset && maxArraySubset[game] < EBName.countNumber(bName2)))
                        {
                            Util.debug("breaking for game " + game + "at " + bName2);
                        }

                        else
                        {
                            for (var j = 1; j <= bName2.MaxLevel; j++)
                            {
                                Util.debug("standard " + standard + " game " + game + "maxarray at game " + maxArrayIdentify[game] + " j " + j);

                                if(standard == EBStd.Numbers_Identify && (maxArrayIdentify[game] > 0 && maxArrayIdentify[game] < j))
                                {
                                    Util.debug("identify bigger than allowed level ");
                                }

                                else if(bubbleList[bName2.Text+"_"+j])
                                {
                                    Util.debug("BubbleGroup : adding "+ bName2 + " " + j + " to game " + game);
                                    bubblesPerGame[game].push(new BubbleId(bName2, j));

                                    if(bubbleList[bName2.Text+"_"+j])
                                        bubbleList[bName2.Text+"_"+j].addGame(game);
                                }
                            }
                        }
                    }
                }
            }

            Util.debug("games at " + game)
            Util.printArray(bubblesPerGame[game]);
        }
    }


    public function get BubblesPerGame() 	: Array	{	return bubblesPerGame;}
    public function get BubbleList() 		: Array { 	return bubbleList;}
    public function get BubbleNamesPerStd() : Array {   return DriverData.getInstance().BubbleNamesPerStd}


    public function get posetProgressionXML():XMLList {
        return _posetProgressionXML;
    }

    public function set posetProgressionXML(value:XMLList):void {
        _posetProgressionXML = value;
    }
}
}
