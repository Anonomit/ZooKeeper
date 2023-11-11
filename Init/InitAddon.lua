
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
ZooKeeper   = Addon




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
  local formOptions = {
    CatForm         = "CatForm",
    TravelForm      = "TravelForm",
    AquaticForm     = "AquaticForm",
    FlightForm      = "FlightForm",
    SwiftFlightForm = "FlightForm",
    
    GhostWolf       = "GhostWolf",
  }
  
  function Addon:CanUseForm(form)
    return self:GetOption("class", self.MY_CLASS_NAME, "useForms") and self:GetOption("class", self.MY_CLASS_NAME, "allowedForms", formOptions[form]) and IsSpellKnown(self.spells[form])
  end
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
    [187] = "Icecrown Citadel",
    
    -- TBC
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

