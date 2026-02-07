/datum/role_preference/supplementary/brother
	name = "Blood-Brother Prime"
	description = "The Syndicate runs on trust - earned, tested, and absolute. Every operative \
		is expected to place their life in the hands of another, and to safeguard the life entrusted \
		to them in return. Bring a brother into the fold, execute your mission with precision, and show \
		the Syndicate what you're truly made of."
	antag_datum = /datum/antagonist/brother
	var/prime = TRUE

/datum/role_preference/supplementary/brother/get_preview_icon()
	var/mob/living/carbon/human/dummy/consistent/brother1 = new
	var/mob/living/carbon/human/dummy/consistent/brother2 = new

	brother1.hair_style = "Pigtails"
	brother1.hair_color = "532"
	brother1.update_hair()

	brother2.hair_style = "Gelled Spikes"
	brother2.hair_color = "A55A3B"
	brother2.update_hair()

	var/icon/brother1_icon = render_preview_outfit(/datum/outfit/job/quartermaster, brother1)
	brother1_icon.Blend(icon('icons/effects/blood.dmi', "maskblood"), ICON_OVERLAY)

	var/icon/brother2_icon = render_preview_outfit(/datum/outfit/job/scientist, brother2)
	brother2_icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)
	if (prime)
		brother2_icon.GrayScale()
		brother2_icon.Scale(26, 26)
		brother2_icon.Shift(EAST, 8)
		brother1_icon.Shift(WEST, 4)
	else
		brother1_icon.GrayScale()
		brother1_icon.Scale(26, 26)
		brother1_icon.Shift(WEST, 5)

	var/icon/final_icon = prime ? brother2_icon : brother1_icon
	final_icon.Blend(prime ? brother1_icon : brother2_icon, ICON_OVERLAY)

	qdel(brother1)
	qdel(brother2)

	return finish_preview_icon(final_icon)

/datum/role_preference/supplementary/brother/convert
	name = "Blood-Brother Convert"
	description = "Tired of your ordinary life, you were given a choice. Fight your way \
		out by following your former colleague-now your brother-into the Syndicate, standing \
		beside him to prove you're worth the risk. Or walk away, condemned to a quiet life and \
		an even quieter death. The choice was obvious..."
	prime = FALSE

/datum/role_preference/supplementary/vampire
	name = "Vampire"
	description = "After your death, you awaken to see yourself as an undead monster. \n\
		Scrape by Space Station 13, or take it over, vassalizing your way!"
	antag_datum = /datum/antagonist/vampire

/datum/role_preference/supplementary/vampire/get_preview_icon()
	var/icon/icon = render_preview_outfit(/datum/outfit/vampire)
	icon.Blend(icon('icons/effects/blood.dmi', "uniformblood"), ICON_OVERLAY)
	return finish_preview_icon(icon)

/datum/outfit/vampire
	name = "Vampire outfit (Preview only)"
	suit = /obj/item/clothing/suit/costume/dracula
