#===============================================================================
# GymChallanger class for Trainer as opponents for GymLeader Challange
#
# This is a Singleton Class. The instance can be accessed globally using:
#   $gcGymChallanger
#===============================================================================

class GymChallanger < Trainer

    def initialize
        pbBattleChallenge.set(
            "gcR"+$gcGymLeader.rank.to_s, #id
            1,              #numrounds
            gcGymChallengeRules #rules
        )
        pbBattleChallenge.start
    end

end


