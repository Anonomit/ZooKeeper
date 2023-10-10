
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)




local MACRO_CHARACTER_LIMIT  = 1023
local MACRO_LENGTH_TOLERANCE = 20
local MAX_MACRO_LENGTH       = MACRO_CHARACTER_LIMIT - MACRO_LENGTH_TOLERANCE


local EXTENDER_PATTERN = "%s_Ext%d"













local function CreateButton(name)
  if not _G[name] then
    mountButton = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    mountButton:SetAttribute("type1", "macro")
  end
  return _G[name]
end


local function Bind(parent, n, buffer)
  local name = Addon:GetMacroButtonName(parent, n)
  local button = CreateButton(name)
  button:SetAttribute("macrotext1", buffer)
end




local function AddToBuffer(buffer, line)
  return buffer .. (buffer == "" and "" or "\n") .. line
end


function Addon:GetMacroButtonName(parent, n)
  return format(EXTENDER_PATTERN, parent, n or 1)
end

function Addon:BindMacro(parent, macroText)
  local n = 1
  local buffer = ""
  
  for i, line in ipairs(macroText:GetLines()) do
    if #buffer + #line > MAX_MACRO_LENGTH then
      Bind(parent, n, AddToBuffer(buffer, "/click " .. self:GetMacroButtonName(parent, n+1)))
      buffer = ""
      n = n + 1
    else
      buffer = AddToBuffer(buffer, line)
    end
  end
  
  if #buffer > 0 then
    Bind(parent, n, buffer)
  end
  
end




