#TODO change all/most Data Class attributes to attr_reader
#TODO reconsider dropping the individual attributes alltogether and just keep the hmap...

#Abstract Data Class for MLLoger
class ML_Log 
    attr_reader :hmap               # Hashmap to collect each variable that needs to be logged
    attr_accessor :dir              # Directory Path to where the Log shall be saved
    attr_accessor :fname            # Filename (Trunc without File-Ending/Type)

    ML_VERSION = 0.1

    #return a JSON String representation of the hmap
    def prep_json(h = self.hmap)
        case h
        when Hash
          h.transform_keys!(&:to_s)
          h.transform_values! { |v| prep_json(v) }
        when Array
          h.map! { |v| prep_json(v) }
        when Integer
          h
        when nil#, "nil"
          ""
        else
          h.to_s
        end
    end

    def as_json
        h = self.prep_json
        #echoln "Hashmap of MLLog before prettyfication:"
        #echoln h
        str = h.to_s
        str.gsub!("=>", ": ")
        str.gsub!('#','') #bc python cant handle this :)
        #handle nested json & prettify:
        str.gsub!('"{', "{\n   ")
        str.gsub!('}"', "}\n")
        str.gsub!('"[', "[\n   ")
        str.gsub!(']"', "]\n")
        str.gsub!('\"', '"')
        str.gsub!(",", ",\n")
        str.gsub!("\\n", "  ") #idk why these got printed but lets use it to our advantage :)
        return str
    end

    def to_s
        return self.as_json
    end

    #writes a JSON representation of the Objet to a File
    #optionally update dir & fname
    def to_json(dir = @dir, fname = self.fname)
        @dir = dir
        @fname = fname
        Dir.mkdir(dir) if !File.directory?(dir)
        #File.open("#{dir}/#{fname}.json", "w") {|f| f.write(self.as_json) }
        File.write("#{dir}/#{fname}.json", self.as_json)
    end
end

#Data Class of Battle for general static Metadate
#Given a Battle Class it will extract & store all relevant information, similar to TurnLog
class BattleLog < ML_Log
    attr_reader   :id               # identifying a battle
    attr_accessor :sid              # identifying a snapshot
    attr_accessor :sLabel           # label/name for the snapshot, also used for the filename
    attr_reader   :player           # Player trainer (or array of trainers)
    attr_reader   :opponent         # Opponent trainer (or array of trainers)  
    attr_accessor :decision
    attr_reader   :gameVersion
    # Results of battle:
    #    0 - Undecided or aborted
    #    1 - Player won
    #    2 - Player lost
    #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
    #    4 - Wild Pokémon was caught
    #    5 - Draw

    def initialize(id, battle, dir = @dir, sid = 0, sLabel = "default")
        @id         = id
        @sid        = sid
        @sLabel     = sLabel
        @player     = TrainerLog.new(battle.player[0])
        @opponent   = TrainerLog.new(battle.opponent[0]) #no double-battles support
        @decision   = 0
        @rep        = $gcGymLeader.rep

        @gameVersion = Settings::GAME_VERSION

        @dir   = dir
    end

    def fname
        return "battle-#{@id}-#{@sid}-#{@sLabel}"
    end
    
    def hmap #dynamic to get updates on @decision
        return {
            :id        => @id, 
            :sid       => @sid,
            :sLabel    => @sLabel,
            :player    => @player, 
            :opponent  => @opponent,
            :decision  => @decision,
            :gameVersion => @gameVersion,
            :rep        => @rep,
            :mlVersion => ML_VERSION
        }
    end
end

#Wrapper Data Class of Trainer
#Given a Trainer Class it will extract & store all relevant information
class TrainerLog < ML_Log 
    def initialize(trainer, dir = @dir, fname = @fname)
        @hmap = {
            :id             => trainer.id, 
            :trainer_type   => trainer.trainer_type, 
            :name           => trainer.name
        }
    end
end

#Data Class of Battle for dynamic Round related data
#Given a Battle Class it will extract & store all relevant information, similar to BattleLog
class TurnLog < ML_Log
    #from Battle class
    attr_reader   :turnCount
    #attr_reader   :field            # Effects common to the whole of a battle
    #attr_reader   :sides            # Effects common to each side of a battle
    #attr_reader   :positions        # Effects that apply to a battler position
    attr_reader   :battler0         # Currently active Pokémon
    attr_reader   :battler1         # Currently active Pokémon
    attr_accessor :items            # Items held by opponents
    attr_accessor :ally_items       # Items held by allies
    attr_accessor :choices          # Choices made by each Pokémon this round
    #attr_reader   :usedInBattle     # Whether each Pokémon was used in battle (for Burmy)
    attr_accessor :lastMoveUsed     # Last move used
    attr_accessor :lastMoveUser     # Last move user
    #TODO: TBC with additional attributes

    def initialize(battleID, turnID, battle, dir = @dir, sid = 0, sLabel = "default")
        @choices = [] #making a deep copy
        for c in battle.choices
            choice = c.clone
            case choice[0] #Possible Cases: :None, :UseMove, :SwitchOut, :UseItem, :Call, :Run, :Shift 
            when :UseMove
                choice[2] = choice[2].id.to_s
            end
            choice[0] = choice[0].to_s
            @choices.append(choice)
        end

        @party0 = []
        battle.player[0].party.each { |p| @party0.push(PokemonLog.new(p))}
        @party1 = []
        battle.opponent[0].party.each { |p| @party1.push(PokemonLog.new(p))}

        @dir   = dir
        @fname = "b-#{battleID}-t-#{turnID}-#{sid}-#{sLabel}"
        @hmap = {
            :battleID   => battleID,
            :turnID     => turnID,
            :sid        => sid,
            :sLabel     => sLabel,
            :turnCount  => battle.turnCount,
            #:field     => @field,
            #:sides     => @sides,
            #:positions      => @positions,
            :battler0      => BattlerLog.new(battleID, turnID, battle.battlers[0]), #Player Pokemon
            :battler1      => BattlerLog.new(battleID, turnID, battle.battlers[1]), #Opponents Pokemon
            :items      => battle.items,
            :ally_items      => battle.ally_items,
            :choices      => @choices,
            #:usedInBattle      => battle.usedInBattle
            :lastMoveUsed      => battle.lastMoveUsed,
            :lastMoveUser      => battle.lastMoveUser,
            :party0 => @party0, #Player Party
            :party1 => @party1  #Opponent Party
        }
    end
end

#Data Class of Battle::Battler
class BattlerLog < ML_Log
    attr_reader   :battleID
    attr_reader   :turnID
    attr_accessor :index
    #from Battle::Battler class
    #attr_reader   :pokemon
    attr_reader   :species
    attr_accessor :ability_id
    attr_accessor :item_id
    attr_accessor :moves
    attr_accessor :plainStats #attack, defense, spatk, spdef, speed
    attr_reader   :totalhp
    attr_reader   :hp
    attr_accessor :stages
    #attr_reader   :fainted    # Boolean to mark whether self has fainted properly

    # Things the battler has done in battle
    attr_accessor :turnCount
    attr_accessor :participants
    attr_accessor :lastAttacker
    attr_accessor :lastFoeAttacker
    attr_accessor :lastHPLost
    attr_accessor :lastHPLostFromFoe
    attr_accessor :lastMoveUsed
    attr_accessor :lastMoveUsedType
    attr_accessor :lastRegularMoveUsed
    #attr_accessor :lastRoundMoved
    attr_accessor :lastMoveFailed        # For Stomping Tantrum
    attr_accessor :lastRoundMoveFailed   # For Stomping Tantrum
    attr_accessor :movesUsed
    #attr_accessor :currentMove   # ID of multi-turn move currently being used
    #attr_accessor :statsDropped   # Used for Eject Pack
    #attr_accessor :tookDamageThisRound   # Boolean for whether self took damage this round
    #attr_accessor :tookPhysicalHit
    attr_accessor :statsRaisedThisRound   # Boolean for whether self's stat(s) raised this round
    attr_accessor :statsLoweredThisRound   # Boolean for whether self's stat(s) lowered this round
    attr_accessor :damageState
    # Properties from Pokémon
    attr_reader   :gender
    #TODO: TBC with additional attributes

    def initialize(battleID, turnID, battler, dir = @dir, fname = @fname)
        @moves = []
        battler.moves.each { |m| @moves.push(MoveLog.new(m.realMove))}

        @movesUsed = []
        battler.movesUsed.each { |m| @movesUsed.push(m.to_s)}
        #battler.movesUsed.each { |m| @movesUsed.push(MoveLog.new(m))}  #unfortunately, "m" here is just a Symbol

        @dir   = dir
        @fname = fname
        @hmap = {
            :battleID   => battleID,
            :turnID     => turnID,
            :index      => battler.index,

            :species    => battler.species,
            :level      => battler.level,
            :gender     => battler.gender,
            :ability_id => battler.ability_id,
            :item_id    => battler.item_id,
            :plainStats => battler.plainStats.transform_keys(&:to_s),
            :totalhp    => battler.totalhp,
            :hp         => battler.hp,
            :stages     => battler.stages.transform_keys(&:to_s) ,

            :moves      => @moves,
            :movesUsed  => @movesUsed, 

            :turnCount  => battler.turnCount,
            :participants          => battler.participants, #only relevant in doubles?
            :lastAttacker          => battler.lastAttacker, #only relevant in doubles?      
            :lastFoeAttacker       => battler.lastFoeAttacker,      
            :lastHPLost            => battler.lastHPLost,   #only relevant in doubles?   
            :lastHPLostFromFoe     => battler.lastHPLostFromFoe,    
            :lastMoveUsed          => battler.lastMoveUsed,         
            :lastMoveUsedType      => battler.lastMoveUsedType,     
            :lastRegularMoveUsed   => battler.lastRegularMoveUsed,             
            :statsRaisedThisRound  => battler.statsRaisedThisRound, 
            :statsLoweredThisRound => battler.statsLoweredThisRound,
            :damageState           => DamageStateLog.new(battler.damageState)        
        }
    end
end

#Simplified Data Class for Pokemon::Move
class MoveLog < ML_Log 
    def initialize(pkmnMove)
        @hmap = {
            #:realMove   => battleMove.realMove  ,
            :id         => pkmnMove.id        ,
            :name       => pkmnMove.name      ,
            :function   => pkmnMove.function_code  ,
            :baseDamage => pkmnMove.base_damage,
            :type       => pkmnMove.type      ,
            :category   => pkmnMove.category  ,
            :accuracy   => pkmnMove.accuracy  ,
            :pp         => pkmnMove.pp        ,
            :total_pp   => pkmnMove.total_pp  ,
            :effectChance => pkmnMove.effect_chance,
            :target     => pkmnMove.target    ,
            :priority   => pkmnMove.priority  ,
            :flags      => pkmnMove.flags
            #:calcType
            #:powerBoost
            #:snatched
        }
    end
end

#Simplified Data Class for Battle::DamageState
class DamageStateLog < ML_Log 
    def initialize(dmgState)
        @hmap = {
            :typeMod             => dmgState.typeMod           ,# Type effectiveness
            :unaffected          => dmgState.unaffected        ,
            :protected           => dmgState.protected         ,
            :magicCoat           => dmgState.magicCoat         ,
            :magicBounce         => dmgState.magicBounce       ,
            :totalHPLost         => dmgState.totalHPLost       ,# Like hpLost, but cumulative over all hits
            :fainted             => dmgState.fainted           ,# Whether battler was knocked out by the move
            :missed              => dmgState.missed            ,# Whether the move failed the accuracy check
            :affection_missed    => dmgState.affection_missed  ,
            :invulnerable        => dmgState.invulnerable      ,# If the move missed due to two turn move invulnerability
            :calcDamage          => dmgState.calcDamage        ,# Calculated damage
            :hpLost              => dmgState.hpLost            ,# HP lost by opponent, inc. HP lost by a substitute
            :critical            => dmgState.critical          ,# Critical hit flag
            :affection_critical  => dmgState.affection_critical,
            :substitute          => dmgState.substitute        ,# Whether a substitute took the damage
            :focusBand           => dmgState.focusBand         ,# Focus Band used
            :focusSash           => dmgState.focusSash         ,# Focus Sash used
            :sturdy              => dmgState.sturdy            ,# Sturdy ability used
            :disguise            => dmgState.disguise          ,# Disguise ability used
            :iceFace             => dmgState.iceFace           ,# Ice Face ability used
            :endured             => dmgState.endured           ,# Damage was endured
            :affection_endured   => dmgState.affection_endured ,
            :berryWeakened       => dmgState.berryWeakened      # Whether a type-resisting berry was used
        }
    end
end

#Data Class of Pokemon (uninitialized Battler)
class PokemonLog < ML_Log
    def initialize(pkmn)

        moves = [] #bc thats a lie: @return [Array<Symbol>] the IDs of moves known by this Pokémon when it was obtained
        pkmn.moves.each { |m| moves.push(MoveLog.new(m))}

        @hmap = {
            :species    => pkmn.species, # @return [Symbol] this Pokémon's species
            :hp         => pkmn.hp, # @return [Integer] the current HP
            :status     => pkmn.status, # @return [Symbol] this Pokémon's current status (see GameData::Status)
            :statusCount => pkmn.statusCount, # @return [Integer] sleep count / toxic flag / 0: sleep (number of rounds before waking up), toxic (0 = regular poison, 1 = toxic)
            :moves      => moves, 
            # @return [Integer] calculated stats
            :totalhp    => pkmn.totalhp,
            :attack     => pkmn.attack, 
            :defense    => pkmn.defense, 
            :spatk      => pkmn.spatk, 
            :spdef      => pkmn.spdef, 
            :speed      => pkmn.speed,
            :level      => pkmn.level,
            :types      => pkmn.types, # @return [Array<Symbol>] an array of this Pokémon's types
            :gender     => pkmn.gender, # @return [0, 1, 2] this Pokémon's gender (0 = male, 1 = female, 2 = genderless)
            #ability # @return [GameData::Ability, nil] an Ability object corresponding to this Pokémon's ability
            :ability_id => pkmn.ability_id, # @return [Symbol, nil] the ability symbol of this Pokémon's ability
            #item # @return [GameData::Item, nil] an Item object corresponding to this Pokémon's item
            :item_id    => pkmn.item_id,
            :baseStats  => pkmn.baseStats # @return [Hash<Integer>] this Pokémon's base stats, a hash with six key/value pairs
        }
    end
end