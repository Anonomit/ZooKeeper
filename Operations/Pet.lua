
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)






local MACRO_BUTTON_NAME = "ZKP"
local SPELL_BUTTON_NAME = MACRO_BUTTON_NAME .. "_SPELL"











local function Summon(button)
  if InCombatLockdown() then return end
  Addon:DebugIfOutput("spellButtonClicked", "Pet button clicked")
  
  button:SetAttribute"spell"
  button.id = nil
  
  local id
  
  if not Addon:HasValidCritters() or Addon:HasSummonedValidCritter() then
    id = Addon:GetSummonedCritter()
  elseif Addon:HasValidCritters() then
    id = Addon:SelectCritter()
  end
  
  if id then
    button.id = id
    
    local name = select(8, C_PetJournal.GetPetInfoByPetID(id))
    
    button:SetAttribute("spell", name)
    return
  end
end
local function PostSummon(button)
  local id = button.id
  if id then
    Addon:SetLastCritter(id)
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
  self:GetSpellButton(SPELL_BUTTON_NAME):SetScript("PreClick",  Summon)
  self:GetSpellButton(SPELL_BUTTON_NAME):SetScript("PostClick", PostSummon)
  
  self:GetMacroButton(MACRO_BUTTON_NAME):SetScript("PreClick", ModifyButton)
  self:RegisterEventCallback("PLAYER_REGEN_DISABLED",          ModifyButton)
  
  
  -- Just in case, run as soon as possible upon login
  self:OnCombatEnd(ModifyButton)
end)

