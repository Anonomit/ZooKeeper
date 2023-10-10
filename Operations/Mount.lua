
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)






local BUTTON_NAME = "ZKM"















local dismountQueued = false

function Addon:Mount()
  if InCombatLockdown() then return end
  if GetShapeshiftFormID() then return end
  
  if not self:HasValidMounts() or self:IsRidingValidMount() then
    if self.MY_CLASS_NAME == "DRUID" then
      dismountQueued = true
    else
      Dismount()
    end
  else
    if GetUnitSpeed"player" ~= 0 then return end
    C_MountJournal.SummonByID(self:SelectMount())
  end
end

function Addon:DismountIfQueued()
  if InCombatLockdown() then return end
  if dismountQueued then
    Dismount()
    dismountQueued = false
  end
end




local macroInitialized = false

local function ModifyMountButton()
  if InCombatLockdown() then return end
  if macroInitialized and not Addon:DoesMountMacroNeedUpdate() then return end
  
  local macroText = Addon.MacroText()
  
  local travelLine
  
  if UnitClassBase"player" == "DRUID" then
    travelLine = Addon.Line"use"
    
    local options = ""
    
    if IsSpellKnown(Addon.spells.AquaticForm) then
      local condition = "[swimming,nomounted]"
      travelLine:Add(condition, Addon.spellNames.AquaticForm)
      options = options .. condition
    end
    if IsSpellKnown(Addon.spells.TravelForm) then
      local condition = "[outdoors,noflyable,noswimming,nomounted]"
      travelLine:Add(condition, Addon.spellNames.TravelForm)
      options = options .. condition
    end
    
    if IsSpellKnown(Addon.spells.SwiftFlightForm) then
      local condition = "[outdoors,flyable,nocombat,noswimming,nomounted]"
      travelLine:Add(condition, Addon.spellNames.SwiftFlightForm)
      options = options .. condition
    elseif IsSpellKnown(Addon.spells.FlightForm) then
      local condition = "[outdoors,flyable,nocombat,noswimming,nomounted]"
      travelLine:Add(condition, Addon.spellNames.FlightForm)
      options = options .. condition
    end
    
    if travelLine:IsComplete() then
      for aura in pairs(Addon.aurasToCancel) do
        macroText:AddLine(Addon.Line("cancelaura"):Add(options, Addon.spellNames[aura]))
      end
    end
  end
  
  if C_Map.GetBestMapForUnit"player" == Addon.zones.Oculus then
    for _, key in ipairs{"EmeraldEssence", "AmberEssence", "RubyEssence"} do
      macroText:AddLine(Addon.Line("use"):Add("item:" .. Addon.items[key]))
      macroText:AddLine(Addon.Line("cancelaura"):Add(Addon.spellNames[key]))
    end
  else
    macroText:AddLine("/run " .. ADDON_NAME .. ":Mount()")
    macroText:AddLine"/dismount [combat]"
  end
  
  
  macroText:AddDruidLine(travelLine)
  
  macroText:AddLine("/run " .. ADDON_NAME .. ":DismountIfQueued()")
  
  if Addon:GetGlobalOption("debugOutput", "macroTextChanged") then
    Addon:Debugf("Mount macro updated. Lines: %d, Length: %d", #macroText:GetLines(), macroText:GetLength())
    for _, line in ipairs(macroText:GetLines()) do
      Addon:Debug(line)
    end
  end
  macroText:Apply(BUTTON_NAME)
end



function Addon:InitMountButton()
  local mountButton = CreateFrame("Button", BUTTON_NAME, UIParent, "SecureActionButtonTemplate")
  mountButton:SetAttribute("type1", "macro")
  mountButton:SetScript("PreClick",  ModifyMountButton)
  -- mountButton:SetScript("PostClick", ModifyMountButton)
  mountButton:SetAttribute("macrotext1", "/click " .. self:GetMacroButtonName(BUTTON_NAME, n))
  ModifyMountButton()
  macroInitialized = true
end





