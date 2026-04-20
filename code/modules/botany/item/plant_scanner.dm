#define RENDER_RULE_PLANTSEED "RENDER_RULE_PLANTSEED"
#define RENDER_RULE_FRUIT "RENDER_RULE_FRUIT"
#define RENDER_RULE_TRAY "RENDER_RULE_TRAY"

/*
	The plant scanner shows some plant information and tray information
*/
/obj/item/plant_scanner
	name = "plant scanner"
	desc = "A portble device used to scan and analyse plants. Also works on plant trays.\n<span class='notice'>Use in-hand to enable / disable advanced scan.</span>"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "plant_scanner"
	inhand_icon_state = "analyzer"
	worn_icon_state = "plantanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=20)
	///Refernece to our screen effect
	var/obj/effect/hydroponics_screen/screen

	var/list/buffer = list()
	var/last_time
	var/last_target
	var/render_rule = null

/obj/item/plant_scanner/Initialize(mapload)
	. = ..()
	screen = new(src, "plant_scanner_on")

/obj/item/plant_scanner/Destroy(force)
	. = ..()
	QDEL_NULL(screen)

/obj/item/plant_scanner/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlantScanner")
		ui.open()

/obj/item/plant_scanner/ui_data(mob/user)
	var/list/data = list()
	data["buffer"] = buffer
	data["last_time"] = last_time
	data["last_target"] = last_target
	data["render_rule"] = render_rule

	return data

/obj/item/plant_scanner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	. = TRUE
	screen?.flash()
	//prepare UI data
	buffer.Cut()
	last_time = station_time_timestamp(format = "hh:mm")
	last_target = target.name
	//These cases are samey but it's easier to read them in this format
//Seed packet
	var/obj/item/plant_seeds/seeds = target
	if(istype(seeds))
		render_rule = RENDER_RULE_PLANTSEED
		for(var/datum/plant_feature/feature as anything in seeds.plant_features)
			buffer += list(list("feature" = feature.get_scan_dialogue(), "needs" = feature.get_need_dialogue()))
		. = FALSE
//Plant
	var/datum/component/plant/plant_component = target.GetComponent(/datum/component/plant)
	if(plant_component && length(plant_component.plant_features))
		render_rule = RENDER_RULE_PLANTSEED
		for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
			buffer += list(list("feature" = feature.get_scan_dialogue(), "needs" = feature.get_need_dialogue()))
		. = FALSE
//Fruit
	var/list/genes = list()
	SEND_SIGNAL(target, COMSIG_PLANT_GET_GENES, genes)
	if(length(genes))
		render_rule = RENDER_RULE_FRUIT
		//Features
		buffer["genes"] = list()
		for(var/datum/plant_feature/feature as anything in genes[PLANT_GENE_INDEX_FEATURES])
			buffer["genes"] += list(list("feature" = feature.get_scan_dialogue(), "needs" = feature.get_need_dialogue()))
		//Reagents
		buffer["reagents"] = list()
		for(var/datum/reagent/reagent as anything in target.reagents?.reagent_list)
			buffer["reagents"] += list("[reagent?.volume]u of [reagent?.name]")
		. = FALSE
//Tray - don't bother opening up the UI for this, we just dump it in chat
	var/obj/item/plant_tray/tray = target
	if(istype(tray) && tray.can_scan)
		render_rule = RENDER_RULE_TRAY
		var/scan_dialogue = ""
		var/datum/plant_feature/feature
		//Report harvest
		var/datum/component/plant/plant
		for(var/ref as anything in tray.harvestable_components)
			plant = locate(ref)
			scan_dialogue += "<span class='plant_sub'>[plant.plant_item]([get_species_name(plant.plant_features)])\n\nReady For Harvest</span>"
			buffer += "[plant.plant_item]([get_species_name(plant.plant_features)]) Ready For Harvest]"
		//Report problems
		for(var/ref as anything in tray.problem_features)
			feature = locate(ref)
			var/big_excerpt = ""
			for(var/exceprt in feature.get_scan_dialogue())
				big_excerpt += exceprt
			scan_dialogue += "<span class='plant_sub'>[big_excerpt]</span>"
			buffer += feature.get_scan_dialogue()
		//Report needs
		for(var/ref as anything in tray.needy_features)
			feature = locate(ref)
			var/big_excerpt = ""
			for(var/exceprt in feature.get_need_dialogue(FALSE))
				big_excerpt += exceprt
			scan_dialogue += "<span class='plant_sub'>[big_excerpt]</span>"
			buffer += feature.get_need_dialogue(FALSE)
		//Report Weeds
		var/datum/component/planter/tray_component = tray.GetComponent(/datum/component/planter)
		scan_dialogue +="<span class='plant_sub'>Weed Composition: [tray_component.weed_level]%</span>"
		buffer += "Weed Composition: [tray_component.weed_level]%"
		//Report tray slots
		scan_dialogue += "<span class='plant_sub'>Open Plant Slots [tray_component.plant_slots]/[initial(tray_component.plant_slots)]</span>"
		buffer += "Open Plant Slots [tray_component.plant_slots]/[initial(tray_component.plant_slots)]"
		to_chat(user, "<span class='plant_scan'><b>[capitalize(target.name)]</b></span><span class='plant_scan'>[scan_dialogue]</span>")
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		ui_update()
		return FALSE
//Fail state
	if(!.)
		playsound(src, 'sound/effects/fastbeep.ogg', 20)
		ui_interact(user)
		ui_update()
		return
	last_target = null
	render_rule = null
	ui_update()

#undef RENDER_RULE_PLANTSEED
#undef RENDER_RULE_FRUIT
#undef RENDER_RULE_TRAY
