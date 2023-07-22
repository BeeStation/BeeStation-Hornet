/obj/machinery/quantumpad
	name = "quantum pad"
	desc = "A bluespace quantum-linked telepad used for teleporting objects to other quantum pads."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "qpad-idle"
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	active_power_usage = 5000
	obj_flags = CAN_BE_HIT | UNIQUE_RENAME
	circuit = /obj/item/circuitboard/machine/quantumpad
	var/teleport_cooldown = 400 //30 seconds base due to base parts
	var/teleport_speed = 50
	var/last_teleport //to handle the cooldown
	var/teleporting = FALSE //if it's in the process of teleporting
	var/power_efficiency = 1
	var/obj/machinery/quantumpad/linked_pad

	//mapping
	var/static/list/mapped_quantum_pads = list()
	var/map_pad_id = "" as text //what's my name
	var/map_pad_link_id = "" as text //who's my friend

/obj/machinery/quantumpad/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/quantum_pad(src)
	if(map_pad_id)
		mapped_quantum_pads[map_pad_id] = src

	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/quantumpad,
	))

/obj/machinery/quantumpad/Destroy()
	QDEL_NULL(wires)
	mapped_quantum_pads -= map_pad_id
	return ..()

/obj/machinery/quantumpad/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It is [ linked_pad ? "currently" : "not"] linked to another pad.</span>"
	if(!panel_open)
		. += "<span class='notice'>The panel is <i>screwed</i> in, obstructing the linking device.</span>"
	else
		. += "<span class='notice'>The <i>linking</i> device is now able to be <i>scanned<i> with a multitool.</span>"

/obj/machinery/quantumpad/RefreshParts()
	var/E = 0
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		E += C.rating
	power_efficiency = E
	E = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		E += M.rating
	teleport_speed = initial(teleport_speed)
	teleport_speed -= (E*10)
	teleport_cooldown = initial(teleport_cooldown)
	teleport_cooldown -= (E * 100)

/obj/machinery/quantumpad/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "pad-idle-o", "qpad-idle", I))
		return
	else if(panel_open && I.tool_behaviour == TOOL_WIRECUTTER)
		wires.interact(user)
		return TRUE

	if(panel_open)
		return

	if(istype(I, /obj/item/quantum_keycard))
		var/obj/item/quantum_keycard/K = I
		if(K.qpad)
			to_chat(user, "<span class='notice'>You insert [K] into [src]'s card slot, activating it.</span>")
			interact(user, K.qpad)
		else
			to_chat(user, "<span class='notice'>You insert [K] into [src]'s card slot, initiating the link procedure.</span>")
			if(do_after(user, 40, target = src))
				to_chat(user, "<span class='notice'>You complete the link between [K] and [src].</span>")
				K.qpad = src

	if(default_deconstruction_crowbar(I))
		return

	return ..()

REGISTER_BUFFER_HANDLER(/obj/machinery/quantumpad)

DEFINE_BUFFER_HANDLER(/obj/machinery/quantumpad)
	if (panel_open)
		if (TRY_STORE_IN_BUFFER(buffer_parent, src))
			to_chat(user, "<span class='notice'>You save the data in [buffer_parent]'s buffer. It can now be saved to pads with closed panels.</span>")
			return COMPONENT_BUFFER_RECIEVED
		return NONE
	if(istype(buffer, /obj/machinery/quantumpad))
		if(buffer == src)
			to_chat(user, "<span class='warning'>You cannot link a pad to itself!</span>")
			return COMPONENT_BUFFER_RECIEVED
		else
			linked_pad = buffer
			to_chat(user, "<span class='notice'>You link [src] to the one in [buffer_parent]'s buffer.</span>")
			return COMPONENT_BUFFER_RECIEVED
	else
		to_chat(user, "<span class='warning'>There is no quantum pad data saved in [buffer_parent]'s buffer!</span>")
		return COMPONENT_BUFFER_RECIEVED

/obj/machinery/quantumpad/interact(mob/user, obj/machinery/quantumpad/target_pad = linked_pad)
	if(!target_pad || QDELETED(target_pad))
		if(!map_pad_link_id || !initMappedLink())
			to_chat(user, "<span class='warning'>Target pad not found!</span>")
			return

	if(world.time < last_teleport + teleport_cooldown)
		to_chat(user, "<span class='warning'>[src] is recharging power. Please wait [DisplayTimeText(last_teleport + teleport_cooldown - world.time)].</span>")
		return

	if(teleporting)
		to_chat(user, "<span class='warning'>[src] is charging up. Please wait.</span>")
		return

	if(target_pad.teleporting)
		to_chat(user, "<span class='warning'>Target pad is busy. Please wait.</span>")
		return

	if(target_pad.machine_stat & NOPOWER)
		to_chat(user, "<span class='warning'>Target pad is not responding to ping.</span>")
		return
	add_fingerprint(user)
	doteleport(user, target_pad)

/obj/machinery/quantumpad/proc/sparks()
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, get_turf(src))
	s.start()

/obj/machinery/quantumpad/attack_ghost(mob/dead/observer/ghost)
	. = ..()
	if(.)
		return
	if(!linked_pad && map_pad_link_id)
		initMappedLink()
	if(linked_pad)
		ghost.forceMove(get_turf(linked_pad))

/obj/machinery/quantumpad/proc/doteleport(mob/user, obj/machinery/quantumpad/target_pad = linked_pad)
	if(target_pad)
		playsound(get_turf(src), 'sound/weapons/flash.ogg', 25, 1)
		teleporting = TRUE

		spawn(teleport_speed)
			if(!src || QDELETED(src))
				teleporting = FALSE
				return
			if(machine_stat & NOPOWER)
				to_chat(user, "<span class='warning'>[src] is unpowered!</span>")
				teleporting = FALSE
				return
			if(!target_pad || QDELETED(target_pad) || target_pad.machine_stat & NOPOWER)
				to_chat(user, "<span class='warning'>Linked pad is not responding to ping. Teleport aborted.</span>")
				teleporting = FALSE
				return

			teleporting = FALSE
			last_teleport = world.time

			// use a lot of power
			use_power(10000 / power_efficiency)
			sparks()
			target_pad.sparks()

			flick("qpad-beam", src)
			playsound(get_turf(src), 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff_exponent = 5)
			flick("qpad-beam", target_pad)
			playsound(get_turf(target_pad), 'sound/weapons/emitter2.ogg', 25, 1, extrarange = 3, falloff_exponent = 5)
			for(var/atom/movable/ROI in get_turf(src))
				if(QDELETED(ROI))
					continue //sleeps in CHECK_TICK

				// if is anchored, don't let through
				if(ROI.anchored)
					if(isliving(ROI))
						var/mob/living/L = ROI
						//only TP living mobs buckled to non anchored items
						if(!L.buckled || L.buckled.anchored)
							continue
					//Don't TP ghosts
					else if(!isobserver(ROI))
						continue

				do_teleport(ROI, get_turf(target_pad),null,null,null,null,null,TRUE, channel = TELEPORT_CHANNEL_QUANTUM)
				CHECK_TICK

/obj/machinery/quantumpad/proc/initMappedLink()
	. = FALSE
	var/obj/machinery/quantumpad/link = mapped_quantum_pads[map_pad_link_id]
	if(link)
		linked_pad = link
		. = TRUE

/obj/item/paper/guides/quantumpad
	name = "Quantum Pad For Dummies"
	default_raw_text = "<center><b>Dummies Guide To Quantum Pads</b></center><br><br><center>Do you hate the concept of having to use your legs, let alone <i>walk</i> to places? Well, with the Quantum Pad (tm), never again will the fear of cardio keep you from going places!<br><br><c><b>How to set up your Quantum Pad(tm)</b></center><br><br>1.Unscrew the Quantum Pad(tm) you wish to link.<br>2. Use your multi-tool to cache the buffer of the Quantum Pad(tm) you wish to link.<br>3. Apply the multi-tool to the secondary Quantum Pad(tm) you wish to link to the first Quantum Pad(tm)<br><br><center>If you followed these instructions carefully, your Quantum Pad(tm) should now be properly linked together for near-instant movement across the station! Bear in mind that this is technically a one-way teleport, so you'll need to do the same process with the secondary pad to the first one if you wish to travel between both.</center>"

/obj/item/circuit_component/quantumpad
	display_name = "Quantum Pad"
	desc = "A bluespace quantum-linked telepad used for teleporting objects to other quantum pads."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/datum/port/input/target_pad
	var/datum/port/output/failed

	var/obj/machinery/quantumpad/attached_pad

/obj/item/circuit_component/quantumpad/populate_ports()
	target_pad = add_input_port("Target Pad", PORT_TYPE_ATOM)
	failed = add_output_port("On Fail", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/quantumpad/register_usb_parent(atom/movable/parent)
	. = ..()
	if(istype(parent, /obj/machinery/quantumpad))
		attached_pad = parent

/obj/item/circuit_component/quantumpad/unregister_usb_parent(atom/movable/parent)
	attached_pad = null
	return ..()

/obj/item/circuit_component/quantumpad/input_received(datum/port/input/port)
	if(!attached_pad)
		return

	var/obj/machinery/quantumpad/targeted_pad = target_pad.value

	if((!attached_pad.linked_pad || QDELETED(attached_pad.linked_pad)) && !(targeted_pad && istype(targeted_pad)))
		failed.set_output(COMPONENT_SIGNAL)
		return

	if(world.time < attached_pad.last_teleport + attached_pad.teleport_cooldown)
		failed.set_output(COMPONENT_SIGNAL)
		return

	if(targeted_pad && istype(targeted_pad))
		if(attached_pad.teleporting || targeted_pad.teleporting)
			failed.set_output(COMPONENT_SIGNAL)
			return

		if(targeted_pad.machine_stat & NOPOWER)
			failed.set_output(COMPONENT_SIGNAL)
			return
		attached_pad.doteleport(target_pad = targeted_pad)
	else
		if(attached_pad.teleporting || attached_pad.linked_pad.teleporting)
			failed.set_output(COMPONENT_SIGNAL)
			return

		if(attached_pad.linked_pad.machine_stat & NOPOWER)
			failed.set_output(COMPONENT_SIGNAL)
			return
		attached_pad.doteleport(target_pad = attached_pad.linked_pad)
