package com.kpm.games.walkthewalk {
 
  import com.kpm.common.Util;
  public class CharacterQuality {

    static public const SPECIES: Number = 0;
    static public const SIZE: Number = 1;
    static public const COLOR: Number = 2;
    static public const MULTIPLICITY: Number = 3;

    static public const PLURAL: Number = 0;
    static public const SINGULAR: Number = 1;

    static public var SPECIES_NAMES: Array = new Array( "animal", "butterfly", "cat", "dog", "horse",
                                                        "elephant", "chicken", "fish", "tiger", "squirrel" );

    static public var SPECIES_NAMES_PLURAL: Array = new Array( "animals", "butterflies", "cats", "dogs", "horses",
                                                               "elephants", "chickens", "fish", "tigers", "squirrels" );

    static public var SIZE_NAMES: Array = new Array( "size", "small", "big");

    static public var COLOR_NAMES: Array = new Array( "color", "orange", "green", "yellow", "red", "blue" );

    static public var NUMBER_NAMES: Array = new Array( "number", "one", "two", "three", "four", "five",
                                                               "six", "seven", "eight", "nine", "ten" );

    static public var QUALITY_RANGE: Array = new Array( SPECIES_NAMES.length - 1, SIZE_NAMES.length - 1,
						        						COLOR_NAMES.length - 1, NUMBER_NAMES.length - 1);

    static public var QUALITY_NAMES: Array = new Array();	
    QUALITY_NAMES[PLURAL] = new Array( SPECIES_NAMES_PLURAL, SIZE_NAMES, COLOR_NAMES, NUMBER_NAMES );
    QUALITY_NAMES[SINGULAR] = new Array( SPECIES_NAMES, SIZE_NAMES, COLOR_NAMES, NUMBER_NAMES );

    static public const NUM_QUALITIES: Number = QUALITY_RANGE.length;

    static public var SIZE_VALUES: Array = new Array( 1, 0.90, 1.5);
    static public var COLOR_VALUES: Array = new Array( {ra: 1, ga: 1, ba: 1, aa: 1, rb: 0, gb: 0, bb: 0, ab: 0},
                                                       {ra: 1, ga: 0.5, ba: 0, aa: 1, rb: 100, gb: 50, bb: 0, ab: 0},
                                                       {ra: 0, ga: 1, ba: 0, aa: 1, rb: 0, gb: 50, bb: 0, ab: 0},
                                                       {ra: 1, ga: 1, ba: 0, aa: 1, rb: 50, gb: 50, bb: 0, ab: 0},
                                                       {ra: 1, ga: 0, ba: 0, aa: 1, rb: 50, gb: 0, bb: 0, ab: 0},
                                                       {ra: 0, ga: 0, ba: 1, aa: 1, rb: 0, gb: 0, bb: 50, ab: 0} );

    static public var SPEED_VALUES: Array = new Array( 1, 14, 18, 16, 16, 11, 11, 14, 16, 18 );

    static public function getRandomQuality(i: Number): Number {
      return 1 + Math.floor(Math.random() * QUALITY_RANGE[i]);
    }

    static public function getQualityNames(pQualityId: Number, pQuals: Array, pNumber: Number, pSeparator: String): String {

      var vQualityNames: String = "";
	  Util.debug("quals length " + pQuals.length);
	  Util.printArray(pQuals);
	  
      if(pQuals.length > 0){
        for(var i: Number = 0; i < pQuals.length; i++){
          trace("number " + pNumber + " pQualityId " + pQualityId + " pQuals[i] " + pQuals[i]);
          if(i > 0) vQualityNames += pSeparator + "or" + pSeparator;
          vQualityNames += QUALITY_NAMES[pNumber][pQualityId][pQuals[i]];
          if(i < pQuals.length - 1) vQualityNames += " ";
        }

        return vQualityNames;
      }

      return QUALITY_NAMES[pNumber][pQualityId][0];
    }
  }
}