/**
 * Created with IntelliJ IDEA.
 * User: carloslara
 * Date: 5/17/14
 * Time: 9:01 PM
 * To change this template use File | Settings | File Templates.
 */
package com.kpm.games.game5 {
import com.kpm.common.Util;

public class EG5PieceType {
    public var Text :String;
    {Util.initEnumConstants(EG5PieceType);} // static ctor

    public static const WHOLE		:EG5PieceType = new EG5PieceType();
    public static const PIECE		:EG5PieceType = new EG5PieceType();


    public function toString() : String
    {
        return "[State : " + Text + " ]";
    }
}
}


