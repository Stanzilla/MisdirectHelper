local macroName = "MDTANK"

local _, _, classId = UnitClass("player")
local spellName = GetSpellInfo(classId == 4 and 57934 or 34477)

local frame = CreateFrame("FRAME")
frame:RegisterEvent("CHALLENGE_MODE_START")
frame:RegisterEvent("PLAYER_ROLES_ASSIGNED")

local function GroupMembers(reversed, forceParty)
  local unit = (not forceParty and IsInRaid()) and "raid" or "party"
  local numGroupMembers = forceParty and GetNumSubgroupMembers() or GetNumGroupMembers()
  local i = reversed and numGroupMembers or (unit == "party" and 0 or 1)
  return function()
    local ret
    if i == 0 and unit == "party" then
      ret = "player"
    elseif i <= numGroupMembers and i > 0 then
      ret = unit .. i
    end
    i = i + (reversed and -1 or 1)
    return ret
  end
end

frame:SetScript("OnEvent", function()
  frame:UnregisterEvent("PLAYER_REGEN_ENABLED")

  for unit in GroupMembers() do
    local role = UnitGroupRolesAssigned(unit)
    if role == "TANK" then
      if not InCombatLockdown() then
        EditMacro(macroName, nil, nil, "#showtooltip\n/cast [@" .. unit .. ", exists] " .. spellName .. "\n/cast [@pet] " .. spellName)
        frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
      else
        frame:RegisterEvent("PLAYER_REGEN_ENABLED")
      end
      break
    end
  end
end)
