#===============================================================================
# Updating the Box with applicable Pkmn
#===============================================================================
def gcFillBox(type, lvl, legendariesAllowed = false)
    applicableSpecies = []
    GameData::Species.each_species { |s| applicableSpecies.push(s.id) if 
        s.types.include?(type) && 
        s.minimum_level <= lvl &&
        s.get_previous_species.minimum_level <= lvl && #exclude trade evos, if their previous stage was illegal to begin with
        (!s.family_item_evolutions_use_item? or s == s.get_baby_species) && #exclude evo stone evolutions
        #GameData::Evolution.get(s.get_previous_species).use_item_proc.nil?? && 
        (!s.egg_groups.include?(:Undiscovered) or legendariesAllowed)
    }
    for pkmn in applicableSpecies
        #echoln pkmn
        #echoln GameData::Species.try_get(pkmn).category
        pbAddPokemonSilent(pkmn, lvl, true, false) #if pkmn.types.include?(type)
    end
    $PokemonStorage.currentBox=(0)
end

def gcUpdateBox(type, lvl, legendariesAllowed = false)
    $PokemonStorage.initialize()
    gcFillBox(type, lvl, legendariesAllowed)
end