/obj/item/pickaxe/energy_pickaxe
	name = "energy pickaxe"
	desc = "An charged pickaxe which uses energy to create a plasma surface, allowing it to cut through dense rock with ease."
	icon_state = "energy_pick_base"
	var/ready = TRUE
	var/animation_played = FALSE
	var/efficiency = 1
	var/cooldown = 2 SECONDS
	var/mining_radius = 1
	var/mineral_damage = 400
	var/max_charge = 1400
	var/charge = 1400
	var/consumed_power = 100

/obj/item/pickaxe/energy_pickaxe/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/item/pickaxe/energy_pickaxe/update_overlays()
	. = ..()
	if (charge >= consumed_power)
		. += "energy_pick_power"
	if (ready && charge >= consumed_power)
		if (animation_played)
			. += "energy_pick_on"
		else
			animation_played = TRUE
			. += "energy_pick_on_anim"
	else
		. += "energy_pick_off"

/obj/item/pickaxe/energy_pickaxe/use_tool(atom/target, mob/living/user, delay, amount, volume, datum/callback/extra_checks)
	if (istype(target, /turf/closed/mineral))
		try_power_attack(target, user)
		return TRUE
	. = ..()

/obj/item/pickaxe/energy_pickaxe/proc/try_power_attack(turf/closed/mineral/target, mob/user)
	SHOULD_NOT_SLEEP(TRUE)
	if (charge >= consumed_power && ready)
		charge -= consumed_power
		// Play sound
		playsound(src, 'sound/weapons/emitter2.ogg', 100)
		// Deal damage to the rock
		target.drop_multiplier = efficiency
		target.take_damage(mineral_damage)
		if (mining_radius > 1)
			for (var/turf/closed/mineral/mineral in RANGE_TURFS(mining_radius - 1, target))
				target.drop_multiplier = efficiency
				target.take_damage(mineral_damage)
		to_chat(user, "<span class='notice'>You hit the [target] with [src].</span>")
		do_attack_animation(user, used_item = src)
		user.changeNext_move(CLICK_CD_MELEE)
		SSblackbox.record_feedback("tally", "pick_used_mining", 1, type)
		start_cooldown()
		if (charge < consumed_power)
			user.balloon_alert(user, "Power depleted.", "#e3a172")
			playsound(src, 'sound/effects/stealthoff.ogg', 100)
		return TRUE
	return FALSE

/obj/item/pickaxe/energy_pickaxe/proc/start_cooldown()
	ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(end_cooldown)), cooldown)
	update_icon(UPDATE_OVERLAYS)

/obj/item/pickaxe/energy_pickaxe/proc/end_cooldown()
	ready = TRUE
	// Reset the sprite
	// Play a sound cue
	playsound(src, 'sound/weapons/kenetic_reload.ogg', 100, 1)
	animation_played = FALSE
	update_icon(UPDATE_OVERLAYS)

//===============================
// Upgrade Station
//===============================

/obj/machinery/energy_pickaxe_modification
	name = "energy pickaxe modification station"
	desc = "A station for applying modifications to energy pickaxes in order to make them more effective tools."

//===============================
// Upgrades
//===============================

/datum/energy_pick_upgrade/proc/apply(obj/item/pickaxe/energy_pickaxe/target)
	return

/datum/energy_pick_upgrade/proc/remove(obj/item/pickaxe/energy_pickaxe/target)
	return

/datum/energy_pick_upgrade/efficiency/apply(obj/item/pickaxe/energy_pickaxe/target)
	target.efficiency += 0.5

/datum/energy_pick_upgrade/efficiency/remove(obj/item/pickaxe/energy_pickaxe/target)
	target.efficiency -= 0.5

/datum/energy_pick_upgrade/speed/apply(obj/item/pickaxe/energy_pickaxe/target)
	target.cooldown /= 2

/datum/energy_pick_upgrade/speed/remove(obj/item/pickaxe/energy_pickaxe/target)
	target.cooldown *= 2

/datum/energy_pick_upgrade/power/apply(obj/item/pickaxe/energy_pickaxe/target)
	target.mineral_damage += 400

/datum/energy_pick_upgrade/power/remove(obj/item/pickaxe/energy_pickaxe/target)
	target.mineral_damage -= 400

/datum/energy_pick_upgrade/radius/apply(obj/item/pickaxe/energy_pickaxe/target)
	target.mining_radius ++

/datum/energy_pick_upgrade/radius/remove(obj/item/pickaxe/energy_pickaxe/target)
	target.mining_radius --

/datum/energy_pick_upgrade/charge/apply(obj/item/pickaxe/energy_pickaxe/target)
	target.max_charge += 1500

/datum/energy_pick_upgrade/charge/remove(obj/item/pickaxe/energy_pickaxe/target)
	target.max_charge -= 1500
