/obj/item/implant/skillchip
	name = "Skillchip"
	desc = "If you are seeing this, something fucked up"
	chipTag = ""//A string which can be compared to ensure figure out what skillchip type it is. This is used for a few logic things.
	activated = 0
	item_flags = COMPONENT_DELETE_OLD_IMPLANT

obj/item/implant/skillchil/proc/on_implanted(mob/user)
	. = ..()

obj/item/implant/skillchip/proc/implant(/mob/living/target, /mob/living/user, silent = FALSE, force = FALSE)
	if(SEND_SIGNAL(src, COMSIG_IMPLANT_IMPLANTING, args) & COMPONENT_STOP_IMPLANTING)
		return
	LAZYINITLIST(target.implants)
	if(!force && (!target.can_be_implanted() || !can_be_implanted_in(target)))
		return FALSE
	var/overRide = NULL
	var/obj/item/implant/imp_e
	for(var/X in target.implants)
		imp_e = X
		var/flags = SEND_SIGNAL(imp_e, COMSIG_IMPLANT_OTHER, args, src)
		if(flags & COMPONENT_DELETE_NEW_IMPLANT)
			UNSETEMPTY(target.implants)
			qdel(src)
			return TRUE
		if(flags & COMPONENT_DELETE_OLD_IMPLANT)
			if(istype(imp_e, type))
				/var/obj/item/implant/skillchip/oldChip = imp_e
				if(oldChip.chipTag == chipTag)
					overRide = FALSE
				else if (oldChip.chipTag == "Empty")
					break
				else
					overRide = TRUE
					break
			continue
		if(flags & COMPONENT_STOP_IMPLANTING)
			UNSETEMPTY(target.implants)
			return FALSE

		if(istype(imp_e, type))
			if(!allow_multiple)
				if(imp_e.uses < initial(imp_e.uses)*2)
					if(uses == -1)
						imp_e.uses = -1
					else
						imp_e.uses = min(imp_e.uses + uses, initial(imp_e.uses)*2)
					qdel(src)
					return TRUE
				else
					return FALSE
	forceMove(target)
	if(overRide == TRUE)//Target has an active skillchip
		qdel(imp_e)
		imp_in = target
		target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3) //Switching Chips deals a bit of brain damage
	else if (overRide == FALSE)//Target has the inert skillchip
		qdel(imp_e)
		imp_in = target
	else //Target had no skillchip
		imp_in = target
	target.implants += src
	if(activated)
		for(var/X in actions)
			var/datum/action/A = X
			A.Grant(target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.sec_hud_set_implants()

	on_implanted(target)

	if(user)
		log_combat(user, target, "implanted", "\a [name]")

	return TRUE

obj/item/implant/skillchip/proc/removed(mob/living/source, silent, special)
	. = ..()

/obj/item/implant/skillchip/bartending
	name = "Bartending Skill Chip"
	desc = "A Skill Chip which teaches the user how to read chem dispenser buttons and throw drinks without spilling them."
	chipTag = "barman"

obj/item/implant/skillchip/bartending/proc/on_implanted(mob/user)
	ADD_TRAIT(user, TRAIT_BOOZE_SLIDER, "implant")
	ADD_TRAIT(User, TRAIT_CHEMISTRY, "implant")
	. = ..()

obj/item/implant/skillchip/bartending/proc/removed(mob/living/source, silent, special)
	REMOVE_TRAIT(source, TRAIT_CHEMISTRY, "implant")
	REMOVE_TRAIT(source, TRAIT_BOOZE_SLIDER, "implant")
	. = ..()


