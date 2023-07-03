/obj/machinery/fax
	name = "Fax Machine"
	desc = "Bluespace technologies on the application of bureaucracy"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "fax"
	density = TRUE
	power_channel = AREA_USAGE_EQUIP
	max_integrity = 100
	pass_flags = PASSTABLE
	circuit = /obj/item/circuitboard/machine/fax
	/// The unique ID by which the fax will build a list of existing faxes.
	var/fax_id
	/// The name of the fax displayed in the list. Not necessarily unique to some EMAG jokes.
	var/fax_name
	/// A weak reference to an inserted object.
	var/datum/weakref/loaded_item_ref
	/// World ticks the machine is electrified for.
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	/// If true, the fax machine is jammed and needs cleaning
	var/jammed = FALSE
	/// Determines the possibility of sending papers to the additional faxes.
	var/access_additional_faxes = FALSE
	/// Defines a list of accesses whose owners can open a connection with the additional faxes.
	var/static/access_additional_faxes_required = list(ACCESS_HEADS, ACCESS_LAWYER, ACCESS_SECURITY)
	/// Necessary to hide syndicate faxes from the general list. Doesn't mean he's EMAGGED!
	var/syndicate_network = FALSE
	/// True if the fax machine should be visible to other fax machines in general.
	var/visible_to_network = TRUE
	/// If true we will eject faxes at speed rather than sedately place them into a tray.
	var/hurl_contents = FALSE
	/// If true you can fax things which strictly speaking are not paper.
	var/allow_exotic_faxes = FALSE
	/// This is where the dispatch and reception history for each fax is stored.
	var/list/fax_history = list()
	/// List of types which should always be allowed to be faxed
	var/static/list/allowed_types = list(
		/obj/item/paper,
		/obj/item/photo
	)
	/// List of types which should be allowed to be faxed if hacked
	var/static/list/exotic_types = list(
		/obj/item/reagent_containers/food/snacks/pizzaslice,
		/obj/item/food/breadslice,
		/obj/item/reagent_containers/food/snacks/donkpocket,
		/obj/item/reagent_containers/food/snacks/cookie,
		/obj/item/reagent_containers/food/snacks/sugarcookie,
		/obj/item/reagent_containers/food/snacks/oatmealcookie,
		/obj/item/reagent_containers/food/snacks/raisincookie,
		/obj/item/reagent_containers/food/snacks/pancakes,
		/obj/item/throwing_star,
		/obj/item/stack/spacecash,
		/obj/item/holochip,
		/obj/item/card,
		/obj/item/mail
	)

/obj/machinery/fax/Initialize(mapload)
	. = ..()
	if(!fax_id)
		fax_id = SSnetworks.assign_random_name()
	if(!fax_name)
		fax_name = "Unregistered fax " + fax_id
	wires = new /datum/wires/fax(src)

/obj/machinery/fax/Destroy()
	QDEL_NULL(loaded_item_ref)
	QDEL_NULL(wires)
	return ..()

/obj/machinery/fax/update_overlays()
	. = ..()
	if(panel_open)
		. += "fax_panel"
	var/obj/item/loaded = loaded_item_ref?.resolve()
	if(loaded)
		. += mutable_appearance(icon, find_overlay_state(loaded, "contain"))

/obj/machinery/fax/examine()
	. = ..()
	if(jammed)
		. += "<span class='notice'>Its output port is jammed and needs cleaning.</span>"


/obj/machinery/fax/process(delta_time)
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified -= delta_time

/obj/machinery/fax/attack_hand(mob/user)
	if(seconds_electrified && !(machine_stat & NOPOWER))
		if(shock(user, 100))
			return
	return ..()

/***
 * Emag the device if the panel is open.
 * Emag does not bring you into the syndicate network, but makes it visible to you.
 */
/obj/machinery/fax/on_emag(mob/user)
	..()
	if(!panel_open && !allow_exotic_faxes)
		balloon_alert(user, "open the panel first!")
		return
	if(!(obj_flags & EMAGGED))
		obj_flags |= EMAGGED
		to_chat(user, "<span class='warning'>An image appears on [src] screen for a moment with Ian in the cap of a Syndicate officer.</span>")

/obj/machinery/fax/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/**
 * Open and close the wire panel.
 */
/obj/machinery/fax/screwdriver_act(mob/living/user, obj/item/screwdriver)
	. = ..()
	default_deconstruction_screwdriver(user, icon_state, icon_state, screwdriver)
	update_icon()
	return TRUE

/**
 * Using the multi-tool with the panel closed causes the fax network name to be renamed.
 */
/obj/machinery/fax/multitool_act(mob/living/user, obj/item/I)
	if(panel_open)
		return
	var/new_fax_name = stripped_input(user, "Enter a new name for the fax machine.", "New Fax Name", max_length=128)
	if(!new_fax_name)
		return TOOL_ACT_TOOLTYPE_SUCCESS
	if(new_fax_name != fax_name)
		if(fax_name_exist(new_fax_name))
			// Being able to set the same name as another fax machine will give a lot of gimmicks for the traitor.
			if(syndicate_network != TRUE && obj_flags != EMAGGED)
				to_chat(user, "<span class='warning'>There is already a fax machine with this name on the network.</span>")
				return TOOL_ACT_TOOLTYPE_SUCCESS
		user.log_message("renamed [fax_name] (fax machine) to [new_fax_name]", LOG_GAME)
		fax_name = new_fax_name
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/fax/attackby(obj/item/item, mob/user, params)
	if(jammed && clear_jam(item, user))
		return
	if(panel_open)
		if(is_wire_tool(item))
			wires.interact(user)
		return
	if(can_load_item(item))
		if(!loaded_item_ref?.resolve())
			loaded_item_ref = WEAKREF(item)
			item.forceMove(src)
			update_icon()
		return
	return ..()

// Checks if the card has access to switch "legal" faxes of administrators.
/obj/machinery/fax/proc/access_additional_faxes_check(mob/living/user)
	if(IsAdminGhost(user))
		return TRUE

	if(!length(access_additional_faxes_required)) // if it needs nothing, it means always allowed
		return TRUE
	var/obj/item/card/id/used_card = user.get_idcard(TRUE)
	if(used_card)
		if(!length(used_card.access)) // it needs something, but do early return FALSE if card has no access
			return FALSE
		for(var/requested_access in access_additional_faxes_required)
			if(requested_access in used_card.access)
				return TRUE
	return FALSE

// Switches access to the "legal" administrator's fax list. Access to the "illegal" is switched by hacking.
/obj/machinery/fax/proc/access_additional_faxes_toggle()
	access_additional_faxes = !access_additional_faxes
	say("The channel of communication with CentCom is [access_additional_faxes ? "open" : "close"].")

/**
 * Attempts to clean out a jammed machine using a passed item.
 * Returns true if successful.
 */
/obj/machinery/fax/proc/clear_jam(obj/item/item, mob/user)
	if(istype(item, /obj/item/reagent_containers/spray))
		var/obj/item/reagent_containers/spray/clean_spray = item
		if(!clean_spray.reagents.has_reagent(/datum/reagent/space_cleaner, clean_spray.amount_per_transfer_from_this))
			return FALSE
		clean_spray.reagents.remove_reagent(/datum/reagent/space_cleaner, clean_spray.amount_per_transfer_from_this, 1)
		playsound(loc, 'sound/effects/spray3.ogg', 50, TRUE, -5)
		user.visible_message("<span class='notice'>[user] cleans \the [src].</span>", "<span class='notice'>You clean \the [src].</span>")
		jammed = FALSE
		return TRUE
	if(istype(item, /obj/item/soap) || istype(item, /obj/item/reagent_containers/glass/rag))
		var/cleanspeed = 50
		if(istype(item, /obj/item/soap))
			var/obj/item/soap/used_soap = item
			cleanspeed = used_soap.cleanspeed
		user.visible_message("<span class='notice'>[user] starts to clean \the [src].</span>", "<span class='notice'>You start to clean \the [src]...</span>")
		if(do_after(user, cleanspeed, target = src))
			user.visible_message("<span class='notice'>[user] cleans \the [src].</span>", "<span class='notice'>You clean \the [src].</span>")
			jammed = FALSE
		return TRUE
	return FALSE

/**
 * Returns true if an item can be loaded into the fax machine.
 */
/obj/machinery/fax/proc/can_load_item(obj/item/item)
	if(!is_allowed_type(item))
		return FALSE
	if(!istype(item, /obj/item/stack))
		return TRUE
	var/obj/item/stack/stack_item = item
	return stack_item.amount == 1

/**
 * Returns true if an item is of a type which can currently be loaded into this fax machine.
 * This list expands if you snip a particular wire.
 */
/obj/machinery/fax/proc/is_allowed_type(obj/item/item)
	if(is_type_in_list(item, allowed_types))
		return TRUE
	if(!allow_exotic_faxes)
		return FALSE
	return is_type_in_list(item, exotic_types)

/obj/machinery/fax/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Fax")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/fax/ui_static_data(mob/user)
	var/list/data = list()
	data["additional_faxes_list"] = GLOB.additional_faxes_list
	data["syndicate_faxes_list"] = GLOB.syndicate_faxes_list
	return data

/obj/machinery/fax/ui_data(mob/user)
	var/list/data = list()
	//Record a list of all existing faxes.
	for(var/obj/machinery/fax/fax in GLOB.machines)
		if(fax.fax_id == fax_id) //skip yourself
			continue
		var/list/fax_data = list()
		fax_data["fax_name"] = fax.fax_name
		fax_data["fax_id"] = fax.fax_id
		fax_data["visible"] = fax.visible_to_network
		fax_data["has_paper"] = !!fax.loaded_item_ref?.resolve()
		// Hacked doesn't mean on the syndicate network.
		fax_data["syndicate_network"] = fax.syndicate_network
		data["faxes"] += list(fax_data)

	// Own data
	data["fax_id"] = fax_id
	data["fax_name"] = fax_name
	data["visible"] = visible_to_network
	data["access_additional_faxes"] = access_additional_faxes
	data["сan_switch_access"] = access_additional_faxes_check(user)
	// In this case, we don't care if the fax is hacked or in the syndicate's network. The main thing is to check the visibility of other faxes.
	data["syndicate_network"] = (syndicate_network || (obj_flags & EMAGGED))
	data["has_paper"] = !!loaded_item_ref?.resolve()
	data["fax_history"] = fax_history
	return data

/obj/machinery/fax/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		// Pulls the paper out of the fax machine
		if("remove")
			var/obj/item/loaded = loaded_item_ref?.resolve()
			if(!loaded)
				return
			loaded.forceMove(drop_location())
			loaded_item_ref = null
			playsound(src, 'sound/machines/terminal_eject.ogg', 50, FALSE)
			update_icon()
			return TRUE
		if("access_additional_faxes_toggle")
			access_additional_faxes_toggle()
		if("send")
			var/obj/item/loaded = loaded_item_ref?.resolve()
			if(!loaded)
				return
			var/destination = params["id"]
			if(send(loaded, destination))
				log_fax(loaded, destination, params["name"])
				loaded_item_ref = null
				update_icon()
				return TRUE
		if("send_to_additional_fax")
			var/obj/item/loaded = loaded_item_ref?.resolve()
			if(!loaded)
				return
			if(istype(loaded, /obj/item/paper))
				if(send_to_additional_faxes(loaded, usr, params["name"], params["color"]))
					loaded_item_ref = null
					update_icon()
					return TRUE
			else
				say("The destination fax blocks the reception of this item.")
		if("history_clear")
			history_clear()
			return TRUE

/**
 * Records logs of bureacratic action
 * Arguments:
 * * sent - The object being sent
 * * destination_id - The unique ID of the fax machine
 * * name - The friendly name of the fax machine, but these can be spoofed so the ID is also required
 */
/obj/machinery/fax/proc/log_fax(obj/item/sent, destination_id, name)
	if (istype(sent, /obj/item/paper))
		var/obj/item/paper/sent_paper = sent
		log_paper("[usr] has sent a fax with the message \"[sent_paper.get_raw_text()]\" to [name]/[destination_id].")
		return
	log_game("[usr] has faxed [sent] to [name]/[destination_id].]")

/**
 * The procedure for sending a paper to another fax machine.
 *
 * The object is called inside /obj/machinery/fax to send the thing to another fax machine.
 * The procedure searches among all faxes for the desired fax ID and calls proc/receive() on that fax.
 * If the thing is sent successfully, it returns TRUE.
 * Arguments:
 * * loaded - The object to be sent.
 * * id - The network ID of the fax machine you want to send the item to.
 */
/obj/machinery/fax/proc/send(obj/item/loaded, id)
	for(var/obj/machinery/fax/fax in GLOB.machines)
		if(fax.fax_id != id)
			continue
		if(fax.jammed)
			do_sparks(5, TRUE, src)
			balloon_alert(usr, "destination port jammed")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, -9)
			return FALSE
		fax.receive(loaded, fax_name)
		playback_sending(loaded, fax.fax_name)
		return TRUE
	return FALSE

/**
 * The procedure for sending a item to virtual admins fax machine.
 *
 * This procedure is similar to the send procedure except that it sends the item to
 * a "virtual" fax to a special administrator list.
 * Arguments:
 * * loaded - The item to be sent.
 * * sender - Reference to the sender's substance.
 * * receiver_name - The recipient's fax name, which will be displayed in the administrator's list.
 * * receiver_color - The color the receiver_name will be colored in.
 */
/obj/machinery/fax/proc/send_to_additional_faxes(obj/item/loaded, mob/sender, receiver_name, receiver_color)
	GLOB.fax_manager.receive_request(sender, src, receiver_name, loaded, receiver_color)
	playback_sending(loaded, receiver_name)
	return TRUE

/**
 * The procedure for playing the animation.
 *
 * Procedure called to add to the history of sending messages, playing the sending animation.
 * Arguments:
 * * loaded - Sending item to determine the animation..
 * * receiver_name - Recipient's name to be added to the message history.
 */
/obj/machinery/fax/proc/playback_sending(obj/item/loaded, receiver_name)
	history_add("Send", receiver_name)
	INVOKE_ASYNC(src, PROC_REF(animate_object_travel), loaded, "fax_receive", find_overlay_state(loaded, "send"))

/**
 * Procedure for accepting papers from another fax machine.
 *
 * The procedure is called in proc/send() of the other fax. It receives a paper-like object and "prints" it.
 * Arguments:
 * * loaded - The object to be printed.
 * * sender_name - The sender's name, which will be displayed in the message and recorded in the history of operations.
 */
/obj/machinery/fax/proc/receive(obj/item/loaded, sender_name)
	playsound(src, 'sound/items/poster_being_created.ogg', 50, FALSE)
	INVOKE_ASYNC(src, PROC_REF(animate_object_travel), loaded, "fax_receive", find_overlay_state(loaded, "receive"))
	say("Received correspondence from [sender_name].")
	history_add("Receive", sender_name)
	addtimer(CALLBACK(src, PROC_REF(vend_item), loaded), 1.9 SECONDS)

/**
 * Procedure for animating an object entering or leaving the fax machine.
 * Arguments:
 * * item - The object which is travelling.
 * * animation_state - An icon state to apply to the fax machine.
 * * overlay_state - An icon state to apply as an overlay to the fax machine.
 */
/obj/machinery/fax/proc/animate_object_travel(obj/item/item, animation_state, overlay_state)
	icon_state = animation_state
	var/mutable_appearance/overlay = mutable_appearance(icon, overlay_state)
	overlays += overlay
	addtimer(CALLBACK(src, PROC_REF(travel_animation_complete), overlay), 2 SECONDS)

/**
 * Called when the travel animation should end. Reset animation and overlay states.
 * Arguments:
 * * remove_overlay - Overlay to remove.
 */
/obj/machinery/fax/proc/travel_animation_complete(mutable_appearance/remove_overlay)
	icon_state = "fax"
	overlays -= remove_overlay

/**
 * Returns an appropriate icon state to represent a passed item.
 * Arguments:
 * * item - Item to interrogate.
 * * state_prefix - Icon state action prefix to mutate.
 */
/obj/machinery/fax/proc/find_overlay_state(obj/item/item, state_prefix)
	if(istype(item, /obj/item/paper))
		return "[state_prefix]_paper"
	if(istype(item, /obj/item/photo))
		return "[state_prefix]_photo"
	if(iscash(item))
		return "[state_prefix]_cash"
	if(istype(item, /obj/item/card))
		return "[state_prefix]_id"
	if(istype(item, /obj/item/reagent_containers/food))
		return "[state_prefix]_food"
	if(istype(item, /obj/item/throwing_star))
		return "[state_prefix]_star"
	return "[state_prefix]_paper"

/**
 * Actually vends an item out of the fax machine.
 * Moved into its own proc to allow a delay for the animation.
 * This will either deposit the item on the fax machine, or throw it if you have hacked a wire.
 * Arguments:
 * * vend - Item to vend from the fax machine.
 */
/obj/machinery/fax/proc/vend_item(obj/item/vend)
	vend.forceMove(drop_location())
	if(hurl_contents)
		vend.throw_at(get_edge_target_turf(drop_location(), pick(GLOB.alldirs)), rand(1, 4), EMBED_THROWSPEED_THRESHOLD)
	if(is_type_in_list(vend, exotic_types) && prob(20))
		do_sparks(5, TRUE, src)
		jammed = TRUE

/**
 * A procedure that makes entries in the history of fax transactions.
 *
 * Called to record the operation in the fax history list.
 * Records the type of operation, the name of the fax machine with which the operation was performed, and the station time.
 * Arguments:
 * * history_type - Type of operation. By default, "Send" and "Receive" should be used.
 * * history_fax_name - The name of the fax machine that performed the operation.
 */
/obj/machinery/fax/proc/history_add(history_type = "Send", history_fax_name)
	var/list/history_data = list()
	history_data["history_type"] = history_type
	history_data["history_fax_name"] = history_fax_name
	history_data["history_time"] = station_time_timestamp()
	fax_history += list(history_data)

/// Clears the history of fax operations.
/obj/machinery/fax/proc/history_clear()
	fax_history = null

/**
 * Checks fax names for a match.
 *
 * Called to check the new fax name against the names of other faxes to prevent the use of identical names.
 * Arguments:
 * * new_fax_name - The text of the name to be checked for a match.
 */
/obj/machinery/fax/proc/fax_name_exist(new_fax_name)
	for(var/obj/machinery/fax/fax in GLOB.machines)
		if (fax.fax_name == new_fax_name)
			return TRUE
	return FALSE

/**
 * Attempts to shock the passed user, returns true if they are shocked.
 *
 * Arguments:
 * * user - the user to shock
 * * chance - probability the shock happens
 */
/obj/machinery/fax/proc/shock(mob/living/user, chance)
	if(!istype(user) || machine_stat & (BROKEN|NOPOWER))
		return FALSE
	if(!prob(chance))
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	return electrocute_mob(user, get_area(src), src, 0.7, check_range)
