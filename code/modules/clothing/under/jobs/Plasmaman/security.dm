/obj/item/clothing/under/plasmaman/security
	name = "security plasma envirosuit"
	desc = "A plasmaman containment suit designed for security officers, offering a limited amount of extra protection."
	icon_state = "security_envirosuit"
	inhand_icon_state = "security_envirosuit"
	armor_type = /datum/armor/plasmaman_security
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	custom_price = 50


/datum/armor/plasmaman_security
	melee = 10
	bio = 100
	fire = 95
	acid = 95
	stamina = 10
	bleed = 10

/obj/item/clothing/under/plasmaman/security/warden
	name = "warden plasma envirosuit"
	desc = "A plasmaman containment suit designed for the warden, white stripes being added to differeciate them from other members of security."
	icon_state = "warden_envirosuit"
	inhand_icon_state = "warden_envirosuit"
//looking back at it now I probably coulda grouped the command suits together under one for less clutter.
/obj/item/clothing/under/plasmaman/security/hos
	name = "head of security plasma envirosuit"
	desc = "A black padded envirosuit designed for the head of security, its gold stripes and black pallete instills fear and respect."
	icon_state = "hos_envirosuit"
	inhand_icon_state = "hos_envirosuit"

/obj/item/clothing/under/plasmaman/security/secmed
	name = "security plasma envirosuit"
	desc = "A plasmaman containment suit designed for brig physicians. It has a red cross emblasoned on the chest."
	icon_state = "secmed_envirosuit"
	inhand_icon_state = "secmed_envirosuit"
	armor_type = /datum/armor/security_secmed


/datum/armor/security_secmed
	melee = 5
	bio = 100
	fire = 95
	acid = 95
	stamina = 10
	bleed = 10
