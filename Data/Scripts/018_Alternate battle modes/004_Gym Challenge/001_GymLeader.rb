#===============================================================================
# GymLeader class for the player
# Could also be considered a GymLicense class at this point...
# This is a Singleton Class. The instance can be accessed globally using:
#   $gcGymLeader
#===============================================================================
class GymLeader #< Player
    attr_reader     :currentType    #Type.id
    attr_reader     :type           #for convinience
    attr_accessor   :rep            #int Reputation value
    attr_accessor   :rank           #int 1 to 14
    attr_reader     :LEGENDARIES_UNLOCK_RANK
    #TODO: decide wether rep & rank should be tied to a license/type

    #RANK       0   1   2   3   4   5   6   7   8   9   10  11  12  13  14
    LVL_CAPS = [5,  10, 15, 20, 25, 30, 35, 40, 45, 50, 60, 70, 80, 90, 100] #max level for each rank, index 0 required for starter level
    PKMN_CAPS= [nil,2,  2,  3,  3,  4,  4,  5,  5,  6,  6,  6,  6,  6,  6] #max pkm for each rank, skipping index 0
    EV_CAPS  = [nil,50, 100,150,200,250,300,350,400,450,500,510,510,510,510] #max EV per pkm for each rank, skipping index 0
    LEGENDARIES_UNLOCK_RANK = 14
    REP_PER_RANK = 100

    def initialize(type)
        @currentType = type
        @type = @currentType
        @rep = 100
        @rank = 0
        gcFillBox(type, self.starterLevel)
        #@LEGENDARIES_UNLOCK_RANK = LEGENDARIES_UNLOCK_RANK
        $gcGymLeader = self #singleton
        #Settings::MAXIMUM_LEVEL = self.levelCap
        #Settings::MAX_PARTY_SIZE = self.pkmnCap
        self.upgradeLicense
    end

    def win
        @rep += 10
    end

    def lose
        @rep -= 5
        @rep = 0 if @rep<0
    end

    def upgradeLicense
        @rank += 1
        writeGymCup

        #provide rewards
        #TODO remaining rewards
        pbMessage(_INTL("\bYour Pokémon can now gain up to {1} EV.", EV_CAPS[@rank])) if @rank < 12
        case @rank
        when 1
            pbMessage(_INTL("\bTo get you started, I will also provide your with an asortment of Berries from our region."))
            pbReceiveItem(:ORANBERRY)
            pbReceiveItem(:SITRUSBERRY)
            pbReceiveItem(:PERSIMBERRY)
            pbReceiveItem(:LUMBERRY)
            pbMessage(_INTL("\bIn fact, let me deliver a comprehensive collection to your town."))
        when 2
            pbReceiveItem(:TM100) #TODO: replace with signature move from gym type?
            pbReceiveItem(:HM01)
            pbReceiveItem(:HM02)
            pbReceiveItem(:HM03)
            pbReceiveItem(:HM04)
            pbReceiveItem(:HM05)
            pbReceiveItem(:HM06)
            pbMessage(_INTL("Caledon City has recieved a parcel from Prof. Oak."))
            #TODO: reduce TM prices by 50% (buy=sell, i.e. basically for free - or can't TMs be sold anyway?)
        when 3
            pbMessage(_INTL("\bProf. Aid: Oak told me, he had a word with the move tutors that are free loading in his Condo here in Caledon. I wonder why he wanted me to tell you that..."))
        end

    end

    def tutorUnlocked?
        return @rank >= 3
    end

    def tmUnlocked?
        return @rank >= 2
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

    def badge
        badge_s    = [nil, "1st","2nd","3rd"] #Badge to be handed over to the Challanger...
        return @rank<4 ? badge_s[@rank] : "{@rank}th"
    end

    #===============================================================================
    # defines the rules which shall be applied to gym challangers
    # TODO: vary rules depending on gym rank?
    #===============================================================================
    def gcGymChallengeRules
        ret = PokemonChallengeRules.new
        ret.setLevelAdjustment(TotalLevelAdjustment.new(self.starterLevel, self.levelCap, ((self.starterLevel + self.levelCap) / 2) * self.pkmnCap))
        ret.addPokemonRule(MaximumLevelRestriction.new(self.levelCap))
        #ret.addPokemonRule(MaximumLevelRestriction.new(1)) # for testing
        ret.addTeamRule(SpeciesClause.new)
        ret.addPokemonRule(BannedSpeciesRestriction.new(:UNOWN)) if @rank+1 >= LEGENDARIES_UNLOCK_RANK
        ret.addTeamRule(ItemClause.new)
        ret.setNumber(self.pkmnCap)
        return ret
    end
    
    #===============================================================================
    # create Trainers & Pokemon to match the current gym rank
    # using "gcR"+@rank as id/tag, e.g. "gcR1"
    #===============================================================================
    def writeGymCup
        pbWriteCup("gcR"+@rank.to_s, self.gcGymChallengeRules)
    end

end