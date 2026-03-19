#define PLANT_X_CLAMP -8
#define PLANT_Y_CLAMP 4

/obj/item/plant_seeds
	name = "seeds"
	icon = 'icons/obj/hydroponics/features/seeds.dmi'
	icon_state = "base" //Although fruit sets the icon state, roundstart seeds / preset will need it set for caching to work - Non-vendor seeds probably dont need this
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	tool_behaviour = TOOL_SEED
	///Species ID
	var/species_id
	///List of plant features for the plant we're... planting
	var/list/plant_features = list()
	///How many seeds do we contain
	var/seeds = 1
	///Do / What name override do we use?
	var/name_override
	var/desc_override

/obj/item/plant_seeds/Initialize(mapload, list/_plant_features, _species_id)
	. = ..()
	create_reagents(15,  INJECTABLE | NO_REACT)
	species_id = _species_id
	plant_features = length(_plant_features) ? _plant_features.Copy() : plant_features
	for(var/datum/plant_feature/feature as anything in plant_features)
		plant_features -= feature
		var/datum/plant_feature/new_feature
		if(ispath(feature))
			new_feature = new feature()
		else
			new_feature = feature.copy()
		plant_features += new_feature
		new_feature.associate_seeds(src)
	update_plant_name()

/obj/item/plant_seeds/examine(mob/user)
	. = ..()
	. += span_notice("This seed pack contains [seeds] seeds.")

/obj/item/plant_seeds/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	//Custom name with a pen
	if(!istype(I, /obj/item/pen))
		return
	if(QDELETED(src) || !user.canUseTopic(src, BE_CLOSE))
		return
//Desc / name select
	var/selection
	selection = tgui_input_list(user, "Edit name, or description?", "Name or Description", list("name", "desc"))
	if(!selection || QDELETED(src) || !user.canUseTopic(src, BE_CLOSE))
		return
//Text input
	var/input = tgui_input_text(user, "New text", "New text", selection == "name" ? name_override : desc_override, selection == "name" ? MAX_NAME_LEN : MAX_MESSAGE_LEN)
	if(QDELETED(src) || !user.canUseTopic(src, BE_CLOSE))
		return
	//empty input so we return
	if(!input)
		to_chat(user, span_warning("You need to enter something!"))
		return
	//check for slurs
	if(CHAT_FILTER_CHECK(input))
		to_chat(user, span_warning("Your message contains forbidden words."))
		return
	//Apply new override
	if(selection == "name")
		name_override = input
		update_plant_name()
	else
		desc_override = input

/obj/item/plant_seeds/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/info = plant(target, user, proximity_flag, click_parameters)
	if(istext(info))
		to_chat(user, info)

/obj/item/plant_seeds/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is swallowing [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.gib()
	var/datum/plant_feature/fruit/fruit = locate(/datum/plant_feature/fruit) in plant_features
	if(!fruit)
		return
	new fruit.fruit_product(drop_location())
	qdel(src)
	return MANUAL_SUICIDE

//Throw any extra special copy logic in here
/obj/item/plant_seeds/proc/copy()
	var/obj/item/plant_seeds/copy = new type(src.loc, src.plant_features, src.species_id)
	copy.name_override = name_override
	copy.desc_override = desc_override
	return copy

/obj/item/plant_seeds/proc/plant(atom/target, mob/user, proximity_flag, click_parameters, logic)
	//Is this even a planter?
	var/datum/component/planter/tray_component = target.GetComponent(/datum/component/planter)
	if(!tray_component)
		return logic ? FALSE : "<span class='warning'>You can't plant [src] here!</span>"
	//Check if our roots fuck with the substrate we're planting it in
	if(!SEND_SIGNAL(src, COMSIG_SEEDS_POLL_ROOT_SUBSTRATE, tray_component.substrate))
		return logic ? FALSE : "<span class='warning'>You can't plant [src] in this substrate!</span>"
	if(!SEND_SIGNAL(src, COMSIG_SEEDS_POLL_TRAY_SIZE, target))
		return logic ? FALSE : "<span class='warning'>There's no room to plant [src] here!</span>"
	//Plant it
	if(user)
		to_chat(user, "<span class='notice'>You begin to plant [src] into [target].</span>")
	if(!logic && !do_after(user, 2.3 SECONDS, target))
		return
	var/obj/item/plant_item/plant = new(get_turf(target), plant_features, species_id, (name_override || get_species_name(plant_features)))
	var/datum/component/plant/plant_component = plant.GetComponent(/datum/component/plant)
	. = plant_component
	//Plant appearance stuff
	plant.name = name_override || plant.name
	plant.desc = "[plant.desc]\n[desc_override]"
	plant.forceMove(target) //forceMove instead of creating it inside to proc Entered()
	SEND_SIGNAL(plant_component, COMSIG_PLANT_PLANTED, target)
	var/obj/vis_target = target
	vis_target.vis_contents |= plant
	//Decrement seeds until it's depleted
	seeds--
	if(seeds <= 0)
		qdel(src)
	else if(user)
		balloon_alert(user, "[seeds] seeds remain")
	//Mouse offset
	if(!plant_component?.use_mouse_offset)
		return
	var/list/modifiers = params2list(click_parameters)
	if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
		return
	//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the planting turf)
	plant.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, PLANT_X_CLAMP, PLANT_Y_CLAMP)

/obj/item/plant_seeds/proc/update_plant_name()
	name = "[name_override || get_species_name(plant_features)] seeds"

/obj/item/plant_seeds/proc/update_species_id()
	species_id = build_plant_species_id(plant_features)
	SSbotany.plant_species |= species_id

/*
	Preset
	This is used for making  preset species ids work at runtime
*/
/obj/item/plant_seeds/preset

/obj/item/plant_seeds/preset/Initialize(mapload, list/_plant_features, _species_id)
	. = ..()
	if(species_id) //Just in case someone uses it wrong
		return
	update_species_id()

/*
	Random
*/
/obj/item/plant_seeds/random

/obj/item/plant_seeds/random/Initialize(mapload, list/_plant_features, _species_id)
	. = ..()
	var/obj/item/plant_seeds/random_seeds = pick(subtypesof(/obj/item/plant_seeds/preset))
	random_seeds = new random_seeds(src.loc)
	return INITIALIZE_HINT_QDEL

/*
	Debug
*/
/obj/item/plant_seeds/debug
	name = "debug seeds"
	seeds = INFINITY

/obj/item/plant_seeds/debug/Initialize(mapload, list/_plant_features)
	. = ..()
	animate(src, color = "#ff0", time = 1 SECONDS, loop = -1)
	animate(color = "#0f0", time = 1 SECONDS)
	animate(color = "#0ff", time = 1 SECONDS)
	animate(color = "#00f", time = 1 SECONDS)
	animate(color = "#f0f", time = 1 SECONDS)
	animate(color = "#f00", time = 1 SECONDS)

/obj/item/plant_seeds/debug/examine(mob/user)
	. = ..()
	for(var/feature as anything in plant_features)
		to_chat(user, "<span class='notice'>[feature]</span>")

/obj/item/plant_seeds/debug/interact(mob/user)
	. = ..()
	var/list/features = typesof(/datum/plant_feature)
	var/choice = tgui_input_list(user, "Add Feature", "Plant Features", features)
	if(choice)
		var/datum/plant_feature/feature = new choice()
		feature.associate_seeds(src)
		plant_features += feature

/obj/item/plant_seeds/debug/AltClick(mob/user)
	. = ..()
	plant_features = list()

#undef PLANT_X_CLAMP
#undef PLANT_Y_CLAMP
