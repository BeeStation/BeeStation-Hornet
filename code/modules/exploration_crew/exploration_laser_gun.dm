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
	e_cost = 40

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
	select_name = "cutting laser"
	e_cost = 30

/obj/projectile/beam/laser/cutting
	damage = 5
	icon_state = "heavylaser"
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
	e_cost = 80

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
	e_cost = 120

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
	desc = "An energy gun that will only fire when off-station. It has two firing modes to swich between destroying living and non-living matter."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/anti_creature/cyborg, /obj/item/ammo_casing/energy/laser/cutting/cyborg)
	gun_charge = 600	//12 or 24 shots depending on firing mode
	fire_rate = 2 		//Two shots per second
	charge_delay = 5	//Fully charged in 30 seconds

	can_charge = FALSE
	use_cyborg_cell = TRUE
	requires_wielding = FALSE

/obj/item/gun/energy/e_gun/mini/exploration/cyborg/add_seclight_point()
	return

/obj/item/ammo_casing/energy/laser/anti_creature/cyborg
	e_cost = 50

/obj/item/ammo_casing/energy/laser/cutting/cyborg
	e_cost = 25
