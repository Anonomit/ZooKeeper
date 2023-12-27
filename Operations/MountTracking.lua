
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local lastID
function Addon:SetLastMount(id)
  Addon:DebugfIfOutput("lastSet", "Last mount is %s", id)
  lastID = id
end



local optionIndex               = 0
local allOptions                = {}
local allOptionsNeedsRefresh    = true
local usableOptions             = {}
local usableOptionsNeedsRefresh = true
local idealOptions              = {}
local idealOptionsNeedsRefresh  = true



local function IsMountActive(mountSpellID)
  return not not AuraUtil.FindAura(function(...)
    local spellID = select(13, ...)
    if spellID == mountSpellID then
      return true
    end
  end, "player", "HELPFUL")
end



local function RefreshAllOptions()
  wipe(allOptions)
  
  local count = 0
  if Addon.expansionLevel < Addon.expansions.wrath then
    for bag = 0, NUM_BAG_SLOTS do
      for slot = 1, C_Container.GetContainerNumSlots(bag) do
        local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
        if containerInfo then
          local spellName, spellID = GetItemSpell(containerInfo.itemID)
          if spellID and Addon.mounts[spellID] and Addon:IsInAQ() == Addon.aqMounts[spellID] and (not Addon.ashenvaleMounts[spellID] or Addon:IsInAshenvale()) then
            Addon:SetOption(containerInfo.itemID, "discovered", "mounts", spellID)
            allOptions[spellID] = {name = GetItemInfo(containerInfo.itemID) or spellName, spellID = spellID, active = IsMountActive(spellID), isCollected = true, itemID = containerInfo.itemID, bag = bag, slot = slot}
            count = count + 1
          end
        end
      end
    end
    
    if not Addon:IsInAQ() then
      for spellID in pairs(Addon.mounts) do
        if IsSpellKnown(spellID) then
          Addon:SetOption(true, "discovered", "mounts", spellID)
          allOptions[spellID] = {name = GetSpellInfo(spellID), spellID = spellID, active = IsMountActive(spellID), isCollected = true}
          count = count + 1
        end
      end
    end
  else
    for _, i in ipairs(C_MountJournal.GetMountIDs()) do
      local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(i)
      if isCollected then
        allOptions[i] = {name = creatureName, spellID = spellID, active = active, isCollected = isCollected}
        count = count + 1
      end
    end
  end
  
  Addon:DebugfIfOutput("allSelected", "All mounts updated: %d found", count)
  
  allOptionsNeedsRefresh = false
end
local function AttemptRefreshAllOptions()
  if allOptionsNeedsRefresh then
    RefreshAllOptions()
  end
end


local function RefreshUsableOptions()
  AttemptRefreshAllOptions()
  wipe(usableOptions)
  
  local count = 0
  if Addon.expansionLevel < Addon.expansions.wrath then
    if IsOutdoors() then
      for k, v in pairs(allOptions) do
        if v.itemID then
          local containerInfo = C_Container.GetContainerItemInfo(v.bag, v.slot)
          if containerInfo and not containerInfo.isLocked then
            usableOptions[k] = v
            count = count + 1
          end
        else
          if Addon:CanUseMount(Addon.spellsByID[v.spellID]) then
            local usable, noMana = IsUsableSpell(v.spellID)
            if usable or noMana then -- try to mount even if there isn't enough mana
              usableOptions[k] = v
              count = count + 1
            end
          end
        end
      end
    end
  else
    for _, i in ipairs(C_MountJournal.GetMountIDs()) do
      local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(i)
      if isUsable then
        usableOptions[i] = {name = creatureName, spellID = spellID, active = active}
        count = count + 1
      end
    end
  end
  
  Addon:DebugfIfOutput("usableSelected", "Usable mounts updated: %d found%s", count, table.concat(Addon:Map(Addon:Squish(usableOptions), function(v, k) return format("\n%d: %s", k, v.name) end), ""))
  
  usableOptionsNeedsRefresh = false
end
local function AttemptRefreshUsableOptions()
  if usableOptionsNeedsRefresh then
    RefreshUsableOptions()
  end
end


local function InsertMount(id, mounts, mountType)
  if not Addon:GetOption("behavior", "onlyUseFavs") then
    tinsert(mounts[mountType], id)
  end
  if Addon:GetOption("fav", id) then
    tinsert(mounts.fav[mountType], id)
  end
  Addon:DebugfIfOutput("mountTypes", "%s can %s", usableOptions[id].name, mountType)
end
local function FilterToFastestMounts(candidates, mountType)
  if mountType == "fallback" then
    mountType = "ground"
  end
  wipe(idealOptions)
  
  if Addon:GetGlobalOption("debugOutput", "candidates") then
    Addon:Debugf("Candidates: %d", #candidates)
    for _, i in ipairs(candidates) do
      Addon:Debugf("  %s", usableOptions[i].name)
    end
  end
  
  if #candidates == 0 then
    return
  end
  
  -- find the fastest mount
  local speedFilter = 0
  for _, i in ipairs(candidates) do
    local speed = Addon:GetMountFastestSpeed(usableOptions[i].spellID, mountType)
    if speed then
      if not speedFilter or speed > speedFilter then
        speedFilter = speed
      end
    end
  end
  
  if speedFilter then
    idealOptions = Addon:Filter(candidates, function(v)
      return Addon:GetMountFastestSpeed(usableOptions[v].spellID, mountType) == speedFilter
    end)
  end
  
  return speedFilter
end
local function RefreshIdealOptions()
  AttemptRefreshUsableOptions()
  local template = {
    "fly",      -- mount is capable of flying
    "ground",   -- mount is ground-only
    "swim",     -- mount is usable in water
    "fallback", -- mount is usable in non-flying ground areas
  }
  local mounts   = Addon:MakeLookupTable(template, function() return {} end)
  mounts.fav     = Addon:MakeLookupTable(template, function() return {} end)
  
  local flyable = false
  for id, mountData in pairs(usableOptions) do
    local _, typeFlags, mountFlags, flightSpeeds, groundSpeeds, swimSpeeds = Addon:GetMountInfo(mountData.spellID)
    
    InsertMount(id, mounts, "fallback")
    
    if bit.band(typeFlags or 0, 0x5) == 0 then -- Mount is not able to fly
      InsertMount(id, mounts, "ground")
    end
    
    if bit.band(typeFlags or 0, 0x2) ~= 0 then -- Mount is usable in water
      InsertMount(id, mounts, "swim")
    end
    
    if bit.band(typeFlags or 0, 0x1) ~= 0 then -- Is flying mount
      InsertMount(id, mounts, "fly")
      flyable = IsFlyableArea()
    end
    
  end
  
  local mountType = IsSwimming() and "swim" or flyable and "fly" or Addon:GetOption("behavior", "preferNonFlyingMountsOnGround") and "ground" or "fallback"
  -- fall back to ground mount if no flyers are available. should only be possible if non-favorite mounts are disallowed
  if mountType == "fly" and #mounts.fav[mountType] == 0 and Addon:GetOption("behavior", "onlyUseFavs") then
    mountType = Addon:GetOption("behavior", "preferNonFlyingMountsOnGround") and "ground" or "fallback"
  end
  
  Addon:DebugfIfOutput("mountType", "Mount Type: %s", mountType)
  
  if Addon:GetGlobalOption("debugOutput", "initialMountPool") then
    Addon:Debug("Initial mount pool:")
    for j, cats in ipairs{mounts.fav, mounts} do
      for _, cat in ipairs{"fly", "ground", "swim", "fallback"} do
        local lis = cats[cat]
        Addon:Debugf("  %s%s:", j == 1 and "fav " or "", cat)
        for _, i in ipairs(lis) do
          Addon:Debug("    " .. usableOptions[i].name)
        end
      end
    end
  end
  
  local fastestSpeed = FilterToFastestMounts(#mounts.fav[mountType] > 0 and mounts.fav[mountType] or mounts[mountType], mountType)
  
  -- if mountType is not fallback or swim and couldn't find a useful (speed>0) mount, then use a fallback
  if (#idealOptions == 0 or fastestSpeed == 0) and mountType ~= "fallback" then
    if not Addon:GetOption("behavior", "allowSlowMounts") then
      wipe(idealOptions)
    elseif mountType ~= "swim" then
      Addon:DebugfIfOutput("usingFallbackMount", "Falling back to ground mount. Valid Mounts: %d, Fastest Speed: %s", not idealOptions and 0 or #idealOptions, tostring(fastestSpeed))
      mountType = "fallback"
      fastestSpeed = FilterToFastestMounts(#mounts.fav[mountType] > 0 and mounts.fav[mountType] or mounts[mountType], mountType)
    end
  end
  
  Addon:DebugfIfOutput("idealSelected", "Ideal mounts updated: %d found%s", #idealOptions, table.concat(Addon:Map(idealOptions, function(v, k) return format("\n%d: %s", k, usableOptions[v].name) end), ""))
  
  if mountType == "fly" and Addon.MY_CLASS_FILENAME == "DRUID" then
    if Addon:CanUseForm"SwiftFlightForm" and (fastestSpeed <= 280 or Addon:GetOption("class", "DRUID", "alwaysPreferFlightForm")) then
      wipe(idealOptions)
      Addon:DebugfIfOutput("idealSelected", "Ideal mounts updated: %d found (using druid form instead)", #idealOptions)
    elseif Addon:CanUseForm"FlightForm" and (fastestSpeed <= 150 or Addon:GetOption("class", "DRUID", "alwaysPreferFlightForm")) then
      wipe(idealOptions)
      Addon:DebugfIfOutput("idealSelected", "Ideal mounts updated: %d found (using druid form instead)", #idealOptions)
    end
  end
  
  
  Addon:Shuffle(idealOptions)
  idealOptionsNeedsRefresh = false
  optionIndex = 0
end
local function AttemptRefreshIdealOptions()
  if idealOptionsNeedsRefresh then
    RefreshIdealOptions()
  end
end





local function WipeIdealOptions()
  if not idealOptionsNeedsRefresh then
    Addon:DebugIfOutput("idealReset", "Ideal mounts cleared")
    wipe(idealOptions)
    idealOptionsNeedsRefresh = true
  end
end
local function WipeUsableOptions()
  if not usableOptionsNeedsRefresh then
    Addon:DebugIfOutput("usableReset", "Usable mounts cleared")
    wipe(usableOptions)
    usableOptionsNeedsRefresh = true
  end
  WipeIdealOptions()
end
local function WipeAllOptions()
  if not allOptionsNeedsRefresh then
    Addon:DebugIfOutput("allReset", "All mounts cleared")
    wipe(allOptions)
    allOptionsNeedsRefresh = true
  end
  WipeUsableOptions()
end




function Addon:DoesMountMacroNeedUpdate()
  return idealOptionsNeedsRefresh or usableOptionsNeedsRefresh or allOptionsNeedsRefresh
end

function Addon:HasValidMounts()
  AttemptRefreshIdealOptions()
  return #idealOptions > 0
end

function Addon:IsRidingMount()
  AttemptRefreshUsableOptions()
  for id, data in pairs(allOptions) do
    if data.active then
      return true
    end
  end
  return false
end

function Addon:IsRidingIdealMount()
  AttemptRefreshIdealOptions()
  for i, id in ipairs(idealOptions) do
    if allOptions[id].active then
      return true
    end
  end
  return false
end

function Addon:SelectMount()
  AttemptRefreshIdealOptions()
  local id
  if self:GetOption("behavior", "useTrueRandomization") then
    id = self:Random(idealOptions)
  else
    id = idealOptions[optionIndex+1]
    if id == lastID then
      optionIndex = (optionIndex+1) % (#idealOptions)
      id = idealOptions[optionIndex+1]
    end
  end
  self:DebugfIfOutput("finalSelectionMade", "Mount selected: %s (%s %d)", usableOptions[id].name, usableOptions[id].itemID and "item" or "id", id)
  if self.expansionLevel < self.expansions.wrath then
    self:SetOption(usableOptions[id].itemID or true, "discovered", "mounts", id)
  end
  return id, usableOptions[id].itemID
end

function Addon:IsFlyableRestricted()
  if not IsFlyableArea() or not self:GetZoneIsFlyableRestricted() then return false end
  
  local hasCollectedFlyingMounts = false
  AttemptRefreshAllOptions()
  for id, mountData in pairs(allOptions) do
    local _, typeFlags = Addon:GetMountInfo(mountData.spellID)
    if mountData.isCollected and bit.band(typeFlags or 0, 0x1) ~= 0 then -- Is flying mount
      AttemptRefreshUsableOptions()
      if usableOptions[id] then
        return false
      else
        hasCollectedFlyingMounts = true
      end
    end
  end
  
  if hasCollectedFlyingMounts then
    return true -- some flying mounts are collected but none are usable
  end
  return false -- can't check flying mounts usability if they aren't collected, so assume they can be used
end


Addon:RegisterEnableCallback(function(self)
  
  self:RegisterOptionSetHandler(function(self, val, ...)
    local dbPath = {...}
    if dbPath[3] == "class" and (dbPath[5] == "useMounts" or dbPath[5] == "allowedMounts") then
      WipeUsableOptions()
    else
      WipeIdealOptions()
    end
  end)
  
  if Addon.expansionLevel < Addon.expansions.wrath then
    
    self:RegisterEventCallback("SPELL_UPDATE_USABLE",   WipeAllOptions) -- when stepping indoors or outdoors
    self:RegisterEventCallback("SPELLS_CHANGED",        WipeAllOptions) -- used for mount spells
    self:RegisterEventCallback("ZONE_CHANGED",          WipeAllOptions) -- used for zone-specific mounts
    self:RegisterEventCallback("ZONE_CHANGED_NEW_AREA", WipeAllOptions) -- used for zone-specific mounts
    self:RegisterEventCallback("ITEM_LOCK_CHANGED",     WipeUsableOptions) -- used for mounts in bag
    self:RegisterEventCallback("BAG_UPDATE_DELAYED",    WipeAllOptions) -- used for mounts in bag
    self:RegisterEventCallback("UNIT_AURA", function(self, e, unitID)
      if unitID == "player" then
        WipeAllOptions()
      end
    end) -- used for auras that block mounting, and mounts themselves
    
  else
    
    hooksecurefunc(C_MountJournal, "SummonByID", function(id) self:SetLastMount(id) end)
    
    
    self:RegisterEventCallback("NEW_MOUNT_ADDED",                 WipeAllOptions)
    self:RegisterEventCallback("PLAYER_MOUNT_DISPLAY_CHANGED",    WipeAllOptions) -- when the player uses a mount
    
    self:RegisterEventCallback("MOUNT_JOURNAL_USABILITY_CHANGED", WipeAllOptions)
    self:RegisterEventCallback("LEARNED_SPELL_IN_TAB",            WipeAllOptions) -- for when a new shapeshift is learned
    
    -- self:RegisterEventCallback("MOUNT_JOURNAL_USABILITY_CHANGED", WipeUsableOptions)
    -- self:RegisterEventCallback("LEARNED_SPELL_IN_TAB",            WipeUsableOptions) -- for when a new shapeshift is learned
    
  end
  
  AttemptRefreshAllOptions()
end)







-- debug
if Addon:IsDebugEnabled() then
  -- function Addon:GetAllOptions()
  --   AttemptRefreshAllOptions()
  --   return allOptions
  -- end
  -- function Addon:GetUsableOptions()
  --   AttemptRefreshUsableOptions()
  --   return usableOptions
  -- end
  -- function Addon:GetIdealOptions()
  --   AttemptRefreshIdealOptions()
  --   return idealOptions
  -- end
end




