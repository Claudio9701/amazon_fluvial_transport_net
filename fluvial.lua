-- profile.lua for OSRM
-- This profile handles the specific highway types listed

-- Basic setup
-- local find_access_tag = require("lib/access").find_access_tag
-- local set_classification = require("lib/guidance").set_classification
-- local measure_speed = require("lib/speed").measure_speed


-- Define properties of the profile
properties = {
    -- Set the profile name
    name = "custom_profile",
    -- Set the maximum speed that can be assigned
    max_speed_for_map_matching = 180 / 3.6, -- 180 km/h in m/s
    -- For boat/ferry, indicate that they are allowed
    use_turn_restrictions = true,
    traffic_light_penalty = 2,  -- Penalty for traffic lights
    u_turn_penalty = 20,
    continue_straight_at_waypoint = true,
}

-- Define a default speed in case none is specified
default_speed = 10

-- Speed profiles per highway type
speeds = {
    motorway = 120,
    trunk = 110,
    primary = 100,
    secondary = 90,
    tertiary = 60,
    unclassified = 50,
    residential = 30,
    service = 15,
    living_street = 10,
    pedestrian = 5,
    footway = 5,
    cycleway = 20,
    bridleway = 10,
    steps = 2,
    track = 10,
    path = 5,
    road = 50,
    ferry = 10, -- speed for ferries (boats)
    boat = 10,
    tram = 40,
    rail = 100,
    narrow_gauge = 40,
}

-- Define access tags
access_tag_whitelist = {
    "yes",
    "foot",
    "bike",
    "car",
    "motor_vehicle",
    "vehicle",
    "boat",
}

access_tag_blacklist = {
    "private",
    "no",
}

restricted_access_tag_list = {
    "private",
    "no",
    "agricultural",
    "forestry",
}

restricted_highway_whitelist = {
    "track",
    "service",
}

function find_access_tag(entity, access_tags_to_check)
    for i, tag in ipairs(access_tags_to_check) do
        local access_tag = entity:get_value_by_key(tag)
        if access_tag then
            return access_tag
        end
    end
    return nil
end

-- Define the process for each node (usually not modified much)
function node_function(node, result)
    local access = find_access_tag(node, access_tag_whitelist)
    if access then
        result.barrier = true
        result.access = false
    end
end

-- Define the process for each way (road segment)
-- function way_function(way, result)
--     -- Get the fclass (highway type)
--     local highway = way:get_value_by_key("highway")
--     local fclass = way:get_value_by_key("fclass")

--     -- Exclude irrelevant ways
--     if not highway or highway == "" then
--         return
--     end

--     -- Set the road speed
--     result.forward_speed = speeds[fclass] or speeds[highway] or default_speed
--     result.backward_speed = result.forward_speed

--     -- Determine if the road is accessible
--     local access = find_access_tag(way, access_tag_whitelist)
--     if access then
--         result.forward_mode = mode.driving
--         result.backward_mode = mode.driving
--     else
--         result.is_access_restricted = true
--     end

--     -- Set access restrictions based on tags
--     if fclass == "ferry" or fclass == "boat" then
--         result.forward_mode = mode.ferry
--         result.backward_mode = mode.ferry
--         result.duration = measure_speed(result.forward_speed, way)
--     end

--     -- Set classification for guidance
--     set_classification(highway, result)
-- end

function way_function(way, result)
    local highway = way:get_value_by_key("highway")
    if not highway or highway == "" then
        return
    end
    result.forward_speed = speeds[highway] or default_speed
    result.backward_speed = result.forward_speed
    result.forward_mode = mode.driving
    result.backward_mode = mode.driving
end

-- Process for each relation (not necessary for this profile but required)
function relation_function(relation, result)
    -- Turn restrictions and other relation processing can go here
end