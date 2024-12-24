/obj/structure/blob/shield
	name = "strong blob"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_shield"
	desc = "A solid wall of slightly twitching tendrils."
	var/damaged_desc = "A wall of twitching tendrils."
	max_integrity = 150
	brute_resist = 0.25
	explosion_block = 3
	point_return = 4
	atmosblock = TRUE
	armor_type = /datum/armor/blob_shield


/datum/armor/blob_shield
	fire = 90
	acid = 90

/obj/structure/blob/shield/scannerreport()
	if(atmosblock)
		return "Will prevent the spread of atmospheric changes."
	return "N/A"

/obj/structure/blob/shield/core
	point_return = 0

/obj/structure/blob/shield/update_name(updates)
	. = ..()
	name = "[(atom_integrity < (max_integrity * 0.5)) ? "weakened " : null][initial(name)]"

/obj/structure/blob/shield/update_desc(updates)
	. = ..()
	desc = (atom_integrity < (max_integrity * 0.5)) ? "[damaged_desc]" : initial(desc)

/obj/structure/blob/shield/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && atom_integrity > 0)
		atmosblock = atom_integrity < (max_integrity * 0.5)
		air_update_turf(TRUE)

/obj/structure/blob/shield/update_icon_state()
	icon_state = "[initial(icon_state)][(atom_integrity < (max_integrity * 0.5)) ? "_damaged" : null]"
	return ..()

/obj/structure/blob/shield/reflective
	name = "reflective blob"
	desc = "A solid wall of slightly twitching tendrils with a reflective glow."
	damaged_desc = "A wall of twitching tendrils with a reflective glow."
	icon_state = "blob_glow"
	flags_ricochet = RICOCHET_SHINY
	point_return = 8
	max_integrity = 100
	brute_resist = 0.5
	explosion_block = 2
