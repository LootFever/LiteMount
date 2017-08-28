--[[----------------------------------------------------------------------------

  LiteMount/Actions.lua

  Mounting actions.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

--[[------------------------------------------------------------------------]]--

local ACTIONS = { }

ACTIONS['Spell'] =
    function (spellID)
        local name = GetSpellInfo(spellID)
        LM_Debug("Setting action to " .. name .. ".")
        return LM_SecureAction:Spell(name)
    end

-- In vehicle -> exit it
ACTIONS['LeaveVehicle'] =
    function ()
        if not CanExitVehicle() then return end

        LM_Debug("Setting action to VehicleExit.")
        return LM_SecureAction:Macro(SLASH_LEAVEVEHICLE1)
    end

-- Mounted -> dismount
ACTIONS['Dismount'] =
    function ()
        if not IsMounted() then return end

        LM_Debug("Setting action to Dismount.")
        return LM_SecureAction:Macro(SLASH_DISMOUNT1)
    end

-- Only cancel forms that we will activate (mount-style ones).
-- See: http://wowprogramming.com/docs/api/GetShapeshiftFormID
ACTIONS['CancelForm'] =
    function ()
        local formIndex = GetShapeshiftForm()
        if formIndex == 0 then return end

        local form = LM_PlayerMounts:GetMountByShapeshiftForm(formIndex)
        if not form or LM_Options:IsExcludedMount(form) then return end

        LM_Debug("Setting action to CancelForm.")
        return LM_SecureAction:Macro(SLASH_CANCELFORM1)
    end

-- Got a player target, try copying their mount
ACTIONS['CopyTargetsMount'] =
    function ()
        if LM_Options.db.char.copyTargetsMount and UnitIsPlayer("target") then
            LM_Debug("Trying to clone target's mount")
            return LM_PlayerMounts:GetMountFromUnitAura("target")
        end
    end

ACTIONS['Vashjir'] =
    function ()
        if IsSubmerged() and LM_Location:IsVashjir() then
            LM_Debug("Trying Vashjir Mount")
            return LM_PlayerMounts:GetRandomMount({ 'VASHJIR' })
        end
    end

ACTIONS['Mount'] =
    function (filters)
        return ACTIONS.Swim(filters) or
               ACTIONS.Fly(filters) or
               ACTIONS.Float(filters) or
               ACTIONS.Run(filters) or
               ACTIONS.Walk(filters) or
               LM_PlayerMounts:GetRandomMount({ unpack(filters) })
    end

ACTIONS['Fly'] =
    function (filters)
        if LM_Location:CanFly() then
            LM_Debug("Trying Flying Mount")
            return LM_PlayerMounts:GetRandomMount({ 'FLY', unpack(filters) })
        end
    end

ACTIONS['Float'] =
    function (filters)
        if LM_Location:IsFloating() then
            LM_Debug("Trying Floating mount")
            return LM_PlayerMounts:GetRandomMount({ 'FLOAT', unpack(filters) })
        end
    end

ACTIONS['Swim'] =
    function (filters)
        if IsSubmerged() and not LM_Location:IsFloating() then
            LM_Debug("Trying Swimming Mount")
            return LM_PlayerMounts:GetRandomMount({ 'SWIM', unpack(filters) })
        end
    end

ACTIONS['Run'] =
    function (filters)
        LM_Debug("Trying Running Mount")
        return LM_PlayerMounts:GetRandomMount({ 'RUN', unpack(filters) })
    end

ACTIONS['Walk'] =
    function (filters)
        LM_Debug("Trying Walking Mount")
        return LM_PlayerMounts:GetRandomMount({ 'WALK', unpack(filters) })
    end

ACTIONS['Macro'] =
    function ()
        if LM_Options.db.char.useUnavailableMacro then
            LM_Debug("Using custom macro.")
            return LM_SecureAction:Macro(LM_Options.db.char.unavailableMacro)
        end
    end

ACTIONS['CantMount'] =
    function ()
        -- This isn't a great message, but there isn't a better one that
        -- Blizzard have already localized. See FrameXML/GlobalStrings.lua.
        -- LM_Warning("You don't know any mounts you can use right now.")
        LM_Warning(SPELL_FAILED_NO_MOUNTS_ALLOWED)

        LM_Debug("Setting action to can't mount now.")
        return LM_SecureAction:Macro("")
    end

ACTIONS['Combat'] =
    function ()
        LM_Debug("Setting action to in-combat action.")

        if LM_Options.db.char.useCombatMacro then
            return LM_SecureAction:Macro(LM_Options.db.char.combatMacro)
        else
            return LM_SecureAction:Macro(LM_Actions:DefaultCombatMacro())
        end
    end

LM_Actions = { }

local function GetDruidMountForms()
    local forms = {}
    for i = 1,GetNumShapeshiftForms() do
        local spell = select(5, GetShapeshiftFormInfo(i))
        if spell == LM_SPELL.FLIGHT_FORM or spell == LM_SPELL.TRAVEL_FORM then
            tinsert(forms, i)
        end
    end
    return table.concat(forms, "/")
end

-- This is the macro that gets set as the default and will trigger if
-- we are in combat.  Don't put anything in here that isn't specifically
-- combat-only, because out of combat we've got proper code available.
-- Note that macros are limited to 255 chars, even inside a SecureActionButton.

function LM_Actions:DefaultCombatMacro()

    local mt = "/dismount [mounted]\n"

    local playerClass = select(2, UnitClass("player"))

    if playerClass ==  "DRUID" then
        local forms = GetDruidMountForms()
        local mount = LM_PlayerMounts:GetMountBySpell(LM_SPELL.TRAVEL_FORM)
        if mount and not LM_Options:IsExcludedMount(mount) then
            mt = mt .. format("/cast [noform:%s] %s\n", forms, mount.name)
            mt = mt .. format("/cancelform [form:%s]\n", forms)
        end
    elseif playerClass == "SHAMAN" then
        local mount = LM_PlayerMounts:GetMountBySpell(LM_SPELL.GHOST_WOLF)
        if mount and not LM_Options:IsExcludedMount(mount) then
            local s = GetSpellInfo(LM_SPELL.GHOST_WOLF)
            mt = mt .. "/cast [noform] " .. s .. "\n"
            mt = mt .. "/cancelform [form]\n"
        end
    end

    mt = mt .. "/leavevehicle\n"

    return mt
end

function LM_Actions:GetHandler(action)
    return ACTIONS[action]
end