--[[----------------------------------------------------------------------------

  LiteMount/SpellInfo.lua

  Constants for mount spell information.

  And UnitAura(name) replacement wrapper for BfA.

  Copyright 2011-2018 Mike Battersby

----------------------------------------------------------------------------]]--

-- The values are sort order
LM_FLAG = { }
LM_FLAG.SWIM        = 1
LM_FLAG.FLOAT       = 2
LM_FLAG.FLY         = 3
LM_FLAG.RUN         = 4
LM_FLAG.WALK        = 5
LM_FLAG.FAVORITES   = 6
LM_FLAG.AQ          = 100
LM_FLAG.VASHJIR     = 101
LM_FLAG.NAGRAND     = 102

LM_SPELL = { }
LM_SPELL.TRAVEL_FORM = 783
LM_SPELL.GHOST_WOLF = 2645
LM_SPELL.FLIGHT_FORM = 165962
LM_SPELL.FLYING_BROOM = 42667
LM_SPELL.MAGIC_BROOM = 47977
LM_SPELL.LOANED_GRYPHON = 64749
LM_SPELL.LOANED_WIND_RIDER = 64762
LM_SPELL.RUNNING_WILD = 87840
LM_SPELL.TARECGOSAS_VISAGE = 101641
LM_SPELL.GARRISON_ABILITY = 161691
LM_SPELL.FROSTWOLF_WAR_WOLF = 164222
LM_SPELL.TELAARI_TALBUK = 165803
LM_SPELL.MOONFANG = 145133
LM_SPELL.DUSTMANE_DIREWOLF = 171844
LM_SPELL.SOARING_SKYTERROR = 191633
LM_SPELL.STAG_FORM = 210053
LM_SPELL.RATSTALLION_HARNESS = 220123
LM_SPELL.BLUE_QIRAJI_WAR_TANK = 239766
LM_SPELL.RED_QIRAJI_WAR_TANK = 239767

LM_ITEM = { }
LM_ITEM.FLYING_BROOM = 33176
LM_ITEM.MAGIC_BROOM = 37011
LM_ITEM.LOANED_GRYPHON_REINS = 44221
LM_ITEM.LOANED_WIND_RIDER_REINS = 44229
LM_ITEM.DRAGONWRATH_TARECGOSAS_REST = 71086
LM_ITEM.SHIMMERING_MOONSTONE = 101675
LM_ITEM.RATSTALLION_HARNESS = 139421
LM_ITEM.RUBY_QIRAJI_RESONATING_CRYSTAL = 151625
LM_ITEM.SAPPHIRE_QIRAJI_RESONATING_CRYSTAL = 151626

function LM_UnitAura(unit, aura, ...)
    if type(aura) == string then
        local i = 1
        while true do
            -- Is it faster to create and destroy a dict or call UnitAura twice?
            local name = UnitAura(unit, i, ...)
            if name == nil then
                return
            elseif name == aura then
                return UnitAura(unit, i, ...)
            else
                i = i + 1
            end
        end
    else
        return UnitAura(unit, aura, ...)
    end
end
