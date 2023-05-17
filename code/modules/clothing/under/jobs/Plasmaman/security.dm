/obj/item/clothing/under/plasmaman/security
	name = "security plasma envirosuit"
	desc = "A plasmaman containment suit designed for security officers, offering a limited amount of extra protection."
	icon_state = "security_envirosuit"
	item_state = "security_envirosuit"
	armor = list(MELEE = 10,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 95, ACID = 95, STAMINA = 20)
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/plasmaman/security/warden
	name = "warden plasma envirosuit"
	desc = "A plasmaman containment suit designed for the warden, white stripes being added to differeciate them from other members of security."
	icon_state = "warden_envirosuit"
	item_state = "warden_envirosuit"
//looking back at it now I probably coulda grouped the command suits together under one for less clutter.
/obj/item/clothing/under/plasmaman/security/hos
	name = "head of security plasma envirosuit"
	desc = "A black padded envirosuit designed for the head of security, its gold stripes and black pallete instills fear and respect."
	icon_state = "hos_envirosuit"
	item_state = "hos_envirosuit"

/obj/item/clothing/under/plasmaman/security/secmed
	name = "security plasma envirosuit"
	desc = "A plasmaman containment suit designed for brig physicians. It has a red cross emblasoned on the chest."
	icon_state = "secmed_envirosuit"
	item_state = "secmed_envirosuit"
	armor = list(MELEE = 5,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 0, FIRE = 95, ACID = 95, STAMINA = 20)
