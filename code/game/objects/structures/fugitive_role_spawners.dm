/obj/effect/mob_spawn/human/fugitive_hunter
	name = "Fugitive Hunter pod"
	desc = "A small sleeper typically used to make long distance travel a bit more bearable."
	mob_name = "a fugitive hunter"
	assignedrole = "Fugitive Hunter"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	show_flavour = FALSE
	density = TRUE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	assignedrole = ROLE_FUGITIVE_HUNTER
	banType = ROLE_FUGITIVE_HUNTER
	/// This is set by the shuttle template
	var/datum/fugitive_type/hunter/backstory
	var/static/leader_spawned = FALSE

/obj/effect/mob_spawn/human/fugitive_hunter/special(mob/living/carbon/human/new_spawn)
	var/leader = FALSE
	if(backstory.has_leader && !leader_spawned)
		leader_spawned = TRUE
		leader = TRUE
	var/datum/antagonist/fugitive_hunter/fughunter = new
	fughunter.backstory = backstory
	new_spawn.mind.add_antag_datum(fughunter)
	new_spawn.mind.assigned_role = ROLE_FUGITIVE_HUNTER
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

/obj/effect/mob_spawn/human/fugitive/spacepol
	name = "police pod"
	short_desc = "You are a member of the Space Police!"
	desc = "A small sleeper typically used to put people to sleep for briefing on the mission."
	mob_name = "a spacepol officer"
	flavour_text = "Justice has arrived. I am a member of the Spacepol!"
	outfit = /datum/outfit/spacepol
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/human/fugitive/russian
	name = "russian pod"
	short_desc = "You are a fugitive!"
	flavour_text = "Ay blyat. I am a space-russian smuggler! We were mid-flight when our cargo was beamed off our ship!"
	desc = "A small sleeper typically used to make long distance travel a bit more bearable."
	mob_name = "russian"
	outfit = /datum/outfit/russian_hunter
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/human/fugitive/bounty
	name = "bounty hunter pod"
	short_desc = "You are a bounty hunter!"
	flavour_text = "We got a new bounty on some fugitives, dead or alive."
	desc = "A small sleeper typically used to make long distance travel a bit more bearable."
	mob_name = "bounty hunter"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"

/obj/effect/mob_spawn/human/fugitive/bounty/armor
	outfit = /datum/outfit/bounty/armor

/obj/effect/mob_spawn/human/fugitive/bounty/hook
	outfit = /datum/outfit/bounty/hook

/obj/effect/mob_spawn/human/fugitive/bounty/synth
	outfit = /datum/outfit/bounty/synth
