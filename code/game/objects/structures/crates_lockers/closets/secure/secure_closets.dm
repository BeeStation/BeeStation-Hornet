/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's a card-locked storage unit."
	locked = TRUE
	icon_state = "secure"
	max_integrity = 250
	armor_type = /datum/armor/closet_secure_closet
	secure = TRUE


/datum/armor/closet_secure_closet
	melee = 30
	bullet = 50
	laser = 50
	energy = 100
	fire = 80
	acid = 80

/obj/structure/closet/secure_closet/run_atom_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE && damage_amount < 20)
		return 0
	. = ..()
