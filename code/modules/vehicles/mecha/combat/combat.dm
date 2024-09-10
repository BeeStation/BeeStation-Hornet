/obj/vehicle/sealed/mecha/combat
	force = 30
	internals_req_access = list(ACCESS_MECH_SCIENCE, ACCESS_MECH_SECURITY)
	internal_damage_threshold = 50
	armor = list(MELEE = 30,  BULLET = 30, LASER = 15, ENERGY = 20, BOMB = 20, BIO = 0, RAD = 0, FIRE = 100, ACID = 100, STAMINA = 0, BLEED = 0)
	mouse_pointer = 'icons/mecha/mecha_mouse.dmi'
	destruction_knockdown_duration = 8 SECONDS
	exit_delay = 40

/obj/vehicle/sealed/mecha/combat/restore_equipment()
	mouse_pointer = 'icons/mecha/mecha_mouse.dmi'
	return ..()
