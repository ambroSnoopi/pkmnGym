#===============================================================================
# Load large script calls, which dont fit into the "Script..." window.
#===============================================================================

def berryPokemonMart(discount=false)
    berries = []
    GameData::Item.each { |i| 
        berries.push(i.id) if i.pocket == 5
    }
    if discount
        setPrice(:CHERIBERRY, 20)
    end
    pbPokemonMart(berries)
end

def tmPokemonMart(discount=false)
    tms = []
    GameData::Item.each { |i| 
        tms.push(i.id) if i.pocket == 4 && i.field_use == 5 #"TR"
    }
    if discount
        adapter = PokemonMartAdapter.new
        for tm in tms
            setPrice(tm, adapter.getPrice(tm,discount))
        end
    end
    pbPokemonMart(tms)
end

def holdItemsMart(discount=false)
    itemScope = []
    GameData::Item.each { |i| 
        itemScope.push(i.id) if i.pocket == 1 && i.description.include?("held")
    }
    if discount
        adapter = PokemonMartAdapter.new
        for i in itemScope
            setPrice(i, adapter.getPrice(i, discount))
        end
    end
    pbPokemonMart(itemScope)
end

def evoItemsMart(discount=false)
    itemScope = []
    GameData::Item.each { |i| 
        itemScope.push(i.id) if i.pocket == 1 && i.description.include?("volve") #Evolve, evolve
    }
    if discount
        adapter = PokemonMartAdapter.new
        for i in itemScope
            setPrice(i, adapter.getPrice(i, discount))
        end
    end
    pbPokemonMart(itemScope)
end