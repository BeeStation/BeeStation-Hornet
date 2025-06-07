#define MAX_DENT_DECALS 15

/turf/closed/wall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WALLS)
		//note consider "canSmoothWith = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_AIRLOCK)" if the artstyle permits it!
	rcd_memory = RCD_MEMORY_WALL
	explosion_block = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 62500 //a little over 5 cm thick , 62500 for 1 m by 2.5 m by 0.25 m iron wall. also indicates the temperature at wich the wall will melt (currently only able to melt with H/E pipes)

	baseturfs = /turf/open/floor/plating

	flags_ricochet = RICOCHET_HARD

	FASTDMM_PROP(\
		pipe_astar_cost = 35\
	)

	var/hardness = 40 //lower numbers are harder. Used to determine the probability of a hulk smashing through.
	var/slicing_duration = 100  //default time taken to slice the wall
	var/sheet_type = /obj/item/stack/sheet/iron
	var/sheet_amount = 2
	var/girder_type = /obj/structure/girder
	var/list/dent_decals
	/// If we added a leaning component to ourselves
	var/added_leaning = FALSE

/turf/closed/wall/Initialize(mapload)
	. = ..()
	if(is_station_level(z))
		GLOB.station_turfs += src
	if(smoothing_flags & SMOOTH_DIAGONAL_CORNERS && fixed_underlay) //Set underlays for the diagonal walls.
		var/mutable_appearance/underlay_appearance = mutable_appearance(layer = TURF_LAYER, plane = FLOOR_PLANE)
		if(fixed_underlay["space"])
			underlay_appearance.icon = 'icons/turf/space.dmi'
			underlay_appearance.icon_state = SPACE_ICON_STATE
			underlay_appearance.plane = PLANE_SPACE
		else
			underlay_appearance.icon = fixed_underlay["icon"]
			underlay_appearance.icon_state = fixed_underlay["icon_state"]
		underlays += underlay_appearance

/turf/closed/wall/MouseDrop_T(atom/dropping, mob/user, params)
	//Adds the component only once. We do it here & not in Initialize() because there are tons of walls & we don't want to add to their init times
	LoadComponent(/datum/component/leanable, dropping)

/turf/closed/wall/atom_destruction(damage_flag)
	. = ..()
	dismantle_wall(TRUE, FALSE)

/turf/closed/wall/Destroy()
	if(is_station_level(z))
		GLOB.station_turfs -= src
	return ..()

/turf/closed/wall/examine(mob/user)
	. += ..()
	. += deconstruction_hints(user)

/turf/closed/wall/proc/deconstruction_hints(mob/user)
	return span_notice("The outer plating is <b>welded</b> firmly in place.")

/turf/closed/wall/attack_tk()
	return

/turf/closed/wall/turf_destruction(damage_flag, additional_damage)
	var/previous_type = type
	dismantle_wall(prob((additional_damage - 50) / 3), TRUE)
	// If we scrape away into a turf of the same type, don't go any deeper.
	if (type == previous_type)
		return
	// Cascade turf damage downwards on destruction
	if (additional_damage > 0)
		take_damage(additional_damage, BRUTE, damage_flag, FALSE)

/turf/closed/wall/proc/dismantle_wall(devastated=0, explode=0)
	if(devastated)
		devastate_wall()
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		var/newgirder = break_wall()
		if(newgirder) //maybe we don't /want/ a girder!
			transfer_fingerprints_to(newgirder)

	for(var/obj/O in src.contents) //Eject contents!
		if(istype(O, /obj/structure/sign/poster))
			var/obj/structure/sign/poster/P = O
			P.roll_and_drop(src)

	ScrapeAway()

/turf/closed/wall/proc/break_wall()
	new sheet_type(src, sheet_amount)
	if(girder_type)
		return new girder_type(src)

/turf/closed/wall/proc/devastate_wall()
	new sheet_type(src, sheet_amount)
	if(girder_type)
		new /obj/item/stack/sheet/iron(src)

/turf/closed/wall/after_damage(damage_amount, damage_type, damage_flag)
	if (damage_flag == MELEE)
		add_dent(WALL_DENT_HIT)

/turf/closed/wall/attack_paw(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	return attack_hand(user)

/turf/closed/wall/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	to_chat(user, span_notice("You push the wall but nothing happens!"))
	playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
	add_fingerprint(user)

/turf/closed/wall/try_clean(obj/item/W, mob/living/user, turf/T)
	if((user.combat_mode) || !LAZYLEN(dent_decals))
		return FALSE

	if(W.tool_behaviour == TOOL_WELDER)
		if(!W.tool_start_check(user, amount=0))
			return FALSE

		balloon_alert(user, "You begin fixing the dents on the wall...")
		if(W.use_tool(src, user, 0, volume=100))
			if(iswallturf(src) && LAZYLEN(dent_decals))
				balloon_alert(user, "You fix some dents on the wall.")
				cut_overlay(dent_decals)
				dent_decals.Cut()
			integrity = max_integrity
			return TRUE

	return FALSE

/turf/closed/wall/try_wallmount(obj/item/W, mob/user, turf/T)
	//check for wall mounted frames
	if(istype(W, /obj/item/wallframe))
		var/obj/item/wallframe/F = W
		if(F.try_build(src, user))
			F.attach(src, user)
			return TRUE
		return FALSE
	//Poster stuff
	else if(istype(W, /obj/item/poster) && Adjacent(user)) //no tk memes.
		return place_poster(W,user)

	return FALSE

/turf/closed/wall/try_decon(obj/item/I, mob/user, turf/T)
	if(I.tool_behaviour == TOOL_WELDER)
		if(!I.tool_start_check(user, amount=0))
			return FALSE

		balloon_alert(user, "You start slicing through the outer plating.")
		if(I.use_tool(src, user, slicing_duration, volume=100))
			if(iswallturf(src))
				balloon_alert(user, "You remove the outer plating.")
				dismantle_wall()
			return TRUE

	return FALSE

/turf/closed/wall/try_destroy(obj/item/I, mob/user, turf/T)
	if(istype(I, /obj/item/pickaxe/drill/jackhammer))
		if(!iswallturf(src))
			return TRUE
		if(user.loc == T)
			I.play_tool_sound(src)
			dismantle_wall()
			user.visible_message(span_warning("[user] smashes through [src] with [I]!"), \
								span_warning("You smash through [src] with [I]!"), \
								span_italics("You hear the grinding of metal."))
			return TRUE
	return FALSE

/turf/closed/wall/singularity_pull(S, current_size)
	..()
	wall_singularity_pull(current_size)

/turf/closed/wall/proc/wall_singularity_pull(current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(50))
			dismantle_wall()
		return
	if(current_size == STAGE_FOUR)
		if(prob(30))
			dismantle_wall()

/turf/closed/wall/narsie_act(force, ignore_mobs, probability = 20)
	. = ..()
	if(.)
		ChangeTurf(/turf/closed/wall/mineral/cult)

/turf/closed/wall/ratvar_act(force, ignore_mobs)
	. = ..()
	if(.)
		ChangeTurf(/turf/closed/wall/clockwork)

/turf/closed/wall/get_dumping_location(obj/item/storage/source, mob/user)
	return null

/turf/closed/wall/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 40, "cost" = 26)
	return FALSE

/turf/closed/wall/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_DECONSTRUCT)
		to_chat(user, span_notice("You deconstruct the wall."))
		log_attack("[key_name(user)] has deconstructed [get_turf(src)] at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
		ScrapeAway()
		return TRUE
	return FALSE

/turf/closed/wall/proc/add_dent(denttype, x=rand(-8, 8), y=rand(-8, 8))
	if(LAZYLEN(dent_decals) >= MAX_DENT_DECALS)
		return

	var/mutable_appearance/decal = mutable_appearance('icons/effects/effects.dmi', "", BULLET_HOLE_LAYER)
	switch(denttype)
		if(WALL_DENT_SHOT)
			decal.icon_state = "bullet_hole"
		if(WALL_DENT_HIT)
			decal.icon_state = "impact[rand(1, 3)]"

	decal.pixel_x = x
	decal.pixel_y = y

	if(LAZYLEN(dent_decals))
		cut_overlay(dent_decals)
		dent_decals += decal
	else
		dent_decals = list(decal)

	add_overlay(dent_decals)

/turf/closed/wall/rust_heretic_act()
	if(HAS_TRAIT(src, TRAIT_RUSTY))
		ScrapeAway()
		return TRUE
	if(prob(70))
		new /obj/effect/temp_visual/glowing_rune(src)
	return ..()

#undef MAX_DENT_DECALS
