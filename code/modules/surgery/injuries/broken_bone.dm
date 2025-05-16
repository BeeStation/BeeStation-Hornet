/datum/injury/broken_bone
	alert_type = /atom/movable/screen/alert/status_effect/broken_bone

/datum/injury/broken_bone/apply_to_part(obj/item/bodypart/part)
	part.bone_max_health -= initial(part.bone_max_health) * 0.5

/datum/injury/broken_bone/remove_from_part(obj/item/bodypart/part)
	part.bone_max_health += initial(part.bone_max_health) * 0.5

/atom/movable/screen/alert/status_effect/broken_bone
	name = "Broken Bone"
	desc = "One of your bones has been broken. The affected limb will be impaired and vulnerable to further damage if not treated with a splint or surgery."
	icon_state = "broken"
