#===============================================================================
# a tiny static logger (singleton)
# 
# Logs will be organized in ML/logs/battle[N]/turn[N]
# for an example see ML/logs/battle0
#===============================================================================
class ML_Logger

    ML_LOG_DIR = "ML/logs/battle"
    @@battleLogDir = ML_LOG_DIR+"0"
    @@battleID = 0
    @@turnID = 0
    @@battlelogs = [] #currently not used (only required if ammended later on)
  
    #resets internal variables and creates directory
    #checks if the dir alrdy exist, if so calls itself recursivly to inc battleID (required after loading the game)
    #then logs metadata about the battle
    #called in gcBattle before starting the battle
    def self.newBattle(battle)
        @@turnID=0
        self.incrBattleID
        battleLog = BattleLog.new(@@battleID, battle)
        battleLog.to_json(@@battleLogDir, "battle#{@@battleID}")
        @@battlelogs[@@battleID] = battleLog
    end

    def self.incrBattleID
        @@battleID+=1
        @@battleLogDir=ML_LOG_DIR+@@battleID.to_s
        File.directory?(@@battleLogDir) ? incrBattleID : Dir.mkdir(@@battleLogDir)
    end

    #called in: pbEndOfRoundPhase
    #other canditates would be:
    #   pbDefaultChooseEnemyCommand
    #   pbDefaultChooseNewEnemy
    #   pbEndOfBattle / pbJudge
    def self.newTurn(battle)
        turnLog = TurnLog.new(battle)
        turnLog.to_json(@@battleLogDir+"/turn#{@@turnID}", "turn#{@@turnID}")
        @@turnID+=1
    end
  
end

#Abstract Data Class for MLLoger
class MLLog 
    attr_reader :hmap               # Hashmap to collect each variable that needs to be logged
    attr_accessor :dir              # Directory Path to where the Log shall be saved
    attr_accessor :fname            # Filename (Trunc without File-Ending/Type)

    #return a JSON String representation of the hmap
    def as_json(hmap = @hmap)
        h = hmap.merge #copy
        h.transform_keys!(&:to_s) 
        h.transform_values!{|v| 
            case
            when v.respond_to?(:as_json)
                v.as_json #TODO: keep it as an hash map without encapsulating it in double quotes (handled below as a workaround)
            when v.is_a?(Integer)
                v
            else
                v.to_s 
            end
        }
        str = h.to_s
        str.gsub!("=>", ": ")
        #handle nested json & prettify: #TOTEST does it work with multiple levels of nesting?
        str.gsub!("\"{", "{\n   ")
        str.gsub!("}\"", "}\n")
        str.gsub!("\\\"", "\"")
        str.gsub!(",", ",\n")
        str.gsub!("\\n", "  ") #idk why these got printed but lets use it to our advantage :)
        return str
    end

    def to_s
        return self.as_json
    end

    #writes a JSON representation of the Objet to a File
    #optionally update dir & fname
    def to_json(dir = @dir, fname = @fname)
        @dir = dir
        @fname = fname
        Dir.mkdir(dir) if !File.directory?(dir)
        File.open("#{dir}/#{fname}.json", "w") {|f| f.write(self.as_json) }
    end
end

#Data Class of Battle
#Given a Battle Class it will extract & store all relevant information
class BattleLog < MLLog
    attr_reader   :id
    attr_reader   :player           # Player trainer (or array of trainers)
    attr_reader   :opponent         # Opponent trainer (or array of trainers)  

    def initialize(id, battle, dir = @dir, fname = @fname)
        @id         = id
        @player     = TrainerLog.new(battle.player[0])
        @opponent   = TrainerLog.new(battle.opponent[0]) #no double-battles support

        @dir   = dir
        @fname = fname
        @hmap = {
            :id        => @id, 
            :player    => @player, 
            :opponent  => @opponent
        }
    end
end

#Wrapper Data Class of Trainer
#Given a Trainer Class it will extract & store all relevant information
class TrainerLog < MLLog 
    attr_reader :id
    attr_reader :trainer_type
    attr_reader :name
    attr_reader :version

    def initialize(trainer, dir = @dir, fname = @fname)
        @id             = trainer.id
        @trainer_type   = trainer.trainer_type
        @name           = trainer.name

        @dir   = dir
        @fname = fname
        @hmap = {
            :id             => @id, 
            :trainer_type   => @trainer_type, 
            :name           => @name
        }
    end
end

#Data Class to store all relevant information of a turn
class TurnLog < MLLog
    #from Battle class
    attr_reader   :turnCount
    attr_reader   :field            # Effects common to the whole of a battle
    attr_reader   :sides            # Effects common to each side of a battle
    attr_reader   :positions        # Effects that apply to a battler position
    attr_reader   :battlers         # Currently active Pokémon
    attr_accessor :items            # Items held by opponents
    attr_accessor :ally_items       # Items held by allies
    attr_accessor :choices          # Choices made by each Pokémon this round
    attr_reader   :usedInBattle     # Whether each Pokémon was used in battle (for Burmy)
    attr_accessor :lastMoveUsed     # Last move used
    attr_accessor :lastMoveUser     # Last move user
    #TBC

    def initialize(battle)
        @turnCount = battle.turnCount
        #TODO add and test more variables

        @dir   = dir
        @fname = fname
        @hmap = {
            :turnCount  => @turnCount
        }
    end
end

=begin
    
# Results of battle:
#    0 - Undecided or aborted
#    1 - Player won
#    2 - Player lost
#    3 - Player or wild Pokémon ran from battle, or player forfeited the match
#    4 - Wild Pokémon was caught
#    5 - Draw
# Possible actions a battler can take in a round:
#    :None
#    :UseMove
#    :SwitchOut
#    :UseItem
#    :Call
#    :Run
#    :Shift
    
=end