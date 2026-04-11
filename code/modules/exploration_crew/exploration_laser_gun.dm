/obj/item/gun/energy/e_gun/mini/exploration
	name = "handheld multi-purpose energy gun"
	desc = "A pistol-sized energy gun with a built-in flashlight designed for exploration crews. It serves a dual purpose and has modes for anti-creature lasers and cutting lasers."
	pin = /obj/item/firing_pin/off_station
	ammo_type = list(/obj/item/ammo_casing/energy/laser/anti_creature, /obj/item/ammo_casing/energy/laser/cutting)

/obj/item/gun/energy/e_gun/mini/exploration/on_emag(mob/user)
	..()
	//Emag the pin too
	if(pin)
		pin.use_emag(user)
	to_chat(user, span_warning("You override the safety of the energy gun, it will now fire higher powered projectiles at a greater cost."))
	ammo_type = list(/obj/item/ammo_casing/energy/laser/exploration_kill, /obj/item/ammo_casing/energy/laser/exploration_destroy)
	update_ammo_types()

//Anti-creature - Extra damage against simplemobs

/obj/item/ammo_casing/energy/laser/anti_creature
	projectile_type = /obj/projectile/beam/laser/anti_creature
	select_name = "anti-creature"
	e_cost = 400 WATT

/obj/projectile/beam/laser/anti_creature
	damage = 15
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/beam/laser/anti_creature/prehit_pierce(atom/target)
	if(!iscarbon(target) && !issilicon(target))
		damage = 30
	return ..()

//Cutting projectile - Damage against objects

/obj/item/ammo_casing/energy/laser/cutting
	projectile_type = /obj/projectile/beam/laser/cutting
	select_name = "demolition"
	e_cost = 300 WATT

/obj/projectile/beam/laser/cutting
	damage = 5
	icon_state = "plasmacutter"
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser

/obj/projectile/beam/laser/cutting/on_hit(atom/target, blocked)
	damage = initial(damage)
	if(isobj(target) && !istype(target, /obj/structure/blob))
		damage = 70
	else if(istype(target, /turf/closed/mineral))
		var/turf/closed/mineral/T = target
		T.gets_drilled()
	. = ..()

//Emagged ammo types

/obj/item/ammo_casing/energy/laser/exploration_kill
	projectile_type = /obj/projectile/beam/laser/exploration_kill
	select_name = "KILL"
	e_cost = 800 WATT

/obj/projectile/beam/laser/exploration_kill
	damage = 30
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/projectile/beam/laser/exploration_kill/on_hit(atom/target, blocked)
	damage = initial(damage)
	if(!iscarbon(target) && !issilicon(target))
		damage = 50
	//If you somehow hit yourself you get fried.
	if(target == firer)
		to_chat(firer, span_userdanger("The laser accelerates violently towards your gun's magnetic field, tearing its way through your body!"))
		damage = 200
	. = ..()

//destroy

/obj/item/ammo_casing/energy/laser/exploration_destroy
	projectile_type = /obj/projectile/beam/laser/exploration_destroy
	select_name = "DESTROY"
	e_cost = 1200 WATT

/obj/projectile/beam/laser/exploration_destroy
	damage = 20
	icon_state = "heavylaser"
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser

/obj/projectile/beam/laser/exploration_destroy/on_hit(atom/target, blocked)
	damage = initial(damage)
	if(isobj(target) && !istype(target, /obj/structure/blob))
		damage = 150
	else if(istype(target, /turf/closed/mineral))
		var/turf/closed/mineral/T = target
		T.gets_drilled()
	else if(isturf(target))
		SSexplosions.medturf += target
	. = ..()

/obj/item/gun/energy/laser/repeater/explorer
	name = "Laser Repeater Model 2284-E"
	desc = "An exploration-fitted laser repeater rifle that uses a built-in bluespace dynamo to recharge its battery, crank it and fire!"
	pin = /obj/item/firing_pin/off_station
	ammo_type = list(/obj/item/ammo_casing/energy/laser/anti_creature)


/obj/item/gun/energy/e_gun/mini/exploration/cyborg
	name = "multi-purpose energy gun"
	desc = "An energy gun with three firing modes useful in a variety of situations."
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/cyborg, /obj/item/ammo_casing/energy/laser/cutting/cyborg, /obj/item/ammo_casing/energy/lasergun/cyborg)
	gun_charge = 10 KILOWATT
	fire_rate = 1		//One shots per second
	charge_delay = 9	//Fully charged in 90 seconds
	w_class = WEIGHT_CLASS_LARGE //Same weight as disabler, for the slightly higher slowdown while active
	can_charge = FALSE
	use_cyborg_cell = TRUE
	requires_wielding = FALSE
	pin = /obj/item/firing_pin
	/// Whether sentry mode has been voluntarily toggled on by the borg
	var/sentry_toggled = FALSE
	/// The action button for toggling sentry mode
	var/datum/action/sentry_toggle/sentry_action

/obj/item/gun/energy/e_gun/mini/exploration/cyborg/add_seclight_point()
	return

/obj/item/gun/energy/e_gun/mini/exploration/cyborg/Initialize(mapload)
	. = ..()
	sentry_action = new(src)

/obj/item/gun/energy/e_gun/mini/exploration/cyborg/Destroy()
	QDEL_NULL(sentry_action)
	return ..()

/// Grants the sentry toggle action to a cyborg
/obj/item/gun/energy/e_gun/mini/exploration/cyborg/proc/grant_sentry_action(mob/living/silicon/robot/Target)
	if(sentry_action && Target)
		sentry_action.Grant(Target)

/// Removes the sentry toggle action from a cyborg
/obj/item/gun/energy/e_gun/mini/exploration/cyborg/proc/remove_sentry_action(mob/living/silicon/robot/Target)
	if(sentry_action && Target)
		sentry_action.Remove(Target)

/obj/item/gun/energy/e_gun/mini/exploration/cyborg/process(delta_time)
	//The next process tick after the gun is fully charged, we return disengage sentry mode (unless voluntarily toggled)
	if(cell.percent() == 100 && !sentry_toggled)
		var/mob/living/silicon/robot/R
		if(iscyborg(loc))
			R = loc
		else if(iscyborg(loc.loc))
			R = loc.loc
		if(R?.has_status_effect(/datum/status_effect/cyborg_sentry))
			R.remove_status_effect(/datum/status_effect/cyborg_sentry)
			to_chat(R, span_notice("Your gun has fully recharged. Sentry mode automatically disengaged."))
			R.balloon_alert(R, "sentry mode auto-OFF")
	. = ..()

/obj/item/gun/energy/e_gun/mini/exploration/cyborg/on_chamber_fired()
	var/mob/living/silicon/robot/R
	if(iscyborg(loc)) //Gun can only be fired from the main bar.
		R = loc
		R.apply_status_effect(/datum/status_effect/cyborg_sentry)
	. = ..()

//Standard disabler round
/obj/item/ammo_casing/energy/disabler/cyborg
	e_cost = 500 WATT	//20 shot capacity

//Rechargeable taser electrode for cyborg use.
/obj/item/ammo_casing/energy/electrode/cyborg
	projectile_type = /obj/projectile/energy/electrode/cyborg
	e_cost = 3000 WATT	//3ish maybe shot capacity

//Does 5 damage to mobs and 70 to objects, with exception to blobs
/obj/item/ammo_casing/energy/laser/cutting/cyborg
	e_cost = 250 WATT	//40 shot capacity

// Much weaker but more reliable, as this is their primary way of attack, and they can recharge it.
/// Why yes, if they tase someone with this, others won't be able to tase the target with actually good tasers! So this could count as sabotage :)
/obj/projectile/energy/electrode/cyborg
	max_duration = 16 SECONDS
	tase_stamina = 20
	piercing = TRUE
	range = 6	// We give the potential victim a single tile of visibility, so you could still cheese a static borg.

// Sentry Mode Toggle Action
/datum/action/sentry_toggle
	name = "Toggle Sentry Mode"
	desc = "Toggle your armor plating on or off. Activating sentry mode grants significant armor at the cost of movement speed. Sentry mode is automatically forced on while your gun is recharging after firing."
	button_icon = 'icons/hud/screen_alert.dmi'
	button_icon_state = "sentry"
	/// Reference to the gun this action is associated with
	var/obj/item/gun/energy/e_gun/mini/exploration/cyborg/gun

/datum/action/sentry_toggle/New(obj/item/gun/energy/e_gun/mini/exploration/cyborg/parent_gun)
	..()
	gun = parent_gun

/datum/action/sentry_toggle/on_activate(mob/user, atom/target)
	if(!iscyborg(user))
		return
	var/mob/living/silicon/robot/our_borgie = user
	if(!gun)
		return

	gun.sentry_toggled = !gun.sentry_toggled
	if(gun.sentry_toggled)
		if(our_borgie.has_status_effect(/datum/status_effect/cyborg_sentry))
			to_chat(our_borgie, span_warning("Sentry mode will remain active once fully charged."))
			our_borgie.balloon_alert(our_borgie, "sentry mode will remain ON when recharged")
		else
			our_borgie.apply_status_effect(/datum/status_effect/cyborg_sentry)
			to_chat(our_borgie, span_notice("You engage your armor plating, granting you armor at the cost of movement speed."))
			our_borgie.balloon_alert(our_borgie, "sentry mode ON")
	else
		//Only remove sentry if the gun is fully charged (not forced by firing)
		if(gun.cell && gun.cell.percent() == 100)
			our_borgie.remove_status_effect(/datum/status_effect/cyborg_sentry)
			to_chat(our_borgie, span_notice("You disengage your armor plating, restoring your movement speed."))
			our_borgie.balloon_alert(our_borgie, "sentry mode OFF")
		else
			to_chat(our_borgie, span_warning("Your gun is still recharging! Sentry mode will automatically deactivate once fully charged."))
			our_borgie.balloon_alert(our_borgie, "sentry mode will turn OFF when recharged")
