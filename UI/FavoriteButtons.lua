
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



Addon.UI.FavoriteButtons = {}
local This = Addon.UI.FavoriteButtons



local journals = {
  Mount = {
    parent = "MountJournal",
    anchor = "MountJournalMountButton",
    GetID  = function() return MountJournal.selectedMountID end,
  },
  Pet = {
    parent = "PetJournal",
    anchor = "PetJournalSummonButton",
    GetID  = function() return PetJournalPetCard.petID end,
  },
}


local function CreateButtons()
  favoriteButtons = {}
  for journal in pairs(journals) do
    for _, mode in ipairs{"Set", "Unset"} do
      local button = CreateFrame("Button", nil, _G[journals[journal].parent], "ZooKeeperFavButton" .. mode)
      button:SetPoint("LEFT", _G[journals[journal].anchor], "RIGHT", 0, 0)
      button.journal = journal
      tinsert(favoriteButtons, button)
    end
  end
  return favoriteButtons
end


function This:Init()
  local favoriteButtons = CreateButtons()
  
  function This:UpdateAll()
    Addon:Map(favoriteButtons, function(v) return v:Update() end)
  end
  
  hooksecurefunc("MountJournal_SetSelected", function() self:UpdateAll() end)
end



function This.OnLoad(self)
  self.Update = function()
    local id = journals[self.journal].GetID()
    if id then
      self:SetShown(self.fav ~= (Addon:GetOption("fav", id) or false))
    end
    return self
  end
end

function This.OnClick(self)
  local id = journals[self.journal].GetID()
  if id then
    Addon:ToggleOption("fav", id)
    This:UpdateAll()
    -- Addon.UI.FavoriteIcons:UpdateAll()
  end
  PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
end



