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

/obj/item/organ/body_egg/Insert(var/mob/living/carbon/M, special = FALSE, pref_load = FALSE)
	..()
	ADD_TRAIT(owner, TRAIT_XENO_HOST, TRAIT_GENERIC)
	ADD_TRAIT(owner, TRAIT_XENO_IMMUNE, "xeno immune")
	START_PROCESSING(SSobj, src)
	owner.med_hud_set_status()
	INVOKE_ASYNC(src, PROC_REF(AddInfectionImages), owner)

/obj/item/organ/body_egg/Remove(var/mob/living/carbon/M, special = FALSE, pref_load = FALSE)
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_XENO_HOST, TRAIT_GENERIC)
		REMOVE_TRAIT(owner, TRAIT_XENO_IMMUNE, "xeno immune")
		owner.med_hud_set_status()
		INVOKE_ASYNC(src, PROC_REF(RemoveInfectionImages), owner)
	..()

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
