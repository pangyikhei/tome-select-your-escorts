local escorts = {
    [1] = {
        name = "lost warrior",
        text = "[a lost warrior]",
        unique = false
    },
    [2] = {
        name = "injured seer",
        text = "[an injured seer]",
        unique = false
    },
    [3] = {
        name = "repented thief",
        text = "[a repented thief]",
        unique = false
    },
    [4] = {
        name = "lone alchemist",
        text = "[a lone alchemist]",
        unique = false
    },
    [5] = {
        name = "lost sun paladin",
        text = "[a lost sun paladin]",
        unique = false
    },
    [6] = {
        name = "lost defiler",
        text = "[a lost defiler]",
        unique = false
    },
    [7] = {
        name = "temporal explorer",
        text = "[a temporal explorer]",
        unique = false
    },
    [8] = {
        name = "worried loremaster",
        text = "[a worried loremaster]",
        unique = false
    }
}
-- tinker must be unlocked and can only be chosen once
if profile.mod.allow_build.orcs_tinker_eyal then
    escorts[#escorts + 1] = {
        name = "lost tinker",
        text = "[a lost tinker]",
        unique = true
    }
end
escorts[#escorts + 1] = {
    name = "random",
    text = "[an unknown adventurer (random)]",
    unique = false
}

local function generate_escorts(jump_target)
    local answers = {}
    local unique_added = {}
    for i = 1, #escorts do
        local escort = escorts[i]
        if escort.unique and not unique_added[escort.name] then
            answers[#answers + 1] = {
                escort.text,
                jump = jump_target,
                cond = function(self)
                    return escort_selection_counts[escort.name] == 0
                end,
                action = function(self)
                    escort_selections[#escort_selections + 1] = escort.name
                    escort_selection_counts[escort.name] = escort_selection_counts[escort.name] + 1
                end
            }
            unique_added[escort.name] = true
        else
            for i = 0, 8 do
                answers[#answers + 1] = {
                    escort.text .. " (" .. i .. ")",
                    jump = jump_target,
                    cond = function(self)
                        return escort_selection_counts[escort.name] == i
                    end,
                    action = function(self)
                        escort_selections[#escort_selections + 1] = escort.name
                        escort_selection_counts[escort.name] = escort_selection_counts[escort.name] + 1
                    end
                }
            end
        end
    end
    return answers
end

local function escortText(ordinal)
    return "#LIGHT_GREEN#*The #YELLOW#" .. ordinal .. "#LIGHT_GREEN# stranger you see appears to be...*#WHITE#"
end

newChat {
    id = "welcome",
    text = [[#LIGHT_GREEN#*You receive a vision of strangers.*
*You have a feeling you will meet them on your adventures.*

#YELLOW#[You may change your future encounters using the game menu (Esc)]
#LIGHT_RED#[The lost tinker may only be encountered once per game]#WHITE#]],
    answers = {
        { "[ok]", jump = "welcome" .. next_escort },
        {
            "[all random]",
            jump = "done",
            action = function(self)
                for i = next_escort, 9 do
                    escort_selections[#escort_selections + 1] = "random"
                    escort_selection_counts["random"] = 9
                end
            end
        },
    }
}


-- There are EXACTLY 9 escorts
newChat {
    id = "welcome1",
    text = escortText("first"),
    answers = generate_escorts("welcome2")
}

newChat {
    id = "welcome2",
    text = escortText("second"),
    answers = generate_escorts("welcome3")
}

newChat {
    id = "welcome3",
    text = escortText("third"),
    answers = generate_escorts("welcome4")
}

newChat {
    id = "welcome4",
    text = escortText("fourth"),
    answers = generate_escorts("welcome5")
}

newChat {
    id = "welcome5",
    text = escortText("fifth"),
    answers = generate_escorts("welcome6")
}

newChat {
    id = "welcome6",
    text = escortText("sixth"),
    answers = generate_escorts("welcome7")
}

newChat {
    id = "welcome7",
    text = escortText("seventh"),
    answers = generate_escorts("welcome8")
}

newChat {
    id = "welcome8",
    text = escortText("eighth"),
    answers = generate_escorts("welcome9")
}

newChat {
    id = "welcome9",
    text = escortText("ninth"),
    answers = generate_escorts("done")
}

newChat {
    id = "done",
    text = "All escorts selected! Good luck!",
    answers = {
        {
            "[ok]",
            action = function(self)
                game:saveGame()
                for k, v in pairs(escort_selections) do
                    print("Escort Selection #" .. k .. ": " .. v)
                end
            end
        }
    }
}

return "welcome"
