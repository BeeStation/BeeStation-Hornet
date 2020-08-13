/*
 * Just for you beauitful mappers.
 *
 * These are the mapping spawners for shuttles, on spawn depending on the difficulty of the area weapons will by dynamically applied.
 * Thats literally it, it's not a helper, it's required unless you want your ship to have static weapons.
*/

/obj/effect/landmark/exploration_weapon_spawner
	name = "ship weapon spawner"
	icon = 'icons/effects/mapping_arrows.dmi'
	icon_state = "blue_up"
	var/spawn_dir = 2	//Where the weapon itself will spawn, direction will be the direction it faces

/obj/effect/landmark/exploration_weapon_spawner/proc/do_weapon_spawn()
	//Pick a weapon type
	var/list/valid_weapon_types = subtypesof(/obj/machinery/shuttle_weapon)
	spawn_weapon(pick(valid_weapon_types))
	qdel(src)

/obj/effect/landmark/exploration_weapon_spawner/proc/spawn_weapon(weapon_type)
	var/obj/machinery/shuttle_weapon/spawned_weapon = new weapon_type(get_turf(src))
	spawned_weapon.dir = dir
	switch(spawn_dir)
		if(1)
			spawned_weapon.pixel_y = -32
		if(2)
			spawned_weapon.pixel_y = 32
		if(4)
			spawned_weapon.pixel_x = 32
		if(8)
			spawned_weapon.pixel_x = -32

/obj/effect/landmark/exploration_weapon_spawner/down
	name = "ship weapon spawner"
	icon = 'icons/effects/mapping_arrows.dmi'
	icon_state = "blue_down"
	spawn_dir = 1

/obj/effect/landmark/exploration_weapon_spawner/left
	name = "ship weapon spawner"
	icon = 'icons/effects/mapping_arrows.dmi'
	icon_state = "blue_left"
	spawn_dir = 8

/obj/effect/landmark/exploration_weapon_spawner/right
	name = "ship weapon spawner"
	icon = 'icons/effects/mapping_arrows.dmi'
	icon_state = "blue_right"
	spawn_dir = 4

/obj/effect/landmark/exploration_weapon_spawner/turret_mount
	name = "ship weapon spawner (turret mount)"
	icon = 'icons/effects/mapping_arrows.dmi'
	icon_state = "red_arrow"

/obj/effect/landmark/exploration_weapon_spawner/turret_mount/spawn_weapon(weapon_type)
	new weapon_type(get_turf(src))
