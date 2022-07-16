

/obj/machinery/plantgenes
	name = "plant DNA manipulator"
	desc = "An advanced device designed to manipulate plant genetic makeup."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "dnamod"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/plantgenes
	pass_flags = PASSTABLE

	var/obj/item/seeds/seed
	var/newseed // Used to store a new seed from mutation
	var/datum/plant_gene/newgene
	var/reagent_id
	var/reag_unit_max

	var/list/core_genes = list()
	var/list/core_genes_sub = list()
	var/list/reagent_genes = list()
	var/list/trait_genes = list()
	var/family_gene
	var/list/mutate_list = list()

	var/datum/plant_gene/target
	var/operation = null



	var/max_potency = 50 // See RefreshParts() for how these work
	var/max_yield = 2
	var/min_production = 12
	var/max_endurance = 10 // IMPT: ALSO AFFECTS LIFESPAN
	var/min_wchance = 67
	var/min_wrate = 10



	var/unit_guage = 0.1
	var/stat_used = 0
	var/bonus_stat = 0

	var/tgui_view_state = "basic"
	var/skip_confirmation = FALSE
	var/reag_target_value = 0
	var/research_valid = TRUE
	var/action_strong_confirmation = FALSE

	var/datum/techweb/stored_research
	var/research_faction_type



/obj/machinery/plantgenes/Initialize(mapload)
	. = ..()
	if(!stored_research)
		stored_research = SSresearch.science_tech
	research_faction_type = BOTANY_RESEARCHED_NANOTRASEN

/obj/machinery/plantgenes/Destroy()
	. = ..()

	core_genes = null
	core_genes_sub = null
	reagent_genes = null
	trait_genes = null
	mutate_list = null


/obj/machinery/plantgenes/RefreshParts() // Comments represent the max you can set per tier, respectively. seeds.dm [219] clamps these for us but we don't want to mislead the viewer.
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		if(M.rating > 3)
			max_potency = 95
		else
			max_potency = initial(max_potency) + (M.rating**3) // 53,59,77,95 	 Clamps at 100

		max_yield = initial(max_yield) + (M.rating*2) // 4,6,8,10 	Clamps at 10

	for(var/obj/item/stock_parts/scanning_module/SM in component_parts)
		if(SM.rating > 3) //If you create t5 parts I'm a step ahead mwahahaha!
			min_production = 1
		else
			min_production = 12 - (SM.rating * 3) //9,6,3,1. Requires if to avoid going below clamp [1]

		max_endurance = initial(max_endurance) + (SM.rating * 25) // 35,60,85,100	Clamps at 10min 100max

	for(var/obj/item/stock_parts/micro_laser/ML in component_parts)
		var/wratemod = ML.rating * 2.5
		min_wrate = FLOOR(10-wratemod,1) // 7,5,2,0	Clamps at 0 and 10	You want this low
		min_wchance = 67-(ML.rating*16) // 48,35,19,3 	Clamps at 0 and 67	You want this low
	for(var/obj/item/circuitboard/machine/plantgenes/vaultcheck in component_parts)
		if(istype(vaultcheck, /obj/item/circuitboard/machine/plantgenes/vault)) // TRAIT_DUMB BOTANY TUTS
			max_potency = 100
			max_yield = 10
			min_production = 1
			max_endurance = 100
			min_wchance = 0
			min_wrate = 0
	ui_update()

/obj/machinery/plantgenes/update_icon()
	..()
	cut_overlays()
	if((stat & (BROKEN|NOPOWER)))
		icon_state = "dnamod-off"
	else
		icon_state = "dnamod"
	if(seed)
		add_overlay("dnamod-dna")
	if(panel_open)
		add_overlay("dnamod-open")

/obj/machinery/plantgenes/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "dnamod", "dnamod", I))
		update_icon()
		return
	if(default_deconstruction_crowbar(I))
		return
	if(iscyborg(user))
		return

	if(istype(I, /obj/item/seeds))
		if (operation)
			to_chat(user, "<span class='notice'>Please complete current operation.</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		eject_seed()
		insert_seed(I)
		to_chat(user, "<span class='notice'>You add [I] to the machine.</span>")
		interact(user)
	else
		..()

/obj/machinery/plantgenes/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PlantDNAManipulator")
		ui.open()

/obj/machinery/plantgenes/ui_data(mob/user)
	var/list/data = list()
	. = data

	data["selectedWindow"] = tgui_view_state

	data["seed"] = seed?.name
	data["plant_name"] = seed?.plantname
	data["plant_desc"] = seed?.plantdesc
	data["seed_desc"] = seed?.desc

	data["operation"] = operation
	data["operation_target"] = build_gene(target)

	data["core_genes"] = build_gene_list(core_genes, /datum/plant_gene/core)
	data["core_genes_sub"] = build_gene_list(core_genes_sub, /datum/plant_gene/core)
	data["reagent_genes"] = build_gene_list(reagent_genes, /datum/plant_gene/reagent)
	data["trait_genes"] = build_gene_list(trait_genes, /datum/plant_gene/trait)
	data["family_gene"] = build_gene(family_gene, /datum/plant_gene/family)

	data["mutate_list"] = build_mutate_list(mutate_list)

	// data["machine_stats"] = build_machine_stats() // not used in Alpha
	data["skip_confirmation"] = skip_confirmation

	data["research_datas"] = build_gene_data_list()
	data["researched_plants"] = build_plant_data_list()
	data["research_faction_type"] = research_faction_type
	data["research_valid"] = research_valid
	data["unit_guage"] = unit_guage


/obj/machinery/plantgenes/proc/build_gene_data_list()
	var/static/history = 0
	var/static/list/static_list
	if(isnull(static_list))
		static_list = list()
	. = static_list

	if(length(stored_research.researched_genes) > history)
		history = length(stored_research.researched_genes)
		var/list/L = list()
		for(var/D in stored_research.researched_genes)
			L += list(build_gene_data(D, stored_research.researched_genes[D]))
		QDEL_LIST(static_list)
		static_list = L
		. = L

		//It should be better to be here because of saving resource
		//It calculates the bonus stat for gene mod based on the amount of researched plants
		var/count = 0
		for(var/plant in L)
			count += (L["faction"] & research_faction_type) ? 1 : 0
		bonus_stat = count
		// every 15 plants researched, you get 1 point.

/obj/machinery/plantgenes/proc/build_gene_data(var/list/DI, var/D)
	if(!D)
		return

	var/list/L = list()
	. = L

	L["id"] = DI //I don't know how to get a key only from `var/D`.
	L["name"] = initial(D["path"].name)
	L["faction"] = D["faction"]
	L["category"] = D["category"]
	L["level"] = D["level"]
	L["reqlevel"] = D["reqlevel"] ? D["reqlevel"] : 0

	if(D["category"] == "reagent")
		L["max_reagent"] = D["maxvolume"]
	else
		L["desc"] = D["desc"] ? D["desc"] : FALSE




/obj/machinery/plantgenes/proc/build_plant_data_list()
	var/static/history = 0
	var/static/list/data

	if(isnull(data))
		data = list()
	. = data
	if(length(stored_research.researched_plants) > history)
		var/list/L = list()
		history = length(stored_research.researched_plants)
		for(var/D in stored_research.researched_plants)
			L += list(stored_research.researched_plants["faction"], stored_research.researched_plants["plant_name"])
		data = L
		. = L



/obj/machinery/plantgenes/proc/build_machine_stats()
	var/list/L = list()
	. = L

	L["potency"] = list("max", max_potency)
	L["yield"] = list("max", max_yield)
	// L["bite size"] = list("min", min_production)
	// L["contaiable size"] = list("min", min_production)
	// L["maturation speed"] = list("min", min_production)
	L["production speed"] = list("min", min_production)
	L["endurance"] = list("max", max_endurance)
	L["lifespan"] = list("max", max_endurance)
	L["weed growth rate"] = list("min", min_wrate)
	L["weed vulnerability"] = list("min", min_wchance)
	// L["ferma type"] = list("min", min_production)

/obj/machinery/plantgenes/proc/build_mutate_list(list/mutablelist)
	var/list/L = list()
	. = L

	for(var/S in mutablelist)
		var/obj/item/seeds/each = S
		L += list(build_mutate(each))


/obj/machinery/plantgenes/proc/build_mutate(obj/item/seeds/P)
	if(!P)
		return

	var/list/L = list()
	. = L

	L["plantname"] = initial(P.plantname)
	L["plantpath"] = P


/obj/machinery/plantgenes/proc/build_gene_list(list/genes, filter_type)
	var/list/L = list()
	. = L

	for(var/datum/plant_gene/gene in genes)
		L += list(build_gene(gene, filter_type))

/obj/machinery/plantgenes/proc/get_gene_id(datum/plant_gene/gene)
	if(istype(gene, /datum/plant_gene/core))
		var/datum/plant_gene/core/core_gene = gene
		return "core[core_gene.type]"
	if(istype(gene, /datum/plant_gene/reagent/innate))
		var/datum/plant_gene/reagent/reagent_gene = gene
		return "innatereagent[reagent_gene.reagent_id]"
	if(istype(gene, /datum/plant_gene/reagent/sandbox))
		var/datum/plant_gene/reagent/reagent_gene = gene
		return "reagent[reagent_gene.reagent_id]"
	if(istype(gene, /datum/plant_gene/trait))
		var/datum/plant_gene/trait/trait_gene = gene
		return "trait[trait_gene.type]"

	return "unknown/[gene.name]"

/obj/machinery/plantgenes/proc/build_gene(datum/plant_gene/gene, filter_type)
	if(!gene)
		return

	if(filter_type && !istype(gene, filter_type))
		return

	var/list/L = list()
	. = L

	L["name"] = gene.get_name()

	L["removable"] = gene.plant_gene_flags & PLANT_GENE_COMMON_REMOVABLE
	L["adjustable"] = gene.plant_gene_flags & PLANT_GENE_REAGENT_ADJUSTABLE

	if(istype(gene, /datum/plant_gene/core))
		var/datum/plant_gene/core/core_gene = gene

		L["category"] = "core"
		L["stat"] = core_gene.name
		L["id"] = get_gene_id(gene)
		L["value"] = core_gene.value

	if(istype(gene, /datum/plant_gene/reagent))
		var/datum/plant_gene/reagent/reagent_gene = gene

		L["category"] = "reagent"
		L["id"] = get_gene_id(gene)
		L["reag_unit"] = reagent_gene.reag_unit
		L["reag_unit_max"] = reagent_gene.reag_unit_max

	if(istype(gene, /datum/plant_gene/trait))
		var/datum/plant_gene/trait/trait_gene = gene

		L["category"] = "trait"
		L["id"] = get_gene_id(gene)
		L["trait_id"] = trait_gene.trait_id


	if(istype(gene, /datum/plant_gene/family))
		var/datum/plant_gene/family/famili_gene = gene // There'a a variable family_gene already.
		L["category"] = "family"
		L["family_name"] = famili_gene.fname
		//L["id"] = get_gene_id(famili_gene) // actually not needed
		L["desc"] = famili_gene.desc

/obj/machinery/plantgenes/ui_static_data(mob/user)
	var/list/data = list()

	data["stat_tooltips"] = list(
		potency = "The 'power' of a plant. Generally effects the amount of reagent in a plant.",
		yield = "The amount of crop yielded from a harvest",
		"production speed" = "The speed at which a plant grows. Lower is better.",
		endurance = "The amount of health the plant has",
		lifespan = "The time it takes before the plant starts dying of old age",
		"weed vulnerability" = "The vulnerability of the plant to weeds growing",
		"weed growth rate" = "The speed at which weeds can grow around the plant. The higher the faster they grow.",
		)

	return data

/obj/machinery/plantgenes/proc/find_gene_by_id(var/gene_id)
	for(var/datum/plant_gene/gene in core_genes)
		if(get_gene_id(gene) == gene_id)
			return gene
	for(var/datum/plant_gene/gene in reagent_genes)
		if(get_gene_id(gene) == gene_id)
			return gene
	for(var/datum/plant_gene/gene in trait_genes)
		if(get_gene_id(gene) == gene_id)
			return gene

/obj/machinery/plantgenes/ui_act(action, params)
	if(..())
		return

	if(!research_valid && action != "eject_insert_seed")
		return

	// ------------------ action and operation ------------------
	switch(action)
		if("toggle_skip_confirmation")
			skip_confirmation = !skip_confirmation
			. = TRUE

		if("abort")
			operation = null
			target = null
			action_strong_confirmation = FALSE
			reagent_id = null
			reag_unit_max = null
			newgene = null
			newseed = null
			. = TRUE
			return

		if("eject_insert_seed")
			var/obj/item/I = usr.get_active_held_item()
			if(istype(I, /obj/item/seeds))
				if(!usr.transferItemToLoc(I, src))
					return
				eject_seed()
				insert_seed(I)
				to_chat(usr, "<span class='notice'>You add [I] to the machine.</span>")
				. = TRUE
			else
				. = eject_seed()

		if("remove")
			if(seed)
				var/datum/plant_gene/G = find_gene_by_id(params["gene_id"])
				if(!G)
					return FALSE
				if(!(G.plant_gene_flags & PLANT_GENE_COMMON_REMOVABLE))
					return FALSE
				operation = action
				target = G
				. = TRUE

		if("adjust")
			if(seed)
				var/datum/plant_gene/reagent/G = find_gene_by_id(params["gene_id"])
				if(!G)
					return FALSE
				if(!(G.plant_gene_flags & PLANT_GENE_REAGENT_ADJUSTABLE))
					return FALSE
				reag_unit_max = G.reag_unit > G.reag_unit_max ? G.reag_unit : G.reag_unit_max
				reag_target_value = clamp(params["value"], unit_guage, reag_unit_max) //save value
				if(((reag_target_value*100)%(unit_guage*100))!=0) //server side cheat check
					return FALSE

				//adjust doesn't need confirmation unless it's revertable
				action_strong_confirmation = FALSE
				if(G.reag_unit > G.reag_unit_max)
					action_strong_confirmation = TRUE //in case it's not revertable, then we need to 'confirm' forcefully regardless 'skip' is checked

				operation = action
				target = G
				. = TRUE

		if("mutate")
			if(seed)
				newseed = text2path(params["mutation_path"]) //take a path first
				if(!newseed)
					return FALSE

				var/found = FALSE
				for(var/i in seed.mutatelist) // server side cheat check
					if(ispath(newseed, i))
						found = TRUE
						break
				if(!found) // you sick hacker
					return

				operation = action
				. = TRUE

		if("insert")
			if(seed)
				if(!params["data_id"])
					return
				newgene = stored_research.researched_genes[params["data_id"]]
				if(!newgene)
					return
				if(newgene["level"] < newgene["reqlevel"]) // lack of research level
					return
				if(newgene["faction"] & research_faction_type)
					switch(newgene["category"])
						if("reagent")
							reagent_id = newgene["path"]
							reag_unit_max = newgene["maxvolume"]
							newgene = /datum/plant_gene/reagent/sandbox
						if("trait")
							newgene = newgene["path"]
				operation = action
				. = TRUE

		if("confirm")
			action_strong_confirmation = FALSE
			. = TRUE
			//this is needed to let 'adjust' ignore confirmation but check if it is under a special situation.

		//TGUI control
		if("set_view")
			tgui_view_state = params["selectedWindow"]
			return TRUE

		//Manipulation controls
		if("modify_plant_name")
			change_seed_name_desc(seed, "Plant Name", usr)
			return TRUE

		if("modify_plant_desc")
			change_seed_name_desc(seed, "Plant Description", usr)
			return TRUE

		if("modify_seed_desc")
			change_seed_name_desc(seed, "Seed Description", usr)
			return TRUE

	// ----------------------------------------------------
	// ------------------- operation ----------------------
	if((action == "confirm" || action == "adjust" || (. && skip_confirmation)) && operation && !action_strong_confirmation)
		switch(operation)
			if("remove")
				var/datum/plant_gene/G = target
				if(G)
					if(!istype(G, /datum/plant_gene/core))
						seed.genes -= G
						if(istype(G, /datum/plant_gene/trait))
							G.on_removal(seed)
						if(G.get_plant_gene_flags() & PLANT_GENE_QDEL_TARGET)
							qdel(G)
					repaint_seed()

			if("insert")
				if((ispath(newgene, /datum/plant_gene/trait) || ispath(newgene, /datum/plant_gene/reagent/sandbox)))
					if(ispath(newgene, /datum/plant_gene/reagent/sandbox))
						newgene = new newgene(reagent_id, list(reag_unit_max, reag_unit_max))
					if(ispath(newgene, /datum/plant_gene/trait))
						newgene = seed.get_trait_gene_from_static(newgene)
					if(newgene.can_add(seed))
						seed.genes += newgene
						newgene.on_new_seed(seed)
					else
						if(newgene.get_plant_gene_flags() & PLANT_GENE_QDEL_TARGET)
							qdel(newgene)
					repaint_seed()

			if("adjust")
				var/datum/plant_gene/reagent/G = target
				if(istype(G, /datum/plant_gene/reagent))
					G.reag_unit = reag_target_value
					repaint_seed()


			if("mutate")
				if(ispath(newseed, /obj/item/seeds) && seed)
					if(ispath(newseed, /obj/item/seeds/random))
						newseed = new newseed
						var/obj/item/seeds/random/newseed_s = newseed
						newseed_s.set_new_seed(seed.research_identifier) // Strange seed will have their own cycle
					else
						newseed = new newseed
					qdel(seed)
					seed = null
					insert_seed(newseed)

		newseed = null
		operation = null
		target = null
		reagent_id = null
		reag_unit_max = null
		newgene = null
		action_strong_confirmation = FALSE
		. = TRUE


	if(.)
		update_genes()
		update_icon()

/obj/machinery/plantgenes/proc/insert_seed(obj/item/seeds/S)
	if(!istype(S) || seed)
		return
	S.forceMove(src)
	seed = S
	research_valid_check()
	update_genes()
	update_icon()
	ui_update()


/obj/machinery/plantgenes/proc/eject_seed()
	if (seed && !operation)
		if(Adjacent(usr) && !issiliconoradminghost(usr))
			if (!usr.put_in_hands(seed))
				seed.forceMove(drop_location())
		else
			seed.forceMove(drop_location())
		research_valid = TRUE
		seed = null
		update_genes()
		ui_update()
		. = TRUE

/obj/machinery/plantgenes/proc/research_valid_check()
	// Check if the seed is researched or you can't manipulate this seed
	research_valid = TRUE
	if(seed)
		research_valid = researched_plant_check(seed, stored_research.researched_plants)

/obj/machinery/plantgenes/proc/researched_plant_check(obj/item/seeds/S, var/list/plantdata)
	. = FALSE
	if(!plantdata)
		return

	if(S.research_identifier in plantdata)
		if(plantdata[S.research_identifier]["faction"] & research_faction_type)
			return TRUE

/obj/machinery/plantgenes/proc/update_genes()
	core_genes = list()
	core_genes_sub = list()
	reagent_genes = list()
	trait_genes = list()
	family_gene = null
	mutate_list = list()

	if(seed)
		var/gene_paths = list(
			/datum/plant_gene/core/potency,
			/datum/plant_gene/core/yield,
			/datum/plant_gene/core/production,
			/datum/plant_gene/core/endurance,
			/datum/plant_gene/core/lifespan,
			/datum/plant_gene/core/weed_rate,
			/datum/plant_gene/core/weed_chance
			)
		for(var/a in gene_paths)
			var/datum/plant_gene/temp = seed.get_gene(a)
			if(!isnull(temp))
				core_genes += temp

		gene_paths = list(
			/datum/plant_gene/core/volume_mod,
			/datum/plant_gene/core/bitesize_mod,
			/datum/plant_gene/core/bite_type,
			///datum/plant_gene/core/distill_reagent, //temporary disable
			/datum/plant_gene/core/wine_power,
			/datum/plant_gene/core/rarity)
		for(var/a in gene_paths)
			var/datum/plant_gene/temp = seed.get_gene(a)
			if(!isnull(temp))
				core_genes_sub += temp

		for(var/datum/plant_gene/reagent/G in seed.genes)
			reagent_genes += G

		for(var/datum/plant_gene/trait/G in seed.genes)
			trait_genes += G

		family_gene = seed.family

		for(var/M in seed.mutatelist)
			mutate_list += M


/obj/machinery/plantgenes/proc/change_seed_name_desc(obj/item/seeds/O, var/choice, mob/user)
	switch(choice)
		if("Plant Name")
			var/input = stripped_input(user,"What do you want to name the plant?", O.plantname, "", MAX_NAME_LEN)
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE) || !length(input))
				return
			O.name = "pack of [input] seeds"
			O.plantname = input

		if("Plant Description")
			var/input = stripped_input(user,"What do you want to change the description of \the plant to?", O.plantdesc, "", MAX_NAME_LEN)
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE) || !length(input))
				return
			O.plantdesc = input

		if("Seed Description")
			var/input = stripped_input(user,"What do you want to change the description of \the seeds to?", O.desc, "", MAX_NAME_LEN)
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE) || !length(input))
				return
			O.desc = input

/obj/machinery/plantgenes/proc/repaint_seed()
	if(!seed)
		return
	if(copytext(seed.name, 1, 13) == "experimental")//13 == length("experimental") + 1
		return // Already modded name and icon
	seed.name = "experimental " + seed.name
	seed.icon_state = "seed-x"
	seed.modified = TRUE
	ui_update()



// Gene modder for seed vault ship, built with high tech alien parts.
/obj/machinery/plantgenes/seedvault
	name = "lifebringer's plant DNA manipulator"
	desc = "An advanced device designed to manipulate plant genetic makeup for scientific podpeople."
	circuit = /obj/item/circuitboard/machine/plantgenes/vault

/obj/machinery/plantgenes/seedvault/Initialize(mapload)
	. = ..()
	if(!stored_research)
		stored_research = SSresearch.science_tech
	research_faction_type = BOTANY_RESEARCHED_LIFEBRINGER

/obj/machinery/plantgenes/centcom
	name = "CentCom plant DNA manipulator"
	circuit = /obj/item/circuitboard/machine/plantgenes/centcom

/obj/machinery/plantgenes/centcom/Initialize(mapload)
	. = ..()
	if(!stored_research)
		stored_research = SSresearch.science_tech
	research_faction_type = BOTANY_RESEARCHED_CENTCOM
