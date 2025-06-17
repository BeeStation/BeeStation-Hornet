/// Spawns the evil floor cluwne to terrorize people
/datum/smite/floorcluwne_trauma
	name = "Floor Cluwne (Traumatize, Non-Lethal)"
	var/floorcluwne_trauma_level_generated

/datum/smite/floorcluwne_trauma/effect(client/user, mob/living/target)
	. = ..()
	if(!floorcluwne_trauma_level_generated)
		floorcluwne_trauma_level_generated = TRUE
		message_admins("Generating z-level for Floorcluwne sacrifices...")
		INVOKE_ASYNC(src, PROC_REF(generate_floorcluwne_z_level))

	var/mob/living/carbon/human/H = target
	var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(get_turf(target))
	FC.force_target(H)
	FC.delete_after_target_killed = FALSE
	FC.terrorize = TRUE

/// Generate the z-level.
/datum/smite/floorcluwne_trauma/proc/generate_floorcluwne_z_level()
	var/datum/map_template/heretic_sacrifice_level/new_level = new() //re-using heretic level
	if(!new_level.load_new_z())
		message_admins("The floorcluwne_trauma z-level failed to load.")
		CRASH("Failed to initialize floorcluwne_trauma z-level!")
