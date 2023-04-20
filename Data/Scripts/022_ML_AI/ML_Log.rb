#TODO: change all/most Data Class attributes to attr_reader
#TODO: reconsider dropping the individual attributes alltogether and just keep the hmap...

# Abstract Data Class for MLLoger
class ML_Log
  attr_reader :hmap         # Hashmap to collect each variable that needs to be logged
  attr_accessor :dir        # Directory Path to where the Log shall be saved
  attr_accessor :fname      # Filename (Trunc without File-Ending/Type)

  attr_reader :battle

  ML_VERSION = 0.3

  # return a JSON String representation of the hmap
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
    str.gsub!("#", "") # bc python cant handle this :)
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

  # writes a JSON representation of the Objet to a File
  # optionally update dir & fname
  def to_json(dir = @dir, fname = self.fname)
    @dir = dir
    @fname = fname
    Dir.mkdir(dir) if !File.directory?(dir)
    #File.open("#{dir}/#{fname}.json", "w") {|f| f.write(self.as_json) }
    File.write("#{dir}/#{fname}.json", self.as_json)
  end
end

# Data Class of Battle for general static Metadate
# Given a Battle Class it will extract & store all relevant information, similar to TurnLog
class BattleLog < ML_Log
  attr_reader   :id         # identifying a battle
  attr_accessor :sid        # identifying a snapshot
  attr_accessor :sLabel       # label/name for the snapshot, also used for the filename
  attr_reader   :player       # Player trainer (or array of trainers)
  attr_reader   :opponent     # Opponent trainer (or array of trainers)  
  attr_accessor :decision
  attr_reader   :gameVersion
  # Results of battle:
  #  0 - Undecided or aborted
  #  1 - Player won
  #  2 - Player lost
  #  3 - Player or wild Pokémon ran from battle, or player forfeited the match
  #  4 - Wild Pokémon was caught
  #  5 - Draw

  def initialize(id, battle, dir = @dir, sid = 0, sLabel = "default")
    @id         = id
    @sid        = sid
    @sLabel     = sLabel
    @battle     = battle
    @player     = battle.player.collect  {|t| TrainerLog.new(t)}
    @opponent   = battle.opponent.collect{|t| TrainerLog.new(t)}
    @decision   = 0

    @dir        = dir

  end

  def fname
    return "battle-#{@id}-#{@sid}-#{@sLabel}"
  end
  
  def hmap #dynamic to get updates on @decision
    return {
      :id           => @id, 
      :sid          => @sid,
      :sLabel       => @sLabel,
      :player       => @player, 
      :opponent     => @opponent,
      :decision     => @decision,
      :pbsVersion   => Essentials::VERSION,
      :gameVersion  => Settings::GAME_VERSION,
      :gameGen      => Settings::MECHANICS_GENERATION,
      :sideSizes    => @battle.sideSizes,
      :rep          => $gcGymLeader.rep,
      :mlVersion    => ML_VERSION,
      :mlModel      => 'AutoML0d3484f3424' #TODO: per side/battler?
    }
  end
end

# Wrapper Data Class of Trainer
# Given a Trainer Class it will extract & store all relevant information
class TrainerLog < ML_Log 
  def initialize(trainer, dir = @dir, fname = @fname)
    trainer_type = GameData::TrainerType.get(trainer.trainer_type)
    @hmap = {
      :id           => trainer.id,
      :name         => trainer.name,

      :trainer_type => trainer.trainer_type,
      :skill_level  => trainer_type.skill_level,
      :base_money   => trainer_type.base_money
    }
  end
end

# Data Class of Battle for dynamic Round related data
# Given a Battle Class it will extract & store all relevant information, similar to BattleLog
class TurnLog < ML_Log
  #from Battle class
  attr_reader   :turnCount
  #attr_reader   :field      # Effects common to the whole of a battle
  #attr_reader   :sides      # Effects common to each side of a battle
  #attr_reader   :positions    # Effects that apply to a battler position
  attr_reader   :battler0     # Currently active Pokémon
  attr_reader   :battler1     # Currently active Pokémon
  attr_accessor :items      # Items held by opponents
  attr_accessor :ally_items     # Items held by allies
  attr_accessor :choices      # Choices made by each Pokémon this round 
  #attr_reader   :usedInBattle   # Whether each Pokémon was used in battle (for Burmy)
  attr_accessor :lastMoveUsed   # Last move used
  attr_accessor :lastMoveUser   # Last move user

  def initialize(battleID, turnID, battle, dir = @dir, sid = 0, sLabel = "default")

    battle.battlers.each_with_index{ |b, i| ML_Logger.seeBattler(i, b)}
    
    # see class Battle::ActiveField
    field_effects_scope = ['AmuletCoin', 'FairyLock', 'FusionBolt', 'FusionFlare', 'Gravity', 'HappyHour', 'IonDeluge', 'MagicRoom', 'MudSportField', 'PayDay', 'TrickRoom', 'WaterSportField', 'WonderRoom']
    field_effects = {}
    field_effects_scope.each_with_index { |e, i| field_effects[e] = battle.field.effects[i] }

    side_effects_scope = ['AuroraVeil', 'CraftyShield', 'EchoedVoiceCounter', 'EchoedVoiceUsed', 'LastRoundFainted', 'LightScreen', 'LuckyChant', 'MatBlock', 'Mist', 'QuickGuard', 'Rainbow', 'Reflect', 'Round', 'Safeguard', 'SeaOfFire', 'Spikes', 'StealthRock', 'StickyWeb', 'Swamp', 'Tailwind', 'ToxicSpikes', 'WideGuard']
    side0_effects = {}
    side1_effects = {}
    side_effects_scope.each_with_index { |e, i| 
      side0_effects[e] = battle.sides[0].effects[i]
      side1_effects[e] = battle.sides[1].effects[i]
    }

    position_effects_scope = ['FutureSightCounter', 'FutureSightMove', 'FutureSightUserIndex', 'FutureSightUserPartyIndex', 'HealingWish', 'LunarDance', 'Wish', 'WishAmount', 'WishMaker']
    position_effects = []
    battle.positions.each_with_index { |pos, p_i|
      pos_effects = {}
      position_effects_scope.each_with_index { |e, i| pos_effects[e] = pos.effects[i] }
      position_effects[p_i] = pos_effects
    }


    @choices = [] #making a deep copy
    for c in battle.choices
      choice = c.clone
      case choice[0] #Possible Cases: :None, :UseMove, :SwitchOut, :UseItem, :Call, :Run, :Shift 
      when :UseMove  #[:UseMove, idxMove, Move, Target] see def pbRegisterMove #where is the score?
        choice[2] = MoveLog.new(choice[2].realMove)
      end
      @choices.append(choice)
    end

    @party0 = []
    battle.player[0].party.each { |p| @party0.push(PokemonLog.new(p)) }
    @party1 = []
    battle.opponent[0].party.each { |p| @party1.push(PokemonLog.new(p)) }

    @dir   = dir
    @fname = "b-#{battleID}-t-#{turnID}-#{sid}-#{sLabel}"
    @hmap = {
      :battleID         => battleID,
      :turnID           => turnID,
      :sid              => sid,
      :sLabel           => sLabel,
      :turnCount        => battle.turnCount,
      :positionEffects  => position_effects,
      "side0.effects"   => side0_effects,
      "side1.effects"   => side1_effects,
      :fieldEffects     => field_effects,
      :weather          => battle.field.weather, #Symbol, e.g. :Sun
      :weatherDuration  => battle.field.weatherDuration, #Symbol, e.g. :Sun
      :terrain          => battle.field.terrain, #Symbol, e.g. :Electric
      :terrainDuration  => battle.field.terrainDuration, #Symbol, e.g. :Electric
      :battler0         => BattlerLog.new(battleID, turnID, battle, battle.battlers[0]), #Player Pokemon
      :battler1         => BattlerLog.new(battleID, turnID, battle, battle.battlers[1]), #Opponents Pokemon
      :items            => battle.items,
      :ally_items       => battle.ally_items,
      :choices          => @choices,
      :usedInBattle     => battle.usedInBattle, #TODO: appearently always empty?
      :lastMoveUsed     => battle.lastMoveUsed,
      :lastMoveUser     => battle.lastMoveUser,
      :party0           => @party0, #Player Party
#      "party0.seen"     => ML_Logger.seenBattler(0),
      :party1           => @party1  #Opponent Party
#      "party1.seen"     => ML_Logger.seenBattler(1)
    }

    #get scores of traditional pbAI for each move of each battler against each target
    battle.battlers.each_with_index{ |battler, b_id| 
      battler.moves.each_with_index{ |m, m_id| 
        battle.battlers.each_with_index{ |target, t_id| 
          score = battle.battleAI.pbGetMoveScore(m, battler, target, skill = 100)
          @hmap["b#{b_id}.m#{m_id}.t#{t_id}.pbScore"] = score

          @hmap["b#{b_id}.m#{m_id}.t#{t_id}.typeMod"] = m.pbCalcTypeMod(m.type, battler, target)
          @hmap[:sharesTypes] = battler.types[0] && target.pbHasType?(battler.types[0]) && battler.types[1] && target.pbHasType?(battler.types[1])
          #TODO: check direction:
          @hmap["b#{b_id}.canSleep.t#{t_id}"] = target.pbCanSleep?(battler, false)
          @hmap["b#{b_id}.canPoison.t#{t_id}"] = target.pbCanPoison?(battler, false)
          @hmap["b#{b_id}.canParalyze.t#{t_id}"] = target.pbCanParalyze?(battler, false)
          @hmap["b#{b_id}.canBurn.t#{t_id}"] = target.pbCanBurn?(battler, false)
          @hmap["b#{b_id}.canFreeze.t#{t_id}"] = target.pbCanFreeze?(battler, false)
          @hmap["b#{b_id}.canConfuse.t#{t_id}"] = target.pbCanConfuse?(battler, false)
        }
      }
    }
  end
end

# Data Class of Battle::Battler
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
  #attr_reader   :fainted  # Boolean to mark whether self has fainted properly

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
  attr_accessor :lastMoveFailed    # For Stomping Tantrum
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

  def initialize(battleID, turnID, battle, battler, dir = @dir, fname = @fname)
    @moves = []
    battler.moves.each { |m| @moves.push(MoveLog.new(m.realMove, m)) }

    @movesUsed = []
    battler.movesUsed.each { |m| @movesUsed.push(m.to_s) }
    #battler.movesUsed.each { |m| @movesUsed.push(MoveLog.new(m))}  #unfortunately, "m" here is just a Symbol

    # module PBEffects list the effects in scope for certain classes with their respective index position
    # join info into a readable battler_effect hash
    effects_scope = ['AquaRing', 'Attract', 'BanefulBunker', 'BeakBlast', 'Bide', 'BideDamage', 'BideTarget', 'BurnUp', 'Charge', 'ChoiceBand', 'Confusion', 'Counter', 'CounterTarget', 'Curse', 'Dancer', 'DefenseCurl', 'DestinyBond', 'DestinyBondPrevious', 'DestinyBondTarget', 'Disable', 'DisableMove', 'Electrify', 'Embargo', 'Encore', 'EncoreMove', 'Endure', 'FirstPledge', 'FlashFire', 'Flinch', 'FocusEnergy', 'FocusPunch', 'FollowMe', 'Foresight', 'FuryCutter', 'GastroAcid', 'GemConsumed', 'Grudge', 'HealBlock', 'HelpingHand', 'HyperBeam', 'Illusion', 'Imprison', 'Ingrain', 'Instruct', 'Instructed', 'JawLock', 'KingsShield', 'LaserFocus', 'LeechSeed', 'LockOn', 'LockOnPos', 'MagicBounce', 'MagicCoat', 'MagnetRise', 'MeanLook', 'MeFirst', 'Metronome', 'MicleBerry', 'Minimize', 'MiracleEye', 'MirrorCoat', 'MirrorCoatTarget', 'MoveNext', 'MudSport', 'Nightmare', 'NoRetreat', 'Obstruct', 'Octolock', 'Outrage', 'ParentalBond', 'PerishSong', 'PerishSongUser', 'PickupItem', 'PickupUse', 'Pinch', 'Powder', 'PowerTrick', 'Prankster', 'PriorityAbility', 'PriorityItem', 'Protect', 'ProtectRate', 'Quash', 'Rage', 'RagePowder', 'Rollout', 'Roost', 'ShellTrap', 'SkyDrop', 'SlowStart', 'SmackDown', 'Snatch', 'SpikyShield', 'Spotlight', 'Stockpile', 'StockpileDef', 'StockpileSpDef', 'Substitute', 'TarShot', 'Taunt', 'Telekinesis', 'ThroatChop', 'Torment', 'Toxic', 'Transform', 'TransformSpecies', 'Trapping', 'TrappingMove', 'TrappingUser', 'Truant', 'TwoTurnAttack', 'Type3', 'Unburden', 'Uproar', 'WaterSport', 'WeightChange', 'Yawn']
    battler_effects = {}
    effects_scope.each_with_index { |e, i| battler_effects[e] = battler.effects[i] }

    @dir   = dir
    @fname = fname
    @hmap = {
      :battleID   => battleID,
      :turnID   => turnID,
      :index    => battler.index,
      :status   => battler.status,
      :statusCount => battler.statusCount,
      :species  => battler.species,
      :types    => battler.types, #or pbTypes?
      :level    => battler.level,
      :gender   => battler.gender,
      :ability_id => battler.ability_id,
      :item_id  => battler.item_id,
      :plainStats => battler.plainStats.transform_keys(&:to_s), #why to_s?
      :totalhp  => battler.totalhp,
      :hp       => battler.hp,
      :hp_z     => battler.hp / battler.totalhp,
      :stages   => battler.stages.transform_keys(&:to_s) ,

      :moves    => @moves,
      :movesUsed  => @movesUsed, 

      :turnCount  => battler.turnCount,
      :participants      => battler.participants, #only relevant in doubles?
      :lastAttacker      => battler.lastAttacker, #only relevant in doubles?    
      :lastFoeAttacker     => battler.lastFoeAttacker,    
      :lastHPLost      => battler.lastHPLost,   #only relevant in doubles?   
      :lastHPLostFromFoe   => battler.lastHPLostFromFoe,  
      :lastMoveUsed      => battler.lastMoveUsed,     
      :lastMoveUsedType    => battler.lastMoveUsedType,   
      :lastRegularMoveUsed   => battler.lastRegularMoveUsed,       
      :statsRaisedThisRound  => battler.statsRaisedThisRound, 
      :statsLoweredThisRound => battler.statsLoweredThisRound,
      :damageState       => DamageStateLog.new(battler.damageState),
      :effects => battler_effects, #Hash<String(PBEffects), int/bool> e.g. {"Reflect" => 1}

      # states considered withing pbGetMoveScore ff
      :belched => battler.belched?,
      :itemActive => battler.itemActive?,
      :abilityActive => battler.abilityActive?,
      :airboren => battler.airborne?,
      :canChangeType => battler.canChangeType?,
      #:recycleItem => battler.recycleItem,
      :unstoppableAbility => battler.unstoppableAbility?,
      :affectedByTerrain => battler.affectedByTerrain?,
      :opposingBattlerCount => battle.pbOpposingBattlerCount(battler),
      :ableNonActiveCount => battle.pbAbleNonActiveCount(battler.idxOwnSide),
      :usingMultiTurnAttack => battler.usingMultiTurnAttack?,
      :semiInvulnerable => battler.semiInvulnerable?,
      :effectiveWeather => battler.effectiveWeather #e.g. :Hail
    }
  end
end

# Simplified Data Class for Pokemon::Move
class MoveLog < ML_Log
  def initialize(pkmnMove, battleMove=nil)
    @hmap = {
      #:realMove    => battleMove.realMove  ,
      :id           => pkmnMove.id    ,
      :name         => pkmnMove.name    ,
      :function     => pkmnMove.function_code  ,
      :baseDamage   => pkmnMove.base_damage,
      :type         => pkmnMove.type    ,
      :category     => pkmnMove.category  ,
      :accuracy     => pkmnMove.accuracy  ,
      :pp           => pkmnMove.pp    ,
      :total_pp     => pkmnMove.total_pp  ,
      :effectChance => pkmnMove.effect_chance,
      :target       => pkmnMove.target,
      :priority     => pkmnMove.priority,
      :flags        => pkmnMove.flags,
      :seen         => pkmnMove.pp != pkmnMove.total_pp,

      #:snatched
      #:calcType           => battleMove&.calcType,
      :powerBoost         => battleMove&.powerBoost,
      :hitsFlyingTargets  => battleMove&.hitsFlyingTargets?,
      :hitsDiggingTargets => battleMove&.hitsDiggingTargets?,
      :hitsDivingTargets  => battleMove&.hitsDivingTargets?,
      :usableWhenAsleep   => battleMove&.usableWhenAsleep?,
      :thawsUser          => battleMove&.thawsUser?,
      :chargingTurnMove   => battleMove&.chargingTurnMove?,
      :flinchingMove      => battleMove&.flinchingMove?
    }
  end
end

# Simplified Data Class for Battle::DamageState
class DamageStateLog < ML_Log 
  def initialize(dmgState)
    @hmap = {
      :typeMod       => dmgState.typeMod       ,# Type effectiveness
      :unaffected      => dmgState.unaffected    ,
      :protected       => dmgState.protected     ,
      :magicCoat       => dmgState.magicCoat     ,
      :magicBounce     => dmgState.magicBounce     ,
      :totalHPLost     => dmgState.totalHPLost     ,# Like hpLost, but cumulative over all hits
      :fainted       => dmgState.fainted       ,# Whether battler was knocked out by the move
      :missed        => dmgState.missed      ,# Whether the move failed the accuracy check
      :affection_missed  => dmgState.affection_missed  ,
      :invulnerable    => dmgState.invulnerable    ,# If the move missed due to two turn move invulnerability
      :calcDamage      => dmgState.calcDamage    ,# Calculated damage
      :hpLost        => dmgState.hpLost      ,# HP lost by opponent, inc. HP lost by a substitute
      :critical      => dmgState.critical      ,# Critical hit flag
      :affection_critical  => dmgState.affection_critical,
      :substitute      => dmgState.substitute    ,# Whether a substitute took the damage
      :focusBand       => dmgState.focusBand     ,# Focus Band used
      :focusSash       => dmgState.focusSash     ,# Focus Sash used
      :sturdy        => dmgState.sturdy      ,# Sturdy ability used
      :disguise      => dmgState.disguise      ,# Disguise ability used
      :iceFace       => dmgState.iceFace       ,# Ice Face ability used
      :endured       => dmgState.endured       ,# Damage was endured
      :affection_endured   => dmgState.affection_endured ,
      :berryWeakened     => dmgState.berryWeakened    # Whether a type-resisting berry was used
    }
  end
end

# Data Class of Pokemon (uninitialized Battler)
class PokemonLog < ML_Log
  attr_accessor :seen

  def initialize(pkmn)
    #for finding relevant attributes
    #echoln pkmn.inspect
    #echoln pkmn.instance_variables 
    #echoln pkmn.local_variables

    moves = [] #bc thats a lie: @return [Array<Symbol>] the IDs of moves known by this Pokémon when it was obtained
    pkmn.moves.each { |m| moves.push(MoveLog.new(m))}

    @hmap = {
      :species  => pkmn.species, # @return [Symbol] this Pokémon's species
      :hp       => pkmn.hp, # @return [Integer] the current HP
      :status   => pkmn.status, # @return [Symbol] this Pokémon's current status (see GameData::Status)
      :statusCount => pkmn.statusCount, # @return [Integer] sleep count / toxic flag / 0: sleep (number of rounds before waking up), toxic (0 = regular poison, 1 = toxic)
      :moves    => moves, 
      # @return [Integer] calculated stats
      :totalhp  => pkmn.totalhp,
      :hp_z     => pkmn.hp/pkmn.totalhp,
      :attack   => pkmn.attack, 
      :defense  => pkmn.defense, 
      :spatk    => pkmn.spatk, 
      :spdef    => pkmn.spdef, 
      :speed    => pkmn.speed,
      :level    => pkmn.level,
      :types    => pkmn.types, # @return [Array<Symbol>] an array of this Pokémon's types
      :gender   => pkmn.gender, # @return [0, 1, 2] this Pokémon's gender (0 = male, 1 = female, 2 = genderless)
      #ability # @return [GameData::Ability, nil] an Ability object corresponding to this Pokémon's ability
      :ability_id => pkmn.ability_id, # @return [Symbol, nil] the ability symbol of this Pokémon's ability
      #item # @return [GameData::Item, nil] an Item object corresponding to this Pokémon's item
      :item_id  => pkmn.item_id,
      :baseStats=> pkmn.baseStats, # @return [Hash<Integer>] this Pokémon's base stats, a hash with six key/value pairs

      :fainted  => pkmn.fainted?,
      :seen     => ML_Logger.pkmnSeen?(pkmn)
    }
  end
end