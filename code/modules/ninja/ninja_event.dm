//Note to future generations: I didn't write this god-awful code I just ported it to the event system and tried to make it less moon-speaky.
//Don't judge me D; ~Carn //Maximum judging occuring - Remie.
// Tut tut Remie, let's keep our comments constructive. - coiax

/*

Contents:
- The Ninja "Random" Event
- Ninja creation code
*/

/datum/round_event_control/ninja
	name = "Space Ninja"
	typepath = /datum/round_event/ghost_role/ninja
	max_occurrences = 1
	earliest_start = 40 MINUTES
	min_players = 15
	dynamic_should_hijack = TRUE

/datum/round_event/ghost_role/ninja
	var/success_spawn = 0
	role_name = "space ninja"
	minimum_required = 1

	var/spawn_loc
	var/give_objectives = TRUE

/datum/round_event/ghost_role/ninja/kill()
	if(!success_spawn && control)
		control.occurrences--
	return ..()


/datum/round_event/ghost_role/ninja/spawn_role()
	//selecting a spawn_loc
	if(!spawn_loc)
		var/list/spawn_locs = list()
		for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
			if(isturf(L.loc))
				spawn_locs += L.loc
		if(!spawn_locs.len)
			return kill()
		spawn_loc = pick(spawn_locs)
	if(!spawn_loc)
		return MAP_ERROR

	//selecting a candidate player
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_one_choice(
		role = /datum/role_preference/midround_ghost/ninja,
		check_jobban = ROLE_NINJA,
		poll_time = 30 SECONDS,
		role_name_text = "space ninja",
		alert_pic = /obj/item/energy_katana,
	)
	if(!candidate)
		return NOT_ENOUGH_PLAYERS

	//Prepare ninja player mind
	var/datum/mind/new_mind = new /datum/mind(candidate.key)
	new_mind.assigned_role = ROLE_NINJA
	new_mind.special_role = ROLE_NINJA
	new_mind.active = TRUE

	//spawn the ninja and assign the candidate
	var/mob/living/carbon/human/Ninja = create_space_ninja(spawn_loc)
	new_mind.transfer_to(Ninja)
	var/datum/antagonist/ninja/ninjadatum = new
	new_mind.add_antag_datum(ninjadatum)

	if(Ninja.mind != new_mind)			//something has gone wrong!
		CRASH("Ninja created with incorrect mind")

	spawned_mobs += Ninja
	message_admins("[ADMIN_LOOKUPFLW(Ninja)] has been made into a ninja by an event")
	log_game("[key_name(Ninja)] was spawned as a ninja by an event.")

	return SUCCESSFUL_SPAWN


//=======//NINJA CREATION PROCS//=======//

/proc/create_space_ninja(spawn_loc)
	var/mob/living/carbon/human/new_ninja = new(spawn_loc)
	new_ninja.real_name = "[pick(GLOB.ninja_titles)] [pick(GLOB.ninja_names)]"
	new_ninja.name = "[pick(GLOB.ninja_titles)] [pick(GLOB.ninja_names)]"
	new_ninja.dna.update_dna_identity()
	return new_ninja
