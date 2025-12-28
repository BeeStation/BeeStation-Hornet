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
	///Upper amount of seeds we can make
	var/seed_amount = 3
	///Our stored seeds index'd by species id
	var/list/stored_seeds = list()
	///Seed amount, also index'd by species id - We do this to avoid having a billion instances of the same seed stored away
	var/list/stored_seeds_amount = list()
	///UI logic, what seed are we looking at
	var/focused_seeds

/obj/machinery/seeder/attackby(obj/item/C, mob/user)
	var/obj/item/food/grown/fruit = C
	if(!istype(C, /obj/item/plant_seeds) && !istype(fruit))
		return ..()
//Store seeds
	if(istype(C, /obj/item/plant_seeds))
		var/obj/item/plant_seeds/seeds = C
		if(!stored_seeds_amount["[seeds.species_id]"])
			stored_seeds_amount["[seeds.species_id]"] = 0
		stored_seeds_amount["[seeds.species_id]"] += 1
		if(stored_seeds["[seeds.species_id]"])
			qdel(seeds)
			return
		stored_seeds["[seeds.species_id]"] = seeds
		seeds.forceMove(src)
		return
//Turn fruit into seeds
	C.forceMove(get_turf(src))
	seedify(C, seed_amount)
	to_chat(user, "<span class='notice'>[seed_amount] seeds created!</span>")

/obj/machinery/seeder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SeedStorage")
		ui.open()

/obj/machinery/seeder/ui_data(mob/user)
	var/list/data = list()
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
			ui_update()

///proc used to transform produce into seeds
/proc/seedify(obj/produce, _seed_amount)
	//General genes
	var/list/genes = list()
	SEND_SIGNAL(produce, COMSIG_PLANT_GET_GENES, genes)
	if(!length(genes))
		return
	//Features
	var/list/features = genes[PLANT_GENE_INDEX_FEATURES]
	//species ID
	var/species_id = genes[PLANT_GENE_INDEX_ID]
	//Impart onto seeds
	if(!length(features))
		return
	var/obj/item/food/grown/food_item = produce //type cast shortcut
	food_item = istype(food_item) ? food_item : null
	for(var/index in 1 to _seed_amount)
		var/obj/item/plant_seeds/seeds = food_item?.seed_base || /obj/item/plant_seeds //If the grown item in question is a real food item, we get to use the seed_base feature, and fuck porting it to regular items
		seeds = new seeds(produce.loc, features, species_id)
	qdel(produce)
