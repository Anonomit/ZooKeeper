


local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)




function Addon:MakeUI()
  
  -- fav icons
  local favIcons = {}
  
  local function UpdateFavIcon(button)
    local spellID = button:GetParent().spellID
    if spellID then
      button:SetShown(self:GetOption("fav", spellID))
    else
      button:Hide()
    end
  end
  
  function Addon:UpdateAllFavIcons()
    for _, button in ipairs(favIcons) do
      UpdateFavIcon(button)
    end
  end
  
  -- make icons
  for i = 1, 12 do
    local parent = _G["CompanionButton"..i]
    local button = CreateFrame("Button", "ZooKeeper$parent", parent)
    tinsert(favIcons, button)
    
    button:EnableMouse(false)
    button:SetNormalTexture("Interface\\AddOns\\ZooKeeper\\Assets\\Textures\\FavoriteSet")
    button:SetSize(16, 16)
    button:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT")
  end
  
  Addon:UpdateAllFavIcons()
  
  hooksecurefunc("PetPaperDollFrame_UpdateCompanions", function() Addon:UpdateAllFavIcons() end)
  
  
  --[[
  -- fav button
  do
    -- make button
    -- local button = CreateFrame("Button", "ZooKeeperCompanionButton", PetPaperDollFrameCompanionFrame, "UIPanelButtonTemplate")
    local button = CreateFrame("CheckButton", "ZooKeeperCompanionButton", PetPaperDollFrameCompanionFrame)
    button:SetSize(32, 32)
    button:SetPoint("RIGHT", CompanionPrevPageButton, "LEFT")
    button:SetPushedTexture("Interface\\AddOns\\ZooKeeper\\Assets\\Textures\\FavoriteUnset")
    button:SetHighlightTexture("Interface\\AddOns\\ZooKeeper\\Assets\\Textures\\FavoriteSet", "ADD")
    
    local function Update()
      if PetPaperDollFrameCompanionFrame.mode ~= "MOUNT" then
        button:Hide()
        return
      end
      local selected = PetPaperDollFrame_FindCompanionIndex()
      if selected > 0 then
        local spellID = select(3, GetCompanionInfo(PetPaperDollFrameCompanionFrame.mode, selected))
        button:SetNormalTexture("Interface\\AddOns\\ZooKeeper\\Assets\\Textures\\Favorite" .. (self:GetOption("fav", spellID) and "Set" or "Unset"))
        -- button:SetText(self:GetOption("fav", spellID) and BATTLE_PET_UNFAVORITE or BATTLE_PET_FAVORITE)
        button:Show()
      end
    end
    
    button:SetScript("OnClick", function()
      local selected = PetPaperDollFrame_FindCompanionIndex()
      if selected > 0 then
        local spellID = select(3, GetCompanionInfo(PetPaperDollFrameCompanionFrame.mode, selected))
        self:SetOption(not self:GetOption("fav", spellID), "fav", spellID)
        Update()
        UpdateAllFavIcons()
      end
    end)
    
    hooksecurefunc("PetPaperDollFrame_UpdateCompanionPreview", Update)
  end--]]
  
  hooksecurefunc("PetPaperDollFrame_UpdateCompanionPreview", function() PetPaperDollFrameCompanionFrame.Set:Update() PetPaperDollFrameCompanionFrame.Unset:Update() end)
  
end

