/obj/projectile/energy/nuclear_particle
	name = "nuclear particle"
	icon_state = "nuclear_particle"
	pass_flags = PASSTABLE | PASSTRANSPARENT | PASSGRILLE | PASSMACHINE
	armor_flag = ENERGY
	damage_type = TOX
	damage = 10
	speed = 1
	hitsound = 'sound/weapons/emitter2.ogg'
	impact_type = /obj/effect/projectile/impact/xray

	/// List of possible colors
	var/static/list/particle_colors = list(
		"red" = COLOR_RED,
		"blue" = COLOR_BLUE,
		"green" = COLOR_VIBRANT_LIME,
		"yellow" = COLOR_YELLOW,
		"cyan" = COLOR_CYAN,
		"purple" = COLOR_MAGENTA
	)

/obj/projectile/energy/nuclear_particle/Initialize(mapload)
	. = ..()
	//Random color time!
	var/our_color = pick(particle_colors)
	add_atom_colour(particle_colors[our_color], FIXED_COLOUR_PRIORITY)
	set_light(4, 3, particle_colors[our_color]) //Range of 4, brightness of 3 - Same range as a flashlight

/obj/projectile/energy/nuclear_particle/scan_moved_turf()
	. = ..()
	//Do a gas check first
	var/turf/turf = get_turf(src)
	var/datum/gas_mixture/air = turf?.return_air()
	if(!air)
		return
	if(GET_MOLES(/datum/gas/tritium, air) < MOLES_GAS_VISIBLE)
		return
	for(var/obj/item/item in loc)
		if(!prob(33))
			continue
		//Proceed with artifact logic
		if(item.GetComponent(/datum/component/xenoartifact))
			continue
		//Check for any pearls attached to the item first
		var/list/trait_list
		for(var/obj/item/sticker/trait_pearl/pearl in item.contents)
			LAZYADD(trait_list, pearl.stored_trait)
			qdel(pearl)
		//Make the item an artifact
		item.AddComponent(/datum/component/xenoartifact, /datum/xenoartifact_material/pearl, trait_list, TRUE, FALSE)
		playsound(item, 'sound/magic/staff_change.ogg', 50, TRUE)
		qdel(src)
		break

/obj/projectile/energy/nuclear_particle/on_hit(atom/target, blocked, pierce_hit)
	if(ishuman(target))
		SSradiation.irradiate(target, intensity = rand(50, 100))
	return ..()

/atom/proc/fire_nuclear_particle(angle = rand(0,360)) //used by fusion to fire random nuclear particles. Fires one particle in a random direction.
	var/obj/projectile/energy/nuclear_particle/particle = new /obj/projectile/energy/nuclear_particle(src)
	particle.fire(angle)
