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
	desc = "An energy gun with three firing modes useful in a variety of situations, it is not capable of causing substantial harm to crew on any setting."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/cyborg, /obj/item/ammo_casing/energy/laser/cutting/cyborg, /obj/item/ammo_casing/energy/laser/anti_creature/cyborg)
	gun_charge = 10 KILOWATT
	fire_rate = 1		//One shots per second
	charge_delay = 9	//Fully charged in 90 seconds
	w_class = WEIGHT_CLASS_LARGE //Same weight as disabler, for the slightly higher slowdown while active
	can_charge = FALSE
	use_cyborg_cell = TRUE
	requires_wielding = FALSE
	pin = /obj/item/firing_pin

/obj/item/gun/energy/e_gun/mini/exploration/cyborg/add_seclight_point()
	return

/obj/item/gun/energy/e_gun/mini/exploration/cyborg/process(delta_time)
	//The next process tick after the gun is fully charged, we return to normal movement speed
	if(cell.percent() == 100)
		var/mob/living/silicon/robot/R
		if(iscyborg(loc))
			R = loc
		else if(iscyborg(loc.loc))
			R = loc.loc
		R?.remove_status_effect(/datum/status_effect/cyborg_sentry)
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

//Does 5 damage to mobs and 70 to objects, with exception to blobs
/obj/item/ammo_casing/energy/laser/cutting/cyborg
	e_cost = 250 WATT	//40 shot capacity

//Does 5 damage to humans, 30 damage to all other mobs.
/obj/item/ammo_casing/energy/laser/anti_creature/cyborg
	projectile_type = /obj/projectile/beam/laser/anti_creature/cyborg
	e_cost = 500 WATT	//20 shot capacity

/obj/projectile/beam/laser/anti_creature/cyborg
	damage = 5  //15 is too much given this can be used on station
