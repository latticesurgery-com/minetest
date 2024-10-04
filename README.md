
# A Minetest mod to view Lattice Surgery Computations in 3D

![FirstViewOf3dSlicing](https://github.com/latticesurgery-com/minetest/assets/36427091/6567bdf6-8b3b-459c-9af1-b839da6cde70)

## Getting started

### Setup
 1. clone `git@github.com:latticesurgery-com/minetest.git` (or HTTPS equivalent for no ssh key) into `~/.minetest/mods/latticesurgery`
    * Note that the `~/.minetest/mods/latticesurgery` should be the top level directory of the git repo, i.e. the lua file should be `~/.minetest/mods/latticesurgery/init.lua`
 2. run `python3 generate_tyles.py` for which you might need to `pip3 install pillow`
 2. IDE support for lua with minetest is not great yet. I use VSCode with the lua language server extesion from the marketplace
 3. Mod setup:
   a. Create a new world (set `flat` for world generator)
   b. From the main menu, make sure the world you just created is selected and then click on `Select Mods`
   c. From the mods menu, select `latticesurgery` and click the `enabled` checkmark


### Before starting minetest, in the `.minetest` folder
`touch minetest.conf`
and include the following line
`secure.enable_security = false`

### Run the Mod
 1. Select the world you just created and click `Play`
 2. Once the world loaded, press `t` and then type `/do_compile`
 3. Slices should appear in your world at this point


### How to load other slices
 1. Compile slices with `lsqecc`
    a. To get slices where ancilla is routed in 3d, you need to do the following
    b. Check out the `3d-routing` branch of the compiler
    c. Build
    d. Compile your slices with the `-P 3d` option
 2. Move the `.json` slices produced above under `~/.minetest/mods/latticesurgery`
 3. Adjust `insecure_load_crossings()` in `init.lua` to make sure do_compile loads the right files

### Minetest commands defined by the mod

 * `/do_compile` make a sample compilation appear into the world
 * `/crossings j` (where 0<=j<=8) display a compilation made of 8 instructions, one at a time depending on `j`. Note how this results in fewer than 8 slices, even though there are 8 instructions

### Useful edits to `init.lua`
 * Uncomment occurrences of `falling_node=2` to get nodes to fall like Minecraft sand
 * Change the position behaviour of where slices appear: edit `set_pos`. Defaults to player position


