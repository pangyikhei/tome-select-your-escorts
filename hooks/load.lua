-- load.lua

class:bindHook("Quest:escort:assign", function(self, data)

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

    for k, escort in pairs(data.possible_types) do
        if escort.name and escort.name == escortName then
            new_types[#new_types + 1] = escort
            break
        end
    end

    data.possible_types = new_types
    return data
end)

class:bindHook("ToME:birthDone", function(self, data)
    -- Unfortunately the possible_types is locally defined in escort-duty.lua and the Quest:escort:assign hook is only called from there
    -- So I have no way to retrieve the possible escort types directly until the quest is assigned without interfering with other
    -- mods.
    game.state.escort_selections = {}
    game.state.escort_selection_counts = {}
    game.state.escort_selection_counts["lost warrior"] = 0;
    game.state.escort_selection_counts["injured seer"] = 0;
    game.state.escort_selection_counts["repented thief"] = 0;
    game.state.escort_selection_counts["lone alchemist"] = 0;
    game.state.escort_selection_counts["lost sun paladin"] = 0;
    game.state.escort_selection_counts["lost defiler"] = 0;
    game.state.escort_selection_counts["temporal explorer"] = 0;
    game.state.escort_selection_counts["worried loremaster"] = 0;
    game.state.escort_selection_counts["lost tinker"] = 0;
    game.state.escort_selection_counts["random"] = 0;
    game.state.escortNum = 1

    local Chat = require "engine.Chat"
    local chat = Chat.new("escort-select", { name = "Select your Escorts!" }, game.player,
        {
            escort_selections = game.state.escort_selections,
            escort_selection_counts = game.state.escort_selection_counts,
            next_escort = 1
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
            game.state.escort_selection_counts["lost warrior"] = 0;
            game.state.escort_selection_counts["injured seer"] = 0;
            game.state.escort_selection_counts["repented thief"] = 0;
            game.state.escort_selection_counts["lone alchemist"] = 0;
            game.state.escort_selection_counts["lost sun paladin"] = 0;
            game.state.escort_selection_counts["lost defiler"] = 0;
            game.state.escort_selection_counts["temporal explorer"] = 0;
            game.state.escort_selection_counts["worried loremaster"] = 0;
            game.state.escort_selection_counts["lost tinker"] = 0;
            game.state.escort_selection_counts["random"] = 0;

            -- remove selected escorts that have not been encountered yet
            for i = 1, 10 - game.state.escortNum do
                table.remove(game.state.escort_selections)
            end

            -- Include the counts of escorts already encountered
            for i = 1, #game.state.escort_selections do
                game.state.escort_selection_counts[game.state.escort_selections[i]] = game.state.escort_selection_counts[game.state.escort_selections[i]] + 1
            end

            local chat = Chat.new("escort-select",
                { name = "Select your Escorts!" },
                game.player,
                {
                    escort_selections = game.state.escort_selections,
                    escort_selection_counts = game.state.escort_selection_counts,
                    next_escort = game.state.escortNum
                })
            chat:invoke()
        end
    })
end)