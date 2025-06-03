/datum/antagonist/scamp
	name = "Scamp"
	roundend_category = "Scamps"
	antagpanel_category = "Scamp"
	banning_key = ROLE_SCAMP
	required_living_playtime = 1
	antag_moodlet = /datum/mood_event/focused
	var/special_role = ROLE_SCAMP

/datum/antagonist/scamp/on_gain()
	forge_objectives()
	..()

/datum/antagonist/scamp/proc/forge_objectives()
	var/datum/objective/cause_trouble/trouble = new
	add_objective(trouble)

	var/datum/objective/survive/survive = new
	add_objective(survive)

/datum/antagonist/scamp/on_removal()
	if(!silent && owner.current)
		to_chat(owner.current,span_userdanger("You are no longer the [special_role]! "))
	owner.special_role = null
	..()

/datum/antagonist/scamp/proc/add_objective(datum/objective/O)
	objectives += O
	log_objective(owner, O.explanation_text)

/datum/antagonist/scamp/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/scamp/greet()
	var/list/msg = list()

	msg += span_alertsyndie("You're a Scamp!")
	msg += span_alertsyndie("You can't lose this round, go cause some interesting drama or conflict of your liking! \n\
	Avoid killing or large scale disturbance if possible.")

	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', vol = 100, vary = FALSE, channel = CHANNEL_ANTAG_GREETING, pressure_affected = FALSE, use_reverb = FALSE)

	to_chat(owner.current, examine_block(msg.Join("\n")))

/datum/antagonist/scamp/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/datum_owner = mob_override || owner.current
	add_antag_hud(ANTAG_HUD_TRAITOR, "traitor", datum_owner)

/datum/antagonist/scamp/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/datum_owner = mob_override || owner.current
	remove_antag_hud(ANTAG_HUD_TRAITOR, datum_owner)
