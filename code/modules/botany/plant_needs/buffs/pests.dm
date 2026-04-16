/*
	Actually a debuff
	Attracts pests to the tray
*/
/datum/plant_need/reagent/buff/pests
	need_description = "Wards off pests usually attracted to this plant's sweet aroma."
	reagent_needs = list(/datum/reagent/toxin/pestkiller = 3, /datum/reagent/toxin = 1, /datum/reagent/consumable/ethanol = 3, /datum/reagent/fluorine = 1, /datum/reagent/chlorine = 1, /datum/reagent/diethylamine = 1,
	/datum/reagent/phosphorus = 1, /datum/reagent/diethylamine = 0.5)
	auto_threshold = TRUE
	debuff = TRUE
	nectar_buff_duration = 15 SECONDS
	do_buff_appearance = FALSE

	///How fast pests build up per tick
	var/pest_build_up = 0.05
	///Level of pests for damage calculation
	var/pest_level = 0
	///Maximum damage from pests per second
	var/pest_damage = 3
	///What reagents feed the pests
	var/feed_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/blood = 0.5, /datum/reagent/plantnutriment/left4zednutriment = 0.01)

	///Quick reference the plant's body
	var/datum/plant_feature/body/body_parent

	///original description before we add pest %
	var/archive_description
	///Holder for particles
	var/atom/movable/artifact_particle_holder/calibrated_holder

/datum/plant_need/reagent/buff/pests/New(datum/plant_feature/_parent)
	. = ..()
	archive_description = need_description

/datum/plant_need/reagent/buff/pests/process(delta_time)
	need_description = "[archive_description]\n	 Pest Level: [pest_level]%"
	if(SEND_SIGNAL(parent.parent.plant_item.loc, COMSIG_PLANTER_PAUSE_PLANT))
		return
	if(pest_level <= 0)
		QDEL_NULL(calibrated_holder)
		return
	if(pest_level >= 30 && !calibrated_holder)
		var/atom/movable/atom_parent = parent.parent.plant_item
		calibrated_holder = new(atom_parent)
		calibrated_holder.add_emitter(/obj/emitter/flies, "calibration", 10)
		atom_parent.vis_contents += calibrated_holder
	var/mod = pest_level/100
	body_parent.adjust_health(mod*pest_damage*-1)

/datum/plant_need/reagent/buff/pests/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	//A little hacky but it shouldn't matter too much
	addtimer(CALLBACK(src, PROC_REF(finish_setup)), 1 SECONDS)

/datum/plant_need/reagent/buff/pests/proc/finish_setup()
	RegisterSignal(parent.parent, COMSIG_PLANT_CARNI_BUFF, PROC_REF(catch_carni))
	body_parent = locate(/datum/plant_feature/body) in parent.parent.plant_features
	if(!body_parent)
		return
	START_PROCESSING(SSobj, src)

/datum/plant_need/reagent/buff/pests/check_need(_delta_time)
	. = ..()
	//Special interaction with sugar & blood
	var/list/reagent_holders = list()
	SEND_SIGNAL(parent.parent, COMSIG_PLANT_REQUEST_REAGENTS, reagent_holders, parent)
	if(!length(reagent_holders))
		return FALSE
	for(var/datum/reagents/R as anything in reagent_holders)
		if(!R)
			continue
		for(var/reagent as anything in feed_reagents)
			var/amount_needed = feed_reagents[reagent] * _delta_time
			if(!R.has_reagent(reagent, amount_needed))
				continue
			if(consume_reagents)
				R.remove_reagent(reagent, amount_needed)
				remove_buff(_delta_time)

/datum/plant_need/reagent/buff/pests/apply_buff(__delta_time)
	. = ..()
	pest_level -= (pest_build_up*__delta_time)*10 //pests are removed faster than they build up
	pest_level = max(pest_level, 0)

/datum/plant_need/reagent/buff/pests/remove_buff(__delta_time)
	. = ..()
	if(body_parent?.current_stage != body_parent?.growth_stages) //Don't make maturing plants endure this chore, purely an upkeep thing
		return
	pest_level += pest_build_up*__delta_time
	pest_level = min(pest_level, 100)

/datum/plant_need/reagent/buff/pests/catch_nectar(datum/source)
	. = ..()
	pest_level = 0

/datum/plant_need/reagent/buff/pests/proc/catch_carni(datum/source, _delta_time)
	SIGNAL_HANDLER

	remove_buff(_delta_time)
