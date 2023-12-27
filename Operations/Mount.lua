
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)






local MACRO_BUTTON_NAME = "ZKM"
local SPELL_BUTTON_NAME = MACRO_BUTTON_NAME .. "_SPELL"








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
  button:SetAttribute"item"
  button.id = nil
  
  if Addon:ShouldZoneItemBlockMounting() then
    return
  end
  
  
  if Addon:IsRidingMount() then
    Addon:DebugIfOutput("queueingDismount", "Queueing dismount")
    QueueDismount()
  end
  if Addon:HasValidMounts() and (Addon:GetOption("behavior", "alwaysDismount") and not Addon:IsRidingMount() or not Addon:GetOption("behavior", "alwaysDismount") and not Addon:IsRidingIdealMount()) then
    if GetUnitSpeed"player" ~= 0 then return end
    
    if Addon.expansionLevel < Addon.expansions.wrath then
      local spellID, itemID = Addon:SelectMount()
      button.id = spellID
      if itemID then
        button:SetAttribute("type", "item")
        button:SetAttribute("item", "item:" .. itemID)
      else
        button:SetAttribute("type", "spell")
        button:SetAttribute("spell", Addon.spellNames[spellID])
      end
    else
      local mountID = Addon:SelectMount()
      button.id = mountID
      local _, spellID = C_MountJournal.GetMountInfoByID(mountID)
      local name = Addon.spellNames[spellID]
      
      button:SetAttribute("spell", name)
    end
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



local function AddAuraLines(macroText)
  local auraLine = Addon.Line"use"
  
  local baseConditional = Addon.Conditional"novehicleui"
  
  if Addon:GetOption("class", Addon.MY_CLASS_FILENAME, "useForms") then
    Addon:Switch(Addon.MY_CLASS_FILENAME, {
      PALADIN = function()
        if Addon:CanUseForm"CrusaderAura" and Addon:HasValidMounts() then
          local conditionals = Addon.Conditionals()
          local conditional  = baseConditional:Copy():Add("outdoors", "nomounted", "nocombat", "noform:7")
          
          conditionals:Add(conditional)
          auraLine:Add(conditionals, Addon.spellNames.CrusaderAura)
          macroText:AddLine(auraLine)
        end
      end,
    })
  end
end


local function MakeTravelLine()
  local travelLine = Addon.Line"use"
  
  local baseConditional = Addon.Conditional("novehicleui", "nomounted")
  
  if Addon:GetOption("class", Addon.MY_CLASS_FILENAME, "useForms") then
    Addon:Switch(Addon.MY_CLASS_FILENAME, {
      DRUID = function()
        if Addon:CanUseForm"AquaticForm" then
          local conditionals = Addon.Conditionals(baseConditional:Copy():Add("swimming"))
          travelLine:Add(conditionals, Addon.spellNames.AquaticForm)
        end
        
        -- if Addon:IsFlyableRestricted() then
        --   -- this causes unsafe dismounting, even when autoDismountFlying cvar is off
          
        --   -- if IsSpellKnown(Addon.spells.SwiftFlightForm) then
        --   --   local conditionals = Addon.Conditionals(baseConditional:Copy():Add("form:6"))
        --   --   travelLine:Add(conditionals, Addon.spellNames.SwiftFlightForm)
        --   -- elseif IsSpellKnown(Addon.spells.FlightForm) then
        --   --   local conditionals = Addon.Conditionals(baseConditional:Copy():Add("form:6"))
        --   --   travelLine:Add(conditionals, Addon.spellNames.FlightForm)
        --   -- end
        --   if Addon:CanUseForm"TravelForm" then
        --     local conditionals = Addon.Conditionals()
        --     local conditional  = baseConditional:Copy():Add("outdoors", "flyable", "nocombat")
            
        --     if not Addon:GetOption("behavior", "allowSlowMounts") then
        --       conditionals:Add(conditional:Copy():Add("swimming", "form:4"))
        --       conditional:Add("noswimming")
        --     end
            
        --     conditionals:Add(conditional)
        --     travelLine:Add(conditionals, Addon.spellNames.TravelForm)
        --   end
          
        --   if Addon:CanUseForm"CatForm" and ({GetTalentInfo(unpack(Addon.talents.FeralSwiftness))})[5] >= Addon.talentRanks.FeralSwiftness then -- Cat form has a speed boost
        --     local conditionals = Addon.Conditionals()
        --     local conditional  = baseConditional:Copy():Add("flyable", "nocombat")
            
        --     if not Addon:GetOption("behavior", "allowSlowMounts") then
        --       conditionals:Add(conditional:Copy():Add("swimming", "form:3"))
        --       conditional:Add("noswimming")
        --     end
            
        --     conditionals:Add(conditional)
        --     travelLine:Add(conditionals, Addon.spellNames.CatForm)
        --   end
        -- end
        
        if Addon:IsFlyableRestricted() then
          if Addon:GetOption("class", Addon.MY_CLASS_FILENAME, "allowRiskyShapeshifting") then
            local form = Addon:CanUseForm"SwiftFlightForm" and "SwiftFlightForm" or Addon:CanUseForm"FlightForm" and "FlightForm" or nil
            if form then
              travelLine:Add(Addon.Conditionals(baseConditional:Copy():Add("form:6")), Addon.spellNames[form])
            end
          end
        else
          local form = Addon:CanUseForm"SwiftFlightForm" and "SwiftFlightForm" or Addon:CanUseForm"FlightForm" and "FlightForm" or nil
          if form then
            local conditionals = Addon.Conditionals(baseConditional:Copy():Add("outdoors", "flyable", "nocombat", "noswimming"))
            if Addon:GetOption("class", Addon.MY_CLASS_FILENAME, "allowRiskyShapeshifting") then
              conditionals:Add(baseConditional:Copy():Add("indoors", "form:6"), baseConditional:Copy():Add("combat", "form:6"), baseConditional:Copy():Add("noflyable", "form:6"))
            end
            travelLine:Add(conditionals, Addon.spellNames[form])
          end
        end
        
        if Addon:CanUseForm"TravelForm" then
          local conditionals = Addon.Conditionals()
          local conditional  = baseConditional:Copy():Add("outdoors")
          
          if not Addon:GetOption("behavior", "allowSlowMounts") then
            conditionals:Add(conditional:Copy():Add("swimming", "form:4"))
            conditional:Add("noswimming")
          end
          
          -- conditionals:Add(conditional:Copy():Add("flyable", "combat"), conditional:Add("noflyable"))
          travelLine:Add(Addon.Conditionals(conditional), Addon.spellNames.TravelForm)
        end
        
        if Addon:CanUseForm"CatForm" and ({GetTalentInfo(unpack(Addon.talents.FeralSwiftness))})[5] >= Addon.talentRanks.FeralSwiftness then -- Cat form has a speed boost
          local conditionals = Addon.Conditionals()
          local conditional  = baseConditional:Copy()
          if Addon.expansionLevel < Addon.expansions.wrath then
            conditional:Add"outdoors"
          end
          
          if not Addon:GetOption("behavior", "allowSlowMounts") then
            conditionals:Add(conditional:Copy():Add("swimming", "form:3"))
            conditional:Add("noswimming")
          end
          
          -- conditionals:Add(conditional:Copy():Add("flyable", "combat"), conditional:Add("noflyable"))
          travelLine:Add(Addon.Conditionals(conditional), Addon.spellNames.CatForm)
        end
      end,
      
      SHAMAN = function()
        if Addon:CanUseForm"GhostWolf" then
          local conditionals = Addon.Conditionals()
          local conditional  = baseConditional:Copy():Add("outdoors")
          if ({GetTalentInfo(unpack(Addon.talents.ImprovedGhostWolf))})[5] >= Addon.talentRanks.ImprovedGhostWolf and Addon:HasValidMounts() then -- shapeshift is not instant, and I can use a real mount
            conditional:Add("combat")
          end
          if not Addon:GetOption("behavior", "allowSlowMounts") then
            conditionals:Add(conditional:Copy():Add("swimming", "form"))
            conditional:Add("noswimming")
          end
          conditionals:Add(conditional)
          travelLine:Add(conditionals, Addon.spellNames.GhostWolf)
        end
      end,
      
      HUNTER = function()
        local aspect
        if Addon:CanUseForm"AspectOfTheCheetah" then
          aspect = "AspectOfTheCheetah"
        elseif Addon:CanUseForm"AspectOfThePack" then
          aspect = "AspectOfThePack"
        end
        if aspect then
          local conditionals = Addon.Conditionals()
          local conditional  = baseConditional:Copy():Add("outdoors")
          if not Addon:GetOption("behavior", "allowSlowMounts") then
            conditional:Add("noswimming")
          end
          conditionals:Add(conditional)
          travelLine:Add(conditionals, "!", Addon.spellNames[aspect])
        end
      end,
    })
  end
  
  return travelLine
end


local combatEquipSlots = Addon:MakeLookupTable{
  "INVTYPE_WEAPON",
  "INVTYPE_SHIELD",
  "INVTYPE_RANGED",
  "INVTYPE_2HWEAPON",
  "INVTYPE_WEAPONMAINHAND",
  "INVTYPE_WEAPONOFFHAND",
  "INVTYPE_HOLDABLE",
  "INVTYPE_AMMO",
  "INVTYPE_THROWN",
  "INVTYPE_RANGEDRIGHT",
  "INVTYPE_RELIC",
}
local function UseZoneItem(macroText, travelLine, zone, item, combatPickup, equip, atCursor)
  local itemID = Addon.itemsByCategory[zone][item]
  
  if not Addon:GetOption("zone", zone, "allowedItems", item) then return end
  if combatPickup or GetItemCount(itemID) > 0 then
    travelLine:Wipe()
  end
  
  local condition = atCursor and Addon:GetOption("zone", zone, "atCursor") and "[@cursor]" or ""
  if equip then
    local itemEquipLoc = select(4, GetItemInfoInstant(itemID))
    local conditionals = Addon.Conditionals()
    if itemEquipLoc and not combatEquipSlots[itemEquipLoc] then
      conditionals:Add(Addon.Conditional"nocombat")
    end
    macroText:AddLine(Addon.Line("equip"):Add(conditionals, "item:" .. itemID))
  end
  macroText:AddLine(Addon.Line("use"):Add(condition, "item:" .. itemID))
end


local function AddZoneLines(macroText, travelLine)
  local zone = Addon:GetZone()
  if zone and Addon:GetOption("zone", zone, "useZoneItems") then
    local cases = {
      ["Molten Core"] = function()
        -- local startTime, duration = GetItemCooldown(Addon.itemsByCategory[zone].EternalQuintessence)
        for _, item in ipairs{"EternalQuintessence", "AqualQuintessence"} do
          UseZoneItem(macroText, travelLine, zone, item)
        end
      end,
      
      -- ["Blackwing Lair"] = function()
      --   if Addon.MY_CLASS_FILENAME == "HUNTER" then
      --     local lastRangedItem = Addon:GetLastRangedItem()
      --     if lastRangedItem and GetItemCount(lastRangedItem) > 0 then
      --       macroText:AddLine(Addon.Line("equip", lastRangedItem))
      --       macroText:AddLine(Addon.Line("run", ADDON_NAME .. ":UnequipRangedItem()"))
      --     end
      --   end
      -- end,
    }
    
    if Addon.expansionLevel >= Addon.expansions.tbc then
      if Addon.expansionLevel < Addon.expansions.wrath then
        Addon:Concatenate(cases, {
          Karazhan = function()
            UseZoneItem(macroText, travelLine, zone, "BlackenedUrn")
          end,
        })
      end
      
      Addon:Concatenate(cases, {
        ["Serpentshrine Cavern"] = function()
          UseZoneItem(macroText, travelLine, zone, "TaintedCore", true)
        end,
        
        ["The Eye"] = function()
          UseZoneItem(macroText, travelLine, zone, "StaffOfDisintegration", true, true)
          UseZoneItem(macroText, travelLine, zone, "NetherstrandLongbow",   true, true)
          UseZoneItem(macroText, travelLine, zone, "WarpSlicer",            true, true)
          UseZoneItem(macroText, travelLine, zone, "Devastation",           true, true)
          UseZoneItem(macroText, travelLine, zone, "CosmicInfuser",         true, true)
          UseZoneItem(macroText, travelLine, zone, "InfinityBlade",         true, true)
          UseZoneItem(macroText, travelLine, zone, "PhaseshiftBulwark",     true, true)
        end,
        
        ["Battle for Mount Hyjal"] = function()
          UseZoneItem(macroText, travelLine, zone, "TearsOfTheGoddess")
        end,
        
        ["Black Temple"] = function()
          UseZoneItem(macroText, travelLine, zone, "NajentusSpine", true)
        end,
      })
    end
    
    if Addon.expansionLevel >= Addon.expansions.wrath then
      Addon:Concatenate(cases, {
        Oculus = function()
          for key, id in pairs(Addon.items.Oculus) do
            UseZoneItem(macroText, travelLine, zone, key)
          end
          macroText:AddLine"/run VehicleExit()"
        end,
        
        Ulduar = function()
          UseZoneItem(macroText, travelLine, zone, "MagneticCore", true)
        end,
        
        ["Icecrown Citadel"] = function()
          UseZoneItem(macroText, travelLine, zone, "GoblinRocketPack", true, true, true)
        end,
      })
    end
    
    Addon:Switch(zone, cases)
  end
end


local macroNeedsUpdate = true
local function ModifyButton()
  if InCombatLockdown() then return end
  if not macroNeedsUpdate and not Addon:DoesMountMacroNeedUpdate() then return end
  
  local macroText = Addon.MacroText()
  
  AddAuraLines(macroText)
  
  local travelLine = MakeTravelLine()
  
  AddZoneLines(macroText, travelLine)
  
  if travelLine:IsComplete() then
    macroText:AddLine(Addon.Line("run", ADDON_NAME .. ":BlockUIErrors()"))
  end
  
  macroText:AddLine(Addon.Line("click", SPELL_BUTTON_NAME))
  
  if travelLine:IsComplete() then
    macroText:AddLine(travelLine)
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
  self:GetMacroButton(MACRO_BUTTON_NAME, true)
  
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
  
  -- Rewrite the macro immediately if options are changed
  self:RegisterOptionSetHandler(FlagForUpdate)
  
  -- Just in case, run as soon as possible upon login
  self:WhenOutOfCombat(ModifyButton)
end)




