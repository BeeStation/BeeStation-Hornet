#define RAD_GAIN_MOD 0.01

/obj/machinery/plant_machine/plant_mutator
	name = "irradiator kiln"
	desc = "A large kiln designed to safely expose plants to radiation."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "mutator"
	density = TRUE
	pass_flags = PASSTABLE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND

	///Last 'command' for UI stuff
	var/last_command = ""

	///Catalyst item we use for source of rads
	var/obj/item/catalyst
	///Shortcut to catalyst's radiation component
	var/datum/component/irradiated/radiation
	///How much rads we've saved up
	var/stored_rads = 0

	///Refence to our working animation effect overlay thing
	var/obj/effect/mutator_working/rad_ghost
	/// Cuz the soundbyte isnt very long
	var/datum/looping_sound/microwave/soundloop

	///The plant we're michael-waving
	var/obj/item/plant
	///Shortcut to component
	var/datum/component/plant/plant_component
	///Currently selected feature
	var/datum/plant_feature/current_feature
	var/current_feature_ref

	///Do we want port traits from old features to new features?
	var/port_traits = FALSE
	///UI confirmation switch so we don't have accidents
	var/confirm_radiation = FALSE
	///Are we under going the process of mutating?
	var/working = FALSE
	var/working_time = 5 SECONDS

/obj/machinery/plant_machine/plant_mutator/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	var/obj/item/irradiated_rock/rock = new(get_turf(src))
	attackby(rock)
	rad_ghost = new(src)
	soundloop = new(src,  FALSE)

/obj/machinery/plant_machine/plant_mutator/Destroy()
	. = ..()
	QDEL_NULL(soundloop)

/obj/machinery/plant_machine/plant_mutator/process(delta_time)
	if(!radiation)
		return
	stored_rads += radiation.intensity * RAD_GAIN_MOD * delta_time
	ui_update()

/obj/machinery/plant_machine/plant_mutator/add_context_self(datum/screentip_context/context, mob/user)
	. = ..()
	if(!isliving(user))
		return
	context.add_left_click_item_action("Insert Plant", /obj/item/shovel/spade)
	context.add_left_click_item_action("Insert Disk", /obj/item/disk/plant_disk)

//Insert
/obj/machinery/plant_machine/plant_mutator/attackby(obj/item/C, mob/user)
	if(working)
		return ..()
//Catalyst
	radiation = radiation || C.GetComponent(/datum/component/irradiated)
	if(radiation && !catalyst)
		C.forceMove(src)
		catalyst = C
		ui_update()
		return
//Spade / Plant
	if(!istype(C, /obj/item/shovel/spade))
		return ..()
	//Return plant to spade, to remove it
	if(plant && plant_component.async_catch_attackby(C, user))
		plant = null
		plant_component = null
		current_feature = null
		current_feature_ref = null
		ui_update()
		return
	//Insert plant from spade
	var/datum/component/plant/comp
	var/obj/item/plant_item
	for(var/obj/item/potential_plant in C.contents)
		comp = potential_plant.GetComponent(/datum/component/plant)
		plant_item = potential_plant
		if(!C)
			continue
		break
	if(!comp)
		return ..()
	C.vis_contents -= plant_item
	plant_item.forceMove(src)
	plant = plant_item
	plant_component = comp
	ui_update()

//Remove
/obj/machinery/plant_machine/plant_mutator/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(working)
		return
	if(!catalyst)
		return
	catalyst.forceMove(get_turf(src))
	user.put_in_active_hand(catalyst)
	catalyst = null
	radiation = null

/obj/machinery/plant_machine/plant_mutator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlantMutator")
		ui.open()

/obj/machinery/plant_machine/plant_mutator/ui_data(mob/user)
	var/list/data = list()
	//last command, cosmetic
	data["last_command"] = last_command
	//generic stats
	data["plant_feature_data"] = list()
	if(plant_component)
		for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
			data["plant_feature_data"] += list(feature.get_ui_stats())
	//current feature
	data["current_feature"] = current_feature_ref
	data["current_feature_data"] = current_feature?.get_ui_data()
	data["current_feature_traits"] = current_feature?.get_ui_traits()
	//Current inserted plant's name
	data["inserted_plant"] = capitalize(plant?.name)
	//Catalyst info
	data["catalyst"] = capitalize(catalyst?.name)
	data["catalyst_desc"] = catalyst?.desc
	data["catalyst_strength"] = stored_rads
	//Machine info
	data["confirm_radiation"] = confirm_radiation
	data["working"] = working
	data["port_traits"] = port_traits
	return data

/obj/machinery/plant_machine/plant_mutator/ui_act(action, params)
	if(..())
		return
	playsound(src, get_sfx("keyboard"), 30, TRUE)
	switch(action)
		if("select_feature")
			current_feature_ref = current_feature_ref == params["key"] ? null : params["key"]
			current_feature = locate(current_feature_ref)
			last_command = "pit feature select -m [params["key"]]"
			ui_update()
		if("cancel")
			confirm_radiation = FALSE
			ui_update()
		if("toggle_port")
			port_traits = params["port_state"] //You could make this port_traits = !port_traits, but I suspect that might lead to UI desync
			ui_update()
		if("mutate")
			//Fix focus
			if(current_feature_ref != params["key"])
				current_feature_ref = params["key"]
				current_feature = locate(current_feature_ref)
				ui_update()
			//Confirmation
			if(!confirm_radiation)
				confirm_radiation = TRUE
				ui_update()
				return
			//Nuke the SOB
			last_command = "per kiln heat -f -k -m [params["key"]]"
			confirm_radiation = FALSE
			ui_update()
			if(!catalyst)
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: No catalyst inserted!")
				return
			if(stored_rads <= 0)
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Catalyst lacks adequate radioactivity!")
				return
			var/datum/plant_feature/feature = locate(current_feature_ref)
			if(!length(feature.mutations))
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Feature lacks genetic avenues!")
				return
			//Check compatibility
			var/datum/plant_feature/new_feature = pick(feature.mutations)
			//Tax radiation
			var/tax = feature.mutations[new_feature] || 1
			if(stored_rads-tax <= 0)
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Catalyst lacks adequate radioactivity, operation requires [tax] Roentgen!")
				return
			stored_rads -= tax
			//Flight checks
			new_feature = new new_feature(plant_component)
			for(var/datum/plant_feature/current_feature as anything in plant_component.plant_features-feature)
				//Is this feature blacklisted from another feature
				if(is_type_in_typecache(new_feature, current_feature.blacklist_features) || is_type_in_typecache(current_feature, new_feature.blacklist_features))
					playsound(src, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition not compatible with selected feature!")
					qdel(new_feature)
					return
				//If a feature has a whitelist, are we in it?
				if(length(current_feature.whitelist_features) && !is_type_in_typecache(new_feature, current_feature.whitelist_features) || length(new_feature.whitelist_features) && !is_type_in_typecache(current_feature, new_feature.whitelist_features))
					playsound(src, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition not compatible with selected feature!")
					qdel(new_feature)
					return
			//Transfer old feature's traits to new feature
			if(port_traits)
				for(var/datum/plant_trait/trait as anything in feature.plant_traits)
					var/bad_hit = FALSE
					for(var/datum/plant_trait/local_trait as anything in new_feature.plant_traits)
						if(!trait.allow_multiple && local_trait.get_id() == trait.get_id())
							bad_hit = TRUE
							break
					if(bad_hit)
						continue
					var/datum/plant_trait/new_trait = trait.copy(new_feature)
					if(!QDELING(new_trait))
						new_feature.plant_traits += new_trait
			//Out with the old, in with the new
			plant_component.plant_features -= feature
			if(!QDELING(new_feature))
				plant_component.plant_features += new_feature
			//Reset species id so a new one can be made
			plant_component.compile_species_id()
			//Reset the plant's growth
			for(var/datum/plant_feature/body/body_feature in plant_component.plant_features)
				body_feature.growth_time_elapsed = 0
				body_feature.current_stage = 0
			qdel(feature)
			working = TRUE
			icon_state = "mutator_on"
			vis_contents |= rad_ghost
			soundloop.start()
			addtimer(CALLBACK(src, PROC_REF(reset_working)), working_time)
			current_feature_ref = ref(new_feature)
			current_feature = new_feature
			ui_update()

/obj/machinery/plant_machine/plant_mutator/proc/reset_working()
	working = FALSE
	icon_state = "mutator"
	vis_contents -= rad_ghost
	soundloop.stop()
	ui_update()

//Circuitboard
/obj/item/circuitboard/machine/plant_mutator
	name = "plant mutator (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/plant_machine/plant_mutator
	req_components = list(/obj/item/stock_parts/matter_bin = 2, /obj/item/stock_parts/manipulator = 2, /obj/item/stock_parts/capacitor = 1, /obj/item/stock_parts/scanning_module = 1)

/*
	Effect for mutator working
*/
/obj/effect/mutator_working
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "mutator_effect"
	color = "#5eff0069"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/mutator_working/Initialize(mapload)
	. = ..()
//Emmisive
	var/mutable_appearance/emissive = emissive_appearance(icon, icon_state)
	add_overlay(emissive)
//Bump up the size
	var/matrix/n_transform = transform
	n_transform.Scale(1.5, 1.5)
	transform = n_transform
//Wave filter
	add_filter("wavy", 1, wave_filter(1, 0.1, 1, 1, WAVE_SIDEWAYS))
	//Animation
	var/filter = get_filter("wavy")
	animate(filter, offset = 1, time = 1 SECONDS, loop = -1)
	animate(offset = 0, time = 0 SECONDS)

/*

*/
/obj/item/irradiated_rock
	name = "debris"
	desc = "A piece of cement broken away from its original structure. It's still warm with the energy of an artificial sun."
	icon_state = "skub"

/obj/item/irradiated_rock/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/irradiated, 1)

#undef RAD_GAIN_MOD
