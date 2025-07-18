/obj/item/organ/internal/body_egg
	name = "body egg"
	desc = "All slimy and yuck."
	icon_state = "innards"
	visual = TRUE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_PARASITE_EGG

/obj/item/organ/internal/body_egg/on_find(mob/living/finder)
	..()
	to_chat(finder, span_warning("You found an unknown alien organism in [owner]'s [zone]!"))

/obj/item/organ/internal/body_egg/New(loc)
	if(iscarbon(loc))
		src.Insert(loc)
	return ..()

/obj/item/organ/internal/body_egg/mob_insert(mob/living/carbon/egg_owner, special = FALSE, movement_flags = DELETE_IF_REPLACED)
	. = ..()

	egg_owner.add_traits(list(TRAIT_XENO_HOST, TRAIT_XENO_IMMUNE), ORGAN_TRAIT)
	START_PROCESSING(SSobj, src)
	egg_owner.med_hud_set_status()
	INVOKE_ASYNC(src, PROC_REF(AddInfectionImages), egg_owner)

/obj/item/organ/internal/body_egg/Remove(mob/living/carbon/egg_owner, special, movement_flags)
	. = ..()
	if(owner)
		egg_owner.remove_traits(list(TRAIT_XENO_HOST, TRAIT_XENO_IMMUNE), ORGAN_TRAIT)
		egg_owner.med_hud_set_status()
		INVOKE_ASYNC(src, PROC_REF(RemoveInfectionImages), egg_owner)

/obj/item/organ/internal/body_egg/on_death(delta_time, times_fired)
	. = ..()
	if(!owner)
		return
	egg_process(delta_time, times_fired)

/obj/item/organ/internal/body_egg/on_life(delta_time, times_fired)
	. = ..()
	egg_process(delta_time, times_fired)

/obj/item/organ/internal/body_egg/proc/egg_process(delta_time, times_fired)
	return

/obj/item/organ/internal/body_egg/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/obj/item/organ/internal/body_egg/proc/AddInfectionImages()
	return

/obj/item/organ/internal/body_egg/proc/RemoveInfectionImages()
	return
