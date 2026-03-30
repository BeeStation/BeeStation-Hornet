/obj/machinery/plant_machine/plant_analyser
	name = "plant analyzer"
	desc = "An advanced device designed to analyse plant genetic makeup."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "analyzer_open"
	density = TRUE
	pass_flags = PASSTABLE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	circuit = /obj/item/circuitboard/machine/plant_analyser

	///Plant we're curently editing
	var/obj/inserted_plant
	///Shortcut to component
	var/datum/component/plant/plant_component
	///Currently selected feature
	var/datum/plant_feature/current_feature
	var/current_feature_ref

	///Inserted disk we're saving data too
	var/obj/item/disk/plant_disk/disk
	///Are we in the process of saving a feature
	var/saving_feature = FALSE
	///What traits are we not saving with the plant feature, if we are saving a plant feature
	var/list/save_excluded_traits = list()
	var/list/save_excluded_traits_ref = list()

	///Last 'command' for UI stuff
	var/last_command = ""

	///Refernece to our screen effect
	var/obj/effect/hydroponics_screen/screen

/obj/machinery/plant_machine/plant_analyser/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PLANTER_PAUSE_PLANT, PROC_REF(catch_pause))
	screen = new(src, "analyzer_on")
	// OOOOH YEAAAAAH I REMEMBER! REMEMBER WHEN? YEAAAAAAAH
	if(prob(1))
		icon = 'icons/obj/hydroponics/equipment.dmi'
		icon_state = "dnamod"

/obj/machinery/plant_machine/plant_analyser/examine(mob/user)
	. = ..()
	. += span_notice("[src] can be used to read and save plant genetics.")
	. += span_warning("[src] is not capable of editing genes.")

/obj/machinery/plant_machine/plant_analyser/proc/catch_pause(datum/source)
	SIGNAL_HANDLER

	return TRUE

/obj/machinery/plant_machine/plant_analyser/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	to_chat(user, span_danger("[src] can be controlled with a hydroponics machine terminal.\nA plant can be inserted into [src] using a spade."))

/obj/machinery/plant_machine/plant_analyser/add_context_self(datum/screentip_context/context, mob/user)
	if(!isliving(user))
		return
	if(disk)
		context.add_right_click_action("Remove Plant Disk")
	else
		context.add_left_click_action("Insert Plant Disk")

/obj/machinery/plant_machine/plant_analyser/attackby(obj/item/C, mob/user)
//Disk
	if(istype(C, /obj/item/disk/plant_disk) && !disk)
		C.forceMove(src)
		disk = C
		ui_update()
		return
//Spade / Plant
	if(!istype(C, /obj/item/shovel/spade))
		return ..()
	//Return plant to spade, to remove it
	if(inserted_plant && !length(C.contents) && plant_component.async_catch_attackby(C, user))
		inserted_plant = null
		plant_component = null
		current_feature = null
		current_feature_ref = null
		icon_state = "analyzer_open"
		ui_update()
		return
	//Insert plant from spade
	if(inserted_plant)
		to_chat(user, span_warning("There's already a plant inside [src]!"))
		return
	var/datum/component/plant/plant
	var/obj/item/plant_item
	for(var/obj/item/potential_plant in C.contents)
		plant = potential_plant.GetComponent(/datum/component/plant)
		plant_item = potential_plant
		if(!plant)
			continue
		break
	if(!plant)
		return ..()
	//Don't let immature plants through
	var/datum/plant_feature/body/body_feature = locate(/datum/plant_feature/body) in plant.plant_features
	if(body_feature?.current_stage < body_feature?.growth_stages)
		playsound(controller, 'sound/machines/terminal_error.ogg', 60)
		say("ERROR: Plant specimen is not fully mature!")
		return
	to_chat(user, span_notice("You begin inserting [plant_item] into [src]."))
	if(!do_after(user, 2.5 SECONDS, src))
		return
	if(!(locate(plant_item) in C.contents))
		return
	C.vis_contents -= plant_item
	plant_item.forceMove(src)
	inserted_plant = plant_item
	plant_component = plant
	icon_state = "analyzer"
	playsound(src, 'sound/machines/click.ogg', 30)
	ui_update()

/obj/machinery/plant_machine/plant_analyser/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	//Remove disk
	if(!disk)
		return
	disk.forceMove(get_turf(src))
	user.put_in_active_hand(disk)
	disk = null

/obj/machinery/plant_machine/plant_analyser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlantEditor")
		ui.open()

/obj/machinery/plant_machine/plant_analyser/ui_data(mob/user)
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
	data["current_feature_data"] += list(PLANT_DATA("Trait Modifier", current_feature?.trait_power), PLANT_DATA(null, null)) //Some special information unqiue to this interface & scanners
	data["current_feature_traits"] = current_feature?.get_ui_traits()
	//Current inserted plant's name
	data["inserted_plant"] = capitalize(inserted_plant?.name)
	///Are we saving a feature
	data["saving_feature"] = saving_feature
	///Which traits are we not including in the save
	data["save_excluded_traits"] = save_excluded_traits_ref
	///Is there a disk inserted
	data["disk_inserted"] = disk
	data["disk_feature_data"] = null
	data["disk_trait_data"] = null
	if(istype(disk?.saved, /datum/plant_feature))
		var/datum/plant_feature/feature = disk.saved
		data["disk_feature_data"] += feature.get_ui_stats()
	else if(istype(disk?.saved, /datum/plant_trait))
		var/datum/plant_trait/trait = disk?.saved
		data["disk_trait_data"] += trait.get_ui_stats()[1]

	return data

/obj/machinery/plant_machine/plant_analyser/ui_act(action, params)
	if(..())
		return
	playsound(controller, get_sfx("keyboard"), 30, TRUE)
	switch(action)
		if("select_feature")
			current_feature_ref = current_feature_ref == params["key"] ? null : params["key"]
			current_feature = locate(current_feature_ref)
			last_command = "pit feature select -m [params["key"]]"
			screen.flash()
			ui_update()
		if("save_trait")
			if(!disk)
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: No disk inserted!")
				return
			if(disk.saved)
				qdel(disk.saved)
			var/datum/plant_trait/trait = locate(params["key"])
			if(!trait.can_copy)
				return
			disk.set_saved(trait.copy())
			last_command = "per reader write -f -m [params["key"]]"
			screen.flash()
			ui_update()
		if("save_feature")
			//Disk flight checks
			if(!disk)
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: No disk inserted!")
				return
			if(disk.saved)
				qdel(disk.saved)
			//Feature flight checks
			var/datum/plant_feature/feature = locate(params["key"])
			if(!feature.can_copy)
				playsound(src, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Feature composition too complex to copy!")
				saving_feature = FALSE
				screen.flash()
				ui_update()
				return
			//Fix focus
			if(current_feature_ref != params["key"])
				current_feature_ref = params["key"]
				current_feature = locate(current_feature_ref)
				screen.flash()
				ui_update()
			//If this plant doesn't have any traits, save it straight to disk - force flag means we're done drafting and want to properly save
			if(!length(current_feature.plant_traits) || params["force"])
				feature = feature.copy()
				//Snip out traits we don't want copied
				for(var/datum/plant_trait/trait as anything in feature.plant_traits)
					if(!(trait.type in save_excluded_traits))
						continue
					feature.plant_traits -= trait
					qdel(trait)
				//finished :)
				disk.set_saved(feature)
				saving_feature = FALSE
				last_command = "per reader write -f -m [params["key"]]"
				screen.flash()
				ui_update()
				return
			//Otherwise, enable drafting phase
			saving_feature = !isnull(current_feature?.get_ui_traits())
			last_command = "pit draft start -k -m [params["key"]]"
			ui_update()
		if("toggle_trait")
			var/datum/plant_trait/trait = locate(params["key"])
			if(!trait.can_remove)
				return
			if(params["key"] in save_excluded_traits_ref)
				save_excluded_traits_ref -= params["key"]
				save_excluded_traits -= trait.type
			else
				save_excluded_traits_ref += params["key"]
				save_excluded_traits += trait.type
			last_command = "pit trait toggle -l -m [params["key"]]"
			screen.flash()
			ui_update()
		if("remove_feature") //For disk
			var/datum/plant_feature/feature = locate(params["key"])
			disk?.set_saved(null)
			//Fix focus
			if(feature == current_feature)
				current_feature_ref = null
				current_feature = null
			qdel(feature)
			last_command = "pit feature remove -f -m [params["key"]]"
			screen.flash()
			ui_update()
		if("remove_trait") //For disk
			var/datum/plant_trait/trait = locate(params["key"])
			disk?.set_saved(null)
			qdel(trait)
			last_command = "pit trait remove -f -m [params["key"]]"
			screen.flash()
			ui_update()
		if("remove_disk")
			//Fix focus
			if(disk.saved == current_feature)
				current_feature_ref = null
				current_feature = null
			//Spit disk out
			disk.forceMove(get_turf(src))
			disk = null
			last_command = "per reader eject -f"
			screen.flash()
			ui_update()

	return TRUE

//Circuitboard
/obj/item/circuitboard/machine/plant_analyser
	name = "plant analyser (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/plant_machine/plant_analyser
	req_components = list(/obj/item/stock_parts/matter_bin = 2, /obj/item/stock_parts/scanning_module = 1)

/datum/design/board/plant_analyser
	name = "Plant Analyser Board"
	id = "plant_analyser_board"
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE
	build_path = /obj/item/circuitboard/machine/plant_analyser
	category = list ("initial", "Misc. Machinery")
