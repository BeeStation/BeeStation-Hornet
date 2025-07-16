/obj/item/organ/body_egg
	name = "body egg"
	desc = "All slimy and yuck."
	icon_state = "innards"
	visual = TRUE
	zone = BODY_ZONE_CHEST
	slot = "parasite_egg"

/obj/item/organ/body_egg/on_find(mob/living/finder)
	..()
	to_chat(finder, span_warning("You found an unknown alien organism in [owner]'s [zone]!"))

/obj/item/organ/body_egg/New(loc)
	if(iscarbon(loc))
		src.Insert(loc)
	return ..()

/obj/item/organ/body_egg/Insert(mob/living/carbon/egg_owner, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(!.)
		return
	ADD_TRAIT(egg_owner, TRAIT_XENO_HOST, ORGAN_TRAIT)
	ADD_TRAIT(egg_owner, TRAIT_XENO_IMMUNE, ORGAN_TRAIT)
	START_PROCESSING(SSobj, src)
	egg_owner.med_hud_set_status()
	INVOKE_ASYNC(src, PROC_REF(AddInfectionImages), egg_owner)

/obj/item/organ/body_egg/Remove(mob/living/carbon/egg_owner, special = FALSE, pref_load = FALSE)
	. = ..()
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_XENO_HOST, ORGAN_TRAIT)
		REMOVE_TRAIT(owner, TRAIT_XENO_IMMUNE, ORGAN_TRAIT)
		egg_owner.med_hud_set_status()
		INVOKE_ASYNC(src, PROC_REF(RemoveInfectionImages), egg_owner)

/obj/item/organ/body_egg/on_death(delta_time, times_fired)
	. = ..()
	if(!owner)
		return
	egg_process(delta_time, times_fired)

/obj/item/organ/body_egg/on_life(delta_time, times_fired)
	. = ..()
	egg_process(delta_time, times_fired)

/obj/item/organ/body_egg/proc/egg_process(delta_time, times_fired)
	return

/obj/item/organ/body_egg/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/obj/item/organ/body_egg/proc/AddInfectionImages()
	return

/obj/item/organ/body_egg/proc/RemoveInfectionImages()
	return
