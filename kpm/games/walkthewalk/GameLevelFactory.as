package com.kpm.games.walkthewalk {

  public class GameLevelFactory {

    public const DEFAULT_NUMROUNDS: Number = 7;

    public function GameLevelFactory() {

    }

    public function createUniformGameLevel(pGoals: Array, pInvariantQuals: Array,
                                           pNumRounds: Number, pMaxGoals: Number,
                                           pTotalCharactersType: Number): GameLevel {

      var vGoals: Array = new Array();
      var vInvariants: Array = new Array();
	  
      for(var i: Number = 0; i < pNumRounds; i++){
        vGoals[i] = new Array();
        vInvariants[i] = new Array();
        for(var j: Number = 0 ; j < CharacterQuality.NUM_QUALITIES; j++){

          if(pGoals[j] > 0) // Must also ensure that the # of goals is within feasible range
            vGoals[i][j] = Math.floor(Math.random() * (pGoals[j] + 1));
          else
            vGoals[i][j] = Math.abs(pGoals[j]);

          vInvariants[i][j] = pInvariantQuals[j];
        }
      }

      return new GameLevel(vGoals, vInvariants, pNumRounds, pMaxGoals, pTotalCharactersType);
    }

    public function createUniformGameLevelBySpec(pGLS: UniformGameLevelSpec): GameLevel {

      return createUniformGameLevel(new Array(pGLS.SpeciesChoice, pGLS.SizeChoice,
                                              pGLS.ColorChoice, pGLS.NumberChoice),
                                    new Array(pGLS.SpeciesInv, pGLS.SizeInv, pGLS.ColorInv, pGLS.NumberInv),
                                    pGLS.NumRounds, pGLS.NumGoalObjects, pGLS.NumTotalObjects);
    }

    public function createUniformGameLevelSpec(pActivity: String, pLevel: Number,
                                               pNumRounds: Number = DEFAULT_NUMROUNDS): UniformGameLevelSpec {

      return new UniformGameLevelSpec(pActivity, pLevel, pNumRounds);
    }

  }

}