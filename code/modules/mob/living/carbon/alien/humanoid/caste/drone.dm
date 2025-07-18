/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 125
	health = 125
	icon_state = "aliend"

/mob/living/carbon/alien/humanoid/drone/Initialize(mapload)
	var/datum/action/alien/evolve_to_praetorian/evolution = new(src)
	evolution.Grant(src)
	return ..()

/mob/living/carbon/alien/humanoid/drone/create_internal_organs()
	organs += new /obj/item/organ/alien/plasmavessel/large
	organs += new /obj/item/organ/alien/resinspinner
	organs += new /obj/item/organ/alien/acid
	return ..()

/datum/action/alien/evolve_to_praetorian
	name = "Evolve to Praetorian"
	desc = "Praetorian"
	button_icon_state = "alien_evolve_drone"
	plasma_cost = 500

/datum/action/alien/evolve_to_praetorian/is_available()
	. = ..()
	if(!.)
		return FALSE

	if(!isturf(owner.loc))
		return FALSE

	if(get_alien_type(/mob/living/carbon/alien/humanoid/royal))
		return FALSE

	var/mob/living/carbon/alien/humanoid/royal/evolver = owner
	var/obj/item/organ/alien/hivenode/node = evolver.get_organ_by_type(/obj/item/organ/alien/hivenode)
	// Players are Murphy's Law. We may not expect
	// there to ever be a living xeno with no hivenode,
	// but they _WILL_ make it happen.
	if(!node || node.recent_queen_death)
		return FALSE

	return TRUE

/datum/action/alien/evolve_to_praetorian/on_activate(mob/user, atom/target)
	var/mob/living/carbon/alien/humanoid/evolver = owner
	var/mob/living/carbon/alien/humanoid/royal/praetorian/new_xeno = new(owner.loc)
	evolver.alien_evolve(new_xeno)
	return TRUE
