#===============================================================================
# GymLeader class for the player
# Could also be considered a GymLicense class at this point...
#===============================================================================
class GymLeader
    attr_reader     :currentType    #Type.id
    attr_accessor   :rep            #int Reputation value
    attr_accessor   :rank           #int 1 to 14
    #TODO: decide wether rep & rank should be tied to a license/type

    #RANK       0   1   2   3   4   5   6   7   8   9   10  11  12  13  14
    LVL_CAPS = [5,  10, 15, 20, 25, 30, 35, 40, 45, 50, 60, 70, 80, 90, 100] #max level for each rank, index 0 required for starter level
    PKMN_CAPS= [nil,2,  2,  3,  3,  4,  4,  5,  5,  6,  6,  6,  6,  6,  6] #max pkm for each rank, skipping index 0
    EV_CAPS  = [nil,50, 100,150,200,250,300,350,400,450,500,510,510,510,510] #max EV per pkm for each rank, skipping index 0
    LEGENDARIES_UNLOCK_RANK = 14
    REP_PER_RANK = 100

    def initialize(type)
        @currentType = type
        @rep = 100
        @rank = 1
        gcFillBox(type, self.starterLevel)
        $gcGymLeader = self
        #Settings::MAXIMUM_LEVEL = self.levelCap
        #Settings::MAX_PARTY_SIZE = self.pkmnCap
    end

    def win
        @rep += 10
    end

    def lose
        @rep -= 5
        @rep = 0 if @rep<0
    end

    def switchType(type)
        @currentType = type
        $player.party = []
        gcUpdateBox(type, self.starterLevel, @rank >= LEGENDARIES_UNLOCK_RANK)
    end

    def levelCap
        return LVL_CAPS[@rank]
    end

    def starterLevel
        return LVL_CAPS[@rank-1]
    end

    #TODO: various scripts still use Settings::MAX_PARTY_SIZE which may cause bugs down the line
    def pkmnCap
        return PKMN_CAPS[@rank]
    end

    def evCap
        return EV_CAPS[@rank]
    end

    def repNxtRank
        return REP_PER_RANK * (@rank+1)
    end

end