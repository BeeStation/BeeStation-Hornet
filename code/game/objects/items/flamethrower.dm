/obj/item/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	lefthand_file = 'icons/mob/inhands/weapons/flamethrower_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/flamethrower_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 3
	throwforce = 10
	var/acti_sound = 'sound/items/welderactivate.ogg'
	var/deac_sound = 'sound/items/welderdeactivate.ogg'
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/iron=500)
	resistance_flags = FIRE_PROOF
	light_system = MOVABLE_LIGHT
	light_on = FALSE
	var/status = FALSE
	var/lit = FALSE	//on or off
	light_color = LIGHT_COLOR_FIRE
	var/operating = FALSE//cooldown
	var/obj/item/weldingtool/weldtool = null
	var/obj/item/assembly/igniter/igniter = null
	var/obj/item/tank/internals/plasma/ptank = null
	var/obj/item/reagent_containers/glass/beaker = null
	var/warned_admins = FALSE //for the message_admins() when lit
	//variables for prebuilt flamethrowers
	var/create_full = FALSE
	var/create_with_tank = FALSE
	var/igniter_type = /obj/item/assembly/igniter
	trigger_guard = TRIGGER_GUARD_NORMAL

/obj/item/flamethrower/Destroy()
	if(weldtool)
		qdel(weldtool)
	if(igniter)
		qdel(igniter)
	if(ptank)
		qdel(ptank)
	if(beaker)
		qdel(beaker)
	return ..()

/obj/item/flamethrower/process()
	if(!lit || !igniter)
		STOP_PROCESSING(SSobj, src)
		return null
	var/turf/location = loc
	if(istype(location, /mob/))
		var/mob/M = location
		if(M.is_holding(src))
			location = M.loc
	if(isturf(location)) //start a fire if possible
		igniter.flamethrower_process(location)


/obj/item/flamethrower/update_icon()
	cut_overlays()
	if(igniter)
		add_overlay("+igniter[status]")
	if(ptank)
		add_overlay("+ptank")
	if(lit)
		add_overlay("+lit")
		item_state = "flamethrower_1"
		if(beaker)
			add_overlay("+beaker")
			item_state = "flamethrower_2"
	else
		if(beaker)
			add_overlay("+beaker")
		item_state = "flamethrower_0"
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_hands()
	return

/obj/item/flamethrower/afterattack(atom/target, mob/user, flag)
	. = ..()
	if(flag)
		return // too close
	if(ishuman(user))
		if(!can_trigger_gun(user))
			return
	if(user && user.get_active_held_item() == src) // Make sure our user is still holding us
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf)
			log_combat(user, target, "flamethrowered", src)
			flame_turf(turflist)

/obj/item/flamethrower/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH && !status)//Taking this apart
		var/turf/T = get_turf(src)
		if(weldtool)
			weldtool.forceMove(T)
			weldtool = null
		if(igniter)
			igniter.forceMove(T)
			igniter = null
		if(ptank)
			ptank.forceMove(T)
			ptank = null
		new /obj/item/stack/rods(T)
		qdel(src)
		return

	else if(W.tool_behaviour == TOOL_SCREWDRIVER && igniter && !lit)
		status = !status
		to_chat(user, "<span class='notice'>[igniter] is now [status ? "secured" : "unsecured"]!</span>")
		update_icon()
		return

	else if(isigniter(W))
		var/obj/item/assembly/igniter/I = W
		if(I.secured)
			return
		if(igniter)
			return
		if(!user.transferItemToLoc(W, src))
			return
		igniter = I
		update_icon()
		return

	else if(istype(W, /obj/item/reagent_containers/glass/))
		if(beaker)
			if(user.transferItemToLoc(W,src))
				beaker.forceMove(get_turf(src))
				beaker = W
				to_chat(user, "<span class='notice'>You swap [beaker] in [src]!</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return
		beaker = W
		to_chat(user, "<span class='notice'>You attach [beaker] to [src]!</span>")
		update_icon()
		return

	else if(istype(W, /obj/item/tank/internals/plasma))
		if(ptank)
			if(user.transferItemToLoc(W,src))
				ptank.forceMove(get_turf(src))
				ptank = W
				to_chat(user, "<span class='notice'>You swap [ptank] in [src]!</span>")
			return
		if(!user.transferItemToLoc(W, src))
			return
		ptank = W
		to_chat(user, "<span class='notice'>You attach [ptank] to [src]!</span>")
		update_icon()
		return

	else
		return ..()

/obj/item/flamethrower/return_analyzable_air()
	if(ptank)
		return ptank.return_analyzable_air()
	else
		return null

/obj/item/flamethrower/attack_self(mob/user)
	toggle_igniter(user)

/obj/item/flamethrower/AltClick(mob/user)
	if(beaker && isliving(user) && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		user.put_in_hands(beaker)
		beaker = null
		to_chat(user, "<span class='notice'>You remove [beaker] from [src]!</span>")
		update_icon()
	else if(ptank && isliving(user) && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		user.put_in_hands(ptank)
		ptank = null
		to_chat(user, "<span class='notice'>You remove [ptank] from [src]!</span>")
		update_icon()

/obj/item/flamethrower/examine(mob/user)
	. = ..()
	if(beaker)
		. += "<span class='notice'>\The [src] has \a [beaker] attached. Alt-click to remove it.</span>"
		if(ptank)
			. += "<span class='notice'>\The [src] has \a [ptank] attached.</span>"
	else if(ptank)
		. += "<span class='notice'>\The [src] has \a [ptank] attached. Alt-click to remove it.</span>"

/obj/item/flamethrower/proc/toggle_igniter(mob/user)
	if(!ptank)
		to_chat(user, "<span class='notice'>Attach a plasma tank first!</span>")
		return
	if(!status)
		to_chat(user, "<span class='notice'>Secure the igniter first!</span>")
		return
	to_chat(user, "<span class='notice'>You [lit ? "extinguish" : "ignite"] [src]!</span>")
	lit = !lit
	if(lit)
		set_light_power(1)
		set_light_range(1)
		playsound(loc, acti_sound, 50, TRUE)
		START_PROCESSING(SSobj, src)
		if(!warned_admins)
			message_admins("[ADMIN_LOOKUPFLW(user)] has lit a flamethrower.")
			warned_admins = TRUE
	else
		set_light_power(0)
		set_light_range(0)
		playsound(loc, deac_sound, 50, TRUE)
		STOP_PROCESSING(SSobj,src)
	set_light_on(lit)
	if(light_system == STATIC_LIGHT)
		update_light()
	update_icon()

/obj/item/flamethrower/CheckParts(list/parts_list)
	..()
	weldtool = locate(/obj/item/weldingtool) in contents
	igniter = locate(/obj/item/assembly/igniter) in contents
	weldtool.status = FALSE
	igniter.secured = FALSE
	status = TRUE
	update_icon()

//Called from turf.dm turf/dblclick
/obj/item/flamethrower/proc/flame_turf(turflist, release_amount = 0.05)
	if(operating)
		return
	operating = TRUE
	var/turf/previousturf = get_turf(src)
	var/turf/startturf = previousturf
	var/datum/reagents/preppedchems = new/datum/reagents
	if(ptank)
		if(ptank.air_contents.return_pressure() > startturf.return_air().return_pressure()) //pressure in the tank must be greater than the pressure outside
			playsound(src, 'sound/effects/spray.ogg', 50, 1, -6)
	if(beaker)
		if(beaker.reagents.total_volume > 0)
			beaker.reagents.trans_to(preppedchems, beaker.reagents.maximum_volume * release_amount)
			beaker.reagents.remove_all(beaker.reagents.maximum_volume * release_amount)
			playsound(src, 'sound/effects/refill.ogg', 50, 1, -6)
	for(var/turf/T in turflist)
		if(T == previousturf)
			continue	//so we don't burn the tile we be standin on
		var/list/turfs_sharing_with_prev = previousturf.GetAtmosAdjacentTurfs(alldir=1)
		if(!(T in turfs_sharing_with_prev))
			break
		if(ptank)
			if(ptank.air_contents.return_pressure() > startturf.return_air().return_pressure())
				project_gas(T, release_amount)
		if(beaker)
			if(beaker.reagents.total_volume > 0)
				project_reagents(T, beaker.reagents.maximum_volume * release_amount, preppedchems)
		sleep(1)
		previousturf = T
	operating = FALSE
	for(var/mob/M as() in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)

/obj/item/flamethrower/proc/project_gas(turf/target, release_amount = 0.05)
	//Transfer 5% of current tank air contents to turf
	var/datum/gas_mixture/air_transfer = ptank.air_contents.remove_ratio(release_amount)
	air_transfer.set_moles(GAS_PLASMA, air_transfer.get_moles(GAS_PLASMA) * 5)
	target.assume_air(air_transfer)
	if(lit) //if the igniter's on, we heat up that gas as well!
		target.hotspot_expose((ptank.air_contents.return_temperature()*2) + 380,500)


/obj/item/flamethrower/proc/project_reagents(turf/target, chem_amount, datum/reagents/chemstothrow)
	var/obj/effect/decal/chempuff/D = new /obj/effect/decal/chempuff(target)
	D.create_reagents(chem_amount)
	chemstothrow.copy_to(D, chem_amount)
	var/reagentcolor = mix_color_from_reagents(D.reagents.reagent_list)
	D.color = reagentcolor
	//Make a visual effect to be slightly more obvious
	var/obj/effect/particle_effect/water/W = new /obj/effect/particle_effect/water(get_turf(src))
	W.add_atom_colour(reagentcolor, WASHABLE_COLOUR_PRIORITY)
	while(get_turf(W) != target)
		if(!step_towards(W, target))
			break
	if(lit) //heat the reagents on the turf but before applying them
		D.reagents.expose_temperature(igniter.is_hot())
	for(var/atom/A in target)
		if(!A.invisibility)
			D.reagents.reaction(A, VAPOR)
	D.reagents.reaction(target, VAPOR)
	qdel(D)


/obj/item/flamethrower/Initialize(mapload)
	. = ..()
	if(create_full)
		if(!weldtool)
			weldtool = new /obj/item/weldingtool(src)
		weldtool.status = FALSE
		if(!igniter)
			igniter = new igniter_type(src)
		igniter.secured = FALSE
		status = TRUE
		if(create_with_tank)
			ptank = new /obj/item/tank/internals/plasma/full(src)
		update_icon()

/obj/item/flamethrower/full
	create_full = TRUE

/obj/item/flamethrower/full/tank
	create_with_tank = TRUE

/obj/item/flamethrower/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/obj/item/projectile/P = hitby
	if(damage && attack_type == PROJECTILE_ATTACK && P.damage_type != STAMINA && prob(15))
		owner.visible_message("<span class='danger'>\The [attack_text] hits the fuel tank on [owner]'s [name], rupturing it! What a shot!</span>")
		var/turf/target_turf = get_turf(owner)
		log_game("A projectile ([hitby]) detonated a flamethrower tank held by [key_name(owner)] at [COORD(target_turf)]")
		flame_turf(src,target_turf, 1)
		qdel(ptank)
		return 1 //It hit the flamethrower, not them


/obj/item/assembly/igniter/proc/flamethrower_process(turf/open/location)
	location.hotspot_expose(700,2)
