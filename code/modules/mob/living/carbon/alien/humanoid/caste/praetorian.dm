/mob/living/carbon/alien/humanoid/royal/praetorian
	name = "alien praetorian"
	caste = "p"
	maxHealth = 250
	health = 250
	icon_state = "alienp"

/mob/living/carbon/alien/humanoid/royal/praetorian/Initialize(mapload)
	real_name = name

	var/static/list/innate_actions = list(
		/datum/action/cooldown/alien/evolve_to_queen,
		/datum/action/cooldown/spell/aoe/repulse/xeno,
	)

	grant_actions_by_list(innate_actions)

	return ..()

/mob/living/carbon/alien/humanoid/royal/praetorian/create_internal_organs()
	internal_organs += new /obj/item/organ/alien/plasmavessel/large
	internal_organs += new /obj/item/organ/alien/resinspinner
	internal_organs += new /obj/item/organ/alien/acid
	internal_organs += new /obj/item/organ/alien/neurotoxin
	return ..()

/datum/action/cooldown/alien/evolve_to_queen
	name = "Evolve"
	desc = "Produce an internal egg sac capable of spawning children. Only one queen can exist at a time."
	button_icon_state = "alien_evolve_praetorian"
	plasma_cost = 500

/datum/action/cooldown/alien/evolve_to_queen/is_available(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!isturf(owner.loc))
		return FALSE

	if(get_alien_type(/mob/living/carbon/alien/humanoid/royal/queen))
		return FALSE

	var/mob/living/carbon/alien/humanoid/royal/evolver = owner
	var/obj/item/organ/alien/hivenode/node = evolver.get_organ_by_type(/obj/item/organ/alien/hivenode)
	if(!node || node.recent_queen_death)
		return FALSE

	return TRUE

/datum/action/cooldown/alien/evolve_to_queen/Activate(atom/target)
	var/mob/living/carbon/alien/humanoid/royal/evolver = owner
	var/mob/living/carbon/alien/humanoid/royal/queen/new_queen = new(owner.loc)
	evolver.alien_evolve(new_queen)
	return TRUE
