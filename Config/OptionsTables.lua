
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)



local strSub = string.sub

local tinsert   = tinsert
local tblConcat = table.concat











local function ToggleJournal(tab)
  ToggleCollectionsJournal(tab)
end
local function ToggleMountsJournal()
  ToggleJournal(1)
end
local function ToggleCrittersJournal()
  ToggleJournal(2)
end





--   ██████╗ ███████╗███╗   ██╗███████╗██████╗  █████╗ ██╗          ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔══██╗██║         ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝███████║██║         ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██║         ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║███████╗    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--   ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝     ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local function MakeGeneralOptions(opts)
  local self = Addon
  local GUI = self.GUI
  local opts = GUI:CreateGroup(opts, ADDON_NAME, ADDON_NAME)
  
  GUI:CreateNewline(opts)
  
  GUI:CreateExecute(opts, {"openMounts"}, self.L["Mounts"], nil, ToggleMountsJournal)
  GUI:CreateNewline(opts)
  
  GUI:CreateExecute(opts, {"openCritters"}, self.L["Companions"], nil, ToggleCrittersJournal)
  
  return opts
end







--  ██████╗ ███████╗██╗  ██╗ █████╗ ██╗   ██╗██╗ ██████╗ ██████╗      ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔══██╗██╔════╝██║  ██║██╔══██╗██║   ██║██║██╔═══██╗██╔══██╗    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██████╔╝█████╗  ███████║███████║██║   ██║██║██║   ██║██████╔╝    ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██╔══██╗██╔══╝  ██╔══██║██╔══██║╚██╗ ██╔╝██║██║   ██║██╔══██╗    ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██████╔╝███████╗██║  ██║██║  ██║ ╚████╔╝ ██║╚██████╔╝██║  ██║    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝     ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local function MakeBehaviorOptions(opts, categoryName)
  local self = Addon
  local GUI = self.GUI
  
  local opts = GUI:CreateGroup(opts, categoryName, categoryName)
  
  GUI:CreateToggle(opts, {"behavior", "onlyUseFavs"}, L["Only use favorites"] , L["Never use a mount/pet that isn't marked as a favorite.|n|nZooKeeper will not be able to use the best mount available if you don't have it favorited.|n|n|cffff2020Make sure you set favorites for every type of mount!"])
  GUI:CreateNewline(opts)
  GUI:CreateToggle(opts, {"behavior", "preferNonFlyingMountsOnGround"}, L["Prefer ground-only mounts"] , L["Try to avoid using flying mounts in non-flying areas."])
  GUI:CreateNewline(opts)
  GUI:CreateToggle(opts, {"behavior", "allowSlowMounts"}, L["Allow slow mounts"] , L["Use a mount/form even when it doesn't increase speed.|n|nThis is most common when swimming without owning any swimming mounts."])
  GUI:CreateNewline(opts)
  GUI:CreateReverseToggle(opts, {"behavior", "useTrueRandomization"}, L["Tweak randomizer"] , L["Allow ZooKeeper to tweak the randomizer to avoid summoning the same mount/pet consecutively."])
  GUI:CreateNewline(opts)
  
  do
    local disabled
    Addon:xpcall(function()
      if _G.ErrorFilter then
        disabled = true
      end
    end)
    GUI:CreateToggle(opts, {"behavior", "hideErrorMessages"}, L["Hide shapeshift error messages"], L["Hides the red messages that can happen when you're unable to use an ability."], disabled).width = 1.5
    if disabled then
      GUI:CreateDescription(opts, Addon:MakeColorCode(Addon:GetHexFromColor(255,  32,  32), L["(Not compatible with ErrorFilter)"]), "small")
    end
  end
  
  
  return opts
end







--   ██████╗██╗      █████╗ ███████╗███████╗     ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔════╝██║     ██╔══██╗██╔════╝██╔════╝    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██║     ██║     ███████║███████╗███████╗    ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║     ██║     ██╔══██║╚════██║╚════██║    ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ╚██████╗███████╗██║  ██║███████║███████║    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--   ╚═════╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝     ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local function MakeClassOptions(opts, categoryName)
  local self = Addon
  local GUI = self.GUI
  
  local opts = GUI:CreateGroup(opts, categoryName, categoryName)
    
  local function MakeFormOptions(opts, className, classFilename, forms)
    GUI:CreateToggle(opts, {"class", classFilename, "useForms"}, self.L["Shapeshifting"], format(L["Use %s class spells."], className))
    GUI:CreateNewline(opts)
    
    do
      local opts = GUI:CreateGroupBox(opts)
      
      local disabled = not Addon:GetOption("class", classFilename, "useForms")
      for i, form in ipairs(forms) do
        if i ~= 1 then
          GUI:CreateNewline(opts)
        end
        GUI:CreateToggle(opts, {"class", classFilename, "allowedForms", form}, Addon.spellNames[form], format(L["Use |cff00ccff%s|r when appropriate."], Addon.spellNames[form]), disabled)
      end
    end
  end
  
  do
    local classID = 11 -- Druid
    local className, classFilename = GetClassInfo(classID)
    
    local opts = GUI:CreateGroup(opts, classFilename, className)
    
    MakeFormOptions(opts, className, classFilename, {
      "AquaticForm",
      "TravelForm",
      "FlightForm",
      "CatForm",
    })
    
    GUI:CreateDivider(opts)
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Preferences"])
      
      local disabled = not Addon:GetOption("class", classFilename, "allowedForms", "FlightForm")
      
      GUI:CreateToggle(opts, {"class", classFilename, "allowRiskyShapeshifting"}, L["Allow risky shapeshifting"], L["Allows you to exit Flight Form in areas where you won't be able to enter it again, such as indoors or around Dalaran.|n|nEnabling this option may lead to accidental falls."], disabled)
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"class", classFilename, "alwaysPreferFlightForm"}, L["Always prefer Flight Form"], L["Use Flight Form even if a faster mount exists."], disabled)
    end
  end
  
  do
    local classID = 7 -- Shaman
    local className, classFilename = GetClassInfo(classID)
    
    local opts = GUI:CreateGroup(opts, classFilename, className)
    
    MakeFormOptions(opts, className, classFilename, {
      "GhostWolf",
    })
  end
  
  return opts
end









--  ███████╗ ██████╗ ███╗   ██╗███████╗     ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ╚══███╔╝██╔═══██╗████╗  ██║██╔════╝    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--    ███╔╝ ██║   ██║██╔██╗ ██║█████╗      ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--   ███╔╝  ██║   ██║██║╚██╗██║██╔══╝      ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ███████╗╚██████╔╝██║ ╚████║███████╗    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝     ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local function MakeZoneOptions(opts, categoryName)
  local self = Addon
  local GUI = self.GUI
  
  local opts = GUI:CreateGroup(opts, categoryName, categoryName)
  
  
  do
    -- local opts = GUI:CreateGroup(opts, "WotLK", self.L["Wrath of the Lich King"])
    
    do
      local zone = "Oculus"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      local dragonNames = {}
      for k, v in pairs(Addon.itemsByCategory.Oculus) do
        tinsert(dragonNames, Addon.itemNames[k])
      end
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, L["Dragon mounts"], format(L["Use |cff00ccff%s|r when available."], tblConcat(dragonNames, "|r,|cff00ccff ")))
    end
    
    do
      local zone = "Icecrown Citadel"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, Addon.itemNames.GoblinRocketPack, format(L["Use |cff00ccff%s|r when available."], Addon.itemNames.GoblinRocketPack))
      GUI:CreateNewline(opts)
      
      local disabled = not Addon:GetOption("zone", zone, "useZoneItems")
      GUI:CreateReverseToggle(opts, {"zone", zone, "atCursor"}, L["Require click to confirm"], L["Enable to use a targeting circle.|nDisable to use mouse cursor location."], disabled)
    end
  end
  --[[
  do
    local opts = GUI:CreateGroup(opts, "TBC", self.L["The Burning Crusade"])
    
    if Addon.blackenedUrnQuality ~= 0 then
      local zone = "Karazhan"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, Addon.itemNames.BlackenedUrn, format(L["Use |cff00ccff%s|r when available."], Addon.itemNames.BlackenedUrn))
    end
    
    do
      local zone = "Serpentshrine Cavern"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, Addon.itemNames.TaintedCore, format(L["Use |cff00ccff%s|r when available."], Addon.itemNames.TaintedCore))
    end
    
    do
      local zone = "The Eye"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, self.L["Legendaries"], L["Equip and activate legendary items."])
      GUI:CreateDivider(opts)
      
      do
        local opts = GUI:CreateGroupBox(opts)
        
        local disabled = not Addon:GetOption("zone", zone, "useZoneItems")
        for i, item in ipairs{
          "StaffOfDisintegration",
          "NetherstrandLongbow",
          "WarpSlicer",
          "Devastation",
          "CosmicInfuser",
          "InfinityBlade",
          "PhaseshiftBulwark",
        } do
          GUI:CreateToggle(opts, {"zone", zone, item}, Addon.itemNames[item], format(L["Use |cff00ccff%s|r when available."], Addon.itemNames[item]), disabled)
        end
      end
    end
    
    do
      local zone = "Battle for Mount Hyjal"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, Addon.itemNames.TearsOfTheGoddess, format(L["Use |cff00ccff%s|r when available."], Addon.itemNames.TearsOfTheGoddess))
    end
    
    do
      local zone = "Black Temple"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, Addon.itemNames.NajentusSpine, format(L["Use |cff00ccff%s|r when available."], Addon.itemNames.NajentusSpine))
    end
  end
  
  do
    local opts = GUI:CreateGroup(opts, "Classic", self.L["Classic"])
    
    do
      local zone = "Molten Core"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, self.L["Use Item"], "desc")
      GUI:CreateDivider(opts)
      
      do
        local opts = GUI:CreateGroupBox(opts)
        
        local disabled = not Addon:GetOption("zone", zone, "useZoneItems")
        GUI:CreateToggle(opts, {"zone", zone, "EternalQuintessence"}, Addon.itemNames.EternalQuintessence, format(L["Use |cff00ccff%s|r when available."], Addon.itemNames.EternalQuintessence), disabled)
        GUI:CreateNewline(opts)
        GUI:CreateToggle(opts, {"zone", zone, "AqualQuintessence"}, Addon.itemNames.AqualQuintessence, format(L["Use |cff00ccff%s|r when available."], Addon.itemNames.AqualQuintessence) .. "|n|n" .. format(L["|cff00ccff%s|r will be used first, if available."], Addon.itemNames.EternalQuintessence), disabled)
      end
    end
    
    do
      local zone = "Blackwing Lair"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, L["Toggle hunter ranged weapon"], "desc").width = 1.5
    end
  end
  --]]
  return opts
end





--  ██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗      ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝     ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗    ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║    ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝      ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local function MakeDebugOptions(opts, categoryName)
  local self = Addon
  local GUI = self.GUI
  
  if not self:IsDebugEnabled() then return end
  
  GUI:SetDBType"Global"
  local opts = GUI:CreateGroup(opts, categoryName, categoryName)
  
  -- Enable
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), self.L["Enable"])
    
    do
      local opts = GUI:CreateGroupBox(opts, "Debug")
      GUI:CreateToggle(opts, {"debug"}, self.L["Enable"])
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugShowLuaErrors"}, "Show Lua Errors", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateExecute(opts, "reload", self.L["Reload UI"], nil, ReloadUI)
    end
  end
  
  -- Debug Output
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "Output")
    
    local disabled = not self:GetGlobalOption"debug"
    
    do
      local opts = GUI:CreateGroupBox(opts, "Suppress All")
      
      GUI:CreateToggle(opts, {"debugOutput", "suppressAll"}, self.debugPrefix .. " " .. self.L["Hide messages like this one."], nil, disabled).width = 2
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, "Message Types")
      
      local disabled = disabled or self:GetGlobalOption("debugOutput", "suppressAll")
      
      
      for i, data in ipairs{
        {"lastSet",            "Last Set"},
        {"allSelected",        "All Selected"},
        {"allReset",           "All Reset"},
        {"usableSelected",     "Usable Selected"},
        {"usableReset",        "Usable Reset"},
        {"idealSelected",      "Ideal Selected"},
        {"idealReset",         "Ideal Reset"},
        {"finalSelectionMade", "Final Selection Made"},
        {"mountTypes",         "Mount Types"},
        {"mountType",          "Selected Mount Type"},
        {"initialMountPool",   "Initial Mount Pool"},
        {"candidates",         "Mount Candidates"},
        -- {"finalMountPool",  "Final Mount Pool"},
        {"usingFallbackMount", "Using Fallback Mount"},
        {"macroTextChanged",   "Macro Text Changed"},
        {"macroBoundToButton", "Macro Bound to Button"},
        {"spellButtonClicked", "Spell Button Clicked"},
        {"queueingDismount",   "Queueing dismount"},
      } do
        if i ~= 1 then
          GUI:CreateNewline(opts)
        end
        GUI:CreateToggle(opts, {"debugOutput", data[1]}, data[2], nil, disabled).width = 2
      end
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
  
  GUI:ResetDBType()
  
  return opts
end









--  ██████╗ ██████╗  ██████╗ ███████╗██╗██╗     ███████╗     ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔══██╗██╔══██╗██╔═══██╗██╔════╝██║██║     ██╔════╝    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██████╔╝██████╔╝██║   ██║█████╗  ██║██║     █████╗      ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██╔═══╝ ██╔══██╗██║   ██║██╔══╝  ██║██║     ██╔══╝      ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██║     ██║  ██║╚██████╔╝██║     ██║███████╗███████╗    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚══════╝     ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local function MakeProfileOptions(opts, categoryName)
  local self = Addon
  local GUI = self.GUI
  
  local profileOptions = self.AceDBOptions:GetOptionsTable(self:GetDB())
  categoryName = profileOptions.name
  profileOptions.order = GUI:Order()
  opts.args[categoryName] = profileOptions
  
  return opts
end



--   █████╗ ██████╗ ██████╗  ██████╗ ███╗   ██╗     ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔══██╗██╔══██╗██╔══██╗██╔═══██╗████╗  ██║    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ███████║██║  ██║██║  ██║██║   ██║██╔██╗ ██║    ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██╔══██║██║  ██║██║  ██║██║   ██║██║╚██╗██║    ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██║  ██║██████╔╝██████╔╝╚██████╔╝██║ ╚████║    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═╝  ╚═╝╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝     ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

function Addon:MakeAddonOptions(chatCmd)
  local title = format("%s v%s  (/%s)", ADDON_NAME, tostring(self:GetOption"version"), chatCmd)
  
  local sections = {}
  for _, data in ipairs{
    {MakeGeneralOptions,  nil},
    {MakeBehaviorOptions, self.L["Preferences"], "preferences", "behaviors", "behaviours"},
    {MakeClassOptions,    self.L["Class"],       "classes"},
    {MakeZoneOptions ,    self.L["Zone"],        "zones"},
    {MakeProfileOptions,  "Profiles",            "profiles"},
    {MakeDebugOptions,    self.L["Debug"],       "debug", "db"},
  } do
    
    local func = data[1]
    local name = data[2]
    local args = {unpack(data, 3)}
    
    tinsert(sections, function(opts) return func(opts, name) end)
    
    local function OpenOptions() return self:OpenConfig(name) end
    if name == self.L["Debug"] then
      local OpenOptions_Old = OpenOptions
      OpenOptions = function(...)
        if not self:GetGlobalOption"debug" then
          self:SetGlobalOption(true, "debug")
          self:Debug("Debug mode enabled")
        end
        return OpenOptions_Old(...)
      end
    end
    
    for _, arg in ipairs(args) do
      self:RegisterChatArgAliases(arg, OpenOptions)
    end
  end
  
  self.AceConfig:RegisterOptionsTable(ADDON_NAME, function()
    local GUI = self.GUI:ResetOrder()
    local opts = GUI:CreateOpts(title, "tab")
    
    for _, func in ipairs(sections) do
      func(opts)
    end
    
    return opts
  end)
  
  self.AceConfigDialog:SetDefaultSize(ADDON_NAME, 700, 800)
end


function Addon:MakeBlizzardOptions(chatCmd)
  local title = format("%s v%s  (/%s)", ADDON_NAME, tostring(self:GetOption"version"), chatCmd)
  local panel = self:CreateBlizzardOptionsCategory(function()
    local GUI = self.GUI:ResetOrder()
    local opts = GUI:CreateOpts(title, "tab")
    
    GUI:CreateExecute(opts, "key", ADDON_NAME .. " " .. self.L["Options"], nil, function()
      self:OpenConfig(ADDON_NAME)
      self:CloseBlizzardConfig()
    end)
    
    return opts
  end)
end


