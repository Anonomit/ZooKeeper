
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)






local MACRO_BUTTON_NAME = "ZKP"
local SPELL_BUTTON_NAME = MACRO_BUTTON_NAME .. "_SPELL"











local function Summon(button)
  if InCombatLockdown() then return end
  Addon:DebugIfOutput("spellButtonClicked", "Pet button clicked")
  
  local id
  
  if Addon.expansionLevel < Addon.expansions.wrath then
    if Addon:HasValidCritters() then
      local spellID, itemID = Addon:SelectCritter()
      button:SetAttribute("type", "item")
      button:SetAttribute("item", "item:" .. itemID)
      Addon:SetLastCritter(spellID)
    end
  else
    if not Addon:HasValidCritters() or Addon:HasSummonedValidCritter() then
      id = Addon:GetSummonedCritter()
      C_PetJournal.DismissSummonedPet(id)
      Addon:SetLastCritter(id)
    elseif Addon:HasValidCritters() then
      id = Addon:SelectCritter()
      DoEmote"STAND"
      C_PetJournal.SummonPetByGUID(id)
      Addon:SetLastCritter(id)
    end
  end
  
end



local macroNeedsUpdate = true
local function ModifyButton()
  if InCombatLockdown() then return end
  if not macroNeedsUpdate and not Addon:DoesPetMacroNeedUpdate() then return end
  
  local macroText = Addon.MacroText()
  
  
  macroText:AddLine(Addon.Line("click", SPELL_BUTTON_NAME))
  
  
  
  if Addon:GetGlobalOption("debugOutput", "macroTextChanged") then
    Addon:Debugf("Pet macro updated. Lines: %d, Length: %d", #macroText:GetLines(), macroText:GetLength())
    for _, line in ipairs(macroText:GetLines()) do
      Addon:Debug(line)
    end
  end
  
  macroText:Apply(MACRO_BUTTON_NAME)
  
  macroNeedsUpdate = false
end

local function FlagForUpdate()
  macroNeedsUpdate = true
end






Addon:RegisterEnableCallback(function(self)
  self:GetMacroButton(MACRO_BUTTON_NAME, true)
  
  self:GetItemButton(SPELL_BUTTON_NAME):SetScript("PreClick",  Summon)
  
  self:GetMacroButton(MACRO_BUTTON_NAME):SetScript("PreClick", ModifyButton)
  self:RegisterEventCallback("PLAYER_REGEN_DISABLED",          ModifyButton)
  
  
  -- Just in case, run as soon as possible upon login
  self:WhenOutOfCombat(ModifyButton)
end)

