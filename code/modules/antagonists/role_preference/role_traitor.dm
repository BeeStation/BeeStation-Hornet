#define TRAITOR_DESC "An unpaid debt. A score to be settled. Maybe you were just in the wrong \
	place at the wrong time. Whatever the reasons, you were selected to \
	infiltrate Space Station 13. Start with a set of sinister objectives and an uplink to purchase \
	items to get the job done."

/datum/role_preference/antagonist/traitor
	name = "Traitor"
	description = TRAITOR_DESC
	antag_datum = /datum/antagonist/traitor
	preview_outfit = /datum/outfit/traitor

/datum/role_preference/midround_living/traitor
	name = "Traitor (Sleeper Agent)"
	description = TRAITOR_DESC
	antag_datum = /datum/antagonist/traitor
	preview_outfit = /datum/outfit/traitor

#undef TRAITOR_DESC

/datum/outfit/traitor
	name = "Traitor (Preview only)"

	uniform = /obj/item/clothing/under/syndicate
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas
	l_hand = /obj/item/melee/transforming/energy/sword
	r_hand = /obj/item/gun/energy/kinetic_accelerator/crossbow

/datum/outfit/traitor/post_equip(mob/living/carbon/human/H, visualsOnly)
	var/obj/item/melee/transforming/energy/sword/sword = locate() in H.held_items
	sword.icon_state = "swordred"
	H.update_inv_hands()
	H.hair_style = "Messy"
	H.hair_color = "111"
	H.update_hair()
