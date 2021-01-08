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
	
	switch (efficiency)
		if (10 to 19)
			ore_rates = list(
				/datum/material/iron = 5, 
				/datum/material/glass = 5,
				/datum/material/copper = 3, 
				/datum/material/silver = 1, 
			)
		if (20 to 29)
			ore_rates = list(
				/datum/material/iron = 5, 
				/datum/material/glass = 5,
				/datum/material/copper = 3, 
				/datum/material/silver = 2, 
				/datum/material/gold = 1, 
				/datum/material/plasma = 1,
			)
		if (30 to INFINITY)	//and beyond
			ore_rates = list(
				/datum/material/iron = 4, 
				/datum/material/glass = 4, 
				/datum/material/copper = 2.4, 
				/datum/material/silver = 1.6, 
				/datum/material/gold = 1.2, 
				/datum/material/plasma = 1.2,
				/datum/material/titanium = 1, 
				/datum/material/uranium = 1, 
				/datum/material/diamond = 1
			)
		else 
			ore_rates = list(
				/datum/material/iron = 1, 
				/datum/material/glass = 1,
			)

/obj/machinery/mineral/bluespace_miner/process()
	if(!materials?.silo || materials?.on_hold())
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || panel_open || !powered())
		return
	var/datum/material/ore = pick(ore_rates)
	mat_container.insert_amount_mat((ore_rates[ore] * rand (200,400)), ore)
