/obj/item/organ/cyberimp/bci
	name = "brain-computer interface"
	desc = "An implant that can be placed in a user's head to control circuits using their brain."
	icon = 'icons/obj/wiremod.dmi'
	icon_state = "bci"
	visual = FALSE
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY

	light_range = 0

/obj/item/organ/cyberimp/bci/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/bci_core,
	), SHELL_CAPACITY_SMALL)

/obj/item/organ/cyberimp/bci/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()

	// Organs are put in nullspace, but this breaks circuit interactions
	forceMove(receiver)

/obj/item/organ/cyberimp/bci/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced)
	if (owner)
		// Otherwise say_dead will be called.
		// It's intentional that a circuit for a dead person does not speak from the shell.
		if (owner.stat == DEAD)
			return

		owner.say(message, forced = "circuit speech")
	else
		return ..()

/obj/item/circuit_component/equipment_action/bci
	display_name = "BCI Action"
	desc = "Represents an action the user can take when implanted with the brain-computer interface."
	required_shells = list(/obj/item/organ/cyberimp/bci)

	/// A reference to the action button itself
	var/datum/action/innate/bci_action/bci_action

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/circuit_component/equipment_action)

/obj/item/circuit_component/equipment_action/bci/Destroy()
	QDEL_NULL(bci_action)
	return ..()

/obj/item/circuit_component/equipment_action/bci/register_shell(atom/movable/shell)
	. = ..()
	var/obj/item/organ/cyberimp/bci/bci = shell
	if(istype(bci))
		bci_action = new(src)
		update_action()

		bci.actions += list(bci_action)

/obj/item/circuit_component/equipment_action/bci/unregister_shell(atom/movable/shell)
	var/obj/item/organ/cyberimp/bci/bci = shell
	if(istype(bci))
		bci.actions -= bci_action
		QDEL_NULL(bci_action)
	return ..()

/obj/item/circuit_component/equipment_action/bci/input_received(datum/port/input/port)
	if (!isnull(bci_action))
		update_action()

/obj/item/circuit_component/equipment_action/bci/update_action()
	bci_action.name = button_name.value
	bci_action.button_icon_state = "[replacetextEx(LOWER_TEXT(icon_options.value), " ", "_")]"
	bci_action.update_buttons()

/datum/action/innate/bci_action
	name = "Action"
	icon_icon = 'icons/hud/actions/actions_items.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "power_green"

	var/obj/item/circuit_component/equipment_action/bci/circuit_component

/datum/action/innate/bci_action/New(obj/item/circuit_component/equipment_action/bci/circuit_component)
	..()

	src.circuit_component = circuit_component

/datum/action/innate/bci_action/Destroy()
	circuit_component.bci_action = null
	circuit_component = null

	return ..()

/datum/action/innate/bci_action/on_activate()
	circuit_component.signal.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/bci_core
	display_name = "BCI Core"
	desc = "Controls the core operations of the BCI."

	/// A reference to the action button to look at charge/get info
	var/datum/action/innate/bci_charge_action/charge_action
	var/datum/port/input/message
	var/datum/port/input/send_message_signal
	var/datum/port/output/user_port
	var/datum/weakref/user

/obj/item/circuit_component/bci_core/populate_ports()
	message = add_input_port("Message", PORT_TYPE_STRING)
	send_message_signal = add_input_port("Send Message", PORT_TYPE_SIGNAL)

	user_port = add_output_port("User", PORT_TYPE_ATOM)

/obj/item/circuit_component/bci_core/Destroy()
	QDEL_NULL(charge_action)
	return ..()

/obj/item/circuit_component/bci_core/register_shell(atom/movable/shell)
	var/obj/item/organ/cyberimp/bci/bci = shell

	charge_action = new(src)
	bci.actions += list(charge_action)

	RegisterSignal(shell, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_organ_implanted))
	RegisterSignal(shell, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))

/obj/item/circuit_component/bci_core/unregister_shell(atom/movable/shell)
	var/obj/item/organ/cyberimp/bci/bci = shell

	bci.actions -= charge_action
	QDEL_NULL(charge_action)

	UnregisterSignal(shell, list(
		COMSIG_ORGAN_IMPLANTED,
		COMSIG_ORGAN_REMOVED,
	))

/obj/item/circuit_component/bci_core/should_receive_input(datum/port/input/port)
	if (!COMPONENT_TRIGGERED_BY(send_message_signal, port))
		return FALSE
	return ..()

/obj/item/circuit_component/bci_core/input_received(datum/port/input/port)
	var/sent_message = trim(message.value)
	if (!sent_message)
		return

	var/mob/living/carbon/resolved_owner = user?.resolve()
	if (isnull(resolved_owner))
		return

	if (resolved_owner.stat == DEAD)
		return

	to_chat(resolved_owner, "<i>You hear a strange, robotic voice in your head...</i> \"[span_robot("[html_encode(sent_message)]")]\"")

/obj/item/circuit_component/bci_core/proc/on_organ_implanted(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	user_port.set_output(owner)
	user = WEAKREF(owner)

	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))
	RegisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))

/obj/item/circuit_component/bci_core/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	user_port.set_output(null)
	user = null

	UnregisterSignal(owner, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_PROCESS_BORGCHARGER_OCCUPANT,
		COMSIG_LIVING_ELECTROCUTE_ACT,
	))

/obj/item/circuit_component/bci_core/proc/on_borg_charge(datum/source, amount)
	SIGNAL_HANDLER

	if (isnull(parent.cell))
		return
	parent.cell.give(amount)

/obj/item/circuit_component/bci_core/proc/on_electrocute(datum/source, shock_damage, siemens_coefficient, flags)
	SIGNAL_HANDLER

	if (isnull(parent.cell))
		return
	if (flags & SHOCK_ILLUSION)
		return
	parent.cell.give(shock_damage * 2)
	to_chat(source, span_notice("You absorb some of the shock into your [parent.name]!"))

/obj/item/circuit_component/bci_core/proc/on_examine(datum/source, mob/mob, list/examine_text)
	SIGNAL_HANDLER

	if (isobserver(mob))
		examine_text += span_notice("[source.p_they(capitalized = TRUE)] [source.p_have()] <a href='?src=[REF(src)];open_bci=1'>\a [parent] implanted in [source.p_them()]</a>.")

/obj/item/circuit_component/bci_core/Topic(href, list/href_list)
	..()

	if (!isobserver(usr))
		return

	if (href_list["open_bci"])
		parent.attack_ghost(usr)

/datum/action/innate/bci_charge_action
	name = "Check BCI Charge"
	check_flags = NONE
	icon_icon = 'icons/obj/power.dmi'
	button_icon_state = "cell"

	var/obj/item/circuit_component/bci_core/circuit_component

/datum/action/innate/bci_charge_action/New(obj/item/circuit_component/bci_core/circuit_component)
	..()

	src.circuit_component = circuit_component

	update_buttons()

	START_PROCESSING(SSobj, src)

/datum/action/innate/bci_charge_action/create_button()
	var/atom/movable/screen/movable/action_button/button = ..()
	button.maptext_x = 2
	button.maptext_y = 0
	return button

/datum/action/innate/bci_charge_action/Destroy()
	circuit_component.charge_action = null
	circuit_component = null

	STOP_PROCESSING(SSobj, src)

	return ..()

/datum/action/innate/bci_charge_action/on_activate(mob/user, atom/target)
	var/obj/item/stock_parts/cell/cell = circuit_component.parent.cell

	if (isnull(cell))
		to_chat(owner, span_boldwarning("[circuit_component.parent] has no power cell."))
	else
		to_chat(owner, span_info("[circuit_component.parent]'s [cell.name] has <b>[cell.percent()]%</b> charge left."))
		to_chat(owner, span_info("You can recharge it by using a cyborg recharging station."))

/datum/action/innate/bci_charge_action/process(delta_time)
	update_buttons()

/datum/action/innate/bci_charge_action/update_button(atom/movable/screen/movable/action_button/button, status_only = FALSE, force = FALSE)
	. = ..()
	if(!.)
		return
	if(status_only)
		return
	var/obj/item/stock_parts/cell/cell = circuit_component.parent.cell
	button.maptext = cell ? MAPTEXT("[cell.percent()]%") : ""

/obj/machinery/bci_implanter
	name = "brain-computer interface manipulation chamber"
	desc = "A machine that, when given a brain-computer interface, will implant it into an occupant. Otherwise, will remove any brain-computer interfaces they already have."
	circuit = /obj/item/circuitboard/machine/bci_implanter
	icon = 'icons/obj/machines/bci_implanter.dmi'
	icon_state = "bci_implanter"
	layer = ABOVE_WINDOW_LAYER
	use_power = IDLE_POWER_USE
	anchored = TRUE
	density = TRUE
	idle_power_usage = 50
	active_power_usage = 300

	var/busy = FALSE
	var/busy_icon_state
	var/locked = FALSE

	var/obj/item/organ/cyberimp/bci/bci_to_implant

	COOLDOWN_DECLARE(message_cooldown)

/obj/machinery/bci_implanter/Initialize(mapload)
	. = ..()
	occupant_typecache = typecacheof(/mob/living/carbon)

/obj/machinery/bci_implanter/on_deconstruction()
	drop_stored_bci()

/obj/machinery/bci_implanter/Destroy()
	qdel(bci_to_implant)
	return ..()

/obj/machinery/bci_implanter/examine(mob/user)
	. = ..()

	if (isnull(bci_to_implant))
		. += span_notice("There is no BCI inserted.")
	else
		. += span_notice("Alt-click to remove [bci_to_implant].")

/obj/machinery/bci_implanter/proc/set_busy(status, working_icon)
	busy = status
	busy_icon_state = working_icon
	update_icon_state()
	update_overlays()

/obj/machinery/bci_implanter/update_icon_state()
	if (occupant)
		icon_state = busy ? busy_icon_state : "bci_implanter_occupied"
		return ..()
	icon_state = "bci_implanter[state_open ? "_open" : null]"
	return ..()

/obj/machinery/bci_implanter/update_overlays()
	var/list/overlays = ..()

	if ((machine_stat & MAINT) || panel_open)
		overlays += "maint"
		return overlays

	if (machine_stat & (NOPOWER|BROKEN))
		return overlays

	if (busy || locked)
		overlays += "red"
		if (locked)
			overlays += "bolted"
		return overlays

	overlays += "green"

	return overlays

/obj/machinery/bci_implanter/AltClick(mob/user)
	. = ..()
	if(!user.Adjacent(src) || !can_interact(user))
		return

	if(locked)
		balloon_alert(user, "it's locked!")
		return ..()

	if (isnull(bci_to_implant))
		balloon_alert(user, "no bci inserted!")
	else
		user.put_in_hands(bci_to_implant)
		balloon_alert(user, "ejected bci")

	bci_to_implant = null

	return ..()

/obj/machinery/bci_implanter/attackby(obj/item/weapon, mob/user, params)
	if (!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, weapon))
		update_icon()
		update_icon_state()
		return

	if (default_pry_open(weapon))
		return

	if (default_deconstruction_crowbar(weapon))
		return

	var/obj/item/organ/cyberimp/bci/new_bci = weapon
	if (istype(new_bci))
		if (!(locate(/obj/item/integrated_circuit) in new_bci))
			balloon_alert(user, "bci has no circuit!")
			return

		var/obj/item/organ/cyberimp/bci/previous_bci_to_implant = bci_to_implant

		user.transferItemToLoc(weapon, src)
		bci_to_implant = weapon

		if (isnull(previous_bci_to_implant))
			balloon_alert(user, "inserted bci")
		else
			balloon_alert(user, "swapped bci")
			user.put_in_hands(previous_bci_to_implant)

		return

	return ..()

/obj/machinery/bci_implanter/proc/start_process()
	if (machine_stat & (NOPOWER|BROKEN))
		return
	if ((machine_stat & MAINT) || panel_open)
		return
	if (!occupant || busy)
		return

	var/locked_state = locked
	locked = TRUE

	set_busy(TRUE, "[initial(icon_state)]_raising")
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_active"), 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(set_busy), TRUE, "[initial(icon_state)]_falling"), 2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(complete_process), locked_state), 3 SECONDS)

/obj/machinery/bci_implanter/proc/complete_process(locked_state)
	locked = locked_state
	set_busy(FALSE)

	var/mob/living/carbon/carbon_occupant = occupant
	if (!istype(carbon_occupant))
		return

	playsound(loc, 'sound/machines/ping.ogg', 30, FALSE)

	var/obj/item/organ/cyberimp/bci/bci_organ = carbon_occupant.getorgan(/obj/item/organ/cyberimp/bci)

	if (bci_organ)
		bci_organ.Remove(carbon_occupant)

		if (isnull(bci_to_implant))
			say("Occupant's previous brain-computer interface has been transferred to internal storage unit.")
			carbon_occupant.transferItemToLoc(bci_organ, src)
			bci_to_implant = bci_organ
		else
			say("Occupant's previous brain-computer interface has been ejected.")
			bci_organ.forceMove(drop_location())
	else if (!isnull(bci_to_implant))
		say("Occupant has been injected with [bci_to_implant].")
		bci_to_implant.Insert(carbon_occupant)

/obj/machinery/bci_implanter/open_machine()
	if(state_open)
		return FALSE

	..()

	return TRUE

/obj/machinery/bci_implanter/close_machine(mob/living/carbon/user)
	if(!state_open)
		return FALSE

	..()

	var/mob/living/carbon/carbon_occupant = occupant
	if (istype(occupant))
		var/obj/item/organ/cyberimp/bci/bci_organ = carbon_occupant.getorgan(/obj/item/organ/cyberimp/bci)
		if (isnull(bci_organ) && isnull(bci_to_implant))
			say("No brain-computer interface inserted, and occupant does not have one. Insert a BCI to implant one.")
			playsound(src, 'sound/machines/buzz-sigh.ogg', 30, TRUE)
			return FALSE

	addtimer(CALLBACK(src, PROC_REF(start_process)), 1 SECONDS)
	return TRUE

/obj/machinery/bci_implanter/relaymove(mob/living/user, direction)
	var/message

	if (locked)
		message = "it won't budge!"
	else if (user.stat != CONSCIOUS)
		message = "you don't have the energy!"

	if (!isnull(message))
		if (COOLDOWN_FINISHED(src, message_cooldown))
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
			balloon_alert(user, message)

		return

	open_machine()

/obj/machinery/bci_implanter/interact(mob/user)
	if (state_open)
		close_machine(null, user)
		return
	else if (locked)
		balloon_alert(user, "it's locked!")
		return

	open_machine()

/obj/machinery/bci_implanter/proc/drop_stored_bci()
	if (isnull(bci_to_implant))
		return
	bci_to_implant.forceMove(drop_location())

/obj/machinery/bci_implanter/dump_inventory_contents(list/subset)
	// Prevents opening the machine dropping the BCI.
	// "dump_contents()" still drops the BCI.
	return ..(contents - bci_to_implant)

/obj/machinery/bci_implanter/Exited(atom/movable/gone, direction)
	if (gone == bci_to_implant)
		bci_to_implant = null
	return ..()

/obj/item/circuitboard/machine/bci_implanter
	name = "Brain-Computer Interface Manipulation Chamber (Machine Board)"
	build_path = /obj/machinery/bci_implanter
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1,
	)
