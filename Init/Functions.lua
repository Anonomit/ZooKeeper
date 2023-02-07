
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local tblConcat = table.concat
local tblRemove = table.remove

local mathMin   = math.min
local mathMax   = math.max











--  ██████╗  █████╗ ████████╗ █████╗ ██████╗  █████╗ ███████╗███████╗
--  ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝
--  ██║  ██║███████║   ██║   ███████║██████╔╝███████║███████╗█████╗  
--  ██║  ██║██╔══██║   ██║   ██╔══██║██╔══██╗██╔══██║╚════██║██╔══╝  
--  ██████╔╝██║  ██║   ██║   ██║  ██║██████╔╝██║  ██║███████║███████╗
--  ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝

do
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
  function Addon:ToggleOption(...)
    return Addon:SetOption(not Addon:GetOption(...), ...)
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
end






--   ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--   ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do
  -- Fix InterfaceOptionsFrame_OpenToCategory not actually opening the category (and not even scrolling to it)
  -- Originally from BlizzBugsSuck (https://www.wowinterface.com/downloads/info17002-BlizzBugsSuck.html) and edited to not be global
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
end






--  ███╗   ██╗██╗   ██╗███╗   ███╗██████╗ ███████╗██████╗ ███████╗
--  ████╗  ██║██║   ██║████╗ ████║██╔══██╗██╔════╝██╔══██╗██╔════╝
--  ██╔██╗ ██║██║   ██║██╔████╔██║██████╔╝█████╗  ██████╔╝███████╗
--  ██║╚██╗██║██║   ██║██║╚██╔╝██║██╔══██╗██╔══╝  ██╔══██╗╚════██║
--  ██║ ╚████║╚██████╔╝██║ ╚═╝ ██║██████╔╝███████╗██║  ██║███████║
--  ╚═╝  ╚═══╝ ╚═════╝ ╚═╝     ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝

do
  function Addon:Round(num, nearest)
    nearest = nearest or 1
    local lower = math.floor(num / nearest) * nearest
    local upper = lower + nearest
    return (upper - num < num - lower) and upper or lower
  end
  
  function Addon:Clamp(min, num, max)
    assert(type(min) == "number", "Can't clamp. min is " .. type(min))
    assert(type(max) == "number", "Can't clamp. max is " .. type(max))
    assert(min <= max, format("Can't clamp. min (%d) > max (%d)", min, max))
    return mathMin(mathMax(num, min), max)
  end
end






--  ████████╗ █████╗ ██████╗ ██╗     ███████╗███████╗
--  ╚══██╔══╝██╔══██╗██╔══██╗██║     ██╔════╝██╔════╝
--     ██║   ███████║██████╔╝██║     █████╗  ███████╗
--     ██║   ██╔══██║██╔══██╗██║     ██╔══╝  ╚════██║
--     ██║   ██║  ██║██████╔╝███████╗███████╗███████║
--     ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚══════╝

do
  function Addon:Map(t, ValMap, KeyMap)
    if type(KeyMap) == "table" then
      local keyTbl = KeyMap
      KeyMap = function(v, k, self) return keyTbl[k] end
    end
    if type(ValMap) == "table" then
      local valTbl = KeyMap
      ValMap = function(v, k, self) return valTbl[k] end
    end
    local new = {}
    for k, v in next, t, nil do
      local key, val = k, v
      if KeyMap then
        key = KeyMap(v, k, t)
      end
      if ValMap then
        val = ValMap(v, k, t)
      end
      if key then
        new[key] = val
      end
    end
    local meta = getmetatable(t)
    if meta then
      setmetatable(new, meta)
    end
    return new
  end
  
  function Addon:MakeLookupTable(t, val, keepOrigVals)
    local ValFunc
    if val ~= nil then
      if type(val) == "function" then
        ValFunc = val
      else
        ValFunc = function() return val end
      end
    end
    local new = {}
    for k, v in next, t, nil do
      if ValFunc then
        new[v] = ValFunc(v, k, t)
      else
        new[v] = k
      end
      if keepOrigVals and new[k] == nil then
        new[k] = v
      end
    end
    return new
  end
end



--  ███╗   ███╗ ██████╗ ██╗   ██╗███╗   ██╗████████╗███████╗
--  ████╗ ████║██╔═══██╗██║   ██║████╗  ██║╚══██╔══╝██╔════╝
--  ██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║   ██║   ███████╗
--  ██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║   ██║   ╚════██║
--  ██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║   ██║   ███████║
--  ╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝

do
  
  -- check if we meet normal conditions for flying in our location
  function Addon:CanFly()
    if not IsFlyableArea() then return false end
    return self.flightPermissionLocations[self:GetMapID()]()
  end
  
  -- check if we're in an area that is "flyable" but sometimes actually prohibits flying mounts
  function Addon:CanFlyingFail()
    return self.flyingFailureLocations[self:GetMapID()]()
  end
  
  
  function Addon:GetMountInfo(spellID)
    local info = self.mounts[spellID]
    if info then
      return unpack(info, 1, 8)
    end
  end
  
  function Addon:GetMountSpeed(spellID, speedType)
    local info = self.mounts[spellID]
    if info then
      if speedType == "ground" then
        return info[4]
      elseif speedType == "fly" then
        return info[5]
      elseif speedType == "swim" then
        return info[6]
      end
    end
  end
  
  function Addon:CanMountBeSpeed(spellID, speedType, exactSpeed)
    local speed = self:GetMountSpeed(spellID, speedType)
    if speed then
      if type(speed) == "table" then
        for i = 1, #speed do
          if speed[i] == exactSpeed or speed[i] == exactSpeed - 100 then
            return true
          end
        end
        return false
      else
        return speed == exactSpeed or speed == exactSpeed - 100
      end
    end
    return false
  end
  
  function Addon:GetMountFastestSpeed(spellID, speedType)
    local speed = self:GetMountSpeed(spellID, speedType)
    if speed then
      local fastest = speed
      if type(speed) == "table" then
        fastest = speed[1]
        for i = 2, #speed do
          if speed[i] > fastest then
            fastest = speed
          end
        end
      end
      return fastest
    end
  end
  
  
  do
    local function IsAQMount(spellID)
      return Addon.aqMounts[spellID]
    end
    
    local function IsInAQ(inAQ)
      if inAQ == nil then
        return self:IsInAQ()
      end
      return inAQ
    end
    
    local function IsFlyable(flyable)
      if flyable == nil then
        return self:CanFly()
      end
      return flyable
    end
    
    local function AmSwimming(swimming)
      if swimming == nil then
        return IsSwimming()
      end
      return swimming
    end
    
    -- can leave flyable/swimming/inAQ nil and they will be retrieved if needed
    function Addon:IsMountUsable(spellID, flyable, swimming, inAQ)
      local _, typeFlags, _, _, _, _, faction, UsableFunc = Addon:GetMountInfo(spellID)
      
      if bit.band(typeFlags or 0, 0x1) ~= 0 and not IsFlyable(flyable) then
        return false
      end
      
      if bit.band(typeFlags or 0, 0x2) == 0 and AmSwimming(swimming) then
        return false
      end
      
      if Addon.expansionLevel >= Addon.expansions.wrath then
        if IsAQMount(spellID) then
          return IsInAQ(inAQ)
        end
      else
        if IsInAQ(inAQ) then
          return IsAQMount(spellID)
        elseif IsAQMount(spellID) then
          return false
        end
      end
      
      return true
    end
  end
  
  
  function Addon:CanAfford(spellID)
    local reagent = self.companionReagents[spellID]
    return not reagent or GetItemCount(reagent) > 0
  end
end



--  ██╗      ██████╗  ██████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██║     ██╔═══██╗██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██║     ██║   ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║     ██║   ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ███████╗╚██████╔╝╚██████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do
  function Addon:GetMapID()
    return (select(8, GetInstanceInfo()))
  end
  
  function Addon:IsInAQ()
    return self:GetMapID() == 531
  end
end

