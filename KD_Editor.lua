local _MPPLY_GLOBAL = 1845263
local _MPPLY_GLOBAL_2 = 877
local _MPPLY_GLOBAL_3 = 205

local _MPPLY_DM_GLOBAL = 2657921
local _MPPLY_DM_GLOBAL_2 = 463
local _MPPLY_DM_GLOBAL_3 = 126

local kills_global             = memory.script_global(_MPPLY_GLOBAL + 1 + (players.user() * _MPPLY_GLOBAL_2) + _MPPLY_GLOBAL_3 + 28) -- MPPLY_KILLS_PLAYERS
local deaths_global            = memory.script_global(_MPPLY_GLOBAL + 1 + (players.user() * _MPPLY_GLOBAL_2) + _MPPLY_GLOBAL_3 + 29) -- MPPLY_DEATHS_PLAYER
local ratio_global             = memory.script_global(_MPPLY_GLOBAL + 1 + (players.user() * _MPPLY_GLOBAL_2) + _MPPLY_GLOBAL_3 + 26) -- MPPLY_KILL_DEATH_RATIO
local deathmatch_kills_global  = memory.script_global(_MPPLY_DM_GLOBAL + 1 + (players.user() * _MPPLY_DM_GLOBAL_2) + _MPPLY_DM_GLOBAL_3 + 1 + 2) -- MPPLY_DM_TOTAL_KILLS
local deathmatch_deaths_global = memory.script_global(_MPPLY_DM_GLOBAL + 1 + (players.user() * _MPPLY_DM_GLOBAL_2) + _MPPLY_DM_GLOBAL_3 + 1 + 3) -- MPPLY_DM_TOTAL_DEATHS

-- thank you Sapphire for helping me with reading/writing globals and helping me fix the ratio not being written <3

-- https://forum.cockos.com/showthread.php?t=183245
local function truncate(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces)
    return math.modf(num * mult) / mult
end

local my_root = menu.my_root()
local max_int = 2147483647

local STATS = {
    ["STAT_GET_INT"]=--[[BOOL (bool)]] function(--[[Hash (int)]] statHash,--[[int* (pointer)]] outValue,--[[int]] p2)native_invoker.begin_call()native_invoker.push_arg_int(statHash)native_invoker.push_arg_pointer(outValue)native_invoker.push_arg_int(p2)native_invoker.end_call_2(0x767FBC2AC802EF3D)return native_invoker.get_return_value_bool()end,
    ["STAT_GET_FLOAT"]=--[[BOOL (bool)]] function(--[[Hash (int)]] statHash,--[[float* (pointer)]] outValue,--[[Any (int)]] p2)native_invoker.begin_call()native_invoker.push_arg_int(statHash)native_invoker.push_arg_pointer(outValue)native_invoker.push_arg_int(p2)native_invoker.end_call_2(0xD7AE6C9C9C6AC54C)return native_invoker.get_return_value_bool()end,
    ["STAT_SET_INT"]=--[[BOOL (bool)]] function(--[[Hash (int)]] statName,--[[int]] value,--[[BOOL (bool)]] save)native_invoker.begin_call()native_invoker.push_arg_int(statName)native_invoker.push_arg_int(value)native_invoker.push_arg_bool(save)native_invoker.end_call_2(0xB3271D7AB655B441)return native_invoker.get_return_value_bool()end,
    ["STAT_SET_FLOAT"]=--[[BOOL (bool)]] function(--[[Hash (int)]] statName,--[[float]] value,--[[BOOL (bool)]] save)native_invoker.begin_call()native_invoker.push_arg_int(statName)native_invoker.push_arg_float(value)native_invoker.push_arg_bool(save)native_invoker.end_call_2(0x4851997F37FE9B3C)return native_invoker.get_return_value_bool()end,
}

local read_mpply_kills_pointer = memory.alloc(4)
local function read_mpply_kills()
    local int_stat_retrieved = STATS.STAT_GET_INT(util.joaat("MPPLY_KILLS_PLAYERS"), read_mpply_kills_pointer, -1)

    local retrieved_global_int = memory.read_int(kills_global)

    if int_stat_retrieved then
        retrieved_stat_int = memory.read_int(read_mpply_kills_pointer)
    end

    if retrieved_global_int == retrieved_stat_int then
        return retrieved_global_int
    end

    return retrieved_stat_int
end

local read_mpply_deaths_pointer = memory.alloc(4)
local function read_mpply_deaths()
    local int_stat_retrieved = STATS.STAT_GET_INT(util.joaat("MPPLY_DEATHS_PLAYER"), read_mpply_deaths_pointer, -1)

    local retrieved_global_int = memory.read_int(deaths_global)

    if int_stat_retrieved then
        retrieved_stat_int = memory.read_int(read_mpply_deaths_pointer)
    end

    if retrieved_global_int == retrieved_stat_int then
        return retrieved_global_int
    end

    return retrieved_stat_int
end

local read_mpply_ratio_pointer = memory.alloc(4)
local function read_mpply_ratio()
    local int_stat_retrieved = STATS.STAT_GET_FLOAT(util.joaat("MPPLY_KILL_DEATH_RATIO"), read_mpply_ratio_pointer, -1)

    local retrieved_global_int = memory.read_float(ratio_global)

    if int_stat_retrieved then
        retrieved_stat_int = memory.read_float(read_mpply_ratio_pointer)
    end

    if retrieved_global_int == retrieved_stat_int then
        return retrieved_global_int
    end

    return retrieved_stat_int
end

---Set a stat and global at once.
---@param global_integer integer --The global for the stat.
---@param stat_name string --The stat name.
---@param value number --The value to set.
local function write_global_stat_int(global_integer, stat_name, value)
    local stat_hash = util.joaat(stat_name)
    memory.write_int(global_integer, value)
    STATS.STAT_SET_INT(stat_hash, value, true)
end

---Set a stat and global at once.
---@param global_integer integer --The global for the stat.
---@param stat_name string --The stat name.
---@param value number --The value to set.
local function write_global_stat_float(global_integer, stat_name, value)
    memory.write_float(global_integer, value)
    STATS.STAT_SET_FLOAT(util.joaat(stat_name), value, true)
end

local function update_current_display()
    current_kills = read_mpply_kills()
    current_deaths = read_mpply_deaths()

    current_ratio = truncate(read_mpply_ratio(), 2)
end

if util.is_session_started() then

    update_current_display()

    my_root:divider("Current KD")

    current_kills_display = my_root:action("Current Kills: " .. current_kills, { "" }, "Shows current kills.", function() end)

    current_death_display = my_root:action("Current Deaths: " .. current_deaths, { "" }, "Shows current deaths.", function() end)

    current_ratio_display = my_root:action("Current Ratio: " .. current_ratio, { "" }, "Shows current ratio.", function() end)

    my_root:divider("New KD")

    local kills_slider_value = current_kills
    local deaths_slider_value = current_deaths

    new_kills = my_root:slider("New Kills Amount", {"killsamount"}, "Selects the number of kills.", -max_int, max_int, current_kills, 1, function(value)
        kills_slider_value = value
    end)

    new_deaths = my_root:slider("New Deaths Amount", {"deathsamount"}, "Selects the number of deaths.", -max_int, max_int, current_deaths, 1, function(value)
        deaths_slider_value = value
    end)

    util.create_tick_handler(function()
        local read_new_kills = kills_slider_value
        local read_new_deaths = deaths_slider_value

        new_ratio = truncate(read_new_kills / read_new_deaths, 2)

        if read_new_kills == 0 or read_new_deaths == 0 then
            new_ratio = 0
        end
    end)

    new_ratio_display = my_root:action("New Ratio: " .. new_ratio, { "" }, "Shows new ratio.", function()  end)

    util.create_tick_handler(function()
        menu.set_menu_name(current_kills_display, "Current Kills: " .. current_kills)
        menu.set_menu_name(current_death_display, "Current Deaths: " .. current_deaths)
        menu.set_menu_name(current_ratio_display, "Current Ratio: " .. current_ratio)
        menu.set_menu_name(new_ratio_display, "New Ratio: " .. new_ratio)
    end)

    my_root:action("Set KD", { "setkd" }, "Sets your KD.", function()

        write_global_stat_int(kills_global, "MPPLY_KILLS_PLAYERS", kills_slider_value)
        write_global_stat_int(deaths_global, "MPPLY_DEATHS_PLAYER", deaths_slider_value)
        write_global_stat_float(ratio_global, "MPPLY_KILL_DEATH_RATIO", new_ratio)
        write_global_stat_int(deathmatch_kills_global, "MPPLY_DM_TOTAL_KILLS", kills_slider_value)
        write_global_stat_int(deathmatch_deaths_global, "MPPLY_DM_TOTAL_DEATHS", deaths_slider_value)

        update_current_display()

        util.toast("Set your KD ratio to " .. new_ratio .. " c:")
    end)
else
    util.toast("You have to be online!")
    util.stop_script()
end

util.keep_running()