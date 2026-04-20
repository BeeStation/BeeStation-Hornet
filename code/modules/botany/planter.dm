#define WEED_RATE 0.3
#define WEED_THRESHOLD 100

/datum/component/planter
	///How many available slots do we have for plants
	var/plant_slots = PLANT_BODY_SLOT_SIZE_LARGEST
	///What kind of substrate do we have?
	var/datum/plant_subtrate/substrate
	///Do we allow our substrate to be changed?
	var/allow_substrate_change = TRUE
	///How much do we visually offset the plant when planting it
	var/list/visual_upset = list(0, 16)
	///How much we offset entering plant's layer - used to make pots work
	var/layer_upset = 0
	///Do we gain weeds over time?
	var/gain_weeds = TRUE
	///Weed buildup
	var/weed_level = 0
	///Have we been visited by a bee recently?
	var/recent_bee_visit = FALSE
	///List of plants stored in us
	var/list/plants = list()

/datum/component/planter/Initialize(list/_visual_upset, _layer_upset, _gain_weeds)
	. = ..()
	visual_upset = _visual_upset || visual_upset
	layer_upset = _layer_upset || layer_upset
	gain_weeds = _gain_weeds
	RegisterSignal(parent, COMSIG_ATOM_AFTER_ATTACKEDBY, PROC_REF(catch_attack))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(catch_examine))
	RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(catch_entered))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(catch_exited))
	if(!gain_weeds)
		return
	START_PROCESSING(SSobj, src)

/datum/component/planter/process(delta_time)
	var/obj/obj_parent = parent
//Weed tick
	if(!substrate)
		return
	weed_level += WEED_RATE * delta_time
//Tick reagents
	SEND_SIGNAL(obj_parent.reagents, COMSIG_PLANTER_TICK_REAGENTS,  src, delta_time)
//Weed overtake
	if(weed_level < WEED_THRESHOLD)
		return
	weed_level = 0
	var/obj/item/plant_seeds/preset/weed = pick_weight(SSbotany.weeds)
	weed = new weed(get_turf(parent))
	if(!weed.plant(parent, logic = TRUE))
		qdel(weed)
		return
	obj_parent.visible_message(span_warning("The [parent] is overtaken by some [weed.name_override]!"))
	qdel(weed)

/datum/component/planter/proc/catch_attack(datum/source, obj/item/I, mob/living/attacker, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	var/list/modifiers = params2list(click_parameters)
//Hasty remove plants
	if(LAZYACCESS(modifiers, RIGHT_CLICK) && istype(I, /obj/item/shovel/spade) && length(plants))
		to_chat(attacker, span_warning("You begin to hastily remove [parent]'s plants! (This will destroy them)"))
		INVOKE_ASYNC(src, PROC_REF(async_hasty_remove), attacker, I)
		return
//Removing weeeds
	if(istype(I, /obj/item/cultivator))
		if(weed_level <= 1)
			attacker.visible_message("[attacker] digs around in [parent].", span_warning("[parent] is devoid of weeds!"))
			return
		attacker.visible_message("[attacker] uproots the weeds.", span_notice("You remove the weeds from [parent]."))
		weed_level = 0
		playsound(parent, 'sound/effects/shovel_dig.ogg', 60)
		return
//Remove substrate
	if(istype(I, /obj/item/shovel/spade) && !length(plants) && allow_substrate_change)
		INVOKE_ASYNC(src, PROC_REF(async_spade_action), attacker)
		return
	else if(istype(I, /obj/item/shovel/spade) && length(plants))
		to_chat(attacker, span_warning("You can't clear [parent]'s substrate while it still contains plants!"))
		//special code selecting specific plants to uproot, helps when visiblity is sucky
		INVOKE_ASYNC(src, PROC_REF(async_spade_options), attacker, I)
		return
//Ported legacy code from old trays
	var/obj/obj_parent = parent
	var/obj/item/reagent_containers/reagent_source = I
	if(istype(reagent_source, /obj/item/reagent_containers) && reagent_source.reagents.total_volume <= 0)
		to_chat(attacker, span_warning("[reagent_source] is empty!"))
		return
	//Composting
	if(IS_EDIBLE(reagent_source) || istype(reagent_source, /obj/item/reagent_containers/pill))
		obj_parent.visible_message(span_notice("[attacker] composts [reagent_source], spreading it through [obj_parent]"))
		reagent_source.reagents?.trans_to(obj_parent, reagent_source.reagents.total_volume, transfered_by = attacker)
		SEND_SIGNAL(reagent_source, COMSIG_ITEM_ON_COMPOSTED, attacker)
		qdel(reagent_source)
	//Syringe
	else if(istype(reagent_source, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/syr = reagent_source
		obj_parent.visible_message(span_notice("[attacker] injects [obj_parent] with [syr]"))
		reagent_source.reagents?.trans_to(obj_parent, syr.amount_per_transfer_from_this, transfered_by = attacker)
	//Sprays
	else if(istype(reagent_source, /obj/item/reagent_containers/spray))
		var/obj/item/reagent_containers/spray/spray = reagent_source
		obj_parent.visible_message(span_notice("[attacker] sprays [obj_parent] with [reagent_source]"))
		playsound(obj_parent)
		reagent_source.reagents?.trans_to(obj_parent, spray.amount_per_transfer_from_this, transfered_by = attacker)
	//Let people fill trays with reagents by hand, non legacy
	else if(istype(reagent_source, /obj/item/reagent_containers))
		if(!reagent_source.reagents.total_volume) //It aint got no gas in it
			to_chat(attacker, span_warning("[reagent_source] is empty!"))
			return
		//Transfer reagents
		reagent_source.reagents.trans_to(parent, reagent_source.amount_per_transfer_from_this, transfered_by = attacker)
		to_chat(attacker, span_notice("You add [reagent_source.amount_per_transfer_from_this]u from [reagent_source] to [parent]!"))

/datum/component/planter/proc/async_spade_action(mob/user)
	playsound(parent, 'sound/effects/shovel_dig.ogg', 60)
	if(!do_after(user, 2.3 SECONDS, parent))
		return
	set_substrate(null)

/datum/component/planter/proc/async_hasty_remove(mob/user, obj/item/I)
	if(!do_after(user, 5 SECONDS, parent))
		return
	if(!length(plants))
		return
	for(var/datum/component/plant/plant as anything in plants)
		qdel(plant.plant_item)
	playsound(parent, 'sound/effects/shovel_dig.ogg', 60)

/datum/component/planter/proc/async_spade_options(mob/user, obj/item/I)
	var/list/pick_plants = list()
	var/list/pick_links = list()
	for(var/datum/component/plant/plant as anything in plants)
		var/image/image = new()
		//Get an icon
		var/datum/plant_feature/body/body_feature = locate(/datum/plant_feature/body) in plant.plant_features //Garunteed, or it should be...
		var/datum/plant_feature/fruit/fruit_feature = locate(/datum/plant_feature/fruit) in plant.plant_features //here's the backup, mostly for MUSHROOMS
		//Link it all up
		image.appearance = body_feature.icon_state != "" ? body_feature?.feature_appearance : fruit_feature.feature_appearance
		pick_plants["[plant.plant_item]([length(pick_plants)])"] = image
		pick_links["[plant.plant_item]([length(pick_links)])"] = plant
	var/result = show_radial_menu(user, parent, pick_plants)
	if(!result)
		return
	var/datum/component/plant/plant = pick_links[result]
	I.afterattack(plant.plant_item, user)

/datum/component/planter/proc/catch_examine(datum/source, mob/looker, list/examine_text)
	SIGNAL_HANDLER

	if(substrate)
		examine_text += ("<span class='notice'>[parent] is filled with [substrate.name].\n[substrate.tooltip]</span>")
	else
		examine_text += ("<span class='warning'>[parent] does not contain any substrate!</span>")

/datum/component/planter/proc/catch_entered(datum/source, atom/movable/entering)
	SIGNAL_HANDLER

	var/plant_comp = entering.GetComponent(/datum/component/plant)
	if(!plant_comp)
		return
//Visuals
	entering.layer += layer_upset
	//Add visuals, move the plant upwards to make it look like it's inside us
	entering.pixel_x += visual_upset[1]
	entering.pixel_y += visual_upset[2]
//Records
	plants |= plant_comp
	RegisterSignal(plant_comp, COMSIG_QDELETING, PROC_REF(catch_qdel))

/datum/component/planter/proc/catch_exited(datum/source, atom/movable/exiting)
	SIGNAL_HANDLER

	var/plant_comp = exiting.GetComponent(/datum/component/plant)
	if(!plant_comp)
		return
	exiting.layer -= layer_upset
	exiting.pixel_x -= visual_upset[1]
	exiting.pixel_y -= visual_upset[2]
	plants -= plant_comp
	UnregisterSignal(plant_comp, COMSIG_QDELETING)

/datum/component/planter/proc/set_substrate(_substrate)
	if(!allow_substrate_change)
		return
	SEND_SIGNAL(src, COMSIG_PLANTER_UPDATE_SUBSTRATE_SETUP, substrate)
	if(substrate)
		QDEL_NULL(substrate)
	if(_substrate)
		substrate = new _substrate()
	SEND_SIGNAL(src, COMSIG_PLANTER_UPDATE_SUBSTRATE, substrate)
	return substrate

/datum/component/planter/proc/catch_qdel(datum/source)
	SIGNAL_HANDLER

	plants -= source

#undef WEED_RATE
#undef WEED_THRESHOLD
