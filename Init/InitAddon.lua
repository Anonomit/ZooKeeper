
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
ZooKeeper   = Addon



local strMatch = string.match




--  ██╗   ██╗██╗    ███████╗██████╗ ██████╗  ██████╗ ██████╗ ███████╗
--  ██║   ██║██║    ██╔════╝██╔══██╗██╔══██╗██╔═══██╗██╔══██╗██╔════╝
--  ██║   ██║██║    █████╗  ██████╔╝██████╔╝██║   ██║██████╔╝███████╗
--  ██║   ██║██║    ██╔══╝  ██╔══██╗██╔══██╗██║   ██║██╔══██╗╚════██║
--  ╚██████╔╝██║    ███████╗██║  ██║██║  ██║╚██████╔╝██║  ██║███████║
--   ╚═════╝ ╚═╝    ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

do
   -- "Sound_EnableErrorSpeech"
   -- "Sound_EnableAllSound"
  
  function Addon:BlockUIErrors()
    if self:GetOption("behavior", "hideErrorMessages") then
      self:xpcall(function()
        if not _G.ErrorFilter then -- ErrorFilter causes the event to be delayed
          UIErrorsFrame:UnregisterEvent"UI_ERROR_MESSAGE"
        end
      end)
    end
  end
  function Addon:AllowUIErrors()
    if self:GetOption("behavior", "hideErrorMessages") then
      self:xpcall(function()
        if not _G.ErrorFilter then -- ErrorFilter causes the event to be delayed
          UIErrorsFrame:RegisterEvent"UI_ERROR_MESSAGE"
        end
      end)
    end
  end
end




--  ██████╗ ██╗   ██╗████████╗████████╗ ██████╗ ███╗   ██╗███████╗
--  ██╔══██╗██║   ██║╚══██╔══╝╚══██╔══╝██╔═══██╗████╗  ██║██╔════╝
--  ██████╔╝██║   ██║   ██║      ██║   ██║   ██║██╔██╗ ██║███████╗
--  ██╔══██╗██║   ██║   ██║      ██║   ██║   ██║██║╚██╗██║╚════██║
--  ██████╔╝╚██████╔╝   ██║      ██║   ╚██████╔╝██║ ╚████║███████║
--  ╚═════╝  ╚═════╝    ╚═╝      ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do
  local function GetButton(name, typeAttribute)
    if not _G[name] then
      CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate"):SetAttribute("type", typeAttribute)
    end
    return _G[name]
  end
  
  function Addon:GetMacroButton(name)
    return GetButton(name, "macro")
  end
  function Addon:GetSpellButton(name)
    return GetButton(name, "spell")
  end
  function Addon:GetItemButton(name)
    return GetButton(name, "item")
  end
end







--  ███████╗████████╗██████╗ ██╗███╗   ██╗ ██████╗ ███████╗
--  ██╔════╝╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝ ██╔════╝
--  ███████╗   ██║   ██████╔╝██║██╔██╗ ██║██║  ███╗███████╗
--  ╚════██║   ██║   ██╔══██╗██║██║╚██╗██║██║   ██║╚════██║
--  ███████║   ██║   ██║  ██║██║██║ ╚████║╚██████╔╝███████║
--  ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝

do
  function Addon:MakeAtlas(atlas, height, width, hex)
    height = tostring(height or "0")
    local tex = "|A:" .. atlas .. ":" .. height .. ":" .. tostring(width or height)
    if hex then
      tex = tex .. format(":::%d:%d:%d", self:ConvertHexToRGB(hex))
    end
    return tex .. "|a"
  end
  function Addon:MakeIcon(texture, height, width, hex)
    local tex = "|T" .. texture .. ":" .. tostring(height or "0") .. ":"
    if width then
      tex = tex .. width
    end
    if hex then
      tex = tex .. format(":::1:1:0:1:0:1:%d:%d:%d", self:ConvertHexToRGB(hex))
    end
    return tex .. "|t"
  end
  function Addon:UnmakeIcon(texture)
    return strMatch(texture, "|T([^:]+):")
  end
  
  function Addon:InsertItemIcon(item)
    local icon = select(5, GetItemInfoInstant(self.items[item]))
    return (icon and (self:MakeIcon(icon) .. " ") or "") .. self.itemNames[item]
  end
  function Addon:InsertSpellIcon(spell)
    local icon = select(3, GetSpellInfo(self.spells[spell]))
    return (icon and (self:MakeIcon(icon) .. " ") or "") .. self.spellNames[spell]
  end
end





--  ██╗████████╗███████╗███╗   ███╗███████╗
--  ██║╚══██╔══╝██╔════╝████╗ ████║██╔════╝
--  ██║   ██║   █████╗  ██╔████╔██║███████╗
--  ██║   ██║   ██╔══╝  ██║╚██╔╝██║╚════██║
--  ██║   ██║   ███████╗██║ ╚═╝ ██║███████║
--  ╚═╝   ╚═╝   ╚══════╝╚═╝     ╚═╝╚══════╝

do
  local lastRangedItem
  local function SetLastRangedItem(itemLink)
    if itemLink then
      lastRangedItem = strMatch(itemLink, "(item:.-)|h")
    end
  end
  function Addon:GetLastRangedItem()
    return lastRangedItem
  end
  
  Addon:RegisterEnableCallback(function(self)
    SetLastRangedItem(GetInventoryItemLink("player", INVSLOT_RANGED))
    self:RegisterEventCallback("PLAYER_EQUIPMENT_CHANGED", function(self, e, slot)
      if slot == INVSLOT_RANGED then
        SetLastRangedItem(GetInventoryItemLink("player", INVSLOT_RANGED))
      end
    end)
  end)
  
  function Addon:UnequipRangedItem()
    if SpellIsTargeting() then return false end
    
    if CursorHasItem() then
      ClearCursor()
    end
    if IsInventoryItemLocked(INVSLOT_RANGED) then return false end
    PickupInventoryItem(INVSLOT_RANGED)
    
    if CursorHasItem() then
      for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
          local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
          if not containerInfo then
            if bag == BACKPACK_CONTAINER then
              PutItemInBackpack()
            else
              PutItemInBag(slot + 19)
            end
            return true
          end
        end
      end
    end
    return false
  end
end






--  ███╗   ███╗ ██████╗ ██╗   ██╗███╗   ██╗████████╗███████╗
--  ████╗ ████║██╔═══██╗██║   ██║████╗  ██║╚══██╔══╝██╔════╝
--  ██╔████╔██║██║   ██║██║   ██║██╔██╗ ██║   ██║   ███████╗
--  ██║╚██╔╝██║██║   ██║██║   ██║██║╚██╗██║   ██║   ╚════██║
--  ██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║   ██║   ███████║
--  ╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝

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
            fastest = speed[i]
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





--  ███████╗ ██████╗ ██████╗ ███╗   ███╗███████╗
--  ██╔════╝██╔═══██╗██╔══██╗████╗ ████║██╔════╝
--  █████╗  ██║   ██║██████╔╝██╔████╔██║███████╗
--  ██╔══╝  ██║   ██║██╔══██╗██║╚██╔╝██║╚════██║
--  ██║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║███████║
--  ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝

do
  local formOptions = setmetatable({
    SwiftFlightForm = "FlightForm",
  }, {__index = function(self, k) return k end})
  
  function Addon:CanUseForm(form)
    return self:GetOption("class", self.MY_CLASS_FILENAME, "useForms") and self:GetOption("class", self.MY_CLASS_FILENAME, "allowedForms", formOptions[form]) and IsSpellKnown(self.spells[form])
  end
  
  function Addon:CanUseMount(mount)
    return self:GetOption("class", self.MY_CLASS_FILENAME, "useMounts") and self:GetOption("class", self.MY_CLASS_FILENAME, "allowedMounts", mount) and IsSpellKnown(self.spells[mount])
  end
  
  
  
  local auraIDs = {
    PALADIN = {
      DevotionAura = {
        
      },
    },
  }
  
  
  local function GetAuraTable()
    local auras = setmetatable({
      PALADIN = {
        -- "DevotionAura"
        [1] = "something",
        [2] = "something",
        [3] = "something",
        [4] = "something",
        [5] = "something",
        [6] = "something",
        [7] = "CrusaderAura",
      },
    }, {__index = function() return {} end})
  end
  
  local lastAura
  local function CheckAuras()
    
    local auraTable = auras[Addon.MY_CLASS_FILENAME]
    
    local form = GetShapeshiftForm()
  end
  Addon:RegisterEnableCallback(function(self)
    self:RegisterEventCallback("UPDATE_SHAPESHIFT_FORM", function()
      
    end)
  end)
end






--  ██╗      ██████╗  ██████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██║     ██╔═══██╗██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██║     ██║   ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║     ██║   ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ███████╗╚██████╔╝╚██████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do
  local zones = {
    
    -- Restricted Flyable
    
    [123] = "Wintergrasp",
    [125] = "Dalaran",
    [126] = "Dalaran Underbelly",
    
    
    -- WotLK
    
    [143] = "Oculus",
    -- [186] = "Icecrown Citadel", -- The Lower Citadel
    [187] = "Icecrown Citadel", -- The Rampart of Skulls
    -- [188] = "Icecrown Citadel", -- Deathbringer's Rise
    -- [189] = "Icecrown Citadel", -- The Frost Queen's Lair
    -- [190] = "Icecrown Citadel", -- The Upper Reaches
    -- [191] = "Icecrown Citadel", -- Royal Quarters
    -- [192] = "Icecrown Citadel", -- The Frozen Throne
    -- [193] = "Icecrown Citadel", -- Frostmourne
    
    
    -- TBC
    
    -- [350] = "Karazhan", -- Servant's Quarters
    -- [351] = "Karazhan", -- Upper Livery Stables
    -- [352] = "Karazhan", -- The Banquet Hall
    -- [353] = "Karazhan", -- The Guest Chambers
    -- [354] = "Karazhan", -- Opera Hall Balcony
    [355] = "Karazhan", -- Master's Terrace
    -- [356] = "Karazhan", -- Lower Broken Stair
    -- [357] = "Karazhan", -- Upper Broken Stair
    -- [358] = "Karazhan", -- The Menagerie
    -- [359] = "Karazhan", -- Guardian's Library
    -- [360] = "Karazhan", -- The Repository
    -- [361] = "Karazhan", -- Upper Library
    -- [362] = "Karazhan", -- The Celestial Watch
    -- [363] = "Karazhan", -- Gamesman's Hall
    -- [364] = "Karazhan", -- Medivh's Chambers
    -- [365] = "Karazhan", -- The Power Station
    -- [366] = "Karazhan", -- Netherspace
    
    [332] = "Serpentshrine Cavern",
    [334] = "The Eye",
    [329] = "Battle for Mount Hyjal",
    
    -- [339] = "Black Temple", -- Black Temple
    [340] = "Black Temple", -- Karabor Sewers
    -- [341] = "Black Temple", -- Sanctuary of Shadows
    -- [342] = "Black Temple", -- Halls of Anguish
    -- [343] = "Black Temple", -- Gorefiend's Vigil
    -- [344] = "Black Temple", -- Den of Mortal Delights
    -- [345] = "Black Temple", -- Chamber of Command
    -- [346] = "Black Temple", -- Temple Summit
    
    
    -- Classic
    
    [232] = "Molten Core",
    -- [287] = "Blackwing Lair", -- Dragonmaw Garrison
    -- [288] = "Blackwing Lair", -- Halls of Strife
    -- [289] = "Blackwing Lair", -- Crimson Laboratories
    [290] = "Blackwing Lair", -- Nefarian's Lair
  }
  
  local flyableRestrictedZones = Addon:MakeLookupTable{
    "Wintergrasp",
    "Dalaran",
    "Dalaran Underbelly",
  }
  
  function Addon:GetZone()
    return zones[C_Map.GetBestMapForUnit"player" or 0]
  end
  
  function Addon:GetZoneIsFlyableRestricted()
    return flyableRestrictedZones[Addon:GetZone() or 0] and true or false
  end
  
  
  function Addon:GetMapID()
    return (select(8, GetInstanceInfo()))
  end
  
  function Addon:IsInAQ()
    return self:GetMapID() == 531
  end
end

