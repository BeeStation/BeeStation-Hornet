/obj/vehicle/sealed/car/clowncar
	name = "clown car"
	desc = "How someone could even fit in there is beyond me."
	icon_state = "clowncar"
	max_integrity = 150
	armor_type = /datum/armor/car_clowncar
	enter_delay = 20
	max_occupants = 50
	movedelay = 0.6
	car_traits = CAN_KIDNAP
	key_type = /obj/item/bikehorn
	///Cooldown time inbetween [/obj/vehicle/sealed/car/clowncar/proc/roll_the_dice()] usages
	var/dice_cooldown_time = 150
	///How many times kidnappers in the clown car said thanks
	var/thankscount = 0
	///Current status of the cannon, alternates between CLOWN_CANNON_INACTIVE, CLOWN_CANNON_BUSY and CLOWN_CANNON_READY
	var/cannonmode = CLOWN_CANNON_INACTIVE
	var/upgraded = FALSE

/obj/vehicle/sealed/car/clowncar/syndicate
	upgraded = TRUE

/datum/armor/car_clowncar
	melee = 70
	bullet = 40
	laser = 40
	bomb = 30
	fire = 80
	acid = 80

/obj/vehicle/sealed/car/clowncar/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/horn, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/thank, VEHICLE_CONTROL_KIDNAPPED)

/obj/vehicle/sealed/car/clowncar/syndicate/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/sealed/RollTheDice, VEHICLE_CONTROL_DRIVE)
	initialize_controller_action_type(/datum/action/vehicle/sealed/cannon, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/sealed/car/clowncar/relaymove(mob/living/user, direction)
	if(upgraded)
		if(!ishuman(user))
			return FALSE
		var/mob/living/carbon/human/rider = user
		if(rider.mind?.assigned_role != JOB_NAME_CLOWN) //Only clowns can drive the syndicate version of the clown car.
			return FALSE
	return ..()

/obj/vehicle/sealed/car/clowncar/auto_assign_occupant_flags(mob/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind?.assigned_role == JOB_NAME_CLOWN) //Ensures only clowns can drive the car. (Including more at once)
			add_control_flags(H, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_PERMISSION)
			RegisterSignal(H, COMSIG_MOB_CLICKON, PROC_REF(fire_cannon_at))
			return
	add_control_flags(M, VEHICLE_CONTROL_KIDNAPPED)

/obj/vehicle/sealed/car/clowncar/mob_forced_enter(mob/M, silent = FALSE)
	. = ..()
	playsound(src, pick('sound/vehicles/clowncar_load1.ogg', 'sound/vehicles/clowncar_load2.ogg'), 75)

/obj/vehicle/sealed/car/clowncar/after_add_occupant(mob/M, control_flags)
	. = ..()
	if(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED).len >= 30)
		for(var/mob/kidnapper as anything in return_drivers())
			kidnapper.client.give_award(/datum/award/achievement/misc/round_and_full, kidnapper)

/obj/vehicle/sealed/car/clowncar/attack_animal(mob/living/simple_animal/M)
	if((M.loc != src) || M.environment_smash & (ENVIRONMENT_SMASH_WALLS|ENVIRONMENT_SMASH_RWALLS))
		return ..()

/obj/vehicle/sealed/car/clowncar/mob_exit(mob/M, silent = FALSE, randomstep = FALSE)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_CLICKON)

/obj/vehicle/sealed/car/clowncar/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(prob(33))
		visible_message(span_danger("[src] spews out a ton of space lube!"))
		new /obj/effect/particle_effect/foam(loc) //YEET

/obj/vehicle/sealed/car/clowncar/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(!istype(I, /obj/item/food/grown/banana))
		return
	var/obj/item/food/grown/banana/banana = I
	atom_integrity += min(banana.seed.potency, max_integrity-atom_integrity)
	to_chat(user, span_danger("You use the [banana] to repair the [src]!"))
	qdel(banana)


/obj/vehicle/sealed/car/clowncar/remove_occupant(mob/M)
	. = ..()
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.uncuff()

/obj/vehicle/sealed/car/clowncar/Bump(atom/bumped)
	. = ..()
	if(isliving(bumped))
		if(ismegafauna(bumped))
			return
		try_pickup_target(bumped)

	else if(istype(bumped, /turf/closed))
		visible_message(span_warning("[src] rams into [bumped] and crashes!"))
		playsound(src, pick('sound/vehicles/clowncar_crash1.ogg', 'sound/vehicles/clowncar_crash2.ogg'), 75)
		playsound(src, 'sound/vehicles/clowncar_crashpins.ogg', 75)
		dump_mobs(TRUE)

/obj/vehicle/sealed/car/clowncar/RunOver(mob/living/carbon/human/H)
	try_pickup_target(H)

/obj/vehicle/sealed/car/clowncar/proc/try_pickup_target(mob/living/L)
	if(!isliving(L))
		return
	var/picking_up = (!L.combat_mode || upgraded) //Upgraded can always pick up, normal needs target to be outside of combat mode

	if(picking_up)
		playsound(src, pick('sound/vehicles/clowncar_ram1.ogg', 'sound/vehicles/clowncar_ram2.ogg', 'sound/vehicles/clowncar_ram3.ogg'), 75)
		restraintarget(L)
		L.visible_message(span_warning("[L] is stuffed into [src]!"))
		mob_forced_enter(L)

	else if(!L.IsKnockdown())
		L.visible_message(span_warning("[src] rams into [L] and runs them over!"))
		L.Knockdown(3 SECONDS)
		playsound(src, pick('sound/vehicles/clowncar_crash1.ogg', 'sound/vehicles/clowncar_crash2.ogg'), 75)

/obj/vehicle/sealed/car/clowncar/proc/restraintarget(mob/living/L)
	if(!iscarbon(L))
		return //can't restrain what doesn't have hands
	var/mob/living/carbon/C = L
	if(istype(C))
		// Dont try and apply more handcuffs if already handcuffed, obviously
		if(C.handcuffed)
			return
		if(C.canBeHandcuffed())
			C.set_handcuffed(new /obj/item/restraints/handcuffs/energy/used(C))
			C.update_handcuffed()
			to_chat(C, span_danger("Your hands are restrained by the sheer volume of occupants in the car!"))

/obj/item/restraints/handcuffs/energy/used/clown
	name = "tangle of limbs"
	desc = "You are restrained in a tangle of bodies!"

/obj/vehicle/sealed/car/clowncar/on_emag(mob/user)
	..()
	to_chat(user, span_danger("You scramble the clowncar safety lock and enable high-octane waddling!"))
	AddComponent(/datum/component/waddling)
	upgraded = TRUE

/obj/vehicle/sealed/car/clowncar/Destroy()
	playsound(src, 'sound/vehicles/clowncar_fart.ogg', 100)
	return ..()

/**
 * Plays a random funky effect
 * Only available while car is emagged
 * Possible effects:
 * * Spawn bananapeel
 * * Spawn random reagent foam
 * * Make the clown car look like a singulo temporarily
 * * Spawn Laughing chem gas
 * * Drop oil
 * * Fart and make everyone nearby laugh
 */
/obj/vehicle/sealed/car/clowncar/proc/roll_the_dice(mob/user)
	if(TIMER_COOLDOWN_CHECK(src, COOLDOWN_CLOWNCAR_RANDOMNESS))
		to_chat(user, span_notice("The button panel is currently recharging."))
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_CLOWNCAR_RANDOMNESS, dice_cooldown_time)
	switch(rand(1,6))
		if(1)
			visible_message(span_danger("[user] presses one of the colorful buttons on [src], and a special banana peel drops out of it."))
			new /obj/item/grown/bananapeel/specialpeel(loc)
		if(2)
			visible_message(span_danger("[user] presses one of the colorful buttons on [src], and unknown chemicals flood out of it."))
			var/datum/reagents/R = new/datum/reagents(300)
			R.my_atom = src
			R.add_reagent(get_random_reagent_id(CHEMICAL_RNG_GENERAL), 100)
			var/datum/effect_system/foam_spread/foam = new
			foam.set_up(200, loc, R)
			foam.start()
		if(3)
			visible_message(span_danger("[user] presses one of the colorful buttons on [src], and the clown car turns on its singularity disguise system."))
			icon = 'icons/obj/singularity.dmi'
			icon_state = "singularity_s1"
			addtimer(CALLBACK(src, PROC_REF(reset_icon)), 10 SECONDS)
		if(4)
			visible_message(span_danger("[user] presses one of the colorful buttons on [src], and the clown car spews out a cloud of laughing gas."))
			var/datum/reagents/R = new/datum/reagents(300)
			R.my_atom = src
			R.add_reagent(/datum/reagent/consumable/superlaughter, 50)
			var/datum/effect_system/smoke_spread/chem/smoke = new()
			smoke.set_up(R, 4)
			smoke.attach(src)
			smoke.start()
		if(5)
			visible_message(span_danger("[user] presses one of the colorful buttons on [src], and the clown car starts dropping an oil trail."))
			RegisterSignal(src, COMSIG_MOVABLE_MOVED, .proc/cover_in_oil)
			addtimer(CALLBACK(src, PROC_REF(stop_dropping_oil)), 3 SECONDS)
		if(6)
			visible_message(span_danger("[user] presses one of the colorful buttons on [src], and the clown car lets out a comedic toot."))
			playsound(src, 'sound/vehicles/clowncar_fart.ogg', 100)
			for(var/mob/living/L in oviewers(6, loc))
				L.emote("laughs")
			for(var/mob/living/L as anything in occupants)
				L.emote("laughs")

///resets the icon and iconstate of the clowncar after it was set to singulo states
/obj/vehicle/sealed/car/clowncar/proc/reset_icon()
	icon = initial(icon)
	icon_state = initial(icon_state)

///Deploys oil when the clowncar moves in oil deploy mode
/obj/vehicle/sealed/car/clowncar/proc/cover_in_oil()
	SIGNAL_HANDLER
	new /obj/effect/decal/cleanable/oil/slippery(loc)

///Stops dropping oil after the time has run up
/obj/vehicle/sealed/car/clowncar/proc/stop_dropping_oil()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

///Toggles the on and off state of the clown cannon that shoots random kidnapped people
/obj/vehicle/sealed/car/clowncar/proc/toggle_cannon(mob/user)
	if(cannonmode == CLOWN_CANNON_BUSY)
		to_chat(user, "<span class='notice'>Please wait for the vehicle to finish its current action first.</span>")
		return
	if(cannonmode) //canon active, deactivate
		flick("clowncar_fromfire", src)
		icon_state = "clowncar"
		addtimer(CALLBACK(src, PROC_REF(deactivate_cannon)), 20)
		playsound(src, 'sound/vehicles/clowncar_cannonmode2.ogg', 75)
		visible_message(span_danger("The [src] starts going back into mobile mode."))
	else
		canmove = FALSE
		flick("clowncar_tofire", src)
		icon_state = "clowncar_fire"
		visible_message(span_danger("The [src] opens up and reveals a large cannon."))
		addtimer(CALLBACK(src, PROC_REF(activate_cannon)), 20)
		playsound(src, 'sound/vehicles/clowncar_cannonmode1.ogg', 75)
	cannonmode = CLOWN_CANNON_BUSY

///Finalizes canon activation
/obj/vehicle/sealed/car/clowncar/proc/activate_cannon()
	mouse_pointer = 'icons/mecha/mecha_mouse.dmi'
	cannonmode = CLOWN_CANNON_READY
	for(var/mob/living/driver as anything in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		driver.update_mouse_pointer()

///Finalizes canon deactivation
/obj/vehicle/sealed/car/clowncar/proc/deactivate_cannon()
	canmove = TRUE
	mouse_pointer = null
	cannonmode = CLOWN_CANNON_INACTIVE
	for(var/mob/living/driver as anything in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE))
		driver.update_mouse_pointer()

///Fires the cannon where the user clicks
/obj/vehicle/sealed/car/clowncar/proc/fire_cannon_at(mob/user, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(cannonmode != CLOWN_CANNON_READY || !length(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED)))
		return
	//The driver can still examine things and interact with his inventory.
	if(modifiers[SHIFT_CLICK] || (ismovable(target) && !isturf(target.loc)))
		return
	var/mob/living/unlucky_sod = pick(return_controllers_with_flag(VEHICLE_CONTROL_KIDNAPPED))
	mob_exit(unlucky_sod, TRUE)
	flick("clowncar_recoil", src)
	playsound(src, pick(
		'sound/vehicles/carcannon1.ogg',
		'sound/vehicles/carcannon2.ogg',
		'sound/vehicles/carcannon3.ogg',
		),75)
	unlucky_sod.throw_at(target, 10, 2)
	log_combat(user, unlucky_sod, "fired", src, "towards [target]") //this doesn't catch if the mob hits something between the car and the target
	return COMSIG_MOB_CANCEL_CLICKON

///Increments the thanks counter every time someone thats been kidnapped thanks the driver
/obj/vehicle/sealed/car/clowncar/proc/increment_thanks_counter()
	thankscount++
	if(thankscount < 100)
		return
	for(var/mob/busdriver as anything in return_drivers())
		busdriver.client.give_award(/datum/award/achievement/misc/the_best_driver, busdriver)
