/proc/translate_legacy_chem_id(id)
	switch (id)
		if ("sacid")
			return "sulfuricacid"
		if ("facid")
			return "fluorosulfuricacid"
		if ("co2")
			return "carbondioxide"
		if ("mine_salve")
			return "minerssalve"
		else
			return ckey(id)

/obj/machinery/chem_dispenser
	name = "chem dispenser"
	desc = "Creates and dispenses chemicals."
	density = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	base_icon_state = "dispenser"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	interaction_flags_machine = INTERACT_MACHINE_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OFFLINE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_dispenser


	var/obj/item/stock_parts/cell/cell
	var/powerefficiency = 0.1
	var/amount = 30
	var/recharge_amount = 10
	var/recharge_counter = 0
	var/mutable_appearance/beaker_overlay
	var/working_state = "dispenser_working"
	var/nopower_state = "dispenser_nopower"
	var/has_panel_overlay = TRUE
	var/obj/item/reagent_containers/beaker = null
	//dispensable_reagents is copypasted in plumbing synthesizers. Please update accordingly. (I didn't make it global because that would limit custom chem dispensers)
	var/list/dispensable_reagents = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/silver,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel
	)
	//these become available once the manipulator has been upgraded to tier 4 (femto)
	var/list/upgrade_reagents = list(
		/datum/reagent/acetone,
		/datum/reagent/ammonia,
		/datum/reagent/ash,
		/datum/reagent/diethylamine,
		/datum/reagent/oil,
		/datum/reagent/saltpetre
	)
	var/list/emagged_reagents = list(
		/datum/reagent/toxin/carpotoxin,
		/datum/reagent/medicine/mine_salve,
		/datum/reagent/medicine/morphine,
		/datum/reagent/drug/space_drugs,
		/datum/reagent/toxin
	)
	var/list/recording_recipe

	var/list/saved_recipes = list()
	/// The default filters for recipes that are shown in the UI
	var/default_filters = ALL & ~(REACTION_TAG_DRINK | REACTION_TAG_FOOD | REACTION_TAG_SLIME)

/obj/machinery/chem_dispenser/Initialize(mapload)
	. = ..()
	dispensable_reagents = sort_list(dispensable_reagents, GLOBAL_PROC_REF(cmp_reagents_asc))
	if(emagged_reagents)
		emagged_reagents = sort_list(emagged_reagents, GLOBAL_PROC_REF(cmp_reagents_asc))
	if(upgrade_reagents)
		upgrade_reagents = sort_list(upgrade_reagents, GLOBAL_PROC_REF(cmp_reagents_asc))
	update_appearance()

/obj/machinery/chem_dispenser/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(cell)
	return ..()

/obj/machinery/chem_dispenser/examine(mob/user)
	. = ..()
	if(panel_open)
		. += span_notice("[src]'s maintenance hatch is open!")
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads:\n"+\
		"Recharging <b>[recharge_amount]</b> power units per interval.\n"+\
		"Power efficiency increased by <b>[round((powerefficiency*1000)-100, 1)]%</b>.</span>"
	. += "<span class='notice'>Use <b>RMB</b> to eject a stored beaker.</span>"

/obj/machinery/chem_dispenser/process(delta_time)
	if (recharge_counter >= 8)
		if(!is_operational)
			return
		var/usedpower = cell.give(recharge_amount)
		if(usedpower)
			use_power(250*recharge_amount)
		recharge_counter = 0
		return
	recharge_counter += delta_time

/obj/machinery/chem_dispenser/proc/display_beaker()
	var/mutable_appearance/b_o = beaker_overlay || mutable_appearance(icon, "disp_beaker")
	b_o.pixel_y = -4
	b_o.pixel_x = -7
	return b_o

/obj/machinery/chem_dispenser/proc/work_animation()
	if(working_state)
		flick(working_state,src)

/obj/machinery/chem_dispenser/update_icon_state()
	icon_state = "[(nopower_state && !powered()) ? nopower_state : base_icon_state]"
	return ..()

/obj/machinery/chem_dispenser/update_overlays()
	. = ..()
	if(has_panel_overlay && panel_open)
		. += mutable_appearance(icon, "[base_icon_state]_panel-o")

	if(beaker)
		beaker_overlay = display_beaker()
		. += beaker_overlay

/obj/machinery/chem_dispenser/on_emag(mob/user)
	..()
	to_chat(user, span_notice("You short out [src]'s safeties."))
	dispensable_reagents |= emagged_reagents//add the emagged reagents to the dispensable ones

/obj/machinery/chem_dispenser/ex_act(severity, target)
	if(severity < 3)
		..()

/obj/machinery/chem_dispenser/contents_explosion(severity, target)
	..()
	if(beaker)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += beaker
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += beaker
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += beaker

/obj/machinery/chem_dispenser/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		cut_overlays()


/obj/machinery/chem_dispenser/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/chem_dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemDispenser")
		if(user.hallucinating())
			ui.set_autoupdate(FALSE) //to not ruin the immersion by constantly changing the fake chemicals
			//Seems like a pretty bad way to do it, but I think a better one would deserve a wider refactor including at least sleeper
		else
			ui.set_autoupdate(TRUE) // Cell charge
		ui.open()

/obj/machinery/chem_dispenser/ui_data(mob/user)
	var/data = list()
	data["amount"] = amount
	data["energy"] = cell.charge ? cell.charge * powerefficiency : "0" //To prevent NaN in the UI.
	data["maxEnergy"] = cell.maxcharge * powerefficiency
	data["isBeakerLoaded"] = beaker ? 1 : 0

	var/beakerContents[0]
	var/beakerCurrentVolume = 0
	if(beaker && beaker.reagents && beaker.reagents.reagent_list.len)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume, "path" = R.type))) // list in a list because Byond merges the first list...
			beakerCurrentVolume += R.volume
	data["beakerContents"] = beakerContents

	if (beaker)
		data["beakerCurrentVolume"] = beakerCurrentVolume
		data["beakerMaxVolume"] = beaker.volume
		data["beakerTransferAmounts"] = beaker.possible_transfer_amounts
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null
		data["beakerTransferAmounts"] = null
	data["containerType"] = beaker?.type

	var/chemicals[0]
	var/is_hallucinating = FALSE
	if(user.hallucinating())
		is_hallucinating = TRUE
	for(var/re in dispensable_reagents)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[re]
		if(temp)
			var/chemname = temp.name
			if(is_hallucinating && prob(5))
				chemname = "[pick_list_replacements("hallucination.json", "chemicals")]"
			chemicals.Add(list(list("title" = chemname, "id" = ckey(temp.name))))
	data["chemicals"] = chemicals
	data["recipes"] = saved_recipes

	data["recordingRecipe"] = recording_recipe
	return data

/obj/machinery/chem_dispenser/ui_static_data(mob/user)
	var/list/data = list()
	var/list/reactions
	for(var/i in GLOB.chemical_reactions_list)
		for(var/datum/chemical_reaction/reaction as anything in GLOB.chemical_reactions_list[i])
			var/list/required_reagents = list()
			var/display_name = reaction::name
			if (ispath(display_name, /datum/reagent))
				var/datum/reagent/reagent_path = display_name
				display_name = reagent_path::name
			for (var/datum/reagent/reagent as anything in reaction.required_reagents)
				required_reagents += list(list(
					"name" = reagent::name,
					"volume" = reaction.required_reagents[reagent],
					"path" = reagent
				))
			var/list/results = list()
			for (var/datum/reagent/result_path as anything in reaction.results)
				var/created_amount = reaction.results[result_path]
				results += list(list(
					"name" = result_path::name,
					"volume" = created_amount,
					"path" = result_path,
					"description" = result_path::description,
					"addiction" = result_path::addiction_threshold,
					"overdose" = result_path::overdose_threshold,
				))
			reactions += list(list(
				name = display_name,
				results = results,
				required_reagents = required_reagents,
				required_catalysts = reaction.required_catalysts,
				required_container = reaction.required_container,
				required_other = reaction.required_other,
				is_cold_recipe = reaction.is_cold_recipe,
				required_temp = reaction.required_temp,
				id = reaction.type,
				hints = reaction.hints,
				reaction_tags = reaction.reaction_tags
			))
	data["reactions_list"] = reactions
	data["default_filters"] = default_filters
	return data

/obj/machinery/chem_dispenser/ui_act(action, params)
	. = ..()
	if(.) // Propagation only used by debug machine, but eh
		return

	switch(action)
		if("eject")
			replace_beaker(usr)
			. = TRUE

	if(!is_operational)
		return

	switch(action)
		if("amount")
			if(QDELETED(beaker))
				return
			var/target = text2num(params["target"])
			if(target in beaker.possible_transfer_amounts)
				amount = target
				work_animation()
				. = TRUE
		if("dispense")
			if(QDELETED(cell))
				return
			var/reagent_name = params["reagent"]
			var/multiplier = floor(params["multiplier"] || 1)
			if(!recording_recipe)
				var/reagent = GLOB.name2reagent[reagent_name]
				if(beaker && dispensable_reagents.Find(reagent))
					var/datum/reagents/R = beaker.reagents
					var/free = R.maximum_volume - R.total_volume
					var/actual = min(amount * multiplier, (cell.charge * powerefficiency)*10, free)
					if(!cell.use(actual / powerefficiency))
						say("Not enough energy to complete operation!")
						return
					R.add_reagent(reagent, actual)

					work_animation()
			else
				recording_recipe[reagent_name] += amount
			. = TRUE
		if("remove")
			if(recording_recipe)
				return
			var/amount = text2num(params["amount"])
			if(beaker && (amount in beaker.possible_transfer_amounts))
				beaker.reagents.remove_all(amount)
				work_animation()
				. = TRUE
		if("dispense_recipe")
			if(QDELETED(cell))
				return
			var/list/chemicals_to_dispense = saved_recipes[params["recipe"]]
			if(!LAZYLEN(chemicals_to_dispense))
				return
			for(var/key in chemicals_to_dispense)
				var/reagent = GLOB.name2reagent[translate_legacy_chem_id(key)]
				var/dispense_amount = chemicals_to_dispense[key]
				if(!dispensable_reagents.Find(reagent))
					return
				if(!recording_recipe)
					if(!beaker)
						return
					var/datum/reagents/R = beaker.reagents
					var/free = R.maximum_volume - R.total_volume
					var/actual = min(dispense_amount, (cell.charge * powerefficiency)*10, free)
					if(actual)
						if(!cell.use(actual / powerefficiency))
							say("Not enough energy to complete operation!")
							return
						R.add_reagent(reagent, actual)
						work_animation()
				else
					recording_recipe[key] += dispense_amount
			. = TRUE
		if("delete_recipe")
			var/recipe_name = params["recipe"]
			if(!recipe_name || !saved_recipes[recipe_name])
				return
			saved_recipes -= recipe_name
			. = TRUE
		if("clear_all_recipes")
			saved_recipes.Cut()
			. = TRUE
		if("record_recipe")
			recording_recipe = list()
			. = TRUE
		if("save_recording")
			var/name = stripped_input(usr,"Name","What do you want to name this recipe?", "Recipe", MAX_NAME_LEN)
			if(!usr.canUseTopic(src, !issilicon(usr)))
				return
			if(saved_recipes[name] && alert("\"[name]\" already exists, do you want to overwrite it?",, "Yes", "No") != "Yes")
				return
			if(name && recording_recipe)
				for(var/reagent in recording_recipe)
					var/reagent_id = GLOB.name2reagent[translate_legacy_chem_id(reagent)]
					if(!dispensable_reagents.Find(reagent_id))
						visible_message(span_warning("[src] buzzes."), span_italics("You hear a faint buzz."))
						to_chat(usr, span_danger("[src] cannot find <b>[reagent]</b>!"))
						playsound(src, 'sound/machines/buzz-two.ogg', 50, 1)
						return
				saved_recipes[name] = recording_recipe
				recording_recipe = null
				. = TRUE
		if("cancel_recording")
			recording_recipe = null
			. = TRUE

/obj/machinery/chem_dispenser/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/chem_dispenser/attackby(obj/item/I, mob/living/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_appearance()
		return
	if(default_deconstruction_crowbar(I))
		return
	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		var/obj/item/reagent_containers/B = I
		. = TRUE //no afterattack
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, span_notice("You add [B] to [src]."))
		updateUsrDialog()
	else if(!user.combat_mode && !istype(I, /obj/item/card/emag) && !istype(I, /obj/item/stock_parts/cell))
		to_chat(user, span_warning("You can't load [I] into [src]!"))
		return ..()
	else
		return ..()

/obj/machinery/chem_dispenser/get_cell()
	return cell

/obj/machinery/chem_dispenser/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	var/list/datum/reagents/R = list()
	var/total = min(rand(7,15), FLOOR(cell.charge*powerefficiency, 1))
	var/datum/reagents/Q = new(total*10)
	if(beaker && beaker.reagents)
		R += beaker.reagents
	for(var/i in 1 to total)
		Q.add_reagent(pick(dispensable_reagents), 10)
	R += Q
	chem_splash(get_turf(src), 3, R)
	if(beaker?.reagents)
		beaker.reagents.remove_all()
	cell.use(total/powerefficiency)
	cell.emp_act(severity)
	work_animation()
	visible_message(span_danger("[src] malfunctions, spraying chemicals everywhere!"))

/obj/machinery/chem_dispenser/RefreshParts()
	recharge_amount = initial(recharge_amount)
	var/newpowereff = 0.0666666
	for(var/obj/item/stock_parts/cell/P in component_parts)
		cell = P
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		newpowereff += 0.0166666666*M.rating
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		recharge_amount *= C.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		if (M.rating > 3)
			dispensable_reagents |= upgrade_reagents
	powerefficiency = round(newpowereff, 0.01)

/obj/machinery/chem_dispenser/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(!user)
		return FALSE
	if(beaker)
		try_put_in_hand(beaker, user)
		beaker = null
		update_appearance()
	if(new_beaker)
		beaker = new_beaker
	update_appearance()
	return TRUE

/obj/machinery/chem_dispenser/on_deconstruction()
	cell = null
	if(beaker)
		beaker.forceMove(drop_location())
		beaker = null
	return ..()

/obj/machinery/chem_dispenser/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!can_interact(user) || !user.canUseTopic(src, !issilicon(user), FALSE, NO_TK))
		return
	replace_beaker(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/chem_dispenser/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/chem_dispenser/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/chem_dispenser/AltClick(mob/user)
	return ..() // This hotkey is BLACKLISTED since it's used by /datum/component/simple_rotation

/obj/machinery/chem_dispenser/drinks
	name = "soda dispenser"
	desc = "Contains a large reservoir of soft drinks."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "soda_dispenser"
	base_icon_state = "soda_dispenser"
	has_panel_overlay = FALSE
	amount = 10
	pixel_y = 6
	layer = WALL_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/chem_dispenser/drinks
	working_state = null
	nopower_state = null
	pass_flags = PASSTABLE
	dispensable_reagents = list(
		/datum/reagent/water,
		/datum/reagent/consumable/ice,
		/datum/reagent/consumable/coffee,
		/datum/reagent/consumable/cream,
		/datum/reagent/consumable/tea,
		/datum/reagent/consumable/icetea,
		/datum/reagent/consumable/space_cola,
		/datum/reagent/consumable/spacemountainwind,
		/datum/reagent/consumable/dr_gibb,
		/datum/reagent/consumable/space_up,
		/datum/reagent/consumable/tonic,
		/datum/reagent/consumable/sodawater,
		/datum/reagent/consumable/lemon_lime,
		/datum/reagent/consumable/pwr_game,
		/datum/reagent/consumable/shamblers,
		/datum/reagent/consumable/sugar,
		/datum/reagent/consumable/pineapplejuice,
		/datum/reagent/consumable/orangejuice,
		/datum/reagent/consumable/grenadine,
		/datum/reagent/consumable/limejuice,
		/datum/reagent/consumable/tomatojuice,
		/datum/reagent/consumable/lemonjuice,
		/datum/reagent/consumable/menthol
	)
	upgrade_reagents = null
	emagged_reagents = list(
		/datum/reagent/consumable/ethanol/thirteenloko,
		/datum/reagent/consumable/ethanol/whiskey_cola,
		/datum/reagent/toxin/mindbreaker,
		/datum/reagent/toxin/staminatoxin
	)
	default_filters = REACTION_TAG_DRINK | REACTION_TAG_FOOD

/obj/machinery/chem_dispenser/drinks/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation)

/obj/machinery/chem_dispenser/drinks/setDir()
	var/old = dir
	. = ..()
	if(dir != old)
		update_appearance()  // the beaker needs to be re-positioned if we rotate

/obj/machinery/chem_dispenser/drinks/display_beaker()
	var/mutable_appearance/b_o = beaker_overlay || mutable_appearance(icon, "disp_beaker")
	switch(dir)
		if(NORTH)
			b_o.pixel_y = 7
			b_o.pixel_x = rand(-9, 9)
		if(EAST)
			b_o.pixel_x = 4
			b_o.pixel_y = rand(-5, 7)
		if(WEST)
			b_o.pixel_x = -5
			b_o.pixel_y = rand(-5, 7)
		else//SOUTH
			b_o.pixel_y = -7
			b_o.pixel_x = rand(-9, 9)
	return b_o

/obj/machinery/chem_dispenser/drinks/fullupgrade //fully upgraded stock parts, emagged
	desc = "Contains a large reservoir of soft drinks. This model has had its safeties shorted out."
	obj_flags = CAN_BE_HIT | EMAGGED
	flags_1 = NODECONSTRUCT_1
	circuit = /obj/item/circuitboard/machine/chem_dispenser/drinks/fullupgrade

/obj/machinery/chem_dispenser/drinks/fullupgrade/Initialize(mapload)
	. = ..()
	dispensable_reagents |= emagged_reagents //adds emagged reagents

/obj/machinery/chem_dispenser/drinks/beer
	name = "booze dispenser"
	desc = "Contains a large reservoir of the good stuff."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "booze_dispenser"
	base_icon_state = "booze_dispenser"
	circuit = /obj/item/circuitboard/machine/chem_dispenser/drinks/beer
	dispensable_reagents = list(
		/datum/reagent/consumable/ethanol/beer,
		/datum/reagent/consumable/ethanol/kahlua,
		/datum/reagent/consumable/ethanol/whiskey,
		/datum/reagent/consumable/ethanol/wine,
		/datum/reagent/consumable/ethanol/vodka,
		/datum/reagent/consumable/ethanol/gin,
		/datum/reagent/consumable/ethanol/rum,
		/datum/reagent/consumable/ethanol/tequila,
		/datum/reagent/consumable/ethanol/vermouth,
		/datum/reagent/consumable/ethanol/cognac,
		/datum/reagent/consumable/ethanol/ale,
		/datum/reagent/consumable/ethanol/absinthe,
		/datum/reagent/consumable/ethanol/hcider,
		/datum/reagent/consumable/ethanol/creme_de_menthe,
		/datum/reagent/consumable/ethanol/creme_de_cacao,
		/datum/reagent/consumable/ethanol/creme_de_coconut,
		/datum/reagent/consumable/ethanol/triple_sec,
		/datum/reagent/consumable/ethanol/sake,
		/datum/reagent/consumable/ethanol/applejack
	)
	upgrade_reagents = null
	emagged_reagents = list(
		/datum/reagent/consumable/ethanol,
		/datum/reagent/iron,
		/datum/reagent/toxin/minttoxin,
		/datum/reagent/consumable/ethanol/atomicbomb,
		/datum/reagent/consumable/ethanol/fernet
	)
	default_filters = REACTION_TAG_DRINK | REACTION_TAG_FOOD

/obj/machinery/chem_dispenser/drinks/beer/fullupgrade //fully ugpraded stock parts, emagged
	desc = "Contains a large reservoir of the good stuff. This model has had its safeties shorted out."
	obj_flags = CAN_BE_HIT | EMAGGED
	flags_1 = NODECONSTRUCT_1
	circuit = /obj/item/circuitboard/machine/chem_dispenser/drinks/beer/fullupgrade

/obj/machinery/chem_dispenser/drinks/beer/fullupgrade/Initialize(mapload)
	. = ..()
	dispensable_reagents |= emagged_reagents //adds emagged reagents

/obj/machinery/chem_dispenser/mutagen
	name = "mutagen dispenser"
	desc = "Creates and dispenses mutagen."
	dispensable_reagents = list(/datum/reagent/toxin/mutagen)
	upgrade_reagents = null
	emagged_reagents = list(/datum/reagent/toxin/plasma)
	default_filters = REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT

/obj/machinery/chem_dispenser/mutagensaltpeter
	name = "botanical chemical dispenser"
	desc = "Creates and dispenses chemicals useful for botany."
	flags_1 = NODECONSTRUCT_1

	circuit = /obj/item/circuitboard/machine/chem_dispenser/mutagensaltpeter

	dispensable_reagents = list(
		/datum/reagent/toxin/mutagen,
		/datum/reagent/saltpetre,
		/datum/reagent/plantnutriment/eznutriment,
		/datum/reagent/plantnutriment/left4zednutriment,
		/datum/reagent/plantnutriment/robustharvestnutriment,
		/datum/reagent/water,
		/datum/reagent/toxin/plantbgone,
		/datum/reagent/toxin/plantbgone/weedkiller,
		/datum/reagent/toxin/pestkiller,
		/datum/reagent/medicine/cryoxadone,
		/datum/reagent/ammonia,
		/datum/reagent/ash,
		/datum/reagent/diethylamine)
	upgrade_reagents = null
	default_filters = REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT

/obj/machinery/chem_dispenser/mutagensaltpetersmall
	name = "minor botanical chemical dispenser"
	desc = "A botanical chemical dispenser on a budget."
	icon_state = "minidispenser"
	base_icon_state = "minidispenser"
	working_state = "minidispenser_working"
	nopower_state = "minidispenser_nopower"
	circuit = /obj/item/circuitboard/machine/chem_dispenser/botany
	dispensable_reagents = list(
		/datum/reagent/toxin/mutagen,
		/datum/reagent/saltpetre,
		/datum/reagent/water)
	upgrade_reagents = list(
		/datum/reagent/toxin/plantbgone,
		/datum/reagent/toxin/plantbgone/weedkiller,
		/datum/reagent/toxin/pestkiller,
		/datum/reagent/diethylamine)
	default_filters = REACTION_TAG_CHEMICAL | REACTION_TAG_PLANT

/obj/machinery/chem_dispenser/mutagensaltpetersmall/display_beaker()
	var/mutable_appearance/b_o = beaker_overlay || mutable_appearance(icon, "disp_beaker")
	b_o.pixel_y = -4
	b_o.pixel_x = -4
	return b_o

/obj/machinery/chem_dispenser/fullupgrade //fully ugpraded stock parts, emagged
	desc = "Creates and dispenses chemicals. This model has had its safeties shorted out."
	obj_flags = CAN_BE_HIT | EMAGGED
	flags_1 = NODECONSTRUCT_1
	circuit = /obj/item/circuitboard/machine/chem_dispenser/fullupgrade

/obj/machinery/chem_dispenser/fullupgrade/Initialize(mapload)
	. = ..()
	dispensable_reagents |= emagged_reagents //adds emagged reagents

/obj/machinery/chem_dispenser/abductor
	name = "reagent synthesizer"
	desc = "Synthesizes a variety of reagents using proto-matter."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "chem_dispenser"
	base_icon_state = "chem_dispenser"
	has_panel_overlay = FALSE
	circuit = /obj/item/circuitboard/machine/chem_dispenser/abductor
	working_state = null
	nopower_state = null
	dispensable_reagents = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/silver,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel,
		/datum/reagent/acetone,
		/datum/reagent/ammonia,
		/datum/reagent/ash,
		/datum/reagent/diethylamine,
		/datum/reagent/oil,
		/datum/reagent/saltpetre,
		/datum/reagent/medicine/mine_salve,
		/datum/reagent/medicine/morphine,
		/datum/reagent/drug/space_drugs,
		/datum/reagent/toxin,
		/datum/reagent/toxin/plasma,
		/datum/reagent/uranium,
		/datum/reagent/toxin/carpotoxin,
		/datum/reagent/medicine/rezadone,
		/datum/reagent/medicine/silibinin,
		/datum/reagent/medicine/polypyr
	)
