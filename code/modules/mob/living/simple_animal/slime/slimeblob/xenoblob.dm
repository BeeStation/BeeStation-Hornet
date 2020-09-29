/* Xenobio rework stuff
 * Currently has:
 *		structure/xenoblob
 *		creep
 *		nodes
 *		node/cores
 * Rest of this folder cain contain everything needed for this rework until ready to pr, then distirbute it to the right places when ready
 * In this file we need:
 * 		buckling, digesting, node creating
 * 		mutation
 */


/obj/structure/xenoblob
	icon = 'icons/mob/xenoblob.dmi'

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
	var/static/list/blacklisted_turfs // What turfs this can't grow on

	var/has_buckled_mob // Is the creep digesting a mob?
	var/living/carbon/buckled_mob // What mob is the creep digesting?
	var/node_timer = 1000 // How long a mob has to be buckled before becoming a node

	var/slimecolor

	var/obj/structure/xenoblob/node/owner_node // What node controls this creep. If none (node is cut out), maybe start dying?

/obj/structure/xenoblob/creep/Initialize(mapload, var/owner = null)
	. = ..()
	if(owner)
		owner_node = owner
		slimecolor = owner_node.color
		owner_node.controlled_tiles += src
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
		if((locate(/obj/structure/xenoblob) in T))
			continue

		if(is_type_in_typecache(T, blacklisted_turfs))
			continue

		new /obj/structure/xenoblob/creep(T, node)
	return TRUE

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

	var/obj/item/slime_extract/core_type // Node's current core type
	var/core_amount = 1 // How many cores you'll get when harvesting, default 1 on nodes
	var/slimecolor = "grey" // Node's current color, determines core type on init
	var/mutation_chance // Unsure how to use yet, probably implemented when creating nodes is

	//var/maxhunger //Not sure if we want a hunger system or not, I'll put this here
	//var/currenthunger // To keep it simple, would go down by 1 a tick. Adjust maxhunger accordingly (rates are unnessecarily hard to keep track of)

	var/frozen = FALSE // If the node is frozen or not, should halt operations
	var/thawing_time = 900 // How long until this node thaws. Might be changed in different slime types

	var/obj/structure/xenoblob/node/core/owner_core // What core controls this node. If none (core is killed), probably start dying or start becoming a core
	var/list/controlled_tiles // List of tiles controlled by this node

	var/mob/living/carbon/trapped_mob // What mob is trapped inside of the node, could be spit out when node is harvested for use in monkey recycler

	var/range = 2 // How far the node will spread creep out to. Keep in mind that expand() makes creep on all adjacent tiles, so real range is this +1

/obj/structure/xenoblob/node/Initialize(mapload, var/owner, var/scolor) //scolor for slimecolor, in case we want to make a new node/core with X color (slime cores growing into nodes?)
	. = ..()
	controlled_tiles = list()
	if(owner)
		owner_core = owner
		slimecolor = owner_core.slimecolor // TODO: color mutation. Maybe color mutation uses scolor?
		owner_core.controlled_nodes += src
	if(scolor)
		slimecolor = scolor
	core_type = text2path("/obj/item/slime_extract/[slimecolor]")
	if(!(locate(/obj/structure/xenoblob/creep) in loc))
		new /obj/structure/xenoblob/creep(loc, src)
	START_PROCESSING(SSobj, src)

/obj/structure/xenoblob/node/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/xenoblob/node/process()
	if(frozen)
		anchored = FALSE
		return
	else
		anchored = TRUE
	if(!(locate(/obj/structure/xenoblob/creep) in loc))
		new /obj/structure/xenoblob/creep(loc, src)
	for(var/obj/structure/xenoblob/creep/C in range(range, src))
		if(C.last_expand <= world.time)
			if(C.expand(src))
				C.last_expand = world.time + C.growth_cooldown

/obj/structure/xenoblob/node/core
	name = "slime core"
	desc = "A translucent, pulsating mass of slime containing glowing cores."
	max_integrity = 400
	core_amount = 4 // Placeholder amount until tile counts are kept
	range = 3

	var/total_tiles // Total of all tiles controlled by this blob, including tiles controlled by its nodes.
	var/list/controlled_nodes // List of all nodes controlled by this core

/obj/structure/xenoblob/node/core/Initialize(mapload, owner, scolor)
	. = ..()
	controlled_nodes = list()

/obj/structure/xenoblob/node/core/process() // Adds the count of total tiles, used to hardcap number of tiles like in the doc
	. = ..()
	var/total_t
	if(controlled_nodes)
		for(var/obj/structure/xenoblob/node/N in controlled_nodes)
			total_t += N.controlled_tiles.len
	total_t += controlled_tiles
	total_tiles = total_t

