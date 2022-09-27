/obj/machinery/ecto_sniffer
	name = "ectoscopic sniffer"
	desc = "A highly sensitive parascientific instrument calibrated to detect the slightest whiff of ectoplasm."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "ecto_sniffer"
	density = FALSE
	anchored = FALSE
	pass_flags = PASSTABLE
	circuit = /obj/item/circuitboard/machine/ecto_sniffer
	///determines if the device if the power switch is turned on or off. Useful if the ghosts are too annoying.
	var/on = TRUE
	///If this var set to false the ghosts will not be able interact with the machine, say if the machine is silently disabled by cutting the internal wire.
	var/sensor_enabled = TRUE
	///List of ckeys containing players who have recently activated the device, players on this list are prohibited from activating the device untill their residue decays.
	var/list/ectoplasmic_residues = list()

/obj/machinery/ecto_sniffer/Initialize()
	. = ..()
	wires = new/datum/wires/ecto_sniffer(src)

/obj/machinery/ecto_sniffer/attack_ghost(mob/user)
	if(!on || !sensor_enabled || !is_operational())
		return

	if(ectoplasmic_residues[user.ckey])
		to_chat(user, "<span class='warning'>You must wait for your ectoplasmic residue to decay off of [src]'s sensors!</span>")
		return

	if(is_banned_from(user.ckey, ROLE_POSIBRAIN))
		to_chat(user, "<span class='warning'>Central Command outlawed your soul from interacting with the living...</span>")
		return
	activate(user)

/obj/machinery/ecto_sniffer/proc/activate(mob/activator)
	flick("ecto_sniffer_flick", src)
	playsound(loc, 'sound/machines/ectoscope_beep.ogg', 25)
	visible_message("<span class='notice'>[src] beeps, detecting ectoplasm! There may be additional positronic brain matrixes available!</span>")
	use_power(10)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_GHOST_SUBMIT)
	if(activator?.ckey)
		ectoplasmic_residues[activator.ckey] = TRUE
		addtimer(CALLBACK(src, .proc/clear_residue, activator.ckey), 30 SECONDS)

/obj/machinery/ecto_sniffer/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	add_fingerprint(user)
	on = !on
	balloon_alert(user, "You turn the sniffer [on ? "on" : "off"].")
	//update_appearance() - not working until update_appearance is ported
	update_icon()

/obj/machinery/ecto_sniffer/update_icon_state()
	. = ..()
	if(panel_open)
		icon_state = "[initial(icon_state)]_open"
	else
		icon_state = "[initial(icon_state)][(is_operational() && on) ? null : "-p"]"


/obj/machinery/ecto_sniffer/wrench_act(mob/living/user, obj/item/tool)
	return default_unfasten_wrench(user, tool)

/obj/machinery/ecto_sniffer/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!.)
		return default_deconstruction_screwdriver(user, "ecto_sniffer_open", "ecto_sniffer", I)

/obj/machinery/ecto_sniffer/crowbar_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_crowbar(tool))
		return ..()

/obj/machinery/ecto_sniffer/Destroy()
	QDEL_NULL(wires)
	ectoplasmic_residues = null
	. = ..()

///Removes the ghost from the ectoplasmic_residues list and lets them know they are free to activate the sniffer again.
/obj/machinery/ecto_sniffer/proc/clear_residue(ghost_ckey)
	ectoplasmic_residues[ghost_ckey] = FALSE
	var/mob/ghost = get_mob_by_ckey(ghost_ckey)
	if(!ghost || isliving(ghost))
		return
	to_chat(ghost, "[FOLLOW_LINK(ghost, src)] <span class='nicegreen'>The coating of ectoplasmic residue you left on [src]'s sensors has decayed.</span>")


/obj/item/ecto_alert
	name = "ectoscopic alerter"
	desc = "A small handheld device that listens for electroscopic transmissions."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "ecto_portable"
	w_class = WEIGHT_CLASS_SMALL
	var/on = TRUE
	/// last time it recieved a signal
	var/last_trigger = 0
	/// how many minutes until the last trigger is cleared from the examinetext
	var/clear_after = 5

/obj/item/ecto_alert/Initialize(mapload)
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_GHOST_SUBMIT, .proc/activate)

/obj/item/ecto_alert/attack_self(mob/user)
	. = ..()
	on = !on
	to_chat(user, "<span class='notice'>You turn \the [src] [on ? "ON" : "OFF"].")

/obj/item/ecto_alert/examine(mob/user)
	. = ..()
	if(last_trigger > world.time + clear_after MINUTES)  // only displays from the last 5 minutes
		var/display_time = FLOOR((last_trigger - world.time) / 10)
		. += "It's last recorded trigger is [display_time], and will clear in [clear_after] minutes."

/obj/item/ecto_alert/proc/activate(datum/source)
	if(!on)
		return
	flick("[initial(icon)]_flick", src)
	playsound(loc, 'sound/machines/ectoscope_beep.ogg', 15)
	visible_message("<span class='notice'>\The [src] relays an ectoscopic signal!</span>")
	last_trigger = world.time
