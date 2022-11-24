/obj/machinery/mineral/bluespace_miner
	name = "bluespace mining machine"
	desc = "A machine that uses the magic of Bluespace to slowly generate materials and add them to a linked ore silo."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "bs_miner"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/bluespace_miner
	layer = BELOW_OBJ_LAYER
	processing_flags = START_PROCESSING_ON_INIT
	var/list/ore_rates = list(/datum/material/iron = 0.6, /datum/material/glass = 0.6, /datum/material/copper = 0.4, /datum/material/plasma = 0.2,  /datum/material/silver = 0.2, /datum/material/gold = 0.1, /datum/material/titanium = 0.1, /datum/material/uranium = 0.1, /datum/material/diamond = 0.1)
	var/datum/component/remote_materials/materials
	var/ammout_produced = 1

/obj/machinery/mineral/bluespace_miner/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "bsm", mapload)

/obj/machinery/mineral/bluespace_miner/Destroy()
	materials = null
	return ..()

/obj/machinery/mineral/bluespace_miner/RefreshParts()
	var/ammout_produced_temp = 0.25
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		ammout_produced_temp +=  (0.125 * B.rating)
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		ammout_produced_temp += (0.02 * L.rating)
	ammout_produced = round(ammout_produced_temp, 0.01)

/obj/machinery/mineral/bluespace_miner/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "bs_miner-open", "bs_miner", W))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(W))
		return
	return ..()

/obj/machinery/mineral/bluespace_miner/multitool_act(mob/living/user, obj/item/multitool/M)
	if(istype(M))
		if(!M.buffer || !istype(M.buffer, /obj/machinery/ore_silo))
			to_chat(user, "<span class='warning'>You need to multitool the ore silo first.</span>")
			return FALSE

/obj/machinery/mineral/bluespace_miner/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The status display reads: Producing <b>[ammout_produced]</b>% per cycle.</span>"
	if(!materials?.silo)
		. += "<span class='notice'>No ore silo connected. Use a multi-tool to link an ore silo to this machine.</span>"
	else if(materials?.on_hold())
		. += "<span class='warning'>Ore silo access is on hold, please contact the quartermaster.</span>"
	if(!powered())
		. += "<span class='notice'>Machine is unpowered.</span>"

/obj/machinery/mineral/bluespace_miner/process(delta_time)
	if(!materials?.silo || materials?.on_hold())
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || panel_open || !powered())
		return
	var/datum/material/ore = pick(ore_rates)
	mat_container.insert_amount_mat((ore_rates[ore] * ammout_produced * 1000), ore)
