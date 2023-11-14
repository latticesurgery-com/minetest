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
    local json_file_path = mod_path .. "/demo.json"
    f = ie.io.open(json_file_path)
    s = f:read("a")
    ie.io.close(f)
    return minetest.parse_json(s)
    
end

local function sleep(n)
    ie.os.execute("sleep " .. tonumber(n))
end


local function place_layer(starting_point, slices)
    for t = 1, #slices do
        for r = 1, #slices[t] do
            for c = 1, #slices[t][r] do
                local value = slices[t][r][c]
                if value then
                        local name = string.format("latticesurgery:routing_%i",t%12+1)
                        if value['patch_type'] == 'DistillationQubit' then
                            name = "latticesurgery:distillation"
                        elseif value['patch_type'] == 'Qubit' then
                            name = "latticesurgery:qubit"
                        end

                    local position = add_vectors(starting_point, { x = r, y = t, z = c })
                    minetest.place_node(position,  { name = name })
                end
            end
        end
    end
    
end


NUM_ROUTING_COLOURS = 12

for i = 1, 12, 1 do
    minetest.register_node(string.format("latticesurgery:routing_%i",i), {
        description = string.format("Routing Volume color variation %i",i),
        tiles = {string.format("routing_%i.png",i)},
        drawtype = "glasslike",
        groups = {cracky = 1, falling_node=2}
    })
end


minetest.register_node("latticesurgery:distillation", {
    description = "Distillation volume",
    tiles = {"distillation.png"},
    drawtype = "glasslike",
    groups = {cracky = 1,  falling_node=2}
})


minetest.register_node("latticesurgery:qubit", {
    description = "Qubit",
    tiles = {"qubit.png"},
    drawtype = "glasslike",
    groups = {cracky = 1, falling_node=2}
})


local function do_compile(name, param)
    local slices = insecure_load_file()
    local player = minetest.get_player_by_name(name)
    place_layer(player:get_pos(), slices)
end

minetest.register_chatcommand("do_compile", {
    func = do_compile
})


