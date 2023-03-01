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
    @@situationID = 0
    @@battlelogs = [] #currently not used (only required if ammended later on)
  
    #resets internal variables and creates directory
    #checks if the dir alrdy exist, if so calls itself recursivly to inc battleID (required after loading the game)
    #then logs metadata about the battle
    #called in gcBattle before starting the battle
    def self.newBattle(battle)
        @@turnID=0
        @@situationID=0
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

    #called in: pbOnAllBattlersEnteringBattle, pbEndOfRoundPhase
    def self.endTurn(battle)
        turnLog = TurnLog.new(@@battleID, @@turnID, battle)
        #turnLog.to_json(@@battleLogDir+"/turn#{@@turnID}", "turn#{@@turnID}") #currently there is no need to store turn logs in a seperate folder
        turnLog.to_json(@@battleLogDir, "turn#{@@turnID}-end")
        @@turnID+=1
        @@situationID=0
    end
  
    #to be called before a player/AI command/choice has to be made to make a snapshot of the current situation
    #the result of the choice should be visable at the turn end log
    #the state before "ChooseCommand" should be visible from the endTurn log
    #called in: 
    #   pbSwitchInBetween
    #other canditates would be:
    #   pbDefaultChooseEnemyCommand
    #   pbRegisterSwitch (never reached)
    #   pbEORSwitch (always executed)
    #   pbDefaultChooseNewEnemy (redundant with pbSwitchInBetween)
    #situations: "preSwitch", ?
    def self.newState(battle, situation)
        turnLog = TurnLog.new(@@battleID, @@turnID, battle)
        #turnLog.to_json(@@battleLogDir+"/turn#{@@turnID}", "turn#{@@turnID}") #currently there is no need to store turn logs in a seperate folder
        turnLog.to_json(@@battleLogDir, "turn#{@@turnID}-s#{@@situationID}-#{situation}")
        @@situationID+=1
    end
end