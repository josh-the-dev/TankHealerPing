local addonName = ...

TankHealerPingDB = TankHealerPingDB or { enabled = true }

local seenApplicants = {}

local function CheckApplicants()
    if not TankHealerPingDB.enabled then return end
    if not C_LFGList or not C_LFGList.GetApplicants then return end

    local applicants = C_LFGList.GetApplicants()
    if not applicants then return end

    local activeSet = {}
    for _, applicantID in ipairs(applicants) do
        activeSet[applicantID] = true
        if not seenApplicants[applicantID] then
            seenApplicants[applicantID] = true

            local info = C_LFGList.GetApplicantInfo(applicantID)
            if info then
                local numMembers = info.numMembers or 1
                for i = 1, numMembers do
                    local memberInfo = C_LFGList.GetApplicantMemberInfo(applicantID, i)
                    if memberInfo then
                        local role = memberInfo.role
                        if role == "TANK" or role == "HEALER" then
                            PlaySound(SOUNDKIT.ALARM_CLOCK_RINGING_2, "Master")
                            break
                        end
                    end
                end
            end
        end
    end

    -- Prune applicants no longer in the list
    for id in pairs(seenApplicants) do
        if not activeSet[id] then
            seenApplicants[id] = nil
        end
    end
end

local frame = CreateFrame("Frame", "TankHealerPingFrame")
frame:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
frame:RegisterEvent("GROUP_LEFT")

frame:SetScript("OnEvent", function(self, event)
    if event == "LFG_LIST_APPLICANT_LIST_UPDATED" then
        CheckApplicants()
    elseif event == "GROUP_LEFT" then
        wipe(seenApplicants)
    end
end)

SLASH_TANKHEALERPING1 = "/thping"
SlashCmdList["TANKHEALERPING"] = function(msg)
    msg = strtrim(msg:lower())
    if msg == "on" then
        TankHealerPingDB.enabled = true
        print("|cff00ff00TankHealerPing:|r Enabled.")
    elseif msg == "off" then
        TankHealerPingDB.enabled = false
        print("|cff00ff00TankHealerPing:|r Disabled.")
    else
        local status = TankHealerPingDB.enabled and "|cff00ff00enabled|r" or "|cffff0000disabled|r"
        print("|cff00ff00TankHealerPing:|r " .. status .. "  |cffaaaaaa/thping on|off|r")
    end
end
