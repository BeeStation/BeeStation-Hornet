/**********************Material Deposit Machine**************************/

/obj/machinery/mineral/material_deposit
	name = "material deposit machine"
	desc = "A machine that accepts sheets of material and deposits them into the ore silo. This one is linked to"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "material_deposit"
	density = TRUE
	input_dir = NORTH
	req_access = list(ACCESS_MINERAL_STOREROOM)
	circuit = /obj/item/circuitboard/machine/material_deposit
	needs_item_input = TRUE
	processing_flags = START_PROCESSING_MANUALLY

	layer = BELOW_OBJ_LAYER
	/// Variable that holds a timer which is used for callbacks to `send_console_message()`. Used for preventing multiple calls to this proc while the MDM is eating a stack of sheets
	var/console_notify_timer
	var/datum/component/remote_materials/materials
	var/static/list/allowed_mats = typecacheof(list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/copper,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/diamond,
		/datum/material/plasma,
		/datum/material/uranium,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/bluespace,
		/datum/material/plastic,
		))
	var/material_pickup = FALSE
	var/department_id = DEPT_ALL
	COOLDOWN_DECLARE(material_cooldown)

/obj/machinery/mineral/material_deposit/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "mdm", mapload)
	materials.department_id = department_id



/obj/machinery/mineral/material_deposit/Destroy()
	materials = null
	return ..()

/obj/machinery/mineral/material_deposit/examine(mob/user)
	. = ..()
	if(panel_open)
		. += "<span class='notice'>Alt-click to rotate the input direction.</span>"


/obj/machinery/mineral/material_deposit/pickup_item(datum/source, atom/movable/target, atom/oldLoc)
	if(!material_pickup)
		return
	if(!COOLDOWN_FINISHED(src, material_cooldown))
		return
	if(QDELETED(target))
		return
	if(!materials.mat_container || panel_open || !powered())
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	if(istype(target, /obj/item/stack))
		var/obj/item/stack/O = target
		if(!O.materials.len)
			return
		var/is_allowed_material = TRUE
		for(var/datum/mat in O.materials)
			is_allowed_material = is_allowed_material && is_type_in_typecache(mat, allowed_mats)
		if(is_allowed_material)
			var/mats = O.materials & mat_container.materials
			var/amount = O.amount
			mat_container.insert_item(O) //insert it
			materials.silo_log(src, "accepted", amount, "someone", mats)
			qdel(O)

/obj/machinery/mineral/material_deposit/default_unfasten_wrench(mob/user, obj/item/I)
	. = ..()
	if(!.)
		return
	if(anchored)
		register_input_turf() // someone just wrenched us down, re-register the turf
	else
		unregister_input_turf() // someone just un-wrenched us, unregister the turf

/obj/machinery/mineral/material_deposit/attackby(obj/item/W, mob/user, params)
	if(default_unfasten_wrench(user, W))
		return
	if(default_deconstruction_screwdriver(user, "material_deposit-open", "material_deposit", W))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(W))
		return

	if(!powered())
		return ..()

	var/obj/item/stack/ore/O = W
	if(istype(O))
		if(O.refined_type == null)

			return

	return ..()

/obj/machinery/mineral/material_deposit/AltClick(mob/living/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(panel_open)
		input_dir = turn(input_dir, -90)
		to_chat(user, "<span class='notice'>You change [src]'s I/O settings, setting the input to [dir2text(input_dir)].</span>")
		unregister_input_turf() // someone just rotated the input and output directions, unregister the old turf
		register_input_turf() // register the new one
		return TRUE


/obj/machinery/mineral/material_deposit/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/mineral/material_deposit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MaterialDepositMachine")
		ui.open()
		ui.set_autoupdate(TRUE) // Material amounts

/obj/machinery/mineral/material_deposit/ui_data(mob/user)
	var/list/data = list()

	data["materials"] = list()
	var/datum/component/material_container/mat_container = materials.mat_container
	if (mat_container)
		for(var/mat in mat_container.materials)
			var/datum/material/M = mat
			var/amount = mat_container.materials[M]
			var/sheet_amount = amount / MINERAL_MATERIAL_AMOUNT
			var/ref = REF(M)
			data["materials"] += list(list("name" = M.name, "id" = ref, "amount" = sheet_amount))
	if(material_pickup)
		data["materialPickup"] = "On"
	else
		data["materialPickup"] = "Off"
	if (!mat_container)
		data["disconnected"] = "local mineral storage is unavailable"
	else if (!materials.silo)
		data["disconnected"] = "no ore silo connection is available; storing locally"
	else if (materials.on_hold())
		data["disconnected"] = "mineral withdrawal is on hold"
	else
		data["disconnected"] = null

	return data

/obj/machinery/mineral/material_deposit/ui_act(action, params)
	if(..())
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	switch(action)
		if("Release")
			if(!mat_container)
				return

			if(materials.on_hold())
				to_chat(usr, "<span class='warning'>Mineral access is on hold, please contact the relevant head of staff.</span>")
			else if(!allowed(usr)) //Check the ID inside, otherwise check the user
				to_chat(usr, "<span class='warning'>Required access not found.</span>")
			else
				var/datum/material/mat = locate(params["id"])

				var/amount = mat_container.materials[mat]
				if(!amount)
					return

				var/stored_amount = CEILING(amount / MINERAL_MATERIAL_AMOUNT, 0.1)

				if(!stored_amount)
					return

				var/desired = 0
				if (params["sheets"])
					desired = text2num(params["sheets"])
				else
					desired = input("How many sheets?", "How many sheets would you like to smelt?", 1) as null|num

				var/sheets_to_remove = round(min(desired,50,stored_amount))
				//sets a cooldown so it doesnt' instantly qdel mats that are dispensed and that it leaves them untouched
				COOLDOWN_START(src, material_cooldown, 5)
				var/count = mat_container.retrieve_sheets(sheets_to_remove, mat,get_step(src, input_dir))
				var/list/mats = list()
				mats[mat] = MINERAL_MATERIAL_AMOUNT
				materials.silo_log(src, "released", -count, "sheets", mats)
				//Logging deleted for quick coding
				. = TRUE
		if("Toggle Material Pickup")
			material_pickup = !material_pickup

/obj/machinery/mineral/material_deposit/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"
	return
