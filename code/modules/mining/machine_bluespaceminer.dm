/obj/machinery/bluespace_miner
	name = "bluespace mining machine"
	desc = "A machine that uses the magic of Bluespace to slowly generate materials and add them to a linked ore silo."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "bs_miner"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/bluespace_miner
	layer = BELOW_OBJ_LAYER
	use_power = IDLE_POWER_USE
	idle_power_usage = 1000
	var/list/ore_rates = list(/datum/material/iron = 6, /datum/material/glass = 6, /datum/material/copper = 4, /datum/material/plasma = 2,  /datum/material/silver = 2, /datum/material/gold = 1, /datum/material/titanium = 1, /datum/material/uranium = 1, /datum/material/diamond = 1)
	var/datum/component/remote_materials/materials
	var/ammout_produced = 1
	var/run_speed = 100
	var/last_ran = 0

/obj/machinery/bluespace_miner/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "bsm", mapload)

/obj/machinery/bluespace_miner/Destroy()
	materials = null
	return ..()

/obj/machinery/bluespace_miner/RefreshParts()
	var/ammout_produced_temp = 0
	var/run_speed_temp = 125
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		ammout_produced_temp +=  (0.125 * B.rating)
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		ammout_produced_temp += (0.05 * L.rating)
	ammout_produced = round(ammout_produced_temp, 0.01)
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		run_speed_temp -= (5 * M.rating)
	run_speed = round(run_speed_temp, 0.1)

/obj/machinery/bluespace_miner/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "bs_miner-open", "bs_miner", W))
		updateUsrDialog()
		return
	if(default_deconstruction_crowbar(W))
		return
	return ..()

/obj/machinery/bluespace_miner/multitool_act(mob/living/user, obj/item/multitool/M)
	if(istype(M))
		if(!M.buffer || !istype(M.buffer, /obj/machinery/ore_silo))
			to_chat(user, "<span class='warning'>You need to multitool the ore silo first.</span>")
			return FALSE

/obj/machinery/bluespace_miner/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The status display reads: Producing at <b>[ammout_produced * 100]</b>% efficency every <b>[run_speed * 0.1]</b> seconds.</span>"
	if(!materials?.silo)
		. += "<span class='notice'>No ore silo connected. Use a multi-tool to link an ore silo to this machine.</span>"
	else if(materials?.on_hold())
		. += "<span class='warning'>Ore silo access is on hold, please contact the quartermaster.</span>"

/obj/machinery/bluespace_miner/process(delta_time)
	if(machine_stat & NOPOWER)
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!materials?.silo || materials?.on_hold() || !mat_container)
		return
	if(!check_delay())
		return
	var/datum/material/ore = pick(ore_rates)
	var/datum/material/ore_ammount = round((ore_rates[ore] * rand(500, 1500) * ammout_produced), 10)
	mat_container.insert_amount_mat(ore_ammount, ore)
	last_ran = world.time
/obj/machinery/bluespace_miner/proc/check_delay()
	if((src.last_ran + src.run_speed) <= world.time)
		return TRUE
	return FALSE
