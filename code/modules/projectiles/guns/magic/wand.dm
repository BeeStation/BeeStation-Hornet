/obj/item/gun/magic/wand
	name = "wand of nothing"
	desc = "It's not just a stick, it's a MAGIC stick!"
	ammo_type = /obj/item/ammo_casing/magic
	icon_state = "nothingwand"
	item_state = "wand"
	w_class = WEIGHT_CLASS_SMALL
	weapon_weight = WEAPON_LIGHT
	max_charges = 5
	recharge_rate = 20 //seconds to recharge one charge

/obj/item/gun/magic/wand/examine(mob/user)
	. = ..()
	. += "Has [charges] charge\s remaining."

/obj/item/gun/magic/wand/update_icon()
	icon_state = "[initial(icon_state)][charges ? "" : "-drained"]"

/obj/item/gun/magic/wand/attack(atom/target, mob/living/user)
	if(target == user)
		return
	..()

/obj/item/gun/magic/wand/pull_trigger(atom/target, mob/living/user, params, aimed)
	if(!charges)
		shoot_with_empty_chamber(user)
		return
	if(can_charge)
		if(!IS_WIZARD(user))
			can_charge = FALSE //Wands only recharge in wizard hands
			charges = 1 //And you only get one shot before it goes inert
			to_chat(user, span_warning("The magic remaining within [src] fizzles away. Only a true wizard can utilize its power again."))

	if(no_den_usage)
		var/area/A = get_area(user)
		if(istype(A, /area/wizard_station))
			to_chat(user, span_warning("You know better than to violate the security of The Den, best wait until you leave to use [src]."))
			return

	if(target == user)
		zap_self(user) //Skips straight to process_fire() around the rest of the pull_trigger checks
		return
	else
		. = ..()
	update_icon()

/obj/item/gun/magic/wand/shoot_with_empty_chamber(mob/living/user)
	. = ..()
	if(IS_WIZARD(user) && !can_charge)
		can_charge = TRUE //wizards kickstart the charging
		to_chat(user, span_notice("The magic within [src] begins to stir again."))

/obj/item/gun/magic/wand/proc/zap_self(mob/living/user)
	user.visible_message(span_danger("[user] zaps [user.p_them()]self with [src]."))
	playsound(user, fire_sound, 50, 1)
	user.log_message("zapped [user.p_them()]self with a <b>[src]</b>", LOG_ATTACK)
	process_fire(user, user)

/////////////////////////////////////
//WAND OF DRAIN VITALITY
/////////////////////////////////////

//RUKO-TODO - Look at tasers and make something similar for this
/obj/item/gun/magic/wand/drain
	name = "wand of drain vitality"
	desc = "This dark wand saps the very life force from your target, slowing them and eventually transferring their life essence to you. Requires you to remain within range to be effective."
	fire_sound = 'sound/magic/wandodeath.ogg'
	ammo_type = /obj/item/ammo_casing/magic/lifedrain
	icon_state = "drainwand"

/////////////////////////////////////
//WAND OF HEALING
/////////////////////////////////////

/obj/item/gun/magic/wand/healing
	name = "wand of healing"
	desc = "This wand uses healing magics to heal some wounds. They are rarely utilized within the Wizard Federation for some reason."
	ammo_type = /obj/item/ammo_casing/magic/heal
	fire_sound = 'sound/magic/staff_healing.ogg'
	icon_state = "healwand"

/////////////////////////////////////
//WAND OF ICE
/////////////////////////////////////

/obj/item/gun/magic/wand/ice
	name = "wand of ice"
	desc = "This wand will chill your enemies to the bone, and the ground beneath their feet too!"
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "icewand"
	fire_sound = 'sound/magic/staff_change.ogg'

/obj/item/gun/magic/wand/polymorph/zap_self(mob/living/user)
	. = ..() //because the user mob ceases to exists by the time wabbajack fully resolves
	user.wabbajack()

/////////////////////////////////////
//WAND OF TELEPORTATION
/////////////////////////////////////

/obj/item/gun/magic/wand/teleport
	name = "wand of teleportation"
	desc = "This wand will warp targets to somewhere else nearby. Great for clean get-away or a firm \"Get away!\"."
	ammo_type = /obj/item/ammo_casing/magic/teleport
	fire_sound = 'sound/magic/wand_teleport.ogg'
	icon_state = "telewand"
	no_den_usage = TRUE

/obj/item/gun/magic/wand/teleport/zap_self(mob/living/user)
	if(do_teleport(user, user, 10, channel = TELEPORT_CHANNEL_MAGIC, teleport_mode = TELEPORT_ALLOW_WIZARD))
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(3, user.loc)
		smoke.start()
	..()

/////////////////////////////////////
//WAND OF ANIMATION
/////////////////////////////////////

/obj/item/gun/magic/wand/animation
	name = "wand of animation"
	desc = "This particular wand can spark life into inanimate objects, causing them to attack anyone nearby except the holder of this wand."
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "animationwand"
	fire_sound = 'sound/magic/staff_animation.ogg'

/////////////////////////////////////
//WAND OF FIRE BOLT
/////////////////////////////////////

/obj/item/gun/magic/wand/firebolt
	name = "wand of fire bolt"
	desc = "This wand shoots scorching balls of fire that ignite anyone they hit. Not as powerful as a proper fireball but still very dangerous."
	fire_sound = 'sound/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/firebolt
	icon_state = "firewand"
