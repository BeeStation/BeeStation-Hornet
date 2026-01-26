/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/storage/closet.dmi'
	icon_state = "generic"
	density = TRUE
	drag_slowdown = 1.5		// Same as a prone mob
	max_integrity = 200
	integrity_failure = 0.25
	armor_type = /datum/armor/structure_closet
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	pass_flags_self = LETPASSCLICKS | PASSSTRUCTURE
	interaction_flags_atom = NONE
	var/contents_initialised = FALSE
	var/enable_door_overlay = TRUE
	var/has_opened_overlay = TRUE
	var/has_closed_overlay = TRUE
	var/icon_door = null
	var/secure = FALSE //secure locker or not, also used if overriding a non-secure locker with a secure door overlay to add fancy lights
	var/opened = FALSE
	var/welded = FALSE
	var/locked = FALSE
	/// Whether a skittish person can dive inside this closet. Disable if opening the closet causes "bad things" to happen or that it leads to a logical inconsistency.
	var/divable = TRUE
	/// true whenever someone with the strong pull component (or magnet modsuit module) is dragging this, preventing opening
	var/strong_grab = FALSE
	var/large = TRUE
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/breakout_time = 1200
	var/message_cooldown
	var/can_weld_shut = TRUE
	var/horizontal = FALSE
	var/allow_objects = FALSE
	var/allow_dense = FALSE
	var/dense_when_open = FALSE //if it's dense when open or not
	var/max_mob_size = MOB_SIZE_HUMAN //Biggest mob_size accepted by the container
	var/mob_storage_capacity = 3 // how many human sized mob/living can fit together inside a closet.
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.
	var/cutting_tool = TOOL_WELDER
	var/open_sound = 'sound/machines/closet_open.ogg'
	var/close_sound = 'sound/machines/closet_close.ogg'
	var/open_sound_volume = 35
	var/close_sound_volume = 50
	var/material_drop = /obj/item/stack/sheet/iron
	var/material_drop_amount = 2
	var/delivery_icon = "deliverycloset" //which icon to use when packagewrapped. null to be unwrappable.
	var/anchorable = TRUE
	var/obj/effect/overlay/closet_door/door_obj
	var/is_animating_door = FALSE
	var/door_anim_squish = 0.30
	var/door_anim_angle = 136
	var/door_hinge = -6.5
	var/door_anim_time = 2.0 // set to 0 to make the door not animate at all

	var/icon_emagged = "emagged"
	var/icon_welded = "welded"
	var/icon_manifest = "manifest"
	var/icon_locked = "locked"
	var/icon_unlocked = "unlocked"

	var/imacrate = FALSE

	//should be just for crates, right?
	var/obj/item/paper/fluff/jobs/cargo/manifest/manifest


/datum/armor/structure_closet
	melee = 20
	bullet = 10
	laser = 10
	bomb = 10
	fire = 70
	acid = 60

/obj/structure/closet/Initialize(mapload)
	. = ..()
	// if closed, any item at the crate's loc is put in the contents
	if (mapload && !opened)
		. = INITIALIZE_HINT_LATELOAD
	populate_contents_immediate()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_MAGICALLY_UNLOCKED = PROC_REF(on_magic_unlock),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	update_icon()

/obj/structure/closet/LateInitialize()
	. = ..()

	take_contents()

/// Used to immediately fill a closet on spawn.
/// Use this if you are spawning any items which can be tracked inside the closet.
/obj/structure/closet/proc/populate_contents_immediate()
	return

//USE THIS TO FILL IT, NOT INITIALIZE OR NEW
/obj/structure/closet/proc/PopulateContents()
	return

/obj/structure/closet/Destroy()
	dump_contents()
	return ..()

/obj/structure/closet/update_icon()
	. = ..()
	if(istype(src, /obj/structure/closet/supplypod))
		return
	else
		if (!imacrate)
			layer = opened ? BELOW_OBJ_LAYER : OBJ_LAYER
		else
			layer = BELOW_OBJ_LAYER

	update_mob_alpha()
/obj/structure/closet/update_overlays()
	. = ..()
	closet_update_overlays(.)

/obj/structure/closet/proc/closet_update_overlays(list/new_overlays)
	. = new_overlays
	if(enable_door_overlay && !is_animating_door)
		var/overlay_state = isnull(base_icon_state) ? initial(icon_state) : base_icon_state
		if(opened && has_opened_overlay)
			var/mutable_appearance/door_overlay = mutable_appearance(icon, "[overlay_state]_open", alpha = src.alpha)
			. += door_overlay
			door_overlay.overlays += emissive_blocker(door_overlay.icon, door_overlay.icon_state, src, alpha = door_overlay.alpha) // If we don't do this the door doesn't block emissives and it looks weird.
		else if(has_closed_overlay)
			. += "[icon_door || overlay_state]_door"
	if(welded)
		. += icon_welded
	if(broken)
		. += icon_emagged
	if(manifest)
		. += icon_manifest
	if(!secure || broken ||(opened && !imacrate))
		return

	//Overlay is similar enough for both that we can use the same mask for both
	. += emissive_appearance(icon, icon_locked, src.layer)
	ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
	. += locked ? icon_locked : icon_unlocked

/obj/structure/closet/proc/animate_door(closing = FALSE)
	if(!door_anim_time)
		return
	if(!door_obj) door_obj = new
	vis_contents |= door_obj
	door_obj.icon = icon
	door_obj.icon_state = "[icon_door || icon_state]_door"
	is_animating_door = TRUE
	var/num_steps = door_anim_time / world.tick_lag
	for(var/I in 0 to num_steps)
		var/angle = door_anim_angle * (closing ? 1 - (I/num_steps) : (I/num_steps))
		var/matrix/M = get_door_transform(angle)
		var/door_state = angle >= 90 ? "[icon_state]_back" : "[icon_door || icon_state]_door"
		var/door_layer = angle >= 90 ? FLOAT_LAYER : ABOVE_MOB_LAYER

		if(I == 0)
			door_obj.transform = M
			door_obj.icon_state = door_state
			door_obj.layer = door_layer
		else if(I == 1)
			animate(door_obj, transform = M, icon_state = door_state, layer = door_layer, time = world.tick_lag, flags = ANIMATION_END_NOW)
		else
			animate(transform = M, icon_state = door_state, layer = door_layer, time = world.tick_lag)
	addtimer(CALLBACK(src,PROC_REF(end_door_animation)),door_anim_time,TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/structure/closet/proc/end_door_animation()
	is_animating_door = FALSE
	vis_contents -= door_obj
	update_icon()
	COMPILE_OVERLAYS(src)

/obj/structure/closet/proc/get_door_transform(angle)
	var/matrix/M = matrix()
	M.Translate(-door_hinge, 0)
	M.Multiply(matrix(cos(angle), 0, 0, -sin(angle) * door_anim_squish, 1, 0))
	M.Translate(door_hinge, 0)
	return M

/obj/structure/closet/examine(mob/user)
	. = ..()
	if(welded)
		. += span_notice("It's welded shut.")
	if(anchored)
		. += span_notice("It is <b>bolted</b> to the ground.")
	if(opened)
		. += span_notice("The parts are <b>welded</b> together.")
	else if(secure && !opened)
		. += span_notice("Right-click to [locked ? "unlock" : "lock"].")
	if(isliving(user))
		if(divable && HAS_TRAIT(user, TRAIT_SKITTISH))
			. += span_notice("Ctrl-Shift-click [src] to jump inside.")

/obj/structure/closet/add_context_self(datum/screentip_context/context, mob/user)

	if(secure && !broken)
		context.add_alt_click_action("[opened ? "Lock" : "Unlock"]")
	if(!welded)
		context.add_left_click_action("[opened ? "Close" : "Open"]")

	if(opened)
		context.add_left_click_tool_action("Deconstruct", TOOL_WELDER)
	else
		if(!welded && can_weld_shut)
			context.add_left_click_tool_action("Weld", TOOL_WELDER)
		else if(welded)
			context.add_left_click_tool_action("Unweld", TOOL_WELDER)

	if(anchorable)
		context.add_left_click_tool_action("[anchored ? "Unanchor" : "Anchor"]", TOOL_WRENCH)

/obj/structure/closet/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(wall_mounted)
		return TRUE

/obj/structure/closet/proc/can_open(mob/living/user, force = FALSE)
	if(force)
		return TRUE
	if(welded || locked)
		return FALSE
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
			if(user)
				to_chat(user, span_danger("There's something large on top of [src], preventing it from opening.") )
			return FALSE
	return TRUE

/obj/structure/closet/proc/can_close(mob/living/user)
	var/turf/T = get_turf(src)
	for(var/obj/structure/closet/closet in T)
		if(closet != src && !closet.wall_mounted)
			if(user)
				balloon_alert(user, "[closet.name] is in the way!")
			return FALSE
	for(var/mob/living/L in T)
		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
			if(user)
				to_chat(user, span_danger("There's something too large in [src], preventing it from closing."))
			return FALSE
	return TRUE

/obj/structure/closet/dump_contents()
	// Generate the contents if we haven't already
	if (!contents_initialised)
		contents_initialised = TRUE
		PopulateContents()
		SEND_SIGNAL(src, COMSIG_CLOSET_CONTENTS_INITIALIZED)

	var/atom/L = drop_location()
	for(var/atom/movable/AM in src)
		AM.forceMove(L)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM, dir)
	if(throwing)
		throwing.finalize(FALSE)

/obj/structure/closet/proc/take_contents()
	var/atom/L = drop_location()
	if(!L)
		return
	for(var/atom/movable/AM in L)
		if(AM != src && insert(AM) == -1) // limit reached
			break

/obj/structure/closet/proc/open(mob/living/user, force = FALSE, special_effects = TRUE)
	if(opened || !can_open(user, force))
		return
	if(special_effects)
		playsound(loc, open_sound, open_sound_volume, TRUE, -3)
	opened = TRUE
	if(!dense_when_open)
		set_density(FALSE)
	dump_contents()
	if(special_effects)
		animate_door(FALSE)
	update_appearance()
	update_icon()
	after_open(user, force)
	return TRUE

///Proc to override for effects after opening a door
/obj/structure/closet/proc/after_open(mob/living/user, force = FALSE)
	return

/obj/structure/closet/proc/insert(atom/movable/AM)
	if(contents.len >= storage_capacity)
		return -1
	if(insertion_allowed(AM))
		AM.forceMove(src)
		return TRUE
	else
		return FALSE

/obj/structure/closet/proc/insertion_allowed(atom/movable/AM)
	if(iseffect(AM))
		return FALSE
	else if(ismob(AM))
		if(!isliving(AM)) //let's not put ghosts or camera mobs inside closets...
			return FALSE
		var/mob/living/L = AM
		if(L.anchored || L.buckled || L.incorporeal_move || L.has_buckled_mobs())
			return FALSE
		if(L.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if(!mob_storage_capacity)
				return FALSE
			if(horizontal && L.density)
				return FALSE
			if(L.mob_size > max_mob_size)
				return FALSE
			var/mobs_stored = 0
			for(var/mob/living/M in contents)
				if(++mobs_stored >= mob_storage_capacity)
					return FALSE
		L.stop_pulling()

	else if(istype(AM, /obj/structure/closet))
		return FALSE
	else if(isobj(AM))
		if((!allow_dense && AM.density) || AM.anchored || AM.has_buckled_mobs())
			return FALSE
		else if(isitem(AM) && !HAS_TRAIT(AM, TRAIT_NODROP))
			return TRUE
		else if(!allow_objects && !istype(AM, /obj/effect/dummy/chameleon))
			return FALSE
	else
		return FALSE

	return TRUE

/obj/structure/closet/proc/close(mob/living/user)
	if(!opened || !can_close(user))
		return FALSE
	take_contents()
	playsound(loc, close_sound, close_sound_volume, 1, -3)
	opened = FALSE
	set_density(TRUE)
	animate_door(TRUE)
	update_appearance()
	after_close(user)
	return TRUE

///Proc to override for effects after closing a door
/obj/structure/closet/proc/after_close(mob/living/user)
	return

/obj/structure/closet/proc/toggle(mob/living/user)
	if(opened)
		return close(user)
	else
		return open(user)

/obj/structure/closet/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(flags_1 & NODECONSTRUCT_1))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/closet/atom_break(damage_flag)
	. = ..()
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		bust_open()

/obj/structure/closet/attackby(obj/item/W, mob/user, params)
	if(user in src)
		return
	if(src.tool_interact(W,user))
		return 1 // No afterattack
	else
		return ..()

/obj/structure/closet/proc/tool_interact(obj/item/W, mob/living/user)//returns TRUE if attackBy call shouldn't be continued (because tool was used/closet was of wrong type), FALSE if otherwise
	. = TRUE
	if(opened)
		if(W.tool_behaviour == cutting_tool)
			if(cutting_tool == TOOL_WELDER)
				if(!W.tool_start_check(user, amount=0))
					return

				to_chat(user, span_notice("You begin cutting \the [src] apart..."))
				if(W.use_tool(src, user, 40, volume=50))
					if(!opened)
						return
					user.visible_message(span_notice("[user] slices apart \the [src]."),
									span_notice("You cut \the [src] apart with \the [W]."),
									span_italics("You hear welding."))
					deconstruct(TRUE)
				return
			else // for example cardboard box is cut with wirecutters
				user.visible_message(span_notice("[user] cut apart \the [src]."), \
									span_notice("You cut \the [src] apart with \the [W]."))
				deconstruct(TRUE)
				return
		if (user.combat_mode)
			return FALSE
		if(user.transferItemToLoc(W, drop_location())) // so we put in unlit welder too
			return
	else if(W.tool_behaviour == TOOL_WELDER && can_weld_shut)
		if(!W.tool_start_check(user, amount=0))
			return

		to_chat(user, span_notice("You begin [welded ? "unwelding":"welding"] \the [src]..."))
		if(W.use_tool(src, user, 40, volume=50))
			if(opened)
				return
			welded = !welded
			after_weld(welded)
			user.visible_message(span_notice("[user] [welded ? "welds shut" : "unwelded"] \the [src]."),
							span_notice("You [welded ? "weld" : "unwelded"] \the [src] with \the [W]."),
							span_italics("You hear welding."))
			update_icon()

	else if(!user.combat_mode)
		var/item_is_id = W.GetID()
		if(!item_is_id)
			return FALSE
		if(item_is_id || !toggle(user))
			togglelock(user)
	else
		return FALSE

/obj/structure/closet/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(!anchorable)
		balloon_alert(user, "no anchor bolts!")
		return TRUE
	if(isinspace() && !anchored) // We want to prevent anchoring a locker in space, but we should still be able to unanchor it there
		balloon_alert(user, "nothing to anchor to!")
		return TRUE
	set_anchored(!anchored)
	tool.play_tool_sound(src, 75)
	user.balloon_alert_to_viewers("[anchored ? "anchored" : "unanchored"]")
	return TRUE

/obj/structure/closet/proc/after_weld(weld_state)
	return

/obj/structure/closet/MouseDrop_T(atom/movable/O, mob/living/user)
	if(!istype(O) || O.anchored || istype(O, /atom/movable/screen))
		return
	if(!istype(user) || user.incapacitated() || user.body_position == LYING_DOWN)
		return
	if(!Adjacent(user) || !user.Adjacent(O))
		return
	if(user == O) //try to climb onto it
		return ..()
	if(!opened)
		return
	if(!isturf(O.loc))
		return

	var/actuallyismob = FALSE
	if(isliving(O))
		actuallyismob = TRUE
	else if(!isitem(O))
		return
	var/turf/T = get_turf(src)
	add_fingerprint(user)
	user.visible_message(span_warning("[user] [actuallyismob ? "tries to " : ""]stuff [O] into [src]."), \
						span_warning("You [actuallyismob ? "try to " : ""]stuff [O] into [src]."), \
						span_italics("You hear clanging."))
	if(actuallyismob)
		if(do_after(user, 4 SECONDS, O))
			user.visible_message(span_notice("[user] stuffs [O] into [src]."), \
								span_notice("You stuff [O] into [src]."), \
								span_italics("You hear a loud metal bang."))
			var/mob/living/L = O
			if(!issilicon(L))
				L.Paralyze(4 SECONDS)
			if(istype(src, /obj/structure/closet/supplypod/extractionpod))
				O.forceMove(src)
			else
				O.forceMove(T)
				close()
	else
		O.forceMove(T)
	return TRUE

/obj/structure/closet/relaymove(mob/living/user, direction)
	if(user.stat || !isturf(loc))
		return
	if(locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, span_warning("[src]'s door won't budge!"))
		return
	container_resist(user)

/obj/structure/closet/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.body_position == LYING_DOWN && get_dist(src, user) > 0)
		return

	if(!toggle(user))
		togglelock(user)


/obj/structure/closet/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/closet/attack_robot(mob/user)
	if(user.Adjacent(src))
		return attack_hand(user)

/obj/structure/closet/attack_robot_secondary(mob/user, list/modifiers)
	if(!user.Adjacent(src))
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	togglelock(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user)
	if(attack_hand(user))
		return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/structure/closet/verb/verb_toggleopen()
	set src in view(1)
	set category = "Object"
	set name = "Toggle Open"

	if(!usr.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return

	if(iscarbon(usr) || issilicon(usr) || isdrone(usr))
		return toggle(usr)
	else
		to_chat(usr, span_warning("This mob type can't use this verb."))

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/leaving, direction)
	open()
	if(leaving.loc == src)
		return 0
	return 1

/obj/structure/closet/container_resist(mob/living/user)
	if(opened)
		return
	if(ismovable(loc))
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		var/atom/movable/AM = loc
		AM.relay_container_resist(user, src)
		return
	if(!welded && !locked)
		open()
		return

	//okay, so the closet is either welded or locked... resist!!!
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_warning("[src] begins to shake violently!"), \
		span_notice("You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_italics("You hear banging from [src]."))
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || (!locked && !welded) )
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting
		user.visible_message(span_danger("[user] successfully broke out of [src]!"),
							span_notice("You successfully break out of [src]!"))
		bust_open()
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, span_warning("You fail to break out of [src]!"))

/obj/structure/closet/proc/bust_open()
	welded = FALSE //applies to all lockers
	locked = FALSE //applies to critter crates and secure lockers only
	broken = TRUE //applies to secure lockers only
	open(force = TRUE, special_effects = FALSE)

/obj/structure/closet/attack_hand_secondary(mob/user, modifiers)
	. = ..()

	if(!user.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return

	if(!opened && secure)
		togglelock(user)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/closet/CtrlShiftClick(mob/living/user)
	if(!(divable && HAS_TRAIT(user, TRAIT_SKITTISH)))
		return ..()
	if(!user.canUseTopic(src, BE_CLOSE) || !isturf(user.loc))
		return
	dive_into(user)

/obj/structure/closet/proc/togglelock(mob/living/user, silent)
	if(secure && !broken)
		if(allowed(user))
			if(iscarbon(user))
				add_fingerprint(user)
			locked = !locked
			user.visible_message(span_notice("[user] [locked ? null : "un"]locks [src]."),
							span_notice("You [locked ? null : "un"]lock [src]."))
			update_icon()
		else if(!silent)
			to_chat(user, span_notice("Access Denied."))
	else if(secure && broken)
		to_chat(user, span_warning("\The [src] is broken!"))

/obj/structure/closet/should_emag(mob/user)
	return secure && !broken && ..()

/obj/structure/closet/on_emag(mob/user)
	..()
	user?.visible_message(span_warning("Sparks fly from [src]!"),
					span_warning("You scramble [src]'s lock, breaking it open!"),
					span_italics("You hear a faint electrical spark."))
	playsound(src, "sparks", 50, 1)
	broken = TRUE
	locked = FALSE
	update_appearance()
	update_icon()

/obj/structure/closet/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 1)

/obj/structure/closet/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if (!(. & EMP_PROTECT_CONTENTS))
		for(var/obj/O in src)
			O.emp_act(severity)
	if(secure && !broken && !(. & EMP_PROTECT_SELF))
		if(prob(50 / severity))
			locked = !locked
			update_icon()
		if(prob(20 / severity) && !opened)
			if(!locked)
				open()
			else
				req_access = list()
				req_access |= pick(get_all_accesses())

/obj/structure/closet/contents_explosion(severity, target)
	// Generate the contents if we haven't already
	if (!contents_initialised)
		PopulateContents()
		contents_initialised = TRUE
	for(var/thing in contents)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += thing
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += thing
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += thing

/obj/structure/closet/singularity_act()
	dump_contents()
	..()

/obj/structure/closet/AllowDrop()
	return TRUE


/obj/structure/closet/return_temperature()
	return

/obj/structure/closet/proc/dive_into(mob/living/user)
	var/turf/T1 = get_turf(user)
	var/turf/T2 = get_turf(src)
	if(!opened)
		if(locked)
			togglelock(user, TRUE)
		if(!open(user))
			to_chat(user, span_warning("It won't budge!"))
			return
	step_towards(user, T2)
	T1 = get_turf(user)
	if(T1 == T2)
		user.set_resting(TRUE) //so people can jump into crates without slamming the lid on their head
		if(!close(user))
			to_chat(user, span_warning("You can't get [src] to close!"))
			user.set_resting(FALSE)
			return
		user.set_resting(FALSE)
		togglelock(user)
		T1.visible_message(span_warning("[user] dives into [src]!"))

/obj/structure/closet/on_object_saved(depth = 0)
	// Generate the contents if we haven't already
	if (!contents_initialised)
		PopulateContents()
		contents_initialised = TRUE
	if(depth >= 10)
		return ""
	var/dat = ""
	for(var/obj/item in contents)
		var/metadata = generate_tgm_metadata(item)
		dat += "[dat ? ",\n" : ""][item.type][metadata]"
		//Save the contents of things inside the things inside us, EG saving the contents of bags inside lockers
		var/custom_data = item.on_object_saved(depth++)
		dat += "[custom_data ? ",\n[custom_data]" : ""]"
	return dat

/obj/structure/closet/proc/on_magic_unlock(datum/source, datum/action/spell/aoe/knock/spell, mob/living/caster)
	SIGNAL_HANDLER

	locked = FALSE
	INVOKE_ASYNC(src, PROC_REF(open))
