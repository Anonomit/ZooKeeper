
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)








local lastCritterID

local function TrackLastCritter(...)
  lastCritterID = ...
end



local critterIndex             = 0
local idealCritters              = {}
local idealCrittersNeedsRefresh  = true
local usableCritters             = {}
local usableCrittersNeedsRefresh = true









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
  
  Addon:DebugfIfOutput("usableSelected", "Usable pets updated: %d found%s", count, table.concat(Addon:Map(Addon:Squish(usableCritters), function(v, k) return format("\n%d: %s", k, v.name) end), ""))
  
  usableCrittersNeedsRefresh = false
end
local function AttemptRefreshUsableCritters()
  if usableCrittersNeedsRefresh then
    RefreshUsableCritters()
  end
end


local function RefreshIdealCritters()
  AttemptRefreshUsableCritters()
  wipe(idealCritters)
  
  local allCritters = {}
  local favCritters = {}
  
  for id in pairs(usableCritters) do
    tinsert(allCritters, id)
    if Addon:GetOption("fav", id) then
      tinsert(favCritters, id)
    end
  end
  
  if #favCritters > 0 then
    idealCritters = favCritters
  else
    idealCritters = allCritters
  end
  
  Addon:DebugfIfOutput("idealSelected", "Ideal pets updated: %d found%s", #idealCritters, table.concat(Addon:Map(idealCritters, function(v, k) return format("\n%d: %s", k, usableCritters[v].name) end), ""))
  
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
    Addon:DebugIfOutput("idealReset", "Ideal mounts cleared")
    wipe(idealCritters)
    idealCrittersNeedsRefresh = true
  end
end
local function WipeUsablePets()
  if not usableCrittersNeedsRefresh then
    Addon:DebugIfOutput("usableReset", "Usable mounts cleared")
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

function Addon:SelectCritter()
  AttemptRefreshIdealCritters()
  local critter = idealCritters[critterIndex+1]
  if critter == lastCritterID then
    critterIndex = (critterIndex+1) % (#idealCritters)
    critter = idealCritters[critterIndex+1]
  end
  return critter
end





function Addon:StartCritterTracking()
  hooksecurefunc(C_PetJournal, "SummonPetByGUID", TrackLastCritter)
  
  self:RegisterEvent("NEW_PET_ADDED", WipeUsablePets)
  
  -- self:RegisterEvent("ZONE_CHANGED", WipeUsablePets)
  -- self:RegisterEvent("PLAYER_REGEN_ENABLED", WipeUsablePets)
end




Addon.WipeUsablePets = WipeUsablePets



-- debug
function Addon:GetUsableCritters()
  return usableCritters
end
function Addon:GetIdealCritters()
  return idealCritters
end







