//Will spawn the mobs
//Either will spawn an AI controlled mob if ship is not player controlled, or will spawn ghosts as the mob
/obj/effect/mob_spawn/human/exploration
	name = "exploration spawner"
	ghost_usable = FALSE
	instant = FALSE
	death = FALSE

	var/ghost_controlled = FALSE

/obj/effect/mob_spawn/human/exploration/pilot

/obj/effect/mob_spawn/human/exploration/weapons_officer

/obj/effect/mob_spawn/human/exploration/commander

/obj/effect/mob_spawn/human/exploration/captain

/obj/effect/mob_spawn/human/exploration/engineer

/obj/effect/mob_spawn/human/exploration/spec_ops

/obj/effect/mob_spawn/human/exploration/mech_ops

/obj/effect/mob_spawn/human/exploration/dropship_troop
