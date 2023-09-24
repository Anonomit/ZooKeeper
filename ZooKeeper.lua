
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
-- local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local tblRemove = table.remove
local tblConcat = table.concat

local type         = type
local next         = next
local ipairs       = ipairs
local format       = format
local assert       = assert
local getmetatable = getmetatable
local setmetatable = setmetatable

local function DeepCopy(orig, seen)
  local new
  if type(orig) == "table" then
    if seen[orig] then
      new = seen[orig]
    else
      new = {}
      seen[orig] = copy
      for k, v in next, orig, nil do
        new[DeepCopy(k, seen)] = DeepCopy(v, seen)
      end
      setmetatable(new, DeepCopy(getmetatable(orig), seen))
    end
  else
    new = orig
  end
  return new
end
function Addon:Copy(val)
  return DeepCopy(val, {})
end

function Addon:GetDB()
  return self.db
end
function Addon:GetDefaultDB()
  return self.dbDefault
end
function Addon:GetProfile()
  return Addon.GetDB(self).profile
end
function Addon:GetDefaultProfile()
  return Addon.GetDefaultDB(self).profile
end
local function GetOption(self, db, ...)
  local val = db
  for _, key in ipairs{...} do
    assert(type(val) == "table", format("Bad database access: %s", tblConcat({...}, " > ")))
    val = val[key]
  end
  return val
end
function Addon:GetOption(...)
  return GetOption(self, Addon.GetProfile(self), ...)
end
function Addon:GetDefaultOption(...)
  return GetOption(self, Addon.GetDefaultProfile(self), ...)
end
local function SetOption(self, db, val, ...)
  local keys = {...}
  local lastKey = tblRemove(keys, #keys)
  local tbl = db
  for _, key in ipairs(keys) do
    tbl = tbl[key]
  end
  tbl[lastKey] = val
  Addon.OnOptionSet(Addon, db, val, ...)
end
function Addon:SetOption(val, ...)
  return SetOption(self, Addon.GetProfile(self), val, ...)
end
function Addon:ResetOption(...)
  return Addon.SetOption(self, Addon.Copy(self, Addon.GetDefaultOption(self, ...)), ...)
end

function Addon:OnOptionSet(...)
  if not self:GetDB() then return end -- db hasn't loaded yet
  for funcName, func in next, Addon.onOptionSetHandlers, nil do
    if type(func) == "function" then
      func(self, ...)
    else
      self[funcName](self, ...)
    end
  end
end




local tinsert = table.insert









function Addon:GetValidMounts(candidates, mountType, requiredSpeed)
  if self:GetOption("debugOutput", "candidates") then
    self:Debugf("Candidates: %d", #candidates)
    for _, spellID in ipairs(candidates) do
      self:Debugf("  %d", spellID)
    end
  end
  
  if #candidates > 0 then
    local speedFilter = requiredSpeed
    
    -- if the exact speed wasn't specified, find the fastest one
    if not speedFilter then
      for _, spellID in ipairs(candidates) do
        local speed = self:GetMountFastestSpeed(spellID, mountType)
        if not speedFilter or speed > speedFilter then
          speedFilter = speed
        end
      end
    end
    
    if speedFilter then
      local validMounts = self:Filter(candidates, function(v)
        if requiredSpeed then
          -- if an exact speed was speficied, allow it to be off by exactly +100
          return self:CanMountBeSpeed(v, mountType, speedFilter) or self:CanMountBeSpeed(v, mountType, speedFilter - 100)
        else
          return self:GetMountFastestSpeed(v, mountType) == speedFilter
        end
      end)
      
      return validMounts, speedFilter
    end
  end
end


do
  local badAuras = {
    [40120] = true, -- Swift Flight Form
  }
  
  local auraIndex
  local function DismissBadAura(...)
    if true then
      Addon:Debug(...)
    end
    auraIndex = auraIndex + 1
    if badAuras[select(13, ...)] then
      if true then
        Addon:Debug("Found bad aura")
      end
      if not InCombatLockdown() then
        CancelUnitBuff("player", auraIndex, "HELPFUL")
      elseif true then
        Addon:Debug("In combat lockdown")
      end
      return true
    end
  end
  
  -- doesn't work for shapeshift forms...
  local function DismissBadAuras()
    auraIndex = 0
    AuraUtil.FindAura(DismissBadAura, "player", "HELPFUL")
  end
  
  function Addon:MountValidMount(validMounts, currentMount, companionMap, silent)
    silent = nil -- silent doesn't actually work because the spellcasts are sent on a later frame
    
    if self:GetOption("debugOutput", "finalMountPool") then
      self:Debug("Final Mount Pool:")
      for _, spellID in ipairs(validMounts) do
        local _, name = GetCompanionInfo("MOUNT", companionMap[spellID])
        self:Debug("  " .. spellID)
      end
    end
    Dismount()
    local alreadyMounted = false
    for _, spellID in ipairs(validMounts) do
      if currentMount == spellID then
        alreadyMounted = true
        break
      end
    end
    if not alreadyMounted then
      local mountID = companionMap[validMounts[random(#validMounts)]]
      mountID = select(12, C_MountJournal.GetDisplayedMountInfo(mountID))
      
      local soundEnabled
      if silent then
        soundEnabled = GetCVarBool"Sound_EnableAllSound"
        if soundEnabled ~= 0 then
          SetCVar("Sound_EnableAllSound", 0)
        end
      end
      C_MountJournal.SummonByID(mountID)
      if silent then
        UIErrorsFrame:Clear()
        if soundEnabled ~= 0 then
          SetCVar("Sound_EnableAllSound", soundEnabled)
        end
      end
    end
    return not alreadyMounted
  end
end



function Addon:GetValidCritters(candidates, currentCritter)
  for i, spellID in ipairs(candidates) do
    if currentCritter == spellID then
      tblRemove(candidates, i)
      break
    end
  end
  return candidates
end

function Addon:CallValidCritter(validCritters, companionMap)
  local soundEnabled
  if silent then
    soundEnabled = GetCVarBool"Sound_EnableAllSound"
    if soundEnabled ~= 0 then
      SetCVar("Sound_EnableAllSound", 0)
    end
  end
  CallCompanion("CRITTER", companionMap[validCritters[random(#validCritters)]])
  if silent then
    UIErrorsFrame:Clear()
    if soundEnabled ~= 0 then
      SetCVar("Sound_EnableAllSound", soundEnabled)
    end
  end
end


-- Mount
do
  local function InsertMount(i, mounts, speed, spellID, mountType)
    if not speed or Addon:CanMountBeSpeed(spellID, mountType, speed) then
      tinsert(mounts[mountType], spellID)
      if Addon:GetOption("fav", spellID) then
        tinsert(mounts.fav[mountType], spellID)
      end
    end
    Addon:DebugfIf({"debugOutput", "mountTypes"}, "%s can %s", spellID, mountType)
  end

  function Addon:Mount(input)
    local args = {self:GetArgs(input, 1)}
    local speed = tonumber(args[1]) or args[1] -- make it a number if possible
    self:DebugfIf({"debugOutput", "speed"}, "Speed: %s (%s)", tostring(speed), type(speed))
    
    local mounts = {fly = {}, ground = {}, swim = {}, fav = {fly = {}, ground = {}, swim = {}}}
    
    -- speed can be a number or fly|ground|swim
    if type(speed) == "string" and not mounts[speed] then
      return
    end
    
    local flyable  = self:CanFly()
    local swimming = IsSwimming()
    local inAQ     = self:IsInAQ()
    
    self:DebugfIf({"debugOutput", "zoneSpecs"}, "Flyable: %s, Swimming: %s, inAQ: %s", tostring(flyable), tostring(swimming), tostring(inAQ))
    
    local currentMount
    
    local companionMap = {}
    for i = 1, C_MountJournal.GetNumDisplayedMounts() do
      local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected = C_MountJournal.GetDisplayedMountInfo(i)
      companionMap[spellID] = i

      self:DebugfIf({"debugOutput", "usable"}, "%s is %susable by Blizzard, is %susable by ZooKeeper", creatureName, isUsable and "" or "un", self:IsMountUsable(spellID, flyable, swimming, inAQ) and "" or "un")
      
      if isUsable then
        local _, typeFlags, mountFlags, flightSpeeds, groundSpeeds, swimSpeeds = self:GetMountInfo(spellID)
        if active then
          currentMount = spellID
        end
        
        if bit.band(typeFlags or 0, 0x5) == 0 then -- Mount is usable on ground
          InsertMount(i, mounts, tonumber(speed), spellID, "ground")
        end
        
        if bit.band(typeFlags or 0, 0x2) ~= 0 then -- Mount is usable in water
          InsertMount(i, mounts, tonumber(speed), spellID, "swim")
        end
        
        if bit.band(typeFlags or 0, 0x1) ~= 0 then -- Is flying mount
          InsertMount(i, mounts, tonumber(speed), spellID, "fly")
        end
      end
    end
    
    local mountType = type(speed) == "string" and speed or swimming and "swim" or flyable and "fly" or "ground"
    if mountType == speed then
      speed = nil
    end
    
    self:DebugfIf({"debugOutput", "mountType"}, "Mount Type: %s", mountType)
    
    if self:GetOption("debugOutput", "initialMountPool") then
      self:Debug("Initial mount pool:")
      for i, cats in ipairs{mounts.fav, mounts} do
        for _, cat in ipairs{"fly", "ground", "swim"} do
          local lis = cats[cat]
          self:Debugf("  %s%s:", i == 1 and "fav " or "", cat)
          for _, spellID in ipairs(lis) do
            local name = C_MountJournal.GetDisplayedMountInfo(companionMap[spellID])
            self:Debug("    " .. name)
          end
        end
      end
    end
    
    local castingMount
    local validMounts, fastestSpeed = self:GetValidMounts(#mounts.fav[mountType] > 0 and mounts.fav[mountType] or mounts[mountType], mountType, speed)
    
    -- if mountType is "swim" or "fly" and couldn't find a proper mount, then use fallback "ground"
    if (not validMounts or #validMounts == 0 or not fastestSpeed or fastestSpeed == 0 and speed ~= 0) and mountType ~= "ground" then
      self:DebugfIf({"debugOutput", "usingFallbackMount"}, "Falling back to ground mount. Valid Mounts: %d, Fastest Speed: %s", not validMounts and 0 or #validMounts, tostring(fastestSpeed))
      mountType = "ground"
      validMounts = self:GetValidMounts(#mounts.fav[mountType] > 0 and mounts.fav[mountType] or mounts[mountType], mountType, speed)
    end
    if validMounts and #validMounts > 0 then
      castingMount = self:MountValidMount(validMounts, currentMount, companionMap, self:CanFlyingFail())
    end
    
    -- if we're in a "sketchy" area, the only solution (besides super detailed coordinate checking) seems to be attempting a ground mount in case the flying one failed
    if mountType == "fly" and self:CanFlyingFail() and castingMount then
      mountType = "ground"
      local validMounts = self:GetValidMounts(#mounts.fav[mountType] > 0 and mounts.fav[mountType] or mounts[mountType], mountType, speed)
      if validMounts and #validMounts > 0 then
        self:MountValidMount(validMounts, currentMount, companionMap)
      end
    end
    
  end
end



function Addon:CallCritter(input)
  local critters = {fav = {}}
  
  local currentPet
  
  local companionMap = {}
  for i = 1, GetNumCompanions"CRITTER" do
    local spellID, _, isSummoned = select(3, GetCompanionInfo("CRITTER", i))
    companionMap[spellID] = i
    
    if isSummoned then
      currentPet = spellID
    end
    
    if self:CanAfford(spellID) then
      tinsert(critters, spellID)
      if Addon:GetOption("fav", spellID) then
        tinsert(critters.fav, spellID)
      end
    end
  end
  
  local validCritters = self:GetValidCritters(#critters.fav > 0 and critters.fav or critters, currentCritter)
  if #validCritters > 0 then
    self:CallValidCritter(validCritters, companionMap)
  end
end


function Addon:OnChatCommand(input)
  local arg = self:GetArgs(input, 1)
  
  local func = arg and self.chatArgs[arg] or nil
  if func then
    func(self)
  else
    self:OpenConfig(ADDON_NAME)
  end
end

-- Fix InterfaceOptionsFrame_OpenToCategory not actually opening the category (and not even scrolling to it)
-- Originally from BlizzBugsSuck (https://www.wowinterface.com/downloads/info17002-BlizzBugsSuck.html) and edited to not be global
do
  local function GetPanelName(panel)
    local tp = type(panel)
    local cat = INTERFACEOPTIONS_ADDONCATEGORIES
    if tp == "string" then
      for i = 1, #cat do
        local p = cat[i]
        if p.name == panel then
          if p.parent then
            return GetPanelName(p.parent)
          else
            return panel
          end
        end
      end
    elseif tp == "table" then
      for i = 1, #cat do
        local p = cat[i]
        if p == panel then
          if p.parent then
            return GetPanelName(p.parent)
          else
            return panel.name
          end
        end
      end
    end
  end
  
  local skip
  local function InterfaceOptionsFrame_OpenToCategory_Fix(panel)
    if skip --[[or InCombatLockdown()--]] then return end
    local panelName = GetPanelName(panel)
    if not panelName then return end -- if its not part of our list return early
    local noncollapsedHeaders = {}
    local shownPanels = 0
    local myPanel
    local t = {}
    local cat = INTERFACEOPTIONS_ADDONCATEGORIES
    for i = 1, #cat do
      local panel = cat[i]
      if not panel.parent or noncollapsedHeaders[panel.parent] then
        if panel.name == panelName then
          panel.collapsed = true
          t.element = panel
          InterfaceOptionsListButton_ToggleSubCategories(t)
          noncollapsedHeaders[panel.name] = true
          myPanel = shownPanels + 1
        end
        if not panel.collapsed then
          noncollapsedHeaders[panel.name] = true
        end
        shownPanels = shownPanels + 1
      end
    end
    local min, max = InterfaceOptionsFrameAddOnsListScrollBar:GetMinMaxValues()
    if shownPanels > 15 and min < max then
      local val = (max/(shownPanels-15))*(myPanel-2)
      InterfaceOptionsFrameAddOnsListScrollBar:SetValue(val)
    end
    skip = true
    InterfaceOptionsFrame_OpenToCategory(panel)
    skip = false
  end
  
  local isMe = false
  hooksecurefunc("InterfaceOptionsFrame_OpenToCategory", function(...)
    if skip then return end
    if Addon:GetOption("fix", "InterfaceOptionsFrameForAll") or Addon:GetOption("fix", "InterfaceOptionsFrameForMe") and isMe then
      Addon:DebugIf({"debugOutput", "InterfaceOptionsFrameFix"}, "Patching Interface Options")
      InterfaceOptionsFrame_OpenToCategory_Fix(...)
      isMe = false
    end
  end)
  
  function Addon:OpenConfig(category)
    isMe = Addon:GetOption("fix", "InterfaceOptionsFrameForMe")
    if isMe then
      InterfaceOptionsFrame_OpenToCategory(category)
      isMe = true
    end
    InterfaceOptionsFrame_OpenToCategory(category)
  end
end

function Addon:ResetProfile(category)
  self:GetDB():ResetProfile()
  self.AceConfigRegistry:NotifyChange(category)
end
function Addon:CreateOptionsCategory(categoryName, options)
  local category = ADDON_NAME .. (categoryName and ("." .. categoryName) or "")
  self.AceConfig:RegisterOptionsTable(category, options)
  local Panel = self.AceConfigDialog:AddToBlizOptions(category, categoryName, categoryName and ADDON_NAME or nil)
  Panel.default = function() self:ResetProfile(category) end
  return Panel
end

function Addon:CreateOptions()
  self:MakeAddonOptions(self.chatCommands[1])
  
  -- Profile Options
  do
    local args = {"profiles", "profile", "prof", "pro", "pr", "p"}
    local profileOptions = self.AceDBOptions:GetOptionsTable(self:GetDB())
    local categoryName = profileOptions.name
    profileOptions.name = format("%s v%s > %s  (/%s %s)", ADDON_NAME, tostring(self:GetOption"version"), profileOptions.name, self.chatCommands[1], args[1])
    local panel = self:CreateOptionsCategory(categoryName, profileOptions)
    local function OpenOptions() return self:OpenConfig(panel) end
    for _, arg in ipairs(args) do
      self.chatArgs[arg] = OpenOptions
    end
  end
  
  -- Debug Options
  if self:IsDebugEnabled() then
    self:MakeDebugOptions(self.L["Debug"], self.chatCommands[1], "debug", "db", "d")
  end
end

function Addon:InitDB()
  local configVersion = self.SemVer(self:GetOption"version" or tostring(self.Version))
  
  
  if not self:GetOption"version" then
    -- first run
    
  end
  
  
  
  self:SetOption(tostring(self.Version), "version")
end


function Addon:OnInitialize()
  self.db        = self.AceDB:New(("%sDB"):format(ADDON_NAME), self:MakeDefaultOptions(), true)
  self.dbDefault = self.AceDB:New({}                         , self:MakeDefaultOptions(), true)
  
  self.chatCommands = {"zk", "zookeeper", ADDON_NAME:lower()}
  for _, chatCommand in ipairs(self.chatCommands) do
    self:RegisterChatCommand(chatCommand, "OnChatCommand", true)
  end
  
  self:RegisterChatCommand("mount",     "Mount")
  self:RegisterChatCommand("critter",   "CallCritter")
  self:RegisterChatCommand("companion", "CallCritter")
end

function Addon:OnEnable()
  self.Version = self.SemVer(GetAddOnMetadata(ADDON_NAME, "Version"))
  self:InitDB()
  self:GetDB().RegisterCallback(self, "OnProfileChanged", "InitDB")
  self:GetDB().RegisterCallback(self, "OnProfileCopied" , "InitDB")
  self:GetDB().RegisterCallback(self, "OnProfileReset"  , "InitDB")
  
  self.chatArgs = {}
  do
    local function PrintVersion() self:Printf("Version: %s", tostring(self.Version)) end
    for _, arg in ipairs{"version", "vers", "ver", "v"} do self.chatArgs[arg] = PrintVersion end
  end
  self:CreateOptions()
  
  self.UI:Init()
  
  self.addonLoadHooks = {}
  self:RegisterEvent("ADDON_LOADED", function(e, addon)
    if self.addonLoadHooks[addon] then
      self.addonLoadHooks[addon]()
    end
  end)
end

function Addon:OnDisable()
  
end


















