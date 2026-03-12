#define PC_LINK_RANGE 3

/obj/machinery/computer/plant_machine_controller
	name = "hydroponics machine terminal"
	desc = "A proprietary terminal made by Yamato to control Yamato machines. It's clearly an older design."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "pc"
	base_icon_state = "pc"
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	smoothing_flags = NONE
	circuit = /obj/item/circuitboard/computer/plant_machine_controller
	///List of linked machines
	var/list/machines = list()
	///List of assembled machine options
	var/list/machine_options = list()
	var/list/option_links = list()

	///Navigation
	var/selected_chapter = "features"
	var/selected_entry
	var/selected_type_shortcut

	///Refernece to our screen effect
	var/obj/effect/hydroponics_screen/screen

	///Last 'command' for UI stuff
	var/last_command = ""

/obj/machinery/computer/plant_machine_controller/Initialize(mapload)
	. = ..()
	desc += span_notice("\nAlt-click to resync nearby machines.")
	screen = new(src, "pc_on")
	//Attach some stickers randomly for fun
	var/list/stickers = list(/obj/item/sticker/series_2/flower, /obj/item/sticker/series_2/banana, /obj/item/sticker/series_2/tomato)
	for(var/obj/item/sticker/sticker as anything in stickers)
		var/obj/item/sticker/new_sticker = new sticker(loc)
		new_sticker.afterattack(src, src, TRUE)
		new_sticker.pixel_y = rand(-8, 8)
		new_sticker.pixel_x = rand(-8, 8)

/obj/machinery/computer/plant_machine_controller/LateInitialize()
	. = ..()
	locate_machines()
	selected_entry = ref(pick(SSbotany.chapters["features"]))

/obj/machinery/plant_machine/plant_mutator/add_context_self(datum/screentip_context/context, mob/user)
	if(!isliving(user))
		return
	context.add_alt_click_action("Re-Link Nearby Machines")

/obj/machinery/computer/plant_machine_controller/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	var/result = show_radial_menu(user, src, machine_options)
	if(!result)
		return
	var/obj/machinery/machine = option_links[result]
	machine.ui_interact(user)
	screen.flash()

/obj/machinery/computer/plant_machine_controller/AltClick(mob/user)
	. = ..()
	to_chat(user, span_notice("Resyncing machines..."))
	playsound(src, 'sound/effects/fastbeep.ogg', 60)
	locate_machines()

/obj/machinery/computer/plant_machine_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlantDictionary")
		ui.open()

/obj/machinery/computer/plant_machine_controller/ui_static_data(mob/user)
	. = ..()
	var/list/data = list()
	//last command, cosmetic
	data["last_command"] = last_command
	//Chapters, seperate content
	data["chapters"] = list("plants" = list(), "features" = list(), "traits" = list())
	//Features
	for(var/datum/plant_feature/feature as anything in SSbotany.chapters["features"])
		var/list/feature_list = list()
		feature_list["data"] = feature.get_ui_data()
		feature_list["traits"] =feature.get_ui_traits()
		feature_list["stats"] = feature.get_ui_stats()
		//An interesting way of seperating features into their distinct types
		data["chapters"]["features"]["[feature.trait_type_shortcut]"] = data["chapters"]["features"]["[feature.trait_type_shortcut]"] || list()
		data["chapters"]["features"]["[feature.trait_type_shortcut]"] += list("[ref(feature)]" = feature_list)
	//Traits
	data["chapters"]["traits"]["reagents"] = list()
	data["chapters"]["traits"]["other"] = list()
	for(var/datum/plant_trait/trait as anything in SSbotany.chapters["traits"])
		data["chapters"]["traits"][istype(trait, /datum/plant_trait/reagent) ? "reagents" : "other"] += list("[ref(trait)]" = trait.get_ui_stats())
	//Plants
	for(var/obj/item/plant_seeds/preset as anything in SSbotany.chapters["plants"])
		var/list/plant_data = list()
		for(var/datum/plant_feature/feature as anything in preset.plant_features)
			var/list/feature_list = list()
			feature_list["data"] = feature.get_ui_data()
			feature_list["traits"] = feature.get_ui_traits()
			feature_list["stats"] = feature.get_ui_stats()
			plant_data += list(feature_list)
		data["chapters"]["plants"] += list("[ref(preset)]" = list("name" = capitalize(preset.name_override), "features" = plant_data))
	//Dictionary links
	data["links"] = SSbotany.dictionary_links
	return data

/obj/machinery/computer/plant_machine_controller/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["selected_chapter"] = selected_chapter
	data["selected_entry"] = selected_entry
	data["selected_type_shortcut"] = selected_type_shortcut
	return data

/obj/machinery/computer/plant_machine_controller/ui_act(action, params)
	if(..())
		return
	//playsound(src, get_sfx("keyboard"), 30, TRUE)
	switch(action)
		if("select_entry")
			selected_entry = selected_entry == params["key"] ? null : params["key"]
			//Logic for selectring a feature
			var/datum/plant_feature/feature = locate(params["key"])
			if(istype(feature))
				selected_type_shortcut = "[feature.trait_type_shortcut]"
			last_command = "pit entry select -m [params["key"]]"
			screen.flash()
			ui_update()
		if("select_chapter")
			selected_chapter = params["key"]
			selected_entry = null
			last_command = "pit chapter select -m [params["key"]]"
			screen.flash()
			ui_update()
		if("select_link")
			selected_entry = params["key"]
			//Logic for selectring a feature
			var/datum/plant_feature/feature = locate(params["key"])
			if(istype(feature))
				selected_type_shortcut = "[feature.trait_type_shortcut]"
			//Chapter
			selected_chapter = params["chapter"]
			last_command = "pit seek select -m [params["key"]]"
			screen.flash()
			ui_update()

/obj/machinery/computer/plant_machine_controller/ratvar_act()
	if(!clockwork)
		clockwork = TRUE

/obj/machinery/computer/plant_machine_controller/update_overlays()
	. = ..()
	icon_state = "pc"

/obj/machinery/computer/plant_machine_controller/proc/locate_machines()
	//Reset our machines
	for(var/obj/machinery/plant_machine/machine as anything in machines)
		machine.controller = null
	machines = list()
	//Link machines
	for(var/obj/machinery/machine in range(PC_LINK_RANGE, src))
		if(machine_options["[machine]"])
			continue
		if(!istype(machine, /obj/machinery/plant_machine))
			continue
		var/obj/machinery/plant_machine/plant_machine = machine
		if(plant_machine.controller) //Don't steal someone's baby
			continue
		plant_machine.controller = src
		machines |= machine
		RegisterSignal(plant_machine, COMSIG_QDELETING, PROC_REF(catch_qdel))
		RegisterSignal(plant_machine, COMSIG_MOVABLE_MOVED, PROC_REF(catch_move))
	assemble_menu()

/obj/machinery/computer/plant_machine_controller/proc/assemble_menu()

	for(var/obj/machinery/machine as anything in machines)
		var/image/image = new()
		image.appearance = machine.appearance
		machine_options["[machine]"] = image
		option_links["[machine]"] = machine
	//Add ourself
	var/image/image = image(icon, null, "plant")
	machine_options["[src]"] = image
	option_links["[src]"] = src

/obj/machinery/computer/plant_machine_controller/proc/catch_qdel(datum/source)
	SIGNAL_HANDLER

	machines -= source

/obj/machinery/computer/plant_machine_controller/proc/catch_move(datum/source, atom/newloc, dir)
	SIGNAL_HANDLER

	if(get_dist(src, source) > PC_LINK_RANGE)
		machines -= source

//Circuitboard
/obj/item/circuitboard/computer/plant_machine_controller
	name = "hydroponics machine terminal (Computer Board)"
	icon_state = "service"
	build_path = /obj/machinery/computer/plant_machine_controller

/datum/design/board/plant_machine_controller
	name = "Computer Design (Hydroponics Machine Terminal)"
	desc = "The circuit board for a hydroponics machine terminal, used to control Yamato machines in hydroponics."
	id = "plant_machine_controller_console"
	build_path = /obj/item/circuitboard/computer/plant_machine_controller
	category = list ("Hydroponics Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE


#undef PC_LINK_RANGE
