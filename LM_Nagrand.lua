--[[----------------------------------------------------------------------------

  LiteMount/LM_Nagrand.lua

  Nagrand mounts, Telaari Talbuk and Frostwolf War Wolf.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_Nagrand = setmetatable({ }, LM_Spell)
LM_Nagrand.__index = LM_Nagrand

local FactionRequirements = {
    [LM_SPELL_FROSTWOLF_WAR_WOLF] = "Horde",
    [LM_SPELL_TELAARI_TALBUK] = "Alliance",
}


function LM_Nagrand:Flags(f)
    return LM_FLAG_BIT_NAGRAND
end

function LM_Nagrand:Get(spellID)
    local m

    if HasDraenorZoneAbility and HasDraenorZoneAbility() then
        m = LM_Spell:Get(spellID, true)
    end

    if m then
        setmetatable(m, LM_Nagrand)
        m:NeedsFaction(FactionRequirements[spellID])
    end

    return m
end

-- Draenor Ability spells are weird.  The name of the Garrison Ability
-- (localized) is name = GetSpellInfo(DraenorZoneAbilitySpellID).
-- But, GetSpellInfo(name) returns the actual current spell that's active.
function LM_Nagrand:IsUsable()
    local DraenorZoneAbilityName = GetSpellInfo(DraenorZoneAbilitySpellID)
    local id = select(7, GetSpellInfo(DraenorZoneAbilityName))
    if id ~= self:SpellID() then return false end
    if not IsUsableSpell(DraenorZoneAbilitySpellID) then return false end
    return LM_Mount.IsUsable(self)
end
