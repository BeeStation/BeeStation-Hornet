/obj/structure/closet/crate/secure
	desc = "A secure crate."
	name = "secure crate"
	icon_state = "secure_crate"
	secure = TRUE
	locked = TRUE
	max_integrity = 500
	armor_type = /datum/armor/crate_secure
	var/tamperproof = 0
	icon_door = "crate"
	damage_deflection = 20

/datum/armor/crate_secure
	melee = 30
	bullet = 50
	laser = 50
	energy = 100
	fire = 80
	acid = 80

/obj/structure/closet/crate/secure/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	if(prob(tamperproof) && damage_amount >= DAMAGE_PRECISION)
		boom()
	else
		return ..()


/obj/structure/closet/crate/secure/proc/boom(mob/user)
	if(user)
		to_chat(user, span_danger("The crate's anti-tamper system activates!"))
		log_bomber(user, "has detonated a", src)
	for(var/obj/loot in src)
		SSexplosions.high_mov_atom += loot
	explosion(get_turf(src), 0, 1, 5, 5)
	qdel(src)

/obj/structure/closet/crate/secure/weapon
	desc = "A secure weapons crate."
	name = "weapons crate"
	icon_state = "weapon_crate"
	icon_door = "weapon_crate"

/obj/structure/closet/crate/secure/plasma
	desc = "A secure plasma crate."
	name = "plasma crate"
	icon_state = "plasma_crate"
	icon_door = "plasma_crate"

/obj/structure/closet/crate/secure/gear
	desc = "A secure gear crate."
	name = "gear crate"
	icon_state = "secgear_crate"
	icon_door = "secgear_crate"

/obj/structure/closet/crate/secure/gear/debug
	name = "debug crate"
	storage_capacity = 300 // unit test blames extreme amount

/obj/structure/closet/crate/secure/gear/debug/cyborg
	name = "debug mech equipment"

/obj/structure/closet/crate/secure/gear/debug/PopulateContents()
	. = ..()
	new /obj/item/robot_model/syndicate_medical(src)
	new /obj/item/robot_model/syndicate(src)
	new /obj/item/robot_model/guard(src)
	new /obj/item/robot_model/saboteur(src)
	new /obj/item/robot_model/deathsquad(src)

/obj/structure/closet/crate/secure/gear/debug/mech
	name = "debug mech equipment"

/obj/structure/closet/crate/secure/gear/debug/mech/PopulateContents()
	. = ..()
	for(var/item in subtypesof(/obj/item/mecha_parts/mecha_equipment))
		new item(src)
	for(var/i in 1 to 5)
		new /obj/item/stack/sheet/animalhide/goliath_hide()
	new /obj/item/mecha_parts/mecha_equipment/concealed_weapon_bay(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking/ai_control(src)

/obj/structure/closet/crate/secure/gear/debug/cyborg
	name = "debug mech equipment"

/obj/structure/closet/crate/secure/gear/debug/PopulateContents()
	. = ..()
	new /obj/item/robot_model/syndicate_medical(src)
	new /obj/item/robot_model/syndicate(src)
	new /obj/item/robot_model/guard(src)
	new /obj/item/robot_model/saboteur(src)
	new /obj/item/robot_model/deathsquad(src)

/obj/structure/closet/crate/secure/gear/debug/mech
	name = "debug mech equipment"

/obj/structure/closet/crate/secure/gear/debug/mech/PopulateContents()
	. = ..()
	for(var/item in subtypesof(/obj/item/mecha_parts/mecha_equipment))
		new item(src)
	for(var/i in 1 to 5)
		new /obj/item/stack/sheet/animalhide/goliath_hide()
	new /obj/item/mecha_parts/mecha_equipment/concealed_weapon_bay(src)
	new /obj/item/mecha_parts/mecha_tracking(src)
	new /obj/item/mecha_parts/mecha_tracking/ai_control(src)

/obj/structure/closet/crate/secure/hydroponics
	desc = "A crate with a lock on it, painted in the scheme of the station's botanists."
	name = "secure hydroponics crate"
	icon_state = "hydro_secure_crate"
	icon_door = "hydro_secure_crate"

/obj/structure/closet/crate/secure/freezer //for consistency with other "freezer" closets/crates
	desc = "An insulated crate with a lock on it, used to secure perishables."
	name = "secure kitchen crate"
	icon_state = "kitchen_secure_crate"

/obj/structure/closet/crate/secure/freezer/pizza
	name = "secure pizza crate"
	desc = "An insulated crate with a lock on it, used to secure pizza."
	req_access = list(28)
	tamperproof = 10

/obj/structure/closet/crate/secure/freezer/pizza/PopulateContents()
	. = ..()
	new /obj/effect/spawner/random/food_or_drink/pizzaparty(src)

/obj/structure/closet/crate/secure/engineering
	desc = "A crate with a lock on it, painted in the scheme of the station's engineers."
	name = "secure engineering crate"
	icon_state = "engi_secure_crate"
	icon_door = "engi_secure_crate"

/obj/structure/closet/crate/secure/science
	name = "secure science crate"
	desc = "A crate with a lock on it, painted in the scheme of the station's scientists."
	icon_state = "sci_secure_crate"
	icon_door = "sci_secure_crate"

/obj/structure/closet/crate/secure/owned
	name = "private crate"
	desc = "A crate cover designed to only open for who purchased its contents."
	icon_state = "private_crate"
	icon_door = "private_crate"

	//Account of the person buying the crate if private purchasing.
	var/datum/bank_account/buyer_account
	//Is the secure crate opened or closed?
	var/privacy_lock = TRUE
	//Is the crate being bought by a person, or a budget card?
	var/department_purchase = FALSE

/obj/structure/closet/crate/secure/owned/examine(mob/user)
	. = ..()
	. += span_notice("It's locked with a privacy lock, and can only be unlocked by the buyer's ID with required access.")

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/closet/crate/secure/owned)

/obj/structure/closet/crate/secure/owned/Initialize(mapload, datum/bank_account/_buyer_account)
	. = ..()
	buyer_account = _buyer_account
	if(istype(buyer_account, /datum/bank_account/department))
		department_purchase = TRUE

/obj/structure/closet/crate/secure/owned/togglelock(mob/living/user, silent)
	if(!privacy_lock)
		..()
	else
		if(broken)
			if(!silent)
				to_chat(user, span_warning("[src] is broken!"))
			return FALSE
		var/obj/item/card/id/id_card = user.get_idcard(TRUE)
		if(!id_card)
			if(!silent)
				to_chat(user, span_notice("No ID detected!"))
			return FALSE
		if(!id_card.registered_account)
			if(!silent)
				to_chat(user, span_notice("No linked bank account detected!"))
			return FALSE
		if(!(id_card.registered_account == buyer_account))
			if(!silent)
				to_chat(user, span_notice("Bank account in ID card does not match with buyer!"))
			return FALSE
		if(department_purchase && !istype(id_card, /obj/item/card/id/departmental_budget))
			if(!silent)
				to_chat(user, span_notice("ID isn't a budget card!"))
			return FALSE
		if(!allowed(user))
			if(!silent)
				if(!department_purchase)
					to_chat(user, span_notice("Access Denied, insufficient access on ID card."))
				else
					to_chat(user, span_notice("Access Denied, insufficient access on ID card. Equip an ID card with the required access to open, and tap the budget card onto the crate."))
			return FALSE
		if(iscarbon(user))
			add_fingerprint(user)
		locked = !locked
		user.visible_message(span_notice("[user] unlocks [src]'s privacy lock."),
						span_notice("You unlock [src]'s privacy lock."))
		privacy_lock = FALSE
		update_icon()
