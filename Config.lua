
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
-- local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strGmatch = string.gmatch
local strGsub   = string.gsub
local strByte   = string.byte
local tinsert   = table.insert
local tblRemove = table.remove
local tblConcat = table.concat
local mathMin   = math.min
local mathMax   = math.max




--   ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
--  ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
--  ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
--  ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
--  ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--   ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ 



function Addon:MakeDefaultOptions()
  local fakeAddon = {
    db = {
      profile = {
        
        enabled    = true,
        invertMode = "none",
        modKeys = {
          ["*"] = true,
        },
        
        fav = {
          ["*"] = false,
        },
        
        -- Debug options
        debug = false,
          
        debugOutput = {
          ["*"] = false,
        },
        
        
        fix = {
          InterfaceOptionsFrameForMe  = true,
          InterfaceOptionsFrameForAll = false,
        },
      },
    },
  }
  return fakeAddon.db
end


--  ███████╗███╗   ██╗██████╗      ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
--  ██╔════╝████╗  ██║██╔══██╗    ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
--  █████╗  ██╔██╗ ██║██║  ██║    ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
--  ██╔══╝  ██║╚██╗██║██║  ██║    ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
--  ███████╗██║ ╚████║██████╔╝    ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--  ╚══════╝╚═╝  ╚═══╝╚═════╝      ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ 







function Addon:InitOptionTableHelpers()
  self.GUI = {}
  local GUI = self.GUI
  
  local defaultInc   = 1000
  local defaultOrder = 1000
  local order        = defaultOrder
  
  function GUI:GetOrder()
    return order
  end
  function GUI:SetOrder(newOrder)
    order = newOrder
    return self
  end
  function GUI:ResetOrder()
    order = defaultOrder
    return self
  end
  function GUI:Order(inc)
    self:SetOrder(self:GetOrder() + (inc or defaultInc))
    return self:GetOrder()
  end
  
  function GUI:CreateEntry(opts, keys, name, desc, widgetType, disabled, order)
    if type(keys) ~= "table" then keys = {keys} end
    local key = widgetType .. "_" .. (tblConcat(keys, ".") or "")
    opts.args[key] = {name = name, desc = desc, type = widgetType, order = order or self:Order(), disabled = disabled}
    opts.args[key].set = function(info, val)        Addon:SetOption(val, unpack(keys)) end
    opts.args[key].get = function(info)      return Addon:GetOption(unpack(keys))      end
    return opts.args[key]
  end
  
  function GUI:CreateHeader(opts, name)
    local option = self:CreateEntry(opts, self:Order(), name, nil, "header", nil, self:Order(0))
  end
  
  function GUI:CreateDescription(opts, desc, fontSize)
    local option = self:CreateEntry(opts, self:Order(), desc, nil, "description", nil, self:Order(0))
    option.fontSize = fontSize or "large"
    return option
  end
  function GUI:CreateDivider(opts, count, fontSize)
    for i = 1, count or 1 do
      self:CreateDescription(opts, " ", fontSize or "small")
    end
  end
  function GUI:CreateNewline(opts)
    return self:CreateDivider(opts, 1)
  end
  
  function GUI:CreateToggle(opts, keys, name, desc, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "toggle", disabled)
    return option
  end
  
  function GUI:CreateSelect(opts, keys, name, desc, values, sorting, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "select", disabled)
    option.values  = values
    option.sorting = sorting
    option.style   = "dropdown"
    return option
  end
  
  function GUI:CreateMultiSelect(opts, keys, name, desc, values, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "multiselect", disabled)
    option.values  = values
    return option
  end
  
  function GUI:CreateRange(opts, keys, name, desc, min, max, step, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "range", disabled)
    option.min   = min
    option.max   = max
    option.step  = step
    return option
  end
  
  function GUI:CreateInput(opts, keys, name, desc, multiline, disabled)
    local option     = self:CreateEntry(opts, keys, name, desc, "input", disabled)
    option.multiline = multiline
    return option
  end
  
  function GUI:CreateColor(opts, keys, name, desc, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "color", disabled)
    option.set   = function(info, r, g, b)        Addon:SetOption(Addon:ConvertColorFromBlizzard(r, g, b), unpack(keys)) end
    option.get   = function(info)          return Addon:ConvertColorToBlizzard(Addon:GetOption(unpack(keys)))            end
    return option
  end
  
  function GUI:CreateExecute(opts, key, name, desc, func, disabled)
    local option = self:CreateEntry(opts, key, name, desc, "execute", disabled)
    option.func  = func
    return option
  end
  
  function GUI:CreateGroup(opts, key, name, groupType, disabled)
    key = "group_" .. key
    opts.args[key] = {name = name, type = "group", childGroups = groupType, args = {}, order = self:Order(), disabled = disabled}
    return opts.args[key]
  end
  
  function GUI:CreateGroupBox(opts, name)
    local key = "group_" .. self:Order(-1)
    opts.args[key] = {name = name, type = "group", args = {}, order = self:Order(), inline = true}
    return opts.args[key]
  end
  
  function GUI:CreateGroupTop(name, groupType, disabled)
    return {name = name, type = "group", childGroups = groupType, args = {}, order = self:Order(), disabled = disabled}
  end
end




-- Addon options
function Addon:MakeAddonOptions(chatCmd)
  local title = format("%s v%s  (/%s)", ADDON_NAME, tostring(self:GetOption"version"), chatCmd)
  local panel = self:CreateOptionsCategory(nil, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title, "tab")
  
  GUI:CreateExecute(opts, {"openCritters"}, self.L["Companions"], nil, function() ToggleCharacter("PetPaperDollFrame", true) PetPaperDollFrame_SetTab(2) end)
  GUI:CreateNewline(opts)
  
  GUI:CreateExecute(opts, {"openMounts"}, self.L["Mounts"], nil, function() ToggleCharacter("PetPaperDollFrame", true) PetPaperDollFrame_SetTab(3) end)
  
  return opts
  end)
  function self:OpenAddonOptions() return self:OpenConfig(panel) end
end



-- Debug Options
function Addon:MakeDebugOptions(categoryName, chatCmd, arg1, ...)
  local title = format("%s v%s > %s  (/%s %s)", ADDON_NAME, tostring(self:GetOption"version"), categoryName, chatCmd, arg1)
  local panel = self:CreateOptionsCategory(categoryName, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title, "tab")
  
  -- Enable
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), self.L["Enable"])
    
    do
      local opts = GUI:CreateGroupBox(opts, "Debug")
      GUI:CreateToggle(opts, {"debug"}, self.L["Enable"])
      GUI:CreateNewline(opts)
      GUI:CreateExecute(opts, "reload", self.L["Reload UI"], nil, ReloadUI)
    end
  end
  
  -- Debug Output
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "Output")
    
    local disabled = not self:GetOption"debug"
    
    do
      local opts = GUI:CreateGroupBox(opts, "Suppress All")
      
      GUI:CreateToggle(opts, {"debugOutput", "suppressAll"}, self.debugPrefix .. " " .. self.L["Hide messages like this one."], nil, disabled).width = 2
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, "Message Types")
      
      local disabled = disabled or self:GetOption("debugOutput", "suppressAll")
      
      for _, data in ipairs{
        {"speed",              "Desired Speed"},
        {"zoneSpecs",          "Zone Specifications"},
        {"usable",             "Usable"},
        {"mountTypes",         "Mount Types"},
        {"mountType",          "Selected Mount Type"},
        {"initialMountPool",   "Initial Mount Pool"},
        {"candidates",         "Mount Candidates"},
        {"finalMountPool",     "Final Mount Pool"},
        {"usingFallbackMount", "Using Fallback Mount"},
      } do
        GUI:CreateToggle(opts, {"debugOutput", data[1]}, data[2], nil, disabled).width = 2
        GUI:CreateNewline(opts)
      end
      
      GUI:CreateToggle(opts, {"debugOutput", "InterfaceOptionsFrameFix"}, "Interface Options Patch", nil, disabled).width = 2
    end
  end
  
  -- Fixes
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "Fixes")
    
    do
      local opts = GUI:CreateGroupBox(opts, "Options Menu")
      
      GUI:CreateToggle(opts, {"fix", "InterfaceOptionsFrameForMe"}, "Fix Category Opening For Me", "Fix a bug with Interface Options so that it can be opened to this addon when scrolling would be required.").width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"fix", "InterfaceOptionsFrameForAll"}, "Fix Category Opening For All", "Fix a bug with Interface Options so that it can be opened to a category that isn't visible without scrolling.").width = 2
    end
  end
  
  return opts
  end)
  local function OpenOptions() return self:OpenConfig(panel) end
  for _, arg in ipairs{arg1, ...} do
    self.chatArgs[arg] = OpenOptions
  end
end

