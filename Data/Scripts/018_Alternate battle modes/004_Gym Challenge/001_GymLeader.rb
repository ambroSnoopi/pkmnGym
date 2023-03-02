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
        #self.upgradeLicense #is done by the intro event
    end

    def win
        @rep < self.repNxtRank ? @rep += 20 : @rep += 1
        pbMessage(_INTL("Your Reputation has increased to {1}.", @rep))
    end

    def lose
        @rep -= 5
        @rep = 0 if @rep<0
        pbMessage(_INTL("Your Reputation has dropped to {1}.", @rep))
    end

    def upgradeLicense
        @rank += 1
        pbSet(103, @rank) #GameVariable "Rank"
        writeGymCup

        #provide rewards
        #TODO remaining rewards
        pbMessage(_INTL("Your Pokémon can now gain up to {1} EV.", EV_CAPS[@rank])) if @rank < 12
        case @rank
        when 1
            pbMessage(_INTL("To get you started, I will also provide your with an asortment of Berries from our region."))
            pbReceiveItem(:ORANBERRY)
            pbReceiveItem(:SITRUSBERRY)
            pbReceiveItem(:PERSIMBERRY)
            pbReceiveItem(:LUMBERRY)
            pbMessage(_INTL("In fact, let me deliver a comprehensive collection to your town."))
        when 2
            pbMessage(_INTL("Prof. Aid: Try teaching your Pokémon special moves, which they don't normally learn, to gain a strategic adventage."))
            pbReceiveItem(:TM100) #TODO: replace with signature move from gym type?
            pbReceiveItem(:HM01)
            pbReceiveItem(:HM02)
            pbReceiveItem(:HM03)
            pbReceiveItem(:HM04)
            pbReceiveItem(:HM05)
            pbReceiveItem(:HM06)
            pbMessage(_INTL("Caledon City has recieved a parcel from Prof. Oak."))
        when 3
            pbMessage(_INTL("Prof. Aid: Oak told me, he had a word with the move tutors that are free loading in his Condo here in Caledon. I wonder why he wanted me to tell you that..."))
        when 4
            pbMessage(_INTL("Prof. Aid: There are powerfull items, which can drastically improve the usability of a Pokémon. You should start experimenting with it."))
            pbReceiveItem(:CHOICEBAND)
            #pbMessage(_INTL("Caledon City has recieved a parcel from Prof. Oak."))
            #TODO: add ShopKeeper for battle items
        when 5
            pbMessage(_INTL("Prof. Aid: Did you know that certain Pokémon can only evolve by interacting with a specific item? Check this one out!"))
            pbReceiveItem(:MOONSTONE)
            #pbMessage(_INTL("Caledon City has recieved a parcel from Prof. Oak."))
            #TODO: add ShopKeeper
        when 6
            pbMessage(_INTL("Prof. Aid: Did you know that it is possible to alter a Pokémon's Nature by using specific Item on them? This is most intriguing..."))
            #TODO: add MINT items to the game...
            #pbMessage(_INTL("Caledon City has recieved a parcel from Prof. Oak."))
        when 7
            pbMessage(_INTL("Prof. Aid: Did you know that it is also possible to alter a Pokémon's Ability by using specific Item on them? This is most intriguing..."))
            #TODO: add CAPSULE items to the game...
            #pbMessage(_INTL("Caledon City has recieved a parcel from Prof. Oak."))
        when 8
            pbMessage(_INTL("Prof. Aid: Every Pokémon is born with Individual Values, but by using specific items you can maximize it's stats!"))
            #TODO: add BOTTLE CAPS items to the game...
            #pbMessage(_INTL("Caledon City has recieved a parcel from Prof. Oak."))
        else 
            pbMessage(_INTL("Prof. Aid: Congratulation! You have become the strongest Gym Leader of this Nation. As such, you have been nominated to become part of the Elite Four! What an honor!"))
            pbMessage(_INTL("Unfortunately, this is how far this demo goes. In a future version of the game, you will be able to become part of the Elite Four - and maybe even the Champ!"))
            pbMessage(_INTL("If you have enjoyed the game so far, why don't you contribute your battle logs on GitHub.com? The repository by searching for: ambroSnoopi/pkmnGym"))
            pbMessage(_INTL("Thank you!"))
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

#===============================================================================
# based on pbGenerateBattleTrainer from 003_Challenge_ChooseFoes.rb
#===============================================================================
def gcGenerateBattleTrainer(idxTrainer, rules)
    bttrainers = pbGetBTTrainers(pbBattleChallenge.currentChallenge)
    btpokemon = pbGetBTPokemon(pbBattleChallenge.currentChallenge)
    prng = Random.new
    # Create the trainer
    trainerdata = bttrainers[idxTrainer]
    echoln "Creating NPC Trainer with id " + idxTrainer.to_s + " ..."
   # echoln "...from " + bttrainers.to_s
    opponent = NPCTrainer.new(
      pbGetMessageFromHash(MessageTypes::TrainerNames, trainerdata[1]),
      trainerdata[0]
    )
    # Determine how many IVs the trainer's Pokémon will have
    indvalues = 31
    indvalues = 21 if idxTrainer < 220
    indvalues = 18 if idxTrainer < 200
    indvalues = 15 if idxTrainer < 180
    indvalues = 12 if idxTrainer < 160
    indvalues = 9 if idxTrainer < 140
    indvalues = 6 if idxTrainer < 120
    indvalues = 3 if idxTrainer < 100
    # Get the indices within bypokemon of the Pokémon the trainer may have
    pokemonnumbers = trainerdata[5]
    # The number of possible Pokémon is <= the required number; make them
    # all Pokémon and use them
    if pokemonnumbers.length <= rules.ruleset.suggestedNumber
      pokemonnumbers.each do |n|
        rndpoke = btpokemon[n]
        level = prng.rand($gcGymLeader.starterLevel..$gcGymLeader.levelCap)
        pkmn = rndpoke.createPokemon(level, indvalues, opponent)
        opponent.party.push(pkmn)
      end
      return opponent
    end
    # There are more possible Pokémon than there are spaces available in the
    # trainer's party; randomly choose Pokémon
    echoln "Choosing " + rules.ruleset.suggestedNumber.to_s + " Pokemon..." 
    loop do
      echoln "Reseting Party..."
      opponent.party.clear
      while opponent.party.length < rules.ruleset.suggestedNumber
        rnd = pokemonnumbers[rand(pokemonnumbers.length)]
        rndpoke = btpokemon[rnd]
        level = prng.rand($gcGymLeader.starterLevel..$gcGymLeader.levelCap)
        pkmn = rndpoke.createPokemon(level, indvalues, opponent)
        opponent.party.push(pkmn)
      end
      break if rules.ruleset.isValid?(opponent.party)
    end
    echoln "Finished creating Opponent."
    return opponent
  end