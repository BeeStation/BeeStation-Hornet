/obj/item/assembly_holder
	name = "Assembly"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "holder"
	item_state = "assembly"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 7

	var/list/obj/item/assembly/assemblies 	/// used to store the list of assemblies making up our assembly holder

/obj/item/assembly_holder/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation,ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS )

/obj/item/assembly_holder/Destroy()
	QDEL_LAZYLIST(assemblies)
	return ..()

/obj/item/assembly_holder/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	return

/obj/item/assembly_holder/Exited(atom/movable/gone, direction)
	. = ..()
	LAZYREMOVE(assemblies, gone)

/obj/item/assembly_holder/IsAssemblyHolder()
	return TRUE

/obj/item/assembly_holder/examine(mob/user)
	. = ..()
	for(var/assembly in assemblies)
		if(istype(assembly, /obj/item/assembly/timer))
			var/obj/item/assembly/timer/timer = assembly
			. += "<span class='notice'>The timer is [timer.timing ? "counting down from [timer.time]":"set for [timer.time] seconds"].</span>"

/obj/item/assembly_holder/Moved(atom/old_loc, movement_dir)
	. = ..()
	on_move(old_loc, movement_dir)

/obj/item/assembly_holder/proc/on_move(atom/old_loc, movement_dir)
	for(var/obj/item/assembly/infra/assembly in assemblies)
		assembly.on_move(old_loc, movement_dir)

/obj/item/assembly_holder/proc/assemble(obj/item/assembly/A, obj/item/assembly/A2, mob/user)
	attach(A,user)
	attach(A2,user)
	name = "[A.name]-[A2.name] assembly"
	update_icon()
	SSblackbox.record_feedback("tally", "assembly_made", 1, "[initial(A.name)]-[initial(A2.name)]")

// on_attach: Pass on_attach message to child assemblies
/obj/item/assembly_holder/proc/on_attach(var/obj/structure/reagent_dispensers/rig)
	var/obj/item/newloc = loc
	if(!newloc.IsSpecialAssembly() && !newloc.IsAssemblyHolder())
		return
	for(var/obj/item/assembly/assembly in assemblies)
		assembly.on_attach(rig)

/obj/item/assembly_holder/proc/try_add_assembly(obj/item/assembly/attached_assembly, mob/user)
	if(attached_assembly.secured)
		balloon_alert(attached_assembly, "not attachable!")
		return FALSE

	if(LAZYLEN(assemblies) >= HOLDER_MAX_ASSEMBLIES)
		balloon_alert(user, "too many assemblies!")
		return FALSE

	if(attached_assembly.assembly_flags & ASSEMBLY_NO_DUPLICATES)
		if(locate(attached_assembly.type) in assemblies)
			balloon_alert(user, "can't attach another of that!")
			return FALSE

	add_assembly(attached_assembly, user)
	balloon_alert(user, "part attached")
	return TRUE

/**
 * Adds an assembly to the assembly holder
 *
 * This proc is used to add an assembly to the assembly holder, update the appearance, and the name of it.
 * Arguments:
 * * attached_assembly - assembly we are adding to the assembly holder
 * * user - user we pass into attach()
 */
/obj/item/assembly_holder/proc/add_assembly(obj/item/assembly/attached_assembly, mob/user)
	attach(attached_assembly, user)
	name = ""
	for(var/obj/item/assembly/assembly as anything in assemblies)
		name += "[assembly.name]-"
	name = splicetext(name, length(name), length(name) + 1, "")
	name += " assembly"
	update_appearance()

/obj/item/assembly_holder/proc/attach(obj/item/assembly/A, mob/user)
	if(!A.remove_item_from_storage(src))
		if(user)
			user.transferItemToLoc(A, src)
		else
			A.forceMove(src)
	A.holder = src
	A.toggle_secure()
	LAZYADD(assemblies, A)
	A.holder_movement()
	A.on_attach()

/obj/item/assembly_holder/update_icon(updates=ALL)
	. = ..()
	master?.update_appearance(updates)

/obj/item/assembly_holder/update_overlays()
	. = ..()
	for(var/i in 1 to LAZYLEN(assemblies))
		if(i % 2 == 1)
			var/obj/item/assembly/assembly = assemblies[i]
			. += "[assembly.icon_state]_left"
			for(var/left_overlay in assembly.attached_overlays)
				. += "[left_overlay]_l"
		if(i % 2 == 0)
			var/obj/item/assembly/assembly = assemblies[i]
			var/mutable_appearance/right = mutable_appearance(icon, "[assembly.icon_state]_left")
			right.transform = matrix(-1, 0, 0, 0, 1, 0)
			for(var/right_overlay in assembly.attached_overlays)
				right.add_overlay("[right_overlay]_l")
			. += right

/obj/item/assembly_holder/on_found(mob/finder)
	for(var/obj/item/assembly/assembly as anything in assemblies)
		assembly.on_found(finder)

/obj/item/assembly_holder/setDir()
	. = ..()
	for(var/obj/item/assembly/assembly as anything in assemblies)
		assembly.holder_movement()


/obj/item/assembly_holder/dropped(mob/user)
	. = ..()
	for(var/obj/item/assembly/assembly as anything in assemblies)
		assembly.dropped(user)

/obj/item/assembly_holder/attack_hand(mob/living/user, list/modifiers)//Perhapse this should be a holder_pickup proc instead, can add if needbe I guess
	. = ..()
	if(.)
		return
	for(var/obj/item/assembly/assembly as anything in assemblies)
		assembly.attack_hand(user, modifiers) // Note override in assembly.dm to prevent side effects here

/obj/item/assembly_holder/attackby(obj/item/weapon, mob/user, params)
	if(isassembly(weapon))
		try_add_assembly(weapon, user)
		return

	return ..()

/obj/item/assembly_holder/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/item/assembly_holder/screwdriver_act(mob/user, obj/item/tool)
	if(..())
		return TRUE
	balloon_alert(user, "disassembled")
	for(var/obj/item/assembly/assembly as anything in assemblies)
		assembly.on_detach()
		LAZYREMOVE(assemblies, assembly)
	qdel(src)
	return TRUE

/obj/item/assembly_holder/attack_self(mob/user)
	src.add_fingerprint(user)
	if(LAZYLEN(assemblies) == 1)
		balloon_alert(user, "part missing!")
		return

	for(var/obj/item/assembly/assembly as anything in assemblies)
		assembly.attack_self(user)


/**
 * this proc is used to process the activation of the assembly holder
 *
 * This proc is usually called by signalers, timers, or anything that can trigger and
 * send a pulse to the assembly holder, which then calls this proc that actually activates the assemblies
 * Arguments:
 * * /obj/D - the device we sent the pulse from which called this proc
 */
/obj/item/assembly_holder/proc/process_activation(obj/D)
	if(!D)
		return FALSE
	if(LAZYLEN(assemblies) >= 2)
		for(var/obj/item/assembly/assembly as anything in assemblies)
			if(assembly != D)
				assembly.pulsed()
	if(master)
		master.receive_signal()
	return TRUE
