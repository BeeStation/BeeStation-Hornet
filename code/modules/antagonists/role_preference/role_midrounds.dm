/datum/role_preference/midround/traitor
	name = "Syndicate Sleeper Agent"
	description = "An unpaid debt. A score to be settled. Maybe you were just in the wrong \
		place at the wrong time. Whatever the reasons, you were selected to infiltrate Space Station 13. \n\
		Start with a set of sinister objectives and an uplink to purchase \
		items to get the job done."
	antag_datum = /datum/antagonist/traitor
	use_icon = /datum/role_preference/roundstart/traitor

/datum/role_preference/midround/heretic
	name = "Fanatic Revelation"
	description = "Find hidden influences and sacrifice crew members to gain magical \
		powers and ascend as one of several paths. \n\
		Forgotten, devoured, gutted. Humanity has forgotten the eldritch forces \
		of decay, but the mansus veil has weakened. We will make them taste fear \
		again..."
	antag_datum = /datum/antagonist/heretic
	use_icon = /datum/role_preference/roundstart/heretic

/datum/role_preference/midround/malfunctioning_ai
	name = "Value Drifted AI"
	description = "With a law zero to complete your objectives at all costs, combine your \
		omnipotence and malfunction modules to wreak havoc across the station. \
		Go delta to destroy the station and all those who opposed you."
	antag_datum = /datum/antagonist/malf_ai
	use_icon = /datum/role_preference/roundstart/malfunctioning_ai

/datum/role_preference/midround/vampire
	name = "Vampiric Accident"
	description = "After your death, you awaken to see yourself as an undead monster. \n\
		Scrape by Space Station 13, or take it over, vassalizing your way!"
	antag_datum = /datum/antagonist/vampire
	use_icon = /datum/role_preference/supplementary/vampire

/datum/role_preference/midround/obsessed
	name = "Obsessed"
	description = "You're obsessed with someone! Your obsession may begin to notice their \
		personal items are stolen and their coworkers have gone missing, \
		but will they realize they are your next victim in time?"
	antag_datum = /datum/antagonist/obsessed

/datum/role_preference/midround/obsessed/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/victim_dummy = new
	victim_dummy.hair_color = "#bb9966" // Brown
	victim_dummy.hair_style = "Messy"
	victim_dummy.update_hair()

	var/icon/obsessed_icon = render_preview_outfit(/datum/outfit/obsessed)
	//obsessed_icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)

	var/icon/final_icon = finish_preview_icon(obsessed_icon)

	final_icon.Blend(
		icon('icons/ui_icons/antags/obsessed.dmi', "obsession"),
		ICON_OVERLAY,
		ANTAGONIST_PREVIEW_ICON_SIZE - 30,
		20,
	)

	return final_icon

/datum/outfit/obsessed
	name = "Obsessed (Preview only)"
	uniform = /obj/item/clothing/under/misc/overalls
	gloves = /obj/item/clothing/gloves/color/latex
	mask = /obj/item/clothing/mask/surgical
	neck = /obj/item/camera
	suit = /obj/item/clothing/suit/apron

/datum/outfit/obsessed/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.get_equipped_items(INCLUDE_POCKETS))
		carried_item.add_mob_blood(H)//Oh yes, there will be blood...
	H.regenerate_icons()
