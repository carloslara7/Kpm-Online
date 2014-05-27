/**
 * Created with IntelliJ IDEA.
 * User: carloslara
 * Date: 5/26/14
 * Time: 8:45 PM
 * To change this template use File | Settings | File Templates.
 */
package kpm.kpm {
import com.de.polygonal.ds.TreeNode;
import com.kpm.common.ELanguage;
import com.kpm.kpm.BubbleId;
import com.kpm.kpm.EBStatus;
import com.kpm.kpm.KpmBubble;

public class Kid2 {

    var id   	       	: String         //randomly generated 6 digit number when kid is created

    var firstName      	: String;
    var lastName  		: String;
    var age            	: uint;
    var primaryLanguage : ELanguage;
    var gameLanguage	: ELanguage;
    var firstTime 		: Boolean ;

    //list of bubbles completed successfully, or unsuccessfully
    var bubbleStatus 	: Array;
    var achievements 	: Array;
    var bubbleActive 	: Array;
    var bubbleAttempts	: Array;
    //var bubblesWeight : Array;

    var predecessorsMarked : Array;
    var kidXML : XML;
    var reports : Array;
    public static const PROFILE_VERSION : uint = 1;

    public function Kid2(pId : String, pFirstName : String, pLastName : String, pAge : uint,
                        pPrimaryLanguage : ELanguage = null, pGameLanguage : ELanguage = null,
                        pFirstTime : Boolean = false )
    {

    }

    //MakeKidFromXML
    public static function makeKidFromXML(pXMLKid : XML, pCheckProfileVersion : Boolean = true, pInitialStatus : Boolean = false) : Kid
    {

    }

    static function checkKidProfileVersion(pNewKid : Kid2)
    {

    }

    public static function findBubble(pKid :Kid2, pBId : String, pStatus : EBStatus = null) : Boolean
    {

    }

    //Poset Function
    // Check if the children of a particular node (or bubble) are complete
    public function areChildComplete(pNode : TreeNode) : Boolean
    {

    }

    //Poset Function
    //Helps with traversal of nodes by visiting all children of the node and then coming back to the node
    public static function postOrder(node:TreeNode, process:Function, pParentBubble : KpmBubble = null):void
    {

    }


    //Poset Function
    // Computes if a bubble is active or not
    public function computeActive(pBubbleId : BubbleId) : Boolean
    {

    }

    //Poset Function
    // Change so that it accepts multiple posets !
    // Get all successors bubbles from the paramter bubble's successorList
    public function getActiveSuccessors(pBubbleId : BubbleId) : Array
    {

    }

    //This function changes the EBSTatus of a list of bubbles, as well as their status (
    public function changeBubbleOutcome( pBIdArray : Array, pLastOutcome : EBStatus = null, pStatus : Boolean = false, pForceWriteXML : Boolean = false, pWriteToProfile : Boolean = true)
    {

    }

    public function setStatus(pBubbleId : BubbleId, pStatus : Boolean)
    {


    }


    public function setOutcome(pBubbleId : BubbleId, pLastOutcome : EBStatus, pWriteToProfile : Boolean = true)
    {

    }

    //Writes the XML object that gets updated to the kid's profile file
    public function writeBStatus()
    {

    }

    public function bubblePassed(index : String, pNoRedo : Boolean = false)
    {

    }



    }
}
