
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
  Addon:DebugIfOutput("spellButtonClicked", "Mount button clicked")
  
  button:SetAttribute"spell"
  button.id = nil
  
  local zone = Addon:GetZone()
  if zone and Addon:GetOption("zone", zone, "useZoneItem") then
    if zone == "Oculus" then -- Stop using a normal mount once I have the mount item in Oculus
      for key, id in pairs(Addon.items.Oculus) do
        if GetItemCount(id) > 0 then
          return
        end
      end
    end
  end
  
  
  if Addon:IsRidingMount() then
    Addon:DebugIfOutput("queueingDismount", "Queueing dismount")
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






local macroNeedsUpdate = true
local function ModifyButton()
  if InCombatLockdown() then return end
  if not macroNeedsUpdate and not Addon:DoesMountMacroNeedUpdate() then return end
  
  local macroText = Addon.MacroText()
  
  local travelLine      = Addon.Line"use"
  local extraTravelLine = Addon.Line"use"
  
  local baseConditional = Addon.Conditional"novehicleui"
  
  if Addon.MY_CLASS_NAME == "DRUID" and Addon:GetOption("class", "DRUID", "useForms") then
    if Addon:CanUseForm"AquaticForm" then
      local conditionals = Addon.Conditionals(baseConditional:Copy():Add("swimming", "nomounted"))
      travelLine:Add(conditionals, Addon.spellNames.AquaticForm)
    end
    if Addon:CanUseForm"TravelForm" then
      local conditionals = Addon.Conditionals()
      local conditional  = baseConditional:Copy():Add("outdoors", "nomounted")
      
      if not Addon:GetOption("behavior", "allowSlowMounts") then
        conditionals:Add(conditional:Copy():Add("swimming", "form:4"))
        conditional:Add("noswimming")
      end
      
      conditionals:Add(conditional:Copy():Add("flyable", "combat"), conditional:Add("noflyable"))
      travelLine:Add(conditionals, Addon.spellNames.TravelForm)
    end
    
    if Addon:IsFlyableRestricted() then
      -- this causes unsafe dismounting, even when autoDismountFlying cvar is off
      
      -- if IsSpellKnown(Addon.spells.SwiftFlightForm) then
      --   local conditionals = Addon.Conditionals(baseConditional:Copy():Add("form:6"))
      --   travelLine:Add(conditionals, Addon.spellNames.SwiftFlightForm)
      -- elseif IsSpellKnown(Addon.spells.FlightForm) then
      --   local conditionals = Addon.Conditionals(baseConditional:Copy():Add("form:6"))
      --   travelLine:Add(conditionals, Addon.spellNames.FlightForm)
      -- end
      if Addon:CanUseForm"TravelForm" then
        local conditionals = Addon.Conditionals()
        local conditional  = baseConditional:Copy():Add("outdoors", "flyable", "nocombat", "nomounted")
        
        if not Addon:GetOption("behavior", "allowSlowMounts") then
          conditionals:Add(conditional:Copy():Add("swimming", "form:4"))
          conditional:Add("noswimming")
        end
        
        conditionals:Add(conditional)
        travelLine:Add(conditionals, Addon.spellNames.TravelForm)
      end
    end
    if Addon:CanUseForm"SwiftFlightForm" then
      local conditionals = Addon.Conditionals(baseConditional:Copy():Add("outdoors", "flyable", "nocombat", "noswimming", "nomounted"))
      -- this causes unsafe dismounting, even when autoDismountFlying cvar is off
      -- conditional = conditional .. "[novehicleui,indoors,form:6][novehicleui,noflyable,form:6]"
      travelLine:Add(conditionals, Addon.spellNames.SwiftFlightForm)
    elseif Addon:CanUseForm"FlightForm" then
      local conditionals = Addon.Conditionals(baseConditional:Copy():Add("outdoors", "flyable", "nocombat", "noswimming", "nomounted"))
      -- this causes unsafe dismounting, even when autoDismountFlying cvar is off
      -- conditional = conditional .. "[novehicleui,indoors,form:6][novehicleui,noflyable,form:6]"
      travelLine:Add(conditionals, Addon.spellNames.FlightForm)
    end
    
    if Addon:CanUseForm"CatForm" and ({GetTalentInfo(2, 12)})[5] > 0 then -- Cat form has a speed boost
      local conditionals = Addon.Conditionals()
      local conditional  = baseConditional:Copy():Add("outdoors", "nomounted")
      
      if not Addon:GetOption("behavior", "allowSlowMounts") then
        conditionals:Add(conditional:Copy():Add("swimming", "form:3"))
        conditional:Add("noswimming")
      end
      
      conditionals:Add(conditional:Copy():Add("flyable", "combat"), conditional:Add("noflyable"))
      travelLine:Add(conditionals, Addon.spellNames.CatForm)
    end
    
  elseif Addon.MY_CLASS_NAME == "SHAMAN" then
    if Addon:CanUseForm"GhostWolf" then
      local conditionals = Addon.Conditionals()
      local conditional  = baseConditional:Copy():Add("outdoors", "nomounted")
      if ({GetTalentInfo(2, 3)})[5] ~= 2 and Addon:HasValidMounts() then -- shapeshift is not instant, and I can use a real mount
        conditional:Add("combat")
      end
      if not Addon:GetOption("behavior", "allowSlowMounts") then
        conditionals:Add(conditional:Copy():Add("swimming", "form"))
        conditional:Add("noswimming")
      end
      conditionals:Add(conditional)
      travelLine:Add(conditionals, Addon.spellNames.GhostWolf)
    end
  end
  
  local zone = Addon:GetZone()
  if zone and Addon:GetOption("zone", zone, "useZoneItem") then
    if zone == "Icecrown Citadel" then
      if GetItemCount(Addon.itemsByCategory[zone].GoblinRocketPack) > 0 then
        travelLine:Wipe()
      end
      
      local condition = Addon:GetOption("zone", zone, "atCursor") and "[@cursor]" or ""
      macroText:AddLine(Addon.Line("equip"):Add("item:" .. Addon.itemsByCategory[zone].GoblinRocketPack))
      macroText:AddLine(Addon.Line("use"):Add(condition, "item:" .. Addon.itemsByCategory[zone].GoblinRocketPack))
    elseif zone == "Oculus" then
      for key, id in pairs(Addon.items.Oculus) do
        macroText:AddLine(Addon.Line("use"):Add("item:" .. id))
      end
      macroText:AddLine"/run VehicleExit()"
    end
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
  
  macroNeedsUpdate = false
end

local function FlagForUpdate()
  macroNeedsUpdate = true
  ModifyButton()
end





Addon:RegisterEnableCallback(function(self)
  self:GetSpellButton(SPELL_BUTTON_NAME):SetScript("PreClick",  Mount)
  self:GetSpellButton(SPELL_BUTTON_NAME):SetScript("PostClick", PostMount)
  
  self:GetMacroButton(MACRO_BUTTON_NAME):SetScript("PreClick", ModifyButton)
  self:RegisterEventCallback("PLAYER_REGEN_DISABLED",          ModifyButton)
  
  
  self:RegisterEventCallback("ZONE_CHANGED",             FlagForUpdate) -- subzone changed
  self:RegisterEventCallback("ZONE_CHANGED_NEW_AREA",    FlagForUpdate) -- zone changed
  self:RegisterEventCallback("PLAYER_TALENT_UPDATE",     FlagForUpdate) -- relevant for some travel forms
  self:RegisterEventCallback("BAG_UPDATE_DELAYED",       FlagForUpdate) -- used for zone-specific items
  self:RegisterEventCallback("PLAYER_EQUIPMENT_CHANGED", FlagForUpdate) -- used for zone-specific items
  self:RegisterEventCallback("UNIT_AURA", function(self, e, unitID)
    if unitID == "player" then
      FlagForUpdate()
    end
  end) -- used for auras that block mounting
  
  -- Just in case, run as soon as possible upon login
  self:OnCombatEnd(ModifyButton)
  
end)




