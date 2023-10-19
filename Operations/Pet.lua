
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)






local MACRO_BUTTON_NAME = "ZKP"
local SPELL_BUTTON_NAME = MACRO_BUTTON_NAME .. "_SPELL"











local function Summon()
  if InCombatLockdown() then return end
  
  local button = Addon:GetSpellButton(SPELL_BUTTON_NAME)
  button:SetAttribute("spell")
  
  local id
  
  if not Addon:HasValidCritters() or Addon:HasSummonedValidCritter() then
    id = Addon:GetSummonedCritter()
  elseif Addon:HasValidCritters() then
    id = Addon:SelectCritter()
  end
  
  if id then
    local name = select(8, C_PetJournal.GetPetInfoByPetID(id))
    
    button:SetAttribute("spell", name)
    return
  end
end




local function ModifyButton(init)
  if InCombatLockdown() then return end
  if not init and not Addon:DoesPetMacroNeedUpdate() then return end
  
  local macroText = Addon.MacroText()
  
  
  macroText:AddLine(Addon.Line("click", SPELL_BUTTON_NAME))
  
  
  
  if Addon:GetGlobalOption("debugOutput", "macroTextChanged") then
    Addon:Debugf("Pet macro updated. Lines: %d, Length: %d", #macroText:GetLines(), macroText:GetLength())
    for _, line in ipairs(macroText:GetLines()) do
      Addon:Debug(line)
    end
  end
  macroText:Apply(MACRO_BUTTON_NAME)
end






Addon:RegisterEnableCallback(function(self)
  self:GetSpellButton(SPELL_BUTTON_NAME):SetScript("PreClick", Summon)
  
  self:GetMacroButton(MACRO_BUTTON_NAME):SetScript("PreClick", ModifyButton)
  
  Addon:OnCombatEnd(function(self)
    self:GetMacroButton(MACRO_BUTTON_NAME):SetAttribute("macrotext",  "/click " .. self:GetMacroButtonName(MACRO_BUTTON_NAME, n))
    ModifyButton(true)
  end)
end)

