/datum/antagonist/wishgranter
	name = "Wishgranter Avatar"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	can_elimination_hijack = ELIMINATION_ENABLED
	banning_key = BAN_ROLE_ALL_ANTAGONISTS
	leave_behaviour = ANTAGONIST_LEAVE_DESPAWN

/datum/antagonist/wishgranter/forge_objectives()
	var/datum/objective/elimination/highlander/elimination_objective = new
	elimination_objective.owner = owner
	objectives += elimination_objective
	log_objective(owner, elimination_objective.explanation_text)

/datum/antagonist/wishgranter/on_gain()
	owner.special_role = "Avatar of the Wish Granter"
	forge_objectives()
	. = ..()
	give_powers()

/datum/antagonist/wishgranter/greet()
	to_chat(owner, "<B>Your inhibitions are swept away, the bonds of loyalty broken, you are free to murder as you please!</B>")
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Wishgranter's Avatar",
		"Your inhibitions are swept away, the bonds of loyalty broken, you are free to murder as you please!")

/datum/antagonist/wishgranter/proc/give_powers()
	var/mob/living/carbon/C = owner.current
	if(!C.has_dna())
		return
	C.dna.add_mutation(/datum/mutation/hulk)
	C.dna.add_mutation(/datum/mutation/thermal/x_ray)
	C.dna.add_mutation(/datum/mutation/space_adaptation)
	C.dna.add_mutation(/datum/mutation/telekinesis)
