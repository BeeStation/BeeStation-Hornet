/obj/item/plant_tray
	name = "plant tray"
	desc = "A fifth generation space compatible botanical growing tray."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "tray"
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE|KEEP_TOGETHER
	density = TRUE
	interaction_flags_item = NONE
	layer = OBJ_LAYER
	///Reagents volume
	var/buffer = 200
	///Do we want the plumbing shit?
	var/plumbing = TRUE
	///Do we gain weeds?
	var/gain_weeds = TRUE
	///Tray component
	var/datum/component/planter/tray_component
	///Our random offset value
	var/list/starting_offset = list(-2, 2, -5, 5)
//Effects
	var/atom/movable/plant_tray_reagents/tray_reagents
	var/icon/mask
	//Mostly used for subtypes, like pots
	var/layer_offset = 0
	///Do we use the substrate sprites?
	var/use_substrate = TRUE
//Tray indicators
	var/use_indicators = TRUE
	///Indicator for when the plant is ready to harvest
	var/obj/effect/tray_indicator/harvest
	var/list/harvestable_components = list()
	//Indicator for when the plant's needs are not met
	var/obj/effect/tray_indicator/need
	var/list/needy_features = list()
	//Indicator for when the plant has 'problem'
	var/obj/effect/tray_indicator/problem
	var/list/problem_features = list()

/obj/item/plant_tray/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	create_reagents(buffer, TRANSPARENT | REFILLABLE)
	if(plumbing)
		AddComponent(/datum/component/plumbing/tank, FALSE)
		AddComponent(/datum/component/simple_rotation)
//Tray component setup
	tray_component = AddComponent(/datum/component/planter, 14, layer_offset, gain_weeds)
	RegisterSignal(tray_component, COMSIG_PLANTER_UPDATE_SUBSTRATE_SETUP, PROC_REF(remove_substrate))
	RegisterSignal(tray_component, COMSIG_PLANTER_UPDATE_SUBSTRATE, PROC_REF(add_substrate))
//Build effects
	//mask for plants
	mask = icon('icons/obj/hydroponics/features/generic.dmi', "[icon_state]_mask")
	//Reagents, for reagents
	tray_reagents = new(src, icon_state, layer)
	vis_contents += tray_reagents
	//Bottom most underlay
	underlays += mutable_appearance('icons/obj/hydroponics/features/generic.dmi', "[icon_state]_bottom", layer-0.1)
//reagents
	tray_reagents.color = mix_color_from_reagents(reagents.reagent_list)
//Build tray indicatos
	if(!use_indicators)
		return
	harvest = new(src, "#0f0", 1)
	need = new(src, "#ff9100", 2)
	problem = new(src, "#f00", 3)
//Apply our starting offset
	pixel_x = rand(starting_offset[1], starting_offset[2])
	pixel_y = rand(starting_offset[3], starting_offset[4])

/obj/item/plant_tray/process(delta_time)
	//Need to update this semi-constantly so it works with plumbing
	update_reagents()
	//Problems
	SEND_SIGNAL(src, COMSIG_PLANT_NEEDS_PAUSE, null, problem_features)
	//Warnings - handled elsewhere too, when listening to plant needs
	if(tray_component.weed_level >= 50)
		vis_contents |= need
	else if(!length(needy_features))
		vis_contents -= need

/obj/item/plant_tray/add_context_self(datum/screentip_context/context, mob/user)
	if(!isliving(user))
		return
	context.add_right_click_tool_action("Plant Seeds", TOOL_SEED)
	context.add_left_click_item_action("Check Alerts", /obj/item/plant_scanner)
	context.add_left_click_item_action("Fill Tray", /obj/item/substrate_bag)

/obj/item/plant_tray/wrench_act(mob/living/user, obj/item/tool)
	//Wrench behaviour for plumbing stuff
	..()
	default_unfasten_wrench(user, tool)
	. = TRUE
	//Visual fluff
	if(anchored)
		pixel_x = 0
		pixel_y = 0
		return
	pixel_x = rand(starting_offset[1], starting_offset[2])
	pixel_y = rand(starting_offset[3], starting_offset[4])

/obj/item/plant_tray/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	//TODO: Using a spade on a tray gives a radial menu for plants to remove - Racc
//Ported legacy code from old trays
	//Composting
	if(IS_EDIBLE(I) || istype(I, /obj/item/reagent_containers/pill))
		visible_message(span_notice("[user] composts [I], spreading it through [src]"))
		I.reagents?.trans_to(src, I.reagents.total_volume, transfered_by = user)
		SEND_SIGNAL(I, COMSIG_ITEM_ON_COMPOSTED, user)
		qdel(I)
	//Syringe
	if(istype(I, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/syr = I
		visible_message(span_notice("[user] injects [src] with [syr]"))
		I.reagents?.trans_to(src, syr.amount_per_transfer_from_this, transfered_by = user)
	//Sprays
	else if(istype(I, /obj/item/reagent_containers/spray))
		var/obj/item/reagent_containers/spray/spray = I
		visible_message(span_notice("[user] sprays [src] with [I]"))
		playsound(src, 'sound/effects/spray3.ogg', 50, 1, -6)
		I.reagents?.trans_to(src, spray.amount_per_transfer_from_this, transfered_by = user)
	//Quick feedback
	update_reagents()

//When a plant is inserted / planted
/obj/item/plant_tray/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	var/datum/component/plant/plant_component = arrived.GetComponent(/datum/component/plant)
//Start listening to component for signals, for indicators
	//Harvest
	RegisterSignal(plant_component, COMSIG_FRUIT_BUILT, PROC_REF(catch_plant_harvest_ready))
	RegisterSignal(plant_component, COMSIG_PLANT_ACTION_HARVEST, PROC_REF(catch_plant_harvest_collected))
	//Needs
	RegisterSignal(plant_component, COMSIG_PLANT_NEEDS_FAILS, PROC_REF(catch_plant_need_fail))
	RegisterSignal(plant_component, COMSIG_PLANT_NEEDS_PASS, PROC_REF(catch_plant_need_pass))
//Visuals
	//Masking
	if(plant_component?.draw_below_water)
		arrived.add_filter("plant_tray_mask", 1, alpha_mask_filter(y = -14, icon = mask, flags = MASK_INVERSE))

//When a plant is uprooted / ceases to exist
/obj/item/plant_tray/Exited(atom/movable/gone, direction)
	. = ..()
//Visuals
	//Remove visuals from previous step
	gone.remove_filter("plant_tray_mask")
	vis_contents -= gone//Do this here because plants don't clean up for themselves
//Component related
	var/datum/component/plant/plant_component = gone.GetComponent(/datum/component/plant)
	if(!plant_component)
		return
	UnregisterSignal(plant_component, COMSIG_FRUIT_BUILT)
	UnregisterSignal(plant_component, COMSIG_PLANT_ACTION_HARVEST)
	UnregisterSignal(plant_component, COMSIG_PLANT_NEEDS_FAILS)
	UnregisterSignal(plant_component, COMSIG_PLANT_NEEDS_PASS)
//Indicators
	//Harvest light
	harvestable_components -= "[ref(plant_component)]"
	//Need light
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		needy_features -= "[ref(feature)]"
	//Problem light
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		problem_features -= "[ref(feature)]"
	update_indicators()

///Helpers to handle substrate vvisuals
/obj/item/plant_tray/proc/add_substrate(_substrate)
	if(!use_substrate)
		return
	var/datum/plant_subtrate/substrate = tray_component.substrate
	underlays += substrate?.substrate_appearance

/obj/item/plant_tray/proc/remove_substrate()
	underlays -= tray_component.substrate?.substrate_appearance

/*
	Signal handlers for plant harvest
*/

/obj/item/plant_tray/proc/catch_plant_harvest_ready(datum/source)
	SIGNAL_HANDLER

	add_feature_indicator(src, source, harvestable_components)

/obj/item/plant_tray/proc/catch_plant_harvest_collected(datum/source)
	SIGNAL_HANDLER

	remove_feature_indicator(src, source, harvestable_components)

/*
	Signal handlers for plant needs
*/
/obj/item/plant_tray/proc/catch_plant_need_fail(datum/source, datum/plant_feature/_needy)
	SIGNAL_HANDLER

	add_feature_indicator(src, _needy, needy_features)

/obj/item/plant_tray/proc/catch_plant_need_pass(datum/source, datum/plant_feature/_passy)
	SIGNAL_HANDLER

	remove_feature_indicator(src, _passy, needy_features)

//You can throw any special reagent logic here
/obj/item/plant_tray/proc/update_reagents()
	if(reagents.total_volume <= 0)
		tray_reagents.color ="#0000"
		return
	tray_reagents.color = mix_color_from_reagents(reagents.reagent_list)

/obj/item/plant_tray/proc/add_feature_indicator(datum/_source, datum/feature, list/feature_list)
	if(!feature_list["[ref(feature)]"])
		feature_list["[ref(feature)]"] = list()
	feature_list["[ref(feature)]"] |= "[ref(_source)]"
	update_indicators()

/obj/item/plant_tray/proc/remove_feature_indicator(datum/_source, datum/feature, list/feature_list)
	if(feature_list["[ref(feature)]"])
		feature_list["[ref(feature)]"] -= "[ref(_source)]"
	if(!length(feature_list["[ref(feature)]"]))
		feature_list -= "[ref(feature)]"
	update_indicators()

/obj/item/plant_tray/proc/update_indicators()
	//needs
	if(length(needy_features))
		vis_contents |= need
	else
		vis_contents -= need
	//harvests
	if(length(harvestable_components))
		vis_contents |= harvest
	else
		vis_contents -= harvest
	//problems
	if(length(problem_features))
		vis_contents |= problem
	else
		vis_contents -= problem

/*
	Some effects live down here
		- Water overlay
*/

//Reagents overlay
/atom/movable/plant_tray_reagents
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "tray_water"
	vis_flags = VIS_INHERIT_ID
	appearance_flags = KEEP_APART
	layer = BELOW_OBJ_LAYER
	color = "#fff0"
	///Water rendered over the plant
	var/mutable_appearance/over_water

/atom/movable/plant_tray_reagents/Initialize(mapload, key = "tray", layer_override)
	. = ..()
	icon_state = "[key]_water"
	layer = layer_override
	over_water = mutable_appearance('icons/obj/hydroponics/features/generic.dmi', "[key]_water_over", layer_override+0.1)
	add_overlay(over_water)
