
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)






local MACRO_BUTTON_NAME = "ZKM"
local SPELL_BUTTON_NAME = MACRO_BUTTON_NAME .. "_SPELL"





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

local function Mount(button)
  if InCombatLockdown() then return end
  
  button:SetAttribute"spell"
  button.id = nil
  
  -- Stop using a normal mount once I have the mount item in Oculus
  if Addon:GetZone() == "Oculus" then
    for key, id in pairs(Addon.items.Oculus) do
      if GetItemCount(id) > 0 then
        return
      end
    end
  end
  
  
  if Addon:IsRidingMount() then
    QueueDismount()
  end
  if Addon:HasValidMounts() and not Addon:IsRidingIdealMount() then
    if GetUnitSpeed"player" ~= 0 then return end
    
    local mountID = Addon:SelectMount()
    button.id = mountID
    local _, spellID = C_MountJournal.GetMountInfoByID(mountID)
    local name = Addon.spellNames[spellID]
    
    button:SetAttribute("spell", name)
    return
  end
end
local function PostMount(button)
  local id = button.id
  if id then
    Addon:SetLastMount(id)
  end
end

function Addon:DismountIfQueued()
  if InCombatLockdown() then return end
  DismountIfQueued()
end






local init = true
local function ModifyButton()
  if InCombatLockdown() then return end
  if not init and not Addon:DoesMountMacroNeedUpdate() then return end
  
  local macroText = Addon.MacroText()
  
  local travelLine      = Addon.Line"use"
  local extraTravelLine = Addon.Line"use"
  
  if Addon.MY_CLASS_NAME == "DRUID" then
    local options = ""
    
    if IsSpellKnown(Addon.spells.AquaticForm) then
      local condition = "[novehicleui,swimming,nomounted]"
      travelLine:Add(condition, Addon.spellNames.AquaticForm)
      options = options .. condition
    end
    if IsSpellKnown(Addon.spells.TravelForm) then
      local condition = "[novehicleui,outdoors,noflyable,noswimming,nomounted][novehicleui,outdoors,flyable,combat,noswimming,nomounted]"
      travelLine:Add(condition, Addon.spellNames.TravelForm)
      options = options .. condition
    end
    
    if Addon:IsFlyableRestricted() then
      -- if IsSpellKnown(Addon.spells.SwiftFlightForm) then
      --   local condition = "[novehicleui,form:6]"
      --   travelLine:Add(condition, Addon.spellNames.SwiftFlightForm)
      --   options = options .. condition
      -- elseif IsSpellKnown(Addon.spells.FlightForm) then
      --   local condition = "[novehicleui,form:6]"
      --   travelLine:Add(condition, Addon.spellNames.FlightForm)
      --   options = options .. condition
      -- end
      if IsSpellKnown(Addon.spells.TravelForm) then
        local condition = "[novehicleui,outdoors,flyable,nocombat,noswimming,nomounted]"
        travelLine:Add(condition, Addon.spellNames.TravelForm)
        options = options .. condition
      end
    end
    if IsSpellKnown(Addon.spells.SwiftFlightForm) then
      local condition = "[novehicleui,outdoors,flyable,nocombat,noswimming,nomounted][novehicleui,indoors,form:6][novehicleui,noflyable,form:6]"
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
        -- macroText:AddLine(Addon.Line("cancelaura"):Add(options, Addon.spellNames[aura]))
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
        -- macroText:AddLine(Addon.Line("cancelaura"):Add(options, Addon.spellNames[aura]))
      end
    end
  end
  
  local zone = Addon:GetZone()
  if zone == "Icecrown Citadel" then
    macroText:AddLine("/use [@cursor]Goblin Rocket Pack")
  elseif zone == "Oculus" then
    for key, id in pairs(Addon.items.Oculus) do
      macroText:AddLine(Addon.Line("use"):Add("item:" .. id))
    end
    macroText:AddLine"/run VehicleExit()"
  end
  
  if travelLine:IsComplete() then
    macroText:AddLine(Addon.Line("run", ADDON_NAME .. ":BlockUIErrors()"))
  end
  macroText:AddLine(Addon.Line("click", SPELL_BUTTON_NAME))
  
  
  if travelLine:IsComplete() then
    macroText:AddLine(travelLine)
    if extraTravelLine:IsComplete() then
      macroText:AddLine(extraTravelLine)
    end
    macroText:AddLine(Addon.Line("run", ADDON_NAME .. ":AllowUIErrors()"))
  end
  
  macroText:AddLine"/dismount [combat]"
  
  macroText:AddLine("/run " .. ADDON_NAME .. ":DismountIfQueued()")
  
  if Addon:GetGlobalOption("debugOutput", "macroTextChanged") then
    Addon:Debugf("|cff00ccffMount macro updated. Lines: %d, Length: %d|r", #macroText:GetLines(), macroText:GetLength())
    for _, line in ipairs(macroText:GetLines()) do
      Addon:Debug(line)
    end
  end
  macroText:Apply(MACRO_BUTTON_NAME)
  
  init = false
end







Addon:RegisterEnableCallback(function(self)
  self:GetSpellButton(SPELL_BUTTON_NAME):SetScript("PreClick",  Mount)
  self:GetSpellButton(SPELL_BUTTON_NAME):SetScript("PostClick", PostMount)
  
  self:GetMacroButton(MACRO_BUTTON_NAME):SetScript("PreClick", ModifyButton)
  
  Addon:OnCombatEnd(function(self)
    self:GetMacroButton(MACRO_BUTTON_NAME):SetAttribute("macrotext",  "/click " .. self:GetMacroButtonName(MACRO_BUTTON_NAME, n))
    ModifyButton()
  end)
end)




