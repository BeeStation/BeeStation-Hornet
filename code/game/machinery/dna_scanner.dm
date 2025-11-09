/obj/machinery/dna_scannernew
	name = "\improper DNA scanner"
	desc = "It scans DNA structures."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "scanner"
	density = TRUE
	obj_flags = BLOCKS_CONSTRUCTION // Becomes undense when the door is open
	use_power = IDLE_POWER_USE
	idle_power_usage = 50
	active_power_usage = 300
	occupant_typecache = list(/mob/living, /obj/item/bodypart/head, /obj/item/organ/brain)
	circuit = /obj/item/circuitboard/machine/clonescanner
	var/locked = FALSE
	var/damage_coeff
	var/scan_level
	var/precision_coeff
	var/message_cooldown
	var/breakout_time = 1200
	var/ignore_id = FALSE

/obj/machinery/dna_scannernew/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/dna_scanner(src)

/obj/machinery/dna_scannernew/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/dna_scannernew/RefreshParts()
	scan_level = 0
	damage_coeff = 0
	precision_coeff = 0
	for(var/obj/item/stock_parts/scanning_module/P in component_parts)
		scan_level += P.rating
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		precision_coeff = M.rating
	for(var/obj/item/stock_parts/micro_laser/P in component_parts)
		damage_coeff = P.rating
	for(var/obj/machinery/computer/scan_consolenew/console in view(1))
		if(console.connected_scanner == src)
			console.calculate_timeouts()

/obj/machinery/dna_scannernew/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += span_notice("The status display reads: Radiation pulse accuracy increased by factor <b>[precision_coeff**2]</b>.<br>Radiation pulse damage decreased by factor <b>[damage_coeff**2]</b>.")
		if(scan_level >= 3)
			. += span_notice("Scanner has been upgraded to support autoprocessing.")

/obj/machinery/dna_scannernew/update_icon()
	cut_overlays()

	if((machine_stat & MAINT) || panel_open)
		add_overlay("maintenance")

	//no power or maintenance
	if(machine_stat & (NOPOWER|BROKEN))
		icon_state = initial(icon_state)+ (state_open ? "_open" : "") + "_unpowered"
		return
	else if(locked)
		add_overlay("locked")

	//running and someone in there
	if(occupant)
		icon_state = initial(icon_state)+ "_occupied"
		return

	//running
	icon_state = initial(icon_state)+ (state_open ? "_open" : "")

/obj/machinery/dna_scannernew/proc/toggle_open(mob/user)
	if(locked)
		to_chat(user, span_notice("The bolts are locked down, securing the door [state_open ? "open" : "shut"]."))
		return

	if(state_open)
		close_machine()
		return

	open_machine()

/obj/machinery/dna_scannernew/container_resist(mob/living/user)
	if(!locked)
		open_machine()
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message(span_notice("You see [user] kicking against the door of [src]!"), \
		span_notice("You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)"), \
		span_italics("You hear a metallic creaking from [src]."))
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
			return
		locked = FALSE
		user.visible_message(span_warning("[user] successfully broke out of [src]!"), \
			span_notice("You successfully break out of [src]!"))
		open_machine()

/obj/machinery/dna_scannernew/proc/locate_computer(type_)
	for(var/direction in GLOB.cardinals)
		var/C = locate(type_, get_step(src, direction))
		if(C)
			return C
	return null

/obj/machinery/dna_scannernew/close_machine(mob/living/carbon/user)
	if(!state_open)
		return FALSE

	..(user)

	return TRUE

/obj/machinery/dna_scannernew/open_machine()
	if(state_open)
		return FALSE

	..()

	return TRUE

/obj/machinery/dna_scannernew/relaymove(mob/living/user, direction)
	if(user.stat || (locked && !state_open))
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, span_warning("[src]'s door won't budge!"))
		return
	open_machine()

/obj/machinery/dna_scannernew/attackby(obj/item/I, mob/user, params)

	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))//sent icon_state is irrelevant...
		update_icon()//..since we're updating the icon here, since the scanner can be unpowered when opened/closed
		return

	if(default_pry_open(I))
		return

	if(default_deconstruction_crowbar(I))
		return

	if(panel_open && is_wire_tool(I))
		wires.interact(user)
		return

	return ..()

/obj/machinery/dna_scannernew/interact(mob/user)
	toggle_open(user)

/obj/machinery/dna_scannernew/MouseDrop_T(mob/target, mob/user)
	if(user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_UI_BLOCKED) || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !ISADVANCEDTOOLUSER(user) || locked)
		return
	close_machine(target)

/obj/machinery/dna_scannernew/proc/shock(mob/user, prb)
	if(machine_stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	if(electrocute_mob(user, get_area(src), src, 0.7, check_range))
		return TRUE
	else
		return FALSE

/obj/machinery/dna_scannernew/proc/reset(wire)
	switch(wire)
		if(WIRE_IDSCAN)
			ignore_id = FALSE
		if(WIRE_BOLTS)
			locked = FALSE
			update_icon()
