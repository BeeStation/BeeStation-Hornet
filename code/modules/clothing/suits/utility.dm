/*
 * Contains:
 * Fire protection
 * Bomb protection
 * Radiation protection
 */

/*
 * Fire protection
 */


/obj/item/clothing/suit/utility
	icon = 'icons/obj/clothing/suits/utility.dmi'
	worn_icon = 'icons/mob/clothing/suits/utility.dmi'

/obj/item/clothing/suit/utility/fire
	name = "emergency firesuit"
	desc = "A suit that helps protect against fire and heat."
	icon_state = "fire"
	item_state = "ro_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.9
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(
		/obj/item/flashlight,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/tank/internals/plasmaman,
		/obj/item/extinguisher,
		/obj/item/crowbar,
		/obj/item/powertool/jaws_of_life
	)
	slowdown = 1
	armor_type = /datum/armor/utility_fire
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 60
	resistance_flags = FIRE_PROOF


/datum/armor/utility_fire
	melee = 15
	bullet = 5
	laser = 20
	energy = 10
	bomb = 20
	bio = 50
	rad = 20
	fire = 100
	acid = 50
	stamina = 10
	bleed = 25

/obj/item/clothing/suit/utility/fire/firefighter
	icon_state = "firesuit"
	item_state = "firefighter"

/obj/item/clothing/suit/utility/fire/heavy
	name = "heavy firesuit"
	desc = "An old, bulky thermal protection suit."
	icon_state = "thermal"
	item_state = "ro_suit"
	slowdown = 1.5

/obj/item/clothing/suit/utility/fire/atmos
	name = "firesuit"
	desc = "An expensive firesuit that protects against even the most deadly of station fires. Designed to protect even if the wearer is set aflame."
	icon_state = "atmos_firesuit"
	item_state = "firesuit_atmos"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	allowed = list(/obj/item/flashlight, /obj/item/extinguisher, /obj/item/crowbar, /obj/item/tank/internals, /obj/item/powertool/jaws_of_life)

/*
 * Bomb protection
 */
/obj/item/clothing/head/utility/bomb_hood
	name = "bomb hood"
	desc = "Use in case of bomb."
	icon_state = "bombsuit"
	clothing_flags = THICKMATERIAL | SNUG_FIT
	armor_type = /datum/armor/utility_bomb_hood
	flags_inv = HIDEFACE|HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	dynamic_hair_suffix = ""
	dynamic_fhair_suffix = ""
	cold_protection = HEAD
	min_cold_protection_temperature = HELMET_MIN_TEMP_PROTECT
	heat_protection = HEAD
	max_heat_protection_temperature = HELMET_MAX_TEMP_PROTECT
	strip_delay = 70
	equip_delay_other = 70
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	resistance_flags = NONE



/datum/armor/utility_bomb_hood
	melee = 20
	laser = 20
	energy = 10
	bomb = 100
	fire = 80
	acid = 50
	stamina = 10
	bleed = 25

/obj/item/clothing/suit/utility/bomb_suit
	name = "bomb suit"
	desc = "A suit designed for safety when handling explosives."
	icon_state = "bombsuit"
	item_state = "bombsuit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 2
	armor_type = /datum/armor/utility_bomb_suit
	flags_inv = HIDEJUMPSUIT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	strip_delay = 70
	equip_delay_other = 70
	resistance_flags = NONE


/datum/armor/utility_bomb_suit
	melee = 20
	laser = 20
	energy = 10
	bomb = 100
	bio = 50
	fire = 80
	acid = 50
	stamina = 10
	bleed = 25

/obj/item/clothing/head/utility/bomb_hood/security
	icon_state = "bombsuit_sec"
	item_state = "bombsuit_sec"

/obj/item/clothing/suit/utility/bomb_suit/security
	icon_state = "bombsuit_sec"
	item_state = "bombsuit_sec"
	allowed = list(/obj/item/gun/energy, /obj/item/melee/baton, /obj/item/restraints/handcuffs)


/obj/item/clothing/head/utility/bomb_hood/white
	icon_state = "bombsuit_white"
	item_state = "bombsuit_white"

/obj/item/clothing/suit/utility/bomb_suit/white
	icon_state = "bombsuit_white"
	item_state = "bombsuit_white"

/*
* Radiation protection
*/

/obj/item/clothing/head/utility/radiation
	name = "radiation hood"
	icon_state = "rad"
	desc = "A hood with radiation protective properties. The label reads, 'Made with lead. Please do not consume insulation.'"
	clothing_flags = THICKMATERIAL | SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEFACE|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	armor_type = /datum/armor/utility_radiation
	strip_delay = 60
	equip_delay_other = 60
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	rad_flags = RAD_PROTECT_CONTENTS


/datum/armor/utility_radiation
	bio = 60
	rad = 100
	fire = 30
	acid = 30
	stamina = 10
	bleed = 15

/obj/item/clothing/suit/utility/radiation
	name = "radiation suit"
	desc = "A suit that protects against radiation. The label reads, 'Made with lead. Please do not consume insulation.'"
	icon_state = "rad"
	item_state = "rad_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.9
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/geiger_counter)
	slowdown = 1.5
	armor_type = /datum/armor/utility_radiation
	strip_delay = 60
	equip_delay_other = 60
	flags_inv = HIDEJUMPSUIT
	rad_flags = RAD_PROTECT_CONTENTS


/datum/armor/utility_radiation
	bio = 60
	rad = 100
	fire = 30
	acid = 30
	stamina = 10
	bleed = 15

/obj/item/clothing/suit/utility/radiation/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/anti_artifact, INFINITY, FALSE, 100)
