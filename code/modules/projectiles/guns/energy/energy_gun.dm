/obj/item/gun/energy/e_gun
	name = "energy gun"
	desc = "A basic hybrid energy gun with two settings: disable and kill."
	icon_state = "energy"
	w_class = WEIGHT_CLASS_BULKY	//powergaming is kill
	inhand_icon_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	modifystate = 1
	ammo_x_offset = 3
	weapon_weight = WEAPON_MEDIUM
	dual_wield_spread = 60
	custom_price = 300

/obj/item/gun/energy/e_gun/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 15, \
		overlay_y = 10)

/obj/item/gun/energy/e_gun/mini
	name = "miniature energy gun"
	desc = "A small, pistol-sized energy gun with a built-in flashlight. It has two settings: disable and kill."
	icon_state = "mini"
	inhand_icon_state = "gun"
	w_class = WEIGHT_CLASS_SMALL
	gun_charge = 6000 WATT
	ammo_x_offset = 2
	charge_sections = 3
	weapon_weight = WEAPON_LIGHT
	single_shot_type_overlay = FALSE

/obj/item/gun/energy/e_gun/mini/add_seclight_point()
	// The mini energy gun's light comes attached but is unremovable.
	AddComponent(/datum/component/seclite_attachable, \
		starting_light = new /obj/item/flashlight/seclite(src), \
		is_light_removable = FALSE, \
		light_overlay_icon = 'icons/obj/guns/flashlights.dmi', \
		light_overlay = "mini-light", \
		overlay_x = 19, \
		overlay_y = 13)

/obj/item/gun/energy/e_gun/stun
	name = "tactical energy gun"
	desc = "Military issue energy gun, is able to fire stun rounds."
	icon_state = "energytac"
	ammo_x_offset = 2
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/spec, /obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/e_gun/old
	name = "prototype energy gun"
	desc = "NT-P:01 Prototype Energy Gun. Early stage development of a unique laser rifle that has multifaceted energy lens allowing the gun to alter the form of projectile it fires on command."
	icon_state = "protolaser"
	ammo_x_offset = 2
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/electrode/old)

/obj/item/gun/energy/e_gun/mini/practice_phaser
	name = "practice phaser"
	desc = "A modified version of the basic phaser gun, this one fires less concentrated energy bolts designed for target practice."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser/practice)
	icon_state = "decloner"

/obj/item/gun/energy/e_gun/hos
	name = "\improper X-01 MultiPhase Energy Gun"
	desc = "This is an expensive, modern recreation of an antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	gun_charge = 12000 WATT
	icon_state = "hoslaser"
	w_class = WEIGHT_CLASS_LARGE
	force = 10
	automatic = 1
	fire_rate = 3
	full_auto = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/hos, /obj/item/ammo_casing/energy/laser/hos, /obj/item/ammo_casing/energy/disabler/hos)
	ammo_x_offset = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/gun/energy/e_gun/hos/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/trackable)

/obj/item/gun/energy/e_gun/hos/contents_explosion(severity, target)
	if (!ammo_type || !cell)
		name = "\improper Broken X-01 MultiPhase Energy Gun"
		desc = "This is an expensive, modern recreation of an antique laser gun. This gun had several unique firemodes, but lacked the ability to recharge over time. Seems too be damaged to the point of not functioning, but still valuable."
		icon_state = "hoslaser_broken"
		update_icon()

/obj/item/gun/energy/e_gun/dragnet
	name = "\improper DRAGnet"
	desc = "The \"Dynamic Rapid-Apprehension of the Guilty\" net is a revolution in law enforcement technology."
	icon_state = "dragnet"
	inhand_icon_state = "dragnet"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/net, /obj/item/ammo_casing/energy/trap)
	ammo_x_offset = 1
	fire_rate = 1.5
	w_class = WEIGHT_CLASS_LARGE

/obj/item/gun/energy/e_gun/dragnet/add_seclight_point()
	return

/obj/item/gun/energy/e_gun/dragnet/snare
	name = "Energy Snare Launcher"
	desc = "Fires an energy snare that slows the target down."
	ammo_type = list(/obj/item/ammo_casing/energy/trap)

/obj/item/gun/energy/e_gun/turret
	name = "hybrid turret gun"
	desc = "A heavy hybrid energy cannon with two settings: Stun and kill."
	icon_state = "turretlaser"
	inhand_icon_state = "turretlaser"
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	gun_charge = 100 KILOWATT
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/turret, /obj/item/ammo_casing/energy/laser)
	weapon_weight = WEAPON_HEAVY
	trigger_guard = TRIGGER_GUARD_NONE
	ammo_x_offset = 2
	automatic = 1
	fire_rate = 5

/obj/item/gun/energy/e_gun/turret/add_seclight_point()
	return

/obj/item/gun/energy/e_gun/nuclear
	name = "advanced energy gun"
	desc = "An energy gun with an experimental miniaturized nuclear reactor that automatically charges the internal power cell."
	icon_state = "nucgun"
	inhand_icon_state = "nucgun"
	charge_delay = 10
	pin = null
	can_charge = FALSE
	ammo_x_offset = 1
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/disabler)
	selfcharge = 1
	var/reactor_overloaded
	var/fail_tick = 0
	var/fail_chance = 0

/obj/item/gun/energy/e_gun/nuclear/process(delta_time)
	if(fail_tick > 0)
		fail_tick -= delta_time * 0.5
	..()

/obj/item/gun/energy/e_gun/nuclear/after_live_shot_fired(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	failcheck()
	update_icon()
	..()

/obj/item/gun/energy/e_gun/nuclear/proc/failcheck()
	if(prob(fail_chance) && isliving(loc))
		var/mob/living/M = loc
		switch(fail_tick)
			if(0 to 200)
				fail_tick += (2*(fail_chance))
				M.adjustFireLoss(3)
				to_chat(M, span_userdanger("Your [name] feels warmer."))
			if(201 to INFINITY)
				SSobj.processing.Remove(src)
				M.adjustFireLoss(10)
				reactor_overloaded = TRUE
				to_chat(M, span_userdanger("Your [name]'s reactor overloads!"))

/obj/item/gun/energy/e_gun/nuclear/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	fail_chance = min(fail_chance + round(15/severity), 100)

/obj/item/gun/energy/e_gun/nuclear/update_overlays()
	. = ..()
	if(reactor_overloaded)
		. += "[icon_state]_fail_3"
		if (emissive_charge)
			. += emissive_appearance(icon, "[icon_state]_fail_3", layer, alpha = 80)
			ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
	else
		switch(fail_tick)
			if(0)
				. += "[icon_state]_fail_0"
				if (emissive_charge)
					. += emissive_appearance(icon, "[icon_state]_fail_0", layer, alpha = 80)
					ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
			if(1 to 150)
				. += "[icon_state]_fail_1"
				if (emissive_charge)
					. += emissive_appearance(icon, "[icon_state]_fail_1", layer, alpha = 80)
					ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
			if(151 to INFINITY)
				. += "[icon_state]_fail_2"
				if (emissive_charge)
					. += emissive_appearance(icon, "[icon_state]_fail_2", layer, alpha = 80)
					ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
