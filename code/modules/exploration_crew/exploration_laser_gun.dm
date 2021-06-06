/obj/item/gun/energy/e_gun/mini/exploration
	name = "handheld multi-purpose energy gun"
	desc = "A pistol-sized energy gun with a built-in flashlight designed for exploration crews. It serves a duel purpose and has modes for anti-creature lasers and cutting lasers."
	pin = /obj/item/firing_pin/off_station
	ammo_type = list(/obj/item/ammo_casing/energy/laser/anti_creature, /obj/item/ammo_casing/energy/laser/cutting)

/obj/item/ammo_casing/energy/laser/anti_creature
	projectile_type = /obj/item/projectile/beam/laser/anti_creature
	select_name = "anti-creature"
	e_cost = 40

/obj/item/projectile/beam/laser/anti_creature
	damage = 15
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/anti_creature/on_hit(atom/target, blocked)
	damage = initial(damage)
	if(!iscarbon(target) && !issilicon(target))
		damage = 30
	. = ..()

/obj/item/ammo_casing/energy/laser/cutting
	projectile_type = /obj/item/projectile/beam/laser/cutting
	select_name = "cutting laser"
	e_cost = 60

/obj/item/projectile/beam/laser/cutting
	damage = 5
	icon_state = "heavylaser"
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser

/obj/item/projectile/beam/laser/cutting/on_hit(atom/target, blocked)
	damage = initial(damage)
	if(isobj(target))
		damage = 70
	. = ..()
