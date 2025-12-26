//Plant loses 10% of current health per tick
#define BODY_NEEDLESS_DAMAGE 0.025

/datum/plant_feature/body
	species_name = "testus testium"
	name = "plant body"
	icon = 'icons/obj/hydroponics/features/body.dmi'
	icon_state = "tree"
	plant_needs = list(/datum/plant_need/reagent/water, /datum/plant_need/reagent/buff/heal/tier_1, /datum/plant_need/reagent/buff/heal/tier_2, /datum/plant_need/reagent/buff/heal/tier_3,
	/datum/plant_need/reagent/buff/toxin)
	feature_catagories = PLANT_FEATURE_BODY
	trait_type_shortcut = /datum/plant_feature/body

	///How much health this plant body has
	var/health = PLANT_BODY_HEALTH_MEDIUM

	///Max, natural, harvest
	var/max_harvest = PLANT_BODY_HARVEST_LARGE

	///How many harvests does this plant have?
	var/yields = PLANT_BODY_YIELD_MICRO
	///Time between yields
	var/yield_cooldown_time = 0 SECONDS
	COOLDOWN_DECLARE(yield_cooldown)

	///Reference to the effect we use for the body overlay  / visual content
	var/atom/movable/body_appearance
	///Layer offset - 0.01 by default to render over mushrooms
	var/layer_offset = 0.01

	///How many planter slots does this feature take up
	var/slot_size = PLANT_BODY_SLOT_SIZE_LARGE

	///What's the upper fruit size we can hold?
	var/upper_fruit_size = PLANT_FRUIT_SIZE_LARGE

	///How many seeds does this plant give seed packets
	var/seeds = 1

///Growth cycle
	var/growth_stages = 3
	var/current_stage
	var/growth_time = 1 SECONDS
	var/growth_time_elapsed = 0

///Visual technical
	///Fruit overlays we're responsible for
	var/list/fruit_overlays = list()
	///List of fruit overlay positions
	var/list/overlay_positions = list(list(11, 20), list(16, 30), list(23, 23), list(8, 31))
	///Do we exist over the water? Use this for stuff that should never be drawn under the tray water
	var/draw_below_water = TRUE
	///Do we use the mouse offset when planting?
	var/use_mouse_offset = FALSE
	///Icon for when we're out of yields
	var/wither_state

/datum/plant_feature/body/New(datum/component/plant/_parent)
//Appearance bullshit
	//Body appearance
	feature_appearance = mutable_appearance(icon, icon_state)
	body_appearance = new()
	body_appearance.appearance = feature_appearance
	body_appearance.vis_flags = VIS_INHERIT_ID
	return ..()

/datum/plant_feature/body/Destroy(force, ...)
	. = ..()
	parent?.plant_item?.vis_contents -= body_appearance
	parent?.plant_item.layer -= layer_offset

/datum/plant_feature/body/get_scan_dialogue()
	. = ..()
	. += "Harvest Size: [max_harvest]\n"
	. += "Remaining Yields: [yields]\n"
	. += "Growth Time: [growth_time/10] seconds\n"
	. += "Fruit Size: [upper_fruit_size]\n"
	. += "Plant Size: [slot_size]\n"
	. += "Plant Health: [health]"

/datum/plant_feature/body/get_ui_data()
	. = ..()
	. += list(PLANT_DATA("Harvest Size", max_harvest), PLANT_DATA("Yields", yields), PLANT_DATA("Growth Time", "[growth_time/10] seconds"), PLANT_DATA("Fruit Size", "[upper_fruit_size]"), PLANT_DATA("Plant Size", "[slot_size]"),
	PLANT_DATA("Plant Health", health), PLANT_DATA(null, null))

/datum/plant_feature/body/process(delta_time)
	var/obj/item/plant_tray/tray = parent.plant_item.loc
	if(health <= initial(health)*0.5 && istype(tray))
		tray.add_feature_indicator(src, src, tray.problem_features)
	else if(istype(tray))
		tray.remove_feature_indicator(src, src, tray.problem_features)
	if(health <= 0)
		catch_harvest()
		return
	//If needs aren't met, we start taking % damage, but this source can't kill us, just weakens
	if(!SEND_SIGNAL(tray, COMSIG_PLANTER_PAUSE_PLANT) && !check_needs(delta_time))
		adjust_health(health*BODY_NEEDLESS_DAMAGE*-1)
//Growth
	if(growth_time_elapsed < growth_time)
		growth_time_elapsed += delta_time SECONDS
		growth_time_elapsed = min(growth_time, growth_time_elapsed)
		current_stage = max(1, FLOOR((growth_time_elapsed/growth_time)*growth_stages, 1))
		//If our parent is eager to be an adult, used for pre-existing plants
		if(parent?.skip_growth)
			growth_time_elapsed = growth_time
			current_stage = growth_stages
		//Signal for traits and other shit to hook effects into
		if(current_stage >= growth_stages)
			SEND_SIGNAL(src, COMSIG_PLANT_GROW_FINAL)
//Harvests
	if(current_stage >= growth_stages && COOLDOWN_FINISHED(src, yield_cooldown_time) && !length(fruit_overlays) && yields > 0)
		setup_fruit(parent?.skip_growth)
		parent?.skip_growth = FALSE //We can happily set this to false here in any case without issues

/datum/plant_feature/body/setup_parent(_parent, reset_features = TRUE)
//Undo any sins
	//Fruit overlay clean up
	for(var/overlay as anything in fruit_overlays)
		parent?.plant_item?.vis_contents -= overlay
		fruit_overlays -= overlay
		qdel(overlay)
	//Remove any old signals or misc overlays
	if(parent)
		UnregisterSignal(parent, COMSIG_PLANT_ACTION_HARVEST)
		UnregisterSignal(parent, COMSIG_PLANT_POLL_TRAY_SIZE)
		parent.plant_item.vis_contents -= body_appearance
	//Reset our growth, yield, etc.
	if(reset_features)
		current_stage = initial(current_stage)
		yields = initial(yields)
	growth_time_elapsed = 0 //just in-case idk
//Start a new life
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent, COMSIG_PLANT_ACTION_HARVEST, PROC_REF(catch_harvest))
	RegisterSignal(parent, COMSIG_PLANT_POLL_TRAY_SIZE, PROC_REF(catch_occupation))
	//Appearance
	if(parent.use_body_appearance && parent.plant_item)
		parent.plant_item.vis_contents += body_appearance
	//Draw settings
	parent.draw_below_water = draw_below_water
	parent.plant_item.layer = draw_below_water ? OBJ_LAYER : ABOVE_OBJ_LAYER
	parent.use_mouse_offset = use_mouse_offset
	parent.plant_item.layer += layer_offset
	//Start growin'
	START_PROCESSING(SSobj, src)

/datum/plant_feature/body/associate_seeds(obj/item/plant_seeds/seeds)
	. = ..()
	seeds.seeds = src.seeds //This does mean seeds come magically out of thin air in the seed editor but it's convenient design wise
	RegisterSignal(seeds, COMSIG_SEEDS_POLL_TRAY_SIZE, PROC_REF(catch_occupation))

/datum/plant_feature/body/catch_planted(datum/source, atom/destination)
	. = ..()
	var/datum/component/planter/tray_component = destination.GetComponent(/datum/component/planter)
	if(!tray_component)
		return
	tray_component.plant_slots -= slot_size

/datum/plant_feature/body/catch_uprooted(datum/source, mob/user, obj/item/tool, atom/old_loc)
	. = ..()
	var/datum/component/planter/tray_component = old_loc.GetComponent(/datum/component/planter)
	if(!tray_component)
		return
	tray_component.plant_slots += slot_size

/datum/plant_feature/body/proc/setup_fruit(skip_growth)
	if(current_stage < growth_stages)
		return
	var/list/visual_fruits = list()
	SEND_SIGNAL(parent, COMSIG_PLANT_REQUEST_FRUIT, max_harvest, visual_fruits, skip_growth)
	var/list/available_positions = overlay_positions.Copy()
	for(var/obj/effect/fruit_effect as anything in visual_fruits)
		if(!length(available_positions))
			return
		//Do it like this becuase remove a list from a non-dictionary list is weird and bad and awful
		var/position_index = rand(1, length(available_positions))
		var/list/position = available_positions[position_index]
		available_positions.Cut(position_index, position_index+1)
		apply_fruit_overlay(fruit_effect, position[1], position[2])

///Position and manipulate fruit overlays
/datum/plant_feature/body/proc/apply_fruit_overlay(obj/effect/fruit_effect, offset_x, offset_y)
	fruit_effect.pixel_x = offset_x-16
	fruit_effect.pixel_y = offset_y-16
	if(prob(50)) //50% chance for fruit to be mirrored
		fruit_effect.transform = fruit_effect.transform.Scale(-1, 1)
		fruit_effect.pixel_x -= 1 //If your sprite is formatted correctly, this will recenter the stem after the flip
	parent.plant_item.vis_contents += fruit_effect
	fruit_overlays += fruit_effect
	return

/datum/plant_feature/body/proc/catch_harvest(datum/source, mob/user, list/temp_fruits, dummy_harvest = FALSE)
	SIGNAL_HANDLER

//Remove our fruit overlays
	for(var/fruit_effect as anything in fruit_overlays)
		fruit_overlays -= fruit_effect
		parent.plant_item.vis_contents -= fruit_effect
	yields -= !dummy_harvest
//Handle yields
	if(yields <= 0 || health <= 0)
		if(!wither_state)
			parent.plant_item.add_filter("wither_colours", 1, color_matrix_filter(list(rgb(193, 87, 87), rgb(76, 128, 76), rgb(76, 76, 128)) ,COLORSPACE_RGB))
		return
	COOLDOWN_START(src, yield_cooldown, yield_cooldown_time)

///Essentially just checks if there's room for us. Also lets some plants have special occupation rules - Please consider substrate stuff for special planting rules before you use this.
/datum/plant_feature/body/proc/catch_occupation(datum/source, atom/location)
	SIGNAL_HANDLER

	var/datum/component/planter/tray_component = location.GetComponent(/datum/component/planter)
	if(!tray_component)
		return
	if(tray_component.plant_slots - slot_size < 0)
		return
	return TRUE

//Special health logic and signals live here
/datum/plant_feature/body/proc/adjust_health(amount)
	health += amount
	health = clamp(health, 0, initial(health))

#undef BODY_NEEDLESS_DAMAGE
