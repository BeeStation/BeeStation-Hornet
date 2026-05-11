/obj/machinery/plant_machine/plant_mutator
	name = "irradiator kiln"
	desc = "A large kiln designed to safely expose plants to radiation particles from excited plasma gas.\n\
	Hardware upgrades reduce the operation cost of gas."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "mutator_open"
	density = TRUE
	pass_flags = PASSTABLE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	circuit = /obj/item/circuitboard/machine/plant_mutator

	///Last 'command' for UI stuff
	var/last_command = ""

	///Catalyst tank  we use for source of plasma
	var/obj/item/tank/catalyst

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
	///Our reduction on mutation prices
	var/reduction_coef = 1

/obj/machinery/plant_machine/plant_mutator/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PLANTER_PAUSE_PLANT, PROC_REF(catch_pause))
	var/obj/item/tank/internals/plasma/plasma_tank = new(get_turf(src))
	attackby(plasma_tank)
	rad_ghost = new(src)
	soundloop = new(src,  FALSE)

/obj/machinery/plant_machine/plant_mutator/Destroy()
	. = ..()
	QDEL_NULL(soundloop)

/obj/machinery/plant_machine/plant_mutator/examine(mob/user)
	. = ..()
	. += span_notice("The gas cost reduction coefficient is [reduction_coef*100]%, a reduction of [(1-reduction_coef)*100]%.")

/obj/machinery/plant_machine/plant_mutator/RefreshParts()
	. = ..()
	var/total_rating = 0
	for(var/obj/item/stock_parts/S in component_parts)
		total_rating += S.rating
	reduction_coef = 6/total_rating
	return total_rating

/obj/machinery/plant_machine/plant_mutator/proc/catch_pause(datum/source)
	SIGNAL_HANDLER

	return TRUE

/obj/machinery/plant_machine/plant_mutator/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	to_chat(user, span_danger("A plant can be inserted into [src] using a spade."))

/obj/machinery/plant_machine/plant_mutator/add_context_self(datum/screentip_context/context, mob/user)
	if(!isliving(user))
		return
	if(catalyst)
		context.add_right_click_action("Remove Tank")
	else
		context.add_left_click_action("Insert Tank")

//Insert
/obj/machinery/plant_machine/plant_mutator/attackby(obj/item/C, mob/user)
	if(working)
		return ..()
//Catalyst
	if(!catalyst && istype(C, /obj/item/tank))
		catalyst = C
		catalyst.forceMove(src)
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
		confirm_radiation = FALSE
		icon_state = "mutator_open"
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
	if(!do_after(user, 2.5 SECONDS, src))
		return
	if(!(locate(plant_item) in C.contents))
		return
	C.vis_contents -= plant_item
	plant_item.forceMove(src)
	plant = plant_item
	plant_component = comp
	icon_state = "mutator"
	playsound(src, 'sound/machines/click.ogg', 30)
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
	data["catalyst_strength"] = catalyst?.air_contents?.total_moles()
	//Machine info
	data["confirm_radiation"] = confirm_radiation
	data["working"] = working
	data["port_traits"] = port_traits
	return data

/obj/machinery/plant_machine/plant_mutator/ui_act(action, params)
	if(..())
		return
	if(working)
		return
	playsound(controller, get_sfx("keyboard"), 30, TRUE)
	switch(action)
		if("select_feature")
			current_feature_ref = current_feature_ref == params["key"] ? null : params["key"]
			current_feature = locate(current_feature_ref)
			last_command = "pit feature select -m [encrypt_ref(params["key"])]"
			return TRUE
		if("cancel")
			confirm_radiation = FALSE
			return TRUE
		if("toggle_port")
			port_traits = params["port_state"] //You could make this port_traits = !port_traits, but I suspect that might lead to UI desync
			return TRUE
		if("mutate")
			//Fix focus
			if(current_feature_ref != params["key"])
				current_feature_ref = params["key"]
				current_feature = locate(current_feature_ref)
			//Confirmation
			if(!confirm_radiation)
				confirm_radiation = TRUE
				return TRUE
			//Nuke the SOB
			last_command = "per kiln heat -f -k -m [encrypt_ref(params["key"])]"
			confirm_radiation = FALSE
			if(!catalyst?.air_contents?.has_gas(/datum/gas/plasma, 1))
				playsound(controller, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Tank lacks adequate moles!")
				return TRUE
			var/datum/plant_feature/feature = locate(current_feature_ref)
			if(!length(feature.mutations))
				playsound(controller, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Feature lacks genetic avenues!")
				return TRUE
			//Check compatibility
			var/datum/plant_feature/new_feature = pick(feature.mutations)
			//Tax plasma
			var/tax = (feature.mutations[new_feature] || 1)*reduction_coef
			if(!catalyst?.air_contents?.has_gas(/datum/gas/plasma, tax))
				playsound(controller, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Tank lacks adequate moles, operation requires [tax] moles!")
				return TRUE
			catalyst?.air_contents.remove_specific(/datum/gas/plasma, tax)
			//Flight checks
			new_feature = new new_feature(plant_component)
			for(var/datum/plant_feature/current_feature as anything in plant_component.plant_features-feature)
				//Is this feature blacklisted from another feature
				if(is_type_in_typecache(new_feature, current_feature.blacklist_features) || is_type_in_typecache(current_feature, new_feature.blacklist_features))
					playsound(controller, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition not compatible with selected feature!")
					qdel(new_feature)
					return TRUE
				//If a feature has a whitelist, are we in it?
				if(length(current_feature.whitelist_features) && !is_type_in_typecache(new_feature, current_feature.whitelist_features) || length(new_feature.whitelist_features) && !is_type_in_typecache(current_feature, new_feature.whitelist_features))
					playsound(controller, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition not compatible with selected feature!")
					qdel(new_feature)
					return TRUE
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
			//In case there's fruit on us and we're mutating a non-fruit feature
			var/datum/plant_feature/fruit/fruit_feature = locate(/datum/plant_feature/fruit) in plant_component.plant_features
			fruit_feature?.catch_attack_hand()
			//Out with the old, in with the new
			plant_component.plant_features -= feature
			if(!QDELING(new_feature))
				plant_component.plant_features += new_feature
			//Reset species id so a new one can be made
			plant_component.compile_species_id()
			//Reset the plant's growth
			for(var/datum/plant_feature/body/body_feature in plant_component.plant_features)
				body_feature.growth_time_elapsed = 0
				body_feature.current_stage = 1
				body_feature.growth_step(1)
			qdel(feature)
			working = TRUE
			icon_state = "mutator_on"
			vis_contents |= rad_ghost
			soundloop.start()
			addtimer(CALLBACK(src, PROC_REF(reset_working)), working_time)
			current_feature_ref = REF(new_feature)
			current_feature = new_feature
			return TRUE

/obj/machinery/plant_machine/plant_mutator/proc/reset_working()
	working = FALSE
	icon_state = "mutator"
	vis_contents -= rad_ghost
	soundloop.stop()
	ui_update()

//Circuitboard
/obj/item/circuitboard/machine/plant_mutator
	name = "irradiator kiln (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/plant_machine/plant_mutator
	req_components = list(/obj/item/stock_parts/matter_bin = 2, /obj/item/stock_parts/manipulator = 2, /obj/item/stock_parts/capacitor = 1, /obj/item/stock_parts/scanning_module = 1)

/datum/design/board/plant_mutator
	name = "Irradiator Kiln Board"
	id = "plant_mutator_board"
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE
	build_path = /obj/item/circuitboard/machine/plant_mutator
	category = list ("initial", "Misc. Machinery")

/*
	Tutorial variant
*/
/obj/machinery/plant_machine/plant_mutator/tutorial
	color = "#0f0" //Make it easier for mappers to identify

/obj/machinery/plant_machine/plant_mutator/tutorial/Initialize(mapload)
	. = ..()
	color = "#fff"
	new /obj/item/sticker/sticky_note/tutorial/catalyst(src)

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
