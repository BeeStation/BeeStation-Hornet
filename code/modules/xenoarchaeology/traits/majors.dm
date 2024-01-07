/datum/xenoartifact_trait/major
	priority = TRAIT_PRIORITY_MAJOR

/*
	Shock
	Electrocutes the mob target, or charges the cell target
*/
/datum/xenoartifact_trait/major/shock
	label_name = "Electrified"
	label_desc = "The artifact seems to contain electrifying components. Triggering these components will shock the target."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	conductivity = 10

/datum/xenoartifact_trait/major/shock/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		dump_targets()
		return
	var/list/focus = override ? list(override) : targets
	if(length(focus))
		playsound(get_turf(parent.parent), 'sound/machines/defib_zap.ogg', 50, TRUE)
	for(var/atom/target in focus)
		if(iscarbon(target))
			var/mob/living/carbon/victim = target
			victim.electrocute_act(parent.trait_strength*0.25, parent.parent, 1, 1) //Deal a max of 25
			unregister_target(target)
		else if(istype(target, /obj/item/stock_parts/cell))
			var/obj/item/stock_parts/cell/C = target
			C.give((parent.trait_strength/100)*C.maxcharge) //Yes, this is potentially potentially powerful, but it will be cool
	dump_targets() //Get rid of anything else, since we can't interact with it

/*
	Hollow
	Captures the target for an amount of time
*/
/datum/xenoartifact_trait/major/hollow
	examine_desc = "hollow"
	label_name = "Hollow"
	label_desc = "The artifact seems to contain hollow components. Triggering these components will capture the target."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	weight = -10
	///Maximum time we hold people for
	var/hold_time = 15 SECONDS

/datum/xenoartifact_trait/major/hollow/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		dump_targets()
		return
	var/list/focus = override ? list(override) : targets
	for(var/atom/target in focus)
		if(ismovable(target))
			var/atom/movable/M = target
			if(M.anchored)
				unregister_target(target)
				continue
			var/atom/movable/AM = parent.parent
			//handle being held
			if(!isturf(AM.loc) && locate(AM.loc) in focus)
				AM.forceMove(get_turf(AM.loc))
			M.forceMove(parent.parent)
			//Buckle targets to artifact
			AM.buckle_mob(M)
			//Add timer to undo this - becuase the hold time is longer than an actual artifact cooldown, we need to do this per-mob
			addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/xenoartifact_trait, un_trigger), M), hold_time*(parent.trait_strength/100))
		else
			unregister_target(target)

/datum/xenoartifact_trait/major/hollow/un_trigger(atom/override, handle_parent = FALSE)
	var/list/focus = override ? list(override) : targets
	if(!length(focus))
		return ..()
	var/atom/movable/AM = parent.parent
	AM.unbuckle_all_mobs()
	for(var/atom/target in focus)
		if(ismovable(target))
			var/atom/movable/M = target
			if(M.loc == AM)
				M.forceMove(get_turf(AM))
	return ..()

/*
	Temporal
	Creates a timestop object at the position of the artfiact
*/

/datum/xenoartifact_trait/major/timestop
	label_name = "Temporal"
	label_desc = "Temporal: The artifact seems to contain temporal components. Triggering these components will create a temporal rift."
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	flags = XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	register_targets = FALSE
	///Maximum time we stop time for
	var/max_time = 10 SECONDS

/datum/xenoartifact_trait/major/timestop/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(parent.parent)
	if(!T)
		return
	new /obj/effect/timestop(T, 2, ((parent.trait_strength/100)*max_time), parent.parent)

/*
	Barreled
	The artifact shoots the target with a random projectile
*/
/datum/xenoartifact_trait/major/projectile
	examine_desc = "barreled"
	label_name = "Barreled"
	label_desc = "Barreled: The artifact seems to contain projectile components. Triggering these components will produce a projectile."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	extra_target_range = 2
	///List of projectiles we *could* shoot
	var/list/possible_projectiles = list(/obj/projectile/beam/disabler, /obj/projectile/beam/laser, /obj/projectile/seedling, /obj/projectile/beam/xray, /obj/projectile/bullet)
	///The projectile type we *will* shoot
	var/obj/projectile/choosen_projectile

/datum/xenoartifact_trait/major/projectile/New(atom/_parent)
	. = ..()
	choosen_projectile = pick(possible_projectiles)

/datum/xenoartifact_trait/major/projectile/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		dump_targets()
		return
	var/list/focus = override ? list(override) : targets
	for(var/atom/target in focus)
		var/turf/T = get_turf(target)
		if(get_turf(parent.parent) == T)
			T = get_edge_target_turf(parent.parent, pick(NORTH, EAST, SOUTH, WEST))
		var/obj/projectile/P = new choosen_projectile()
		P.preparePixelProjectile(T, parent.parent)
		P.fire()
		playsound(get_turf(parent.parent), 'sound/mecha/mech_shield_deflect.ogg', 50, TRUE)
	dump_targets()
	

/*
	Fuzzy
	The artifact shoots the target with a random projectile
*/
/datum/xenoartifact_trait/major/animalize ///All of this is stolen from corgium.
	label_name = "Bestialized"
	label_desc = "Bestialized: The artifact contains transforming components. Triggering these components transforms the target into an animal."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	///List of potential animals we could turn people into
	var/list/possible_animals = list(/mob/living/simple_animal/pet/dog/corgi)
	///The animal we will turn people into
	var/mob/choosen_animal
	///How long we keep them as animals
	var/animal_time = 15 SECONDS

/datum/xenoartifact_trait/major/animalize/New(atom/_parent)
	. = ..()
	choosen_animal = pick(possible_animals)

/datum/xenoartifact_trait/major/animalize/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		dump_targets()
		return
	var/list/focus = override ? list(override) : targets
	for(var/mob/living/target in focus)
		if(istype(target, choosen_animal) || IS_DEAD_OR_INCAP(target))
			continue
		transform(target)
		//Add timer to undo this
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/xenoartifact_trait, un_trigger), target), animal_time*(parent.trait_strength/100))

/datum/xenoartifact_trait/major/animalize/un_trigger(atom/override, handle_parent = FALSE)
	var/list/focus = override ? list(override) : targets
	if(!length(focus))
		return ..()
	//Restore every swap holder
	for(var/mob/living/target in focus)
		var/obj/shapeshift_holder/H = (locate(/obj/shapeshift_holder) in target) || istype(target.loc, /obj/shapeshift_holder) ? target.loc : null
		H?.restore(FALSE, FALSE)
		REMOVE_TRAIT(target, TRAIT_NOBREATH, TRAIT_GENERIC)
	return ..()

//Transform a valid target into our choosen animal
/datum/xenoartifact_trait/major/animalize/proc/transform(mob/living/target)
	if(!istype(target))
		return
	//Check for a mob swap holder, and deny the transform if we find one
	var/obj/shapeshift_holder/H = locate(/obj/shapeshift_holder) in target
	if(H)
		playsound(get_turf(target), 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return
	ADD_TRAIT(target, TRAIT_NOBREATH, TRAIT_GENERIC)
	//Setup the animal
	var/mob/new_animal = new choosen_animal(target.loc)
	//Swap holder
	H = new(new_animal, src, target)
	RegisterSignal(new_animal, COMSIG_MOB_DEATH, PROC_REF(un_trigger))
	return new_animal

/*
	EMP
	Creates an EMP effect at the position of the artfiact
*/

/datum/xenoartifact_trait/major/emp
	label_name = "EMP"
	label_desc = "EMP: The artifact seems to contain electromagnetic pulsing components. Triggering these components will create an EMP."
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	register_targets = FALSE
	rarity = XENOA_TRAIT_WEIGHT_RARE

/datum/xenoartifact_trait/major/emp/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	INVOKE_ASYNC(src, PROC_REF(do_emp)) //empluse() calls stoplag(), which calls sleep()

/datum/xenoartifact_trait/major/emp/proc/do_emp()
	var/turf/T = get_turf(parent.parent)
	if(!T)
		return
	playsound(T, 'sound/magic/disable_tech.ogg', 50, TRUE)
	empulse(T, max(1, parent.trait_strength*0.04), max(1, parent.trait_strength*0.08, 1))

/*
	Invisible
	TODO: Consider removing this - Racc
*/

//datum/xenoartifact_trait/major/invisible 

/*
	Displaced
	Teleports the target to a random nearby turf
*/
/datum/xenoartifact_trait/major/displaced
	label_name = "Displaced"
	label_desc = "The artifact seems to contain displacing components. Triggering these components will displace the target."
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	flags =  XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT

/datum/xenoartifact_trait/major/displaced/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		dump_targets()
		return
	var/list/focus = override ? list(override) : targets
	if(length(focus))
		playsound(get_turf(parent.parent), 'sound/machines/defib_zap.ogg', 50, TRUE)
	for(var/atom/movable/target in focus)
		if(!target.anchored)
			do_teleport(target, get_turf(target), (parent.trait_strength*0.3)+1, channel = TELEPORT_CHANNEL_BLUESPACE)
		unregister_target(target)
	dump_targets()

/*
	Illuminating
	Toggles a light on the artifact
*/

/datum/xenoartifact_trait/major/illuminating
	label_name = "Illuminating"
	label_desc = "Illuminating: The artifact seems to contain illuminating components. Triggering these components will cause the artifact to illuminate."
	cooldown = XENOA_TRAIT_COOLDOWN_EXTRA_SAFE
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	register_targets = FALSE
	rarity = XENOA_TRAIT_WEIGHT_RARE
	///List of possible colors
	var/list/possible_colors = list(LIGHT_COLOR_FIRE, LIGHT_COLOR_BLUE, LIGHT_COLOR_GREEN, LIGHT_COLOR_RED, LIGHT_COLOR_ORANGE, LIGHT_COLOR_PINK)
	///Our actual color
	var/color
	///Are we currently lit?
	var/lit = FALSE

/datum/xenoartifact_trait/major/illuminating/New(atom/_parent)
	. = ..()
	color = pick(possible_colors)

/datum/xenoartifact_trait/major/illuminating/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	lit = !lit
	var/atom/light_source = parent.parent
	if(lit)
		light_source.set_light(parent.trait_strength*0.04, min(parent.trait_strength*0.1, 10), color)
	else
		light_source.set_light(0, 0)
