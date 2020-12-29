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
				oldChip.Destroy(target)
				qdel(oldChip)
				imp_in = target
				on_implanted(target)
			else
				oldChip.Destroy(target)
				qdel(oldChip)
				imp_in = target
				target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3)
				on_implanted(target)
		else
			imp_in = target
			on_implanted(target)

		if(user)
			log_combat(user, target, "implanted", "\a [name]")

/obj/item/implant/skillchip/engineering
	name = "Engineering Skill Chip"
	desc = "A Skill Chip which stores the wire schematics for all doors on station."
	chipTag = "engineer"

/obj/item/implant/skillchip/engineering/on_implanted(mob/user)
	ADD_TRAIT(user, TRAIT_WIRESEEING, "implant")
	..()

/obj/item/implant/skillchip/engineering/removed(mob/living/source, silent, special)
	REMOVE_TRAIT(source, TRAIT_WIRESEEING, "implant")
	..()

/obj/item/implant/skillchip/chemistry
	name = "Chemistry Skill Chip"
	desc = "A Skill Chip which teaches the user how to read chem dispenser buttons."
	chipTag = "chemistry"

/obj/item/implant/skillchip/chemistry/on_implanted(mob/user)
	ADD_TRAIT(user, TRAIT_CHEMISTRY, "implant")
	..()

/obj/item/implant/skillchip/chemistry/removed(mob/living/source, silent, special)
	REMOVE_TRAIT(source, TRAIT_CHEMISTRY, "implant")
	..()

/obj/item/implant/skillchip/chemistry/bartending
	name = "Bartending Skill Chip"
	desc = "A Skill Chip which teaches the user how to read chem dispenser buttons and throw drinks without spilling them."
	chipTag = "barman"

/obj/item/implant/skillchip/chemistry/bartending/on_implanted(mob/user)
	ADD_TRAIT(user, TRAIT_BOOZE_SLIDER, "implant")
	..()

/obj/item/implant/skillchip/chemistry/bartending/removed(mob/living/source, silent, special)
	REMOVE_TRAIT(source, TRAIT_BOOZE_SLIDER, "implant")
	..()

/obj/item/implant/skillchip/surgeon
	name = "Surgical Skill Chip"
	desc = "A Skill Chip which teaches the user about surgical techniques which give a higher success chance."
	chipTag = "surgeon"

/obj/item/implant/skillchip/surgeon/on_implanted(mob/user)
	ADD_TRAIT(user, TRAIT_SURGICAL_EXPERT, "implant")
	..()

/obj/item/implant/skillchip/surgeon/removed(mob/living/source, silent, special)
	REMOVE_TRAIT(source, TRAIT_SURGICAL_EXPERT, "implant")
	..()

/obj/item/implant/skillchip/surgeon/chiefmedical
	name = "Chief Medical Officer Skill Chip"
	desc = "A Skill Chip which includes the ability to read chem dispenser buttons  and employ surgical techniques which give a higher success chance."
	chipTag = "chiefMed"

/obj/item/implant/skillchip/surgeon/chiefmedical/on_implanted(mob/user)
	ADD_TRAIT(user, TRAIT_CHEMISTRY, "implant")
	..()

/obj/item/implant/skillchip/surgeon/chiefmedical/removed(mob/living/source, silent, special)
	REMOVE_TRAIT(source, TRAIT_CHEMISTRY, "implant")
	..()

/obj/item/implant/skillchip/martial_arts
	name = "Martial Arts Skill Chip"
	desc = "If you are seeing this, something went wrong."
	chipTag = "martial"
	var/datum/martial_art/style

/obj/item/implant/skillchip/martial_arts/on_implanted(mob/user)
	style = new
	style.teach(user)
	..()

/obj/item/implant/skillchip/martial_arts/removed(mob/living/source, silent, special)
	style = new
	style.remove(source)
	..()

/obj/item/implant/skillchip/martial_arts/chef
	name = "Advanced Cooking Skill Chip"
	desc = "A Skill Chip which teaches you about Close Quarters Cooking."
	chipTag = "martialChef"
	style = /datum/martial_art/cqc/under_siege

/obj/item/implant/skillchip/martial_arts/security
	name = "Security CQC Skill Chip"
	desc = "A Skill Chip which teaches you Nanotrasen Approved Methods of unarmed takedowns taugh to most members of security staff."
	chipTag = "martialSec"
	style = /datum/martial_art/security_cqc
