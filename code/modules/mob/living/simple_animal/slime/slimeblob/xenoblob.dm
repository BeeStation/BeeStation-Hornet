/* Xenobio rework stuff
 * Currently has:
 *		structure/xenoblob
 *		creep
 *		nodes
 *		node/cores
 * In this file we need:
 * 		mutation
 */


/obj/structure/xenoblob
	icon = 'icons/mob/xenoblob.dmi'

/obj/structure/xenoblob/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)


/*
 * CREEP (acts like vines)
 */

/obj/structure/xenoblob/creep
	gender = PLURAL
	name = "slime creep"
	desc = "A layer of slime covers the floor here. Ewww..."
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "creep"
	max_integrity = 30
	//canSmoothWith = list(/obj/structure/xenoblob/creep, /turf/closed/wall)
	//smooth = SMOOTH_MORE

	var/last_expand = 0 // Last world.time this creep expanded
	var/growth_cooldown = 100
	var/node_timer = 0
	var/absorb_time = 200 // How long a (non-bio protected) mob has to be buckled (and dead) before becoming a node

	var/static/list/blacklisted_turfs // What turfs this can't grow on

	var/grabbing = FALSE // If the slime is currently working on buckling a mob
	var/absorbing = FALSE // If the creep is currently making a node

	var/obj/structure/xenoblob/node/owner_node // What node controls this creep. If none (node is cut out), maybe start dying?
	var/obj/structure/xenoblob/node/core/owner_core // If owned by a core, this is owner_node, if not, this is owner_node.owner_core. basically what blob this belongs to

	var/buckle_timer = 30 // How long it takes a (non bio-protected) mob to get buckled to creep in deciseconds
	var/eat_damage = 10 // How much damage this slime deals to a buckled mob

	var/distance_from_node = 0 //How far away (in tiles) are we from our node

/obj/structure/xenoblob/creep/Initialize(mapload, var/obj/structure/xenoblob/node/owner = null)
	. = ..()
	if(owner)
		owner_node = owner
		buckle_timer = owner.scolor.buckle_timer
		eat_damage = owner.scolor.eat_damage
		owner_node.creeps += src
		if(owner_node.is_core)
			owner_core = owner_node
		else
			owner_core = owner_node.owner_core
		distance_from_node = get_dist(get_turf(src), get_turf(owner_node))
	if(!blacklisted_turfs)
		blacklisted_turfs = typecacheof(list(
			/turf/open/space,
			/turf/open/chasm,
			/turf/open/lava))
	last_expand = world.time + growth_cooldown


/obj/structure/xenoblob/creep/proc/expand(var/node)
	var/turf/U = get_turf(src)
	if(is_type_in_typecache(U, blacklisted_turfs))
		qdel(src)
		return FALSE

	for(var/turf/T in U.GetAtmosAdjacentTurfs())
		var/obj/structure/xenoblob/creep/C = locate(/obj/structure/xenoblob/creep) in T
		if(C)
			if(!C.owner_node)
				C.owner_node = owner_node
				owner_node.creeps += C
				C.distance_from_node = get_dist(get_turf(C), get_turf(owner_node))
			continue

		if(is_type_in_typecache(T, blacklisted_turfs))
			continue

		new /obj/structure/xenoblob/creep(T, node)
	return TRUE

/obj/structure/xenoblob/creep/proc/on_step(var/mob/living/carbon/M) // Add stuff/override this for different slime step effects
	if(has_buckled_mobs() || M.stat == DEAD) // Shouldn't do any effect or try to grab again if it has something, or if the mob is dead
		return

	owner_node.scolor.effect(M, src) // color-specific effects go here
	to_chat(world, "## I STEP ON DA CREEP")

	var/delay = buckle_timer * 1 + M.getarmor(type = "bio")/20 // Bio protection increases the time, bio suit will make it take 5x as long
	grabbing = TRUE
	M.visible_message("<span class='warning'>[src] starts latching on to [M]!</span>", \
				"<span class='userdanger'>You feel [src] wrapping around you!</span>")
	if(do_after(M, delay))
		if(src.buckle_mob(M, TRUE))
			M.visible_message("<span class='warning'>[src] latches on to [M]!</span>", \
				"<span class='userdanger'>The [src] envelops you!</span>")
		else
			M.visible_message("<span class='warning'>[src] fails to latch on to [M]!</span>", \
				"<span class='warning'>The [src] tries to envelop you, but fails.</span>")
	grabbing = FALSE


/obj/structure/xenoblob/creep/proc/process_mob()
	for(var/mob/living/M in buckled_mobs) // Eating buckled mobs
		if(M.stat != DEAD) // If it isn't dead, eat
			eat(M)
		else if(locate(/obj/structure/xenoblob/node) in range(1, src)) //Nodes must be at least 1 tile away
			src.visible_message("<span class='warning'>[src] lets go of [M], as there is already a node nearby!</span>")
			return
		else if(!absorbing && M.stat == DEAD) // If buckled mob dead and creep not absorbing, start
			node_timer = world.time + absorb_time
			absorbing = TRUE
			visible_message("<span class='warning'>[src] starts absorbing [M]!</span>")
		else if (node_timer <= world.time) // If finished absorbing (and still has mob attached), attempt to make node
			if(buckled_mobs.Find(M))
				make_node(M)
				absorbing = FALSE
			else
				visible_message("<span class='warning'>[src] fails to absorb anything!</span>")

/obj/structure/xenoblob/creep/proc/eat(var/mob/living/carbon/M)
	var/bio_modifier = 1 + M.getarmor(type = "bio")/20
	var/damage = eat_damage / bio_modifier
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(ismonkey(M))
			C.adjustCloneLoss(damage) // Speed things up a bit for working
		C.adjustCloneLoss(damage)
		C.adjustToxLoss(damage/2)
	else if(isanimal(M))
		var/mob/living/simple_animal/SA = M
		SA.adjustCloneLoss(damage)
		SA.adjustToxLoss(damage/2)
	owner_core.add_hunger(30)

/obj/structure/xenoblob/creep/proc/make_node(var/mob/living/carbon/M)
	src.visible_message("<span class='warning'>[M] was engulfed by [src]!</span>")
	var/obj/structure/xenoblob/node/N
	var/datum/slimecolor/newColor
	if(prob(owner_node.mutation_chance))
		newColor = pick(owner_node.scolor.possible_mutations)

	if(src.owner_node.is_core)
		N = new /obj/structure/xenoblob/node(loc, src.owner_node, new newColor) // If creep is owned by a core, set new node's core to it
	else
		N = new /obj/structure/xenoblob/node(loc, src.owner_node.owner_core, new newColor) // If creep is owned by a node, set node's core to its core
	var/atom/movable/AM = M
	AM.forceMove(N) // Add this mob to contents of the new node, to be spit out on destroy

/obj/structure/xenoblob/creep/user_unbuckle_mob(mob/living/carbon/M, mob/user) // Make it take some time to unbuckle, overrides normal unbuckling
	if(has_buckled_mobs())
		if(M != user)
			user.visible_message("<span class='notice'>[user] begins to pull [M] free of the [src]...</span>", \
				"<span class='notice'>You begin to pull [M] free of the [src]...</span>")
			if(!do_mob(user, M, 30))
				return
			user.visible_message("<span class='notice'>[user] rips [M] free of the [src]!</span>", \
				"<span class='notice'>You rip [M] free of the [src]!</span>")
		else
			M.visible_message("<span class='warning'>[M] struggles to get the slime off!</span>", \
				"<span class='warning'>You struggle to get the slime off... (Stay still for 10 seconds.)</span>")
			if(!do_after(M, 100, target = src))
				if(M && M.buckled)
					to_chat(M, "<span class='warning'>You fail to free yourself!</span>")
				return
			if(!M.buckled)
				return
			M.visible_message("<span class='warning'>[M] rips the slime off!</span>", \
				"<span class='notice'>You rip the slime off!</span>")
		unbuckle_all_mobs(TRUE)

/obj/structure/xenoblob/creep/Destroy()
	if(owner_node)
		owner_node.creeps -= src
	qdel(src)
	. = ..()

/obj/structure/xenoblob/creep/proc/find_new_node()
	if(!owner_node)
		to_chat(world, "## [src] IS DYING")
		qdel(src)
		return
	var/obj/structure/xenoblob/node/N = locate(/obj/structure/xenoblob/node) in range(owner_node.range, src)
	if(N && N.frozen == FALSE)
		owner_node.creeps -= src
		owner_node = N
		N.creeps += src
		to_chat(world, "## [src] FOUND NEW NODE: [N]")
	else
		to_chat(world, "## [src] IS DYING")
		qdel(src)

/*
 * NODE
 */

/obj/structure/xenoblob/node
	gender = NEUTER
	name = "slime node"
	desc = "A mound of slime that contains what looks like... a living thing?"
	icon_state = "node"
	anchored = TRUE
	density = TRUE
	layer = MOB_LAYER
	plane = GAME_PLANE
	max_integrity = 200 // Should probably be used as health value

	var/extract_amount = 1 // How many extracts you'll get when harvesting, default 1 on nodes

	var/datum/slimecolor/scolor // Holds agression info, effect() (for on_step()), range, color
	var/mutation_chance = 100// Chance in % to mutate

	var/frozen = FALSE // If the node is frozen (by an endothermic trimmer) or not, should halt operations but stay alive
	var/thawing_time = 90 SECONDS // How long until this node thaws. Might be changed in different slime types -- TESTING
	var/time_frozen = 0 //When was the node frozen
	var/desecrated = FALSE // If the node has been completely desecrated by cold. Makes it unharvesable, and won't thaw unless heated to very high temps

	var/obj/structure/xenoblob/node/core/owner_core // What core controls this node. If none (core is killed), probably start becoming a core
	var/is_core = FALSE // If this is a node or a core. simplifes having to do if(X.owner_node == /obj/structure/xenoblob/node/core)

	var/range = 1 // How far the node will spread creep out to. Keep in mind that expand() makes creep on all adjacent tiles, so real range is this +1
	var/list/creeps // List of tiles controlled by this node

/obj/structure/xenoblob/node/Initialize(mapload, var/owner, var/datum/slimecolor/slmcolor) //scolor for slimecolor, in case we want to make a new node/core with X color (slime extracts growing into nodes?)
	. = ..()
	creeps = list()
	if(owner)
		owner_core = owner
		scolor = owner_core.scolor
		owner_core.controlled_nodes += src
	if(slmcolor)
		scolor = slmcolor
	if(!scolor)
		scolor = new /datum/slimecolor/grey

	var/obj/structure/xenoblob/creep/base_creep = locate() in loc
	if(!base_creep)
		new /obj/structure/xenoblob/creep(loc, src)
	else
		base_creep.owner_node.creeps.Remove(base_creep)
		base_creep.owner_node = src
		base_creep.distance_from_node = 0
		creeps.Add(base_creep)
	START_PROCESSING(SSobj, src)

/obj/structure/xenoblob/node/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/atom/movable/AM in contents)
		AM.forceMove(src.loc)
	for(var/obj/structure/xenoblob/creep/C in creeps)
		C.find_new_node()
	return ..()

/obj/structure/xenoblob/node/process()
	if(frozen || desecrated)
		anchored = FALSE
		handle_thawing()
		return // Don't do process stuff if frozen/super frozen
	else
		anchored = TRUE

	if(!(locate(/obj/structure/xenoblob/creep) in loc)) // Always have a creep below the node/core
		new /obj/structure/xenoblob/creep(loc, src)

	for(var/obj/structure/xenoblob/creep/C in creeps) // Expands the creep in a range, and sets cooldown
		if(C.last_expand <= world.time && C.distance_from_node <= range)
			if(C.expand(src))
				C.last_expand = world.time + C.growth_cooldown

	for(var/obj/structure/xenoblob/creep/C in creeps)
		if(C.has_buckled_mobs()) // If it has a mob, process it
			C.process_mob()
		else if(C.absorbing) // If it doesn't have a mob and still thinks it's absorbing, stop absorbing
			C.visible_message("<span class='warning'>[C] stops absorbing it's victim!</span>")
			C.absorbing = FALSE

		if(!C.grabbing)
			for(var/mob/living/carbon/M in C.loc) // I think on_step() should be overriden to do step effects for slime colors, and we probably need a cooldown
				C.on_step(M)
	handle_aggression()

/obj/structure/xenoblob/node/proc/uproot()
	frozen = TRUE
	for(var/obj/structure/xenoblob/creep/C in creeps)
		C.find_new_node()
	owner_core = null	//for now.
	creeps = null
	time_frozen = world.time

/obj/structure/xenoblob/node/proc/handle_aggression()
	var/slime_spawn_chance = owner_core.aggression/100
	if(slime_spawn_chance >= LOWEST_SLIME_SPAWN_CHANCE && prob(slime_spawn_chance + 10))// && LAZYLEN(owner_core.controlled_slimes) <= MAX_NUMBER_OF_SLIMES)
		var/mob/living/simple_animal/slime/S = new(get_turf(src), src.scolor.color)
		to_chat(world, "## [src] colour is: [src.scolor.color]")
		playsound(src, 'sound/effects/splat.ogg', 50, 1)
		to_chat(world, "<span class='notice'>[src] spits out [S].</span>")
		owner_core.controlled_slimes.Add(S)

/obj/structure/xenoblob/node/proc/handle_thawing()
	if(!frozen)
		to_chat(world, "## !FROZEN: FALSE")
		return

	to_chat(world, "## TIME FROZEN: [time_frozen] ## THAWING TIME: [thawing_time] ## WORLD TIME: [world.time]")

	if(time_frozen + thawing_time > world.time)
		to_chat(world, "## STILL THAWING")
		return
	to_chat(world, "## I'M HOT AGAIN")
	frozen = FALSE
	anchored = TRUE

	if(!(locate(/obj/structure/xenoblob/creep) in loc)) //Become a new core
		to_chat(world, "## BECOMING NEW CORE")
		new /obj/structure/xenoblob/node/core(loc, null, scolor)
		qdel(src)

/*
 * CORE (node+)
 */

/obj/structure/xenoblob/node/core
	name = "slime core"
	desc = "A translucent, pulsating mass of slime containing glowing cores."
	max_integrity = 400
	extract_amount = 1 // Placeholder amount until tile counts are kept
	range = 2
	is_core = TRUE

	var/total_tiles // Total of all tiles controlled by this blob, including tiles controlled by its nodes.
	var/list/controlled_nodes // List of all nodes controlled by this core

	// max hunger and agression are in __DEFINES/xenoblob.dm
	var/current_hunger // Directly relates to aggression rate
	var/aggression // Should do stuff like speed up eating, speed up buckling, maybe make step effects worse?, and make slimes come out of the core at a certain point
	var/aggression_rate // How fast agression goes up/down, could be locked by BZ gas and the CBZ reagent, and slowed down by frost oil and morphine
	var/aggression_level //At which aggression level the blob currently is: 6 - happy blob, not aggressive, 1 - pissed off, very aggressive
	var/list/controlled_slimes //List of slimes that this blob controls

/obj/structure/xenoblob/node/core/Initialize(mapload, owner, scolor)
	. = ..()
	controlled_nodes = list()
	create_reagents(100, INJECTABLE)
	current_hunger = src.scolor.max_hunger / 2
	aggression = 0
	aggression_level = 6
	controlled_slimes = list()
	if(!owner)
		owner_core = src
	else
		owner_core = owner


/obj/structure/xenoblob/node/core/process()
	. = ..()
	calculate_extracts()
	metabolize()

/obj/structure/xenoblob/node/core/proc/calculate_extracts() // Adds the count of total tiles, used to hardcap number of tiles like in the doc
	var/total_t
	if(controlled_nodes)
		for(var/obj/structure/xenoblob/node/N in controlled_nodes)
			total_t += N.creeps.len

	total_t += creeps.len
	total_tiles = total_t
	extract_amount = max(round(total_t/10), 1) // extract amount is dependant on tiles controlled, minimum 1

/obj/structure/xenoblob/node/core/proc/add_hunger(var/added_hunger)
	current_hunger = min(scolor.max_hunger, current_hunger + added_hunger)

/obj/structure/xenoblob/node/core/proc/add_aggression(var/added_aggression)
	aggression = min(scolor.max_aggression, aggression + added_aggression)

/obj/structure/xenoblob/node/core/proc/metabolize() // Everything to deal with hunger, reagent processing, and aggression
	if(current_hunger >= 0)
		current_hunger = max(0, current_hunger - 1)
		obj_integrity = min(max_integrity, obj_integrity + src.scolor.regen) // regen

	var/max_hunger = scolor.max_hunger
	var/list/aggro = scolor.aggression_rate

	if(current_hunger >= max_hunger * 0.75 && current_hunger <= max_hunger)
		aggression_rate = aggro[6]
		aggression_level = 6
	else if(current_hunger >= max_hunger * 0.6 && current_hunger < max_hunger * 0.75)
		aggression_rate = aggro[5]
		aggression_level = 5
	else if(current_hunger >= max_hunger * 0.4 && current_hunger < max_hunger * 0.6)
		aggression_rate = aggro[4]
		aggression_level = 4
	else if(current_hunger >= max_hunger * 0.25 && current_hunger < max_hunger * 0.4)
		aggression_rate = aggro[3]
		aggression_level = 3
	else if(current_hunger >= max_hunger * 0.05 && current_hunger < max_hunger * 0.25)
		aggression_rate = aggro[2]
		aggression_level = 2
	else if(current_hunger >= 0 && current_hunger < max_hunger * 0.05)
		aggression_rate = aggro[1]
		aggression_level = 1

	var/temp_aggression_rate = aggression_rate
	for(var/datum/reagent/R in reagents.reagent_list)
		switch(R.type)
			if(/datum/reagent/blood)
				add_hunger(40) // blood metabolizes super fast (5u a tick) so it needs to add a ton of hunger
			if(/datum/reagent/medicine/morphine)
				temp_aggression_rate = max(aggro[6], aggression_rate - 1)
			if(/datum/reagent/consumable/frostoil)
				temp_aggression_rate = max(aggro[6], aggression_rate - 2)
		reagents.remove_reagent(R.type, R.metabolization_rate)

	add_aggression(temp_aggression_rate)
	to_chat(world, "## AGGRESSION: [aggression] ## HUNGER: [current_hunger]")
