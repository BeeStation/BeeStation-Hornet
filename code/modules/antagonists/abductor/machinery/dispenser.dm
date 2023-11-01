// This is classic abductor dispenser, but it is awfully identifiable.
// The actual one abductors are using is after this type (as smartfridge)
/obj/machinery/abductor/gland_dispenser
	name = "replacement organ storage"
	desc = "A tank filled with replacement organs."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "dispenser"
	density = TRUE
	var/list/gland_types
	var/list/gland_colors
	var/list/amounts

/obj/machinery/abductor/gland_dispenser/proc/random_color()
	//TODO : replace with presets or spectrum
	return rgb(rand(0,255),rand(0,255),rand(0,255))

/obj/machinery/abductor/gland_dispenser/Initialize(mapload)
	. = ..()
	gland_types = subtypesof(/obj/item/organ/heart/gland)
	gland_types = shuffle(gland_types)
	gland_colors = new/list(gland_types.len)
	amounts = new/list(gland_types.len)
	for(var/i in 1 to gland_types.len)
		gland_colors[i] = random_color()
		amounts[i] = rand(1,5)

/obj/machinery/abductor/gland_dispenser/ui_status(mob/user)
	if(!isabductor(user) && !isobserver(user))
		return UI_CLOSE
	return ..()

/obj/machinery/abductor/gland_dispenser/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/abductor/gland_dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GlandDispenser", name)
		ui.open()

/obj/machinery/abductor/gland_dispenser/ui_data(mob/user)
	var/list/data = list()
	data["glands"] = list()
	for(var/gland_number in 1 to gland_colors.len)
		var/list/gland_information = list(
			"color" = gland_colors[gland_number],
			"amount" = amounts[gland_number],
			"id" = gland_number,
		)
		data["glands"] += list(gland_information)
	return data

/obj/machinery/abductor/gland_dispenser/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("dispense")
			var/gland_id = text2num(params["gland_id"])
			if(!gland_id)
				return
			Dispense(gland_id)
			return TRUE

/obj/machinery/abductor/gland_dispenser/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/organ/heart/gland))
		if(!user.transferItemToLoc(W, src))
			return
		for(var/i in 1 to gland_colors.len)
			if(gland_types[i] == W.type)
				amounts[i]++
		ui_update()
	else
		return ..()

/obj/machinery/abductor/gland_dispenser/proc/Dispense(count)
	if(amounts[count]>0)
		amounts[count]--
		var/T = gland_types[count]
		new T(get_turf(src))
	ui_update()

// -------------------------
// This is just smartfridge but for abductors.
// less flavour, but abductor can see what these are at a glance
/obj/machinery/smartfridge/abductor
	name = "replacement organ storage"
	desc = "A tank filled with replacement organs."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "dispenser"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	density = TRUE
	idle_power_usage = 0
	active_power_usage = 0
	max_n_of_items = 1000
	tgui_theme = "abductor"
	var/repair_rate = 0
	var/allowed_to_everyone = FALSE

/obj/machinery/smartfridge/abductor/Initialize(mapload)
	. = ..()
	generate_glands()

/obj/machinery/smartfridge/abductor/proc/generate_glands()
	for(var/each as() in shuffle(subtypesof(/obj/item/organ/heart/gland)))
		for(var/i in 1 to rand(2, 7))
			var/obj/item/organ/heart/gland/each_gland = new each
			each_gland.name = each_gland.true_name
			each_gland.forceMove(src)

/obj/machinery/smartfridge/abductor/ui_status(mob/user)
	if(!allowed_to_everyone && !isabductor(user) && !isobserver(user))
		return UI_CLOSE
	return ..()

/obj/machinery/smartfridge/abductor/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/smartfridge/abductor/accept_check(obj/item/O)
	if(istype(O, /obj/item/organ/heart/gland))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/abductor/load(obj/item/O)
	. = ..()
	if(!.)	//if the item loads, clear can_decompose
		return
	if(!istype(O, /obj/item/organ/heart/gland))
		return
	var/obj/item/organ/heart/gland/organ = O
	organ.organ_flags |= ORGAN_FROZEN
	organ.name = organ.true_name

/obj/machinery/smartfridge/abductor/Exited(atom/movable/gone, direction)
	. = ..()
	if(!istype(gone, /obj/item/organ/heart/gland))
		return
	var/obj/item/organ/heart/gland/organ = gone
	organ.organ_flags &= ~ORGAN_FROZEN
	organ.organ_flags &= ~ORGAN_FAILING
	organ.setOrganDamage(-200)
	organ.name = initial(organ.name)

/obj/machinery/smartfridge/abductor/update_icon()
	return
