local function add_vectors(vector1, vector2)
    if type(vector1) == "table" and type(vector2) == "table" then
        local result = {
            x = (vector1.x or 0) + (vector2.x or 0),
            y = (vector1.y or 0) + (vector2.y or 0),
            z = (vector1.z or 0) + (vector2.z or 0)
        }
        return result
    else
        error("Both arguments must be tables representing vectors")
    end
end
 

ie = minetest.request_insecure_environment()

local function insecure_load_file()
    local mod_path = minetest.get_modpath("latticesurgery")
    local json_file_path = mod_path .. "/crossings/grover_3.json"
    f = ie.io.open(json_file_path)
    s = f:read("a")
    ie.io.close(f)
    return minetest.parse_json(s)
    
end

local function insecure_load_crossings(index)
    local mod_path = minetest.get_modpath("latticesurgery")
    local json_file_path = mod_path .. "/crossings/crossings_3d_" .. index ..".json"
    f = ie.io.open(json_file_path)
    s = f:read("a")
    ie.io.close(f)
    return minetest.parse_json(s)
    
end


local function sleep(n)
    ie.os.execute("sleep " .. tonumber(n))
end

local function array_to_s(a)
    local r = ""
    for i, k in pairs(a) do
        r = r .. k
    end
    return r
end

local function stitch_border(border, patch_type)
    if border == "AncillaJoin" then return true end
    if border == "SolidStiched" then return true end
    if border == "DashedStiched" then return true end
    if border == "Solid" then return false end
    if border == "Dashed" then return false end
    if border == "None" and patch_type == "DistillationQubit" then return true end

    return false
end

local function is_dead_cell(cell)
    if cell['patch_type'] == "Ancilla" and
        cell['edges']['Top'] == "None" and
        cell['edges']['Bottom'] == "None" and
        cell['edges']['Left'] == "None" and
        cell['edges']['Right'] == "None" 
    then
        return true
    end
    return false
end

local function max(a,b)
    if a > b then
        return a
    else 
        return b
    end
end

local function max_key(start, ll)
    acc = start
    for k,v in pairs(ll) do
        acc = max(acc, k)
    end
    return acc
end

local function place_layers(starting_point, slices)
    for t = 1, #slices do
        for r, rval in pairs(slices[t]) do
            for c, cval in  pairs(slices[t][r]) do
                local value = slices[t][r][c]
                if value and (not is_dead_cell(value)) and value['patch_type'] ~= 'DistillationQubit' then
                    
                    local connections = {0, 0, 0, 0, 1, 1};
                    if stitch_border(value['edges']['Top'], value['patch_type']) then connections[1] = 1 end
                    if stitch_border(value['edges']['Bottom'], value['patch_type']) then connections[2] = 1 end
                    if stitch_border(value['edges']['Left'], value['patch_type']) then connections[3] = 1 end
                    if stitch_border(value['edges']['Right'], value['patch_type']) then connections[4] = 1 end

                    if value['patch_type'] == 'Ancilla' then
                        if not value['routing_connect_to_prec'] then
                            connections[5] = 0;
                        end
                        if not value['routing_connect_to_next'] then
                            connections[6] = 0;
                        end
                    end

                    local name = string.format("latticesurgery:routing_%i_%s",t%12+1, array_to_s(connections))
                    if is_dead_cell(value) then
                        name = "latticesurgery:dead_cell"
                    elseif value['patch_type'] == 'DistillationQubit' then
                        name = string.format("latticesurgery:distillation_%s", array_to_s(connections))
                    elseif value['patch_type'] == 'Qubit' then
                        name = string.format("latticesurgery:qubit_%s", array_to_s(connections))
                    end

                    local position = add_vectors(starting_point, { x = r, y = t, z = c })
                    local existing_node = minetest.get_node(position)
                    if existing_node.name ~= "air" then
                        minetest.remove_node(position)
                    end
                    minetest.place_node(position,  { name = name })
                end
            end
        end
    end
    
end


NUM_ROUTING_COLOURS = 12



for j = 0, 63, 1 do
    -- j to bit string
    local bitstring = {
        math.floor(j / 32) % 2,
        math.floor(j / 16) % 2,
        math.floor(j / 8) % 2,
        math.floor(j / 4) % 2,
        math.floor(j / 2) % 2,
        math.floor(j / 1) % 2};

    minetest.register_node(string.format("latticesurgery:qubit_%s", array_to_s(bitstring)), {
        description = string.format("Qubit %s", array_to_s(bitstring)),
        tiles = {"qubit.png"},
        drawtype = "nodebox",
        node_box = {
            type = "connected",
            drawtype = "nodebox",
            fixed = {
                -3/8 - bitstring[1] * 1/8, 
                -3/8 - bitstring[5] * 1/8,
                -3/8 - bitstring[3] * 1/8, 
                3/8 + bitstring[2] * 1/8,
                3/8 + bitstring[6] * 1/8,
                3/8 + bitstring[4] * 1/8},
        },
        groups = {cracky = 1} -- , falling_node=2}
    })

    minetest.register_node(string.format("latticesurgery:distillation_%s", array_to_s(bitstring)), {
        description = string.format("Distillation volume", array_to_s(bitstring)),
        tiles = {"distillation.png"},
        drawtype = "nodebox",
            node_box = {
                type = "connected",
                drawtype = "nodebox",
                fixed = {
                    -3/8 - bitstring[1] * 1/8, 
                    -3/8 - bitstring[5] * 1/8,
                    -3/8 - bitstring[3] * 1/8, 
                    3/8 + bitstring[2] * 1/8,
                    3/8 + bitstring[6] * 1/8,
                    3/8 + bitstring[4] * 1/8},
            },
        groups = {cracky = 1} -- , falling_node=2}
    })

    for i = 1, 12, 1 do
        minetest.register_node(string.format("latticesurgery:routing_%i_%s",i, array_to_s(bitstring)), {
            description = string.format("Routing Volume color variation %i %s",i, array_to_s(bitstring)),
            tiles = {string.format("routing_%i.png",i)},
            drawtype = "nodebox",
            node_box = {
                type = "connected",
                drawtype = "nodebox",
                fixed = {
                    -3/8 - bitstring[1] * 1/8, 
                    -3/8 - bitstring[5] * 1/8,
                    -3/8 - bitstring[3] * 1/8, 
                    3/8 + bitstring[2] * 1/8,
                    3/8 + bitstring[6] * 1/8,
                    3/8 + bitstring[4] * 1/8},
            },
            groups = {cracky = 1} -- , falling_node=2}
        })
    end
end

minetest.register_node("latticesurgery:dead_cell", {
    description = "Dead Cell",
    tiles = {"dead.png"},
    drawtype = "glasslike",
    groups = {cracky = 1} -- , falling_node=2}
})



LS_LOCAL_START_POS = nil

local function set_pos(name, param)
    local player = minetest.get_player_by_name(name)
    LS_LOCAL_START_POS = player:get_pos()
end

minetest.register_chatcommand("set_pos", {
    func = set_pos
})

local function crossings(name, param)
    local slices = insecure_load_crossings(param)
    if LS_LOCAL_START_POS ~= nil then
        place_layers(LS_LOCAL_START_POS, slices)
    else
        local player = minetest.get_player_by_name(name)
        place_layers(player:get_pos(), slices)
    end

end

minetest.register_chatcommand("crossings", {
    func = crossings
})


local function do_compile(name, param)
    local slices = insecure_load_file()
    if LS_LOCAL_START_POS ~= nil then
        place_layers(LS_LOCAL_START_POS, slices)
    else
        local player = minetest.get_player_by_name(name)
        place_layers(player:get_pos(), slices)
    end
end

minetest.register_chatcommand("do_compile", {
    func = do_compile
})

