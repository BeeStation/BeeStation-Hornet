GLOBAL_LIST_INIT(cable_colors, list(
	"yellow" = "#ffff00",
	"green" = "#00aa00",
	"blue" = "#1919c8",
	"pink" = "#ff3cc8",
	"orange" = "#ff8000",
	"cyan" = "#00ffff",
	"white" = "#ffffff",
	"red" = "#ff0000"
	))


///////////////////////////////
//CABLE STRUCTURE
///////////////////////////////


////////////////////////////////
// Definitions
////////////////////////////////

/* Cable directions (d1 and d2)


  9   1   5
	\ | /
  8 - 0 - 4
	/ | \
  10  2   6

If d1 = 0 and d2 = 0, there's no cable
If d1 = 0 and d2 = dir, it's a O-X cable, getting from the center of the tile to dir (knot cable)
If d1 = dir1 and d2 = dir2, it's a full X-X cable, getting from dir1 to dir2
By design, d1 is the smallest direction and d2 is the highest
*/

/obj/structure/cable
	name = "power cable"
	desc = "A flexible, superconducting insulated cable for heavy-duty power transfer."
	icon = 'icons/obj/power_cond/cables.dmi'
	icon_state = "0-1"
	layer = WIRE_LAYER //Above hidden pipes, GAS_PIPE_HIDDEN_LAYER
	anchored = TRUE
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	var/d1 = 0   // cable direction 1 (see above)
	var/d2 = 1   // cable direction 2 (see above)
	var/datum/powernet/powernet

	FASTDMM_PROP(\
		pipe_type = PIPE_TYPE_CABLE,\
		pipe_interference_group = list("cable"),\
		pipe_group = "cable-[cable_color]"\
	)

	var/cable_color = "red"
	color = "#ff0000"

/obj/structure/cable/yellow
	cable_color = "yellow"
	color = "#ffff00"

/obj/structure/cable/green
	cable_color = "green"
	color = "#00aa00"

/obj/structure/cable/blue
	cable_color = "blue"
	color = "#1919c8"

/obj/structure/cable/pink
	cable_color = "pink"
	color = "#ff3cc8"

/obj/structure/cable/orange
	cable_color = "orange"
	color = "#ff8000"

/obj/structure/cable/cyan
	cable_color = "cyan"
	color = "#00ffff"

/obj/structure/cable/white
	cable_color = "white"
	color = "#ffffff"

// the power cable object
/obj/structure/cable/Initialize(mapload, param_color)
	. = ..()

	// ensure d1 & d2 reflect the icon_state for entering and exiting cable
	var/dash = findtext(icon_state, "-")
	d1 = text2num(copytext(icon_state, 1, dash))
	d2 = text2num(copytext(icon_state, dash + length(icon_state[dash])))

	GLOB.cable_list += src //add it to the global cable list

	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE)

	var/list/cable_colors = GLOB.cable_colors
	cable_color = param_color || cable_color || pick(cable_colors)
	if(cable_colors[cable_color])
		cable_color = cable_colors[cable_color]
	update_icon()

/obj/structure/cable/Destroy()					// called when a cable is deleted
	if(powernet)
		cut_cable_from_powernet()				// update the powernets
	GLOB.cable_list -= src							//remove it from global cable list
	return ..()									// then go ahead and delete the cable

/obj/structure/cable/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(loc)
		if(T)
			var/obj/R = new /obj/item/stack/cable_coil(T, d1 ? 2 : 1, cable_color)
			if(QDELETED(R)) // the coil merged with something on the tile
				R = locate(/obj/item/stack/cable_coil) in T
			if(R)
				transfer_fingerprints_to(R)
		var/turf/T_below = T.below()
		if((d1 == DOWN || d2 == DOWN) && T_below)
			for(var/obj/structure/cable/C in T_below)
				if(C.d1 == UP || C.d2 == UP)
					C.deconstruct()
	..()

///////////////////////////////////
// General procedures
///////////////////////////////////

/obj/structure/cable/update_icon()
	icon_state = "[d1]-[d2]"
	color = null
	add_atom_colour(cable_color, FIXED_COLOUR_PRIORITY)

/obj/structure/cable/proc/handlecable(obj/item/W, mob/user, params)
	var/turf/T = get_turf(src)
	if(T.intact)
		return
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		if(d1 == UP || d2 == UP)
			to_chat(user, "<span class='warning'>You must cut this cable from above.</span>")
			return
		if (shock(user, 50))
			return
		user.visible_message("[user] cuts the cable.", "<span class='notice'>You cut the cable.</span>")
		investigate_log("was cut by [key_name(usr)] in [AREACOORD(src)]", INVESTIGATE_WIRES)
		deconstruct()
		return

	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = W
		if (coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>Not enough cable!</span>")
			return
		coil.cable_join(src, user)

	else if(istype(W, /obj/item/rcl))
		var/obj/item/rcl/R = W
		if(R.loaded)
			R.loaded.cable_join(src, user)
			R.is_empty(user)

	else if(W.tool_behaviour == TOOL_MULTITOOL)
		to_chat(user, get_power_info())
		shock(user, 5, 0.2)

	add_fingerprint(user)

// Items usable on a cable :
//   - Wirecutters : cut it duh !
//   - Cable coil : merge cables
//   - Multitool : get the power currently passing through the cable
//
/obj/structure/cable/attackby(obj/item/W, mob/user, params)
	handlecable(W, user, params)

/obj/structure/cable/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += get_power_info()

// shock the user with probability prb
/obj/structure/cable/proc/shock(mob/user, prb, siemens_coeff = 1)
	if(!prob(prb))
		return 0
	if (electrocute_mob(user, powernet, src, siemens_coeff))
		do_sparks(5, TRUE, src)
		return 1
	else
		return 0

/obj/structure/cable/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/structure/cable/proc/get_power_info()
	if(powernet && (powernet.avail > 0))		// is it powered?
		return "<span class='danger'>Total power: [display_power(powernet.avail)]\nLoad: [display_power(powernet.load)]\nExcess power: [display_power(surplus())]</span>"
	else
		return "<span class='danger'>The cable is not powered.</span>"

////////////////////////////////////////////
// Power related
///////////////////////////////////////////

// All power generation handled in add_avail()
// Machines should use add_load(), surplus(), avail()
// Non-machines should use add_delayedload(), delayed_surplus(), newavail()

/obj/structure/cable/proc/add_avail(amount)
	if(powernet)
		powernet.newavail += amount

/obj/structure/cable/proc/add_load(amount)
	if(powernet)
		powernet.load += amount

/obj/structure/cable/proc/surplus()
	if(powernet)
		return CLAMP(powernet.avail-powernet.load, 0, powernet.avail)
	else
		return 0

/obj/structure/cable/proc/avail(amount)
	if(powernet)
		return amount ? powernet.avail >= amount : powernet.avail
	else
		return 0

/obj/structure/cable/proc/add_delayedload(amount)
	if(powernet)
		powernet.delayedload += amount

/obj/structure/cable/proc/delayed_surplus()
	if(powernet)
		return CLAMP(powernet.newavail - powernet.delayedload, 0, powernet.newavail)
	else
		return 0

/obj/structure/cable/proc/newavail()
	if(powernet)
		return powernet.newavail
	else
		return 0

/////////////////////////////////////////////////
// Cable laying helpers
////////////////////////////////////////////////

//handles merging diagonally matching cables
//for info : direction^3 is flipping horizontally, direction^12 is flipping vertically
/obj/structure/cable/proc/mergeDiagonalsNetworks(direction)

	//search for and merge diagonally matching cables from the first direction component (north/south)
	var/turf/T  = get_step_multiz(src, direction&3)//go north/south

	for(var/obj/structure/cable/C in T)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == (direction^3) || C.d2 == (direction^3)) //we've got a diagonally matching cable
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

	//the same from the second direction component (east/west)
	T  = get_step_multiz(src, direction&12)//go east/west

	for(var/obj/structure/cable/C in T)

		if(!C)
			continue

		if(src == C)
			continue
		if(C.d1 == (direction^12) || C.d2 == (direction^12)) //we've got a diagonally matching cable
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the given direction
/obj/structure/cable/proc/mergeConnectedNetworks(direction)

	var/fdir = (!direction)? 0 : dir_inverse_multiz(direction) //flip the direction, to match with the source position on its turf

	if(!(d1 == direction || d2 == direction)) //if the cable is not pointed in this direction, do nothing
		return

	var/turf/TB  = get_step_multiz(src, direction)

	for(var/obj/structure/cable/C in TB)

		if(!C)
			continue

		if(src == C)
			continue

		if(C.d1 == fdir || C.d2 == fdir) //we've got a matching cable in the neighbor turf
			if(!C.powernet) //if the matching cable somehow got no powernet, make him one (should not happen for cables)
				var/datum/powernet/newPN = new()
				newPN.add_cable(C)

			if(powernet) //if we already have a powernet, then merge the two powernets
				merge_powernets(powernet,C.powernet)
			else
				C.powernet.add_cable(src) //else, we simply connect to the matching cable powernet

// merge with the powernets of power objects in the source turf
/obj/structure/cable/proc/mergeConnectedNetworksOnTurf()
	var/list/to_connect = list()

	if(!powernet) //if we somehow have no powernet, make one (should not happen for cables)
		var/datum/powernet/newPN = new()
		newPN.add_cable(src)

	//first let's add turf cables to our powernet
	//then we'll connect machines on turf with a node cable is present
	for(var/AM in loc)
		if(istype(AM, /obj/structure/cable))
			var/obj/structure/cable/C = AM
			if(C.d1 == d1 || C.d2 == d1 || C.d1 == d2 || C.d2 == d2) //only connected if they have a common direction
				if(C.powernet == powernet)
					continue
				if(C.powernet)
					merge_powernets(powernet, C.powernet)
				else
					powernet.add_cable(C) //the cable was powernetless, let's just add it to our powernet

		else if(istype(AM, /obj/machinery/power/apc))
			var/obj/machinery/power/apc/N = AM
			if(!N.terminal)
				continue // APC are connected through their terminal

			if(N.terminal.powernet == powernet)
				continue

			to_connect += N.terminal //we'll connect the machines after all cables are merged

		else if(istype(AM, /obj/machinery/power)) //other power machines
			var/obj/machinery/power/M = AM

			if(M.powernet == powernet)
				continue

			to_connect += M //we'll connect the machines after all cables are merged

	//now that cables are done, let's connect found machines
	for(var/obj/machinery/power/PM in to_connect)
		if(!PM.connect_to_network())
			PM.disconnect_from_network() //if we somehow can't connect the machine to the new powernet, remove it from the old nonetheless

//////////////////////////////////////////////
// Powernets handling helpers
//////////////////////////////////////////////

//if powernetless_only = 1, will only get connections without powernet
/obj/structure/cable/proc/get_connections(powernetless_only = 0)
	. = list()	// this will be a list of all connected power objects
	var/turf/T

	//get matching cables from the first direction
	if(d1) //if not a node cable
		T = get_step_multiz(src, d1)
		if(T)
			. += power_list(T, src, dir_inverse_multiz(d1), powernetless_only) //get adjacents matching cables

	if(d1&(d1-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step_multiz(src,d1&3) // go north/south
		if(T)
			. += power_list(T, src, d1 ^ 3, powernetless_only) //get diagonally matching cables
		T = get_step_multiz(src,d1&12) // go east/west
		if(T)
			. += power_list(T, src, d1 ^ 12, powernetless_only) //get diagonally matching cables

	. += power_list(loc, src, d1, powernetless_only) //get on turf matching cables

	//do the same on the second direction (which can't be 0)
	T = get_step_multiz(src, d2)
	if(T)
		. += power_list(T, src, dir_inverse_multiz(d2), powernetless_only) //get adjacents matching cables

	if(d2&(d2-1)) //diagonal direction, must check the 4 possibles adjacents tiles
		T = get_step_multiz(src,d2&3) // go north/south
		if(T)
			. += power_list(T, src, d2 ^ 3, powernetless_only) //get diagonally matching cables
		T = get_step_multiz(src,d2&12) // go east/west
		if(T)
			. += power_list(T, src, d2 ^ 12, powernetless_only) //get diagonally matching cables
	. += power_list(loc, src, d2, powernetless_only) //get on turf matching cables

	return .

//should be called after placing a cable which extends another cable, creating a "smooth" cable that no longer terminates in the centre of a turf.
//needed as this can, unlike other placements, disconnect cables
/obj/structure/cable/proc/denode()
	var/turf/T1 = loc
	if(!T1)
		return

	var/list/powerlist = power_list(T1,src,0,0) //find the other cables that ended in the centre of the turf, with or without a powernet
	if(powerlist.len>0)
		var/datum/powernet/PN = new()
		propagate_network(powerlist[1],PN) //propagates the new powernet beginning at the source cable

		if(PN.is_empty()) //can happen with machines made nodeless when smoothing cables
			qdel(PN)

/obj/structure/cable/proc/auto_propogate_cut_cable(obj/O)
	if(O && !QDELETED(O))
		var/datum/powernet/newPN = new()// creates a new powernet...
		propagate_network(O, newPN)//... and propagates it to the other side of the cable

// cut the cable's powernet at this cable and updates the powergrid
/obj/structure/cable/proc/cut_cable_from_powernet(remove=TRUE)
	var/turf/T1 = loc
	var/list/P_list
	if(!T1)
		return
	if(d1)
		T1 = get_step_multiz(T1, d1)
		P_list = power_list(T1, src, dir_inverse_multiz(d1),0,cable_only = 1)	// what adjacently joins on to cut cable...

	P_list += power_list(loc, src, d1, 0, cable_only = 1)//... and on turf


	if(P_list.len == 0)//if nothing in both list, then the cable was a lone cable, just delete it and its powernet
		powernet.remove_cable(src)

		for(var/obj/machinery/power/P in T1)//check if it was powering a machine
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network (and delete powernet)
		return

	var/obj/O = P_list[1]
	// remove the cut cable from its turf and powernet, so that it doesn't get count in propagate_network worklist
	if(remove)
		moveToNullspace()
	powernet.remove_cable(src) //remove the cut cable from its powernet

	addtimer(CALLBACK(O, PROC_REF(auto_propogate_cut_cable), O), 0) //so we don't rebuild the network X times when singulo/explosion destroys a line of X cables

	// Disconnect machines connected to nodes
	if(d1 == 0) // if we cut a node (O-X) cable
		for(var/obj/machinery/power/P in T1)
			if(!P.connect_to_network()) //can't find a node cable on a the turf to connect to
				P.disconnect_from_network() //remove from current network


///////////////////////////////////////////////
// The cable coil object, used for laying cable
///////////////////////////////////////////////

////////////////////////////////
// Definitions
////////////////////////////////

GLOBAL_LIST_INIT(cable_coil_recipes, list (new/datum/stack_recipe("cable restraints", /obj/item/restraints/handcuffs/cable, 15), new/datum/stack_recipe("noose", /obj/structure/chair/noose, 30, time = 80, one_per_turf = 1, on_floor = 1)))

/obj/item/stack/cable_coil
	name = "cable coil"
	custom_price = 15
	gender = NEUTER //That's a cable coil sounds better than that's some cable coils
	icon = 'icons/obj/power.dmi'
	icon_state = "coil"
	item_state = "coil"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	max_amount = MAXCOIL
	amount = MAXCOIL
	merge_type = /obj/item/stack/cable_coil // This is here to let its children merge between themselves
	var/cable_color = "red"
	desc = "A coil of insulated power cable."
	throwforce = 0
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 3
	throw_range = 5
	materials = list(/datum/material/iron=10, /datum/material/glass=5)
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined", "flogged")
	singular_name = "cable piece"
	full_w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/copper = 2) //2 copper per cable in the coil
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/stack/cable_coil/cyborg
	is_cyborg = 1
	materials = list()
	cost = 1

/obj/item/stack/cable_coil/cyborg/attack_self(mob/user)
	var/picked = input(user,"Pick a cable color.","Cable Color") in list("red","yellow","green","blue","pink","orange","cyan","white")
	cable_color = picked
	update_icon()

/obj/item/stack/cable_coil/suicide_act(mob/user)
	if(locate(/obj/structure/chair/stool) in get_turf(user))
		user.visible_message("<span class='suicide'>[user] is making a noose with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	else
		user.visible_message("<span class='suicide'>[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return(OXYLOSS)

/obj/item/stack/cable_coil/get_recipes()
	return GLOB.cable_coil_recipes

/obj/item/stack/cable_coil/Initialize(mapload, new_amount = null, param_color = null)
	. = ..()

	var/list/cable_colors = GLOB.cable_colors
	cable_color = param_color || cable_color || pick(cable_colors)
	if(cable_colors[cable_color])
		cable_color = cable_colors[cable_color]

	pixel_x = base_pixel_x + rand(-2,2)
	pixel_y = base_pixel_y + rand(-2,2)
	update_icon()

///////////////////////////////////
// General procedures
///////////////////////////////////

/obj/item/stack/cable_coil/update_icon()
	icon_state = "[initial(item_state)][amount < 3 ? amount : ""]"
	name = "cable [amount < 3 ? "piece" : "coil"]"
	color = null
	add_atom_colour(cable_color, FIXED_COLOUR_PRIORITY)

/obj/item/stack/cable_coil/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	var/obj/item/stack/cable_coil/new_cable = ..()
	if(istype(new_cable))
		new_cable.cable_color = cable_color
		new_cable.update_icon()

//add cables to the stack
/obj/item/stack/cable_coil/proc/give(extra)
	if(amount + extra > max_amount)
		amount = max_amount
	else
		amount += extra
	update_icon()



///////////////////////////////////////////////
// Cable laying procedures
//////////////////////////////////////////////

/obj/item/stack/cable_coil/proc/get_new_cable(location)
	var/path = /obj/structure/cable
	return new path(location, cable_color)

// called when cable_coil is clicked on a turf
/obj/item/stack/cable_coil/proc/place_turf(turf/T, mob/user, dirnew)
	if(!isturf(user.loc))
		return

	if(!isturf(T) || T.intact || !T.can_have_cabling())
		to_chat(user, "<span class='warning'>You can only lay cables on top of exterior catwalks and plating!</span>")
		return

	if(get_amount() < 1) // Out of cable
		to_chat(user, "<span class='warning'>There is no cable left!</span>")
		return

	if(get_dist(T,user) > 1) // Too far
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return

	var/d2
	if(!dirnew) //If we weren't given a direction, come up with one! (Called as null from catwalk.dm and floor.dm)
		if(user.loc == T)
			d2 = user.dir //If laying on the tile we're on, lay in the direction we're facing
		else
			d2 = get_dir(T, user)
	else
		d2 = dirnew

	var/d1 = 0
	if(istype(T, /turf/open/openspace))
		if(!(get_amount() >= 2))
			to_chat(user, "<span class='warning'>You need at least 2 pieces of cable to wire between decks!</span>")
			return
		d1 = d2 //bigger number goes last for sprite reasons
		d2 = DOWN

	for(var/obj/structure/cable/LC in T)
		if(LC.d2 == d2 && LC.d1 == d1)
			to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
			return

	var/obj/structure/cable/C = place_cable(T, user, d1, d2)
	if(C.shock(user, 50))
		if(prob(50)) //fail
			new /obj/item/stack/cable_coil(get_turf(C), 1, C.color)
			C.deconstruct()
	else if(d2 == DOWN)
		place_cable(T.below(), user, 0, UP)
		to_chat(user, "<span class='notice'>You slide the cable downward.</span>")

	return C

/obj/item/stack/cable_coil/proc/place_cable(turf/open/T, mob/user, d1, d2)
	if(!istype(T))
		return
	var/obj/structure/cable/C = get_new_cable(T)

	//set up the new cable
	C.d1 = d1
	C.d2 = d2
	C.add_fingerprint(user)
	C.update_icon()

	//create a new powernet with the cable, if needed it will be merged later
	var/datum/powernet/PN = new()
	PN.add_cable(C)

	C.mergeConnectedNetworks(C.d1)
	C.mergeConnectedNetworks(C.d2) //merge the powernet with adjacents powernets
	C.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

	if(C.d1 & (C.d1 - 1))// if the cable is layed diagonally, check the others 2 possible directions
		C.mergeDiagonalsNetworks(C.d2)

	if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
		C.mergeDiagonalsNetworks(C.d2)

	use(1)

	return C

// called when cable_coil is click on an installed obj/cable
// or click on a turf that already contains a "node" cable
/obj/item/stack/cable_coil/proc/cable_join(obj/structure/cable/C, mob/user, var/showerror = TRUE, forceddir)
	var/turf/U = user.loc
	if(!isturf(U))
		return

	var/turf/T = C.loc

	if(!isturf(T) || T.intact)		// sanity checks, also stop use interacting with T-scanner revealed cable
		return

	if(get_dist(C, user) > 1)		// make sure it's close enough
		to_chat(user, "<span class='warning'>You can't lay cable at a place that far away!</span>")
		return


	if(U == T && !forceddir) //if clicked on the turf we're standing on and a direction wasn't supplied, try to put a cable in the direction we're facing
		place_turf(T,user)
		return

	var/dirn = get_dir(C, user)
	if(T.allow_z_travel && T.below() && !locate(/obj/structure/lattice/catwalk, T))
		dirn = DOWN
	if(forceddir)
		dirn = forceddir

	// one end of the clicked cable is pointing towards us and no direction was supplied
	if((C.d1 == dirn || C.d2 == dirn) && !forceddir)
		if(!U.can_have_cabling())						//checking if it's a plating or catwalk
			if (showerror)
				to_chat(user, "<span class='warning'>You can only lay cables on catwalks and plating!</span>")
			return
		if(U.intact)						//can't place a cable if it's a plating with a tile on it
			to_chat(user, "<span class='warning'>You can't lay cable there unless the floor tiles are removed!</span>")
			return
		else
			// cable is pointing at us, we're standing on an open tile
			// so create a stub pointing at the clicked cable on our tile

			var/fdirn = dir_inverse_multiz(dirn)		// the opposite direction

			for(var/obj/structure/cable/LC in U)		// check to make sure there's not a cable there already
				if(LC.d1 == fdirn || LC.d2 == fdirn)
					if (showerror)
						to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")
					return

			var/obj/structure/cable/NC = get_new_cable (U)

			NC.d1 = 0
			NC.d2 = fdirn
			NC.add_fingerprint(user)
			NC.update_icon()

			//create a new powernet with the cable, if needed it will be merged later
			var/datum/powernet/newPN = new()
			newPN.add_cable(NC)

			NC.mergeConnectedNetworks(NC.d2) //merge the powernet with adjacents powernets
			NC.mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

			if(NC.d2 & (NC.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
				NC.mergeDiagonalsNetworks(NC.d2)

			use(1)

			if (NC.shock(user, 50))
				if (prob(50)) //fail
					NC.deconstruct()

			return

	// exisiting cable doesn't point at our position or we have a supplied direction, so see if it's a stub
	else if(C.d1 == 0)
							// if so, make it a full cable pointing from it's old direction to our dirn
		var/nd1 = C.d2	// these will be the new directions
		var/nd2 = dirn


		if(nd1 > nd2)		// swap directions to match icons/states
			nd1 = dirn
			nd2 = C.d2


		for(var/obj/structure/cable/LC in T)		// check to make sure there's no matching cable
			if(LC == C)			// skip the cable we're interacting with
				continue
			if((LC.d1 == nd1 && LC.d2 == nd2) || (LC.d1 == nd2 && LC.d2 == nd1) )	// make sure no cable matches either direction
				if (showerror)
					to_chat(user, "<span class='warning'>There's already a cable at that position!</span>")

				return


		C.update_icon()

		C.d1 = nd1
		C.d2 = nd2

		C.add_fingerprint(user)
		C.update_icon()


		C.mergeConnectedNetworks(C.d1) //merge the powernets...
		C.mergeConnectedNetworks(C.d2) //...in the two new cable directions
		C.mergeConnectedNetworksOnTurf()

		if(C.d1 & (C.d1 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d1)

		if(C.d2 & (C.d2 - 1))// if the cable is layed diagonally, check the others 2 possible directions
			C.mergeDiagonalsNetworks(C.d2)

		use(1)

		if (C.shock(user, 50))
			if (prob(50)) //fail
				C.deconstruct()
				return

		C.denode()// this call may have disconnected some cables that terminated on the centre of the turf, if so split the powernets.
		return

//////////////////////////////
// Misc.
/////////////////////////////

/obj/item/stack/cable_coil/red
	cable_color = "red"
	color = "#ff0000"

/obj/item/stack/cable_coil/red/one
	amount = 1

/obj/item/stack/cable_coil/yellow
	cable_color = "yellow"
	color = "#ffff00"

/obj/item/stack/cable_coil/blue
	cable_color = "blue"
	color = "#1919c8"

/obj/item/stack/cable_coil/green
	cable_color = "green"
	color = "#00aa00"

/obj/item/stack/cable_coil/pink
	cable_color = "pink"
	color = "#ff3ccd"

/obj/item/stack/cable_coil/orange
	cable_color = "orange"
	color = "#ff8000"

/obj/item/stack/cable_coil/cyan
	cable_color = "cyan"
	color = "#00ffff"

/obj/item/stack/cable_coil/white
	cable_color = "white"

/obj/item/stack/cable_coil/random
	cable_color = null
	color = "#ffffff"


/obj/item/stack/cable_coil/random/five
	amount = 5

/obj/item/stack/cable_coil/cut
	amount = null
	icon_state = "coil2"

/obj/item/stack/cable_coil/cut/Initialize(mapload)
	. = ..()
	if(!amount)
		amount = rand(1,2)
	pixel_x = rand(-2,2)
	pixel_y = rand(-2,2)
	update_icon()

/obj/item/stack/cable_coil/cut/red
	cable_color = "red"
	color = "#ff0000"

/obj/item/stack/cable_coil/cut/yellow
	cable_color = "yellow"
	color = "#ffff00"

/obj/item/stack/cable_coil/cut/blue
	cable_color = "blue"
	color = "#1919c8"

/obj/item/stack/cable_coil/cut/green
	cable_color = "green"
	color = "#00aa00"

/obj/item/stack/cable_coil/cut/pink
	cable_color = "pink"
	color = "#ff3ccd"

/obj/item/stack/cable_coil/cut/orange
	cable_color = "orange"
	color = "#ff8000"

/obj/item/stack/cable_coil/cut/cyan
	cable_color = "cyan"
	color = "#00ffff"

/obj/item/stack/cable_coil/cut/white
	cable_color = "white"

/obj/item/stack/cable_coil/cut/random
	cable_color = null
	color = "#ffffff"
