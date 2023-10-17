
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)






local BUTTON_NAME = "ZKM"





--[[
Mounting model


if druid
  if I intend to shapeshift then
    cancelaura all shapeshift forms which cannot be used for speed

if in oculus
  use oculus mount
otherwise and if not in combat and not in shapeshift form
  (lua)
  if can't mount or already riding one
    if a druid
      queue a dismount
    otherwise
      dismount
  otherwise
    use the mount (unless I'm moving or am a druid with equal speed flying form)

dismount if in combat

if a druid
  use a shapeshift form

if a druid and dismounting is queued
  dismount


--]]




local dismountQueued = false
local function QueueDismount()
  dismountQueued = true
end
local function DismountIfQueued()
  Dismount()
  dismountQueued = false
end

function Addon:Mount()
  if InCombatLockdown() then return end
  if Addon.shapeshiftFormIDs[GetShapeshiftFormID() or 0] then return end -- mounting through lua doesn't cancel shapeshift forms
  
  -- Stop using a normal mount once I have the mount item in Oculus
  if C_Map.GetBestMapForUnit"player" == Addon.zones.Oculus then
    for key, id in pairs(Addon.items.Oculus) do
      if GetItemCount(id) > 0 then
        return
      end
    end
  end
  
  
  if self:IsRidingMount() then
    QueueDismount()
  end
  if self:HasValidMounts() and not self:IsRidingIdealMount() then
    if GetUnitSpeed"player" ~= 0 then return end
    C_MountJournal.SummonByID(self:SelectMount())
  end
end

function Addon:DismountIfQueued()
  if InCombatLockdown() then return end
  DismountIfQueued()
end




local macroInitialized = false

local function ModifyMountButton()
  if InCombatLockdown() then return end
  if macroInitialized and not Addon:DoesMountMacroNeedUpdate() then return end
  
  local macroText = Addon.MacroText()
  
  local travelLine = Addon.Line"use"
  
  if Addon.MY_CLASS_NAME == "DRUID" then
    local options = ""
    
    if IsSpellKnown(Addon.spells.AquaticForm) then
      local condition = "[novehicleui,swimming,nomounted]"
      travelLine:Add(condition, Addon.spellNames.AquaticForm)
      options = options .. condition
    end
    if IsSpellKnown(Addon.spells.TravelForm) then
      local condition = "[novehicleui,outdoors,noflyable,noswimming,nomounted]"
      travelLine:Add(condition, Addon.spellNames.TravelForm)
      options = options .. condition
    end
    
    if IsSpellKnown(Addon.spells.SwiftFlightForm) then
      local condition = "[novehicleui,outdoors,flyable,nocombat,noswimming,nomounted]"
      travelLine:Add(condition, Addon.spellNames.SwiftFlightForm)
      options = options .. condition
    elseif IsSpellKnown(Addon.spells.FlightForm) then
      local condition = "[novehicleui,outdoors,flyable,nocombat,noswimming,nomounted]"
      travelLine:Add(condition, Addon.spellNames.FlightForm)
      options = options .. condition
    end
    
    if IsSpellKnown(Addon.spells.CatForm) and ({GetTalentInfo(2, 12)})[5] > 0 then -- Cat form has a speed boost
      local condition = "[novehicleui,noflyable,noswimming,nomounted]"
      travelLine:Add(condition, Addon.spellNames.CatForm)
      options = options .. condition
    end
    
    if travelLine:IsComplete() then
      for aura in pairs(Addon.spellsByCategory.druidForms.nonMounts) do
        macroText:AddLine(Addon.Line("cancelaura"):Add(options, Addon.spellNames[aura]))
      end
    end
    
  elseif Addon.MY_CLASS_NAME == "SHAMAN" then
    local options = ""
    
    if IsSpellKnown(Addon.spells.GhostWolf) then
      local condition
      if Addon:HasValidMounts() then
        condition = "[novehicleui,combat,outdoors,nomounted]"
      else
        condition = "[novehicleui,outdoors,nomounted]"
      end
      options = options .. condition
      travelLine:Add(condition, Addon.spellNames.GhostWolf)
    end
    
    if travelLine:IsComplete() then
      for aura in pairs(Addon.spellsByCategory.shamanForms) do
        macroText:AddLine(Addon.Line("cancelaura"):Add(options, Addon.spellNames[aura]))
      end
    end
  end
  
  local map = C_Map.GetBestMapForUnit"player"
  if map == Addon.zones.IcecrownCitadel then
    macroText:AddLine("/use [@cursor]Goblin Rocket Pack")
  elseif map == Addon.zones.Oculus then
    for key, id in pairs(Addon.items.Oculus) do
      macroText:AddLine(Addon.Line("use"):Add("item:" .. id))
    end
    macroText:AddLine"/run VehicleExit()"
  end
  
  macroText:AddLine("/run " .. ADDON_NAME .. ":Mount()")
  
  
  if travelLine:IsComplete() then
    macroText:AddLine(travelLine)
  end
  
  macroText:AddLine"/dismount [combat]"
  
  macroText:AddLine("/run " .. ADDON_NAME .. ":DismountIfQueued()")
  
  if Addon:GetGlobalOption("debugOutput", "macroTextChanged") then
    Addon:Debugf("|cff00ccffMount macro updated. Lines: %d, Length: %d|r", #macroText:GetLines(), macroText:GetLength())
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





