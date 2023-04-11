#define CONSTRUCTION_COMPLETE 0 //No construction done - functioning as normal
#define CONSTRUCTION_PANEL_OPEN 1 //Maintenance panel is open, still functioning
#define CONSTRUCTION_WIRES_EXPOSED 2 //Cover plate is removed, wires are available
#define CONSTRUCTION_GUTTED 3 //Wires are removed, circuit ready to remove
#define CONSTRUCTION_NOCIRCUIT 4 //Circuit board removed, can safely weld apart

#define RECLOSE_DELAY 5 SECONDS // How long until a firelock tries to shut itself if it's blocking a vacuum.
#define FIRE_ALARM 2
/obj/machinery/door/firedoor
	name = "firelock"
	desc = "A convenable firelock. It has a card reader and a set of indicator lights on the side."
	icon = 'icons/obj/doors/doorfireglass.dmi'
	icon_state = "door_open"
	opacity = FALSE
	density = FALSE
	max_integrity = 300
	resistance_flags = FIRE_PROOF
	heat_proof = TRUE
	glass = TRUE
	sub_door = TRUE
	explosion_block = 1
	safe = FALSE
	layer = BELOW_OPEN_DOOR_LAYER
	closingLayer = CLOSED_FIREDOOR_LAYER
	assemblytype = /obj/structure/firelock_frame
	armor = list(MELEE = 30,  BULLET = 30, LASER = 20, ENERGY = 20, BOMB = 10, BIO = 100, RAD = 100, FIRE = 95, ACID = 70, STAMINA = 0)
	interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_REQUIRES_SILICON | INTERACT_MACHINE_OPEN
	air_tight = TRUE
	open_speed = 2
	req_one_access = list(ACCESS_ENGINE, ACCESS_ATMOSPHERICS)
	processing_flags = START_PROCESSING_MANUALLY
	var/emergency_close_timer = 0
	var/nextstate = null
	var/boltslocked = TRUE
	var/list/affecting_areas
	var/list/access_log
	var/process_ticker //Ratelimit process to one check ~5 process ticks

/obj/machinery/door/firedoor/Initialize(mapload)
	. = ..()
	CalculateAffectingAreas()

/obj/machinery/door/firedoor/examine(mob/user)
	. = ..()
	if(!density)
		. += "<span class='notice'>It is open, but could be <b>pried</b> closed.</span>"
	else if(!welded)
		. += "<span class='notice'>It is closed, but could be <i>pried</i> open. Deconstruction would require it to be <b>welded</b> shut.</span>"
	else if(boltslocked)
		. += "<span class='notice'>It is <i>welded</i> shut. The floor bolts have been locked by <b>screws</b>.</span>"
	else
		. += "<span class='notice'>The bolt locks have been <i>unscrewed</i>, but the bolts themselves are still <b>wrenched</b> to the floor.</span>"

/obj/machinery/door/firedoor/proc/CalculateAffectingAreas()
	remove_from_areas()
	affecting_areas = get_adjacent_open_areas(src) | get_area(src)
	for(var/I in affecting_areas)
		var/area/A = I
		LAZYADD(A.firedoors, src)

/obj/machinery/door/firedoor/closed
	icon_state = "door_closed"
	opacity = TRUE
	density = TRUE
	processing_flags = START_PROCESSING_ON_INIT

//see also turf/AfterChange for adjacency shennanigans

/obj/machinery/door/firedoor/proc/remove_from_areas()
	if(affecting_areas)
		for(var/I in affecting_areas)
			var/area/A = I
			LAZYREMOVE(A.firedoors, src)

/obj/machinery/door/firedoor/Destroy()
	remove_from_areas()
	affecting_areas.Cut()
	return ..()

/obj/machinery/door/firedoor/Bumped(atom/movable/AM)
	if(panel_open || operating)
		return
	if(!density)
		return ..()
	return FALSE


/obj/machinery/door/firedoor/power_change()
	if(powered(power_channel))
		set_machine_stat(machine_stat & ~NOPOWER)
		INVOKE_ASYNC(src, PROC_REF(latetoggle))
	else
		set_machine_stat(machine_stat | NOPOWER)

/obj/machinery/door/firedoor/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(operating || !density)
		return

	user.changeNext_move(CLICK_CD_MELEE)

	user.visible_message("[user] bangs on \the [src].",
						 "You bang on \the [src].")
	playsound(loc, 'sound/effects/glassknock.ogg', 10, FALSE, frequency = 32000)

/obj/machinery/door/firedoor/attackby(obj/item/C, mob/user, params)
	add_fingerprint(user)
	if(operating)
		return

	if(istype(C, /obj/item/modular_computer/tablet/pda))
		var/attack_verb = pick("smushes","rubs","smashes","presses","taps")
		visible_message("<span class='warning'>[user] [attack_verb] \the [C] against [src]\s card reader.</span>", "<span class='warning'>You [attack_verb] \the [C] against [src]\s card reader. It doesn't do anything.</span>", "You hear plastic click against metal.")
		return

	if(welded)
		if(C.tool_behaviour == TOOL_WRENCH)
			if(boltslocked)
				to_chat(user, "<span class='notice'>There are screws locking the bolts in place!</span>")
				return
			C.play_tool_sound(src)
			user.visible_message("<span class='notice'>[user] starts undoing [src]'s bolts...</span>", \
								 "<span class='notice'>You start unfastening [src]'s floor bolts...</span>")
			if(!C.use_tool(src, user, 50))
				return
			playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
			user.visible_message("<span class='notice'>[user] unfastens [src]'s bolts.</span>", \
								 "<span class='notice'>You undo [src]'s floor bolts.</span>")
			deconstruct(TRUE)
			return
		if(C.tool_behaviour == TOOL_SCREWDRIVER)
			user.visible_message("<span class='notice'>[user] [boltslocked ? "unlocks" : "locks"] [src]'s bolts.</span>", \
								 "<span class='notice'>You [boltslocked ? "unlock" : "lock"] [src]'s floor bolts.</span>")
			C.play_tool_sound(src)
			boltslocked = !boltslocked
			return
	if(C.tool_behaviour == TOOL_MULTITOOL)
		if(!access_log)
			to_chat(user, "<span class='warning'>\the [C] beeps, 'Access Log Empty.'</span>")
			return
		to_chat(user, "<span class='notice'>\the [C] beeps, 'Dumping access log...'</span>")
		for(var/entry in access_log)
			to_chat(user, "<span class='notice robot'>[entry]</span>")

	return ..()

/obj/machinery/door/firedoor/try_to_activate_door(obj/item/I, mob/user)
	if(!density || welded)
		return

	if(isidcard(I))
		if((check_safety(user) == TRUE) || check_access(I))
			log_opening(I, user, check_safety(user))
			playsound(src, 'sound/machines/beep.ogg', 50, 1)
			open()
			return
		else
			log_opening(I, user, -1)
			to_chat(user, "<span class='danger'>Access Denied, User not authorized to override alarms or pressure checks.</span>")
			playsound(src, 'sound/machines/terminal_error.ogg', 50, 1)
			return
	to_chat("<span class='warning'>You try to pull the card reader. Nothing happens.</span>")
	return

/obj/machinery/door/firedoor/proc/log_opening(obj/item/card/id/I, mob/user, safe)
	var/safestate = "UNK_STATE:"
	switch(safe)
		if(-1)//Rejected
			safestate = "USR_NOACC:"
		if(FALSE)//Unsafe, Atmos
			safestate = "OVER_SENS:"
		if(TRUE)//Safe.
			safestate = "SAFE_OPEN:"
		if(FIRE_ALARM)
			safestate = "OVER_ALRM:"
	LAZYADD(access_log, "[safestate]|N:[I.registered_name]|A:[I.assignment]|T_OFFSET:[DisplayTimeText(world.time - SSticker.round_start_time)]")
	if(length(access_log) > 20) //Unless this is getting spammed this shouldn't happen.
		access_log.Remove(access_log[1])
	if(!check_safety(user))
		log_game("[key_name(user)] has opened a firelock with a pressure difference or a fire alarm at [AREACOORD(loc)], using [I]")
		user.log_message("has opened a firelock with a pressure difference or a fire alarm at [AREACOORD(loc)], using [I]", LOG_ATTACK)


/obj/machinery/door/firedoor/try_to_weld(obj/item/weldingtool/W, mob/user)
	if(!W.tool_start_check(user, amount=0))
		return
	user.visible_message("<span class='notice'>[user] starts [welded ? "unwelding" : "welding"] [src].</span>", "<span class='notice'>You start welding [src].</span>")
	if(W.use_tool(src, user, 40, volume=50))
		welded = !welded
		to_chat(user, "<span class='danger'>[user] [welded?"welds":"unwelds"] [src].</span>", "<span class='notice'>You [welded ? "weld" : "unweld"] [src].</span>")
		update_icon()


/obj/machinery/door/firedoor/try_to_crowbar(obj/item/I, mob/user)
	if(welded || operating)
		return

	if(density)
		if(!(machine_stat & NOPOWER))
			LAZYADD(access_log, "MOTOR_ERR:|MOTOR CONTROLLER REPORTED BACKDRIVE|T_OFFSET:[DisplayTimeText(world.time - SSticker.round_start_time)]")
			if(length(access_log) > 20) //Unless this is getting spammed this shouldn't happen.
				access_log.Remove(access_log[1])
			to_chat(user, "<span class='warning'>You begin forcing open \the [src], the motors whine...</span>")
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
			if(!do_after(user, 10 SECONDS, src))
				return
		else
			to_chat(user, "<span class='notice'>You begin forcing open \the [src], the motors don't resist...</span>")
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 100, TRUE)
			if(!do_after(user, 1 SECONDS, TRUE, src))
				return
		if(!check_safety(user))
			log_game("[key_name(user)] has opened a firelock with a pressure difference or a fire alarm at [AREACOORD(loc)], using a crowbar")
			user.log_message("has opened a firelock with a pressure difference or a fire alarm at [AREACOORD(loc)], using a crowbar", LOG_ATTACK)
		open()
	else
		close()


/obj/machinery/door/firedoor/proc/check_safety(mob/user, check_alarm = TRUE)
	var/area/A = get_area(src)
	if(check_alarm && A && A.fire)
		return FIRE_ALARM
	return !is_holding_pressure()

/obj/machinery/door/firedoor/allowed(mob/M)
	if(check_safety(M))//Passing the mob here is cargo cult programming, I can't see what wants it.
		return TRUE
	update_icon()
	return ..()


/obj/machinery/door/firedoor/attack_ai(mob/user)
	add_fingerprint(user)
	if(welded || operating || machine_stat & NOPOWER)
		return TRUE
	if(density)
		open()
	else
		close()
	return TRUE

/obj/machinery/door/firedoor/attack_robot(mob/user)
	return attack_ai(user)

/obj/machinery/door/firedoor/attack_alien(mob/user)
	add_fingerprint(user)
	if(welded)
		to_chat(user, "<span class='warning'>[src] refuses to budge!</span>")
		return
	open()

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)

/obj/machinery/door/firedoor/update_icon()
	cut_overlays()
	if(density)
		icon_state = "door_closed"
		if(welded)
			add_overlay("welded")
		switch(check_safety()) //TODO: Check Global Override here. Find some way to update the icon without making firedoors process?
			if(FALSE) //Unsafe, Atmos.
				add_overlay("overlay_pressure")
			if(FIRE_ALARM) //Unsafe, Alarm.
				add_overlay("overlay_alarm")
	else
		icon_state = "door_open"
		if(welded)
			add_overlay("welded_open")

/obj/machinery/door/firedoor/open()
	if(density && !operating) //This is hacky but gets the sound to play on time.
		playsound(src, 'sound/machines/firedoor_open.ogg', 30, 1)
	. = ..()
	if(.)
		STOP_PROCESSING(SSmachines, src)
	latetoggle()


/obj/machinery/door/firedoor/close()
	if(HAS_TRAIT(loc, TRAIT_FIREDOOR_STOP))
		return
	if(!density && !operating) //This is hacky but gets the sound to play on time.
		playsound(src, 'sound/machines/firedoor_close.ogg', 30, 1)
	. = ..()
	if(.)
		START_PROCESSING(SSmachines, src)
	latetoggle()

/obj/machinery/door/firedoor/process(delta_time)
	process_ticker += delta_time
	if(process_ticker < 5*delta_time)
		return
	process_ticker = 0
	update_icon()

/obj/machinery/door/firedoor/proc/whack_a_mole(reconsider_immediately = FALSE)
	set waitfor = 0
	for(var/cdir in GLOB.cardinals)
		if((flags_1 & ON_BORDER_1) && cdir != dir)
			continue
		whack_a_mole_part(get_step(src, cdir), reconsider_immediately)
	if(flags_1 & ON_BORDER_1)
		whack_a_mole_part(get_turf(src), reconsider_immediately)

/obj/machinery/door/firedoor/proc/whack_a_mole_part(turf/start_point, reconsider_immediately)
	set waitfor = 0
	var/list/doors_to_close = list()
	var/list/turfs = list()
	turfs[start_point] = 1
	for(var/i = 1; (i <= turfs.len && i <= 11); i++) // check up to 11 turfs.
		var/turf/open/T = turfs[i]
		if(istype(T, /turf/open/space))
			return -1
		for(var/T2 in T.atmos_adjacent_turfs)
			if(turfs[T2])
				continue
			var/is_cut_by_unopen_door = FALSE
			for(var/obj/machinery/door/firedoor/FD in T2)
				if((FD.flags_1 & ON_BORDER_1) && get_dir(T2, T) != FD.dir)
					continue
				if(FD.operating || FD == src || FD.welded || FD.density)
					continue
				doors_to_close += FD
				is_cut_by_unopen_door = TRUE

			for(var/obj/machinery/door/firedoor/FD in T)
				if((FD.flags_1 & ON_BORDER_1) && get_dir(T, T2) != FD.dir)
					continue
				if(FD.operating || FD == src || FD.welded || FD.density)
					continue
				doors_to_close += FD
				is_cut_by_unopen_door= TRUE
			if(!is_cut_by_unopen_door)
				turfs[T2] = 1
	if(turfs.len > 10)
		return // too big, don't bother
	for(var/obj/machinery/door/firedoor/FD in doors_to_close)
		FD.emergency_pressure_stop(FALSE)
		if(reconsider_immediately)
			var/turf/open/T = FD.loc
			if(istype(T))
				T.ImmediateCalculateAdjacentTurfs()

/obj/machinery/door/firedoor/proc/emergency_pressure_stop(consider_timer = TRUE)
	set waitfor = 0
	if(density || operating || welded)
		return
	if(world.time >= emergency_close_timer || !consider_timer)
		close()

/obj/machinery/door/firedoor/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/structure/firelock_frame/F = new assemblytype(get_turf(src))
		F.dir = src.dir
		if(disassembled)
			F.constructionStep = CONSTRUCTION_PANEL_OPEN
		else
			F.constructionStep = CONSTRUCTION_WIRES_EXPOSED
			F.obj_integrity = F.max_integrity * 0.5
		F.update_icon()
	qdel(src)


/obj/machinery/door/firedoor/proc/latetoggle()
	if(operating || machine_stat & NOPOWER || !nextstate)
		return
	switch(nextstate)
		if(FIREDOOR_OPEN)
			nextstate = null
			open()
		if(FIREDOOR_CLOSED)
			nextstate = null
			close()

/obj/machinery/door/firedoor/border_only
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	flags_1 = ON_BORDER_1
	CanAtmosPass = ATMOS_PASS_PROC
	assemblytype = /obj/structure/firelock_frame/border

/obj/machinery/door/firedoor/border_only/Initialize(mapload)
	. = ..()

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/door/firedoor/border_only/Destroy()
	set_density(FALSE)
	air_update_turf(1)
	return ..()

/obj/machinery/door/firedoor/border_only/closed
	icon_state = "door_closed"
	opacity = TRUE
	density = TRUE

/obj/machinery/door/firedoor/border_only/close()
	if(density)
		return TRUE
	if(operating || welded)
		return
	var/turf/T1 = get_turf(src)
	var/turf/T2 = get_step(T1, dir)
	for(var/mob/living/M in T1)
		if(M.stat == CONSCIOUS && M.pulling && M.pulling.loc == T2 && !M.pulling.anchored && M.pulling.move_resist <= M.move_force)
			var/mob/living/M2 = M.pulling
			if(!istype(M2) || !M2.buckled || !M2.buckled.buckle_prevents_pull)
				to_chat(M, "<span class='notice'>You pull [M.pulling] through [src] right as it closes.</span>")
				M.pulling.forceMove(T1)
				M.start_pulling(M2)
	for(var/mob/living/M in T2)
		if(M.stat == CONSCIOUS && M.pulling && M.pulling.loc == T1 && !M.pulling.anchored && M.pulling.move_resist <= M.move_force)
			var/mob/living/M2 = M.pulling
			if(!istype(M2) || !M2.buckled || !M2.buckled.buckle_prevents_pull)
				to_chat(M, "<span class='notice'>You pull [M.pulling] through [src] right as it closes.</span>")
				M.pulling.forceMove(T2)
				M.start_pulling(M2)
	. = ..()

/obj/machinery/door/firedoor/border_only/check_safety(mob/user)
	var/area/A = get_area(src)
	if((!A || !A.fire) && !is_holding_pressure())
		return TRUE
	whack_a_mole(TRUE) // WOOP WOOP SIDE EFFECTS
	var/turf/T = loc
	var/turf/T2 = get_step(T, dir)
	if(!T || !T2)
		return
	var/status1 = check_door_side(T)
	var/status2 = check_door_side(T2)
	if((status1 == 1 && status2 == -1) || (status1 == -1 && status2 == 1))
		return FALSE
	return TRUE

/obj/machinery/door/firedoor/border_only/proc/check_door_side(turf/open/start_point)
	var/list/turfs = list()
	turfs[start_point] = 1
	for(var/i = 1; (i <= turfs.len && i <= 11); i++) // check up to 11 turfs.
		var/turf/open/T = turfs[i]
		if(istype(T, /turf/open/space))
			return -1
		for(var/T2 in T.atmos_adjacent_turfs)
			turfs[T2] = 1
	if(turfs.len <= 10)
		return 0 // not big enough to matter
	return start_point.air.return_pressure() < 20 ? -1 : 1

/obj/machinery/door/firedoor/border_only/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(!(get_dir(loc, target) == dir)) //Make sure looking at appropriate border
		return TRUE

/obj/machinery/door/firedoor/border_only/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/machinery/door/firedoor/border_only/CanAtmosPass(turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return TRUE

/obj/machinery/door/firedoor/heavy
	name = "heavy firelock"
	icon = 'icons/obj/doors/doorfire.dmi'
	glass = FALSE
	explosion_block = 2
	assemblytype = /obj/structure/firelock_frame/heavy
	max_integrity = 550

/obj/machinery/door/firedoor/window
	name = "firelock window shutter"
	icon = 'icons/obj/doors/doorfirewindow.dmi'
	desc = "A second window that slides in when the original window is broken, designed to protect against hull breaches. Truly a work of genius by NT engineers."
	glass = TRUE
	explosion_block = 0
	max_integrity = 100
	resistance_flags = 0 // not fireproof
	heat_proof = FALSE
	assemblytype = /obj/structure/firelock_frame/window

/obj/machinery/door/firedoor/window/attack_alien(mob/living/carbon/alien/humanoid/user)
	playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
	return attack_generic(user, 60, BRUTE, MELEE, 0)

/obj/machinery/door/firedoor/window/process(delta_time)
	set waitfor = FALSE
	return PROCESS_KILL

/obj/item/electronics/firelock
	name = "firelock circuitry"
	custom_price = 5
	desc = "A circuit board used in construction of firelocks."
	icon_state = "mainboard"

/obj/structure/firelock_frame
	name = "firelock frame"
	desc = "A partially completed firelock."
	icon = 'icons/obj/doors/doorfire.dmi'
	icon_state = "frame1"
	anchored = FALSE
	density = TRUE
	var/constructionStep = CONSTRUCTION_NOCIRCUIT
	var/reinforced = 0
	var/firelock_type = /obj/machinery/door/firedoor

/obj/structure/firelock_frame/examine(mob/user)
	. = ..()
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			. += "<span class='notice'>It is <i>unbolted</i> from the floor. A small <b>loosely connected</b> metal plate is covering the wires.</span>"
			if(!reinforced)
				. += "<span class='notice'>It could be reinforced with plasteel.</span>"
		if(CONSTRUCTION_WIRES_EXPOSED)
			. += "<span class='notice'>The maintenance plate has been <i>pried away</i>, and <b>wires</b> are trailing.</span>"
		if(CONSTRUCTION_GUTTED)
			. += "<span class='notice'>The maintenance panel is missing <i>wires</i> and the circuit board is <b>loosely connected</b>.</span>"
		if(CONSTRUCTION_NOCIRCUIT)
			. += "<span class='notice'>There are no <i>firelock electronics</i> in the frame. The frame could be <b>cut</b> apart.</span>"

/obj/structure/firelock_frame/update_icon()
	..()
	icon_state = "frame[constructionStep]"

/obj/structure/firelock_frame/attackby(obj/item/C, mob/user)
	switch(constructionStep)
		if(CONSTRUCTION_PANEL_OPEN)
			if(C.tool_behaviour == TOOL_CROWBAR)
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] starts prying something out from [src]...</span>", \
									 "<span class='notice'>You begin prying out the wire cover...</span>")
				if(!C.use_tool(src, user, 50))
					return
				if(constructionStep != CONSTRUCTION_PANEL_OPEN)
					return
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] pries out a metal plate from [src], exposing the wires.</span>", \
									 "<span class='notice'>You remove the cover plate from [src], exposing the wires.</span>")
				constructionStep = CONSTRUCTION_WIRES_EXPOSED
				update_icon()
				return
			if(C.tool_behaviour == TOOL_WRENCH)
				var/obj/machinery/door/firedoor/A = locate(/obj/machinery/door/firedoor) in get_turf(src)
				if(A && A.dir == src.dir)
					to_chat(user, "<span class='warning'>There's already a firelock there.</span>")
					return
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] starts bolting down [src]...</span>", \
									 "<span class='notice'>You begin bolting [src]...</span>")
				if(!C.use_tool(src, user, 30))
					return
				var/obj/machinery/door/firedoor/D = locate(/obj/machinery/door/firedoor) in get_turf(src)
				if(D && D.dir == src.dir)
					return
				user.visible_message("<span class='notice'>[user] finishes the firelock.</span>", \
									 "<span class='notice'>You finish the firelock.</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				var/obj/machinery/door/firedoor/F = new firelock_type(get_turf(src))
				F.dir = src.dir
				F.update_icon()
				qdel(src)
				return
			if(istype(C, /obj/item/stack/sheet/plasteel))
				var/obj/item/stack/sheet/plasteel/P = C
				if(reinforced)
					to_chat(user, "<span class='warning'>[src] is already reinforced.</span>")
					return
				if(P.get_amount() < 2)
					to_chat(user, "<span class='warning'>You need more plasteel to reinforce [src].</span>")
					return
				user.visible_message("<span class='notice'>[user] begins reinforcing [src]...</span>", \
									 "<span class='notice'>You begin reinforcing [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				if(do_after(user, 60, target = src))
					if(constructionStep != CONSTRUCTION_PANEL_OPEN || reinforced || P.get_amount() < 2 || !P)
						return
					user.visible_message("<span class='notice'>[user] reinforces [src].</span>", \
										 "<span class='notice'>You reinforce [src].</span>")
					playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
					P.use(2)
					reinforced = TRUE
					firelock_type = /obj/machinery/door/firedoor/heavy
				return

		if(CONSTRUCTION_WIRES_EXPOSED)
			if(C.tool_behaviour == TOOL_WIRECUTTER)
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] starts cutting the wires from [src]...</span>", \
									 "<span class='notice'>You begin removing [src]'s wires...</span>")
				if(!C.use_tool(src, user, 60))
					return
				if(constructionStep != CONSTRUCTION_WIRES_EXPOSED)
					return
				user.visible_message("<span class='notice'>[user] removes the wires from [src].</span>", \
									 "<span class='notice'>You remove the wiring from [src], exposing the circuit board.</span>")
				new/obj/item/stack/cable_coil(get_turf(src), 5)
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
			if(C.tool_behaviour == TOOL_CROWBAR)
				C.play_tool_sound(src)
				user.visible_message("<span class='notice'>[user] starts prying a metal plate into [src]...</span>", \
									 "<span class='notice'>You begin prying the cover plate back onto [src]...</span>")
				if(!C.use_tool(src, user, 80))
					return
				if(constructionStep != CONSTRUCTION_WIRES_EXPOSED)
					return
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				user.visible_message("<span class='notice'>[user] pries the metal plate into [src].</span>", \
									 "<span class='notice'>You pry [src]'s cover plate into place, hiding the wires.</span>")
				constructionStep = CONSTRUCTION_PANEL_OPEN
				update_icon()
				return
		if(CONSTRUCTION_GUTTED)
			if(C.tool_behaviour == TOOL_CROWBAR)
				user.visible_message("<span class='notice'>[user] begins removing the circuit board from [src]...</span>", \
									 "<span class='notice'>You begin prying out the circuit board from [src]...</span>")
				if(!C.use_tool(src, user, 50, volume=50))
					return
				if(constructionStep != CONSTRUCTION_GUTTED)
					return
				user.visible_message("<span class='notice'>[user] removes [src]'s circuit board.</span>", \
									 "<span class='notice'>You remove the circuit board from [src].</span>")
				new /obj/item/electronics/firelock(drop_location())
				constructionStep = CONSTRUCTION_NOCIRCUIT
				update_icon()
				return
			if(istype(C, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/B = C
				if(B.get_amount() < 5)
					to_chat(user, "<span class='warning'>You need more wires to add wiring to [src].</span>")
					return
				user.visible_message("<span class='notice'>[user] begins wiring [src]...</span>", \
									 "<span class='notice'>You begin adding wires to [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				if(do_after(user, 60, target = src))
					if(constructionStep != CONSTRUCTION_GUTTED || B.get_amount() < 5 || !B)
						return
					user.visible_message("<span class='notice'>[user] adds wires to [src].</span>", \
										 "<span class='notice'>You wire [src].</span>")
					playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
					B.use(5)
					constructionStep = CONSTRUCTION_WIRES_EXPOSED
					update_icon()
				return
		if(CONSTRUCTION_NOCIRCUIT)
			if(C.tool_behaviour == TOOL_WELDER)
				if(!C.tool_start_check(user, amount=1))
					return
				user.visible_message("<span class='notice'>[user] begins cutting apart [src]'s frame...</span>", \
									 "<span class='notice'>You begin slicing [src] apart...</span>")

				if(C.use_tool(src, user, 40, volume=50, amount=1))
					if(constructionStep != CONSTRUCTION_NOCIRCUIT)
						return
					var/turf/T = get_turf(src)
					switch(firelock_type)
						if(/obj/machinery/door/firedoor/heavy)
							user.visible_message("<span class='notice'>[user] cuts apart [src]!</span>", \
										 "<span class='notice'>You cut [src] into iron and plasteel.</span>")
							new /obj/item/stack/sheet/plasteel(T, 2)
							new /obj/item/stack/sheet/iron(T, 3)
						if(/obj/machinery/door/firedoor/window)
							user.visible_message("<span class='notice'>[user] cuts apart [src]!</span>", \
										 "<span class='notice'>You cut [src] into reinforced glass.</span>")
							new /obj/item/stack/sheet/rglass(T,2)
						else
							user.visible_message("<span class='notice'>[user] cuts apart [src]!</span>", \
										 "<span class='notice'>You cut [src] into iron.</span>")
							new /obj/item/stack/sheet/iron(T, 3)
					qdel(src)
				return
			if(istype(C, /obj/item/electronics/firelock))
				user.visible_message("<span class='notice'>[user] starts adding [C] to [src]...</span>", \
									 "<span class='notice'>You begin adding a circuit board to [src]...</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				if(!do_after(user, 40, target = src))
					return
				if(constructionStep != CONSTRUCTION_NOCIRCUIT)
					return
				qdel(C)
				user.visible_message("<span class='notice'>[user] adds a circuit to [src].</span>", \
									 "<span class='notice'>You insert and secure [C].</span>")
				playsound(get_turf(src), 'sound/items/deconstruct.ogg', 50, 1)
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
			if(istype(C, /obj/item/electroadaptive_pseudocircuit))
				var/obj/item/electroadaptive_pseudocircuit/P = C
				if(!P.adapt_circuit(user, 30))
					return
				user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
				"<span class='notice'>You adapt a firelock circuit and slot it into the assembly.</span>")
				constructionStep = CONSTRUCTION_GUTTED
				update_icon()
				return
	return ..()

/obj/structure/firelock_frame/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 16)
	else if((constructionStep == CONSTRUCTION_NOCIRCUIT) && (the_rcd.upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS))
		return list("mode" = RCD_UPGRADE_SIMPLE_CIRCUITS, "delay" = 20, "cost" = 1)
	return FALSE

/obj/structure/firelock_frame/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_UPGRADE_SIMPLE_CIRCUITS)
			user.visible_message("<span class='notice'>[user] fabricates a circuit and places it into [src].</span>", \
			"<span class='notice'>You adapt a firelock circuit and slot it into the assembly.</span>")
			constructionStep = CONSTRUCTION_GUTTED
			update_icon()
			return TRUE
		if(RCD_DECONSTRUCT)
			to_chat(user, "<span class='notice'>You deconstruct [src].</span>")
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/firelock_frame/heavy
	name = "heavy firelock frame"
	reinforced = TRUE
	firelock_type = /obj/machinery/door/firedoor/heavy

/obj/structure/firelock_frame/border
	name = "firelock frame"
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	icon_state = "door_frame"
	density = FALSE
	firelock_type = /obj/machinery/door/firedoor/border_only

/obj/structure/firelock_frame/border/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, PROC_REF(can_be_rotated)))

/obj/structure/firelock_frame/border/proc/can_be_rotated(mob/user, rotation_type)
	if (anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	return TRUE

/obj/structure/firelock_frame/border/update_icon()
	return

/obj/structure/firelock_frame/window
	name = "window firelock frame"
	icon = 'icons/obj/doors/doorfirewindow.dmi'
	icon_state = "door_frame"
	firelock_type = /obj/machinery/door/firedoor/window

/obj/structure/firelock_frame/window/update_icon()
	return

#undef CONSTRUCTION_COMPLETE
#undef CONSTRUCTION_PANEL_OPEN
#undef CONSTRUCTION_WIRES_EXPOSED
#undef CONSTRUCTION_GUTTED
#undef CONSTRUCTION_NOCIRCUIT

#undef FIRE_ALARM
