util.require_natives("natives-1660775568")

-- stackoverflow is love
-- https://stackoverflow.com/a/67917666
local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local joaat = util.joaat
local my_root = menu.my_root()
local action = menu.action
local slider = menu.slider
local div = menu.divider
local max_int = 2147483647

local mem = {
    alloc = memory.alloc,
    g_global = memory.script_global,
    get_int = memory.read_int,
    get_float = memory.read_float,
}

local kills_ptr  = mem.alloc(4)
local deaths_ptr = mem.alloc(4)
local ratio_ptr  = mem.alloc(4)

-- thank you Sapphire for helping me with reading/writing globals and helping me fix the ratio not being written c:
local global_kills  = mem.g_global(1853910 + 1 + (players.user() * 862) + 205 + 28)
local global_deaths = mem.g_global(1853910 + 1 + (players.user() * 862) + 205 + 29)
local global_ratio  = mem.g_global(1853910 + 1 + (players.user() * 862) + 205 + 26)

local kills_stat_hash  = joaat("MPPLY_KILLS_PLAYERS")
local deaths_stat_hash = joaat("MPPLY_DEATHS_PLAYER")
local ratio_stat_hash  = joaat("MPPLY_KILL_DEATH_RATIO")

util.create_tick_handler(function()

    STATS.STAT_GET_INT(kills_stat_hash, kills_ptr, -1)
    STATS.STAT_GET_INT(deaths_stat_hash, deaths_ptr, -1)
    STATS.STAT_GET_FLOAT(ratio_stat_hash, ratio_ptr, -1)

    get_stat_kills  = mem.get_int(kills_ptr)
    get_stat_deaths = mem.get_int(deaths_ptr)
    get_stat_ratio  = mem.get_float(ratio_ptr)

    get_global_kills  = mem.get_int(global_kills)
    get_global_deaths = mem.get_int(global_deaths)
    get_global_ratio = mem.get_float(global_ratio)

    if get_global_kills == get_stat_kills then
        cur_kills = get_global_kills
    else
        cur_kills = get_stat_kills
    end

    if get_global_deaths == get_stat_deaths then
        cur_deaths = get_global_deaths
    else
        cur_deaths = get_stat_deaths
    end

    if get_global_ratio == get_stat_ratio then
        cur_ratio = get_global_ratio
    else
        cur_ratio = get_stat_ratio
    end
end)

if util.is_session_started() then

    div(my_root, "Current KD")

    local cur_kills_display = action(my_root, "Current Kills: " .. cur_kills, { "" }, "Shows current kills.", function() end)

    local cur_death_display = action(my_root, "Current Deaths: " .. cur_deaths, { "" }, "Shows current deaths.", function() end)

    local cur_ratio_display = action(my_root, "Current Ratio: " .. cur_ratio, { "" }, "Shows current ratio.", function() end)

    div(my_root, "New KD")

    local kills_slider_value = cur_kills
    local deaths_slider_value = cur_deaths

    local new_kills = slider(my_root, "New Kills Amount", {"killsamount"}, "Selects the number of kills.", -max_int, max_int, cur_kills, 1, function(value)
        kills_slider_value = value
    end)

    local new_deaths = slider(my_root, "New Deaths Amount", {"deathsamount"}, "Selects the number of deaths.", -max_int, max_int, cur_deaths, 1, function(value)
        deaths_slider_value = value
    end)

    util.create_tick_handler(function()
        new_ratio = menu.get_value(new_kills) / menu.get_value(new_deaths)
    end)

    local new_ratio_display = action(my_root, "New Ratio: " .. round(new_ratio, 2), { "" }, "Shows new ratio.", function()  end)

    action(my_root, "Set KD", { "setkd" }, "Sets your KD.", function()

        memory.write_int(global_kills, kills_slider_value)
        memory.write_int(global_deaths, deaths_slider_value)
        memory.write_float(global_ratio, new_ratio)

        STATS.STAT_SET_INT(kills_stat_hash, kills_slider_value, true)
        STATS.STAT_SET_INT(deaths_stat_hash, deaths_slider_value, true)
        STATS.STAT_SET_FLOAT(ratio_stat_hash, new_ratio, true)

        util.toast("Set your KD ratio to " .. new_ratio .. " c:")
    end)

    util.create_tick_handler(function()
        menu.set_menu_name(cur_kills_display, "Current Kills: " .. cur_kills)
        menu.set_menu_name(cur_death_display, "Current Deaths: " .. cur_deaths)
        menu.set_menu_name(cur_ratio_display, "Current Ratio: " .. round(cur_ratio, 2))
        menu.set_menu_name(new_ratio_display, "New Ratio: " .. new_ratio)
    end)
else
    util.yield(169)
    util.toast("You have to be online!")
    util.stop_script()
end

util.keep_running()