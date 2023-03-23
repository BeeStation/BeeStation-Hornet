/// Smelt amount per second
#define SMELT_AMOUNT 5

/**********************Mineral processing unit console**************************/

/obj/machinery/mineral
	processing_flags = START_PROCESSING_MANUALLY
	subsystem_type = /datum/controller/subsystem/processing/fastprocess
	/// The current direction of `input_turf`, in relation to the machine.
	var/input_dir = NORTH
	/// The current direction, in relation to the machine, that items will be output to.
	var/output_dir = SOUTH
	/// The turf the machines listens to for items to pick up. Calls the `pickup_item()` proc.
	var/turf/input_turf = null
	/// Determines if this machine needs to pick up items. Used to avoid registering signals to `/mineral` machines that don't pickup items.
	var/needs_item_input = FALSE

/obj/machinery/mineral/Initialize(mapload)
	. = ..()
	if(needs_item_input)
		register_input_turf()

/// Gets the turf in the `input_dir` direction adjacent to the machine, and registers signals for ATOM_ENTERED and ATOM_CREATED. Calls the `pickup_item()` proc when it receives these signals.
/obj/machinery/mineral/proc/register_input_turf()
	input_turf = get_step(src, input_dir)
	if(input_turf) // make sure there is actually a turf
		RegisterSignal(input_turf, list(COMSIG_ATOM_CREATED, COMSIG_ATOM_ENTERED), PROC_REF(pickup_item))

/// Unregisters signals that are registered the machine's input turf, if it has one.
/obj/machinery/mineral/proc/unregister_input_turf()
	if(input_turf)
		UnregisterSignal(input_turf, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_CREATED))

/**
	Base proc for all `/mineral` subtype machines to use. Place your item pickup behavior in this proc when you override it for your specific machine.
	Called when the COMSIG_ATOM_ENTERED and COMSIG_ATOM_CREATED signals are sent.
	Arguments:
	* source - the turf that is listening for the signals.
	* target - the atom that just moved onto the `source` turf.
	* oldLoc - the old location that `target` was at before moving onto `source`.
*/
/obj/machinery/mineral/proc/pickup_item(datum/source, atom/movable/target, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	return

/// Generic unloading proc. Takes an atom as an argument and forceMove's it to the turf adjacent to this machine in the `output_dir` direction.
/obj/machinery/mineral/proc/unload_mineral(atom/movable/S)
	S.forceMove(drop_location())
	var/turf/T = get_step(src,output_dir)
	if(T)
		S.forceMove(T)

/obj/machinery/mineral/processing_unit_console
	name = "production machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = TRUE
	var/obj/machinery/mineral/processing_unit/machine = null
	var/machinedir = EAST
	var/link_id = null

/obj/machinery/mineral/processing_unit_console/Initialize(mapload)
	. = ..()
	if(link_id)
		return INITIALIZE_HINT_LATELOAD
	else
		machine = locate(/obj/machinery/mineral/processing_unit, get_step(src, machinedir))
		if (machine)
			machine.CONSOLE = src
		else
			return INITIALIZE_HINT_QDEL

// Only called if mappers set ID
/obj/machinery/mineral/processing_unit_console/LateInitialize()
	for(var/obj/machinery/mineral/processing_unit/PU in GLOB.machines)
		if(PU.link_id == link_id)
			machine = PU
			machine.CONSOLE = src
			return

/obj/machinery/mineral/processing_unit_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smelter")
		ui.open()
		ui.set_autoupdate(TRUE) // Material amounts

/obj/machinery/mineral/processing_unit_console/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	if(!machine)
		return

	data = machine.get_machine_data()
	return data

/obj/machinery/mineral/processing_unit_console/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("Redeem")
			if(!machine.stored_points)
				to_chat(usr, "<span class='warning'>No points to claim.</span>")
				return

			var/mob/M = usr
			var/obj/item/card/id/I = M.get_idcard(TRUE)
			if(!I)
				to_chat(usr, "<span class='warning'>No ID detected.</span>")
				return
			if(!I.registered_account)
				to_chat(usr, "<span class='warning'>No bank account detected on the ID card.</span>")
				return
			I.registered_account.adjust_currency(ACCOUNT_CURRENCY_MINING, machine.stored_points)
			machine.stored_points = 0

		if("Toggle_on")
			machine.toggle_on()

		if("Material")
			var/datum/material/new_material = locate(params["id"])
			if(istype(new_material))
				machine.selected_material = new_material
				machine.selected_alloy = null

		if("Alloy")
			machine.selected_material = null
			machine.selected_alloy = params["id"]

/obj/machinery/mineral/processing_unit_console/Destroy()
	machine = null
	return ..()


/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "furnace"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = TRUE
	needs_item_input = TRUE
	var/obj/machinery/mineral/CONSOLE = null
	var/on = FALSE
	var/datum/material/selected_material = null
	var/selected_alloy = null
	var/datum/techweb/stored_research
	var/link_id = null
	var/stored_points = 0
	var/allow_point_redemption = FALSE

/obj/machinery/mineral/processing_unit/laborcamp
	allow_point_redemption = FALSE

/obj/machinery/mineral/processing_unit/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 1)
	AddComponent(/datum/component/material_container, list(/datum/material/iron, /datum/material/glass, /datum/material/copper, /datum/material/silver, /datum/material/gold, /datum/material/diamond, /datum/material/plasma, /datum/material/uranium, /datum/material/bananium, /datum/material/titanium, /datum/material/bluespace), INFINITY, TRUE, /obj/item/stack)
	stored_research = new /datum/techweb/specialized/autounlocking/smelter
	selected_material = getmaterialref(/datum/material/iron)

/obj/machinery/mineral/processing_unit/Destroy()
	CONSOLE = null
	QDEL_NULL(stored_research)
	return ..()

/obj/machinery/mineral/processing_unit/proc/process_ore(obj/item/stack/ore/O)
	if(QDELETED(O))
		return
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/material_amount = materials.get_item_material_amount(O)
	if(!materials.has_space(material_amount))
		unload_mineral(O)
	else
		if(allow_point_redemption)
			stored_points += O.points * O.amount
		materials.insert_item(O)
		qdel(O)

/obj/machinery/mineral/processing_unit/proc/get_machine_data()
	var/list/data = list()
	data["on"] = on
	data["allowredeem"] = allow_point_redemption

	//Points
	if(allow_point_redemption)
		data["stored_points"] = stored_points

	data["materials"] = list()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	for(var/datum/material/M in materials.materials)
		var/amount = materials.materials[M]
		var/sheet_amount = amount / MINERAL_MATERIAL_AMOUNT
		var/ref = REF(M)
		data["materials"] += list(list("name" = M.name, "id" = ref, "amount" = sheet_amount, "smelting" = (selected_material == M)))

	data["alloys"] = list()

	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		data["alloys"] += list(list("name" = D.name, "id" = D.id, "smelting" = (selected_alloy == D.id), "amount" = can_smelt(D)))

	return data

/obj/machinery/mineral/processing_unit/pickup_item(datum/source, atom/movable/target, atom/oldLoc)
	if(QDELETED(target))
		return
	if(istype(target, /obj/item/stack/ore))
		process_ore(target)

/obj/machinery/mineral/processing_unit/proc/toggle_on()
	on = !on
	if(on)
		begin_processing()

/obj/machinery/mineral/processing_unit/process(delta_time)
	if(on)
		if(selected_material)
			smelt_ore(delta_time)

		else if(selected_alloy)
			smelt_alloy(delta_time)

	else
		end_processing()

/obj/machinery/mineral/processing_unit/proc/smelt_ore(delta_time = 2)
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	var/datum/material/mat = selected_material
	if(mat)
		var/sheets_to_remove = (materials.materials[mat] >= (MINERAL_MATERIAL_AMOUNT * SMELT_AMOUNT * delta_time) ) ? SMELT_AMOUNT * delta_time : round(materials.materials[mat] /  MINERAL_MATERIAL_AMOUNT)
		if(!sheets_to_remove)
			on = FALSE
		else
			var/out = get_step(src, output_dir)
			materials.retrieve_sheets(sheets_to_remove, mat, out)


/obj/machinery/mineral/processing_unit/proc/smelt_alloy(delta_time = 2)
	var/datum/design/alloy = stored_research.isDesignResearchedID(selected_alloy) //check if it's a valid design
	if(!alloy)
		on = FALSE
		return

	var/amount = can_smelt(alloy, delta_time)

	if(!amount)
		on = FALSE
		return

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.use_materials(alloy.materials, amount)

	generate_mineral(alloy.build_path)

/obj/machinery/mineral/processing_unit/proc/can_smelt(datum/design/D, delta_time = 2)
	if(D.make_reagents.len)
		return FALSE

	var/build_amount = SMELT_AMOUNT * delta_time

	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)

	for(var/mat_cat in D.materials)
		var/required_amount = D.materials[mat_cat]
		var/amount = materials.materials[mat_cat]

		build_amount = min(build_amount, round(amount / required_amount))

	return build_amount

/obj/machinery/mineral/processing_unit/proc/generate_mineral(P)
	var/O = new P(src)
	unload_mineral(O)

/obj/machinery/mineral/processing_unit/on_deconstruction()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all()
	..()

#undef SMELT_AMOUNT
