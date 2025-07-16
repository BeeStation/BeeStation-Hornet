/obj/machinery/ecto_sniffer
	name = "ectoscopic sniffer"
	desc = "A highly sensitive parascientific instrument calibrated to detect the slightest whiff of ectoplasm."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "ecto_sniffer"
	density = FALSE
	anchored = TRUE
	pass_flags = PASSTABLE
	circuit = /obj/item/circuitboard/machine/ecto_sniffer
	///determines if the device if the power switch is turned on or off. Useful if the ghosts are too annoying.
	var/on = TRUE
	///If this var set to false the ghosts will not be able interact with the machine, say if the machine is silently disabled by cutting the internal wire.
	var/sensor_enabled = TRUE
	///List of ckeys containing players who have recently activated the device, players on this list are prohibited from activating the device until their residue decays.
	var/list/ectoplasmic_residues = list()
	///Internal radio
	var/obj/item/radio/radio
	///Cooldown for radio, prevents spam
	COOLDOWN_DECLARE(radio_cooldown)

/obj/machinery/ecto_sniffer/Initialize(mapload)
	. = ..()
	wires = new/datum/wires/ecto_sniffer(src)
	radio = new(src)
	radio.keyslot = new /obj/item/encryptionkey/headset_sci
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()

/obj/machinery/ecto_sniffer/attack_ghost(mob/user)
	if(!on || !sensor_enabled || !is_operational)
		return

	if(ectoplasmic_residues[user.ckey])
		to_chat(user, span_warning("You must wait for your ectoplasmic residue to decay off of [src]'s sensors!"))
		return

	if(is_banned_from(user.ckey, ROLE_POSIBRAIN))
		to_chat(user, span_warning("Central Command outlawed your soul from interacting with the living..."))
		return

	activate(user)

/obj/machinery/ecto_sniffer/proc/activate(mob/activator)
	flick("ecto_sniffer_flick", src)
	playsound(loc, 'sound/machines/ectoscope_beep.ogg', 25)

	if(COOLDOWN_FINISHED(src, radio_cooldown))
		COOLDOWN_START(src, radio_cooldown, 3 MINUTES)
		radio.talk_into(src, "Ectoplasm has been detected! There may be additional positronic brain matrices available!", RADIO_CHANNEL_SCIENCE)
	visible_message(span_notice("[src] has detected ectoplasm! There may be additional positronic brain matrices available!"))

	use_power(10)
	if(activator?.ckey)
		ectoplasmic_residues[activator.ckey] = TRUE
		activator.log_message("activated an ecto sniffer", LOG_ATTACK)
		addtimer(CALLBACK(src, PROC_REF(clear_residue), activator.ckey), 30 SECONDS)

SCREENTIP_ATTACK_HAND(/obj/machinery/ecto_sniffer, "Toggle")

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
		icon_state = "[initial(icon_state)][(is_operational && on) ? null : "-p"]"


/obj/machinery/ecto_sniffer/wrench_act(mob/living/user, obj/item/tool)
	to_chat(user, span_notice("You need to deconstruct the [src] before moving it."))
	return TRUE

/obj/machinery/ecto_sniffer/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!.)
		return default_deconstruction_screwdriver(user, "ecto_sniffer_open", "ecto_sniffer", I)

/obj/machinery/ecto_sniffer/crowbar_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_crowbar(tool))
		return ..()

/obj/machinery/ecto_sniffer/Destroy()
	QDEL_NULL(wires)
	QDEL_NULL(radio)
	ectoplasmic_residues = null
	. = ..()

///Removes the ghost from the ectoplasmic_residues list and lets them know they are free to activate the sniffer again.
/obj/machinery/ecto_sniffer/proc/clear_residue(ghost_ckey)
	ectoplasmic_residues[ghost_ckey] = FALSE
	var/mob/ghost = get_mob_by_ckey(ghost_ckey)
	if(!ghost || isliving(ghost))
		return
	to_chat(ghost, "[FOLLOW_LINK(ghost, src)] [span_nicegreen("The coating of ectoplasmic residue you left on [src]'s sensors has decayed.")]")
