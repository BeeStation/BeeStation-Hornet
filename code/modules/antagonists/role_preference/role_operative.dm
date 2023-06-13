#define OPERATIVE_DESC "Congratulations, agent. You have been chosen to join the Syndicate \
	Nuclear Operative strike team. Your mission, whether or not you choose \
	to accept it, is to destroy Nanotrasen's most advanced research facility! \
	That's right, you're going to Space Station 13. \
	Retrieve the nuclear authentication disk, use it to activate the nuclear \
	fission explosive, and destroy the station."

/datum/role_preference/antagonist/nuclear_operative
	name = "Nuclear Operative"
	description = OPERATIVE_DESC
	antag_datum = /datum/antagonist/nukeop

/datum/role_preference/antagonist/nuclear_operative/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(/datum/outfit/nuclear_operative)
	var/icon/teammate = render_preview_outfit(/datum/outfit/nuclear_operative)
	teammate.Blend(rgb(206, 206, 206, 197), ICON_MULTIPLY)

	final_icon.Blend(teammate, ICON_OVERLAY, -world.icon_size / 4, 0)
	final_icon.Blend(teammate, ICON_OVERLAY, world.icon_size / 4, 0)

	return finish_preview_icon(final_icon)

/datum/role_preference/midround_ghost/nuclear_operative
	name = "Nuclear Operative (Assailant)"
	description = OPERATIVE_DESC
	antag_datum = /datum/antagonist/nukeop
	use_icon = /datum/role_preference/antagonist/nuclear_operative



#undef OPERATIVE_DESC

/datum/outfit/nuclear_operative
	name = "Nuclear Operative (Preview only)"

	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	head = /obj/item/clothing/head/helmet/space/hardsuit/syndi
