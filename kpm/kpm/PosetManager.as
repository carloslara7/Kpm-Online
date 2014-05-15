/**
 * Created with IntelliJ IDEA.
 * User: carloslara
 * Date: 12/17/13
 * Time: 12:28 AM
 * To change this template use File | Settings | File Templates.
 */
package com.kpm.kpm
{

import com.de.polygonal.ds.DListNode;
import com.de.polygonal.ds.Graph;
import com.de.polygonal.ds.GraphArc;
import com.de.polygonal.ds.GraphNode;
import com.de.polygonal.ds.TreeNode;
import com.kpm.common.EGame;
import com.kpm.common.Util;

import flash.events.Event;
import flash.events.EventDispatcher;

import flash.events.IOErrorEvent;

import flash.net.URLLoader;
import flash.net.URLRequest;

public class PosetManager extends EventDispatcher
{

    //Poset Manager is a singleton
    private static var instance : PosetManager
    private static var currentPoset, previousPoset : String

    var outcomesInarow : Array = [0,0,0];

    //2d-list of bubbleNames indexed by stdIndex
    private var bubbleNamesPerStd 	: Array = new Array(DriverData.NUM_STANDARDS);

    //List of bubbles indexed by Game ("G1", "G2", "G3", "G4");
    private var bubblesPerGame 		: Array = new Array();

    //List of bubbles indexed by Game ("G1", "G2", "G3", "G4");
    public var gamEBNames 			: Array = new Array();

    public static var currentKidXML		: XML;


    //public static const POSET_PROGRESSION_FILENAME : String = "PosetProgression.xml";
    public static const POSET_PROGRESSION_FILENAME : String = "PosetProgressionMinimized.xml";

    public static const ENABLE_POSET_NAVIGATION : Boolean = true;

    public static const FULL_TO_FWD_PASS_NEEDED = 3;
    public static const FWD_TO_FULL_ENJOY_NEEDED = 2;

    var posetList : Array;

    public static function getInstance(): PosetManager {

        if (instance == null) {

            Util.debug("Instanciating PosetManager ");
            instance = new PosetManager();
            currentPoset = Poset.FULL;
        }

        return instance;
    }

    public function PosetManager()
    {
        //if(PosetManager.ENABLE_POSET_NAVIGATION)
        //   currentPoset = PosetManager.POSET_PROGRESSION_MINIMIZED_FILENAME;
        //else
        //    currentPoset = PosetManager.POSET_PROGRESSION_FILENAME;

        posetList = new Array();
        posetList[Poset.PRIMARY] = new Poset(PosetManager.POSET_PROGRESSION_FILENAME, Poset.PRIMARY);
        posetList[Poset.FULL] = new Poset(PosetManager.POSET_PROGRESSION_FILENAME, Poset.FULL);



    }

    public function get BubbleNamesPerStd() : Array { 	return bubbleNamesPerStd; }

    function populatePosetProgression()
    {
        Util.debug("////////////////////////");
        Util.debug("PosetManager.populatePosetProgression");
        var myLoader: URLLoader = new URLLoader();
        myLoader.addEventListener(IOErrorEvent.IO_ERROR, DriverData.getInstance().reportError, false, 0 , true);

        Util.debug("loading bubble progression " + currentPoset);
        myLoader.load(new URLRequest(DriverData.FOLDER_DATA + PosetManager.POSET_PROGRESSION_FILENAME));
        myLoader.addEventListener(Event.COMPLETE, populatePosetsFromXML, false, 0 , true);


    }

    //Populate all puzzles from the file specified at PosetManager.POSET_PROGRESSION_FILENAME
    //This file contains both Full Poset and Fwd Poset for now

    function populatePosetsFromXML(e : Event)
    {
        Util.debug("PosetManager.populatePosetsFromXML");

        var posetProgressionXML : XML = new XML(e.target.data);



        posetList[Poset.FULL].posetProgressionXML = posetProgressionXML.children().(@id=="FULL");
        Util.debug(posetList[Poset.FULL].posetProgressionXML.toXMLString());

        posetList[Poset.FULL].populatePosetFromXML(Poset.FULL);

        //Util.debug(posetList[Poset.FULL].posetProgressionXML.toXMLString());

        //posetList[Poset.FWD].posetProgressionXML = new XML(e.target.data);
        //posetList[Poset.FWD].posetProgressionXML = XML(posetProgressionXML.children().(@id=="FWD"));
        //posetList[Poset.FWD].populatePosetFromXML(Poset.FWD);
        //Util.debug(posetList[Poset.FWD].posetProgressionXML.toXMLString());
    }


    public function updateOutcomesInarow(index : int)
    {
        outcomesInarow[index]++;
        Util.debug("PosetManager.updateOutcomesInarow " + index + " " + outcomesInarow[index]);

        if(currentPoset == Poset.FWD)
        {
            Util.debug("current Poset is FWD");
            if(outcomesInarow[KpmBubble.ENJOYED] > PosetManager.FWD_TO_FULL_ENJOY_NEEDED || index == KpmBubble.FAILED)
                switchToPoset(Poset.FULL);
        }

        else if (currentPoset == Poset.FULL)
        {
            Util.debug("current Poset is FULL");
            if(outcomesInarow[KpmBubble.PASSED] > PosetManager.FULL_TO_FWD_PASS_NEEDED)
            {
                switchToPoset(Poset.FWD);
            }
        }
    }

    public function switchToPoset(posetId : String)
    {
        currentPoset = posetId;
        DriverData.getInstance().computeSuccessors1fromPredecessors();
        Util.debug("SWITCHING TO " + posetId + " POSET ")
        // load all bubbles and successsors from current poset!!!
    }

    public static function get CurrentPoset() : String
         { return currentPoset }


    // BEGIN PROCESSING GRAPH
    // POSET FUNCTION
//
//    function initLogAndPredecessorGraphAndDAG()
//    {
//        Util.debug("PosetManager.initLogAndPredecessorGraphAndDag")
//        Util.debug("finish initialize kid");
//
//        DriverData.getInstance().initLog();
//        posetList[Poset.PRIMARY].computeDagAndPoset();
//
//
//    }




}
}
