/datum/role_preference/antagonist/changeling
	name = "Changeling"
	description = "A highly intelligent alien predator that is capable of altering their \
	shape to flawlessly resemble a human. Transform yourself or others into different identities, and buy from an \
	arsenal of biological weaponry with the DNA you collect."
	antag_datum = /datum/antagonist/changeling

/datum/role_preference/antagonist/changeling/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(/datum/outfit/job/medical_doctor)
	var/icon/split_icon = render_preview_outfit(/datum/outfit/job/engineer)

	final_icon.Shift(WEST, world.icon_size / 2)
	final_icon.Shift(EAST, world.icon_size / 2)

	split_icon.Shift(EAST, world.icon_size / 2)
	split_icon.Shift(WEST, world.icon_size / 2)

	final_icon.Blend(split_icon, ICON_OVERLAY)

	return finish_preview_icon(final_icon)
