/obj/item/pickaxe/energy_pickaxe
	name = "energy pickaxe"
	desc = "An charged pickaxe which uses energy to create a plasma surface, allowing it to cut through dense rock with ease."
	icon_state = "energy_pick_base"
	var/datum/energy_pick_upgrade/applied_upgrade
	var/ready = TRUE
	var/animation_played = FALSE
	var/efficiency = 1
	var/cooldown = 1.5 SECONDS
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
	var/required_for_upgrade = 5
	var/static/list/mineral_upgrades = list(
		/obj/item/stack/sheet/iron = new /datum/energy_pick_upgrade/power,
		/obj/item/stack/sheet/mineral/diamond = new /datum/energy_pick_upgrade/instant,
		/obj/item/stack/sheet/mineral/uranium,
		/obj/item/stack/sheet/mineral/plasma = new /datum/energy_pick_upgrade/charge,
		/obj/item/stack/sheet/mineral/gold = new /datum/energy_pick_upgrade/efficiency,
		/obj/item/stack/sheet/mineral/silver,
		/obj/item/stack/sheet/mineral/copper = new /datum/energy_pick_upgrade/speed,
		/obj/item/stack/sheet/mineral/titanium,
		/obj/item/stack/ore/bluespace_crystal = new /datum/energy_pick_upgrade/radius,
		/obj/item/stack/sheet/mineral/bananium,
		/obj/item/stack/sheet/telecrystal
	)

/obj/machinery/energy_pickaxe_modification/attackby(obj/item/C, mob/user)
	if (user.a_intent == INTENT_HARM)
		return ..()
	if (istype(C, /obj/item/stack))
		var/obj/item/stack/inserted_sheet = C
		for (var/obj/item/stack/inserted_mineral in contents)
			if (inserted_mineral.amount >= required_for_upgrade)
				balloon_alert(user, "Already contains [inserted_mineral.name]!")
				to_chat(user, "<span class='warning'>[src] already contains [inserted_mineral.name], use it or eject it first!<span>")
				return
			if (inserted_sheet.type != inserted_mineral.type)
				balloon_alert(user, "Already contains [inserted_mineral.name]!")
				to_chat(user, "<span class='warning'>[src] already contains [inserted_mineral.amount] [inserted_mineral.name], add more or eject it!<span>")
				return
			var/amount_used = min(inserted_sheet.amount, required_for_upgrade - inserted_mineral.amount)
			inserted_sheet.use(amount_used)
			inserted_mineral.add(amount_used)
			to_chat(user, "<span class='notice'>You insert [amount_used] [inserted_sheet] into [src].<span>")
			if (inserted_mineral.amount >= required_for_upgrade)
				balloon_alert(user, "Ready!")
			else
				balloon_alert(user, "Requires an additional [required_for_upgrade - inserted_mineral.amount]")
			return
		// Allow for inserting of the sheet
		if (!(inserted_sheet.type in mineral_upgrades))
			to_chat(user, "<span class='notice'>You cannot use [inserted_sheet] for upgrades.<span>")
			return
		if (inserted_sheet.amount <= 5)
			user.temporarilyRemoveItemFromInventory(inserted_sheet)
			inserted_sheet.forceMove(src)
		else
			inserted_sheet.use(5)
			new inserted_sheet.type(src, 5)
		return
	if (istype(C, /obj/item/pickaxe/energy_pickaxe))
		var/obj/item/pickaxe/energy_pickaxe/energy_pick = C
		// Check for other pickaxes
		if (locate(/obj/item/pickaxe/energy_pickaxe) in contents)
			balloon_alert(user, "Upgrade station full")
			return
		user.temporarilyRemoveItemFromInventory(energy_pick)
		energy_pick.forceMove(src)
		return
	..()

/obj/machinery/energy_pickaxe_modification/attack_hand(mob/living/user)
	// Activate the upgrader

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

/datum/energy_pick_upgrade/instant/apply(obj/item/pickaxe/energy_pickaxe/target)
	target.mineral_damage += 1000

/datum/energy_pick_upgrade/instant/remove(obj/item/pickaxe/energy_pickaxe/target)
	target.mineral_damage -= 1000

/datum/energy_pick_upgrade/radius/apply(obj/item/pickaxe/energy_pickaxe/target)
	target.mining_radius ++

/datum/energy_pick_upgrade/radius/remove(obj/item/pickaxe/energy_pickaxe/target)
	target.mining_radius --

/datum/energy_pick_upgrade/charge/apply(obj/item/pickaxe/energy_pickaxe/target)
	target.max_charge += 1500

/datum/energy_pick_upgrade/charge/remove(obj/item/pickaxe/energy_pickaxe/target)
	target.max_charge -= 1500
