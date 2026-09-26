/datum/antagonist/santa
	name = "Santa"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	banning_key = UNBANNABLE_ANTAGONIST
	required_living_playtime = 2

/datum/antagonist/santa/on_gain()
	. = ..()
	give_equipment()
	if(give_objectives)
		forge_objectives()

	owner.add_traits(list(TRAIT_CANNOT_OPEN_PRESENTS, TRAIT_PRESENT_VISION), TRAIT_SANTA)

/datum/antagonist/santa/forge_objectives()
	var/datum/objective/santa_objective = new("Bring joy and presents to the station!")
	santa_objective.completed = TRUE //lets cut our santas some slack.
	add_objective(santa_objective)

/datum/antagonist/santa/greet()
	to_chat(owner, span_boldannounce("You are Santa! Your objective is to bring joy to the people on this station. You have a magical bag, which generates presents as long as you have it! You can examine the presents to take a peek inside, to make sure that you give the right gift to the right person."))

/datum/antagonist/santa/proc/give_equipment()
	var/mob/living/carbon/human/human_santa = owner.current
	if(istype(human_santa))
		human_santa.equipOutfit(/datum/outfit/santa)
		human_santa.dna.update_dna_identity()

	var/datum/action/spell/teleport/area_teleport/wizard/santa/teleport = new(owner)
	teleport.Grant(human_santa)
