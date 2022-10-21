

local ADDON_NAME, Data = ...




-- local Addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local Addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0")
Addon.onOptionSetHandlers = {}

-- Curseforge automatic packaging will comment this out
-- https://support.curseforge.com/en/support/solutions/articles/9000197281-automatic-packaging
--@debug@
  local debugMode = true
  
  -- GAME_LOCALE = "enUS" -- AceLocale override
--@end-debug@
function Addon:IsDebugEnabled()
  if self.GetOption then
    return self:GetOption"debug"
  else
    return debugMode
  end
end

do
  Addon.debugPrefix = "[" .. BINDING_HEADER_DEBUG .. "]"
  local function Debug(self, methodName, ...)
    if not self:IsDebugEnabled() then return end
    if self.GetOption and self:GetOption("debugOutput", "suppressAll") then return end
    return self[methodName](self, ...)
  end
  function Addon:Debug(...)
    return Debug(self, "Print", self.debugPrefix, ...)
  end
  function Addon:Debugf(...)
    return Debug(self, "Printf", "%s " .. select(1, ...), self.debugPrefix, select(2, ...))
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
end


Addon.AceConfig         = LibStub"AceConfig-3.0"
Addon.AceConfigDialog   = LibStub"AceConfigDialog-3.0"
-- Addon.AceConfigRegistry = LibStub"AceConfigRegistry-3.0"
Addon.AceDB             = LibStub"AceDB-3.0"
Addon.AceDBOptions      = LibStub"AceDBOptions-3.0"

Addon.SemVer     = LibStub"SemVer"



do
  Addon.expansions = {
    retail  = 9,
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




local strLower  = string.lower
local strFind   = string.find
local strMatch  = string.match
local strSub    = string.sub
local strGsub   = string.gsub
local strGmatch = string.gmatch
local strByte   = string.byte

local mathMin   = math.min
local mathMax   = math.max
local mathFloor = math.floor

local tinsert   = table.insert
local tblRemove = table.remove
local tblConcat = table.concat
















local L = setmetatable({}, {
  __index = function(self, key)
    rawset(self, key, key)
    if Addon:IsDebugEnabled() then
      geterrorhandler()(ADDON_NAME..": Missing automatic translation for '"..tostring(key).."'")
    end
    return key
  end
})
Addon.L = L


L["Enable"]  = ENABLE
L["Disable"] = DISABLE
L["Enabled"] = VIDEO_OPTIONS_ENABLED
-- L["Disabled"] = ADDON_DISABLED
L["Modifiers:"] = MODIFIERS_COLON

L["never"] = strLower(CALENDAR_REPEAT_NEVER)
L["any"]   = strLower(SPELL_TARGET_TYPE1_DESC)
L["all"]   = strLower(SPELL_TARGET_TYPE12_DESC)

L["SHIFT key"] = SHIFT_KEY
L["CTRL key"]  = CTRL_KEY
L["ALT key"]   = ALT_KEY


L["Debug"]                        = BINDING_HEADER_DEBUG
L["Reload UI"]                    = RELOADUI
L["Hide messages like this one."] = COMBAT_LOG_MENU_SPELL_HIDE


L["Mounts"]     = MOUNTS
L["Companions"] = COMPANIONS





function Addon:Round(num, nearest)
  nearest = nearest or 1;
  local lower = mathFloor(num / nearest) * nearest;
  local upper = lower + nearest;
  return (upper - num < num - lower) and upper or lower;
end

function Addon:Clamp(min, num, max)
  assert(type(min) == "number", "Can't clamp. min is " .. type(min))
  assert(type(max) == "number", "Can't clamp. max is " .. type(max))
  assert(min <= max, format("Can't clamp. min (%d) > max (%d)", min, max))
  return mathMin(mathMax(num, min), max)
end


function Addon:GetHexFromColor(r, g, b)
  return format("%.2x%.2x%.2x", r, g, b)
end
function Addon:ConvertColorFromBlizzard(r, g, b)
  return self:GetHexFromColor(Addon:Round(r*255, 1), Addon:Round(g*255, 1), Addon:Round(b*255, 1))
end
function Addon:GetTextColorAsHex(frame)
  return self:ConvertColorFromBlizzard(frame:GetTextColor())
end

function Addon:ConvertColorToBlizzard(hex)
  return tonumber(strSub(hex, 1, 2), 16) / 255, tonumber(strSub(hex, 3, 4), 16) / 255, tonumber(strSub(hex, 5, 6), 16) / 255, 1
end
function Addon:SetTextColorFromHex(frame, hex)
  frame:SetTextColor(self:ConvertColorToBlizzard(hex))
end

function Addon:MakeColorCode(hex, text)
  return format("|cff%s%s%s", hex, text or "", text and "|r" or "")
end


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


local function passesFilters(v, k, tbl, ...)
  for filt in AnonTable(...):ivals() do
    if not filt(v, k, tbl) then
      return false
    end
  end
  return true
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





do
  local mountMeta = {__index = function() return false end}
  
  local groundMounts = setmetatable({
    [5784]  = true,
    [17454] = true,
    [22717] = true,
    [22719] = true,
    [22720] = true,
    [22723] = true,
    [23161] = true,
    [23338] = true,
    [60118] = true,
  }, mountMeta)
  
  local flyingMounts = setmetatable({
    [32240] = true,
    [32289] = true,
    [61451] = true,
  }, mountMeta)
  
  function Addon:IsGroundMount(spellID)
    return groundMounts[spellID]
  end
  
  function Addon:IsFlyingMount(spellID)
    return flyingMounts[spellID]
  end
end


