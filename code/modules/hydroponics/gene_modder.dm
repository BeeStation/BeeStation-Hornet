/obj/machinery/plantgenes
	name = "plant DNA manipulator"
	desc = "An advanced device designed to manipulate plant genetic makeup."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "dnamod"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/plantgenes
	pass_flags = PASSTABLE

	var/obj/item/seeds/seed
	var/obj/item/disk/plantgene/disk

	var/list/core_genes = list()
	var/list/reagent_genes = list()
	var/list/trait_genes = list()

	var/datum/plant_gene/target
	var/operation = null
	var/max_potency = 50 // See RefreshParts() for how these work
	var/max_yield = 2
	var/min_production = 12
	var/max_endurance = 10 // IMPT: ALSO AFFECTS LIFESPAN
	var/min_wchance = 67
	var/min_wrate = 10

	var/skip_confirmation = FALSE

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
	if((machine_stat & (BROKEN|NOPOWER)))
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
			to_chat(user, span_notice("Please complete current operation."))
			return
		if(!user.transferItemToLoc(I, src))
			return
		eject_seed()
		insert_seed(I)
		to_chat(user, span_notice("You add [I] to the machine."))
		interact(user)
	else if(istype(I, /obj/item/disk/plantgene))
		if (operation)
			to_chat(user, span_notice("Please complete current operation."))
			return
		if(!user.transferItemToLoc(I, src))
			return
		eject_disk()
		disk = I
		to_chat(user, span_notice("You add [I] to the machine."))
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

	data["seed"] = seed?.name
	data["disk"] = null
	data["disk_gene"] = null
	data["disk_readonly"] = FALSE
	data["disk_canadd"] = TRUE

	data["operation"] = operation
	data["operation_target"] = build_gene(target)

	if(disk)
		data["disk_readonly"] = disk.read_only
		if(disk.gene)
			data["disk_gene"] = build_gene(disk.gene)
			data["disk"] = disk.gene.get_name()
			if(seed)
				data["disk_canadd"] = disk.gene.can_add(seed)
		else
			data["disk"] = "Empty disk"
		if(disk.read_only)
			data["disk"] += " (RO)"

	data["core_genes"] = build_gene_list(core_genes, /datum/plant_gene/core)
	data["reagent_genes"] = build_gene_list(reagent_genes, /datum/plant_gene/reagent)
	data["trait_genes"] = build_gene_list(trait_genes, /datum/plant_gene/trait)

	data["machine_stats"] = build_machine_stats()
	data["skip_confirmation"] = skip_confirmation

/obj/machinery/plantgenes/proc/build_machine_stats()
	var/list/L = list()
	. = L

	L["potency"] = list("max", max_potency)
	L["yield"] = list("max", max_yield)
	L["production speed"] = list("min", min_production)
	L["endurance"] = list("max", max_endurance)
	L["lifespan"] = list("max", max_endurance)
	L["weed growth rate"] = list("min", min_wrate)
	L["weed vulnerability"] = list("min", min_wchance)

/obj/machinery/plantgenes/proc/build_gene_list(list/genes, filter_type)
	var/list/L = list()
	. = L

	for(var/datum/plant_gene/gene in genes)
		L += list(build_gene(gene, filter_type))

/obj/machinery/plantgenes/proc/get_gene_id(datum/plant_gene/gene)
	if(istype(gene, /datum/plant_gene/core))
		var/datum/plant_gene/core/core_gene = gene
		return "core[core_gene.type]"
	if(istype(gene, /datum/plant_gene/reagent))
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

	L["extractable"] = gene.mutability_flags & PLANT_GENE_EXTRACTABLE
	L["removable"] = gene.mutability_flags & PLANT_GENE_REMOVABLE

	if(istype(gene, /datum/plant_gene/core))
		var/datum/plant_gene/core/core_gene = gene

		L["type"] = "core"
		L["stat"] = core_gene.name
		L["id"] = get_gene_id(gene)
		L["value"] = core_gene.value

	if(istype(gene, /datum/plant_gene/reagent))
		var/datum/plant_gene/reagent/reagent_gene = gene

		L["type"] = "reagent"
		L["id"] = get_gene_id(gene)
		L["rate"] = reagent_gene.rate

	if(istype(gene, /datum/plant_gene/trait))
		var/datum/plant_gene/trait/trait_gene = gene

		L["type"] = "trait"
		L["id"] = get_gene_id(gene)
		L["trait_id"] = trait_gene.trait_id

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

/obj/machinery/plantgenes/proc/find_gene_by_id(gene_id)
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

	if(action == "toggle_skip_confirmation")
		skip_confirmation = !skip_confirmation
		. = TRUE

	if(action == "eject_insert_seed")
		var/obj/item/I = usr.get_active_held_item()
		if(istype(I, /obj/item/seeds))
			if(!usr.transferItemToLoc(I, src))
				return
			eject_seed()
			insert_seed(I)
			to_chat(usr, span_notice("You add [I] to the machine."))
			. = TRUE
		else
			. = eject_seed()

	if(action == "eject_insert_disk")
		var/obj/item/I = usr.get_active_held_item()
		if(istype(I, /obj/item/disk/plantgene))
			if(!usr.transferItemToLoc(I, src))
				return
			eject_disk()
			disk = I
			to_chat(usr, span_notice("You add [I] to the machine."))
			. = TRUE
		else
			. = eject_disk()

	if(seed)
		if(action == "remove")
			var/datum/plant_gene/G = find_gene_by_id(params["gene_id"])
			if(!G)
				return FALSE
			operation = action
			target = G
			. = TRUE

		if(action == "extract")
			var/datum/plant_gene/G = find_gene_by_id(params["gene_id"])
			if(!G)
				return FALSE
			if(disk && !disk.read_only)
				operation = action
				target = G
				. = TRUE

		if(action == "replace")
			var/datum/plant_gene/G = find_gene_by_id(params["gene_id"])
			if(!G)
				return FALSE
			if(disk && disk.gene && istype(disk.gene, G.type) && istype(G, /datum/plant_gene/core))
				operation = action
				target = G
				. = TRUE

		if(action == "insert" && !istype(disk.gene, /datum/plant_gene/core) && disk.gene.can_add(seed))
			operation = action
			target = null
			. = TRUE

	if((action == "confirm" || (. && skip_confirmation)) && operation)
		if(operation == "remove")
			var/datum/plant_gene/G = target
			if(G)
				if(!istype(G, /datum/plant_gene/core))
					seed.genes -= G
					if(istype(G, /datum/plant_gene/reagent))
						seed.reagents_from_genes()
				repaint_seed()

		if(operation == "extract")
			var/datum/plant_gene/G = target
			if(G && disk && !disk.read_only)
				disk.gene = G
				if(istype(G, /datum/plant_gene/core))
					var/datum/plant_gene/core/gene = G
					if(istype(G, /datum/plant_gene/core/potency))
						gene.value = min(gene.value, max_potency)
					else if(istype(G, /datum/plant_gene/core/lifespan))
						gene.value = min(gene.value, max_endurance) //INTENDED
					else if(istype(G, /datum/plant_gene/core/endurance))
						gene.value = min(gene.value, max_endurance)
					else if(istype(G, /datum/plant_gene/core/production))
						gene.value = max(gene.value, min_production)
					else if(istype(G, /datum/plant_gene/core/yield))
						gene.value = min(gene.value, max_yield)
					else if(istype(G, /datum/plant_gene/core/weed_rate))
						gene.value = max(gene.value, min_wrate)
					else if(istype(G, /datum/plant_gene/core/weed_chance))
						gene.value = max(gene.value, min_wchance)
				disk.update_name()
				qdel(seed)
				seed = null

		if(operation == "replace")
			var/datum/plant_gene/G = target
			if(G && disk && disk.gene && istype(disk.gene, G.type) && istype(G, /datum/plant_gene/core))
				seed.genes -= G
				var/datum/plant_gene/core/C = disk.gene.Copy()
				seed.genes += C
				C.apply_stat(seed)
				repaint_seed()

		if(operation == "insert" && !istype(disk.gene, /datum/plant_gene/core) && disk.gene.can_add(seed))
			seed.genes += disk.gene.Copy()
			if(istype(disk.gene, /datum/plant_gene/reagent))
				seed.reagents_from_genes()
			repaint_seed()

		operation = null
		target = null
		. = TRUE

	if(action == "abort" && operation)
		operation = null
		target = null
		. = TRUE


	if(.)
		update_genes()
		update_icon()

/obj/machinery/plantgenes/proc/insert_seed(obj/item/seeds/S)
	if(!istype(S) || seed)
		return
	S.forceMove(src)
	seed = S
	update_genes()
	update_icon()
	ui_update()

/obj/machinery/plantgenes/proc/eject_disk()
	if (disk && !operation)
		if(Adjacent(usr) && !issiliconoradminghost(usr))
			if (!usr.put_in_hands(disk))
				disk.forceMove(drop_location())
		else
			disk.forceMove(drop_location())
		disk = null
		update_genes()
		ui_update()
		. = TRUE

/obj/machinery/plantgenes/proc/eject_seed()
	if (seed && !operation)
		if(Adjacent(usr) && !issiliconoradminghost(usr))
			if (!usr.put_in_hands(seed))
				seed.forceMove(drop_location())
		else
			seed.forceMove(drop_location())
		seed = null
		update_genes()
		ui_update()
		. = TRUE

/obj/machinery/plantgenes/proc/update_genes()
	core_genes = list()
	reagent_genes = list()
	trait_genes = list()

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
			core_genes += seed.get_gene(a)

		for(var/datum/plant_gene/reagent/G in seed.genes)
			reagent_genes += G

		for(var/datum/plant_gene/trait/G in seed.genes)
			trait_genes += G

/obj/machinery/plantgenes/proc/repaint_seed()
	if(!seed)
		return
	if(copytext(seed.name, 1, 13) == "experimental")//13 == length("experimental") + 1
		return // Already modded name and icon
	seed.name = "experimental " + seed.name
	seed.icon_state = "seed-x"
	ui_update()

// Gene modder for seed vault ship, built with high tech alien parts.
/obj/machinery/plantgenes/seedvault
	circuit = /obj/item/circuitboard/machine/plantgenes/vault

/*
 *  Plant DNA disk
 */

/obj/item/disk/plantgene
	name = "plant data disk"
	desc = "A disk for storing plant genetic data."
	icon_state = "datadisk_hydro"
	custom_materials = list(/datum/material/iron=30, /datum/material/glass=10)
	var/datum/plant_gene/gene
	var/read_only = 0 //Well, it's still a floppy disk
	obj_flags = UNIQUE_RENAME

/obj/item/disk/plantgene/Initialize(mapload)
	. = ..()
	add_overlay("datadisk_gene")
	src.pixel_x = rand(-5, 5)
	src.pixel_y = rand(-5, 5)

/obj/item/disk/plantgene/update_name()
	. = ..()
	if(gene)
		name = "[gene.get_name()] (plant data disk)"
	else
		name = "plant data disk"

/obj/item/disk/plantgene/attack_self(mob/user)
	read_only = !read_only
	to_chat(user, span_notice("You flip the write-protect tab to [src.read_only ? "protected" : "unprotected"]."))

/obj/item/disk/plantgene/examine(mob/user)
	. = ..()
	if(gene && (istype(gene, /datum/plant_gene/core/potency)))
		. += span_notice("Percent is relative to potency, not maximum volume of the plant.")
	. += "The write-protect tab is set to [src.read_only ? "protected" : "unprotected"]."
