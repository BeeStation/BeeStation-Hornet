/obj/structure/girder
	name = "girder"
	desc = "A large structural frame made out of iron; It requires a layer of materials before it can be considered a wall."
	icon = 'icons/obj/smooth_structures/girders/girder.dmi'
	icon_state = "girder-0"
	anchored = TRUE
	density = TRUE
	z_flags = Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP
	layer = BELOW_OBJ_LAYER
	max_integrity = 200
	rad_flags = RAD_PROTECT_CONTENTS | RAD_NO_CONTAMINATE
	rad_insulation = RAD_VERY_LIGHT_INSULATION
	base_icon_state = "girder"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_GIRDER)
	canSmoothWith = list(SMOOTH_GROUP_GIRDER)
	var/state = GIRDER_NORMAL
	var/girderpasschance = 20 // percentage chance that a projectile passes through the girder.
	var/can_displace = TRUE //If the girder can be moved around by wrenching it
	var/next_beep = 0 //Prevents spamming of the construction sound
	/// The material cost to construct something on the girder
	var/static/list/construction_cost = list(
		/obj/item/stack/sheet/iron = 2,
		/obj/item/stack/rods = 5,
		/obj/item/stack/sheet/plasteel = 2,
		/obj/item/stack/sheet/bronze = 2,
		/obj/item/stack/sheet/runed_metal = 1,
		/obj/item/stack/sheet/titaniumglass = 2,
		exotic_material = 2 // this needs to be refactored properly
	)

/obj/structure/girder/examine(mob/user)
	. = ..()
	switch(state)
		if(GIRDER_REINF)
			. += span_notice("The support struts are <b>screwed</b> in place.")
		if(GIRDER_REINF_STRUTS)
			. += span_notice("The support struts are <i>unscrewed</i> and the inner <b>grille</b> is intact.")
		if(GIRDER_NORMAL)
			if(can_displace)
				. += span_notice("The bolts are <b>wrenched</b> in place.")
		if(GIRDER_DISPLACED)
			. += span_notice("The bolts are <i>loosened</i>, but the <b>screws</b> are holding [src] together.")
		if(GIRDER_DISASSEMBLED)
			. += span_notice("[src] is disassembled! You probably shouldn't be able to see this examine message.")

/obj/structure/girder/attackby(obj/item/W, mob/user, params)
	var/platingmodifier = 1
	if(HAS_TRAIT(user, TRAIT_QUICK_BUILD))
		platingmodifier = 0.7
		if(next_beep <= world.time)
			next_beep = world.time + 10
			playsound(src, 'sound/machines/clockcult/integration_cog_install.ogg', 50, TRUE)
	add_fingerprint(user)

	if(istype(W, /obj/item/gun/energy/plasmacutter))
		balloon_alert(user, "slicing apart...")
		if(W.use_tool(src, user, 40, volume=100))
			var/obj/item/stack/sheet/iron/M = new (loc, 2)
			if(!QDELETED(M))
				M.add_fingerprint(user)
			qdel(src)
			return

	else if(istype(W, /obj/item/pickaxe/drill/jackhammer))
		to_chat(user, span_notice("You smash through [src]!"))
		new /obj/item/stack/sheet/iron(get_turf(src))
		W.play_tool_sound(src)
		qdel(src)


	else if(isstack(W))
		if(iswallturf(loc) || (locate(/obj/structure/falsewall) in src.loc.contents))
			balloon_alert(user, "wall already present!")
			return
		if(!isfloorturf(loc))
			balloon_alert(user, "need floor!")
			return

		if(istype(W, /obj/item/stack/rods))
			var/obj/item/stack/rods/S = W
			var/amount = construction_cost[S.type]
			if(state == GIRDER_DISPLACED)
				if(S.get_amount() < amount)
					balloon_alert(user, "need [amount] rods!")
					return
				balloon_alert(user, "concealing entrance...")
				if(do_after(user, 20, target = src))
					if(S.get_amount() < amount)
						return
					S.use(amount)
					var/obj/structure/falsewall/iron/FW = new (loc)
					transfer_fingerprints_to(FW)
					qdel(src)
					return
			else
				if(S.get_amount() < amount)
					balloon_alert(user, "need [amount] rods!")
					return
				balloon_alert(user, "adding plating...")
				if(do_after(user, 40, target = src))
					if(S.get_amount() < amount)
						return
					S.use(amount)
					var/turf/T = get_turf(src)
					T.PlaceOnTop(/turf/closed/wall/mineral/iron)
					transfer_fingerprints_to(T)
					qdel(src)
				return

		if(!istype(W, /obj/item/stack/sheet))
			return

		var/obj/item/stack/sheet/sheets = W
		if(istype(sheets, /obj/item/stack/sheet/iron))
			var/amount = construction_cost[/obj/item/stack/sheet/iron]
			if(state == GIRDER_DISPLACED)
				if(sheets.get_amount() < amount)
					balloon_alert(user, "need [amount] sheets!")
					return
				balloon_alert(user, "concealing entrance...")
				if(do_after(user, 20*platingmodifier, target = src))
					if(sheets.get_amount() < amount)
						return
					sheets.use(amount)
					var/obj/structure/falsewall/F = new (loc)
					transfer_fingerprints_to(F)
					qdel(src)
					return
			else if(state == GIRDER_REINF)
				balloon_alert(user, "need plasteel sheet!")
				return
			else
				if(sheets.get_amount() < amount)
					balloon_alert(user, "need [amount] sheets!")
					return
				balloon_alert(user, "adding plating...")
				if (do_after(user, 40*platingmodifier, target = src))
					if(sheets.get_amount() < amount)
						return
					sheets.use(amount)
					var/turf/T = get_turf(src)
					T.PlaceOnTop(/turf/closed/wall)
					transfer_fingerprints_to(T)
					qdel(src)
				return

		if(istype(sheets, /obj/item/stack/sheet/plasteel))
			var/amount = construction_cost[/obj/item/stack/sheet/plasteel]
			if(state == GIRDER_DISPLACED)
				if(sheets.get_amount() < amount)
					balloon_alert(user, "need [amount] sheets!")
					return
				balloon_alert(user, "concealing entrance...")
				if(do_after(user, 20, target = src))
					if(sheets.get_amount() < amount)
						return
					sheets.use(amount)
					var/obj/structure/falsewall/reinforced/FW = new (loc)
					transfer_fingerprints_to(FW)
					qdel(src)
					return
			else if(state == GIRDER_REINF)
				amount = 1 // hur dur let's make plasteel have different construction amounts 4norasin
				if(sheets.get_amount() < amount)
					return
				balloon_alert(user, "adding plating...")
				if(do_after(user, 50*platingmodifier, target = src))
					if(sheets.get_amount() < amount)
						return
					sheets.use(amount)
					var/turf/T = get_turf(src)
					T.PlaceOnTop(/turf/closed/wall/r_wall)
					transfer_fingerprints_to(T)
					qdel(src)
				return
			else
				amount = 1 // hur dur x2
				if(sheets.get_amount() < amount)
					return
				balloon_alert(user, "reinforcing frame...")
				if(do_after(user, 60*platingmodifier, target = src))
					if(sheets.get_amount() < amount)
						return
					sheets.use(amount)
					var/obj/structure/girder/reinforced/R = new (loc)
					transfer_fingerprints_to(R)
					qdel(src)
				return

		if(!sheets.has_unique_girder && sheets.material_type)
			if(istype(src, /obj/structure/girder/reinforced))
				balloon_alert(user, "need plasteel!")
				return

			var/M = sheets.sheettype
			var/amount = construction_cost["exotic_material"]
			if(state == GIRDER_DISPLACED)
				var/falsewall_type = text2path("/obj/structure/falsewall/[M]")
				if(sheets.get_amount() < amount)
					balloon_alert(user, "need [amount] sheets!")
					return
				balloon_alert(user, "concealing entrance...")
				if(do_after(user, 2 SECONDS, target = src))
					if(sheets.get_amount() < amount)
						return
					sheets.use(amount)
					var/obj/structure/falsewall/falsewall
					if(falsewall_type)
						falsewall = new falsewall_type (loc)
					transfer_fingerprints_to(falsewall)
					qdel(src)
					return
			else
				if(sheets.get_amount() < amount)
					balloon_alert(user, "need [amount] sheets!")
					return
				balloon_alert(user, "adding plating...")
				if (do_after(user, 4 SECONDS, target = src))
					if(sheets.get_amount() < amount)
						return
					sheets.use(amount)
					var/turf/T = get_turf(src)
					if(sheets.walltype)
						T.PlaceOnTop(sheets.walltype)
					else
						var/turf/newturf = T.PlaceOnTop(/turf/closed/wall/material)
						var/list/material_list = list()
						material_list[SSmaterials.GetMaterialRef(sheets.material_type)] = MINERAL_MATERIAL_AMOUNT * 2
						if(material_list)
							newturf.set_custom_materials(material_list)

					transfer_fingerprints_to(T)
					qdel(src)
				return

		add_hiddenprint(user)

	else if(istype(W, /obj/item/pipe))
		var/obj/item/pipe/P = W
		if(P.pipe_type in list(0, 1, 5))	//simple pipes, simple bends, and simple manifolds.
			if(!user.transferItemToLoc(P, drop_location()))
				return
			balloon_alert(user, "inserted pipe")
	else
		return ..()

// Screwdriver behavior for girders
/obj/structure/girder/screwdriver_act(mob/user, obj/item/tool)
	if(..())
		return TRUE

	. = FALSE
	if(state == GIRDER_DISPLACED)
		balloon_alert(user, "disassembling frame...")
		if(tool.use_tool(src, user, 40, volume=100))
			if(state != GIRDER_DISPLACED)
				return
			state = GIRDER_DISASSEMBLED
			new /obj/item/stack/sheet/iron(loc, 2, TRUE, user)
			qdel(src)
		return TRUE

	else if(state == GIRDER_REINF)
		balloon_alert(user, "unsecuring support struts...")
		if(tool.use_tool(src, user, 40, volume=100))
			if(state != GIRDER_REINF)
				return
			state = GIRDER_REINF_STRUTS
		return TRUE

	else if(state == GIRDER_REINF_STRUTS)
		balloon_alert(user, "securing support struts...")
		if(tool.use_tool(src, user, 40, volume=100))
			if(state != GIRDER_REINF_STRUTS)
				return
			state = GIRDER_REINF
		return TRUE

// Wirecutter behavior for girders
/obj/structure/girder/wirecutter_act(mob/user, obj/item/tool)
	. = FALSE
	if(state == GIRDER_REINF_STRUTS)
		balloon_alert(user, "removing inner grille...")
		if(tool.use_tool(src, user, 40, volume=100))
			new /obj/item/stack/sheet/plasteel(get_turf(src))
			var/obj/structure/girder/G = new (loc)
			transfer_fingerprints_to(G)
			qdel(src)
		return TRUE

/obj/structure/girder/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	if(state == GIRDER_DISPLACED)
		if(!isfloorturf(loc))
			balloon_alert(user, "needs floor!")

		balloon_alert(user, "securing frame...")
		if(tool.use_tool(src, user, 40, volume=100))
			var/obj/structure/girder/G = new (loc)
			transfer_fingerprints_to(G)
			qdel(src)
		return TRUE
	else if(state == GIRDER_NORMAL && can_displace)
		balloon_alert(user, "unsecuring frame...")
		if(tool.use_tool(src, user, 40, volume=100))
			var/obj/structure/girder/displaced/D = new (loc)
			transfer_fingerprints_to(D)
			qdel(src)
		return TRUE

/obj/structure/girder/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if((mover.pass_flags & PASSGRILLE) || isprojectile(mover))
		return prob(girderpasschance)

/obj/structure/girder/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/passing_atom)
	. = !density
	if(istype(passing_atom))
		. = . || (passing_atom.pass_flags & PASSGRILLE)

/obj/structure/girder/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/remains = pick(/obj/item/stack/rods, /obj/item/stack/sheet/iron)
		new remains(loc)
	qdel(src)

/obj/structure/girder/narsie_act()
	new /obj/structure/girder/cult(loc)
	qdel(src)

/obj/structure/girder/ratvar_act()
	new /obj/structure/girder/bronze(loc)
	qdel(src)

// Displaced girder
/obj/structure/girder/displaced
	name = "displaced girder"
	desc = "A large structural frame made out of iron; It requires a layer of materials before it can be considered a wall. This one has unachored from the ground."
	icon = 'icons/obj/structures.dmi'
	icon_state = "displaced_girder"
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	anchored = FALSE
	state = GIRDER_DISPLACED
	girderpasschance = 25
	max_integrity = 120

// Reinforced girder
/obj/structure/girder/reinforced
	name = "reinforced girder"
	desc = "A large structural frame made out of iron; This one has been reinforced and It requires a layer of plasteel before it can be considered a reinforced wall."
	icon = 'icons/obj/smooth_structures/girders/reinforced_girder.dmi'
	icon_state = "reinforced_girder-0"
	base_icon_state = "reinforced_girder"
	state = GIRDER_REINF
	girderpasschance = 0
	max_integrity = 350

//////////////////////////////////////////// cult girders //////////////////////////////////////////////
///they will get a proper smoothing icon later :D, but not today, courier pigeon's word! 4/09/24
/obj/structure/girder/cult
	name = "runed girder"
	desc = "Framework made of a strange and shockingly cold metal. It doesn't seem to have any bolts."
	icon = 'icons/obj/structures.dmi'
	icon_state = "bloodcult_girder"
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_displace = FALSE

/obj/structure/girder/cult/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(W.tool_behaviour == TOOL_WELDER)
		if(!W.tool_start_check(user, amount=0))
			return

		balloon_alert(user, "You start slicing apart [src]...")
		if(W.use_tool(src, user, 40, volume=50))
			balloon_alert(user, "You slice [src] apart.")
			var/drop_loc = drop_location()
			var/obj/item/stack/sheet/runed_metal/R = new(drop_loc, 1)
			if(QDELETED(R))
				R = locate(/obj/item/stack/sheet/runed_metal) in drop_loc
			if(R)
				transfer_fingerprints_to(R)
			qdel(src)

	else if(istype(W, /obj/item/pickaxe/drill/jackhammer))
		to_chat(user, span_notice("Your jackhammer smashes through [src]!"))
		var/drop_loc = drop_location()
		var/obj/item/stack/sheet/runed_metal/R = new(drop_loc, 2)
		if(QDELETED(R))
			R = locate(/obj/item/stack/sheet/runed_metal) in drop_loc
		if(R)
			transfer_fingerprints_to(R)
		W.play_tool_sound(src)
		qdel(src)

	else if(istype(W, /obj/item/stack/sheet/runed_metal))
		var/obj/item/stack/sheet/runed_metal/R = W
		if(R.get_amount() < 1)
			to_chat(user, span_warning("You need at least one sheet of runed metal to construct a runed wall!"))
			return 0
		user.visible_message(span_notice("[user] begins laying runed metal on [src]..."), span_notice("You begin constructing a runed wall..."))
		if(do_after(user, 50, target = src))
			if(R.get_amount() < 1)
				return
			user.visible_message(span_notice("[user] plates [src] with runed metal."), span_notice("You construct a runed wall."))
			R.use(1)
			var/turf/T = get_turf(src)
			T.PlaceOnTop(/turf/closed/wall/mineral/cult)
			qdel(src)

	else
		return ..()

/obj/structure/girder/cult/narsie_act()
	return

/obj/structure/girder/cult/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/runed_metal(drop_location(), 1)
	qdel(src)

/obj/structure/girder/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			return rcd_result_with_memory(
				list("mode" = RCD_FLOORWALL, "delay" = 2 SECONDS, "cost" = 8),
				get_turf(src), RCD_MEMORY_WALL,
			)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 13)
	return FALSE

/obj/structure/girder/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	var/turf/T = get_turf(src)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			balloon_alert(user, "You finish the wall.")
			log_attack("[key_name(user)] has constructed a wall at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
			var/overlapping_lattice = locate(/obj/structure/lattice) in get_turf(src)
			if(overlapping_lattice)
				qdel(overlapping_lattice) // Don't need lattice burried under the wall, or in the case of catwalk - on top of it.
			T.PlaceOnTop(/turf/closed/wall)
			qdel(src)
			return TRUE
		if(RCD_DECONSTRUCT)
			balloon_alert(user, "You deconstruct [src].")
			log_attack("[key_name(user)] has deconstructed [src] at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/girder/bronze
	name = "wall gear"
	desc = "A girder made out of sturdy bronze, made to resemble a gear."
	icon = 'icons/obj/structures.dmi'
	icon_state = "clockcult_girder"
	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_displace = FALSE

/*
/obj/structure/girder/bronze/attackby(obj/item/W, mob/living/user, params)
	add_fingerprint(user)

	if(W.tool_behaviour == TOOL_WELDER)
		if(!W.tool_start_check(user, amount = 0))
			return
		balloon_alert(user, "slicing apart...")
		if(W.use_tool(src, user, 40, volume=50))
			var/drop_loc = drop_location()
			var/obj/item/stack/sheet/bronze/B = new(drop_loc, 2)
			if(QDELETED(B))
				B = locate(/obj/item/stack/sheet/bronze) in drop_loc
			if(B)
				transfer_fingerprints_to(B)
			qdel(src)

	else if(istype(W, /obj/item/pickaxe/drill/jackhammer))
		to_chat(user, span_notice("Your jackhammer smashes through [src]!"))
		var/drop_loc = drop_location()
		var/obj/item/stack/sheet/bronze/B = new(drop_loc, 2)
		if(QDELETED(B))
			B = locate(/obj/item/stack/sheet/bronze) in drop_loc
		if(B)
			transfer_fingerprints_to(B)
		W.play_tool_sound(src)
		qdel(src)

	else if(istype(W, /obj/item/stack/sheet/bronze))
		var/obj/item/stack/sheet/bronze/B = W
		if(B.get_amount() < 2)
			to_chat(user, span_warning("You need at least two bronze sheets to build a bronze wall!"))
			return FALSE
		user.visible_message(span_notice("[user] begins plating [src] with bronze..."), span_notice("You begin constructing a bronze wall..."))
		if(do_after(user, 50, target = src))
			if(B.get_amount() < 2)
				return
			user.visible_message(span_notice("[user] plates [src] with bronze!"), span_notice("You construct a bronze wall."))
			B.use(2)
			var/turf/T = get_turf(src)
			T.PlaceOnTop(/turf/closed/wall/mineral/bronze)
			qdel(src)

	else
		return ..()
*/

/obj/structure/girder/ratvar_act()
	return
