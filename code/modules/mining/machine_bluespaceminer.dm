/obj/machinery/mineral/bluespace_miner
	name = "bluespace mining machine"
	desc = "A machine that uses the magic of Bluespace to slowly generate materials and add them to a linked ore silo."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "bs_miner"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/bluespace_miner
	layer = BELOW_OBJ_LAYER
	var/mob/living/simple_animal/hostile/megafauna/chosen_mob
	var/damage_buffer
	var/list/lavaland_mobs = list()
	var/list/ore_rates = list(/datum/material/iron = 0.6, /datum/material/glass = 0.6, /datum/material/copper = 0.4, /datum/material/plasma = 0.2,  /datum/material/silver = 0.2, /datum/material/gold = 0.1, /datum/material/titanium = 0.1, /datum/material/uranium = 0.1, /datum/material/diamond = 0.1)
	var/datum/component/remote_materials/materials

/obj/machinery/mineral/bluespace_miner/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "bsm", mapload)

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

/obj/machinery/mineral/bluespace_miner/process()
	if(damage_buffer >= 1000)
		for(var/mob/living/simple_animal/hostile/megafauna/chonker in GLOB.mob_living_list)
			lavaland_mobs += chonker
		if(!length(lavaland_mobs))
			for(var/mob/living/simple_animal/hostile/lesser_chonk in GLOB.mob_living_list)
				if(istype(lesser_chonk, /area/lavaland/surface/outdoors))
					lavaland_mobs += lesser_chonk
		if(!length(lavaland_mobs))
			for(var/mob/living/carbon/human/H in GLOB.mob_living_list)
				if(H.job == "Shaft Miner")
					lavaland_mobs += H
		if(!length(lavaland_mobs))
			return
		chosen_mob = pick(lavaland_mobs)
		chosen_mob.adjustBruteLoss(5000)
		chosen_mob.adjustFireLoss(5000)
		lavaland_mobs.Cut()
		damage_buffer = 0
		visible_message("<span class='notice'>[src] has automatically slain [chosen_mob]!</span>")
	else
		damage_buffer += 50
