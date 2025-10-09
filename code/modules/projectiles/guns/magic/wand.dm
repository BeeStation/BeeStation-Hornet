/obj/item/gun/magic/wand
	name = "wand of nothing"
	desc = "It's not just a stick, it's a MAGIC stick!"
	ammo_type = /obj/item/ammo_casing/magic
	icon_state = "nothingwand"
	item_state = "wand"
	w_class = WEIGHT_CLASS_SMALL
	weapon_weight = WEAPON_LIGHT
	max_charges = 100

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
//WAND OF DEATH
/////////////////////////////////////

/obj/item/gun/magic/wand/death
	name = "wand of death"
	desc = "This deadly wand overwhelms the victim's body with pure energy, attacking their very life essence directly."
	fire_sound = 'sound/magic/wandodeath.ogg'
	ammo_type = /obj/item/ammo_casing/magic/death
	icon_state = "deathwand"
	max_charges = 5 //45 clone damage and 75 stamina damage per shot. One hit will slow most mobs dramatically, two will stamcrit, three will true crit.


/////////////////////////////////////
//WAND OF HEALING
/////////////////////////////////////

/obj/item/gun/magic/wand/healing
	name = "wand of healing"
	desc = "This wand uses healing magics to heal some wounds. They are rarely utilized within the Wizard Federation for some reason."
	ammo_type = /obj/item/ammo_casing/magic/heal
	fire_sound = 'sound/magic/staff_healing.ogg'
	icon_state = "revivewand"
	max_charges = 5 // Heals 25 of every type of damage per charge and can revive dead targets. When fully charged this is always enough to fully heal the wizard using it, but the charges will take time to come back.

/obj/item/gun/magic/wand/healing/inert
	name = "weakened wand of healing"
	desc = "This wand uses healing magics to heal and revive. The years of the cold have weakened the magic inside the wand."
	max_charges = 1

/////////////////////////////////////
//WAND OF POLYMORPH
/////////////////////////////////////

/obj/item/gun/magic/wand/polymorph
	name = "wand of polymorph"
	desc = "This wand is attuned to chaos and will radically alter the victim's form."
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "polywand"
	fire_sound = 'sound/magic/staff_change.ogg'
	max_charges = 3 //Turn into one of a number of random mobs permanently. While it doesn't kill outright, this is often worse than a death sentence

/obj/item/gun/magic/wand/polymorph/zap_self(mob/living/user)
	. = ..() //because the user mob ceases to exists by the time wabbajack fully resolves
	user.wabbajack()

/////////////////////////////////////
//WAND OF TELEPORTATION
/////////////////////////////////////

/obj/item/gun/magic/wand/teleport
	name = "wand of teleportation"
	desc = "This wand will wrench targets through space and time to move them somewhere else."
	ammo_type = /obj/item/ammo_casing/magic/teleport
	fire_sound = 'sound/magic/wand_teleport.ogg'
	icon_state = "telewand"
	max_charges = 8 //Mostly harmless most of the time. This one gets more charges
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
	icon_state = "doorwand"
	fire_sound = 'sound/magic/staff_animation.ogg'
	max_charges = 5

/////////////////////////////////////
//WAND OF FIREBALL
/////////////////////////////////////

/obj/item/gun/magic/wand/fireball
	name = "wand of lesser fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames. Not as powerful as the dedicated spell, but still dangerous."
	fire_sound = 'sound/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/fireball
	icon_state = "firewand"
	max_charges = 3

/obj/item/gun/magic/wand/fireball/inert
	name = "weakened wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames. The years of the cold have weakened the magic inside the wand."
	max_charges = 1
