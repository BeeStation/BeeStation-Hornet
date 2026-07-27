/obj/effect/mob_spawn/human/fugitive_hunter
	name = "Fugitive Hunter pod"
	desc = "A small sleeper typically used to make long distance travel a bit more bearable."
	mob_name = "a fugitive hunter"
	spawner_job_path = /datum/job/fugitive_hunter
	roundstart = FALSE
	death = FALSE
	random = TRUE
	show_flavour = FALSE
	density = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	banType = ROLE_FUGITIVE_HUNTER
	is_antagonist = TRUE
	/// This is set by the shuttle template
	var/datum/fugitive_type/hunter/backstory
	var/static/leader_spawned = FALSE
	/// If this pod can use the leader spawn
	var/use_leader_spawn = FALSE

/obj/effect/mob_spawn/human/fugitive_hunter/leader
	name = "Fugitive Hunter Leader pod"
	mob_name = "a fugitive hunter leader"
	use_leader_spawn = TRUE

/obj/effect/mob_spawn/human/fugitive_hunter/special(mob/living/carbon/human/new_spawn)
	var/leader = FALSE
	if(backstory.has_leader && !leader_spawned && use_leader_spawn)
		leader_spawned = TRUE
		leader = TRUE
	var/datum/antagonist/fugitive_hunter/fughunter = new
	fughunter.backstory = backstory
	new_spawn.mind.add_antag_datum(fughunter)
	var/outfit = leader ? backstory.leader_outfit : backstory.outfit
	if(islist(outfit))
		var/static/index = 1 // incredibly jank, but no two fugitive teams should exist or I will explode reality
		outfit = outfit[((index - 1) % length(outfit)) + 1]
		index++
	new_spawn.equipOutfit(outfit)
	message_admins("[ADMIN_LOOKUPFLW(new_spawn)] has been made into a Fugitive Hunter by an event.")
	log_game("[key_name(new_spawn)] was spawned as a Fugitive Hunter by an event.")

/obj/effect/mob_spawn/human/fugitive_hunter/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()
