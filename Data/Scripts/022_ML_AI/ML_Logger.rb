#===============================================================================
# a tiny static logger (singleton)
#
# Logs will be organized in ML/logs/battle[N]/turn[N]
# for an example see ML/logs/battle0
#===============================================================================
module ML_Logger
  attr_accessor :seenBattler

  ML_LOG_DIR = "ML/logs/battle"
  @@battleLogDir = ML_LOG_DIR+"0"
  @@battleID = 0
  @@turnID = 0
  @@situationID = 0
  @@battleLogs = []
  @@turnLogs = []
  @@situationLogs = []

  @seenBattler = [] # map of seen battler pokemons by pos index
  def self.seeBattler(idx, battler)
    seen = @seenBattler[idx].nil? ? [] : @seenBattler[idx]
    seen.push(battler.pokemon) unless seen.include?(battler.pokemon)
    @seenBattler[idx] = seen
  end

  def self.seenBattler(idx)
    return @seenBattler[idx]
  end

  def self.pkmnSeen?(pkmn)
    return @seenBattler.flatten.include?(pkmn)
  end

  #resets internal variables and creates directory
  #checks if the dir alrdy exist, if so calls itself recursivly to inc battleID (required after loading the game)
  #then logs metadata about the battle
  #called in def pbStartBattle of Data\Scripts\011_Battle\001_Battle\002_Battle_StartAndEnd.rb
  def self.newBattle(battle)
    @@turnID=0
    @@situationID=0
    self.incrBattleID
    battleLog = BattleLog.new(@@battleID, battle)
    battleLog.to_json(@@battleLogDir)
    @@battleLogs[@@battleID] = battleLog
    @@turnLogs = []
    @@situationLogs = []
  end

  def self.incrBattleID
    @@battleID+=1
    @@battleLogDir=ML_LOG_DIR+@@battleID.to_s
    File.directory?(@@battleLogDir) ? incrBattleID : Dir.mkdir(@@battleLogDir)
  end

  #called in: pbOnAllBattlersEnteringBattle, pbEndOfRoundPhase
  def self.endTurn(battle)
    turnLog = TurnLog.new(@@battleID, @@turnID, battle, @@battleLogDir, @@situationID, "end")
    #turnLog.to_json(@@battleLogDir+"/turn#{@@turnID}", "turn#{@@turnID}") #currently there is no need to store turn logs in a seperate folder
    turnLog.to_json(@@battleLogDir)
    @@turnLogs[@@turnID] = turnLog
    @@situationLogs = []
    @@turnID+=1
    @@situationID=0
  end

  #called in pbEndOfBattle
  def self.endBattle(decision)
    return unless decision > 0
    @@battleLogs[@@battleID].decision=decision
    @@battleLogs[@@battleID].sid=1
    @@battleLogs[@@battleID].sLabel="end"
    @@battleLogs[@@battleID].to_json(@@battleLogDir)
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
  #   pbCommandPhase
  #situations: "preSwitch", ?
  def self.newState(battle, situation)
    turnLog = TurnLog.new(@@battleID, @@turnID, battle, @@battleLogDir, @@situationID, situation)
    turnLog.to_json(@@battleLogDir)
    @@situationID+=1
    return turnLog
  end
end