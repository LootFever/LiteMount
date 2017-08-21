--[[----------------------------------------------------------------------------

  LiteMount/Advanced.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

function LiteMountOptionsAdvanced_OnLoad(self)
    self.name = ADVANCED_OPTIONS

    self.EditBox.ntabs = 4

    UIDropDownMenu_Initialize(self.BindingDropDown, LiteMountOptionsAdvancedBindingDropDown_Initialize)
    UIDropDownMenu_SetText(self.BindingDropDown, BindingText(1))
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsAdvancedBindingDropDown_Initialize(dropDown, level)
    local info = UIDropDownMenu_CreateInfo()

    if level == 1 then
        for i = 1,4 do
            info.text = BindingText(i)
            info.arg1 = i
            info.arg2 = BindingText(i)
            info.func = function (button, v, t)
                    LiteMountOptionsControl_SetTab(LiteMountOptionsAdvanced.EditBox, v)
                    UIDropDownMenu_SetText(dropDown, t)
                end
            info.checked = (LiteMountOptionsAdvanced.currentButtonIndex == i)
            UIDropDownMenu_AddButton(info, level)
        end
    end
end