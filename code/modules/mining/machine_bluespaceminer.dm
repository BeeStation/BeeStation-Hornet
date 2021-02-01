/obj/machinery/mineral/bluespace_miner
	name = "bluespace mining machine"
	desc = "A machine that uses the magic of Bluespace to slowly generate materials and add them to a linked ore silo."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "bs_miner"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/bluespace_miner
	layer = BELOW_OBJ_LAYER
	var/list/ore_rates = list(/datum/material/iron = 1, /datum/material/glass = 1)
	var/datum/component/remote_materials/materials

/obj/machinery/mineral/bluespace_miner/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "bsm", mapload)
	revise_mat_rates()

/obj/machinery/mineral/bluespace_miner/Destroy()
	materials = null
	return ..()

/obj/machinery/mineral/bluespace_miner/multitool_act(mob/living/user, obj/item/multitool/M)
	if(istype(M))
		if(!M.buffer || !istype(M.buffer, /obj/machinery/ore_silo))
			to_chat(user, "<span class='warning'>You need to multitool the ore silo first.</span>")
			return FALSE

/obj/machinery/mineral/bluespace_miner/examine(mob/user)
	. = ..()
	if(!materials?.silo)
		. += "<span class='notice'>No ore silo connected. Use a multi-tool to link an ore silo to this machine.</span>"
	else if(materials?.on_hold())
		. += "<span class='warning'>Ore silo access is on hold, please contact the quartermaster.</span>"

/obj/machinery/mineral/bluespace_miner/exchange_parts(mob/living/user,obj/item/tool)
	..()
	revise_mat_rates()

/obj/machinery/mineral/bluespace_miner/proc/revise_mat_rates()
	var/efficiency = 0	
	for(var/obj/item/stock_parts/P in component_parts)
		efficiency += P.rating
	efficiency /= 40
		
	ore_rates = list(
				/datum/material/iron = 0.2 + 0.6 * efficiency, 
				/datum/material/glass = 0.2 + 0.6 * efficiency, 
				/datum/material/copper = 0.2 + 0.3 * efficiency, 
				/datum/material/silver = 0.1 + 0.2 * efficiency, 
				/datum/material/plasma = 0.1 + 0.2 * efficiency,
				/datum/material/gold = 0.05 + 0.1 * efficiency, 
				/datum/material/titanium = 0.05 + 0.1 * efficiency, 
				/datum/material/uranium = 0.05 + 0.1 * efficiency, 
				/datum/material/diamond = 0.05 + 0.1 * efficiency
		)

/obj/machinery/mineral/bluespace_miner/process()
	if(!materials?.silo || materials?.on_hold())
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || panel_open || !powered())
		return
	var/datum/material/ore = pick(ore_rates)
	mat_container.insert_amount_mat((ore_rates[ore] * rand (300,500)), ore)
