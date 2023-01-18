/obj/structure/closet/secure_closet
	name = "secure locker"
	desc = "It's a card-locked storage unit."
	locked = TRUE
	icon_state = "secure"
	max_integrity = 250
	armor = list(MELEE = 30, BULLET = 50, "laser" = 50, ENERGY = 100, BOMB = 0, "bio" = 0, "rad" = 0, FIRE = 80, "acid" = 80, "stamina" = 0)
	secure = TRUE

/obj/structure/closet/secure_closet/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE && damage_amount < 20)
		return 0
	. = ..()
