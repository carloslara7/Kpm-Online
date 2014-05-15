package com.kpm.games.walkthewalk {

	import com.kpm.common.Util
  public class GameCharacterFactory {

    static public function createGameCharacters (pGL: GameLevel): Array {

      var vObjQuality: Array = new Array();
      var vObjPosition: Number;
      var vGameCharacters: Array = new Array();

      var i: Number;
      var j: Number;
      var k: Number;
      var l: Number;
	  
	  
	  
      for(i = 0; i < pGL.NumRounds; i++){

        vGameCharacters[i] = new Array();
		
		Util.debug(pGL.TotalObjects[i] + " pex");
		
        for(j = 0; j < pGL.NumGoalObjects[i]; j++){

          vObjPosition = pGL.GoalObjPos[i][j];
          vGameCharacters[i][vObjPosition] = new GameCharacter(true);

          for(k = 0; k < CharacterQuality.NUM_QUALITIES; k++){

            if(pGL.Goals[i][k].length > 0 &&
               pGL.Goals[i][k].length <= CharacterQuality.QUALITY_RANGE[k]){

              l = Math.floor(Math.random() * pGL.Goals[i][k].length);
              vObjQuality[k] = pGL.Goals[i][k][l];
            }
            else {
              vObjQuality[k] = CharacterQuality.getRandomQuality(k);
            }

            if(pGL.Invariants[i][k] >= 0)
              vGameCharacters[i][vObjPosition].setCharacterQuality(k, pGL.Invariants[i][k]);
            else
              vGameCharacters[i][vObjPosition].setCharacterQuality(k, vObjQuality[k]);
          }
        }

        var vNumGoalQualities: Number = 0;
        for(j = 0; j < pGL.Goals[i].length; j++)
          if(pGL.Goals[i][j].length > 0) vNumGoalQualities++;

        if(vNumGoalQualities == 0) vNumGoalQualities++;

        var vNextNonGoal: Number = 0;
        var vNextGoal: Number = 0;

        for(j = 0; j < pGL.TotalObjects[i] - pGL.NumGoalObjects[i]; j++){

          var vGoalsMet: Number;
		  trace("j " + j );
          while(true){

            vGoalsMet = 0;
            for(k = 0; k < CharacterQuality.NUM_QUALITIES; k++){

              if(pGL.Invariants[i][k] >= 0)
                vObjQuality[k] = pGL.Invariants[i][k];
              else
                vObjQuality[k] = CharacterQuality.getRandomQuality(k);

              for(l = 0; l < pGL.Goals[i][k].length; l++)
                if(vObjQuality[k] == pGL.Goals[i][k][l]){ 
                	vGoalsMet++; break; 
                }

            }
            if(vGoalsMet < vNumGoalQualities) break;
          }
		  
		  
          for(; vNextNonGoal == pGL.GoalObjPos[i][vNextGoal] && vNextGoal < pGL.NumGoalObjects[i];
                vNextNonGoal++, vNextGoal++)
                { }

          vGameCharacters[i][vNextNonGoal] = new GameCharacter(false);

          for(k = 0; k < CharacterQuality.NUM_QUALITIES; k++){

            if(pGL.Invariants[i][k] >= 0)
              vGameCharacters[i][vNextNonGoal].setCharacterQuality(k, pGL.Invariants[i][k]);
            else
              vGameCharacters[i][vNextNonGoal].setCharacterQuality(k, vObjQuality[k]);
          }

          vNextNonGoal++;
        }
      } // End of Rounds Loop

		
      return vGameCharacters;

    } // End of createGameCharacters

  }
}