/*
	Major
	These traits cause the xenoartifact to do a specific action
	
	* weight - All majors should have a weight that is a multiple of 3
	* conductivity - If a major should have conductivity, it will be a multiple of 3 too
*/
/datum/xenoartifact_trait/major
	priority = TRAIT_PRIORITY_MAJOR
	weight = 3
	conductivity = 0

/*
	Electrified
	Electrocutes the mob target, or charges the cell target
*/
/datum/xenoartifact_trait/major/shock
	label_name = "Electrified"
	label_desc = "The artifact seems to contain electrifying components. Triggering these components will shock the target."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 27
	///max damage
	var/max_damage = 25

/datum/xenoartifact_trait/major/shock/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	if(length(focus))
		playsound(get_turf(parent.parent), 'sound/machines/defib_zap.ogg', 50, TRUE)
	for(var/atom/target in focus)
		if(iscarbon(target))
			var/mob/living/carbon/victim = target
			victim.electrocute_act(max_damage*(parent.trait_strength/100), parent.parent, 1, 1) //Deal a max of 25
		else if(istype(target, /obj/item/stock_parts/cell))
			var/obj/item/stock_parts/cell/C = target
			C.give((parent.trait_strength/100)*C.maxcharge) //Yes, this is potentially potentially powerful, but it will be cool
		var/atom/log_atom = parent.parent
		log_game("[parent] in [log_atom] electrocuted [key_name_admin(target)] at [world.time]. [log_atom] located at [AREACOORD(log_atom)]")
	dump_targets() //Get rid of anything else, since we can't interact with it
	clear_focus()

/*
	Hollow
	Captures the target for an amount of time
*/
/datum/xenoartifact_trait/major/hollow
	material_desc = "hollow"
	label_name = "Hollow"
	label_desc = "The artifact seems to contain hollow components. Triggering these components will capture the target."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = -10
	weight = 27
	///Maximum time we hold people for
	var/hold_time = 15 SECONDS

/datum/xenoartifact_trait/major/hollow/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
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
			//Paralyze so they don't break shit, I know they would if they were able to move
			if(isliving(AM))
				var/mob/living/L = AM
				L.Paralyze(hold_time*(parent.trait_strength/100))
			//Add timer to undo this - becuase the hold time is longer than an actual artifact cooldown, we need to do this per-mob
			addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/xenoartifact_trait, un_trigger), M), hold_time*(parent.trait_strength/100))
		else
			unregister_target(target)
	clear_focus()

/datum/xenoartifact_trait/major/hollow/un_trigger(atom/override, handle_parent = FALSE)
	focus = override ? list(override) : targets
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
	flags = XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	weight = 24
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
	material_desc = "barreled"
	label_name = "Barreled"
	label_desc = "Barreled: The artifact seems to contain projectile components. Triggering these components will produce a projectile."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	extra_target_range = 2
	weight = 21
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
		return
	for(var/atom/target in focus)
		var/turf/T = get_turf(target)
		if(get_turf(parent.parent) == T)
			T = get_edge_target_turf(parent.parent, pick(NORTH, EAST, SOUTH, WEST))
		var/obj/projectile/P = new choosen_projectile()
		P.preparePixelProjectile(T, parent.parent)
		P.fire()
		playsound(get_turf(parent.parent), 'sound/mecha/mech_shield_deflect.ogg', 50, TRUE)
	dump_targets()
	clear_focus()

/*
	Bestialized
	The artifact shoots the target with a random projectile
*/
/datum/xenoartifact_trait/major/animalize ///All of this is stolen from corgium.
	label_name = "Bestialized"
	label_desc = "Bestialized: The artifact contains transforming components. Triggering these components transforms the target into an animal."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	weight = 15
	conductivity = 12
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
		return
	for(var/mob/living/target in focus)
		if(istype(target, choosen_animal) || IS_DEAD_OR_INCAP(target))
			continue
		transform(target)
		var/atom/log_atom = parent.parent
		log_game("[parent] in [log_atom] transformed [key_name_admin(target)] into [choosen_animal] at [world.time]. [log_atom] located at [AREACOORD(log_atom)]")
		//Add timer to undo this
		addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/xenoartifact_trait, un_trigger), target), animal_time*(parent.trait_strength/100))
	clear_focus()

/datum/xenoartifact_trait/major/animalize/un_trigger(atom/override, handle_parent = FALSE)
	focus = override ? list(override) : targets
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
	var/obj/shapeshift_holder/H = (locate(/obj/shapeshift_holder) in target) || istype(target.loc, /obj/shapeshift_holder) ? target.loc : null
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
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	rarity = XENOA_TRAIT_WEIGHT_RARE
	weight = 9
	conductivity = 36

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
	empulse(T, max(1, parent.trait_strength*0.03), max(1, parent.trait_strength*0.05, 1))
	var/atom/log_atom = parent.parent
	log_game("[parent] in [log_atom] made an EMP at [world.time]. [log_atom] located at [AREACOORD(log_atom)]")

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
	flags =  XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 15
	conductivity = 15

/datum/xenoartifact_trait/major/displaced/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	if(length(focus))
		playsound(get_turf(parent.parent), 'sound/machines/defib_zap.ogg', 50, TRUE)
	for(var/atom/movable/target in focus)
		if(!target.anchored)
			do_teleport(target, get_turf(target), (parent.trait_strength*0.3)+1, channel = TELEPORT_CHANNEL_BLUESPACE)
			var/atom/log_atom = parent.parent
			log_game("[parent] in [log_atom] teleported [key_name_admin(target)] at [world.time]. [log_atom] located at [AREACOORD(log_atom)]")
		unregister_target(target)
	dump_targets()
	clear_focus()

/*
	Illuminating
	Toggles a light on the artifact
*/
/datum/xenoartifact_trait/major/illuminating
	label_name = "Illuminating"
	label_desc = "Illuminating: The artifact seems to contain illuminating components. Triggering these components will cause the artifact to illuminate."
	cooldown = XENOA_TRAIT_COOLDOWN_EXTRA_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	weight = 18
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

/*
	Obstructing
	Builds forcefields around the artifact
*/
/datum/xenoartifact_trait/major/forcefield
	label_name = "Obstructing"
	label_desc = "Obstructing: The artifact seems to contain obstructing components. Triggering these components will cause the artifact to build walls around itself."
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	weight = 33
	///What wall size are we making?
	var/wall_size
	///Max time we keep walls around for
	var/wall_time = 8 SECONDS

/datum/xenoartifact_trait/major/forcefield/New(atom/_parent)
	. = ..()
	wall_size = pick(1, 2, 3)

/datum/xenoartifact_trait/major/forcefield/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/time = wall_time*(parent.trait_strength/100)
	//Don't use a switch case, we just pass through the ifs and add walls as we go
	if(wall_size >= 1)
		new /obj/effect/forcefield/xenoartifact_type(get_turf(parent.parent), time)
	if(wall_size >= 2)
		//If we're not making a symetrical design, pick a random orientation
		var/outcome = pick(0, 1)
		if(outcome || wall_size >= 3)
			new /obj/effect/forcefield/xenoartifact_type(get_step(parent.parent, NORTH), time)
			new /obj/effect/forcefield/xenoartifact_type(get_step(parent.parent, SOUTH), time)
		else
			new /obj/effect/forcefield/xenoartifact_type(get_step(parent.parent, EAST), time)
			new /obj/effect/forcefield/xenoartifact_type(get_step(parent.parent, WEST), time)
	if(wall_size >= 3)
		new /obj/effect/forcefield/xenoartifact_type(get_step(parent.parent, WEST), time)
		new /obj/effect/forcefield/xenoartifact_type(get_step(parent.parent, EAST), time)

//Special wall type for artifact. Throw any extra code or special logic in here
/obj/effect/forcefield/xenoartifact_type
	desc = "An impenetrable artifact wall."

/*
	Healing
	TODO: Consider re-designing this - Racc
*/
//datum/xenoartifact_trait/major/heal 

/*
	Hypodermic
	Injects the target with a random, safe, chemical
*/
/datum/xenoartifact_trait/major/chem
	label_name = "Hypodermic"
	label_desc = "Hypodermic: The artifact seems to contain chemical components. Triggering these components will inject the target with a chemical."
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 30
	///What chemical we're injecting
	var/datum/reagent/formula
	///max amount we can inject people with
	var/formula_amount
	var/generic_amount = 11

/datum/xenoartifact_trait/major/chem/New(atom/_parent)
	. = ..()
	formula = get_random_reagent_id(CHEMICAL_RNG_GENERAL)
	formula_amount = (initial(formula.overdose_threshold) || generic_amount) - 1

/datum/xenoartifact_trait/major/chem/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/target in focus)
		if(target.reagents)
			playsound(get_turf(target), pick('sound/items/hypospray.ogg','sound/items/hypospray2.ogg'), 50, TRUE)
			var/datum/reagents/R = target.reagents
			R.add_reagent(formula, formula_amount*(parent.trait_strength/100))
			var/atom/log_atom = parent.parent
			log_game("[parent] in [log_atom] injected [key_name_admin(target)] with [formula_amount*(parent.trait_strength/100)]u of [formula] at [world.time]. [log_atom] located at [AREACOORD(log_atom)]")
		unregister_target(target)
	dump_targets()
	clear_focus()

/*
	Forcing
	Inacts a pushing or pulling force on the target
*/
/datum/xenoartifact_trait/major/force
	label_name = "Forcing"
	label_desc = "Forcing: The artifact seems to contain impulsing components. Triggering these components will impulse, either pushing or pulling, the target."
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 21
	conductivity = 27
	///Max force we can use, aka how far we throw things
	var/max_force = 7
	///Force direction, push or pull
	var/force_dir

/datum/xenoartifact_trait/major/force/New(atom/_parent)
	. = ..()
	force_dir = rand(0, 1)

/datum/xenoartifact_trait/major/force/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/movable/target in focus)
		if(target.anchored)
			return
		var/turf/parent_turf = get_turf(parent.parent)
		var/turf/T
		if(force_dir)
			T = get_edge_target_turf(parent_turf, get_dir(parent_turf, get_turf(target)) || pick(NORTH, EAST, SOUTH, WEST))
		else
			T = parent_turf
		target.throw_at(T, max_force*(parent.trait_strength/100), 4)
		unregister_target(target)
	dump_targets()
	clear_focus()

/*
	Echoing
	The artifact plays a random sound
*/
/datum/xenoartifact_trait/major/noise
	label_name = "Echoing"
	label_desc = "Echoing: The artifact seems to contain echoing components. Triggering these components will cause the artifact to make a noise."
	cooldown = XENOA_TRAIT_COOLDOWN_EXTRA_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	///List of possible noises
	var/list/possible_noises = list('sound/effects/adminhelp.ogg', 'sound/effects/applause.ogg', 'sound/effects/bubbles.ogg',
					'sound/effects/empulse.ogg', 'sound/effects/explosion1.ogg', 'sound/effects/explosion_distant.ogg',
					'sound/effects/laughtrack.ogg', 'sound/effects/magic.ogg', 'sound/effects/meteorimpact.ogg',
					'sound/effects/phasein.ogg', 'sound/effects/supermatter.ogg', 'sound/weapons/armbomb.ogg',
					'sound/weapons/blade1.ogg')
	///The noise we will make
	var/noise

/datum/xenoartifact_trait/major/noise/New(atom/_parent)
	. = ..()
	noise = pick(possible_noises)

/datum/xenoartifact_trait/major/noise/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	playsound(get_turf(parent.parent), noise, 50, FALSE)

/*
	Porous
	The artifact replaces one random gas with another
*/
/datum/xenoartifact_trait/major/gas
	label_name = "Porous"
	label_desc = "Porous: The artifact seems to contain porous components. Triggering these components will cause the artifact to exchange one gas with another."
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	weight = 15
	///Possible target gasses
	var/list/target_gasses = list(
		/datum/gas/oxygen = 6,
		/datum/gas/nitrogen = 3,
		/datum/gas/plasma = 1,
		/datum/gas/carbon_dioxide = 1,
		/datum/gas/water_vapor = 3
	)
	///Possible exchange gasses
	var/list/exchange_gasses = list(
		/datum/gas/bz = 3,
		/datum/gas/hypernoblium = 1,
		/datum/gas/plasma = 3,
		/datum/gas/tritium = 2,
		/datum/gas/nitryl = 1
	)
	///Choosen target gas
	var/datum/gas/choosen_target
	///Choosen exchange gas
	var/datum/gas/choosen_exchange
	///Max amount of moles we exchange at once
	var/max_moles = 10

/datum/xenoartifact_trait/major/gas/New(atom/_parent)
	. = ..()
	choosen_target = pick_weight(target_gasses)
	choosen_exchange = pick_weight(exchange_gasses)

/datum/xenoartifact_trait/major/gas/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(parent.parent)
	var/datum/gas_mixture/air = T.return_air()
	var/input_id = initial(choosen_target.id)
	var/output_id = initial(choosen_exchange.id)
	var/moles = min(air.get_moles(input_id), max_moles)
	air.adjust_moles(input_id, -moles)
	air.adjust_moles(output_id, moles)

/*
	Destabilizing
	Send the target to the shadow realm
*/
/datum/xenoartifact_trait/major/shadow_realm
	label_name = "Destabilizing"
	label_desc = "Destabilizing: The artifact seems to contain destabilizing components. Triggering these components will cause the artifact transport the target to another realm."
	cooldown = XENOA_TRAIT_COOLDOWN_GAMER
	flags = XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	rarity = XENOA_TRAIT_WEIGHT_EPIC
	weight = 36
	conductivity = 36

/datum/xenoartifact_trait/major/shadow_realm/New(atom/_parent)
	. = ..()
	GLOB.destabliization_exits += parent.parent

/datum/xenoartifact_trait/major/shadow_realm/Destroy(force, ...)
	GLOB.destabliization_exits -= parent.parent
	return ..()

/datum/xenoartifact_trait/major/shadow_realm/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/movable/target in focus)
		if(target.anchored)
			continue
		//handle being held
		var/atom/movable/AM = parent.parent
		if(!isturf(AM.loc) && locate(AM.loc) in focus)
			AM.forceMove(get_turf(AM.loc))
		//Banish target
		target.forceMove(pick(GLOB.destabilization_spawns))
	dump_targets()
	clear_focus()

/*
	Dissipating
	The artifact spawns a cloud of smoke
*/
/datum/xenoartifact_trait/major/smoke
	label_name = "Dissipating"
	label_desc = "Dissipating: The artifact seems to contain dissipating components. Triggering these components will cause the artifact to create a cloud of smoke."
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	register_targets = FALSE
	weight = 6
	///The maximum size of our smoke stack in turfs, I think
	var/max_size = 6

/datum/xenoartifact_trait/major/smoke/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/datum/effect_system/smoke_spread/E = new()
	E.set_up(max_size*(parent.trait_strength/100), get_turf(parent.parent))
	E.start()

/*
	Marking
	Colors the target
*/
/datum/xenoartifact_trait/major/color
	label_name = "Marking"
	label_desc = "Marking: The artifact seems to contain colorizing components. Triggering these components will color the target."
	cooldown = XENOA_TRAIT_COOLDOWN_EXTRA_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	///Possible colors
	var/list/possible_colors = list(COLOR_RED, COLOR_GREEN, COLOR_BLUE, COLOR_PURPLE, COLOR_ORANGE, COLOR_YELLOW, COLOR_CYAN, COLOR_PINK, "all")
	///Choosen color
	var/color

/datum/xenoartifact_trait/major/color/New(atom/_parent)
	. = ..()
	color = pick(possible_colors)

/datum/xenoartifact_trait/major/color/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/target in focus)
		//These colors can be washed off
		//TODO: make that know ;3 - Racc
		if(color == "all")
			target.color = pick(possible_colors)
		else
			target.color = color
	dump_targets() //Get rid of anything else, since we can't interact with it
	clear_focus()

/*
	Enthusing
	Colors the target
*/
/datum/xenoartifact_trait/major/emote
	label_name = "Enthusing"
	label_desc = "Enthusing: The artifact seems to contain emoting components. Triggering these components will cause the target to emote."
	cooldown = XENOA_TRAIT_COOLDOWN_EXTRA_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	///List of possible emotes
	var/list/possible_emotes = list(/datum/emote/flip, /datum/emote/spin, /datum/emote/living/laugh, 
	/datum/emote/living/scream, /datum/emote/living/tremble, /datum/emote/living/whimper,
	/datum/emote/living/smile, /datum/emote/living/pout, /datum/emote/living/gag,
	/datum/emote/living/deathgasp, /datum/emote/living/dance, /datum/emote/living/blush)
	///Emote to preform
	var/datum/emote/emote

/datum/xenoartifact_trait/major/emote/New(atom/_parent)
	. = ..()
	emote = pick(possible_emotes)
	emote = new emote()

/datum/xenoartifact_trait/major/emote/Destroy(force, ...)
	QDEL_NULL(emote)
	return ..()

/datum/xenoartifact_trait/major/emote/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/mob/living/carbon/target in focus)
		INVOKE_ASYNC(src, PROC_REF(run_emote), target) 
	//TODO: Add a default hint - Racc
	dump_targets() //Get rid of anything else, since we can't interact with it
	clear_focus()

/datum/xenoartifact_trait/major/emote/proc/run_emote(mob/living/carbon/target)
	emote.run_emote(target)
