#require 'socket'

# Interface to a trained ML Model
#TODO: This is W.I.P.!
class ML_AI

  ML_AI_DICT = { #TODO: make it rep or trainer.skill_level based? move this config to a  PBS-style file?
    :online => {
      "action" => '',
      :UseMove => 'ML/models/maram-ml-kpwft/score.py',
      "switch" => '' },
    :local  => {
      "action" => '',
      :UseMove => 'ML/models/AutoML0d3484f3424/scoring_file_v_2_0_0.py',
      "switch" => '' }
  } #TODO: specify ML_VERSION of each model, add mlVersion as parameter for infer() function, case branch inside infer() to e.g. inferV0_2() for backwards compability

  def initialize(online=Settings::ONLINE_AI)
    @mode = online ? :online : :local
  end


  #TODO: should be called in def pbChooseMoves(idxBattler) of Battle::AI / especially considering AI skill levels
  #but I'm lazy for now, so let's just catch it in def pbRegisterMove of Battle (004_Battle_ActionAttacksPriority.rb)
  def inferMove(turnlog, idxBattler, battle)
    #turnlog.hmap is of form {string => string/int} because prep_json replaces it inplace
    #TODO: either store each attribute again outside of the hmap, or def restore, or alter how to_json works (make copy instead of inplace update)
    #meanwhile using original values from battle
    '''
    h = turnlog.hmap
    echoln h.class.to_s
    h.each do |key, value|
      echoln key.class.to_s+": "+value.class.to_s
      echoln key.to_s+": "+value.to_s
    end
    if idxBattler==0
      actor    = h[:battler0].hmap
      opponent = h[:battler1].hmap
    else
      actor    = h[:battler1].hmap
      opponent = h[:battler0].hmap
    end
    actor_move0 = actor[:moves][0].hmap
    actor_move1 = actor[:moves][1].hmap
    actor_move2 = actor[:moves][2].hmap
    actor_move3 = actor[:moves][3].hmap

    data = {
      "--turnCount" => h.turnCount,
      "--actor_move0_function" => actor_move0[:function],
      "--actor_move0_baseDamage" => actor_move0[:baseDamage],
      "--actor_move0_type" => actor_move0[:type],
      "--actor_move0_category" => actor_move0[:category],
      "--actor_move0_accuracy" => actor_move0[:accuracy],
      "--actor_move0_priority" => actor_move0[:priority],
      "--actor_move1_function" => actor_move1[:function],
      "--actor_move1_baseDamage" => actor_move1[:baseDamage],
      "--actor_move1_type" => actor_move1[:type],
      "--actor_move1_category" => actor_move1[:category],
      "--actor_move1_accuracy" => actor_move1[:accuracy],
      "--actor_move1_priority" => actor_move1[:priority],
      "--actor_move2_function" => actor_move2[:function],
      "--actor_move2_baseDamage" => actor_move2[:baseDamage],
      "--actor_move2_type" => actor_move2[:type],
      "--actor_move2_category" => actor_move2[:category],
      "--actor_move2_accuracy" => actor_move2[:accuracy],
      "--actor_move2_priority" => actor_move2[:priority],
      "--actor_move3_function" => actor_move3[:function],
      "--actor_move3_baseDamage" => actor_move3[:baseDamage],
      "--actor_move3_type" => actor_move3[:type],
      "--actor_move3_category" => actor_move3[:category],
      "--actor_move3_accuracy" => actor_move3[:accuracy],
      "--actor_move3_priority" => actor_move3[:priority],
      "--actor_attack" => actor[:plainStats]["ATTACK"],
      "--actor_spatk" => actor[:plainStats]["SPECIAL_ATTACK"],
      "--actor_spdef" => actor[:plainStats]["SPECIAL_DEFENSE"],
      "--actor_totalhp" => actor[:totalhp],
      "--actor_hp" => actor[:hp],
      "--actor_stages_attack" => actor[:stages]["ATTACK"],
      "--actor_stages_defense" => actor[:stages]["DEFENSE"],
      "--actor_stages_spatk" => actor[:stages]["SPECIAL_ATTACK"],
      "--actor_stages_spdef" => actor[:stages]["SPECIAL_DEFENSE"],
      "--actor_stages_speed" => actor[:stages]["SPEED"],
      "--actor_stages_accuracy" => actor[:stages]["ACCURACY"],
      "--actor_stages_evasion" => actor[:stages]["EVASION"],
      "--opponent_stages_attack" => opponent[:stages]["ATTACK"],
      "--opponent_stages_defense" => opponent[:stages]["DEFENSE"],
      "--opponent_stages_spatk" => opponent[:stages]["SPECIAL_ATTACK"],
      "--opponent_stages_spdef" => opponent[:stages]["SPECIAL_DEFENSE"],
      "--opponent_stages_speed" => opponent[:stages]["SPEED"],
      "--opponent_stages_accuracy" => opponent[:stages]["ACCURACY"],
      "--opponent_stages_evasion" => opponent[:stages]["EVASION"]
    }
    '''

    if idxBattler == 0
      actor    = battle.battlers[0]
      opponent = battle.battlers[1]
    else
      actor    = battle.battlers[1]
      opponent = battle.battlers[0]
    end

    data = {
      "--turnCount"               => battle.turnCount,
      "--actor_move0_function"    => actor.moves[0].realMove.function_code,
      "--actor_move0_baseDamage"  => actor.moves[0].realMove.base_damage,
      "--actor_move0_type"        => actor.moves[0].realMove.type,
      "--actor_move0_category"    => actor.moves[0].realMove.category,
      "--actor_move0_accuracy"    => actor.moves[0].realMove.accuracy,
      "--actor_move0_priority"    => actor.moves[0].realMove.priority,
      "--actor_move1_function"    => actor.moves[1]&.realMove.function_code, # Using Safe Navigation Operator in case battler only has 1 move
      "--actor_move1_baseDamage"  => actor.moves[1]&.realMove.base_damage,
      "--actor_move1_type"        => actor.moves[1]&.realMove.type,
      "--actor_move1_category"    => actor.moves[1]&.realMove.category,
      "--actor_move1_accuracy"    => actor.moves[1]&.realMove.accuracy,
      "--actor_move1_priority"    => actor.moves[1]&.realMove.priority,
      "--actor_move2_function"    => actor.moves[2]&.realMove.function_code,
      "--actor_move2_baseDamage"  => actor.moves[2]&.realMove.base_damage,
      "--actor_move2_type"        => actor.moves[2]&.realMove.type,
      "--actor_move2_category"    => actor.moves[2]&.realMove.category,
      "--actor_move2_accuracy"    => actor.moves[2]&.realMove.accuracy,
      "--actor_move2_priority"    => actor.moves[2]&.realMove.priority,
      "--actor_move3_function"    => actor.moves[3]&.realMove.function_code,
      "--actor_move3_baseDamage"  => actor.moves[3]&.realMove.base_damage,
      "--actor_move3_type"        => actor.moves[3]&.realMove.type,
      "--actor_move3_category"    => actor.moves[3]&.realMove.category,
      "--actor_move3_accuracy"    => actor.moves[3]&.realMove.accuracy,
      "--actor_move3_priority"    => actor.moves[3]&.realMove.priority,
      "--actor_attack"            => actor.plainStats[:ATTACK],
      "--actor_spatk"             => actor.plainStats[:SPECIAL_ATTACK],
      "--actor_spdef"             => actor.plainStats[:SPECIAL_DEFENSE],
      "--actor_totalhp"           => actor.totalhp,
      "--actor_hp"                => actor.hp,
      "--actor_stages_attack"     => actor.stages[:ATTACK],
      "--actor_stages_defense"    => actor.stages[:DEFENSE],
      "--actor_stages_spatk"      => actor.stages[:SPECIAL_ATTACK],
      "--actor_stages_spdef"      => actor.stages[:SPECIAL_DEFENSE],
      "--actor_stages_speed"      => actor.stages[:SPEED],
      "--actor_stages_accuracy"   => actor.stages[:ACCURACY],
      "--actor_stages_evasion"    => actor.stages[:EVASION],
      "--opponent_stages_attack"  => opponent.stages[:ATTACK],
      "--opponent_stages_defense" => opponent.stages[:DEFENSE],
      "--opponent_stages_spatk"   => opponent.stages[:SPECIAL_ATTACK],
      "--opponent_stages_spdef"   => opponent.stages[:SPECIAL_DEFENSE],
      "--opponent_stages_speed"   => opponent.stages[:SPEED],
      "--opponent_stages_accuracy"=> opponent.stages[:ACCURACY],
      "--opponent_stages_evasion" => opponent.stages[:EVASION]
    }

    prompt = ""
    data.each do |key, value|
      prompt += " "+key+" "+value.to_s
    end

    model = ML_AI_DICT[@mode][:UseMove]
    result = `python "#{model}"#{prompt}`.chomp
    return result.to_i
  end
end
