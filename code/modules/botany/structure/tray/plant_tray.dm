/obj/item/plant_tray
	name = "plant tray"
	desc = "A fifth generation space compatible botanical growing tray."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "tray"
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE|KEEP_TOGETHER
	density = TRUE
	interaction_flags_item = NONE
	layer = OBJ_LAYER
	pass_flags_self = PASSSTRUCTURE
	pass_flags = NONE
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
	///Plant offset to properly line things up
	var/list/plant_offset = list(-2, 14)
	///Can this tray be scanned with a plant scanner?
	var/can_scan = TRUE
//Effects
	var/mutable_appearance/tray_reagents
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
	///Tray direction
	var/obj/effect/tray_direction/direction

/obj/item/plant_tray/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	create_reagents(buffer, TRANSPARENT | REFILLABLE)
	if(plumbing)
		AddComponent(/datum/component/plumbing/tank, FALSE)
		AddComponent(/datum/component/simple_rotation)
//Tray component setup
	tray_component = AddComponent(/datum/component/planter, plant_offset, layer_offset, gain_weeds)
	RegisterSignal(tray_component, COMSIG_PLANTER_UPDATE_SUBSTRATE_SETUP, PROC_REF(remove_substrate))
	RegisterSignal(tray_component, COMSIG_PLANTER_UPDATE_SUBSTRATE, PROC_REF(add_substrate))
//Build effects
	//mask for plants
	mask = icon(icon, "[icon_state]_mask")
	//Reagent liquids, visual puddle
	tray_reagents = mutable_appearance(src.icon, "[icon_state]_water", layer)
	tray_reagents.add_overlay(mutable_appearance(src.icon, "[icon_state]_water_over", layer+0.1))
	tray_reagents.appearance_flags = KEEP_APART
	tray_reagents.color = mix_color_from_reagents(reagents.reagent_list)
	if(length(reagents.reagent_list))
		add_overlay(tray_reagents)
	//Bottom most underlay
	underlays += mutable_appearance(icon, "[icon_state]_bottom", layer-0.1)
	//Direction
	direction = new(src)
	vis_contents += direction
//Build tray indicatos
	if(!use_indicators)
		return
	harvest = new(src, COLOR_VIBRANT_LIME, 1)
	need = new(src, COLOR_ORANGE, 2)
	problem = new(src, COLOR_RED, 3)
//Apply our starting offset
	pixel_x = rand(starting_offset[1], starting_offset[2])
	pixel_y = rand(starting_offset[3], starting_offset[4])

/obj/item/plant_tray/Destroy(force)
	. = ..()
	QDEL_NULL(mask)
	QDEL_NULL(tray_reagents)
	QDEL_NULL(direction)
	QDEL_NULL(harvest)
	QDEL_NULL(need)
	QDEL_NULL(problem)

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

/obj/item/plant_tray/setDir(ndir)
	if(ndir == dir || !plumbing)
		return ..()
	direction.dir = dir
	direction.alpha = 255
	animate(direction, alpha = 0, time = 1.3 SECONDS)
	return ..()

/obj/item/plant_tray/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	to_chat(user, span_notice("You start furiously plunging [name]."))
	if(do_after(user, 30, target = src))
		to_chat(user, span_notice("You finish plunging the [name]."))
		reagents.expose(get_turf(src), TOUCH) //splash on the floor
		reagents.clear_reagents()

/obj/item/plant_tray/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(length(harvest))
		to_chat(user, span_danger("Harvest plants by clicking on them!"))
	to_chat(user, span_danger("You need a plant scanner to check weed level, and alert descriptions."))

/obj/item/plant_tray/add_context_self(datum/screentip_context/context, mob/user)
	if(!isliving(user))
		return
	context.add_right_click_tool_action("Plant Seeds", TOOL_SEED)
	context.add_right_click_item_action("Remove All Plants", /obj/item/shovel/spade)
	context.add_left_click_item_action("Check Alerts", /obj/item/plant_scanner)
	context.add_left_click_item_action("Fill Tray", /obj/item/substrate_bag)
	context.add_alt_click_action("Rotate Plumbing")

//Wrench behaviour for plumbing stuff
/obj/item/plant_tray/wrench_act(mob/living/user, obj/item/tool)
	if(!default_unfasten_wrench(user, tool))
		return
	. = TOOL_ACT_TOOLTYPE_SUCCESS
	//Visual fluff
	if(anchored)
		pixel_x = 0
		pixel_y = 0
		return
	pixel_x = rand(starting_offset[1], starting_offset[2])
	pixel_y = rand(starting_offset[3], starting_offset[4])

/obj/item/plant_tray/attackby(obj/item/attacking_item, mob/living/user, params)
	. = ..()
	if(attacking_item?.reagents?.total_volume && reagents.total_volume < reagents.maximum_volume)
		playsound(src, 'sound/effects/footstep/water4.ogg', 30, TRUE)
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
		arrived.add_filter("plant_tray_mask", 1, alpha_mask_filter(y = -plant_offset[2], icon = mask, flags = MASK_INVERSE))

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
	harvestable_components -= "[REF(plant_component)]"
	//Need light
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		needy_features -= "[REF(feature)]"
	//Problem light
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		problem_features -= "[REF(feature)]"
	update_indicators()

///Helpers to handle substrate vvisuals
/obj/item/plant_tray/proc/add_substrate()
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
	cut_overlay(tray_reagents)
	if(reagents.total_volume <= 1)
		return
	tray_reagents.color = mix_color_from_reagents(reagents.reagent_list)
	add_overlay(tray_reagents)

/obj/item/plant_tray/proc/add_feature_indicator(datum/_source, datum/feature, list/feature_list)
	var/key = isatom(_source) ? REF(_source) : _source //let coders pass a string instead of a responsible atom, if need be
	if(!feature_list["[REF(feature)]"])
		feature_list["[REF(feature)]"] = list()
	feature_list["[REF(feature)]"] |= "[key]"
	update_indicators()

/obj/item/plant_tray/proc/remove_feature_indicator(datum/_source, datum/feature, list/feature_list)
	var/key = isatom(_source) ? REF(_source) : _source
	if(feature_list["[REF(feature)]"])
		feature_list["[REF(feature)]"] -= "[key]"
	if(!length(feature_list["[REF(feature)]"]))
		feature_list -= "[REF(feature)]"
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
