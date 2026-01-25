/obj/structure/reagent_dispensers
	name = "Dispenser"
	desc = "..."
	icon = 'icons/obj/objects.dmi'
	icon_state = "water"
	density = TRUE
	anchored = FALSE
	pressure_resistance = 2*ONE_ATMOSPHERE
	max_integrity = 300
	var/tank_volume = 1000 //In units, how much the dispenser can hold
	var/reagent_id = /datum/reagent/water //The ID of the reagent that the dispenser uses
	var/obj/item/assembly_holder/rig = null // An assembly attached to the tank - if this dispenser accepts_rig
	var/accepts_rig = FALSE // Whether this dispenser can be rigged with an assembly (and blown up with an igniter)
	var/mutable_appearance/assembliesoverlay //overlay of attached assemblies
	var/last_rigger = "" // The person who attached an assembly to this dispenser, for bomb logging purposes

/obj/structure/reagent_dispensers/IsSpecialAssembly() // This check is necessary for assemblies to automatically detect that we are compatible
	return accepts_rig

/obj/structure/reagent_dispensers/Destroy()
	QDEL_NULL(rig)
	return ..()

/**
 * rig_boom: Wrapper to log when a reagent_dispenser is set off by an assembly
 *
 */
/obj/structure/reagent_dispensers/proc/rig_boom()
	log_bomber(last_rigger, "rigged [src] exploded", src)
	boom()

/obj/structure/reagent_dispensers/Initialize(mapload)
	create_reagents(tank_volume, DRAINABLE | AMOUNT_VISIBLE)
	if(reagent_id)
		reagents.add_reagent(reagent_id, tank_volume)
	. = ..()

/obj/structure/reagent_dispensers/examine(mob/user)
	. = ..()
	if(accepts_rig && get_dist(user, src) <= 2)
		if(rig)
			. += span_warning("There is some kind of device <b>rigged</b> to the tank!")
		else
			. += span_notice("It looks like you could <b>rig</b> a device to the tank.")

	for(var/obj/item/assembly/timer/timer in rig?.assemblies)
		. += span_notice("There is a timer [timer.timing ? "counting down from [timer.time]" : "set for [timer.time] seconds"].")

/obj/structure/reagent_dispensers/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(. && atom_integrity > 0)
		if(tank_volume && (damage_flag == BULLET || damage_flag == LASER))
			boom()

/obj/structure/reagent_dispensers/attackby(obj/item/W, mob/user, params)
	if(W.is_refillable())
		return 0 //so we can refill them via their afterattack.
	if(istype(W, /obj/item/assembly_holder) && accepts_rig)
		if(rig)
			balloon_alert(user, "another device is in the way!")
			return ..()
		var/obj/item/assembly_holder/holder = W
		if(!(locate(/obj/item/assembly/igniter) in holder.assemblies))
			return ..()

		user.balloon_alert_to_viewers("attaching rig...")
		add_fingerprint(user)
		if(!do_after(user, 2 SECONDS, target = src) || !user.transferItemToLoc(holder, src))
			return
		rig = holder
		holder.master = src
		holder.on_attach(src)
		assembliesoverlay = holder
		assembliesoverlay.pixel_x += 6
		assembliesoverlay.pixel_y += 1
		add_overlay(assembliesoverlay)
		RegisterSignal(src, COMSIG_IGNITER_ACTIVATE, PROC_REF(rig_boom))
		log_bomber(user, "attached [holder.name] to ", src)
		last_rigger = user
		user.balloon_alert_to_viewers("attached rig")
		return
	return ..()

/obj/structure/reagent_dispensers/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == rig)
		rig = null

/obj/structure/reagent_dispensers/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !rig)
		return
	// mousetrap rigs only make sense if you can set them off, can't step on them
	// If you see a mousetrap-rigged fuel tank, just leave it alone
	rig.on_found()
	if(QDELETED(src))
		return
	user.balloon_alert_to_viewers("detaching rig...")
	if(!do_after(user, 2 SECONDS, target = src))
		return
	user.balloon_alert_to_viewers("detached rig")
	user.log_message("detached [rig] from [src].", LOG_GAME)
	if(!user.put_in_hands(rig))
		rig.forceMove(get_turf(user))
	rig = null
	last_rigger = null
	cut_overlays(assembliesoverlay)
	UnregisterSignal(src, COMSIG_IGNITER_ACTIVATE)

/obj/structure/reagent_dispensers/proc/boom()
	if(QDELETED(src))
		return // little bit of sanity sauce before we wreck ourselves somehow
	var/datum/reagent/fuel/volatiles = reagents.has_reagent(/datum/reagent/fuel)
	var/fuel_amt = 0
	if(istype(volatiles) && volatiles.volume >= 25)
		fuel_amt = volatiles.volume
		reagents.del_reagent(/datum/reagent/fuel) // not actually used for the explosion
	if(reagents.total_volume)
		if(!fuel_amt)
			visible_message(span_danger("\The [src] ruptures!"))
		// Leave it up to future terrorists to figure out the best way to mix reagents with fuel for a useful boom here
		chem_splash(loc, min(2 + (reagents.total_volume + fuel_amt) / 1000, 6), list(reagents), extra_heat=(fuel_amt / 50), adminlog=(fuel_amt<25))

	if(fuel_amt) // with that done, actually explode
		visible_message(span_danger("\The [src] explodes!"))
		// old code for reference:
		// standard fuel tank = 1000 units = heavy_impact_range = 1, light_impact_range = 5, flame_range = 5
		// big fuel tank = 5000 units = devastation_range = 1, heavy_impact_range = 2, light_impact_range = 7, flame_range = 12
		// It did not account for how much fuel was actually in the tank at all, just the size of the tank.
		// I encourage others to better scale these numbers in the future.
		// As it stands this is a minor nerf in exchange for an easy bombing technique working that has been broken for a while.
		switch(fuel_amt)
			if(25 to 150)
				explosion(src, light_impact_range = 1, flame_range = 2)
			if(150 to 300)
				explosion(src, light_impact_range = 2, flame_range = 3)
			if(300 to 750)
				explosion(src, heavy_impact_range = 1, light_impact_range = 3, flame_range = 5)
			if(750 to 1500)
				explosion(src, heavy_impact_range = 1, light_impact_range = 4, flame_range = 6)
			if(1500 to INFINITY)
				explosion(src, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 6, flame_range = 8)
	qdel(src)

/obj/structure/reagent_dispensers/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(rig)
		rig.on_move(old_loc, movement_dir)

/obj/structure/reagent_dispensers/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!disassembled)
			boom()
	else
		qdel(src)

/obj/structure/reagent_dispensers/watertank
	name = "water tank"
	desc = "A water tank."
	icon_state = "water"

/obj/structure/reagent_dispensers/watertank/high
	name = "high-capacity water tank"
	desc = "A highly pressurized water tank made to hold gargantuan amounts of water."
	icon_state = "water_high" //I was gonna clean my room...
	tank_volume = 100000

/obj/structure/reagent_dispensers/foamtank
	name = "firefighting foam tank"
	desc = "A tank full of firefighting foam."
	icon_state = "foam"
	reagent_id = /datum/reagent/firefighting_foam
	tank_volume = 500

/obj/structure/reagent_dispensers/fueltank
	name = "fuel tank"
	desc = "A tank full of industrial welding fuel. Do not consume."
	icon_state = "fuel"
	reagent_id = /datum/reagent/fuel
	accepts_rig = TRUE

/obj/structure/reagent_dispensers/fueltank/blob_act(obj/structure/blob/B)
	boom()

/obj/structure/reagent_dispensers/fueltank/ex_act()
	boom()

/obj/structure/reagent_dispensers/fueltank/fire_act(exposed_temperature, exposed_volume)
	boom()

/obj/structure/reagent_dispensers/fueltank/zap_act(power, zap_flags)
	. = ..()
	boom()

/obj/structure/reagent_dispensers/fueltank/bullet_act(obj/projectile/P)
	. = ..()
	if(!QDELETED(src)) //wasn't deleted by the projectile's effects.
		if(!P.nodamage && ((P.damage_type == BURN) || (P.damage_type == BRUTE)))
			log_bomber(P.firer, "detonated a", src, "via projectile")
			boom()

/obj/structure/reagent_dispensers/fueltank/attackby(obj/item/I, mob/living/user, params)
	if(I.tool_behaviour == TOOL_WELDER)
		if(!reagents.has_reagent(/datum/reagent/fuel))
			to_chat(user, span_warning("[src] is out of fuel!"))
			return
		var/obj/item/weldingtool/W = I
		if(istype(W) && !W.welding)
			if(W.reagents.has_reagent(/datum/reagent/fuel, W.max_fuel))
				to_chat(user, span_warning("Your [W.name] is already full!"))
				return
			reagents.trans_to(W, W.max_fuel, transfered_by = user)
			user.visible_message(span_notice("[user] refills [user.p_their()] [W.name]."), span_notice("You refill [W]."))
			playsound(src, 'sound/effects/refill.ogg', 50, 1)
			W.update_icon()
		else
			user.visible_message(span_warning("[user] catastrophically fails at refilling [user.p_their()] [I.name]!"), span_userdanger("That was stupid of you."))
			log_bomber(user, "detonated a", src, "via welding tool")

			if (user.client)
				user.client.give_award(/datum/award/achievement/misc/welderbomb, user)

			boom()
		return
	return ..()


/obj/structure/reagent_dispensers/peppertank
	name = "pepper spray refiller"
	desc = "Contains condensed capsaicin for use in law \"enforcement.\""
	icon_state = "pepper"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_WINDOW_LAYER
	reagent_id = /datum/reagent/consumable/condensedcapsaicin

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/reagent_dispensers/peppertank, 30)

/obj/structure/reagent_dispensers/peppertank/Initialize(mapload)
	. = ..()
	if(prob(1))
		desc = "IT'S PEPPER TIME, BITCH!"

/obj/structure/reagent_dispensers/water_cooler
	name = "liquid cooler"
	desc = "A machine that dispenses liquid to drink."
	icon = 'icons/obj/vending.dmi'
	icon_state = "water_cooler"
	anchored = TRUE
	tank_volume = 500
	var/paper_cups = 25 //Paper cups left from the cooler

/obj/structure/reagent_dispensers/water_cooler/examine(mob/user)
	. = ..()
	if (paper_cups > 1)
		. += "There are [paper_cups] paper cups left."
	else if (paper_cups == 1)
		. += "There is one paper cup left."
	else
		. += "There are no paper cups left."

/obj/structure/reagent_dispensers/water_cooler/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!paper_cups)
		to_chat(user, span_warning("There aren't any cups left!"))
		return
	user.visible_message(span_notice("[user] takes a cup from [src]."), span_notice("You take a paper cup from [src]."))
	var/obj/item/reagent_containers/cup/glass/sillycup/S = new(get_turf(src))
	user.put_in_hands(S)
	paper_cups--

/obj/structure/reagent_dispensers/beerkeg
	name = "beer keg"
	desc = "Beer is liquid bread, it's good for you..."
	icon_state = "beer"
	reagent_id = /datum/reagent/consumable/ethanol/beer

/obj/structure/reagent_dispensers/beerkeg/blob_act(obj/structure/blob/B)
	explosion(src.loc,0,3,5,7,10)
	if(!QDELETED(src))
		qdel(src)

/obj/structure/reagent_dispensers/nutriment/fat/oil
	name = "vat of cooking oil"
	desc = "A huge metal vat with a tap on the front. Filled with cooking oil for use in frying food."
	icon_state = "vat"
	anchored = TRUE
	reagent_id = /datum/reagent/consumable/nutriment/fat/oil

/obj/structure/reagent_dispensers/plumbed
	name = "stationairy water tank"
	anchored = TRUE
	icon_state = "water_stationairy"
	desc = "A stationairy, plumbed, water tank."

/obj/structure/reagent_dispensers/plumbed/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_supply)

/obj/structure/reagent_dispensers/plumbed/wrench_act(mob/living/user, obj/item/I)
	default_unfasten_wrench(user, I)
	return TRUE

/obj/structure/reagent_dispensers/plumbed/storage/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/structure/reagent_dispensers/plumbed/storage
	name = "stationairy storage tank"
	icon_state = "tank_stationairy"
	reagent_id = null //start empty

/obj/structure/reagent_dispensers/plumbed/storage/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)
	AddComponent(/datum/component/plumbing/tank)
