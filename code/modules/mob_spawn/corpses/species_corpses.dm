/obj/effect/mob_spawn/human/skeleton
	name = "skeletal remains"
	mob_name = "skeleton"
	mob_species = /datum/species/skeleton
	mob_gender = NEUTER

/obj/effect/mob_spawn/human/skeleton/alive
	death = FALSE
	roundstart = FALSE
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"
	short_desc = "By unknown powers, your skeletal remains have been reanimated!"
	flavour_text = "Walk this mortal plane and terrorize all living adventurers who dare cross your path."
	assignedrole = "Skeleton"
	use_cooldown = TRUE
	banType = ROLE_SKELETAL_REMAINS

/obj/effect/mob_spawn/human/skeleton/alive/equip(mob/living/carbon/human/H)
	var/obj/item/implant/exile/implant = new/obj/item/implant/exile(H)
	implant.implant(H)
	H.set_species(/datum/species/skeleton)

/obj/effect/mob_spawn/human/abductor
	name = "abductor"
	mob_name = "alien"
	mob_species = /datum/species/abductor
	outfit = /datum/outfit/abductorcorpse

/datum/outfit/abductorcorpse
	name = "Abductor Corpse"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/combat
