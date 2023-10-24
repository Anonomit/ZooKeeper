
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)








local lastID
function Addon:SetLastCritter(id)
  Addon:DebugfIfOutput("lastSet", "Last critter is %s", id)
  lastID = id
end



local critterIndex               = 0
local allCritters                = {}
local allCrittersNeedsRefresh    = true
local idealCritters              = {}
local idealCrittersNeedsRefresh  = true
local usableCritters             = {}
local usableCrittersNeedsRefresh = true







local function RefreshAllCritters()
  wipe(allCritters)
  
  local count = 0
  for i = 1, C_PetJournal.GetNumPets() do
    local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(i)
    if petID then
      local isSummonable, error, errorText = C_PetJournal.GetPetSummonInfo(petID)
      local active = C_PetJournal.IsCurrentlySummoned(petID)
      allCritters[petID] = {name = speciesName, active = active}
      count = count + 1
    end
  end
  
  allCrittersNeedsRefresh = false
end



local function RefreshUsableCritters()
  wipe(usableCritters)
  
  local count = 0
  for i = 1, C_PetJournal.GetNumPets() do
    local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(i)
    if petID then
      local isSummonable, error, errorText = C_PetJournal.GetPetSummonInfo(petID)
      local active = C_PetJournal.IsCurrentlySummoned(petID)
      if isSummonable then
        usableCritters[petID] = {name = speciesName, active = active}
        count = count + 1
      end
    end
  end
  
  Addon:DebugfIfOutput("usableSelected", "Usable critters updated: %d found%s", count, table.concat(Addon:Map(Addon:Squish(usableCritters), function(v, k) return format("\n%d: %s", k, v.name) end), ""))
  
  usableCrittersNeedsRefresh = false
  RefreshAllCritters()
end
local function AttemptRefreshUsableCritters()
  if usableCrittersNeedsRefresh then
    RefreshUsableCritters()
  end
end


local function RefreshIdealCritters()
  AttemptRefreshUsableCritters()
  wipe(idealCritters)
  
  local nonFavCritters = {}
  local favCritters    = {}
  
  for id in pairs(usableCritters) do
    tinsert(nonFavCritters, id)
    if Addon:GetOption("fav", id) then
      tinsert(favCritters, id)
    end
  end
  
  if #favCritters > 0 then
    idealCritters = favCritters
  else
    idealCritters = nonFavCritters
  end
  
  Addon:DebugfIfOutput("idealSelected", "Ideal critters updated: %d found%s", #idealCritters, table.concat(Addon:Map(idealCritters, function(v, k) return format("\n%d: %s", k, usableCritters[v].name) end), ""))
  
  Addon:Shuffle(idealCritters)
  idealCrittersNeedsRefresh = false
  critterIndex = 0
end
local function AttemptRefreshIdealCritters()
  if idealCrittersNeedsRefresh then
    RefreshIdealCritters()
  end
end





local function WipeIdealCritters()
  if not idealCrittersNeedsRefresh then
    Addon:DebugIfOutput("idealReset", "Ideal critters cleared")
    wipe(idealCritters)
    idealCrittersNeedsRefresh = true
  end
end
local function WipeUsablePets()
  if not usableCrittersNeedsRefresh then
    Addon:DebugIfOutput("usableReset", "Usable critters cleared")
    wipe(usableCritters)
    usableCrittersNeedsRefresh = true
  end
  WipeIdealCritters()
end




function Addon:DoesPetMacroNeedUpdate()
  return idealCrittersNeedsRefresh or usableCrittersNeedsRefresh
end

function Addon:HasValidCritters()
  AttemptRefreshIdealCritters()
  return #idealCritters > 0
end

function Addon:GetSummonedCritter()
  AttemptRefreshUsableCritters()
  for _, id in ipairs(idealCritters) do
    if usableCritters[id].active then
      return id
    end
  end
end

function Addon:HasSummonedCritter()
  AttemptRefreshUsableCritters()
  return self:GetSummonedCritter() and true or false
end

function Addon:HasSummonedValidCritter()
  AttemptRefreshUsableCritters()
  for _, id in ipairs(idealCritters) do
    if allCritters[id].active then
      return true
    end
  end
  return false
end

function Addon:SelectCritter()
  AttemptRefreshIdealCritters()
  local critter = idealCritters[critterIndex+1]
  if critter == lastID then
    critterIndex = (critterIndex+1) % (#idealCritters)
    critter = idealCritters[critterIndex+1]
  end
  return critter
end





Addon:RegisterEnableCallback(function(self)
  hooksecurefunc(C_PetJournal, "SummonPetByGUID", function(id) self:SetLastCritter(id) end)
  
  self:RegisterOptionSetHandler(WipeIdealPets)
  
  self:RegisterEventCallback("NEW_PET_ADDED",           WipeUsablePets)
  self:RegisterEventCallback("PET_JOURNAL_LIST_UPDATE", WipeUsablePets)
  
  -- fires for other players too
  self:RegisterEventCallback("COMPANION_UPDATE", function(self, event, category)
    if category == "CRITTER" then
      WipeUsablePets()
    end
  end)
end)







-- debug
function Addon:GetUsableCritters()
  return usableCritters
end
function Addon:GetIdealCritters()
  return idealCritters
end







