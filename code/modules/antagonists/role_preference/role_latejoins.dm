/datum/role_preference/latejoin/brother
	name = "Syndicate Infiltrator"
	description = "An unpaid debt. A score to be settled. Maybe you were just in the wrong \
		place at the wrong time. Whatever the reasons, you were selected to infiltrate Space Station 13. \n\
		Start with a set of sinister objectives and an uplink to purchase \
		items to get the job done."
	antag_datum = /datum/antagonist/brother

/datum/role_preference/latejoin/brother/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/brother1 = new
	var/mob/living/carbon/human/dummy/consistent/brother2 = new

	brother1.hair_style = "Pigtails"
	brother1.hair_color = "532"
	brother1.update_hair()

	brother2.dna.features["moth_antennae"] = "Plain"
	brother2.dna.features["moth_markings"] = "None"
	brother2.dna.features["moth_wings"] = "Plain"
	brother2.set_species(/datum/species/moth)

	var/icon/brother1_icon = render_preview_outfit(/datum/outfit/job/quartermaster, brother1)
	brother1_icon.Blend(icon('icons/effects/blood.dmi', "maskblood"), ICON_OVERLAY)
	brother1_icon.Shift(WEST, 8)

	var/icon/brother2_icon = render_preview_outfit(/datum/outfit/job/scientist, brother2)
	brother2_icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)
	brother2_icon.Shift(EAST, 8)

	var/icon/final_icon = brother1_icon
	final_icon.Blend(brother2_icon, ICON_OVERLAY)

	qdel(brother1)
	qdel(brother2)

	return finish_preview_icon(final_icon)

/datum/role_preference/latejoin/vampire
	name = "Vampire Breakout"
	description = "After your death, you awaken to see yourself as an undead monster. \n\
		Scrape by Space Station 13, or take it over, vassalizing your way!"
	antag_datum = /datum/antagonist/vampire

/datum/role_preference/latejoin/vampire/get_preview_icon()
	var/icon/icon = render_preview_outfit(/datum/outfit/vampire)
	icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)

	return finish_preview_icon(icon)

/datum/outfit/vampire
	name = "Vampire outfit (Preview only)"
	suit = /obj/item/clothing/suit/costume/dracula
