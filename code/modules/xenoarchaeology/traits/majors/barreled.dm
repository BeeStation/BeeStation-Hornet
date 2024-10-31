/*
	Barreled
	The artifact shoots the target with a random projectile
*/
/datum/xenoartifact_trait/major/projectile
	material_desc = "barreled"
	label_name = "Barreled"
	label_desc = "Barreled: The artifact seems to contain projectile components. Triggering these components will produce a 'safe' projectile."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	extra_target_range = 2
	weight = 21
	///List of projectiles we *could* shoot
	var/list/possible_projectiles = list(/obj/projectile/beam/disabler, /obj/projectile/tentacle, /obj/projectile/beam/lasertag, /obj/projectile/energy/electrode)
	///The projectile type we *will* shoot
	var/obj/projectile/choosen_projectile

/datum/xenoartifact_trait/major/projectile/New(atom/_parent)
	. = ..()
	choosen_projectile = pick(possible_projectiles)

/datum/xenoartifact_trait/major/projectile/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/target in focus)
		var/turf/T = get_turf(target)
		if(get_turf(component_parent.parent) == T)
			T = get_edge_target_turf(component_parent.parent, pick(NORTH, EAST, SOUTH, WEST))
		var/obj/projectile/P = new choosen_projectile()
		P.preparePixelProjectile(T, component_parent.parent)
		P.fire()
		playsound(get_turf(component_parent.parent), 'sound/mecha/mech_shield_deflect.ogg', 50, TRUE)
	dump_targets()
	clear_focus()

/datum/xenoartifact_trait/major/projectile/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("produce a 'safe' projectile"))

/*
	Barreled Δ
	Barreled but scary
*/
/datum/xenoartifact_trait/major/projectile/unsafe
	material_desc = "barreled"
	label_name = "Barreled Δ"
	label_desc = "Barreled Δ: The artifact seems to contain projectile components. Triggering these components will produce an unsafe projectile."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	possible_projectiles = list(/obj/projectile/beam/laser, /obj/projectile/bullet/c38, /obj/projectile/energy/tesla)
	conductivity = 3

/datum/xenoartifact_trait/major/projectile/unsafe/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("produce an unsafe projectile"))
