
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)








local lastID
function Addon:SetLastCritter(id)
  Addon:DebugfIfOutput("lastSet", "Last critter is %s", id)
  lastID = id
end



local optionIndex               = 0
local allOptions                = {}
local allOptionsNeedsRefresh    = true
local usableOptions             = {}
local usableOptionsNeedsRefresh = true
local idealOptions              = {}
local idealOptionsNeedsRefresh  = true







local function RefreshAllOptions()
  wipe(allOptions)
  
  local count = 0
  if Addon.isClassic then
    for bag = 0, NUM_BAG_SLOTS do
      for slot = 1, C_Container.GetContainerNumSlots(bag) do
        local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
        if containerInfo then
          local spellName, spellID = GetItemSpell(containerInfo.itemID)
          if spellID and Addon.critters[spellID] then
            Addon:SetOption(containerInfo.itemID, "discovered", "critters", spellID)
            allOptions[spellID] = {name = GetItemInfo(containerInfo.itemID) or spellName, spellID = spellID, isCollected = true, itemID = containerInfo.itemID, bag = bag, slot = slot}
            count = count + 1
          end
        end
      end
    end
  else
    for i = 1, C_PetJournal.GetNumPets() do
      local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(i)
      if petID then
        local isSummonable, error, errorText = C_PetJournal.GetPetSummonInfo(petID)
        local active = C_PetJournal.IsCurrentlySummoned(petID)
        allOptions[petID] = {name = speciesName, active = active}
        count = count + 1
      end
    end
  end
  
  Addon:DebugfIfOutput("allSelected", "All critters updated: %d found", count)
  
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
  if Addon.isClassic then
    for k, v in pairs(allOptions) do
      local containerInfo = C_Container.GetContainerItemInfo(v.bag, v.slot)
      if containerInfo and not containerInfo.isLocked then
        usableOptions[k] = v
        count = count + 1
      end
    end
  else
    for i = 1, C_PetJournal.GetNumPets() do
      local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(i)
      if petID then
        local isSummonable, error, errorText = C_PetJournal.GetPetSummonInfo(petID)
        local active = C_PetJournal.IsCurrentlySummoned(petID)
        if isSummonable then
          usableOptions[petID] = {name = speciesName, active = active}
          count = count + 1
        end
      end
    end
  end
  
  Addon:DebugfIfOutput("usableSelected", "Usable critters updated: %d found%s", count, table.concat(Addon:Map(Addon:Squish(usableOptions), function(v, k) return format("\n%d: %s", k, v.name) end), ""))
  
  usableOptionsNeedsRefresh = false
end
local function AttemptRefreshUsableOptions()
  if usableOptionsNeedsRefresh then
    RefreshUsableOptions()
  end
end


local function RefreshIdealOptions()
  AttemptRefreshUsableOptions()
  wipe(idealOptions)
  
  local nonFavCritters = {}
  local favCritters    = {}
  
  for id in pairs(usableOptions) do
    tinsert(nonFavCritters, id)
    if Addon:GetOption("fav", id) then
      tinsert(favCritters, id)
    end
  end
  
  if #favCritters > 0 then
    idealOptions = favCritters
  else
    idealOptions = nonFavCritters
  end
  
  Addon:DebugfIfOutput("idealSelected", "Ideal critters updated: %d found%s", #idealOptions, table.concat(Addon:Map(idealOptions, function(v, k) return format("\n%d: %s", k, usableOptions[v].name) end), ""))
  
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
    Addon:DebugIfOutput("idealReset", "Ideal critters cleared")
    wipe(idealOptions)
    idealOptionsNeedsRefresh = true
  end
end
local function WipeUsableOptions()
  if not usableOptionsNeedsRefresh then
    Addon:DebugIfOutput("usableReset", "Usable critters cleared")
    wipe(usableOptions)
    usableOptionsNeedsRefresh = true
  end
  WipeIdealOptions()
end
local function WipeAllOptions()
  if not allOptionsNeedsRefresh then
    Addon:DebugIfOutput("allReset", "All critters cleared")
    wipe(allOptions)
    allOptionsNeedsRefresh = true
  end
  WipeUsableOptions()
end




function Addon:DoesPetMacroNeedUpdate()
  return idealOptionsNeedsRefresh or usableOptionsNeedsRefresh
end

function Addon:HasValidCritters()
  AttemptRefreshIdealOptions()
  return #idealOptions > 0
end

function Addon:GetSummonedCritter()
  AttemptRefreshUsableOptions()
  for _, id in ipairs(idealOptions) do
    if usableOptions[id].active then
      return id
    end
  end
end

function Addon:HasSummonedCritter()
  AttemptRefreshUsableOptions()
  return self:GetSummonedCritter() and true or false
end

function Addon:HasSummonedValidCritter()
  AttemptRefreshIdealOptions()
  for _, id in ipairs(idealOptions) do
    if allOptions[id].active then
      return true
    end
  end
  return false
end

function Addon:SelectCritter()
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
  if self.isClassic then
    self:SetOption(usableOptions[id].itemID or true, "discovered", "critters", id)
  end
  return id, usableOptions[id].itemID
end





Addon:RegisterEnableCallback(function(self)
  if self.isClassic then
    self:RegisterOptionSetHandler(WipeIdealPets)
    
    self:RegisterEventCallback("ITEM_LOCK_CHANGED",  WipeUsableOptions) -- used for critters in bag
    self:RegisterEventCallback("BAG_UPDATE_DELAYED", WipeAllOptions) -- used for critters in bag
    
  else
    hooksecurefunc(C_PetJournal, "SummonPetByGUID", function(id) self:SetLastCritter(id) end)
    
    self:RegisterOptionSetHandler(WipeIdealPets)
    
    self:RegisterEventCallback("NEW_PET_ADDED",           WipeAllOptions)
    self:RegisterEventCallback("PET_JOURNAL_LIST_UPDATE", WipeAllOptions)
    
    -- fires for other players too
    self:RegisterEventCallback("COMPANION_UPDATE", function(self, event, category)
      if category == "CRITTER" then
        WipeUsableOptions()
      end
    end)
  end
  
  AttemptRefreshAllOptions()
end)







-- debug
if Addon:IsDebugEnabled() then
  -- function Addon:GetAllOptions()
  --   RefreshAllOptions()
  --   return allOptions
  -- end
  -- function Addon:GetUsableOptions()
  --   AttemptRefreshUsableOptions()
  --   return usableOptions
  -- end
  -- function Addon:GetIdealOptions()
  --   RefreshIdealOptions()
  --   return idealOptions
  -- end
end







