/*
	The plant scanner shows some plant information and tray information
*/
/obj/item/plant_scanner
	name = "plant scanner"
	desc = "A portble device used to scan and analyse plants.\n<span class='notice'>Use in-hand to enable / disable advanced scan.</span>"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "plant_scanner"
	w_class = WEIGHT_CLASS_TINY
	///Do we show extra information
	var/advanced = TRUE

/obj/item/plant_scanner/interact(mob/user)
	. = ..()
	advanced = !advanced
	to_chat(user, span_notice("Advanced scan [advanced ? "enabled" : "disabled"]."))

/obj/item/plant_scanner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	var/scan_dialogue = ""
	//This code is kinda samey but it's easier to read
//Tray
	var/obj/item/plant_tray/tray = target
	if(istype(tray))
		var/datum/plant_feature/feature
		//Report needs
		for(var/ref as anything in tray.needy_features)
			feature = locate(ref)
			scan_dialogue += "<span class='plant_sub'>[feature.get_need_dialogue(FALSE)]</span>"
		//Report problems
		for(var/ref as anything in tray.problem_features)
			feature = locate(ref)
			scan_dialogue += "<span class='plant_sub'>[feature.get_scan_dialogue()]</span>"
		//Report harvest
		var/datum/component/plant/plant
		for(var/ref as anything in tray.harvestable_components)
			plant = locate(ref)
			scan_dialogue += "<span class='plant_sub'>[plant.plant_item]([get_species_name(plant.plant_features)])\n\nReady For Harvest</span>"
		//Report Weeds
		var/datum/component/planter/tray_component = tray.GetComponent(/datum/component/planter)
		scan_dialogue +="<span class='plant_sub'>Weed Composition: [tray_component.weed_level]%</span>"
		to_chat(user, "<span class='plant_scan'><b>[capitalize(target.name)]</b></span><span class='plant_scan'>[scan_dialogue]</span>")
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		return FALSE
//Seed packet
	var/obj/item/plant_seeds/seeds = target
	if(istype(seeds))
		for(var/datum/plant_feature/feature as anything in seeds.plant_features)
			scan_dialogue += "<span class='plant_sub'>[feature.get_scan_dialogue()]<br/>[advanced ? "\n[feature.get_need_dialogue()]" : ""]</span>"
		to_chat(user, "<span class='plant_scan'><b>[capitalize(target.name)]</b></span><span class='plant_scan'>[scan_dialogue]</span>")
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		return FALSE
//Fruit
	var/list/genes = list()
	SEND_SIGNAL(target, COMSIG_PLANT_GET_GENES, genes)
	if(length(genes))
		for(var/datum/plant_feature/feature as anything in genes[PLANT_GENE_INDEX_FEATURES])
			scan_dialogue += "<span class='plant_sub'>[feature.get_scan_dialogue()][advanced ? "\n[feature.get_need_dialogue()]" : ""]</span>"
		to_chat(user, "<span class='plant_scan'><b>[capitalize(target.name)]</b></span><span class='plant_scan'>[scan_dialogue]</span>")
		//TODO: Add dialogue to show ALL reagent contents - Racc
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		return FALSE
//Plant
	var/datum/component/plant/plant_component = target.GetComponent(/datum/component/plant)
	if(!plant_component || !length(plant_component.plant_features))
		return FALSE
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		scan_dialogue += "<span class='plant_sub'>[feature.get_scan_dialogue()][advanced ? "\n[feature.get_need_dialogue()]" : ""]</span>"
	to_chat(user, "<span class='plant_scan'><b>[capitalize(target.name)]</b></span><span class='plant_scan'>[scan_dialogue]</span>")
	playsound(src, 'sound/effects/fastbeep.ogg', 20)
	return FALSE
