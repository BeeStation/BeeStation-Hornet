/datum/component/swimming/ethereal
	var/obj/machinery/pool_filter/linked_filter

/datum/component/swimming/ethereal/enter_pool()
	var/mob/living/L = parent
	L.visible_message("<span class='warning'>Sparks of energy being coursing around the pool!</span>")
	var/turf/open/indestructible/sound/pool/water = get_turf(parent)
	for(var/obj/machinery/pool_filter/PF in GLOB.pool_filters)
		if(PF.id == water.id)
			linked_filter = PF
			break

/datum/component/swimming/ethereal/process()
	..()
	if(!linked_filter)
		return
	var/mob/living/L = parent
	if(prob(2) && L.nutrition > NUTRITION_LEVEL_FED)
		L.adjust_nutrition(-50)
		linked_filter.reagents.add_reagent_list(list(/datum/reagent/teslium = 5, /datum/reagent/water = 5))	//Creates a tesla spawn