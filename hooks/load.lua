-- load.lua

local EscortRewards = require("mod.class.EscortRewards")

class:bindHook("EscortRewards:givers", function(self,data)
    if not game.state.initialized_sye then
        return data
    end

    local escortName = game.state.escort_selections[game.state.escortNum]
    if (escortName == nil) then
        -- support more than 9 escorts?
        print("nil escort at " .. game.state.escortNum)
        escortName = "random"
    end
    -- increment escort index
    print("Escort Selection: " .. escortName)
    if escortName == 'random' then
        -- no modification
        return data
    end
    local new_types = {}

    for k, possible_escort in pairs(data.possible_types) do
        if possible_escort.escort and possible_escort.escort.name and possible_escort.escort.name == escortName then
            new_types[k] = possible_escort
            break
        end
    end

    data.possible_types = new_types
    return data
end)

class:bindHook("ToME:birthDone", function(self, data)
    local possible_escorts = EscortRewards:listGivers()

    game.state.escort_selections = {}
    game.state.escort_selection_counts = {}

    local escort_choices = initEscortChoices(possible_escorts)
    game.state.escortNum = 1
    game.state.initialized_sye = true

    local Chat = require "engine.Chat"
    local chat = Chat.new("escort-select", { name = "Select your Escorts!" }, game.player,
        {
            escort_selections = game.state.escort_selections,
            escort_selection_counts = game.state.escort_selection_counts,
            next_escort = 1,
            escorts = escort_choices
        })
    chat:invoke()
end)

class:bindHook("Chat:load", function(self, data)

    if self.name == "escort-quest-start" then
        -- only increment the escort num if the escort quest was actually given!
        -- if the escort doesn't spawn, it still goes through the Quest:escort:assign hook
        game.state.escortNum = game.state.escortNum + 1
    end
end)

class:bindHook("Game:alterGameMenu", function(self, data)
    table.insert(data.menu, 1, {
        "Addon: Select your Escorts (again)", function()
            local Chat = require "engine.Chat"
            if game.state.escortNum == 10 then
                -- don't let the player change selection after all escorts have been encountered
                Chat.new("escorts-already-encountered", {name="All escorts encountered!"}, game.player):invoke()
                return
            end

            game.state.initialized_sye = false

            local possible_escorts = EscortRewards:listGivers()
            local escort_choices = initEscortChoices(possible_escorts)

            -- remove selected escorts that have not been encountered yet
            for i = 1, 10 - game.state.escortNum do
                table.remove(game.state.escort_selections)
            end

            -- Include the counts of escorts already encountered
            for i = 1, #game.state.escort_selections do
                game.state.escort_selection_counts[game.state.escort_selections[i]] = game.state.escort_selection_counts[game.state.escort_selections[i]] + 1
            end

            game.state.initialized_sye = true

            local chat = Chat.new("escort-select",
                { name = "Select your Escorts!" },
                game.player,
                {
                    escort_selections = game.state.escort_selections,
                    escort_selection_counts = game.state.escort_selection_counts,
                    next_escort = game.state.escortNum,
                    escorts = escort_choices
                })
            chat:invoke()
        end
    })
end)

function initEscortChoices (possible_escorts)
    local escort_choices = {}
    for k, possible_escort in pairs(possible_escorts) do
        game.state.escort_selection_counts[possible_escort.escort.name] = 0

        local escort_name = possible_escort.escort.name
        local a = "a"
        if string.find("aeiou", escort_name.sub(1,1)) then
            a = "an"
        end

        escort_choices[#escort_choices + 1] = {
            name = escort_name,
            text = "[".. a .. " " .. escort_name .. "]",
            unique = possible_escort.unique
        }
    end

    escort_choices[#escort_choices + 1] = {
        name = "random",
        text = "[an unknown adventurer (random)]",
        unique = false
    }

    game.state.escort_selection_counts["random"] = 0;

    return escort_choices
end