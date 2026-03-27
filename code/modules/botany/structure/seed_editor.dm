/obj/machinery/plant_machine/seed_editor
	name = "seed sequencer"
	desc = "An advanced device designed to manipulate seed genetic makeup."
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "editor_open"
	density = TRUE
	pass_flags = PASSTABLE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	circuit = /obj/item/circuitboard/machine/seed_editor

	///Inserted seeds we're editing
	var/obj/item/plant_seeds/seeds

	///Currently selected feature
	var/datum/plant_feature/current_feature
	var/current_feature_ref

	///Inserted disk we're reading data from
	var/obj/item/disk/plant_disk/disk

	///Last 'command' for UI stuff
	var/last_command = ""

/obj/machinery/plant_machine/seed_editor/examine(mob/user)
	. = ..()
	. += span_notice("[src] can be used to edit seed genetics.")
	. += span_warning("[src] is not capable of saving genes.")

/obj/machinery/plant_machine/seed_editor/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	playsound(src, 'sound/effects/glassknock.ogg', 15, TRUE)
	to_chat(user, span_danger("[src] can be controlled with a hydroponics mechine terminal."))

/obj/machinery/plant_machine/seed_editor/add_context_self(datum/screentip_context/context, mob/user)
	if(!isliving(user))
		return
	if(disk || seeds)
		context.add_right_click_action("Remove Seed / Plant Disk")
	else
		context.add_left_click_action("Insert Seed / Plant Disk")

/obj/machinery/plant_machine/seed_editor/attackby(obj/item/C, mob/user)
	//insert disk
	if(istype(C, /obj/item/disk/plant_disk) && !disk)
		C.forceMove(src)
		disk = C
	//insert seeds
	else if(istype(C, /obj/item/plant_seeds) && !seeds)
		C.forceMove(src)
		seeds = C
		icon_state = "editor"
		playsound(src, 'sound/machines/click.ogg', 30)
	else
		return ..()
	ui_update()

/obj/machinery/plant_machine/seed_editor/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
//Remove Seeds
	if(seeds)
		seeds.forceMove(get_turf(src))
		user.put_in_active_hand(seeds)
		seeds = null
		icon_state = "editor_open"
//Remove disk
	if(disk)
		disk.forceMove(get_turf(src))
		user.put_in_active_hand(disk)
		disk = null
	ui_update()

/obj/machinery/plant_machine/seed_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SeedEditor")
		ui.open()

/obj/machinery/plant_machine/seed_editor/ui_data(mob/user)
	var/list/data = list()
	//last command, cosmetic
	data["last_command"] = last_command
	//generic stats
	data["seeds_feature_data"] = list()
	if(seeds)
		for(var/datum/plant_feature/feature as anything in seeds.plant_features)
			data["seeds_feature_data"] += list(feature.get_ui_stats())
	//current feature
	data["current_feature"] = current_feature_ref
	data["current_feature_data"] = current_feature?.get_ui_data()
	data["current_feature_traits"] = current_feature?.get_ui_traits()
	data["current_feature_genetic_budget"] = current_feature?.genetic_budget
	data["current_feature_remaining_genetic_budget"] = current_feature?.remaining_genetic_budget
	//Current inserted plant's name
	data["inserted_plant"] = capitalize(seeds?.name)
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

/obj/machinery/plant_machine/seed_editor/ui_act(action, params)
	if(..())
		return
	playsound(src, get_sfx("keyboard"), 30, TRUE)
	switch(action)
		if("select_feature")
			current_feature_ref = current_feature_ref == params["key"] ? null : params["key"]
			current_feature = locate(current_feature_ref)
			last_command = "pit feature select -m [params["key"]]"
			return TRUE
		if("remove_feature")
			var/datum/plant_feature/feature = locate(params["key"])
			if(!feature.can_remove)
				return
			//If it's a disk feature
			if(feature == disk?.saved)
				disk?.set_saved(null)
			//Fix focus
			if(feature == current_feature)
				current_feature_ref = null
				current_feature = null
			seeds.plant_features -= feature
			qdel(feature)
			//We can safely set this to null, so it makes a new ID when planted.
			seeds.update_species_id()
			seeds.update_plant_name()
			last_command = "pit feature remove -f -m [params["key"]]"
			return TRUE
		if("remove_trait")
			var/datum/plant_trait/trait = locate(params["key"])
			if(!trait.can_remove)
				return
			//If it's a disk trait
			if(trait == disk?.saved)
				disk?.set_saved(null)
			else //otherwise just carry on and null our species ID while we're at it, to gen a new one
				seeds.update_species_id()
				seeds.update_plant_name()
			if(current_feature)
				current_feature.plant_traits -= trait
			qdel(trait)
			last_command = "pit trait remove -f -m [params["key"]]"
			return TRUE
		if("add_trait")
			if(!current_feature)
				return
			//Don't allow trait duplication
			var/datum/plant_trait/trait = locate(params["key"])
			for(var/datum/plant_trait/local_trait as anything in current_feature.plant_traits)
				if(!local_trait.allow_multiple && local_trait.get_id() == trait.get_id())
					playsound(controller, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition cannot support multiple of selected trait!")
					return
			//Add the trait
			var/datum/plant_trait/new_trait = trait.copy(current_feature)
			if(!QDELING(new_trait))
				current_feature.plant_traits += new_trait
			else
				playsound(controller, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Seed composition not compatible with selected trait!")
				return
			//Reset the species ID
			seeds.update_species_id()
			seeds.update_plant_name()
			last_command = "pit trait add -f -cd [params["key"]]"
			return TRUE
		if("add_feature")
			var/datum/plant_feature/feature = locate(params["key"])
		//Generic compatibility checking
			for(var/datum/plant_feature/current_feature as anything in seeds.plant_features)
				//Does this plant already have this kind of feature>
				if(current_feature.feature_catagories & feature.feature_catagories) //If you want to have multiple features of the same type on one plant, this is one of the things stopping you
					playsound(controller, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition cannot fit selected feature!")
					return
				//Is this feature blacklisted from another feature
				if(is_type_in_typecache(feature, current_feature.blacklist_features) || is_type_in_typecache(current_feature, feature.blacklist_features))
					playsound(controller, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition not compatible with selected feature!")
					return
				//If a feature has a whitelist, are we in it?
				if(length(current_feature.whitelist_features) && !is_type_in_typecache(feature, current_feature.whitelist_features) || length(feature.whitelist_features) && !is_type_in_typecache(current_feature, feature.whitelist_features))
					playsound(controller, 'sound/machines/terminal_error.ogg', 60)
					say("ERROR: Seed composition not compatible with selected feature!")
					return
		//Special compatibility checking
			//If it's a fruit- check if it fits on the body - This will be the other thing you'll have to potentially rewrite if you allow duplicate features
			var/datum/plant_feature/fruit/fruit_feature = feature
			var/datum/plant_feature/body/body_feature = locate(/datum/plant_feature/body) in seeds.plant_features //Might create overhead if they spam it and we later add 5 million unique features
			//These are arranged to be a little more readable, dont sweat efficiency
			if(istype(fruit_feature) && !body_feature)
				playsound(controller, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Seed composition does not contain a supporting body for this feature!")
				return
			if((istype(fruit_feature) && body_feature) && fruit_feature.fruit_size > body_feature.upper_fruit_size)
				playsound(controller, 'sound/machines/terminal_error.ogg', 60)
				say("ERROR: Seed composition's body feature doesn't support this feature!")
				return
		//Good to go, slap that bad boy on
			var/datum/plant_feature/new_feature = feature.copy()
			new_feature.associate_seeds(seeds)
			seeds.plant_features += new_feature
			seeds.update_species_id()
			seeds.update_plant_name()
			last_command = "pit feature add -f -cd [params["key"]]"
			return TRUE
		if("remove_disk")
			//Fix focus
			if(disk.saved == current_feature)
				current_feature_ref = null
				current_feature = null
			//Spit disk out
			disk.forceMove(get_turf(src))
			disk = null
			last_command = "per reader eject -f"
			return TRUE

//Circuitboard
/obj/item/circuitboard/machine/seed_editor
	name = "seed editor (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/plant_machine/seed_editor
	req_components = list(/obj/item/stock_parts/matter_bin = 2, /obj/item/stock_parts/manipulator = 2, /obj/item/stock_parts/capacitor = 1, /obj/item/stock_parts/scanning_module = 1)

/datum/design/board/seed_editor
	name = "Seed Editor Board"
	id = "seed_editor_board"
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE
	build_path = /obj/item/circuitboard/machine/seed_editor
	category = list ("initial", "Misc. Machinery")
