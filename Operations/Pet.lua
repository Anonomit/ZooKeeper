
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)






local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)






local BUTTON_NAME = "ZKP"















local dismountQueued = false

function Addon:Summon()
  
  if not self:HasValidCritters() or self:HasSummonedValidCritter() then
    C_PetJournal.DismissSummonedPet(self:GetSummonedCritter())
  else
    -- if GetUnitSpeed"player" ~= 0 then return end
    C_PetJournal.SummonPetByGUID(self:SelectCritter())
  end
end



local macroInitialized = false

local function ModifyCritterButton()
  if InCombatLockdown() then return end
  if macroInitialized and not Addon:DoesPetMacroNeedUpdate() then return end
  
  local macroText = Addon.MacroText()
  
  
  macroText:AddLine("/run " .. ADDON_NAME .. ":Summon()")
  
  
  
  if Addon:GetGlobalOption("debugOutput", "macroTextChanged") then
    Addon:Debugf("Pet macro updated. Lines: %d, Length: %d", #macroText:GetLines(), macroText:GetLength())
    for _, line in ipairs(macroText:GetLines()) do
      Addon:Debug(line)
    end
  end
  macroText:Apply(BUTTON_NAME)
end



function Addon:InitCritterButton()
  local mountButton = CreateFrame("Button", BUTTON_NAME, UIParent, "SecureActionButtonTemplate")
  mountButton:SetAttribute("type1", "macro")
  mountButton:SetScript("PreClick",  ModifyCritterButton)
  -- mountButton:SetScript("PostClick", ModifyCritterButton)
  mountButton:SetAttribute("macrotext1", "/click " .. self:GetMacroButtonName(BUTTON_NAME, n))
  ModifyCritterButton()
  macroInitialized = true
  
  -- mountButton = CreateFrame("Button", "ZKM", UIParent, "SecureActionButtonTemplate")
  -- mountButton:SetAttribute("type1", "macro")
  -- mountButton:SetScript("PreClick",  ModifyCritterButton)
  -- -- mountButton:SetScript("PostClick", ModifyCritterButton)
  -- ModifyCritterButton()
end




