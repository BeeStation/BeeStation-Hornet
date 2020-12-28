/obj/item/implant/skillchip
	name = "Skillchip"
	desc = "If you are seeing this, something fucked up"
	var/chipTag = ""//A string which can be compared to ensure figure out what skillchip type it is. This is used for a few logic things.
	activated = 0
	allow_multiple = TRUE //This Allows for the Implant Override to work.

/obj/item/implant/skillchip/implant(mob/living/target, mob/living/user, silent = FALSE, force = FALSE)
	if(..())
		LAZYINITLIST(target.implants)
		var/obj/item/implant/skillchip/oldChip
		for(var/X in target.implants)
			var/obj/item/implant/imp_e = X
			if(istype(imp_e, /obj/item/implant/skillchip))
				oldChip = imp_e
				break

		if(oldChip.chipTag == chipTag)
			return FALSE
		else if(oldChip.chipTag != chipTag)
			if(oldChip.chipTag == "Empty")
				qdel(oldChip)
				imp_in = target
				on_implanted(target)
			else
				qdel(oldChip)
				imp_in = target
				target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3)
				on_implanted(target)
		else
			imp_in = target
			on_implanted(target)

		if(user)
			log_combat(user, target, "implanted", "\a [name]")

/obj/item/implant/skillchip/bartending
	name = "Bartending Skill Chip"
	desc = "A Skill Chip which teaches the user how to read chem dispenser buttons and throw drinks without spilling them."
	chipTag = "barman"

/obj/item/implant/skillchip/bartending/on_implanted(mob/user)
	ADD_TRAIT(imp_in, TRAIT_BOOZE_SLIDER, "implant")
	ADD_TRAIT(imp_in, TRAIT_CHEMISTRY, "implant")
	..()

/obj/item/implant/skillchip/bartending/removed(mob/living/source, silent, special)
	REMOVE_TRAIT(imp_in, TRAIT_CHEMISTRY, "implant")
	REMOVE_TRAIT(imp_in, TRAIT_BOOZE_SLIDER, "implant")
	..()


