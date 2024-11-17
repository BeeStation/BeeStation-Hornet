/*CONTENTS
Buildable pipes
Buildable meters
*/

//construction defines are in __defines/pipe_construction.dm
//update those defines ANY TIME an atmos path is changed...
//...otherwise construction will stop working

/obj/item/pipe
	name = "pipe"
	desc = "A pipe."
	var/pipe_type
	var/pipename
	force = 7
	throwforce = 7
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "simple"
	item_state = "buildpipe"
	w_class = WEIGHT_CLASS_NORMAL
	var/piping_layer = PIPING_LAYER_DEFAULT
	var/RPD_type
	/// whether it can be painted
	var/paintable = FALSE

/obj/item/pipe/directional
	RPD_type = PIPE_UNARY
/obj/item/pipe/binary
	RPD_type = PIPE_STRAIGHT
/obj/item/pipe/binary/bendable
	RPD_type = PIPE_BENDABLE
/obj/item/pipe/trinary
	RPD_type = PIPE_TRINARY
/obj/item/pipe/trinary/flippable
	RPD_type = PIPE_TRIN_M
	var/flipped = FALSE
/obj/item/pipe/quaternary
	RPD_type = PIPE_ONEDIR

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/pipe)

/obj/item/pipe/Initialize(mapload, _pipe_type, _dir, obj/machinery/atmospherics/make_from)
	if(make_from)
		make_from_existing(make_from)
	else
		pipe_type = _pipe_type
		setDir(_dir)

	update()
	pixel_x += rand(-5, 5)
	pixel_y += rand(-5, 5)

	//Flipping handled manually due to custom handling for trinary pipes
	AddComponent(/datum/component/simple_rotation, ROTATION_NO_FLIPPING)
	return ..()

/obj/item/pipe/proc/make_from_existing(obj/machinery/atmospherics/make_from)
	setDir(make_from.dir)
	pipename = make_from.name
	add_atom_colour(make_from.color, FIXED_COLOUR_PRIORITY)
	pipe_type = make_from.type
	paintable = make_from.paintable

/obj/item/pipe/trinary/flippable/make_from_existing(obj/machinery/atmospherics/components/trinary/make_from)
	..()
	if(make_from.flipped)
		do_a_flip()

/obj/item/pipe/dropped()
	..()
	if(loc)
		set_piping_layer(piping_layer)

/obj/item/pipe/proc/set_piping_layer(new_layer = PIPING_LAYER_DEFAULT)
	var/obj/machinery/atmospherics/fakeA = pipe_type

	if(initial(fakeA.pipe_flags) & PIPING_ALL_LAYER)
		new_layer = PIPING_LAYER_DEFAULT
	piping_layer = new_layer

	PIPING_LAYER_SHIFT(src, piping_layer)
	layer = initial(layer) + ((piping_layer - PIPING_LAYER_DEFAULT) * PIPING_LAYER_LCHANGE)

/obj/item/pipe/proc/update()
	var/obj/machinery/atmospherics/fakeA = pipe_type
	name = "[initial(fakeA.name)] fitting"
	icon_state = initial(fakeA.pipe_state)
	if(ispath(pipe_type,/obj/machinery/atmospherics/pipe/heat_exchanging))
		resistance_flags |= FIRE_PROOF | LAVA_PROOF

/obj/item/pipe/verb/flip()
	set category = "Object"
	set name = "Invert Pipe"
	set src in view(1)

	if(usr.incapacitated() || !isliving(usr))
		return

	do_a_flip()

/obj/item/pipe/proc/do_a_flip()
	setDir(turn(dir, -180))

/obj/item/pipe/trinary/flippable/do_a_flip()
	setDir(turn(dir, flipped ? 45 : -45))
	flipped = !flipped

/obj/item/pipe/Move()
	var/old_dir = dir
	..()
	setDir(old_dir) //pipes changing direction when moved is just annoying and buggy

// Convert dir of fitting into dir of built component
/obj/item/pipe/proc/fixed_dir()
	return dir

/obj/item/pipe/binary/fixed_dir()
	. = dir
	if(dir == SOUTH)
		. = NORTH
	else if(dir == WEST)
		. = EAST

/obj/item/pipe/trinary/flippable/fixed_dir()
	. = dir
	if(dir in GLOB.diagonals)
		. = turn(dir, 45)

/obj/item/pipe/attack_self(mob/user)
	setDir(turn(dir,-90))

/obj/item/pipe/wrench_act(mob/living/user, obj/item/wrench/W)
	if(!isturf(loc))
		return TRUE

	add_fingerprint(user)

	var/obj/machinery/atmospherics/fakeA = pipe_type
	var/flags = initial(fakeA.pipe_flags)
	for(var/obj/machinery/atmospherics/M in loc)
		if((M.pipe_flags & flags & PIPING_ONE_PER_TURF))	//Only one dense/requires density object per tile, eg connectors/cryo/heater/coolers.
			to_chat(user, "<span class='warning'>Something is hogging the tile!</span>")
			return TRUE
		if((M.piping_layer != piping_layer) && !((M.pipe_flags | flags) & PIPING_ALL_LAYER)) //don't continue if either pipe goes across all layers
			continue
		if(M.GetInitDirections() & SSair.get_init_dirs(pipe_type, fixed_dir()))	// matches at least one direction on either type of pipe
			to_chat(user, "<span class='warning'>There is already a pipe at that location!</span>")
			return TRUE
	// no conflicts found

	var/obj/machinery/atmospherics/A = new pipe_type(loc)
	build_pipe(A)
	A.on_construction(color, piping_layer)
	transfer_fingerprints_to(A)

	W.play_tool_sound(src)
	user.visible_message( \
		"[user] fastens \the [src].", \
		"<span class='notice'>You fasten \the [src].</span>", \
		"<span class='italics'>You hear ratcheting.</span>")

	qdel(src)

/obj/item/pipe/proc/build_pipe(obj/machinery/atmospherics/A)
	A.setDir(fixed_dir())
	A.SetInitDirections()

	if(pipename)
		A.name = pipename
	if(A.on)
		// Certain pre-mapped subtypes are on by default, we want to preserve
		// every other aspect of these subtypes (name, pre-set filters, etc.)
		// but they shouldn't turn on automatically when wrenched.
		A.on = FALSE

/obj/item/pipe/trinary/flippable/build_pipe(obj/machinery/atmospherics/components/trinary/T)
	..()
	T.flipped = flipped

/obj/item/pipe/directional/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] shoves [src] in [user.p_their()] mouth and turns it on! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		for(var/i=1 to 20)
			C.vomit(0, TRUE, FALSE, 4, FALSE)
			if(prob(20))
				C.spew_organ()
			sleep(5)
		C.blood_volume = 0
	return(OXYLOSS|BRUTELOSS)

/obj/item/pipe/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The pipe layer is set to [piping_layer].</span>"
	. += "<span class='notice'>You can change the pipe layer by Right-Clicking the device.</span>"

/obj/item/pipe/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	var/layer_to_set = (piping_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (piping_layer + 1)
	set_piping_layer(layer_to_set)
	balloon_alert(user, "pipe layer set to [piping_layer]")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/pipe/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/item/pipe/trinary/flippable/examine(mob/user)
	. = ..()
	. += "<span class='notice'>You can flip the device by Right-Clicking it.</span>"

/obj/item/pipe/trinary/flippable/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	do_a_flip()
	balloon_alert(user, "pipe was flipped")
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/pipe_meter
	name = "meter"
	desc = "A meter that can be laid on pipes."
	icon = 'icons/obj/atmospherics/pipes/pipe_item.dmi'
	icon_state = "meter"
	item_state = "buildpipe"
	w_class = WEIGHT_CLASS_BULKY
	var/piping_layer = PIPING_LAYER_DEFAULT

/obj/item/pipe_meter/wrench_act(mob/living/user, obj/item/wrench/W)

	var/obj/machinery/atmospherics/pipe/pipe
	for(var/obj/machinery/atmospherics/pipe/P in loc)
		if(P.piping_layer == piping_layer)
			pipe = P
			break
	if(!pipe)
		to_chat(user, "<span class='warning'>You need to fasten it to a pipe!</span>")
		return TRUE
	new /obj/machinery/meter(loc, piping_layer)
	W.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You fasten the meter to the pipe.</span>")
	qdel(src)

/obj/item/pipe_meter/screwdriver_act(mob/living/user, obj/item/S)
	. = ..()
	if(.)
		return TRUE

	if(!isturf(loc))
		to_chat(user, "<span class='warning'>You need to fasten it to the floor!</span>")
		return TRUE

	new /obj/machinery/meter/turf(loc, piping_layer)
	S.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You fasten the meter to the [loc.name].</span>")
	qdel(src)

/obj/item/pipe_meter/dropped()
	..()
	if(loc)
		setAttachLayer(piping_layer)

/obj/item/pipe_meter/proc/setAttachLayer(new_layer = PIPING_LAYER_DEFAULT)
	piping_layer = new_layer
	PIPING_LAYER_DOUBLE_SHIFT(src, piping_layer)
