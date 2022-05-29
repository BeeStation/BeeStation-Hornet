/datum/component/discoverable
	dupe_mode = COMPONENT_DUPE_UNIQUE
	//Amount of discovery points awarded when researched.
	var/scanned = FALSE
	var/unique = FALSE
	var/point_reward = 0

/datum/component/discoverable/Initialize(_point_reward, _unique = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_CLICK, .proc/tryScan)

	point_reward = _point_reward
	unique = _unique

/datum/component/discoverable/proc/tryScan(datum/source, location, control, params, mob/user)
	SIGNAL_HANDLER
	if(!isliving(user))
		return
	var/mob/living/L = user
	if(istype(L.get_active_held_item(), /obj/item/discovery_scanner))
		INVOKE_ASYNC(L.get_active_held_item(), /obj/item/discovery_scanner.proc/begin_scanning, user, src)

/datum/component/discoverable/proc/examine(datum/source, mob/user, atom/thing)
	SIGNAL_HANDLER
	if(!user.research_scanner)
		return
	to_chat(user, "<span class='notice'>Scientific data detected.</span>")
	to_chat(user, "<span class='notice'>Scanned: [scanned ? "True" : "False"].</span>")
	to_chat(user, "<span class='notice'>Discovery Value: [point_reward].</span>")

/datum/component/discoverable/proc/discovery_scan(datum/techweb/linked_techweb, mob/user, faction)
	//Already scanned our atom.
	var/shows_effect = FALSE
	var/atom/A = parent

	//------------------------------------------------------------------------------------
	//-------------------------------------- BOTANY --------------------------------------
	// Need to do this for hydroponics tray plants
	if(istype(A, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/M = A
		if(isnull(M.myseed))
			to_chat(user, "<span class='warning'>There's no growing plant in [M].</span>")
			return
		if(!M.harvest)
			to_chat(user, "<span class='warning'>[M.myseed.plantname] isn't ready for harvest.</span>")
			return
		if(M.dead)
			to_chat(user, "<span class='warning'>[M.myseed.plantname] is dead...</span>")
			return
		var/obj/item/seeds/S = M.myseed
		var/obj/item/reagent_containers/food/snacks/grown/SP = new S.product
		if(!isnull(SP))
			tryScan(SP)
			qdel(SP)
		return

	// Botany scan
	if(istype(A, /obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/P = A
		var/obj/item/seeds/seed = P.seed
		if(P.roundstart) //Roundstart crops are not valid to scan
			to_chat(user, "<span class='warning'>[P.name] has to be manually researched by growing them.</span>")
			return
		if(seed.modified) //You shouldn't scan a modified plant
			to_chat(user, "<span class='warning'>[P.name] has been modified. You need a pure sample.</span>")
			return
		if(discovery_scan_botany(linked_techweb, user, A, seed, P.research_identifier, research_faction_type=faction))
			to_chat(user, "<span class='notice'>Plant research successful. Data has been added.</span>")
			shows_effect = TRUE

	// I hate this duplication, but need to do for another botany type item.
	else if(istype(A, /obj/item/grown))
		var/obj/item/grown/P = A
		var/obj/item/seeds/seed = P.seed
		if(P.roundstart) //Roundstart crops are not valid to scan
			to_chat(user, "<span class='warning'>[P.name] has to be manually researched by growing them.</span>")
			return
		if(seed.modified) //You shouldn't scan a modified plant
			to_chat(user, "<span class='warning'>[P.name] has been modified. You need a pure sample.</span>")
			return
		if(discovery_scan_botany(linked_techweb, user, A, seed, P.research_identifier, research_faction_type=faction))
			to_chat(user, "<span class='notice'>Plant research successful. Data has been added.</span>")
			shows_effect = TRUE

	//-------------------------------------- BOTANY DONE --------------------------------------
	//-----------------------------------------------------------------------------------------

	// Standard scan check
	if(faction & BOTANY_RESEARCHED_NANOTRASEN)
		if(scanned)
			to_chat(user, "<span class='warning'>[A] has already been analysed.</span>")
			return

		//Already scanned another of this type.
		if(linked_techweb.scanned_atoms[A.type] && !unique)
			to_chat(user, "<span class='warning'>Datapoints about [A] already in system.</span>")
			return
		if(A.flags_1 & HOLOGRAM_1)
			to_chat(user, "<span class='warning'>[A] is holographic, no datapoints can be extracted.</span>")
			return

		// Successful scan
		scanned = TRUE
		shows_effect = TRUE
		linked_techweb.add_point_type(TECHWEB_POINT_TYPE_DISCOVERY, point_reward)
		linked_techweb.scanned_atoms[A.type] = TRUE
		to_chat(user, "<span class='notice'>New datapoint scanned, [point_reward] discovery points gained.</span>")

	if(shows_effect)
		playsound(user, 'sound/machines/terminal_success.ogg', 60)
		pulse_effect(get_turf(A), 4)

/datum/component/discoverable/proc/discovery_scan_botany(datum/techweb/linked_techweb, mob/user, atom/A, obj/item/seeds/S, var/research_identifier, var/research_faction_type)
	/*  <what does this do?>
		This stores botanical datas once you grow crops and scan them.
		saved datas are used in `gene_modder.dm` to manipulate plant genes.

		<from `grown.dm`>
		*research_identifier: [key] an identifier not to conflict in saved datas.
		                        Don't replace it with [P] or [P.type] (as path),
		                        because you need to research Strange seeds again and again
								and if you store it as path type, you won't be able to research strange seeds more than once.

		<variables from `techweb`>
		*researched_plants: [key from research_identifier] [value as bitflag from research_faction_type]
							Stores researched plants so that preventing you spamming scan to research them again.
		*researched_genes:  [key as data_id] Stores traits/chemicals from researched plants.

		<`researched_genes` array structure>
		## Structure rule:
				researched_genes[data_id] = list([bitflag], [path], [string], [number], [number])

		*[data_id]: just an unique key not to conflict themselves
			i.e.)
				trait:   F1T/datum/plant_gene/trait/cell_charge
				reagent: F1R/datum/plant_gene/reagent/sandbox (this stores reagent path already)
				family:  F1F/datum/plant_gene/family/carnivory
		*[data_id][1]: <bitflag> (from `research_faction_type` variable)
			Stores where this data belongs to.
		    `research_faction_type=BOTANY_RESEARCHED_NANOTRASEN` means this data is bound to station.
		    Lifebringers use BOTANY_RESEARCHED_LIFEBRINGERS instead of it, so they don't share data.
		*[data_id][2]: <path> Path of its data
			i.e.)    /datum/plant_gene/trait/cell_charge
		*[data_id][3]: <string> category of this gene, just as string.
		*[data_id][4]: <number> How many this data is researched.
			This is needed to store when you want a trait is unlocked after a few researches.
			i.e.) Perenial growth needs 5 research levels to unlock
		*[data_id][5]: <number> (reagent trait only) How much you can maximize this type of reagent. 10 means 10u is maximum.
		    `max(linked_techweb.researched_genes[data_id][5], reagent_gene.reag_unit_max)` is to override as the highest value from researched plants.

		<defines - used in `research_faction_type`>
		check `/code/_DEFINES/machines.dm`
		It uses bitflag to check which faction a data came from.

		BOTANY_RESEARCHED_NANOTRASEN 1
		BOTANY_RESEARCHED_LIFEBRINGER 2
	*/
	if(istype(A, /obj/item/reagent_containers/food/snacks/grown) || istype(A, /obj/item/grown))

		//------------------------------------------------------------------------------------------------------------------
		// Storing roundstart researches
		// Basically the same code from "trait" part of the code below.
		var/static/roundstart
		if(!isnull(roundstart))
			roundstart = TRUE
			var/all_factions = BOTANY_RESEARCHED_NANOTRASEN | BOTANY_RESEARCHED_LIFEBRINGER | BOTANY_RESEARCHED_CENTCOM
			for(var/each in subtypesof(/datum/plant_gene/trait)) // `var/datum/plant_gene/trait/each` doesn't work. don't ask me why.
				var/datum/plant_gene/trait/T = each
				var/data_id
				if(initial(T.research_needed) == 0) // if a research_needed is `0`, this will be roundstarting.
					data_id = "F[all_factions]T[T]"
					if(!linked_techweb.researched_genes[data_id])
						linked_techweb.researched_genes[data_id] += list(all_factions, null, "trait", 0)
					linked_techweb.researched_genes[data_id][2] = T
					linked_techweb.researched_genes[data_id][4] += 1
		//------------------------------------------------------------------------------------------------------------------

		if(!linked_techweb.researched_plants[research_identifier])
			linked_techweb.researched_plants[research_identifier] = 0
			// Establishing a storable variable in the list
		if(!(linked_techweb.researched_plants[research_identifier] & research_faction_type))
			linked_techweb.researched_plants[research_identifier] |= research_faction_type // Remembers which faction researched this data.
			. = TRUE //need this to pass TRUE to discoverable result.

			var/data_id
			for(var/datum/plant_gene/each in S.genes)
				// We only save genes from trait and reagent.
				if(istype(each, /datum/plant_gene/trait))
					var/datum/plant_gene/trait/trait_gene = each
					if(initial(trait_gene.research_needed) == -1) // if a research_needed is `-1`, this means unresearchable
						continue
					data_id = "F[research_faction_type]T[trait_gene.type]"
					if(!linked_techweb.researched_genes[data_id])
						linked_techweb.researched_genes[data_id] += list(research_faction_type, null, "trait", 0)
						// Establishing a storable variable in the list
					linked_techweb.researched_genes[data_id][2] = trait_gene.type
					linked_techweb.researched_genes[data_id][4] += 1
					// As stated abive, second array in the list is how much this is researched
					// Some plant genes should be researched more than once.
				if(istype(each, /datum/plant_gene/reagent/sandbox))
					var/datum/plant_gene/reagent/sandbox/reagent_gene = each
					data_id = "F[research_faction_type]R[reagent_gene.reagent_id]"
					if(!linked_techweb.researched_genes[data_id])
						linked_techweb.researched_genes[data_id] += list(research_faction_type, null, "reagent", 0, 0)
						// Establishing a storable variable in the list
					linked_techweb.researched_genes[data_id][2] = reagent_gene.reagent_id
					linked_techweb.researched_genes[data_id][4] += 1
					if(reagent_gene.reagent_id == /datum/reagent/consumable/nutriment)
						linked_techweb.researched_genes[data_id][5] = max(2.5, linked_techweb.researched_genes[data_id][5]+0.5) // starts at 2.5u nutriment, and 0.5+ per research
					else if(reagent_gene.reagent_id == /datum/reagent/consumable/nutriment/vitamin)
						linked_techweb.researched_genes[data_id][5] = max(1.25, linked_techweb.researched_genes[data_id][5]+0.25) // starts at 1.25u vitamin, and 0.25+ per research
						// because I don't want people to cherry-pick 20u nutriment at the roundstarting
					else
						linked_techweb.researched_genes[data_id][5] = max(linked_techweb.researched_genes[data_id][5], reagent_gene.reag_unit_max)
						// fifth array is maximum reagent unit. 15 means 15u, and botanist can't exceed this value by gene manipulation.

			// family gene isn't in `S.genes` variable, so we need to do this separately.
			var/datum/plant_gene/family/family_gene = S.family
			data_id = "F[research_faction_type]F[family_gene.type]"
			if(!linked_techweb.researched_genes[data_id])
				linked_techweb.researched_genes[data_id] += list(research_faction_type, null, "family", 0)
			linked_techweb.researched_genes[data_id][2] = family_gene.type
			linked_techweb.researched_genes[data_id][4] += 1
