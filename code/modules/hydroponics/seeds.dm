// ********************************************************
// Here's all the seeds (plants) that can be used in hydro
// ********************************************************
#define BTNY_CALC_WRAP(X)

/obj/item/seeds
	icon = 'icons/obj/hydroponics/seeds.dmi'
	icon_state = "seed"				// Unknown plant seed - these shouldn't exist in-game.
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	var/plantname = "Plants"		// Name of plant when planted.
	var/plantdesc
	var/species = ""                // Used to update icons. Should match the name in the sprites unless all icon_* are overridden.

	var/growing_icon = 'icons/obj/hydroponics/growing.dmi' //the file that stores the sprites of the growing plant from this seed.
	var/icon_grow					// Used to override grow icon (default is "[species]-grow"). You can use one grow icon for multiple closely related plants with it.
	var/icon_dead					// Used to override dead icon (default is "[species]-dead"). You can use one dead icon for multiple closely related plants with it.
	var/icon_harvest				// Used to override harvest icon (default is "[species]-harvest"). If null, plant will use [icon_grow][growthstages].
	var/growthstages = 6   // Amount of growth sprites the plant has.

	var/product                     // A type path. The thing that is created when the plant is harvested.

	var/list/mutatelist = list()    // The type of plants that this plant can mutate into.
	/* ## Structure rule:
			mutatelist = list(/obj/item/seeds/something1, /obj/item/seeds/another2, /obj/item/seeds/maybe3)
	*/

	// Seed stats
	var/potency = 50       // The 'power' of a plant. Effects the intensity of abilities in a plant. (It was used to effect the amount of reagents in a plant, but not anymore.)
	var/lifespan = 25      // How long before the plant begins to take damage from age.
	var/endurance = 20     // Amount of health the plant has.
	var/maturation = 6     // Used to determine which sprite to switch to when growing.
	var/production = 6     // Changes the amount of time needed for a plant to become harvestable.
	var/yield = 3          // Amount of growns created per harvest. If is -1, the plant/shroom/weed is never meant to be harvested.
	var/maxyield = 10      // r
	var/weed_rate = 1      //If the chance below passes, then this many weeds sprout during growth
	var/weed_chance = 5    //Percentage chance per tray update to grow weeds
	var/max_stat = 16

	// Plant stats
	var/bitesize_mod = 5      //How much do you eat - default 5u
	var/bite_type = PLANT_BITE_TYPE_DYNAM  // bitesize_mod 5, CONST = 5u / size 5, RATIO = 5%
	var/volume_mod = 50    //How big this plant is
	var/can_distill = TRUE //If FALSE, this object cannot be distilled into an alcohol.
	var/distill_reagent    //If NULL and this object can be distilled, it uses a generic fruit_wine reagent and adjusts its variables.
	var/wine_power = 10    //Determines the boozepwr of the wine if distill_reagent is NULL.
	var/rarity = 0					// How rare the plant is. Used for giving points to cargo when shipping off to CentCom.

	// Plant genes
	var/list/genes = list()			// Plant genes are stored here, see plant_genes.dm for more info.
	var/datum/plant_gene/family/family = /datum/plant_gene/family // Basic family that does nothing.
	var/list/reagents_innate = list() // a reagent gene that you can't play well
	var/list/reagents_set = list()    // a reagent geen you can play with
	/* ## Structure rule:
		reagents_set = list(
			[datum path: datum/reagent/something1] = list([number: default_reagent_size], [number: maximum_reagent_size])
			[datum path: datum/reagent/another2] = list([number: default_reagent_size], [number: maximum_reagent_size])
			innate needs FLAG additionally.

		reagents_innate = list(
			/datum/reagent/consumable/nutriment = list(1, 2, NONE), // FLAG: Can't remove, Can't adjust
			/datum/reagent/consumable/nutriment/vitamin = list(3, 4, PLANT_GENE_REAGENT_ADJUSTABLE), // FLAG: can't remove
			/datum/reagent/consumable/banana = list(5, 7, PLANT_GENE_COMMON_REMOVABLE)) // FLAG: Can't adjust
	 */

	var/research_identifier
	// used to check if a plant was researched through checking its `product` path. strange seed needs customised identifier.
	// You don't have to touch this value unless you certainly believe you need to do.
	// TLDR: Don't touch this.

	var/modified = FALSE //Used to block scan a crop when they're modified. need to block cross-research between factions.


/obj/item/seeds/Initialize(mapload, nogenes = 0)
	. = ..()
	pixel_x = rand(-8, 8)
	pixel_y = rand(-8, 8)

	if(!icon_grow)
		icon_grow = "[species]-grow"

	if(!icon_dead)
		icon_dead = "[species]-dead"

	if(!icon_harvest && !get_gene(/datum/plant_gene/family/fungal_metabolism) && yield != -1)
		icon_harvest = "[species]-harvest"

	research_identifier = name

	if(!nogenes) // not used on Copy()
		set_core_genes()
		set_trait_genes()
		set_family_gene()
		set_reagent_genes()

/obj/item/seeds/Destroy()
	qdel_genes() //qdel_genes should be used for seed re-initialization too.
	if(mutatelist)
		mutatelist.Cut()
	return ..()

/obj/item/seeds/proc/qdel_genes()
	// some genes are a static object which used in every plant - i.e.)perennial growth
	if(genes)
		for(var/datum/plant_gene/C in genes)
			if(C.get_plant_gene_flags() & PLANT_GENE_QDEL_TARGET)
				qdel(C)
		genes = null
	if(istype(family))
		if(family.get_plant_gene_flags() & PLANT_GENE_QDEL_TARGET)
			qdel(family)
		family = null


/////////////////////////////////////////
///// plant gene controlling system /////
// core -------------------------
/obj/item/seeds/proc/set_core_genes()
	genes += new PLANT_GENEPATH_POTENT(potency)
	genes += new PLANT_GENEPATH_YIELD(yield)
	genes += new PLANT_GENEPATH_MATURA(maturation)
	genes += new PLANT_GENEPATH_PRODUC(production)
	genes += new PLANT_GENEPATH_LIFESP(lifespan)
	genes += new PLANT_GENEPATH_ENDURA(endurance)
	genes += new PLANT_GENEPATH_WEEDRA(weed_rate)
	genes += new PLANT_GENEPATH_WEEDCH(weed_chance)
	if(bite_type) // non-edible
		genes += new PLANT_GENEPATH_VOLUME(volume_mod)
		genes += new PLANT_GENEPATH_BITESI(bitesize_mod)
		genes += new PLANT_GENEPATH_BITETY(bite_type)
	genes += new PLANT_GENEPATH_DISTIL(distill_reagent)
	if(!isnull(distill_reagent))
		genes += new PLANT_GENEPATH_WINEPO(wine_power)
	if(rarity)
		genes += new PLANT_GENEPATH_RARITY(rarity)


/obj/item/seeds/proc/gene_update_from_seed(var/target)
	var/datum/plant_gene/core/thing = get_gene(target)
	if(!isnull(thing))
		thing.update_from_seed(src)

// trait -------------------------
/obj/item/seeds/proc/get_trait_gene_from_static(var/datum/plant_gene/trait/genepath)
	if(isnull(genepath))
		return
	if(istype(genepath))
		genepath = genepath.type

	var/static/list/trait_genes
	if(isnull(trait_genes))
		trait_genes = list()
		for(var/each as() in subtypesof(/datum/plant_gene/trait))
			trait_genes[each] += new each

	var/datum/plant_gene/trait/T = trait_genes[genepath]
	return (initial(T.plant_gene_flags) & PLANT_GENE_QDEL_TARGET) ? new trait_genes[genepath] : trait_genes[genepath]

/obj/item/seeds/proc/set_trait_genes()
	for(var/G in genes)
		if(ispath(G))
			genes -= G
			genes += get_trait_gene_from_static(G)

	// trait genes apply
	for(var/datum/plant_gene/G in genes)
		if(istype(G, /datum/plant_gene/trait))
			G.on_new_seed(src)

// family -------------------------
/obj/item/seeds/proc/get_family_gene_from_static(var/datum/plant_gene/family/genepath)
	if(isnull(genepath))
		return
	if(istype(genepath))
		genepath = genepath.type

	var/static/list/family_genes
	if(isnull(family_genes))
		family_genes = list()
		for(var/datum/plant_gene/family/each as() in typesof(/datum/plant_gene/family))
			family_genes[each] += new each

	var/datum/plant_gene/family/F = family_genes[genepath]
	return (initial(F.plant_gene_flags) & PLANT_GENE_QDEL_TARGET) ? new family_genes[genepath] : family_genes[genepath]


/obj/item/seeds/proc/set_family_gene()
	family = get_family_gene_from_static(family)

// reagent -------------------------
/obj/item/seeds/proc/set_reagent_genes()
	for(var/reag_id in reagents_innate)
		genes += new /datum/plant_gene/reagent/innate(reag_id, reagents_innate[reag_id])
	reagents_innate = null
	for(var/reag_id in reagents_set)
		genes += new /datum/plant_gene/reagent/sandbox(reag_id, reagents_set[reag_id])
	reagents_set = null

/obj/item/seeds/proc/get_gene(typepath)
	return (locate(typepath) in genes)

///This proc adds a mutability_flag to a gene
/obj/item/seeds/proc/set_plant_gene_flags(typepath, mutability)
	var/datum/plant_gene/g = get_gene(typepath)
	if(g)
		g.plant_gene_flags |=  mutability

///This proc removes a mutability_flag from a gene
/obj/item/seeds/proc/unset_plant_gene_flags(typepath, mutability)
	var/datum/plant_gene/g = get_gene(typepath)
	if(g)
		g.plant_gene_flags &=  ~mutability


/obj/item/seeds/proc/gettype()
	return type

/obj/item/seeds/proc/Copy()
	var/obj/item/seeds/S = new type(null, 1)
	//plant info
	S.name = name
	S.plantname = plantname
	S.desc = desc
	S.plantdesc = plantdesc
	S.species = species
	S.research_identifier = research_identifier
	S.modified = modified

	// gene initialize
	S.qdel_genes()
	S.genes = list()

	// Copy core genes
	for(var/datum/plant_gene/core/each in genes)
		var/datum/plant_gene/core/G = each
		S.genes += G.Copy()
		G.apply_stat(S)

	// trait genes
	for(var/datum/plant_gene/trait/each in genes)
		S.genes += get_trait_gene_from_static(each)

	// trait genes apply
	for(var/datum/plant_gene/G in genes)
		if(istype(G, /datum/plant_gene/trait))
			G.on_new_seed(S)

	// Copy family gene
	if(istype(family, /datum/plant_gene/family/alien_properties))
		var/datum/plant_gene/family/F = family
		S.family = F.Copy()
	else
		S.family = get_family_gene_from_static(family)

	// Copy reagent genes
	for(var/datum/plant_gene/reagent/each in genes)
		var/datum/plant_gene/reagent/R = each
		S.genes += R.Copy()

	return S

// Harvest procs
/obj/item/seeds/proc/getYield()
	var/return_yield = yield

	var/obj/machinery/hydroponics/parent = loc
	if(istype(loc, /obj/machinery/hydroponics))
		if(parent.yieldmod == 0)
			return_yield = min(return_yield, 1)//1 if above zero, 0 otherwise
		else
			return_yield *= (parent.yieldmod)

	return return_yield


/obj/item/seeds/proc/harvest(mob/user)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0
	var/list/result = list()
	var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc //needed for TK
	var/product_name
	while(t_amount < getYield())
		var/obj/item/reagent_containers/food/snacks/grown/t_prod = new product(output_loc, src)
		if(parent.myseed.plantname != initial(parent.myseed.plantname))
			t_prod.name = parent.myseed.plantname
		if(parent.myseed.plantdesc)
			t_prod.desc = parent.myseed.plantdesc
		t_prod.seed.name = parent.myseed.name
		t_prod.seed.desc = parent.myseed.desc
		t_prod.seed.plantname = parent.myseed.plantname
		t_prod.seed.plantdesc = parent.myseed.plantdesc
		t_prod.roundstart = 0 // make them researchable
		result.Add(t_prod) // User gets a consumable
		if(!t_prod)
			return
		t_amount++
		product_name = t_prod.seed.plantname
	if(getYield() >= 1)
		SSblackbox.record_feedback("tally", "food_harvested", getYield(), product_name)

	var/gene_list = ""
	for(var/datum/plant_gene/reagent/each in genes)
		gene_list += "\[[each.name] [each.reag_unit]\] "
	for(var/datum/plant_gene/trait/each in genes)
		gene_list += "\[[each.name]\] "
	user.investigate_log("has harvested a plant that has traits: [gene_list]. Harvester's ckey: \"[user.ckey]\"", INVESTIGATE_BOTANY)
	parent.update_tray(user)

	return result

/obj/item/seeds/proc/harvest_inedible(mob/user)
	var/obj/machinery/hydroponics/parent = loc //for ease of access
	var/t_amount = 0
	var/list/result = list()
	var/output_loc = parent.Adjacent(user) ? user.loc : parent.loc //needed for TK
	var/product_name
	while(t_amount < getYield())
		var/obj/item/grown/t_prod = new product(output_loc, src)
		if(parent.myseed.plantname != initial(parent.myseed.plantname))
			t_prod.name = parent.myseed.plantname
		if(parent.myseed.plantdesc)
			t_prod.desc = parent.myseed.plantdesc
		t_prod.seed.name = parent.myseed.name
		t_prod.seed.desc = parent.myseed.desc
		t_prod.seed.plantname = parent.myseed.plantname
		t_prod.seed.plantdesc = parent.myseed.plantdesc
		t_prod.roundstart = 0 // make them researchable
		result.Add(t_prod) // User gets a consumable
		if(!t_prod)
			return
		t_amount++
		product_name = t_prod.seed.plantname
	if(getYield() >= 1)
		SSblackbox.record_feedback("tally", "food_harvested", getYield(), product_name)

	var/gene_list = ""
	for(var/datum/plant_gene/trait/each in genes)
		gene_list += "\[[each.name]\] "
	user.investigate_log("has harvested a plant that has traits: [gene_list]. Harvester's ckey: \"[user.ckey]\"", INVESTIGATE_BOTANY)
	parent.update_tray(user)

	return result


/obj/item/seeds/proc/prepare_result(var/obj/item/T)
	if(!T.reagents)
		CRASH("[T] has no reagents.")

	for(var/datum/plant_gene/G in genes)
		if(!istype(G, /datum/plant_gene/reagent))
			continue
		var/datum/plant_gene/reagent/RG = G
		// gene variable contains multiple variable which isn't /plant_gene/reagent, so I had to do this. I know this looks ugly.
		var/amount = RG.reag_unit

		var/list/data = null
		if(RG.reagent_id == /datum/reagent/blood) // Hack to make blood in plants always O-
			data = list("blood_type" = "O-")
		if(RG.reagent_id == /datum/reagent/consumable/nutriment || RG.reagent_id == /datum/reagent/consumable/nutriment/vitamin)
			// apple tastes of apple.
			if(istype(T, /obj/item/reagent_containers/food/snacks/grown))
				var/obj/item/reagent_containers/food/snacks/grown/grown_edible = T
				data = grown_edible.tastes

		T.reagents.add_reagent(RG.reagent_id, amount, data)


/// Setters procs ///
/obj/item/seeds/proc/adjust_yield(adjustamt)
	if(yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		yield = CLAMP(yield + adjustamt, 0, 10)

		if(yield <= 0 && get_gene(/datum/plant_gene/family/fungal_metabolism))
			yield = 1 // Mushrooms always have a minimum yield of 1.
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/yield)
		if(C)
			C.value = yield

/obj/item/seeds/proc/adjust_lifespan(adjustamt)
	lifespan = CLAMP(lifespan + adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/lifespan)
	if(C)
		C.value = lifespan

/obj/item/seeds/proc/adjust_endurance(adjustamt)
	endurance = CLAMP(endurance + adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/endurance)
	if(C)
		C.value = endurance

/obj/item/seeds/proc/adjust_production(adjustamt)
	if(yield != -1)
		production = CLAMP(production + adjustamt, 1, 10)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/production)
		if(C)
			C.value = production

/obj/item/seeds/proc/adjust_potency(adjustamt)
	if(potency != -1)
		potency = CLAMP(potency + adjustamt, 0, 100)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/potency)
		if(C)
			C.value = potency

/obj/item/seeds/proc/adjust_weed_rate(adjustamt)
	weed_rate = CLAMP(weed_rate + adjustamt, 0, 10)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_rate)
	if(C)
		C.value = weed_rate

/obj/item/seeds/proc/adjust_weed_chance(adjustamt)
	weed_chance = CLAMP(weed_chance + adjustamt, 0, 67)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_chance)
	if(C)
		C.value = weed_chance

//Directly setting stats
/obj/item/seeds/proc/set_yield(adjustamt)
	if(yield != -1) // Unharvestable shouldn't suddenly turn harvestable
		yield = CLAMP(adjustamt, 0, 10)

		if(yield <= 0 && get_gene(/datum/plant_gene/family/fungal_metabolism))
			yield = 1 // Mushrooms always have a minimum yield of 1.
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/yield)
		if(C)
			C.value = yield

/obj/item/seeds/proc/set_lifespan(adjustamt)
	lifespan = CLAMP(adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/lifespan)
	if(C)
		C.value = lifespan

/obj/item/seeds/proc/set_endurance(adjustamt)
	endurance = CLAMP(adjustamt, 10, 100)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/endurance)
	if(C)
		C.value = endurance

/obj/item/seeds/proc/set_production(adjustamt)
	if(yield != -1)
		production = CLAMP(adjustamt, 1, 10)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/production)
		if(C)
			C.value = production

/obj/item/seeds/proc/set_maturation(adjustamt)
	if(yield != -1)
		maturation = CLAMP(adjustamt, 1, 100)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/maturation)
		if(C)
			C.value = maturation

/obj/item/seeds/proc/set_potency(adjustamt)
	if(potency != -1)
		potency = CLAMP(adjustamt, 0, 100)
		var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/potency)
		if(C)
			C.value = potency

/obj/item/seeds/proc/set_weed_rate(adjustamt)
	weed_rate = CLAMP(adjustamt, 0, 10)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_rate)
	if(C)
		C.value = weed_rate

/obj/item/seeds/proc/set_weed_chance(adjustamt)
	weed_chance = CLAMP(adjustamt, 0, 67)
	var/datum/plant_gene/core/C = get_gene(/datum/plant_gene/core/weed_chance)
	if(C)
		C.value = weed_chance


/obj/item/seeds/proc/get_analyzer_text()  //in case seeds have something special to tell to the analyzer
	var/datum/plant_gene/family/F = family
	var/text = ""
	text += "- Plant family: [F.fname] \n"
	text += "- Potency: [potency]\n"
	text += "- Yield: [yield]\n"
	text += "- Maturation speed: [maturation]\n"
	text += "- Production speed: [production]\n"
	text += "- Lifespan: [lifespan]\n"
	text += "- Endurance: [endurance]\n"
	text += "- Weed Growth Rate: [weed_rate]\n"
	text += "- Weed Vulnerability: [weed_chance]\n"
	if(rarity)
		text += "- Species Discovery Value: [rarity]\n"
	var/all_traits = ""
	for(var/datum/plant_gene/trait/traits in genes)
		all_traits += "\[[traits.get_name()]\] "
	text += "- Plant Traits: [all_traits]\n"

	text += "*---------*"

	return text

/obj/item/seeds/proc/on_chem_reaction(datum/reagents/S)  //in case seeds have some special interaction with special chems
	return

/obj/item/seeds/attackby(obj/item/O, mob/user, params)
	if (istype(O, /obj/item/plant_analyzer))
		to_chat(user, "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>.</span>")
		var/text = get_analyzer_text()
		if(text)
			to_chat(user, "<span class='notice'>[text]</span>")

		return

	if (istype(O, /obj/item/pen))
		var/penchoice = input(user, "What would you like to edit?") as null|anything in list("Plant Name","Plant Description","Seed Description")
		if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
			return

		if(penchoice == "Plant Name")
			var/input = stripped_input(user,"What do you want to name the plant?", ,"", MAX_NAME_LEN)
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			name = "pack of [input] seeds"
			plantname = input

		if(penchoice == "Plant Description")
			var/input = stripped_input(user,"What do you want to change the description of \the plant to?", ,"", MAX_NAME_LEN)
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			plantdesc = input

		if(penchoice == "Seed Description")
			var/input = stripped_input(user,"What do you want to change the description of \the seeds to?", ,"", MAX_NAME_LEN)
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			desc = input
	..() // Fallthrough to item/attackby() so that bags can pick seeds up







// Checks plants for broken tray icons. Use Advanced Proc Call to activate.
// Maybe some day it would be used as unit test.
/proc/check_plants_growth_stages_icons()
	var/list/states = icon_states('icons/obj/hydroponics/growing.dmi')
	states |= icon_states('icons/obj/hydroponics/growing_fruits.dmi')
	states |= icon_states('icons/obj/hydroponics/growing_flowers.dmi')
	states |= icon_states('icons/obj/hydroponics/growing_mushrooms.dmi')
	states |= icon_states('icons/obj/hydroponics/growing_vegetables.dmi')
	var/list/paths = typesof(/obj/item/seeds) - /obj/item/seeds - typesof(/obj/item/seeds/sample)

	for(var/seedpath in paths)
		var/obj/item/seeds/seed = new seedpath

		for(var/i in 1 to seed.growthstages)
			if("[seed.icon_grow][i]" in states)
				continue
			to_chat(world, "[seed.name] ([seed.type]) lacks the [seed.icon_grow][i] icon!")

		if(!(seed.icon_dead in states))
			to_chat(world, "[seed.name] ([seed.type]) lacks the [seed.icon_dead] icon!")

		if(seed.icon_harvest) // mushrooms have no grown sprites, same for items with no product
			if(!(seed.icon_harvest in states))
				to_chat(world, "[seed.name] ([seed.type]) lacks the [seed.icon_harvest] icon!")

/obj/item/seeds/proc/randomize_stats(given_identifier)
	var/list/chances = rand_LCM(given_identifier, maximum=101, flat=0, numbers_of_return=4)
	set_potency(chances[1])
	set_lifespan(chances[2])
	set_endurance(chances[3])
	set_weed_chance(chances[4])

	chances = rand_LCM(given_identifier, maximum=11, flat=0, numbers_of_return=3)
	set_yield(chances[1])
	set_production(chances[2])
	set_weed_rate(chances[3])

	set_maturation(rand_LCM(given_identifier, maximum=21, flat=0))

	chances = null


/obj/item/seeds/proc/add_random_reagents(var/chem_rand_seed = FALSE)
	var/static/botany_chem_len
	if(!botany_chem_len)
		botany_chem_len = length(get_random_reagent_id(CHEMICAL_RNG_BOTANY, return_as_list=TRUE))
	var/chem_id = get_random_reagent_id(CHEMICAL_RNG_BOTANY, find_by_number=rand_LCM(chem_rand_seed, maximum=botany_chem_len))
	var/random_amount = (rand_LCM(chem_rand_seed, maximum=4, flat=1)+2)*5 // 10u~30u
	if(!chem_id)
		CRASH("Failed to pick a random chem from botany random reagent.")
	var/datum/plant_gene/reagent/sandbox/R = new(chem_id, list(random_amount-5, random_amount))
	if(R.can_add(src))
		genes += R
	else
		qdel(R)

/obj/item/seeds/proc/add_random_traits(var/trait_rand_seed = FALSE)
	var/static/trait_len
	var/static/list/trait_list = list()
	if(!trait_list.len)
		for(var/each in subtypesof(/datum/plant_gene/trait))
			var/datum/plant_gene/trait/T = each
			if(initial(T.plant_gene_flags) & PLANT_GENE_RANDOM_ALLOWED)
				trait_list += T
		trait_len = length(trait_list)

	var/trait_id = trait_list[rand_LCM(trait_rand_seed, maximum=trait_len)]
	var/datum/plant_gene/trait/T
	if(ispath(trait_id, /datum/plant_gene/trait/glow/random))
		T = get_trait_gene_from_static(trait_id)
		T.on_new_seed(src, rand_LCM(trait_rand_seed, maximum=8)) // manual input is needed. current glow trait subtype length is 8.
	if(isnull(trait_id))
		CRASH("random trait [T] is called as null.")
	T = get_trait_gene_from_static(trait_id)
	if(!istype(T))
		return
	if(T.can_add(src))
		genes += T
	else if(T.plant_gene_flags & PLANT_GENE_QDEL_TARGET)
		qdel(T)
	for(var/datum/plant_gene/G in genes)
		if(istype(G, /datum/plant_gene/trait))
			G.on_new_seed(src)




/obj/item/seeds/proc/add_random_plant_type(normal_plant_chance = 75)
	if(prob(normal_plant_chance))
		qdel(family)
		var/random_plant_type = pick(subtypesof(/datum/plant_gene/family))
		var/datum/plant_gene/family/P = new random_plant_type
		if(P.can_add(src))
			family = P
		else
			qdel(P)

/*
/obj/item/seeds/proc/add_random_traits_tempo(lower = 0, upper = 2, supercheck = FALSE)
    //random list initialisation
    var/static/list/random_traits
    var/static/list/random_super_traits
    if(!random_traits)
        random_traits = list()
        random_super_traits = list()
        for(var/datum/plant_gene/trait/trait as() in subtypesof(/datum/plant_gene/trait)-typesof(/datum/plant_gene/trait/plant_type))
            if(initial(trait.random_flags) & PLANT_GENE_BASE_RANDOM)
                random_traits += trait
                world.log << initial(trait.name)
            //else if(!(initial(trait.random_flags) & PLANT_GENE_NO_RANDOM_EX))


    //pick random
    if(!supercheck)
        var/amount_random_traits = rand(lower, upper)
        for(var/i in 1 to amount_random_traits)
            var/picked_trait = pick(random_traits)
            var/datum/plant_gene/trait/T = new picked_trait()
            if(T.can_add(src))
                genes += T
            else
                qdel(T)
*/
/obj/item/seeds/proc/setting_crops(var/list/given_seeds)
	if(!length(given_seeds))
		return list()

	world.log << "SS: [given_seeds[1]]"
	var/static/list/static_seeds
	if(!static_seeds)
		world.log << "STARTED"
		static_seeds = list()
		for(var/obj/item/seeds/seed as() in subtypesof(/obj/item/seeds)-/obj/item/seeds/sample)
			var/obj/item/seeds/temp_seed = new seed
			static_seeds += temp_seed
			world.log << "1: [seed]"
			world.log << "2: [temp_seed]"
			world.log << "3: [static_seeds[1]]"

	var/list/L = list()
	. = L

	for(var/given_seed in given_seeds)
		if(given_seed in static_seeds)
			world.log << "static seed given"
			L += static_seeds[given_seed]
