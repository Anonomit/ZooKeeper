
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)



local strSub     = string.sub
local strReverse = string.reverse

local tinsert   = tinsert
local tblConcat = table.concat
local tblSort   = table.sort










local function CanToggleJournal()
  return ToggleCollectionsJournal
end
local function ToggleJournal(tab)
  ToggleCollectionsJournal(tab)
end
local function ToggleMountsJournal()
  ToggleJournal(1)
end
local function ToggleCrittersJournal()
  ToggleJournal(2)
end

local function ForgetDiscovered(category, spellID)
  Addon:SetOption(false, "fav",        spellID)
  Addon:SetOption(nil,   "discovered", category, spellID)
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
  
  do
    local icon = self:MakeIcon"Interface\\AddOns\\ZooKeeper\\Assets\\Textures\\FavoriteSet"
    GUI:CreateDescription(opts, icon .. " " .. self.L["Favorites"] .. " " .. icon)
  end
  
  if CanToggleJournal() then
    GUI:CreateExecute(opts, {"mounts"}, self.L["Toggle Mounts Journal"], nil, ToggleMountsJournal)
    GUI:CreateExecute(opts, {"pets"},   self.L["Toggle Pet Journal"],    nil, ToggleCrittersJournal)
  end
  
  for k, v in ipairs{
    {"mounts",   self.L["Mounts"]},
    {"critters", self.L["Pets"]},
  } do
    local key, title, journalText, func = unpack(v)
    
    local opts = GUI:CreateGroup(opts, key, title)
    
    GUI:CreateDivider(opts)
    
    local collection = {}
    if Addon.expansionLevel < Addon.expansions.wrath then
      for spellID, itemID in pairs(self:GetOptionSafe("discovered", key)) do
        collection[#collection+1] = {favKey = spellID, spellID = spellID, itemID = type(itemID) == "number" and itemID or nil, icon = select(3, GetSpellInfo(spellID)), name = self.spellNames[spellID]}
      end
    else
      if key == "mounts" then
        for i = 1, C_MountJournal.GetNumDisplayedMounts() do
          local creatureName, spellID, icon, active, isUsable, sourceType, isFavorite, isFactionSpecific, faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(C_MountJournal.GetDisplayedMountID(i))
          if isCollected and not hideOnChar then
            collection[#collection+1] = {favKey = mountID, collectionID = mountID, spellID = spellID, icon = icon, name = creatureName}
          end
        end
      elseif key == "critters" then
        for i = 1, C_PetJournal.GetNumPets() do
          local petID, speciesID, owned, customName, level, favorite, isRevoked, speciesName, icon, petType, companionID, tooltip, description, isWild, canBattle, isTradeable, isUnique, obtainable = C_PetJournal.GetPetInfoByIndex(i)
          if petID then
            collection[#collection+1] = {favKey = petID, collectionID = mountID, icon = icon, name = speciesName}
          end
        end
        
      end
    end
    
    tblSort(collection, function(a, b) return strReverse(a.name) < strReverse(b.name) end)
    
    local count = 0
    for _, data in ipairs(collection) do
      count = count + 1
      if count > 1 then
        GUI:CreateNewline(opts)
      end
      local text = data.name
      if data.icon then
        text = self:MakeIcon(data.icon) .. " " .. text
      end
      
      if Addon.expansionLevel < Addon.expansions.wrath then
        GUI:CreateExecute(opts, {"forget", data.spellID}, self.L["Remove"], nil, function() ForgetDiscovered(key, data.spellID) end)
      end
      
      local option = GUI:CreateToggle(opts, {"fav", data.favKey}, text)
      option.width = 1.5
      if data.itemID then
        option.tooltipHyperlink = "item:" .. data.itemID
      elseif data.spellID then
        option.tooltipHyperlink = "spell:" .. data.spellID
      end
      
    end
    
    if count == 0 then
      GUI:CreateDescription(opts, self.L["No items found"])
    end
  end
  
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
  
  if not Addon.isEra then
    GUI:CreateToggle(opts, {"behavior", "preferNonFlyingMountsOnGround"}, L["Prefer ground-only mounts"] , L["Try to avoid using flying mounts in non-flying areas."]).width = 1.5
    GUI:CreateNewline(opts)
  end
  GUI:CreateToggle(opts, {"behavior", "allowSlowMounts"}, L["Allow slow mounts"] , L["Use a mount/form even when it doesn't increase speed.|n|nThis is most common when swimming without owning any swimming mounts."])
  GUI:CreateNewline(opts)
  GUI:CreateReverseToggle(opts, {"behavior", "useTrueRandomization"}, L["Tweak randomizer"] , L["Allow ZooKeeper to tweak the randomizer to avoid summoning the same mount/pet consecutively."])
  GUI:CreateNewline(opts)
  GUI:CreateToggle(opts, {"behavior", "onlyUseFavs"}, L["Only use favorites"] , L["Never use a mount/pet that isn't marked as a favorite.|n|nZooKeeper will not be able to use the best mount available if you don't have it favorited.|n|n|cffff2020Make sure you set favorites for every type of mount!"])
  GUI:CreateNewline(opts)
  GUI:CreateToggle(opts, {"behavior", "alwaysDismount"}, L["Always dismount"] , L["When already mounted and a better mount exists, dismount instead of using the better mount."])
  GUI:CreateNewline(opts)
  
  if Addon.expansionLevel < Addon.expansions.wrath then
    GUI:CreateToggle(opts, {"behavior", "useReagents"}, self.L["Reagents"] , L["Use pets that consume reagents."])
    GUI:CreateNewline(opts)
  end
  
  do
    local disabled
    Addon:xpcall(function()
      if _G.ErrorFilter then
        disabled = true
      end
    end)
    GUI:CreateToggle(opts, {"behavior", "hideErrorMessages"}, L["Hide some error messages"], L["Hides the red messages that can happen when you're unable to use an ability."], disabled).width = 1.5
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
    
  local function MakeClassOptionsSection(opts, className, classFilename, optionsType, options)
    local title = Addon:Switch(optionsType, {
      forms  = function() return L["Use %s spells"] end,
      mounts = function() return L["Use %s mounts"] end,
    })
    local desc = Addon:Switch(optionsType, {
      forms  = function() return L["Use |cff00ccff%s|r class spells when appropriate."] end,
      mounts = function() return L["Use |cff00ccff%s|r class mounts when appropriate."] end,
    })
    local enableToggle = Addon:Switch(optionsType, {
      forms  = function() return "useForms"  end,
      mounts = function() return "useMounts" end,
    })
    local allowedToggle = Addon:Switch(optionsType, {
      forms  = function() return "allowedForms"  end,
      mounts = function() return "allowedMounts" end,
    })
    
    GUI:CreateToggle(opts, {"class", classFilename, enableToggle}, format(title, className), format(desc, className))
    
    do
      local opts = GUI:CreateGroupBox(opts)
      
      local disabled = not Addon:GetOption("class", classFilename, enableToggle)
      for i, option in ipairs(options) do
        if i ~= 1 then
          GUI:CreateNewline(opts)
        end
        
        local spellID = Addon.spells[option]
        local text = self.spellNames[option]
        local icon = select(3, GetSpellInfo(spellID))
        if icon then
          text = self:MakeIcon(icon) .. " " .. text
        end
        GUI:CreateToggle(opts, {"class", classFilename, allowedToggle, option}, text, format(L["Use |cff00ccff%s|r when appropriate."], Addon.spellNames[option]), disabled).tooltipHyperlink = "spell:" .. spellID
      end
    end
  end
    
  local function MakeMountOptions(opts, className, classFilename, options)
    GUI:CreateToggle(opts, {"class", classFilename, "useMounts"}, self.L["Use %s mounts"], format(L["Use %s class mounts when appropriate."], className))
    
    do
      local opts = GUI:CreateGroupBox(opts)
      
      local disabled = not Addon:GetOption("class", classFilename, "useMounts")
      for i, form in ipairs(forms) do
        if i ~= 1 then
          GUI:CreateNewline(opts)
        end
        GUI:CreateToggle(opts, {"class", classFilename, "allowedMounts", form}, Addon.spellNames[form], format(L["Use |cff00ccff%s|r when appropriate."], Addon.spellNames[form]), disabled)
      end
    end
  end
  
  local classMenus = {}
  
  do
    local classID = 11 -- Druid
    
    classMenus[classID] = function()
      local className, classFilename = GetClassInfo(classID)
      
      local opts = GUI:CreateGroup(opts, classFilename, className)
      
      MakeClassOptionsSection(opts, className, classFilename, "forms", Addon:Squish{
        "CatForm",
        "AquaticForm",
        "TravelForm",
        not Addon.isEra and "FlightForm" or nil,
      })
      
      if not Addon.isEra then
        GUI:CreateDivider(opts)
        do
          local opts = GUI:CreateGroupBox(opts, self.L["Preferences"])
          
          local disabled = not (Addon:GetOption("class", classFilename, "useForms") and Addon:GetOption("class", classFilename, "allowedForms", "FlightForm"))
          
          GUI:CreateToggle(opts, {"class", classFilename, "allowRiskyShapeshifting"}, L["Allow risky shapeshifting"], L["Allows you to exit Flight Form in areas where you won't be able to enter it again, such as indoors or around Dalaran.|n|nEnabling this option may lead to accidental falls."], disabled).width = 1.5
          GUI:CreateNewline(opts)
          GUI:CreateToggle(opts, {"class", classFilename, "alwaysPreferFlightForm"}, L["Always prefer Flight Form"], L["Use Flight Form even if a faster mount exists."], disabled).width = 1.5
        end
      end
    end
  end
  
  do
    local classID = 7 -- Shaman
    
    classMenus[classID] = function()
      local className, classFilename = GetClassInfo(classID)
      
      local opts = GUI:CreateGroup(opts, classFilename, className)
      
      MakeClassOptionsSection(opts, className, classFilename, "forms", {
        "GhostWolf",
      })
    end
  end
  
  do
    local classID = 2 -- Paladin
    
    classMenus[classID] = function()
      local className, classFilename = GetClassInfo(classID)
      
      local opts = GUI:CreateGroup(opts, classFilename, className)
      
      if Addon.expansionLevel < Addon.expansions.wrath then
        MakeClassOptionsSection(opts, className, classFilename, "mounts", {
          "Warhorse",
          "Charger",
        })
      else
        MakeClassOptionsSection(opts, className, classFilename, "forms", {
          "CrusaderAura",
        })
      end
    end
  end
  
  do
    local classID = 3 -- Hunter
    
    classMenus[classID] = function()
      local className, classFilename = GetClassInfo(classID)
      
      local opts = GUI:CreateGroup(opts, classFilename, className)
      
      MakeClassOptionsSection(opts, className, classFilename, "forms", {
        "AspectOfTheCheetah",
        "AspectOfThePack",
      })
    end
  end
  
  if Addon.expansionLevel < Addon.expansions.wrath then
    local classID = 9 -- Warlock
    
    classMenus[classID] = function()
      local className, classFilename = GetClassInfo(classID)
      
      local opts = GUI:CreateGroup(opts, classFilename, className)
      
      MakeClassOptionsSection(opts, className, classFilename, "mounts", {
        "Felsteed",
        "Dreadsteed",
      })
    end
  end
  
  do
    (classMenus[Addon.MY_CLASS_ID] or nop)()
    classMenus[Addon.MY_CLASS_ID] = nil
    
    local menuKeys = {}
    for key in pairs(classMenus) do
      tinsert(menuKeys, key)
    end
    tblSort(menuKeys, function(a, b) return GetClassInfo(a) < GetClassInfo(b) end)
    for _, key in ipairs(menuKeys) do
      classMenus[key]()
    end
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
  
  
  if Addon.expansionLevel >= Addon.expansions.wrath then
    local opts = GUI:CreateGroup(opts, "WotLK", self.L["Wrath of the Lich King"])
    
    do
      local zone = "Oculus"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      do
        for i, item in ipairs{
          "AmberEssence",
          "RubyEssence",
          "EmeraldEssence",
        } do
          GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, Addon:InsertItemIcon(item), nil).tooltipHyperlink = "item:" .. Addon.items[item]
        end
      end
    end
    
    do
      local zone = "Ulduar"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, Addon:InsertItemIcon"MagneticCore").tooltipHyperlink = "item:" .. Addon.items.MagneticCore
    end
    
    do
      local zone = "Icecrown Citadel"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, Addon:InsertItemIcon"GoblinRocketPack").tooltipHyperlink = "item:" .. Addon.items.GoblinRocketPack
      GUI:CreateNewline(opts)
      
      local disabled = not Addon:GetOption("zone", zone, "useZoneItems")
      GUI:CreateReverseToggle(opts, {"zone", zone, "atCursor"}, L["Require click to confirm"], L["Enable to use a targeting circle.|nDisable to use mouse cursor location."], disabled)
    end
  end
  
  if Addon.expansionLevel >= Addon.expansions.tbc then
    local opts = GUI:CreateGroup(opts, "TBC", self.L["The Burning Crusade"])
    
    if Addon.expansionLevel < Addon.expansions.wrath then
      local zone = "Karazhan"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, Addon:InsertItemIcon"BlackenedUrn").tooltipHyperlink = "item:" .. Addon.items.BlackenedUrn
    end
    
    do
      local zone = "Serpentshrine Cavern"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, Addon:InsertItemIcon"TaintedCore").tooltipHyperlink = "item:" .. Addon.items.TaintedCore
    end
    
    do
      local zone = "The Eye"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, self.L["Legendaries"], L["Equip and activate legendary items."])
      
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
          GUI:CreateToggle(opts, {"zone", zone, "allowedItems", item}, Addon:InsertItemIcon(item), nil, disabled).tooltipHyperlink = "item:" .. Addon.items[item]
        end
      end
    end
    
    do
      local zone = "Battle for Mount Hyjal"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, Addon:InsertItemIcon"TearsOfTheGoddess").tooltipHyperlink = "item:" .. Addon.items.TearsOfTheGoddess
    end
    
    do
      local zone = "Black Temple"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, Addon:InsertItemIcon"NajentusSpine").tooltipHyperlink = "item:" .. Addon.items.NajentusSpine
    end
  end
  
  do
    local opts = opts
    if not Addon.isEra then
      opts = GUI:CreateGroup(opts, "Classic", self.L["Classic"])
    end
    
    do
      local zone = "Molten Core"
      local opts = GUI:CreateGroup(opts, zone, zone)
      
      GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, self.L["Use Item"], L["Douse the Runes of Warding."])
      
      do
        local opts = GUI:CreateGroupBox(opts)
        
        local disabled = not Addon:GetOption("zone", zone, "useZoneItems")
        GUI:CreateToggle(opts, {"zone", zone, "allowedItems", "EternalQuintessence"}, Addon:InsertItemIcon"EternalQuintessence", nil, disabled).tooltipHyperlink = "item:" .. Addon.items.EternalQuintessence
        GUI:CreateNewline(opts)
        GUI:CreateToggle(opts, {"zone", zone, "allowedItems", "AqualQuintessence"}, Addon:InsertItemIcon"AqualQuintessence", nil, disabled).tooltipHyperlink = "item:" .. Addon.items.AqualQuintessence
      end
    end
    
    -- do
    --   local zone = "Blackwing Lair"
    --   local opts = GUI:CreateGroup(opts, zone, zone)
      
    --   GUI:CreateToggle(opts, {"zone", zone, "useZoneItems"}, L["Toggle hunter ranged weapon"], L["Avoid hunter class calls by toggling ranged weapon off before it happens."]).width = 1.5
    -- end
  end
  
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
  
  GUI:CreateExecute(opts, "reload", self.L["Reload UI"], nil, ReloadUI)
  
  -- Enable
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), self.L["Enable"])
    
    do
      local opts = GUI:CreateGroupBox(opts, "Debug")
      GUI:CreateToggle(opts, {"debug"}, self.L["Enable"])
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugShowLuaErrors"}, self.L["Display Lua Errors"], nil).width = 2
      GUI:CreateNewline(opts)
      
      local disabled = not self:GetGlobalOption"debugShowLuaErrors"
      GUI:CreateToggle(opts, {"debugShowLuaWarnings"}, self.L["Lua Warning"], nil, disabled).width = 2
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
        {"optionSet",          "Option Set"},
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
  
  -- default is (700, 500)
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


