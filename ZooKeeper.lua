
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
-- local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)





function Addon:InitDB()
  local configVersion = self.SemVer(self:GetOption"version" or tostring(self.version))
  
  if not self:GetOption"version" then -- first run
    
  else -- upgrade data schema
    
    -- migrate settings from earlier than 2.0.0 (collections interface release)
    if configVersion < self.SemVer"2.0.0" then
      self:Debugf("Migrating from %s to 2.0.0", tostring(configVersion))
      
      local fav = {} -- store old spellIDs
      for spellID in pairs(self:GetOption("fav")) do
        fav[spellID] = true
      end
      
      -- match spellIDs to mount IDs
      for _, id in ipairs(C_MountJournal.GetMountIDs()) do
        local _, spellID = C_MountJournal.GetMountInfoByID(id)
        if fav[spellID] then
          self:SetOption(true, "fav", id)
          self:ResetOption("fav", spellID)
        end
      end
      
      -- match mount IDs to spellIDs
      for _, id in ipairs(C_MountJournal.GetMountIDs()) do
        local _, spellID = C_MountJournal.GetMountInfoByID(id)
        if fav[spellID] then
          self:SetOption(true, "fav", id)
          self:ResetOption("fav", spellID)
        end
      end
      
      -- can't simply match spellIDs to pet IDs, so just leaving the old ones there and users can redo their favorites
      self:Debug"Migration complete"
    end
  end
  
  
  self:SetOption(tostring(self.version), "version")
end




function Addon:OnInitialize()
  self.db        = self.AceDB:New(("%sDB"):format(ADDON_NAME), self:MakeDefaultOptions(), true)
  self.dbDefault = self.AceDB:New({}                         , self:MakeDefaultOptions(), true)
  
  self:RunInitializeCallbacks()
end

function Addon:OnEnable()
  self.version = self.SemVer(GetAddOnMetadata(ADDON_NAME, "Version"))
  self:InitDB()
  self:GetDB().RegisterCallback(self, "OnProfileChanged", "InitDB")
  self:GetDB().RegisterCallback(self, "OnProfileCopied" , "InitDB")
  self:GetDB().RegisterCallback(self, "OnProfileReset"  , "InitDB")
  
  self:InitChatCommands{"zk", ADDON_NAME:lower()}
  
  self:RegisterChatCommand("mount",     "OldMountCommand")
  self:RegisterChatCommand("critter",   "OldCritterCommand")
  self:RegisterChatCommand("companion", "OldCompanionCommand")
  
  
  -- self.addonLoadHooks = {}
  -- self:RegisterEvent("ADDON_LOADED", function(e, addon)
  --   if self.addonLoadHooks[addon] then
  --     self.addonLoadHooks[addon]()
  --   end
  -- end)
  -- self.addonLoadHooks["Blizzard_Collections"] = function()
  --   self.UI:Init()
  -- end
  
  self:RunEnableCallbacks()
end

function Addon:OnDisable()
  
end














