--[[----------------------------------------------------------------------------

  LiteMount/PlayerMounts.lua

  Information on all your mounts.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_PlayerMounts = LM_CreateAutoEventFrame("Frame", "LM_PlayerMounts", UIParent)

local Broken71MountSpells = {
    213158,         -- Predatory Bloodgazer
    213163,         -- Snowfeather Hunter
    213164,         -- Brilliant Direbeak
    213165,         -- Viridian Sharptalon
}

local RescanEvents = {
    -- Companion change. Don't add COMPANION_UPDATE to this as it fires
    -- for units other than "player" and triggers constantly.
    "COMPANION_LEARNED", "COMPANION_UNLEARNED",
    -- Talents (might have mount abilities). Glyphs that teach spells
    -- fire PLAYER_TALENT_UPDATE too, don't need to watch GLYPH_ events.
    "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_LEVEL_UP", "PLAYER_TALENT_UPDATE",
    -- You might have received a mount item (e.g., Magic Broom).
    "BAG_UPDATE",
    -- Draenor flying is an achievement
    "ACHIEVEMENT_EARNED",
}

function LM_PlayerMounts:Initialize()
    -- Delayed scanning stops us rescanning unnecessarily.
    self.needScan = true

    self.byName = { }
    self.list = LM_MountList:New()

    -- Rescan event setup
    for _,ev in ipairs(RescanEvents) do
        self[ev] = function (self, event, ...)
                            LM_Debug("Got rescan event "..event)
                            self.needScan = true
                        end
        self:RegisterEvent(ev)
    end
end

function LM_PlayerMounts:AddMount(m)
    if m and not self.byName[m:Name()] then
        self.byName[m:Name()] = m
        tinsert(self.list, m)
    end
end

function LM_PlayerMounts:AddJournalMounts()
    for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
        local m = LM_Mount:Get("Journal", mountID)
        self:AddMount(m)
    end
end

-- The unpack function turns a table into a list. I.e.,
--      unpack({ a, b, c }) == a, b, c
function LM_PlayerMounts:AddSpellMounts()
    for _,typeAndArgs in ipairs(LM_MOUNT_SPELLS) do
        local m = LM_Mount:Get(unpack(typeAndArgs))
        self:AddMount(m)
    end
end

function LM_PlayerMounts:ScanMounts()
    if not self.needScan then return end
    LM_Debug("Rescanning list of mounts.")

    self.needScan = nil
    wipe(self.byName)
    wipe(self.list)

    self:AddJournalMounts()
    self:AddSpellMounts()

    for m in self.list:Iterate() do
        LM_Options:SeenMount(m, true)
    end

    LM_Debug("Finished rescan.")
end

function LM_PlayerMounts:Iterate()
    return self.list:Iterate()
end

function LM_PlayerMounts:Search(matchfunc)
    return self.list:Search(matchfunc)
end

function LM_PlayerMounts:GetAllMounts()
    local function match() return true end
    return self:Search(match)
end

function LM_PlayerMounts:GetAvailableMounts(flags)
    local function match(m)
        if not m:CurrentFlagsSet(flags) then return end
        if not m:IsUsable() then return end
        if LM_Options:IsExcludedMount(m) then return end
        if tContains(Broken71MountSpells, m:SpellID()) then return end
        return true
    end

    return self:Search(match)
end

function LM_PlayerMounts:GetMountFromUnitAura(unitid)
    for i = 1,BUFF_MAX_DISPLAY do
        local m = self:GetMountByName(UnitAura(unitid, i))
        if m and m:IsUsable() then return m end
    end
end

function LM_PlayerMounts:GetMountByName(name)
    return self.byName[name]
end

function LM_PlayerMounts:GetMountBySpell(id)
    local name = GetSpellInfo(id)
    if name then return self:GetMountByName(name) end
end

-- For some reason GetShapeshiftFormInfo doesn't work on Ghost Wolf.
function LM_PlayerMounts:GetMountByShapeshiftForm(i)
    if not i then return end
    local class = select(2, UnitClass("player"))
    if class == "SHAMAN" and i == 1 then
         return self:GetMountBySpell(LM_SPELL_GHOST_WOLF)
    end
    local name = select(2, GetShapeshiftFormInfo(i))
    if name then return self:GetMountByName(name) end
end

function LM_PlayerMounts:GetRandomMount(flags)
    local poss = self:GetAvailableMounts(flags)
    return poss:Random()
end

function LM_PlayerMounts:Dump()
    for m in self.list:Iterate() do
        m:Dump()
    end
end
