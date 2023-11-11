

local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")


Addon.AceConfig         = LibStub"AceConfig-3.0"
Addon.AceConfigDialog   = LibStub"AceConfigDialog-3.0"
Addon.AceConfigRegistry = LibStub"AceConfigRegistry-3.0"
Addon.AceDB             = LibStub"AceDB-3.0"
Addon.AceDBOptions      = LibStub"AceDBOptions-3.0"

Addon.SemVer = LibStub"SemVer"




local strMatch     = string.match
local strSub       = string.sub

local tblConcat    = table.concat
local tblSort      = table.sort
local tblRemove    = table.remove

local mathFloor    = math.floor
local mathMin      = math.min
local mathMax      = math.max
local mathRandom   = math.random

local ipairs       = ipairs
local next         = next
local unpack       = unpack
local select       = select
local type         = type
local format       = format
local tinsert      = tinsert
local strjoin      = strjoin
local tostring     = tostring
local tonumber     = tonumber
local getmetatable = getmetatable
local setmetatable = setmetatable
local assert       = assert
local random       = random








--  ██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗ 
--  ██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝ 
--  ██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗
--  ██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║
--  ██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝
--  ╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝ 


do
  Addon.debugPrefix = "[" .. BINDING_HEADER_DEBUG .. "]"
  
  local debugMode = false
  
  --@debug@
  do
    debugMode = true
    
    -- GAME_LOCALE = "enUS" -- AceLocale override
    
    -- TOOLTIP_UPDATE_TIME = 10000
    
    -- DECIMAL_SEPERATOR = ","
  end
  --@end-debug@
  
  function Addon:IsDebugEnabled()
    if self.db then
      return self:GetGlobalOption"debug"
    else
      return debugMode
    end
  end
  
  function Addon:Dump(t)
    return DevTools_Dump(t)
  end
  
  local function Debug(self, methodName, ...)
    if not self:IsDebugEnabled() then return end
    if self.GetGlobalOption and self:GetGlobalOption("debugOutput", "suppressAll") then return end
    return self[methodName](self, ...)
  end
  function Addon:Debug(...)
    return Debug(self, "Print", self.debugPrefix, ...)
  end
  function Addon:Debugf(...)
    return Debug(self, "Printf", "%s " .. select(1, ...), self.debugPrefix, select(2, ...))
  end
  function Addon:DebugDump(t, header)
    if header then
      Debug(self, "Print", tostring(header) .. ":")
    end
    return self:Dump(t)
  end
  
  local function DebugIf(self, methodName, keys, ...)
    if self.GetOption and self:GetOption(unpack(keys)) then
      return self[methodName](self, ...)
    end
  end
  function Addon:DebugIf(keys, ...)
    return DebugIf(self, "Debug", keys, ...)
  end
  function Addon:DebugfIf(keys, ...)
    return DebugIf(self, "Debugf", keys, ...)
  end
  function Addon:DebugDumpIf(keys, ...)
    return DebugIf(self, "DebugDump", keys, ...)
  end
  
  local function DebugIfOutput(self, methodName, key, ...)
    if self.GetGlobalOption and self:GetGlobalOption("debugOutput", key) then
      return self[methodName](self, ...)
    end
  end
  function Addon:DebugIfOutput(key, ...)
    return DebugIfOutput(self, "Debug", key, ...)
  end
  function Addon:DebugfIfOutput(key, ...)
    return DebugIfOutput(self, "Debugf", key, ...)
  end
  function Addon:DebugDumpIfOutput(key, ...)
    return DebugIfOutput(self, "DebugDump", key, ...)
  end
  
  function Addon:DebugData(t)
    local texts = {}
    for _, data in ipairs(t) do
      if data[2] ~= nil then
        if type(data[2]) == "string" then
          tinsert(texts, data[1] .. ": '" .. data[2] .. "'")
        else
          tinsert(texts, data[1] .. ": " .. tostring(data[2]))
        end
      end
    end
    self:Debug(tblConcat(texts, ", "))
  end
  function Addon:DebugDataIf(keys, ...)
    if self.GetOption and self:GetOption(unpack(keys)) then
      return self:DebugData(...)
    end
  end
  
  
  function Addon:GetDebugView(key)
    return self:IsDebugEnabled() and not self:GetGlobalOption("debugView", "suppressAll") and self:GetGlobalOption("debugView", key)
  end
  
  do
    local function GetErrorHandler(errFunc)
      if Addon:IsDebugEnabled() and (not Addon:IsDBLoaded() or Addon:GetGlobalOption"debugShowLuaErrors") then
        return function(...)
          geterrorhandler()(...)
          if errFunc then
            Addon:xpcall(errFunc)
          end
        end
      end
      return nop
    end
    function Addon:xpcall(func, errFunc)
      return xpcall(func, GetErrorHandler(errFunc))
    end
    function Addon:xpcallSilent(func, errFunc)
      return xpcall(func, nop)
    end
    function Addon:Throw(...)
      if Addon:IsDebugEnabled() and (not Addon:IsDBLoaded() or Addon:GetGlobalOption"debugShowLuaErrors") then
        geterrorhandler()(...)
      end
    end
    function Addon:Throwf(...)
      local args = {...}
      local count = select("#", ...)
      self:xpcall(function() self:Throw(format(unpack(args, 1, count))) end)
    end
    function Addon:Assert(bool, ...)
      if not bool then
        self:Throw(...)
      end
    end
    function Addon:Assertf(bool, ...)
      if not bool then
        self:Throwf(...)
      end
    end
  end
end





--  ███████╗██╗  ██╗██████╗  █████╗ ███╗   ██╗███████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔════╝╚██╗██╔╝██╔══██╗██╔══██╗████╗  ██║██╔════╝██║██╔═══██╗████╗  ██║██╔════╝
--  █████╗   ╚███╔╝ ██████╔╝███████║██╔██╗ ██║███████╗██║██║   ██║██╔██╗ ██║███████╗
--  ██╔══╝   ██╔██╗ ██╔═══╝ ██╔══██║██║╚██╗██║╚════██║██║██║   ██║██║╚██╗██║╚════██║
--  ███████╗██╔╝ ██╗██║     ██║  ██║██║ ╚████║███████║██║╚██████╔╝██║ ╚████║███████║
--  ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do
  Addon.expansions = {
    retail  = 10,
    wrath   = 3,
    wotlk   = 3,
    tbc     = 2,
    bcc     = 2,
    classic = 1,
  }
  Addon.expansionLevel = tonumber(GetBuildInfo():match"^(%d+)%.")
  if Addon.expansionLevel >= Addon.expansions.retail then
    Addon.expansionName = "retail"
  elseif Addon.expansionLevel >= Addon.expansions.wrath then
    Addon.expansionName = "wrath"
  elseif Addon.expansionLevel == Addon.expansions.tbc then
    Addon.expansionName = "tbc"
  elseif Addon.expansionLevel == Addon.expansions.classic then
    Addon.expansionName = "classic"
  end
  Addon.isRetail  = Addon.expansionName == "retail"
  Addon.isWrath   = Addon.expansionName == "wrath"
  Addon.isTBC     = Addon.expansionName == "tbc"
  Addon.isClassic = Addon.expansionName == "classic"
end





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
  
  local onOptionSetHandlers = {}
  function Addon:RegisterOptionSetHandler(func)
    tinsert(onOptionSetHandlers, func)
    return #onOptionSetHandlers
  end
  function Addon:UnrgisterOptionSetHandler(id)
    onOptionSetHandlers[id] = nil
  end
  
  local function OnOptionSet(self, val, ...)
    if not self:GetDB() then return end -- db hasn't loaded yet
    self:DebugfIfOutput("optionSet", "Setting %s: %s", strjoin(" > ", ...), tostring(val))
    for id, func in next, onOptionSetHandlers, nil do
      if type(func) == "function" then
        func(self, val, ...)
      else
        self[func](self, val, ...)
      end
    end
  end
  
  local dbTables = {
    {"dbDefault", "Default", true},
    {"db", ""},
  }
  local dbTypes = {
    {"profile", ""},
    {"global", "Global"},
  }
  
  local defaultKey, defaultName
  
  for _, dbType in ipairs(dbTables) do
    local dbKey, dbName, isDefault = unpack(dbType, 1, 3)
    if isDefault then
      defaultKey  = dbKey
      defaultName = dbName
    end
    
    local IsDBLoaded = format("Is%sDBLoaded", dbName)
    local GetDB      = format("Get%sDB",      dbName)
    
    Addon[IsDBLoaded] = function(self)
    return self[dbKey] ~= nil
    end
    Addon[GetDB] = function(self)
      return self[dbKey]
    end
    
    for _, dbSection in ipairs(dbTypes) do
      local typeKey, typeName = unpack(dbSection, 1, 2)
      
      local GetOption        = format("Get%s%sOption", dbName, typeName)
      local GetDefaultOption = format("Get%s%sOption", defaultName, typeName)
      
      Addon[GetOption] = function(self, ...)
        assert(self[dbKey], format("Attempted to access database before initialization: %s", tblConcat({dbKey, typeKey, ...}, " > ")))
        local val = self[dbKey][typeKey]
        for _, key in ipairs{...} do
          assert(type(val) == "table", format("Bad database access: %s", tblConcat({dbKey, typeKey, ...}, " > ")))
          val = val[key]
        end
        if type(val) == "table" then
          self:Debugf("[Warning] Database request returned a table: %s", tblConcat({dbKey, typeKey, ...}, " > "))
        end
        return val
      end
      
      if not isDefault then
        local SetOption    = format("Set%s%sOption",    dbName, typeName)
        local ToggleOption = format("Toggle%s%sOption", dbName, typeName)
        local ResetOption  = format("Reset%s%sOption",  dbName, typeName)
      
        Addon[SetOption] = function(self, val, ...)
          assert(self[dbKey], format("Attempted to access database before initialization: %s = %s", tblConcat({dbKey, typeKey, ...}, " > "), tostring(val)))
          local keys = {...}
          local lastKey = tblRemove(keys, #keys)
          local tbl = self[dbKey][typeKey]
          for _, key in ipairs(keys) do
            assert(type(tbl[key]) == "table", format("Bad database access: %s = %s", tblConcat({dbKey, typeKey, ...}, " > "), tostring(val)))
            tbl = tbl[key]
          end
          tbl[lastKey] = val
          OnOptionSet(Addon, val, dbKey, typeKey, ...)
        end
        
        Addon[ToggleOption] = function(self, ...)
          return self[SetOption](self, not self[GetOption](self, ...), ...)
        end
        
        Addon[ResetOption] = function(self, ...)
          return self[SetOption](self, Addon.Copy(self, self[GetDefaultOption](self, ...)), ...)
        end
      end
      
    end
  end
end





--  ███████╗██╗   ██╗███████╗███╗   ██╗████████╗███████╗
--  ██╔════╝██║   ██║██╔════╝████╗  ██║╚══██╔══╝██╔════╝
--  █████╗  ██║   ██║█████╗  ██╔██╗ ██║   ██║   ███████╗
--  ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║╚██╗██║   ██║   ╚════██║
--  ███████╗ ╚████╔╝ ███████╗██║ ╚████║   ██║   ███████║
--  ╚══════╝  ╚═══╝  ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝

do
  local function Call(func, ...)
    local args = {...}
    if type(func) == "function" then
      Addon:xpcall(function() func(unpack(args)) end)
    else
      Addon:xpcall(function() Addon[func](unpack(args)) end)
    end
  end
  
  local onEventCallbacks = {}
  local function OnEvent(event, ...)
    local t = onEventCallbacks[event]
    Addon:Assertf(t, "Event %s is registered, but no callbacks were found", event)
    for i, func in ipairs(t) do
      Call(func, Addon, event, ...)
    end
  end
  
  function Addon:RegisterEventCallback(event, func)
    local t = onEventCallbacks[event] or {}
    tinsert(t, func)
    if #t == 1 then
      onEventCallbacks[event] = t
      self:RegisterEvent(event, OnEvent)
    end
    return #t
  end
  function Addon:RegisterSingleEventCallback(event, ...)
    local id = self:RegisterEventCallback(event, ...)
    local func = onEventCallbacks[event][id]
    onEventCallbacks[event][id] = function(...) func(...) self:UnregisterEventCallback(event, id) end
    return id
  end
  function Addon:UnregisterEventCallbacks(event)
    self:Assertf(onEventCallbacks[event], "Attempted to unregister event %s, but no callbacks were found", event)
    onEventCallbacks[event] = nil
    self:UnregisterEvent(event)
  end
  function Addon:UnregisterEventCallback(event, id)
    local t = onEventCallbacks[event] or {}
    self:Assertf(t[id], "Attempted to unregister callback %s from event %s, but it was not found", id, event)
    tblRemove(t, id)
    if #t == 0 then
      self:UnregisterEventCallbacks(event)
    end
  end
  
  
  local onInitializeCallbacks = {}
  function Addon:RunInitializeCallbacks()
    for i, func in ipairs(onInitializeCallbacks) do
      Call(func, Addon)
    end
  end
  function Addon:RegisterInitializeCallback(func)
    tinsert(onInitializeCallbacks, func)
    return #onInitializeCallbacks
  end
  function Addon:UnregisterInitializeCallbacks()
    self:Assert(#onInitializeCallbacks > 0, "Attempted to unregister initialize callbacks, but none were found")
    wipe(onInitializeCallbacks)
  end
  function Addon:UnregisterInitializeCallback(id)
    self:Assertf(onInitializeCallbacks[id], "Attempted to unregister initialize callback %s, but it was not found", id)
    tblRemove(onInitializeCallbacks, id)
  end
  
  
  local onEnableCallbacks = {}
  function Addon:RunEnableCallbacks()
    for i, func in ipairs(onEnableCallbacks) do
      Call(func, Addon)
    end
  end
  function Addon:RegisterEnableCallback(func)
    tinsert(onEnableCallbacks, func)
    return #onEnableCallbacks
  end
  function Addon:UnregisterEnableCallbacks()
    self:Assert(#onEnableCallbacks > 0, "Attempted to unregister enable callbacks, but none were found")
    wipe(onEnableCallbacks)
  end
  function Addon:UnregisterEnableCallback(id)
    self:Assertf(onEnableCallbacks[id], "Attempted to unregister enable callback %s, but it was not found", id)
    tblRemove(onEnableCallbacks, id)
  end
  
  
  local onAddonLoadCallbacks = {}
  function Addon:OnAddonLoad(addonName, func)
    local loaded, finished = IsAddOnLoaded(addonName)
    if finished then
      Call(func, self)
    else
      local id
      id = self:RegisterEventCallback("ADDON_LOADED", function(self, event, addon)
        if addon == addonName then
          Call(func, self)
          self:UnregisterEventCallback("ADDON_LOADED", id)
        end
      end)
    end
  end
  
  function Addon:OnCombatEnd(func)
    if not InCombatLockdown() then
      Call(func, self)
    else
      self:RegisterSingleEventCallback("PLAYER_REGEN_ENABLED", function() Call(func, self) end)
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
  local usingSettingsPanel = Settings and Settings.RegisterCanvasLayoutCategory -- from AceConfigDialog
  local SettingsFrame = usingSettingsPanel and SettingsPanel or InterfaceOptionsFrame
  local blizzardCategory
  
  -- Fix InterfaceOptionsFrame_OpenToCategory not actually opening the category (and not even scrolling to it)
  -- Originally from BlizzBugsSuck (https://www.wowinterface.com/downloads/info17002-BlizzBugsSuck.html) and edited to not be global
  if not usingSettingsPanel then
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
      if Addon:GetGlobalOption("fix", "InterfaceOptionsFrameForAll") or Addon:GetGlobalOption("fix", "InterfaceOptionsFrameForMe") and isMe then
        Addon:DebugIfOutput("InterfaceOptionsFrameFix", "Patching Interface Options")
        InterfaceOptionsFrame_OpenToCategory_Fix(...)
        isMe = false
      end
    end)
  end
  
  function Addon:OpenBlizzardConfig(category)
    if usingSettingsPanel then
      Settings.OpenToCategory(blizzardCategory)
    else
      isMe = Addon:GetGlobalOption("fix", "InterfaceOptionsFrameForMe")
      if isMe then
        InterfaceOptionsFrame_OpenToCategory(blizzardCategory)
        isMe = true
      end
      InterfaceOptionsFrame_OpenToCategory(blizzardCategory)
    end
  end
  function Addon:CloseBlizzardConfig()
    if usingSettingsPanel then
      SettingsFrame:Close(true)
    else
      SettingsFrame:Hide()
    end
  end
  function Addon:ToggleBlizzardConfig(...)
    if SettingsFrame:IsShown() then
      self:CloseBlizzardConfig(...)
    else
      self:OpenBlizzardConfig(...)
    end
  end
  
  function Addon:OpenConfig(...)
    self.AceConfigDialog:Open(ADDON_NAME)
    if select("#", ...) > 0 then
      self.AceConfigDialog:SelectGroup(ADDON_NAME, ...)
    end
  end
  function Addon:CloseConfig()
    self.AceConfigDialog:Close(ADDON_NAME)
  end
  function Addon:ToggleConfig(...)
    if self.AceConfigDialog.OpenFrames[ADDON_NAME] then
      self:CloseConfig()
    else
      self:OpenConfig(...)
      self.AceConfigDialog:SelectGroup(ADDON_NAME, ...)
    end
  end
  
  
  function Addon:ResetProfile(category)
    self:GetDB():ResetProfile()
    self.AceConfigRegistry:NotifyChange(category)
  end
  
  function Addon:CreateBlizzardOptionsCategory(options)
    local blizzardOptions = ADDON_NAME .. ".Blizzard"
    self.AceConfig:RegisterOptionsTable(blizzardOptions, options)
    local Panel, id = self.AceConfigDialog:AddToBlizOptions(blizzardOptions, ADDON_NAME)
    blizzardCategory = id
    Panel.default = function() self:ResetProfile(blizzardOptions) end
    return Panel
  end
end




--   ██████╗██╗  ██╗ █████╗ ████████╗
--  ██╔════╝██║  ██║██╔══██╗╚══██╔══╝
--  ██║     ███████║███████║   ██║   
--  ██║     ██╔══██║██╔══██║   ██║   
--  ╚██████╗██║  ██║██║  ██║   ██║   
--   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   

do
  Addon.chatArgs = {}

  function Addon:RegisterChatArg(arg, func)
    Addon.chatArgs[arg] = func
  end

  function Addon:RegisterChatArgAliases(arg, func)
    for i = #arg, 1, -1 do
      local alias = strSub(arg, 1, i)
      if not self.chatArgs[alias] then
        self:RegisterChatArg(alias, func)
      end
    end
    Addon.chatArgs[arg] = func
  end

  function Addon:OnChatCommand(input)
    local args = {self:GetArgs(input, 1)}
    
    local func = args[1] and self.chatArgs[args[1]] or nil
    if func then
      func(self, unpack(args))
    else
      self:OpenConfig()
    end
  end

  function Addon:InitChatCommands(slashKeywords)
    for i, chatCommand in ipairs(slashKeywords) do
      if i == 1 then
        self:MakeAddonOptions(chatCommand)
        self:MakeBlizzardOptions(chatCommand)
      end
      self:RegisterChatCommand(chatCommand, "OnChatCommand", true)
    end

    local function PrintVersion() self:Printf("Version: %s", tostring(self.version)) end
    self:RegisterChatArgAliases("version", PrintVersion)
  end
end




--   ██████╗ ██████╗ ██╗      ██████╗ ██████╗ ███████╗
--  ██╔════╝██╔═══██╗██║     ██╔═══██╗██╔══██╗██╔════╝
--  ██║     ██║   ██║██║     ██║   ██║██████╔╝███████╗
--  ██║     ██║   ██║██║     ██║   ██║██╔══██╗╚════██║
--  ╚██████╗╚██████╔╝███████╗╚██████╔╝██║  ██║███████║
--   ╚═════╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

do
  function Addon:GetHexFromColor(r, g, b)
    return format("%02x%02x%02x", r, g, b)
  end
  function Addon:ConvertColorFromBlizzard(r, g, b)
    return self:GetHexFromColor(self:Round(r*255, 1), self:Round(g*255, 1), self:Round(b*255, 1))
  end
  function Addon:GetTextColorAsHex(frame)
    return self:ConvertColorFromBlizzard(frame:GetTextColor())
  end
  
  function Addon:ConvertHexToRGB(hex)
    return tonumber(strSub(hex, 1, 2), 16), tonumber(strSub(hex, 3, 4), 16), tonumber(strSub(hex, 5, 6), 16), 1
  end
  function Addon:ConvertColorToBlizzard(hex)
    return tonumber(strSub(hex, 1, 2), 16) / 255, tonumber(strSub(hex, 3, 4), 16) / 255, tonumber(strSub(hex, 5, 6), 16) / 255, 1
  end
  function Addon:SetTextColorFromHex(frame, hex)
    frame:SetTextColor(self:ConvertColorToBlizzard(hex))
  end
  
  function Addon:TrimAlpha(hex)
    return strMatch(hex, "%x?%x?(%x%x%x%x%x%x)") or hex
  end
  function Addon:MakeColorCode(hex, text)
    return format("|cff%s%s%s", hex, text or "", text and "|r" or "")
  end
  
  function Addon:StripColorCode(text, hex)
    local pattern = hex and ("|c%x%x" .. hex) or "|c%x%x%x%x%x%x%x%x"
    return self:ChainGsub(text, {pattern, "|r", ""})
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
    local lower = mathFloor(num / nearest) * nearest
    local upper = lower + nearest
    return (upper - num < num - lower) and upper or lower
  end
  
  function Addon:Clamp(min, num, max)
    assert(not min or type(min) == "number", "Can't clamp. min is " .. type(min))
    assert(not max or type(max) == "number", "Can't clamp. max is " .. type(max))
    assert(not min or not max or (min <= max), format("Can't clamp. min (%d) > max (%d)", min, max))
    if min then
      num = mathMax(num, min)
    end
    if max then
      num = mathMin(num, max)
    end
    return num
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

  function Addon:Filter(t, ...)
    local new = {}
    
    for i, v in pairs(t) do
      local pass = true
      for j = 1, select("#", ...) do
        local filter = select(j, ...)
        if not filter(v, i, t) then
          pass = false
          break
        end
      end
      if pass then
        tinsert(new, v)
      end
    end
    
    local meta = getmetatable(self)
    if meta then
      setmetatable(new, meta)
    end
    
    return new
  end
  
  function Addon:Squish(t)
    local new = { }
    for k in pairs(t) do
      tinsert(new, k)
    end
    tblSort(new)
    for i, k in ipairs(new) do
      new[i] = t[k]
    end
    return new
  end

  function Addon:Shuffle(t)
    for i = #t, 2, -1 do
      local j = math.random(i)
      t[i], t[j] = t[j], t[i]
    end
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
  
  function Addon:Random(t)
    return t[random(#t)]
  end
end
