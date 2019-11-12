local addonName, PowerShiftConsumable = ...;

local EventHandler = CreateFrame("Frame");
EventHandler:RegisterEvent("ADDON_LOADED");
EventHandler:RegisterEvent("UPDATE_BINDINGS");

EventHandler:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        PowerShiftConsumable:OnAddonLoaded(...);
    elseif event == "UPDATE_BINDINGS" then
        PowerShiftConsumable:OnUpdateBindings(...);
    end
end);

PowerShiftConsumableBarsToModify = PowerShiftConsumableBarsToModify or {
    MultiBarBottomLeft = {
        binding = "MULTIACTIONBAR1BUTTON",
        click = "MultiBarBottomLeftButton",
        buttons = {},
    },
    MultiBarBottomRight = {
        binding = "MULTIACTIONBAR2BUTTON",
        click = "MultiBarBottomRightButton",
        buttons = {},
    },
    MultiBarRight = {
        binding = "MULTIACTIONBAR3BUTTON",
        click = "MultiBarRightButton",
        buttons = {},
    },
    MultiBarLeft = { -- aka multibarright2
        binding = "MULTIACTIONBAR4BUTTON",
        click = "MultiBarLeftButton",
        buttons = {},
    },
}

function PowerShiftConsumable:OnUpdateBindings()
    if not self.state then
        return;
    end
    ClearOverrideBindings(self.state);
    for _,button in pairs(self.btn) do
        local key1, key2 = GetBindingKey(button:GetAttribute("binding"));
        local name = button:GetName();
        if key1 then
            SetOverrideBindingClick(self.state, true, key1, name);
        end
        if key2 then
            SetOverrideBindingClick(self.state, true, key2, name);
        end
    end
end

function PowerShiftConsumable:OnAddonLoaded(name)
    if name ~= addonName then return; end
    self.state = CreateFrame("Frame", "PowerShiftConsumableStateHandler", UIParent, "SecureHandlerStateTemplate")
    self.btn = {};
    local i = 0;
    for _,tbl in pairs(PowerShiftConsumableBarsToModify) do
        for key_ind=1,12 do
            if tbl.buttons[key_ind] then
                i = i + 1;
                self.btn[i] = CreateFrame("Button", "PowerShiftConsumableButton_"..i, self.state, "SecureActionButtonTemplate");
                -- so we can access the buttons when form changes
                self.state:SetFrameRef("btn"..i, self.btn[i]);

                self.btn[i]:SetAttribute("type", "macro");
                -- name of the clickable button
                self.btn[i]:SetAttribute("button", tbl.click .. key_ind);
                -- keybinding name
                self.btn[i]:SetAttribute("binding", tbl.binding .. key_ind);
            end
        end
    end
    --args: self, stateid, newstate
    self.state:SetAttribute("_onstate-formstate", [[
local i=1;
local ref = self:GetFrameRef("btn"..i);
while ref do
    local macro_hdr = "";
    local macro_ftr = "";
    if newstate == "bear" then
        macro_hdr = "/cancelaura Predatory Strikes\n/cancelaura Leader of the Pack\n/cancelform\n";
        macro_ftr = "/cast Dire Bear Form"
    elseif newstate == "cat" then
        macro_hdr = "/cancelaura Predatory Strikes\n/cancelaura Leader of the Pack\n/cancelform\n";
        macro_ftr = "/cast Cat Form"
    elseif newstate == "travel" then
        macro_hdr = "/cancelform\n";
        macro_ftr = "/cast [noswimming] Travel Form; Aquatic Form"
    end
    ref:SetAttribute("macrotext", string.format("%s/click %s\n%s",macro_hdr,ref:GetAttribute("button"),macro_ftr));
    i = i + 1;
    ref = self:GetFrameRef("btn"..i);
end
    ]])
    RegisterStateDriver(self.state, "formstate", "[form:1]bear;[form:3]cat;[form:2/4]travel;[]caster");
    self:OnUpdateBindings();
end

function PowerShiftConsumable:SlashState(enable,args)
    local bar,rest = args:match("^%s*(%S*)%s*(.-)$");
    local tbl = PowerShiftConsumableBarsToModify[bar]
    if not tbl then return string.format("ERROR: '%s' is not a valid bar.",bar); end
    if rest == "" then
        for key=1,12 do
            tbl.buttons[key] = enable;
        end
    else
        for match in rest:gmatch("(%d+)") do
            local key = tonumber(match);
            if 1 <= key and key <= 12 then
                tbl.buttons[key] = enable;
            end
        end
    end
    return "Changed states."
end

function PowerShiftConsumable:SlashStatus()
    for bar,tbl in pairs(PowerShiftConsumableBarsToModify) do
        local msg = bar;
        for ind=1,12 do
            if PowerShiftConsumableBarsToModify[bar].buttons[ind] then
                msg = msg .. " " .. ind;
            end
        end
        print("Enabled", msg);
    end
    return "Status message."
end

function PowerShiftConsumable:SlashHelp(verbose)
    if verbose then
        barNames = ""
        for bar_name,_ in pairs(PowerShiftConsumableBarsToModify) do
            barNames = barNames .. " " .. bar_name;
        end
        print("/pow (enable||disable) BARNAME [n1 n2 ...]");
        print("    enables/disables given bar");
        print("    where BARNAME is one of",barNames);
        print("    and [n1 n2 ...] is an optional list of numbers ranging from 1 to 12, to enable/disable specific keys.")
        print("/pow status")
        print("    prints which keys are enabled")
        return "Help message."
    else
        return "Usage: /pow (enable||disable||status||help)"
    end
end

local function SlashCommands(msg)
    local cmd,rest = msg:match("^%s*(%S*)%s*(.-)$");
    local msg = "";
    cmd = strlower(cmd);
    if cmd == "enable" then
        msg = PowerShiftConsumable:SlashState(true,rest);
    elseif cmd == "disable" then
        msg = PowerShiftConsumable:SlashState(false,rest);
    elseif cmd == "status" then
        msg = PowerShiftConsumable:SlashStatus()
    else
        msg = PowerShiftConsumable:SlashHelp((cmd == "help"))
    end
    print("|cffff7c0aPowerShiftConsumable|r", msg);
end
SLASH_POWSHIFTCONS_SLASHCMD1 = '/pow';
SLASH_POWSHIFTCONS_SLASHCMD2 = '/powershiftconsumable';
SlashCmdList['POWSHIFTCONS_SLASHCMD'] = SlashCommands;
