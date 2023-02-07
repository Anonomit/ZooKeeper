
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)




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

