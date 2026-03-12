/*
	Used to make and store seeds
		Semi important that this isn't a plant machine subtype
*/
/obj/machinery/seeder
	name = "industrial seeder"
	desc = "A large set of jaws set in a compact frame.\n<span class='notice'>Turns 'fruit' into seed</span>"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "seeder"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/seeder
	///Upper amount of seeds we can make
	var/seed_amount = 3
	///Our stored seeds index'd by species id
	var/list/stored_seeds = list()
	///Seed amount, also index'd by species id - We do this to avoid having a billion instances of the same seed stored away
	var/list/stored_seeds_amount = list()
	///UI logic, what seed are we looking at
	var/focused_seeds
	///Refernece to our screen effect
	var/obj/effect/hydroponics_screen/screen
	///Last 'command' for UI stuff
	var/last_command = ""

/obj/machinery/seeder/Initialize(mapload)
	. = ..()
	screen = new(src, "seeder_on")

/obj/machinery/seeder/RefreshParts()
	. = ..()
	seed_amount = initial(seed_amount)
	var/total_rating = 0
	for(var/obj/item/stock_parts/S in component_parts)
		total_rating += S.rating
	if(total_rating >= 8)
		seed_amount = initial(seed_amount) * 2

/obj/machinery/seeder/attackby(obj/item/C, mob/user)
	var/obj/item/food/grown/fruit = C
//Turn spade plant into seeds
	if(istype(C, /obj/item/shovel/spade))
		//Insert plant from spade
		var/datum/component/plant/plant
		var/obj/item/plant_item
		for(var/obj/item/potential_plant in C.contents)
			plant = potential_plant.GetComponent(/datum/component/plant)
			plant_item = potential_plant
			if(!C)
				continue
			break
		if(!plant)
			return ..()
		//Don't let immature plants through
		var/new_seed_amount = seed_amount
		var/datum/plant_feature/body/body_feature = locate(/datum/plant_feature/body) in plant.plant_features
		if(body_feature?.current_stage < body_feature?.growth_stages)
			new_seed_amount = seed_amount / initial(seed_amount)
		C.vis_contents -= plant_item
		plant_item.forceMove(get_turf(src))
		seedify(plant_item, new_seed_amount)
		playsound(src, 'sound/machines/juicer.ogg', 30)
		to_chat(user, "<span class='notice'>[new_seed_amount] seeds created!</span>")
		shake()
//Store seeds
	if(istype(C, /obj/item/plant_seeds))
		store_seed(C)
		ui_update()
		return
//Plant bag
	if(istype(C, /obj/item/storage/bag/plants))
		for(var/obj/item/plant_seeds/seed in C.contents)
			store_seed(seed)
		ui_update()
		return
//Turn fruit into seeds
	if(istype(fruit))
		C.forceMove(get_turf(src))
		seedify(C, seed_amount)
		playsound(src, 'sound/machines/juicer.ogg', 30)
		to_chat(user, "<span class='notice'>[seed_amount] seeds created!</span>")
		shake()

/obj/machinery/seeder/proc/store_seed(obj/item/plant_seeds/seeds)
	if(!stored_seeds_amount["[seeds.species_id]"])
		stored_seeds_amount["[seeds.species_id]"] = 0
	stored_seeds_amount["[seeds.species_id]"] += 1
	if(stored_seeds["[seeds.species_id]"])
		qdel(seeds)
		return
	stored_seeds["[seeds.species_id]"] = seeds
	seeds.forceMove(src)

/obj/machinery/seeder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SeedStorage")
		ui.open()

/obj/machinery/seeder/ui_data(mob/user)
	var/list/data = list()
	//last command, cosmetic
	data["last_command"] = last_command
	//General seed data
	data["seeds"] = list()
	for(var/species_id as anything in stored_seeds)
		if(stored_seeds_amount[species_id] <= 0)
			continue
		var/obj/item/plant_seeds/seeds = stored_seeds[species_id]
		var/list/features = list()
		for(var/datum/plant_feature/feature as anything in seeds.plant_features)
			features["[ref(feature)]"] = list()
			features["[ref(feature)]"]["data"] = feature.get_ui_data()
			features["[ref(feature)]"]["traits"] = feature.get_ui_traits()
			features["[ref(feature)]"]["stats"] = feature.get_ui_stats()
		data["seeds"]["[seeds.species_id]"] = list("name" = seeds.name_override || seeds.name, "species_name" = get_species_name(seeds.plant_features), "count" = stored_seeds_amount[species_id],
		"seeds" = seeds.seeds, "features" = features, "species_id" = seeds.species_id, "ref" = "[ref(seeds)]")
	//Special boy who tells us who the star is
	data["focused_seeds"] = list()
	if(focused_seeds)
		var/obj/item/plant_seeds/seeds = locate(focused_seeds)
		data["focused_seeds"] = list("key" = focused_seeds, "species_id" = seeds.species_id)
	return data

/obj/machinery/seeder/ui_act(action, params)
	if(..())
		return
	playsound(src, get_sfx("keyboard"), 30, TRUE)
	switch(action)
		if("select_entry")
			focused_seeds = params["key"]
			last_command = "pit seed select -m [params["key"]]"
			screen.flash()
			ui_update()
		if("dispense")
			var/species_id = params["key"]
			if(stored_seeds_amount[species_id] <= 0) //This shouldn't be possible, but laggier UIs might make it so
				return
			var/obj/item/plant_seeds/seeds = stored_seeds[species_id]
			seeds = seeds.copy()
			stored_seeds_amount[species_id] -= 1
			seeds.forceMove(get_turf(src))
			if(stored_seeds_amount[species_id] <= 0 && focused_seeds == ref(seeds))
				focused_seeds = null
			last_command = "per dispenser eject -m [seeds.name] -f"
			screen.flash()
			ui_update()

/obj/machinery/seeder/proc/shake(shakes = 5)
	animate(src, pixel_x = 0, pixel_y = 0, time = 0 SECONDS, loop = shakes)
	for(var/index in 1 to 10)
		animate(pixel_x = rand(-1, 1), pixel_y = rand(-1, 1), time = 0.05 SECONDS)
	animate(pixel_x = 0, pixel_y = 0, time = 0.05 SECONDS)


/obj/item/circuitboard/machine/seeder
	name = "industrial seeder (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/seeder
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/datum/design/board/seeder
	name = "Industrial Seeder"
	desc = "This machine turns fruits & plants into seeds."
	id = "seeder"
	build_path = /obj/item/circuitboard/machine/seeder
	category = list ("initial", "Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE

///proc used to transform produce into seeds
/proc/seedify(obj/produce, _seed_amount)
	var/datum/component/plant/plant_component = produce.GetComponent(/datum/component/plant)
	var/species_id
	var/list/features
//Food items
	if(!plant_component)
		//General genes
		var/list/genes = list()
		SEND_SIGNAL(produce, COMSIG_PLANT_GET_GENES, genes)
		if(!length(genes))
			return
		//Features
		features = genes[PLANT_GENE_INDEX_FEATURES]
		//species ID
		species_id = genes[PLANT_GENE_INDEX_ID]
	else
		features = plant_component.plant_features
		species_id = plant_component.species_id
//Plants
	//Impart onto seeds
	if(!length(features))
		return
	var/obj/item/food/grown/food_item = produce //type cast shortcut
	food_item = istype(food_item) ? food_item : null
	for(var/index in 1 to _seed_amount)
		var/obj/item/plant_seeds/seeds = food_item?.seed_base || /obj/item/plant_seeds //If the grown item in question is a real food item, we get to use the seed_base feature, and fuck porting it to regular items
		seeds = new seeds(produce.loc, features, species_id)
	qdel(produce)


