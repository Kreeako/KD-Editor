--  ╔═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
--  ║                                                                                                                                             ║
--  ║    Written by Kreeako                                                                                                                       ║
--  ║    If you are looking for an updated version of this script, you may be able to find it on github: https://github.com/Kreeako/KD-Editor     ║
--  ║                                                                                                                                             ║
--  ╚═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝

if menu.get_version().game ~= "1.69-3274" then
    util.toast("The version of this script is outdated, check github for an update.")
    util.stop_script()
end

local _MPPLY_GLOBAL_0 <const> = 1845281
local _MPPLY_GLOBAL_1 <const> = 877
local _MPPLY_GLOBAL_2 <const> = 205

local _MPPLY_DM_GLOBAL_0 <const> = 2657971
local _MPPLY_DM_GLOBAL_1 <const> = 463
local _MPPLY_DM_GLOBAL_2 <const> = 126

local MPPLY_KILLS_PLAYERS_GLOBAL    <const> = memory.script_global(_MPPLY_GLOBAL_0 + 1 +    (players.user() * _MPPLY_GLOBAL_1)    + _MPPLY_GLOBAL_2 + 28)       -- MPPLY_KILLS_PLAYERS
local MPPLY_DEATHS_PLAYER_GLOBAL    <const> = memory.script_global(_MPPLY_GLOBAL_0 + 1 +    (players.user() * _MPPLY_GLOBAL_1)    + _MPPLY_GLOBAL_2 + 29)       -- MPPLY_DEATHS_PLAYER
local MPPLY_KILL_DEATH_RATIO_GLOBAL <const> = memory.script_global(_MPPLY_GLOBAL_0 + 1 +    (players.user() * _MPPLY_GLOBAL_1)    + _MPPLY_GLOBAL_2 + 26)       -- MPPLY_KILL_DEATH_RATIO
local MPPLY_DM_TOTAL_KILLS_GLOBAL   <const> = memory.script_global(_MPPLY_DM_GLOBAL_0 + 1 + (players.user() * _MPPLY_DM_GLOBAL_1) + _MPPLY_DM_GLOBAL_2 + 1 + 2) -- MPPLY_DM_TOTAL_KILLS
local MPPLY_DM_TOTAL_DEATHS_GLOBAL  <const> = memory.script_global(_MPPLY_DM_GLOBAL_0 + 1 + (players.user() * _MPPLY_DM_GLOBAL_1) + _MPPLY_DM_GLOBAL_2 + 1 + 3) -- MPPLY_DM_TOTAL_DEATHS

-- thank you Sapphire for helping me with reading/writing globals and helping me fix the ratio not being written <3

local base_root <const> = menu.my_root()
local int64_max_positive <const> = 2147483647
local int64_max_negative <const> = -2147483648

local MPPLY_KILLS_PLAYERS_HASH    <const> = util.joaat("MPPLY_KILLS_PLAYERS")
local MPPLY_DEATHS_PLAYER_HASH    <const> = util.joaat("MPPLY_DEATHS_PLAYER")
local MPPLY_KILL_DEATH_RATIO_HASH <const> = util.joaat("MPPLY_KILL_DEATH_RATIO")
local MPPLY_DM_TOTAL_KILLS_HASH   <const> = util.joaat("MPPLY_DM_TOTAL_KILLS")
local MPPLY_DM_TOTAL_DEATHS_HASH  <const> = util.joaat("MPPLY_DM_TOTAL_DEATHS")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Online Functions / Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Online Functions / Variables

local online <const> = {}

---For checking if in a session.
---@return boolean -- If in session.
function online.in_session()
    if util.is_session_started() and not util.is_session_transition_active() then
        return true
    end
    return false
end

--#endregion Online Functions / Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Online Functions / Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Stats Functions / Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Stats Functions / Variables

local STATS <const> = {}

---For reading an integer stat value.
---@param keyHash integer -- The stat hash to retrieve.
---@param data userdata -- Your pointer to read the data from.
---@param playerIndex integer -- The player index to read from.
---@return boolean -- Returns if native was successful in getting stat.
function STATS.STAT_GET_INT(--[[STATSENUM]] keyHash, --[[INT&]] data, --[[INT]] playerIndex)
    native_invoker.begin_call()
    native_invoker.push_arg_int(keyHash)
    native_invoker.push_arg_pointer(data)
    native_invoker.push_arg_int(playerIndex)
    native_invoker.end_call_2(0x767FBC2AC802EF3D)
    return native_invoker.get_return_value_bool()
end

---For reading a float stat value.
---@param keyHash integer -- The stat hash to retrieve.
---@param data userdata -- Your pointer to read the data from.
---@param playerIndex integer -- The player index to read from.
---@return boolean -- Returns if native was successful in getting stat.
function STATS.STAT_GET_FLOAT(--[[STATSENUM]] keyHash, --[[INT&]] data, --[[INT]] playerIndex)
    native_invoker.begin_call()
    native_invoker.push_arg_int(keyHash)
    native_invoker.push_arg_pointer(data)
    native_invoker.push_arg_int(playerIndex)
    native_invoker.end_call_2(0xD7AE6C9C9C6AC54C)
    return native_invoker.get_return_value_bool()
end

---For writing an int stat value.
---@param keyHash integer -- The stat hash to write to.
---@param data integer -- The value to set the stat to.
---@param coderAssert boolean -- If to save the stat.
---@return boolean -- Returns if native was successful in writing stat.
function STATS.STAT_SET_INT(--[[STATSENUM]] keyHash, --[[INT]] data, --[[BOOL]] coderAssert)
    native_invoker.begin_call()
    native_invoker.push_arg_int(keyHash)
    native_invoker.push_arg_int(data)
    native_invoker.push_arg_bool(coderAssert)
    native_invoker.end_call_2(0xB3271D7AB655B441)
    return native_invoker.get_return_value_bool()
end

---For writing a float stat value. 
---@param keyHash integer -- The stat hash to write to.
---@param data integer -- The value to set the stat to.
---@param coderAssert boolean -- If to save the stat.
---@return boolean -- Returns if native was successful in writing stat.
function STATS.STAT_SET_FLOAT(--[[STATSENUM]] keyHash, --[[INT]] data, --[[BOOL]] coderAssert)
    native_invoker.begin_call()
    native_invoker.push_arg_int(keyHash)
    native_invoker.push_arg_float(data)
    native_invoker.push_arg_bool(coderAssert)
    native_invoker.end_call_2(0x4851997F37FE9B3C)
    return native_invoker.get_return_value_bool()
end

--#endregion Stats Functions / Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Stats Functions / Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Math Functions / Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--#region Math Functions / Variables

---For truncating.
---@param num number
---@param numDecimalPlaces integer
---@return number
function math.truncate(num, numDecimalPlaces) -- https://forum.cockos.com/showthread.php?t=183245
    local mult = 10 ^ (numDecimalPlaces)
    return math.modf(num * mult) / mult
end

--#endregion Math Functions / Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Math Functions / Variables
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local read_mpply_kills_pointer = memory.alloc(4)
local function read_mpply_kills()
    local int_stat_retrieved = STATS.STAT_GET_INT(MPPLY_KILLS_PLAYERS_HASH, read_mpply_kills_pointer, -1)

    local retrieved_global_int = memory.read_int(MPPLY_KILLS_PLAYERS_GLOBAL)

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
    local int_stat_retrieved = STATS.STAT_GET_INT(MPPLY_DEATHS_PLAYER_HASH, read_mpply_deaths_pointer, -1)

    local retrieved_global_int = memory.read_int(MPPLY_DEATHS_PLAYER_GLOBAL)

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
    local int_stat_retrieved = STATS.STAT_GET_FLOAT(MPPLY_KILL_DEATH_RATIO_HASH, read_mpply_ratio_pointer, -1)

    local retrieved_global_int = memory.read_float(MPPLY_KILL_DEATH_RATIO_GLOBAL)

    if int_stat_retrieved then
        retrieved_stat_int = memory.read_float(read_mpply_ratio_pointer)
    end

    if retrieved_global_int == retrieved_stat_int then
        return retrieved_global_int
    end

    return retrieved_stat_int
end

local function write_kd(kills, deaths, ratio)
    memory.write_int(MPPLY_KILLS_PLAYERS_GLOBAL, kills)
    STATS.STAT_SET_INT(MPPLY_KILLS_PLAYERS_HASH, kills, true)

    memory.write_int(MPPLY_DEATHS_PLAYER_GLOBAL, deaths)
    STATS.STAT_SET_INT(MPPLY_DEATHS_PLAYER_HASH, deaths, true)

    memory.write_float(MPPLY_KILL_DEATH_RATIO_GLOBAL, ratio)
    STATS.STAT_SET_FLOAT(MPPLY_KILL_DEATH_RATIO_HASH, ratio, true)

    memory.write_int(MPPLY_DM_TOTAL_KILLS_GLOBAL, kills)
    STATS.STAT_SET_INT(MPPLY_DM_TOTAL_KILLS_HASH, kills, true)

    memory.write_int(MPPLY_DM_TOTAL_DEATHS_GLOBAL, deaths)
    STATS.STAT_SET_INT(MPPLY_DM_TOTAL_DEATHS_HASH, deaths, true)
end

local function update_current_display()
    current_kills = read_mpply_kills()
    current_deaths = read_mpply_deaths()

    current_ratio = math.truncate(read_mpply_ratio(), 2)
end

if online.in_session() then
    update_current_display()

    base_root:divider("Current KD")

    current_kills_display = base_root:action("Current Kills: " .. current_kills, { "" }, "Shows current kills.", function() end)

    current_death_display = base_root:action("Current Deaths: " .. current_deaths, { "" }, "Shows current deaths.", function() end)

    current_ratio_display = base_root:action("Current Ratio: " .. current_ratio, { "" }, "Shows current ratio.", function() end)

    base_root:divider("New KD")

    local kills_slider_value = current_kills
    local deaths_slider_value = current_deaths

    new_kills = base_root:slider("New Kills Amount", { "killsamount" }, "Selects the number of kills.",
        int64_max_negative, int64_max_positive, current_kills, 1, function(value)
        kills_slider_value = value
    end)

    new_deaths = base_root:slider("New Deaths Amount", { "deathsamount" }, "Selects the number of deaths.",
        int64_max_negative, int64_max_positive, current_deaths, 1, function(value)
        deaths_slider_value = value
    end)

    util.create_tick_handler(function()
        local read_new_kills = kills_slider_value
        local read_new_deaths = deaths_slider_value

        new_ratio = math.truncate(read_new_kills / read_new_deaths, 2)

        if read_new_kills == 0 or read_new_deaths == 0 then
            new_ratio = 0
        end
    end)

    new_ratio_display = base_root:action("New Ratio: " .. new_ratio, { "" }, "Shows new ratio.", function() end)

    util.create_tick_handler(function()
        menu.set_menu_name(current_kills_display, "Current Kills: " .. current_kills)
        menu.set_menu_name(current_death_display, "Current Deaths: " .. current_deaths)
        menu.set_menu_name(current_ratio_display, "Current Ratio: " .. current_ratio)
        menu.set_menu_name(new_ratio_display, "New Ratio: " .. new_ratio)
    end)

    base_root:action("Set KD", { "setnewkd" }, "Sets your KD.", function()
        write_kd(kills_slider_value, deaths_slider_value, new_ratio)
        update_current_display()
        util.toast("Set your KD ratio to " .. new_ratio .. " c:")
    end)
else
    util.toast("You have to be online!")
    util.stop_script()
end

util.keep_running()