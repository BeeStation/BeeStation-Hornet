/turf/closed/wall/r_wall
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "reinforced_wall-0"
	base_icon_state = "reinforced_wall"
	smoothing_flags = SMOOTH_BITMASK
	opacity = 1
	density = TRUE

	var/d_state = INTACT
	hardness = 10
	sheet_type = /obj/item/stack/sheet/plasteel
	sheet_amount = 1
	girder_type = /obj/structure/girder/reinforced
	explosion_block = 2
	rad_insulation = RAD_HEAVY_INSULATION
	FASTDMM_PROP(\
		pipe_astar_cost = 50 \
	)

/turf/closed/wall/r_wall/deconstruction_hints(mob/user)
	switch(d_state)
		if(INTACT)
			return "<span class='notice'>The outer <b>grille</b> is fully intact.</span>"
		if(SUPPORT_LINES)
			return "<span class='notice'>The outer <i>grille</i> has been cut, and the support lines are <b>screwed</b> securely to the outer cover.</span>"
		if(COVER)
			return "<span class='notice'>The support lines have been <i>unscrewed</i>, and the metal cover is <b>welded</b> firmly in place.</span>"
		if(CUT_COVER)
			return "<span class='notice'>The metal cover has been <i>sliced through</i>, and is <b>connected loosely</b> to the girder.</span>"
		if(ANCHOR_BOLTS)
			return "<span class='notice'>The outer cover has been <i>pried away</i>, and the bolts anchoring the support rods are <b>wrenched</b> in place.</span>"
		if(SUPPORT_RODS)
			return "<span class='notice'>The bolts anchoring the support rods have been <i>loosened</i>, but are still <b>welded</b> firmly to the girder.</span>"
		if(SHEATH)
			return "<span class='notice'>The support rods have been <i>sliced through</i>, and the outer sheath is <b>connected loosely</b> to the girder.</span>"

/turf/closed/wall/r_wall/devastate_wall()
	new sheet_type(src, sheet_amount)
	new /obj/item/stack/sheet/iron(src, 2)

/turf/closed/wall/r_wall/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if(!M.environment_smash)
		return
	if(M.environment_smash & ENVIRONMENT_SMASH_RWALLS)
		dismantle_wall(1)
		playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1)
	else
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		to_chat(M, "<span class='warning'>This wall is far too strong for you to destroy.</span>")

/turf/closed/wall/r_wall/try_destroy(obj/item/I, mob/user, turf/T)
	return FALSE

/turf/closed/wall/r_wall/try_decon(obj/item/W, mob/user, turf/T)
	//DECONSTRUCTION
	switch(d_state)
		if(INTACT)
			if(W.tool_behaviour == TOOL_WIRECUTTER)
				W.play_tool_sound(src, 100)
				d_state = SUPPORT_LINES
				update_icon()
				balloon_alert(user, "You cut the outer grille.")
				return TRUE

		if(SUPPORT_LINES)
			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				balloon_alert(user, "You begin unsecuring the support lines...")
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SUPPORT_LINES)
						return TRUE
					d_state = COVER
					update_icon()
					balloon_alert(user, "You unsecure the support lines.")
				return TRUE

			else if(W.tool_behaviour == TOOL_WIRECUTTER)
				W.play_tool_sound(src, 100)
				d_state = INTACT
				update_icon()
				balloon_alert(user, "You repair the outer grille.")
				return TRUE

		if(COVER)
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				balloon_alert(user, "You begin slicing through the metal cover...")
				if(W.use_tool(src, user, 60, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != COVER)
						return TRUE
					d_state = CUT_COVER
					update_icon()
					balloon_alert(user, "You remove the metal cover.")
				return TRUE

			if(W.tool_behaviour == TOOL_SCREWDRIVER)
				balloon_alert(user, "You begin securing the support lines...")
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != COVER)
						return TRUE
					d_state = SUPPORT_LINES
					update_icon()
					balloon_alert(user, "You secure the support lines.")
				return TRUE

		if(CUT_COVER)
			if(W.tool_behaviour == TOOL_CROWBAR)
				balloon_alert(user, "You struggle to pry off the cover...")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != CUT_COVER)
						return TRUE
					d_state = ANCHOR_BOLTS
					update_icon()
					balloon_alert(user, "You pry the cover off.")
				return TRUE

			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				balloon_alert(user, "You begin welding the metal cover back to the frame...")
				if(W.use_tool(src, user, 60, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != CUT_COVER)
						return TRUE
					d_state = COVER
					update_icon()
					balloon_alert(user, "You welded the metal cover to the frame.")
				return TRUE

		if(ANCHOR_BOLTS)
			if(W.tool_behaviour == TOOL_WRENCH)
				balloon_alert(user, "You start loosening the anchoring bolts which secure the support rods to their frame...")
				if(W.use_tool(src, user, 40, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != ANCHOR_BOLTS)
						return TRUE
					d_state = SUPPORT_RODS
					update_icon()
					balloon_alert(user, "You remove the bolts.")
				return TRUE

			if(W.tool_behaviour == TOOL_CROWBAR)
				balloon_alert(user, "You start to pry the cover back into place...")
				if(W.use_tool(src, user, 20, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != ANCHOR_BOLTS)
						return TRUE
					d_state = CUT_COVER
					update_icon()
					balloon_alert(user, "You pry the metal cover back in place.")
				return TRUE

		if(SUPPORT_RODS)
			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				balloon_alert(user, "You start slicing through the support rods...")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SUPPORT_RODS)
						return TRUE
					d_state = SHEATH
					update_icon()
					balloon_alert(user, "You have sliced through the support rods.")
				return TRUE

			if(W.tool_behaviour == TOOL_WRENCH)
				balloon_alert(user, "You start tightening the bolts securing the support rods...")
				W.play_tool_sound(src, 100)
				if(W.use_tool(src, user, 40))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SUPPORT_RODS)
						return TRUE
					d_state = ANCHOR_BOLTS
					update_icon()
					balloon_alert(user, "You tighten the bolts.")
				return TRUE

		if(SHEATH)
			if(W.tool_behaviour == TOOL_CROWBAR)
				balloon_alert(user, "You start prying off the outer sheath...")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SHEATH)
						return TRUE
					balloon_alert(user, "You pried the outer sheath off.")
					dismantle_wall()
				return TRUE

			if(W.tool_behaviour == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return
				balloon_alert(user, "You start welding the support rods back together...")
				if(W.use_tool(src, user, 100, volume=100))
					if(!istype(src, /turf/closed/wall/r_wall) || d_state != SHEATH)
						return TRUE
					d_state = SUPPORT_RODS
					update_icon()
					balloon_alert(user, "You weld the support rods back together.")
				return TRUE
	return FALSE

/turf/closed/wall/r_wall/update_icon(updates=ALL)
	. = ..()
	if(d_state != INTACT)
		icon_state = "r_wall-[d_state]"
		smoothing_flags = NONE
		return
	if (!(updates & UPDATE_SMOOTHING))
		return
	smoothing_flags = SMOOTH_BITMASK
	icon_state = "[base_icon_state]-[smoothing_junction]"
	QUEUE_SMOOTH_NEIGHBORS(src)
	QUEUE_SMOOTH(src)

/turf/closed/wall/r_wall/update_icon_state()
	if(d_state != INTACT)
		icon_state = "r_wall-[d_state]"
	else
		icon_state = "r_wall"
	return ..()

/turf/closed/wall/r_wall/wall_singularity_pull(current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(30))
			dismantle_wall()

/turf/closed/wall/r_wall/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.canRturf)
		return ..()


/turf/closed/wall/r_wall/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(the_rcd.canRturf)
		return ..()

/turf/closed/wall/r_wall/rust_heretic_act()
	if(prob(50))
		return
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ScrapeAway()
		return TRUE
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	return ..()

/turf/closed/wall/r_wall/syndicate
	name = "hull"
	desc = "The armored hull of an ominous looking ship."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_SYNDICATE_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_SYNDICATE_WALLS, SMOOTH_GROUP_PLASTITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_SHUTTLE_PARTS)
	explosion_block = 20
	sheet_type = /obj/item/stack/sheet/mineral/plastitanium

/turf/closed/wall/r_wall/syndicate/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE

/turf/closed/wall/r_wall/syndicate/nodiagonal
	smoothing_flags = SMOOTH_BITMASK
	icon_state = "map-shuttle_nd"

/turf/closed/wall/r_wall/syndicate/nosmooth
	smoothing_flags = NONE
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"

/turf/closed/wall/r_wall/syndicate/overspace
	icon_state = "map-overspace"
	fixed_underlay = list("space"=1)


