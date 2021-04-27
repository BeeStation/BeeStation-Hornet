/datum/antagonist/wishgranter
	name = "Wishgranter Avatar"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	can_elimination_hijack = ELIMINATION_ENABLED

/datum/antagonist/wishgranter/proc/forge_objectives()
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
	var/mob/living/carbon/human/H = owner.current
	if(!istype(H))
		return
	H.dna.add_mutation(HULK)
	H.dna.add_mutation(XRAY)
	H.dna.add_mutation(SPACEMUT)
	H.dna.add_mutation(TK)
