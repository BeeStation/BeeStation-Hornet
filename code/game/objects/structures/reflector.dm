/obj/structure/reflector
	name = "reflector base"
	icon = 'icons/obj/structures.dmi'
	icon_state = "reflector_map"
	desc = "A base for reflector assemblies."
	anchored = FALSE
	density = FALSE
	var/deflector_icon_state
	var/image/deflector_overlay
	var/finished = FALSE
	var/admin = FALSE //Can't be rotated or deconstructed
	var/can_rotate = TRUE
	var/framebuildstacktype = /obj/item/stack/sheet/iron
	var/framebuildstackamount = 5
	var/buildstacktype = /obj/item/stack/sheet/iron
	var/buildstackamount = 0
	var/list/allowed_projectile_typecache = list(/obj/projectile/beam)
	var/rotation_angle = -1

/obj/structure/reflector/Initialize(mapload)
	. = ..()
	icon_state = "reflector_base"
	allowed_projectile_typecache = typecacheof(allowed_projectile_typecache)
	if(deflector_icon_state)
		deflector_overlay = image(icon, deflector_icon_state)
		add_overlay(deflector_overlay)

	if(rotation_angle == -1)
		set_angle(dir2angle(dir))
	else
		set_angle(rotation_angle)

	if(admin)
		can_rotate = FALSE

/obj/structure/reflector/examine(mob/user)
	. = ..()
	if(finished)
		. += "It is set to [rotation_angle] degrees, and the rotation is [can_rotate ? "unlocked" : "locked"]."
		if(!admin)
			if(can_rotate)
				. += span_notice("Use your <b>hand</b> to adjust its direction.")
				. += span_notice("Use a <b>screwdriver</b> to lock the rotation.")
			else
				. += span_notice("Use <b>screwdriver</b> to unlock the rotation.")

/obj/structure/reflector/proc/set_angle(new_angle, force_rotate = FALSE)
	if(can_rotate || force_rotate)
		rotation_angle = new_angle
		if(deflector_overlay)
			cut_overlay(deflector_overlay)
			deflector_overlay.transform = turn(matrix(), new_angle)
			add_overlay(deflector_overlay)

/obj/structure/reflector/shuttleRotate(rotation, params=ROTATE_DIR|ROTATE_SMOOTH|ROTATE_OFFSET)
	. = ..()
	if(params & ROTATE_DIR)
		set_angle(rotation_angle + rotation, TRUE)

/obj/structure/reflector/setDir(new_dir)
	return ..(NORTH)

/obj/structure/reflector/proc/dir_map_to_angle(dir)
	return 0

/obj/structure/reflector/bullet_act(obj/projectile/P)
	var/pdir = P.dir
	var/pangle = P.Angle
	var/ploc = get_turf(P)
	if(!finished || !allowed_projectile_typecache[P.type] || !(P.dir in GLOB.cardinals))
		return ..()
	if(auto_reflect(P, pdir, ploc, pangle) != BULLET_ACT_FORCE_PIERCE)
		return ..()
	return BULLET_ACT_FORCE_PIERCE

/obj/structure/reflector/proc/auto_reflect(obj/projectile/P, pdir, turf/ploc, pangle)
	P.ignore_source_check = TRUE
	P.range = P.decayedRange
	P.decayedRange = max(P.decayedRange--, 0)
	return BULLET_ACT_FORCE_PIERCE

/obj/structure/reflector/attackby(obj/item/W, mob/user, params)
	if(admin)
		return

	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		can_rotate = !can_rotate
		to_chat(user, span_notice("You [can_rotate ? "unlock" : "lock"] [src]'s rotation."))
		W.play_tool_sound(src)
		return

	if(W.tool_behaviour == TOOL_WRENCH)
		if(anchored)
			to_chat(user, span_warning("Unweld [src] from the floor first!"))
			return
		user.visible_message("[user] starts to dismantle [src].", span_notice("You start to dismantle [src]..."))
		if(W.use_tool(src, user, 80, volume=50))
			to_chat(user, span_notice("You dismantle [src]."))
			new framebuildstacktype(drop_location(), framebuildstackamount)
			if(buildstackamount)
				new buildstacktype(drop_location(), buildstackamount)
			qdel(src)
	else if(W.tool_behaviour == TOOL_WELDER)
		if(atom_integrity < max_integrity)
			if(!W.tool_start_check(user, amount=0))
				return

			user.visible_message("[user] starts to repair [src].",
								span_notice("You begin repairing [src]..."),
								span_italics("You hear welding."))
			if(W.use_tool(src, user, 40, volume=40))
				atom_integrity = max_integrity
				user.visible_message("[user] has repaired [src].", \
									span_notice("You finish repairing [src]."))

		else if(!anchored)
			if(!W.tool_start_check(user, amount=0))
				return

			user.visible_message("[user] starts to weld [src] to the floor.",
								span_notice("You start to weld [src] to the floor..."),
								span_italics("You hear welding."))
			if (W.use_tool(src, user, 20, volume=50))
				set_anchored(TRUE)
				to_chat(user, span_notice("You weld [src] to the floor."))
		else
			if(!W.tool_start_check(user, amount=0))
				return

			user.visible_message("[user] starts to cut [src] free from the floor.",
								span_notice("You start to cut [src] free from the floor..."),
								span_italics("You hear welding."))
			if (W.use_tool(src, user, 20, volume=50))
				set_anchored(FALSE)
				to_chat(user, span_notice("You cut [src] free from the floor."))

	//Finishing the frame
	else if(istype(W, /obj/item/stack/sheet))
		if(finished)
			return
		var/obj/item/stack/sheet/S = W
		if(istype(S, /obj/item/stack/sheet/glass))
			if(S.use(5))
				new /obj/structure/reflector/single(drop_location())
				qdel(src)
			else
				to_chat(user, span_warning("You need five sheets of glass to create a reflector!"))
				return
		if(istype(S, /obj/item/stack/sheet/rglass))
			if(S.use(10))
				new /obj/structure/reflector/double(drop_location())
				qdel(src)
			else
				to_chat(user, span_warning("You need ten sheets of reinforced glass to create a double reflector!"))
				return
		if(istype(S, /obj/item/stack/sheet/mineral/diamond))
			if(S.use(1))
				new /obj/structure/reflector/box(drop_location())
				qdel(src)
	else
		return ..()

/obj/structure/reflector/proc/rotate(mob/user)
	if (!can_rotate || admin)
		to_chat(user, span_warning("The rotation is locked!"))
		return FALSE
	var/new_angle = input(user, "Input a new angle for primary reflection face.", "Reflector Angle", rotation_angle) as null|num
	if(!user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		return
	if(!isnull(new_angle))
		set_angle(SIMPLIFY_DEGREES(new_angle))
	return TRUE

//TYPES OF REFLECTORS, SINGLE, DOUBLE, BOX

//SINGLE

/obj/structure/reflector/single
	name = "reflector"
	deflector_icon_state = "reflector"
	desc = "An angled mirror for reflecting laser beams."
	density = TRUE
	finished = TRUE
	buildstacktype = /obj/item/stack/sheet/glass
	buildstackamount = 5

/obj/structure/reflector/single/anchored
	anchored = TRUE

/obj/structure/reflector/single/mapping
	admin = TRUE
	anchored = TRUE

/obj/structure/reflector/single/auto_reflect(obj/projectile/P, pdir, turf/ploc, pangle)
	var/incidence = GET_ANGLE_OF_INCIDENCE(rotation_angle, (P.Angle + 180))
	if(abs(incidence) > 90 && abs(incidence) < 270)
		return FALSE
	var/new_angle = SIMPLIFY_DEGREES(rotation_angle + incidence)
	P.set_angle_centered(new_angle)
	return ..()

//DOUBLE

/obj/structure/reflector/double
	name = "double sided reflector"
	deflector_icon_state = "reflector_double"
	desc = "A double sided angled mirror for reflecting laser beams."
	density = TRUE
	finished = TRUE
	buildstacktype = /obj/item/stack/sheet/rglass
	buildstackamount = 10

/obj/structure/reflector/double/anchored
	anchored = TRUE

/obj/structure/reflector/double/mapping
	admin = TRUE
	anchored = TRUE

/obj/structure/reflector/double/auto_reflect(obj/projectile/P, pdir, turf/ploc, pangle)
	var/incidence = GET_ANGLE_OF_INCIDENCE(rotation_angle, (P.Angle + 180))
	var/new_angle = SIMPLIFY_DEGREES(rotation_angle + incidence)
	P.set_angle_centered(new_angle)
	return ..()

//BOX

/obj/structure/reflector/box
	name = "reflector box"
	deflector_icon_state = "reflector_box"
	desc = "A box with an internal set of mirrors that reflects all laser beams in a single direction."
	density = TRUE
	finished = TRUE
	buildstacktype = /obj/item/stack/sheet/mineral/diamond
	buildstackamount = 1

/obj/structure/reflector/box/anchored
	anchored = TRUE

/obj/structure/reflector/box/mapping
	admin = TRUE
	anchored = TRUE

/obj/structure/reflector/box/auto_reflect(obj/projectile/P)
	P.set_angle_centered(rotation_angle)
	return ..()

/obj/structure/reflector/ex_act()
	if(admin)
		return
	else
		return ..()

/obj/structure/reflector/dir_map_to_angle(dir)
	return dir2angle(dir)

/obj/structure/reflector/singularity_act()
	if(admin)
		return
	else
		return ..()

// tgui menu

/obj/structure/reflector/ui_interact(mob/user, datum/tgui/ui)
	if(!finished)
		user.balloon_alert(user, "nothing to rotate!")
		return
	if(!can_rotate)
		user.balloon_alert(user, "can't rotate!")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Reflector")
		ui.open()

/obj/structure/reflector/attack_robot(mob/user)
	ui_interact(user)
	return

/obj/structure/reflector/ui_state(mob/user)
	return GLOB.physical_state //Prevents borgs from adjusting this at range

/obj/structure/reflector/ui_data(mob/user)
	var/list/data = list()
	data["rotation_angle"] = rotation_angle
	data["reflector_name"] = name

	return data

/obj/structure/reflector/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("rotate")
			if (!can_rotate || admin)
				return FALSE
			var/new_angle = text2num(params["rotation_angle"])
			if(isnull(new_angle))
				log_href_exploit(usr, " inputted a string to [src] instead of a number while interacting with the rotate UI, somehow.")
				return FALSE
			set_angle(SIMPLIFY_DEGREES(new_angle))
			return TRUE
		if("calculate")
			if (!can_rotate || admin)
				return FALSE
			var/new_angle = rotation_angle + text2num(params["rotation_angle"])
			if(isnull(new_angle))
				log_href_exploit(usr, " inputted a string to [src] instead of a number while interacting with the calculate UI, somehow.")
				return FALSE
			set_angle(SIMPLIFY_DEGREES(new_angle))
			return TRUE
