
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local lastMountID

local function TrackLastMount(...)
  lastMountID = ...
end



local mountIndex               = 0
local allMounts                = {}
local allMountsNeedsRefresh    = true
local idealMounts              = {}
local idealMountsNeedsRefresh  = true
local usableMounts             = {}
local usableMountsNeedsRefresh = true






local function RefreshAllMounts()
  wipe(allMounts)
  
  local count = 0
  for _, i in ipairs(C_MountJournal.GetMountIDs()) do
    local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(i)
    allMounts[i] = {name = creatureName, spellID = spellID, active = active}
    count = count + 1
  end
  
  allMountsNeedsRefresh = false
end


local function RefreshUsableMounts()
  wipe(usableMounts)
  
  local count = 0
  for _, i in ipairs(C_MountJournal.GetMountIDs()) do
    local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(i)
    if isUsable then
      usableMounts[i] = {name = creatureName, spellID = spellID, active = active}
      count = count + 1
    end
  end
  
  Addon:DebugfIfOutput("usableSelected", "Usable mounts updated: %d found%s", count, table.concat(Addon:Map(Addon:Squish(usableMounts), function(v, k) return format("\n%d: %s", k, v.name) end), ""))
  
  usableMountsNeedsRefresh = false
  RefreshAllMounts()
end
local function AttemptRefreshUsableMounts()
  if usableMountsNeedsRefresh then
    RefreshUsableMounts()
  end
end


local function InsertMount(id, mounts, mountType)
  tinsert(mounts[mountType], id)
  if Addon:GetOption("fav", id) then
    tinsert(mounts.fav[mountType], id)
  end
  Addon:DebugIfOutput("mountTypes", "%s can %s", usableMounts[id].name, mountType)
end
local function FilterToFastestMounts(candidates, mountType)
  wipe(idealMounts)

  if Addon:GetGlobalOption("debugOutput", "candidates") then
    Addon:Debugf("Candidates: %d", #candidates)
    for _, spellID in ipairs(candidates) do
      Addon:Debugf("  %d", spellID)
    end
  end
  
  if #candidates == 0 then
    return
  end

  -- find the fastest mount
  local speedFilter = 0
  for _, i in ipairs(candidates) do
    local speed = Addon:GetMountFastestSpeed(usableMounts[i].spellID, mountType)
    if not speedFilter or speed > speedFilter then
      speedFilter = speed
    end
  end
  
  if speedFilter then
    idealMounts = Addon:Filter(candidates, function(v)
      return Addon:GetMountFastestSpeed(usableMounts[v].spellID, mountType) == speedFilter
    end)
  end
  
  return speedFilter
end
local function RefreshIdealMounts()
  AttemptRefreshUsableMounts()

  local mounts = {fly = {}, ground = {}, swim = {}, fav = {fly = {}, ground = {}, swim = {}}}

  local flyable = false
  for id, mountData in pairs(usableMounts) do
    local _, typeFlags, mountFlags, flightSpeeds, groundSpeeds, swimSpeeds = Addon:GetMountInfo(mountData.spellID)
    
    if bit.band(typeFlags or 0, 0x5) == 0 then -- Mount is usable on ground
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

  local mountType = IsSwimming() and "swim" or flyable and "fly" or "ground"
  
  Addon:DebugIfOutput("mountType", "Mount Type: %s", mountType)
  
  if Addon:GetGlobalOption("debugOutput", "initialMountPool") then
    Addon:Debug("Initial mount pool:")
    for j, cats in ipairs{mounts.fav, mounts} do
      for _, cat in ipairs{"fly", "ground", "swim"} do
        local lis = cats[cat]
        Addon:Debugf("  %s%s:", j == 1 and "fav " or "", cat)
        for _, i in ipairs(lis) do
          Addon:Debug("    " .. usableMounts[i].name)
        end
      end
    end
  end
  
  local fastestSpeed = FilterToFastestMounts(#mounts.fav[mountType] > 0 and mounts.fav[mountType] or mounts[mountType], mountType)
  
  -- if mountType is "swim" or "fly" and couldn't find a proper mount, then use fallback "ground"
  if (#idealMounts == 0 or fastestSpeed == 0) and mountType ~= "ground" then
    if useFallback then
      Addon:DebugIfOutput("usingFallbackMount", "Falling back to ground mount. Valid Mounts: %d, Fastest Speed: %s", not idealMounts and 0 or #idealMounts, tostring(fastestSpeed))
      mountType = "ground"
      fastestSpeed = FilterToFastestMounts(#mounts.fav[mountType] > 0 and mounts.fav[mountType] or mounts[mountType], mountType)
    else
      wipe(idealMounts)
    end
  end
  
  if mountType == "fly" and Addon.MY_CLASS_NAME == "DRUID" then
    if IsSpellKnown(Addon.spells.SwiftFlightForm) and fastestSpeed <= 280 then
      wipe(idealMounts)
    elseif IsSpellKnown(Addon.spells.FlightForm) and fastestSpeed <= 150 then
      wipe(idealMounts)
    end
  end
  
  Addon:DebugfIfOutput("idealSelected", "Ideal mounts updated: %d found%s", #idealMounts, table.concat(Addon:Map(idealMounts, function(v, k) return format("\n%d: %s", k, usableMounts[v].name) end), ""))
  
  Addon:Shuffle(idealMounts)
  idealMountsNeedsRefresh = false
  mountIndex = 0
end
local function AttemptRefreshIdealMounts()
  if idealMountsNeedsRefresh then
    RefreshIdealMounts()
  end
end





local function WipeIdealMounts()
  if not idealMountsNeedsRefresh then
    Addon:DebugIfOutput("idealReset", "Ideal mounts cleared")
    wipe(idealMounts)
    idealMountsNeedsRefresh = true
  end
end
local function WipeUsableMounts()
  if not usableMountsNeedsRefresh then
    Addon:DebugIfOutput("usableReset", "Usable mounts cleared")
    wipe(usableMounts)
    usableMountsNeedsRefresh = true
  end
  WipeIdealMounts()
end




function Addon:DoesMountMacroNeedUpdate()
  return idealMountsNeedsRefresh or usableMountsNeedsRefresh
end

function Addon:HasValidMounts()
  AttemptRefreshIdealMounts()
  return #idealMounts > 0
end

function Addon:IsRidingMount()
  AttemptRefreshUsableMounts()
  for id, data in pairs(allMounts) do
    if data.active then
      return true
    end
  end
  return false
end

function Addon:IsRidingIdealMount()
  AttemptRefreshIdealMounts()
  for i, id in ipairs(idealMounts) do
    if allMounts[id].active then
      return true
    end
  end
  return false
end

function Addon:SelectMount()
  AttemptRefreshIdealMounts()
  local mount = idealMounts[mountIndex+1]
  if mount == lastMountID then
    mountIndex = (mountIndex+1) % (#idealMounts)
    mount = idealMounts[mountIndex+1]
  end
  self:DebugfIfOutput("finalSelectionMade", "Mount selected: %s (%d)", usableMounts[mount].name, mount)
  return mount
end


function Addon:StartMountTracking()
  hooksecurefunc(C_MountJournal, "SummonByID", TrackLastMount)
  
  self:RegisterEvent("NEW_MOUNT_ADDED", WipeUsableMounts)
  self:RegisterEvent("ZONE_CHANGED", WipeUsableMounts)
  
  -- self:RegisterEvent("ZONE_CHANGED", WipeUsableMounts)
  -- self:RegisterEvent("PLAYER_REGEN_ENABLED", WipeUsableMounts)
end




Addon.WipeUsableMounts = WipeUsableMounts



-- debug
function Addon:GetUsableMounts()
  AttemptRefreshUsableMounts()
  return usableMounts
end
function Addon:GetIdealMounts()
  AttemptRefreshIdealMounts()
  return idealMounts
end



