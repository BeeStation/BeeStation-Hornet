/obj/item/gun/grenadelauncher
	name = "grenade launcher"
	desc = "A terrible, terrible thing. It's really awful!"
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "riotgun"
	inhand_icon_state = "riotgun"
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 7
	force = 5
	var/list/grenades = new/list()
	var/max_grenades = 3
	custom_materials = list(/datum/material/iron=2000)
	fire_rate = 1.5
	weapon_weight = WEAPON_MEDIUM

/obj/item/gun/grenadelauncher/examine(mob/user)
	. = ..()
	. += "[grenades.len] / [max_grenades] grenades loaded."

/obj/item/gun/grenadelauncher/attackby(obj/item/I, mob/user, params)

	if((istype(I, /obj/item/grenade)))
		if(grenades.len < max_grenades)
			if(!user.transferItemToLoc(I, src))
				return
			grenades += I
			to_chat(user, span_notice("You put the grenade in the grenade launcher."))
			to_chat(user, span_notice("[grenades.len] / [max_grenades] Grenades."))
		else
			to_chat(usr, span_danger("The grenade launcher cannot hold more grenades."))

/obj/item/gun/grenadelauncher/can_shoot()
	return grenades.len && ..()

/obj/item/gun/grenadelauncher/fire_shot_at(mob/living/user, atom/target, message, params, zone_override, aimed)
	user.visible_message(span_danger("[user] fired a grenade!"), \
						span_danger("You fire the grenade launcher!"))
	var/obj/item/grenade/F = grenades[1] //Now with less copypasta!
	grenades -= F
	F.forceMove(user.loc)
	F.throw_at(target, 30, 2, user)
	message_admins("[ADMIN_LOOKUPFLW(user)] fired a grenade ([F.name]) from a grenade launcher ([src]) from [AREACOORD(user)] at [target] [AREACOORD(target)].")
	log_game("[key_name(user)] fired a grenade ([F.name]) with a grenade launcher ([src]) from [AREACOORD(user)] at [target] [AREACOORD(target)].")
	F.active = 1
	F.icon_state = initial(F.icon_state) + "_active"
	playsound(user.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	addtimer(CALLBACK(F, TYPE_PROC_REF(/obj/item/grenade, prime)), 15)

/obj/item/gun/grenadelauncher/security
	desc = "A terrible, terrible thing. It's really awful! It's been crudely painted blue."
