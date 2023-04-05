/obj/machinery/chem_master
	name = "ChemMaster 3000"
	desc = "Used to separate chemicals and distribute them in a variety of forms."
	density = TRUE
	layer = BELOW_OBJ_LAYER
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = FIRE_PROOF | ACID_PROOF
	circuit = /obj/item/circuitboard/machine/chem_master



	var/obj/item/reagent_containers/beaker = null
	var/obj/item/storage/pill_bottle/bottle = null
	var/mode = 1
	var/condi = FALSE
	var/chosen_pill_style = "pill_shape_capsule_purple_pink"
	var/chosen_patch_style = "bandaid_small_cross"
	var/screen = "home"
	var/analyzeVars[0]
	var/useramount = 30 // Last used amount
	var/static/list/pill_styles = list()
	var/static/list/patch_styles = list()

	// Persistent UI states
	var/saved_name_state = "Auto"
	var/saved_volume_state = "Auto"
	/// UNSANITIZED. DO NOT DISPLAY OUTSIDE TGUI WITHOUT HTML_ENCODE AND TRIM.
	var/saved_name = ""
	var/saved_volume = 10

/obj/machinery/chem_master/Initialize(mapload)
	create_reagents(100)

	//Calculate the span tags and ids fo all the available pill icons
	if(!length(pill_styles))
		for (var/each_pill_shape in PILL_SHAPE_LIST_WITH_DUMMY)
			var/list/style_list = list()
			style_list["id"] = each_pill_shape
			style_list["pill_icon_name"] = each_pill_shape
			pill_styles += list(style_list)
	if(!length(patch_styles))
		for (var/each_patch_shape in PATCH_SHAPE_LIST)
			var/list/style_list = list()
			style_list["id"] = each_patch_shape
			style_list["patch_icon_name"] = each_patch_shape
			patch_styles += list(style_list)

	. = ..()

/obj/machinery/chem_master/Destroy()
	QDEL_NULL(beaker)
	QDEL_NULL(bottle)
	return ..()

/obj/machinery/chem_master/RefreshParts()
	reagents.maximum_volume = 0
	for(var/obj/item/reagent_containers/glass/beaker/B in component_parts)
		reagents.maximum_volume += B.reagents.maximum_volume

/obj/machinery/chem_master/ex_act(severity, target)
	if(severity < 3)
		..()

/obj/machinery/chem_master/contents_explosion(severity, target)
	..()
	if(beaker)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += beaker
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += beaker
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += beaker
	if(bottle)
		switch(severity)
			if(EXPLODE_DEVASTATE)
				SSexplosions.high_mov_atom += bottle
			if(EXPLODE_HEAVY)
				SSexplosions.med_mov_atom += bottle
			if(EXPLODE_LIGHT)
				SSexplosions.low_mov_atom += bottle

/obj/machinery/chem_master/handle_atom_del(atom/A)
	..()
	if(A == beaker)
		beaker = null
		reagents.clear_reagents()
		update_icon()
		ui_update()
	else if(A == bottle)
		bottle = null
		ui_update()

/obj/machinery/chem_master/update_icon()
	cut_overlays()
	if (machine_stat & BROKEN)
		add_overlay("waitlight")
	if(beaker)
		icon_state = "mixer1"
	else
		icon_state = "mixer0"

/obj/machinery/chem_master/blob_act(obj/structure/blob/B)
	if (prob(50))
		qdel(src)

/obj/machinery/chem_master/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mixer0_nopower", "mixer0", I))
		return

	else if(default_deconstruction_crowbar(I))
		return

	if(default_unfasten_wrench(user, I))
		return
	if(istype(I, /obj/item/reagent_containers) && !(I.item_flags & ABSTRACT) && I.is_open_container())
		. = TRUE // no afterattack
		if(panel_open)
			to_chat(user, "<span class='warning'>You can't use the [src.name] while its panel is opened!</span>")
			return
		var/obj/item/reagent_containers/B = I
		. = TRUE // no afterattack
		if(!user.transferItemToLoc(B, src))
			return
		replace_beaker(user, B)
		to_chat(user, "<span class='notice'>You add [B] to [src].</span>")
		ui_update()
		update_icon()
	else if(!condi && istype(I, /obj/item/storage/pill_bottle))
		if(bottle)
			to_chat(user, "<span class='warning'>A pill bottle is already loaded into [src]!</span>")
			return
		if(!user.transferItemToLoc(I, src))
			return
		bottle = I
		to_chat(user, "<span class='notice'>You add [I] into the dispenser slot.</span>")
		ui_update()
	else
		return ..()

/obj/machinery/chem_master/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return
	replace_beaker(user)
	ui_update()
	return

/obj/machinery/chem_master/proc/replace_beaker(mob/living/user, obj/item/reagent_containers/new_beaker)
	if(beaker)
		beaker.forceMove(drop_location())
		if(user && Adjacent(user) && !issiliconoradminghost(user))
			user.put_in_hands(beaker)
	if(new_beaker)
		beaker = new_beaker
	else
		beaker = null
	update_icon()
	return TRUE

/obj/machinery/chem_master/on_deconstruction()
	replace_beaker()
	if(bottle)
		bottle.forceMove(drop_location())
		adjust_item_drop_location(bottle)
		bottle = null
	return ..()


/obj/machinery/chem_master/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/chem_master/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMaster")
		ui.open()

/obj/machinery/chem_master/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/medicine_containers)
	)

/obj/machinery/chem_master/ui_data(mob/user)
	var/list/data = list()
	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null
	data["mode"] = mode
	data["condi"] = condi
	data["screen"] = screen
	data["saved_name"] = saved_name
	data["saved_volume"] = saved_volume
	data["saved_name_state"] = saved_name_state
	data["saved_volume_state"] = saved_volume_state
	data["analyzeVars"] = analyzeVars
	data["chosen_pill_style"] = chosen_pill_style
	data["chosen_patch_style"] = chosen_patch_style
	data["isPillBottleLoaded"] = bottle ? 1 : 0
	if(bottle)
		var/datum/component/storage/STRB = bottle.GetComponent(/datum/component/storage)
		data["pillBottleCurrentAmount"] = bottle.contents.len
		data["pillBottleMaxAmount"] = STRB.max_items

	var/beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "id" = ckey(R.name), "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents

	var/bufferContents[0]
	if(reagents.total_volume)
		for(var/datum/reagent/N in reagents.reagent_list)
			bufferContents.Add(list(list("name" = N.name, "id" = ckey(N.name), "volume" = N.volume))) // ^
	data["bufferContents"] = bufferContents

	//Calculated at init time as it never changes
	data["pill_styles"] = pill_styles
	data["patch_styles"] = patch_styles
	return data

/obj/machinery/chem_master/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("setSavedNameState")
			var/state = params["name_state"]
			if(!state || (state != "Auto" && state != "Manual"))
				return
			saved_name_state = state
			. = TRUE
		if("setSavedName")
			var/name = trim(params["name"], MAX_NAME_LEN)
			if(!name)
				return
			if(CHAT_FILTER_CHECK(name))
				to_chat(usr, "<span class='warning'>ERROR: Packaging name contains prohibited word(s).</span>")
				return
			saved_name = name
			. = TRUE
		if("setSavedVolumeState")
			if(!params["volume_state"] || (params["volume_state"] != "Auto" && params["volume_state"] != "Exact"))
				return
			saved_volume_state = params["volume_state"]
			. = TRUE
		if("setSavedVolume")
			var/vol = text2num(params["volume"])
			if(!vol || vol < 0.01 || vol > 50)
				return
			saved_volume = vol
			. = TRUE
		if("eject")
			replace_beaker(usr)
			. = TRUE
		if("ejectPillBottle")
			if(!bottle)
				return
			bottle.forceMove(drop_location())
			adjust_item_drop_location(bottle)
			bottle = null
			. = TRUE
		if("transfer")
			if(!beaker)
				return
			var/reagent = GLOB.name2reagent[params["id"]]
			var/amount = text2num(params["amount"])
			var/to_container = params["to"]
			// Custom amount
			if (amount == -1)
				amount = text2num(input(
					"Enter the amount you want to transfer:",
					name, ""))
			if (amount == null || amount <= 0)
				return
			if (to_container == "buffer")
				beaker.reagents.trans_id_to(src, reagent, amount)
				. = TRUE
			else if (to_container == "beaker" && mode)
				reagents.trans_id_to(beaker, reagent, amount)
				. = TRUE
			else if (to_container == "beaker" && !mode)
				reagents.remove_reagent(reagent, amount)
				. = TRUE
		if("toggleMode")
			mode = !mode
			. = TRUE
		if("pillStyle")
			chosen_pill_style = "[params["id"]]"
			. = TRUE
		if("patchStyle")
			chosen_patch_style = "[params["id"]]"
			. = TRUE
		if("create")
			if(reagents.total_volume == 0)
				return
			var/item_type = params["type"]
			// Get amount of items
			var/amount = text2num(params["amount"])
			if(amount == null)
				amount = text2num(input(usr,
					"Max 10. Buffer content will be split evenly.",
					"How many to make?", 1))
			amount = clamp(round(amount), 0, 10)
			if (amount <= 0)
				return
			// Get units per item
			var/vol_each = text2num(params["volume"])
			var/vol_each_text = params["volume"]
			var/vol_each_max = reagents.total_volume / amount
			if (item_type == "pill" && !condi)
				vol_each_max = min(50, vol_each_max)
			else if (item_type == "patch" && !condi)
				vol_each_max = min(40, vol_each_max)
			else if (item_type == "bottle" && !condi)
				vol_each_max = min(30, vol_each_max)
			else if (item_type == "bag" && !condi)
				vol_each_max = min(200, vol_each_max)
			else if (item_type == "condimentPack" && condi)
				vol_each_max = min(10, vol_each_max)
			else if (item_type == "condimentBottle" && condi)
				vol_each_max = min(50, vol_each_max)
			else
				return
			if(vol_each_text == "auto")
				vol_each = vol_each_max
			if(vol_each == null)
				vol_each = text2num(input(usr,
					"Maximum [vol_each_max] units per item.",
					"How many units to fill?",
					vol_each_max))
			vol_each = clamp(vol_each, 0, vol_each_max)
			if(vol_each <= 0)
				return
			// Get item name
			var/name = params["name"]
			if(CHAT_FILTER_CHECK(name))
				to_chat(usr, "<span class='warning'>ERROR: Packaging name contains prohibited word(s).</span>")
				return
			if(name) // if we were passed a name from UI, html_encode it before adding to the world.
				name = trim(html_encode(name), MAX_NAME_LEN)
				if(!name) // our saved name was bad, clear it
					saved_name = ""
					return TRUE
			var/name_has_units = item_type == "pill" || item_type == "patch"
			if(!name)
				var/name_default = reagents.get_master_reagent_name()
				if (name_has_units)
					name_default += " ([vol_each]u)"
				name = stripped_input(usr,
					"Name:",
					"Give it a name!",
					name_default,
					MAX_NAME_LEN)
			if(!name || !reagents.total_volume || !src || QDELETED(src) || !usr.canUseTopic(src, !issilicon(usr)))
				return
			// Start filling
			switch(item_type)
				if("pill")
					var/obj/item/reagent_containers/pill/P
					var/target_loc = drop_location()
					var/drop_threshold = INFINITY
					if(bottle)
						var/datum/component/storage/STRB = bottle.GetComponent(
							/datum/component/storage)
						if(STRB)
							drop_threshold = STRB.max_items - bottle.contents.len
							target_loc = bottle
					for(var/i in 1 to amount)
						if(i-1 < drop_threshold)
							P = new/obj/item/reagent_containers/pill(target_loc)
						else
							P = new/obj/item/reagent_containers/pill(drop_location())
						P.name = trim("[name] pill")
						P.label_name = trim(name)
						if(chosen_pill_style == "pill_random_dummy")
							P.icon_state = pick(PILL_SHAPE_LIST)
						else
							P.icon_state = chosen_pill_style
						if(P.icon_state == "pill_shape_capsule_bloodred")
							P.desc = "A tablet or capsule, but not just any, a red one, one taken by the ones not scared of knowledge, freedom, uncertainty and the brutal truths of reality."
						adjust_item_drop_location(P)
						reagents.trans_to(P, vol_each, transfered_by = usr)
					. = TRUE
				if("patch")
					var/obj/item/reagent_containers/pill/patch/P
					for(var/i in 1 to amount)
						P = new/obj/item/reagent_containers/pill/patch(drop_location())
						P.name = trim("[name] patch")
						P.label_name = trim(name)
						P.icon_state = chosen_patch_style
						adjust_item_drop_location(P)
						reagents.trans_to(P, vol_each, transfered_by = usr)
					. = TRUE
				if("bottle")
					var/obj/item/reagent_containers/glass/bottle/P
					for(var/i in 1 to amount)
						P = new/obj/item/reagent_containers/glass/bottle(drop_location())
						P.name = trim("[name] bottle")
						P.label_name = trim(name)
						adjust_item_drop_location(P)
						reagents.trans_to(P, vol_each, transfered_by = usr)
					. = TRUE
				if("bag")
					var/obj/item/reagent_containers/chem_bag/P
					for(var/i in 1 to amount)
						P = new/obj/item/reagent_containers/chem_bag(drop_location())
						P.name = trim("[name] chemical bag")
						P.label_name = trim(name)
						adjust_item_drop_location(P)
						reagents.trans_to(P, vol_each, transfered_by = usr)
					. = TRUE
				if("condimentPack")
					var/obj/item/reagent_containers/food/condiment/pack/P
					for(var/i in 1 to amount)
						P = new/obj/item/reagent_containers/food/condiment/pack(drop_location())
						P.originalname = name
						P.name = trim("[name] pack")
						P.label_name = trim(name)
						P.desc = "A small condiment pack. The label says it contains [name]."
						reagents.trans_to(P, vol_each, transfered_by = usr)
					. = TRUE
				if("condimentBottle")
					var/obj/item/reagent_containers/food/condiment/P
					for(var/i in 1 to amount)
						P = new/obj/item/reagent_containers/food/condiment(drop_location())
						P.originalname = name
						P.name = trim("[name] bottle")
						P.label_name = trim(name)
						reagents.trans_to(P, vol_each, transfered_by = usr)
					. = TRUE
		if("analyze")
			var/datum/reagent/R = GLOB.name2reagent[params["id"]]
			if(R && reagents.get_reagent_amount(R))
				var/state = "Unknown"
				if(initial(R.reagent_state) == 1)
					state = "Solid"
				else if(initial(R.reagent_state) == 2)
					state = "Liquid"
				else if(initial(R.reagent_state) == 3)
					state = "Gas"
				var/const/P = 3 //The number of seconds between life ticks
				var/T = initial(R.metabolization_rate) * (60 / P)
				analyzeVars = list("name" = initial(R.name), "state" = state, "color" = initial(R.color), "description" = initial(R.description), "metaRate" = T, "overD" = initial(R.overdose_threshold), "addicD" = initial(R.addiction_threshold))
				screen = "analyze"
				. = TRUE
		if("goScreen")
			screen = params["screen"]
			. = TRUE


/obj/machinery/chem_master/proc/isgoodnumber(num)
	if(isnum_safe(num))
		if(num > 200)
			num = 200
		else if(num < 0)
			num = 0
		else
			num = round(num)
		return num
	else
		return 0


/obj/machinery/chem_master/adjust_item_drop_location(atom/movable/AM) // Special version for chemmasters and condimasters
	if (AM == beaker)
		AM.pixel_x = -8
		AM.pixel_y = 8
		return null
	else if (AM == bottle)
		if (length(bottle.contents))
			AM.pixel_x = -13
		else
			AM.pixel_x = -7
		AM.pixel_y = -8
		return null
	else
		var/md5 = rustg_hash_string(RUSTG_HASH_MD5, AM.name)
		for (var/i in 1 to 32)
			. += hex2num(md5[i])
		. = . % 9
		AM.pixel_x = ((.%3)*6)
		AM.pixel_y = -8 + (round( . / 3)*8)

/obj/machinery/chem_master/condimaster
	name = "CondiMaster 3000"
	desc = "Used to create condiments and other cooking supplies."
	condi = TRUE
