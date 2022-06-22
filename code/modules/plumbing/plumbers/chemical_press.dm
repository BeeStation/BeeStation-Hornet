///We take a constant input of reagents, and produce a pill once a set volume is reached
/obj/machinery/plumbing/chemical_press
	name = "chemical press"
	desc = "A press that makes pills, patches and bottles"
	icon_state = "pill_press"
	use_power = IDLE_POWER_USE
	layer = BELOW_OBJ_LAYER

	///maximum size of a pill
	var/max_pill_volume = 50
	///maximum size of a patch
	var/max_patch_volume = 40
	///maximum size of a bottle
	var/max_bottle_volume = 30
	///current operating product (pills or patches)
	var/product = "pill"
	///the minimum size a pill or patch can be
	var/min_volume = 5
	///the maximum size a pill or patch can be
	var/max_volume = 50
	///selected size of the product
	var/current_volume = 10
	///prefix for the product name
	var/product_name = "factory"
	///the icon_state number for the pill.
	var/pill_number = RANDOM_PILL_STYLE
	///list of id's and icons for the pill selection of the ui
	var/list/pill_styles
	/// Currently selected patch style
	var/patch_style = DEFAULT_PATCH_STYLE
	/// List of available patch styles for UI
	var/list/patch_styles
	///list of products stored in the machine, so we dont have 610 pills on one tile
	var/list/stored_products = list()
	///max amount of pills allowed on our tile before we start storing them instead
	var/max_floor_products = 10

	///Used for slowing transfer speed of items to smartfridge
	var/next_slowtransfer = 0
	///Is pill press actively transporting to nearby Smart Fridge?
	var/active_transfer_state = FALSE
	///Pill Press no power
	var/no_power_state = FALSE

/obj/machinery/plumbing/chemical_press/Destroy()
	. = ..()
	QDEL_LIST(stored_products)
	QDEL_LIST(contents)

/obj/machinery/plumbing/chemical_press/examine(mob/user)
	. = ..()
	. += span_infoplain("The [name] uses precision injection tools to fill a variety of bottles, pills, and even the microcapsules that align the patented NanoTrasen chemical delivery patches. And with the power of bluespace it can materialize the products into the nearest Nanotrasen brand Smart Chemical Storage Unit.")

/obj/machinery/plumbing/chemical_press/Initialize(mapload, bolt)
	. = ..()
	update_icon()
	AddComponent(/datum/component/plumbing/simple_demand, bolt)

	var/datum/asset/spritesheet/simple/assets = get_asset_datum(/datum/asset/spritesheet/simple/pills)
	pill_styles = list()
	for (var/x in 1 to PILL_STYLE_COUNT)
		var/list/SL = list()
		SL["id"] = x
		SL["class_name"] = assets.icon_class_name("pill[x]")
		pill_styles += list(SL)
	var/datum/asset/spritesheet/simple/patches_assets = get_asset_datum(/datum/asset/spritesheet/simple/patches)
	patch_styles = list()
	for (var/raw_patch_style in PATCH_STYLE_LIST)
		//adding class_name for use in UI
		var/list/patch_style = list()
		patch_style["style"] = raw_patch_style
		patch_style["class_name"] = patches_assets.icon_class_name(raw_patch_style)
		patch_styles += list(patch_style)

/obj/machinery/plumbing/chemical_press/process(delta_time)
	if(machine_stat & NOPOWER)
		active_transfer_state = FALSE
		no_power_state = TRUE
		update_icon()
		return

	no_power_state = FALSE
	if(next_slowtransfer < world.time) //Less processes needed to transfer or create products
		slow_production() //Produce and fill pills, patches, or bottles
		if(stored_products.len)
			slow_transfer() //Transfer to nearest SmartFridge
			use_power(active_power_usage * delta_time) //Lets use more of that power
		next_slowtransfer = world.time + 1 SECONDS //Set to wait for a second before processing again
		QDEL_LIST(contents) //So contents doesn't store insane amounts of product. No infinite magical contents allowed

/obj/machinery/plumbing/chemical_press/proc/slow_production()
	if(reagents.total_volume >= current_volume)
		if(product == "pill")
			var/obj/item/reagent_containers/pill/Pill = new(src)
			reagents.trans_to(Pill, current_volume)
			Pill.name = trim("[product_name] pill")
			stored_products += Pill
			if(pill_number == RANDOM_PILL_STYLE)
				Pill.icon_state = "pill[rand(1,21)]"
			else
				Pill.icon_state = "pill[pill_number]"
			if(Pill.icon_state == "pill4") //mirrored from chem masters
				Pill.desc = "A tablet or capsule, but not just any, a red one, one taken by the ones not scared of knowledge, freedom, uncertainty, and the brutal truths of reality."

		else if(product == "patch")
			var/obj/item/reagent_containers/pill/patch/Patch = new(src)
			reagents.trans_to(Patch, current_volume)
			Patch.name = trim("[product_name] patch")
			Patch.icon_state = patch_style
			stored_products += Patch

		else if(product == "bottle")
			var/obj/item/reagent_containers/glass/bottle/Bottle = new(src)
			reagents.trans_to(Bottle, current_volume)
			Bottle.name = trim("[product_name] bottle")
			stored_products += Bottle

/obj/machinery/plumbing/chemical_press/proc/slow_transfer()
	var/pill_amount = 0
	for(var/thing in loc) ///Keeping loc floor product logic in case others in the future have some clever plans
		if(!istype(thing, /obj/item/reagent_containers/glass/bottle) && !istype(thing, /obj/item/reagent_containers/pill))
			continue
		pill_amount++
		if(pill_amount >= max_floor_products) //too much so just stop
			break
	if(pill_amount < max_floor_products)
		var/atom/movable/AM = stored_products[1] //AM load product to chemfridge
		stored_products -= AM
		var/obj/machinery/smartfridge/chemistry/chem_fridge = locate(/obj/machinery/smartfridge/chemistry) in orange(4, src)
		if(!chem_fridge)
			active_transfer_state = FALSE
			update_icon()
			return
		if(chem_fridge.contents.len >= chem_fridge.max_n_of_items)
			active_transfer_state = FALSE
			update_icon()
			return
		if(chem_fridge.accept_check(AM))
			active_transfer_state = TRUE
			chem_fridge.load(AM)
			update_icon()
			playsound(src, 'sound/items/pshoom.ogg', 15, 10)
			src.Beam(chem_fridge.loc, icon_state="item_transfer", time=4)


/obj/machinery/plumbing/chemical_press/update_icon()
	. = ..()
	if(active_transfer_state)
		icon_state = initial(icon_state) + "-on"
		return
	if(no_power_state)
		icon_state = initial(icon_state) + "-off"
		return
	else
		icon_state = initial(icon_state) //Default Idle State

/obj/machinery/plumbing/chemical_press/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/pills),
		get_asset_datum(/datum/asset/spritesheet/simple/patches),
	)

/obj/machinery/plumbing/chemical_press/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemPress", name)
		ui.open()

/obj/machinery/plumbing/chemical_press/ui_data(mob/user)
	var/list/data = list()
	data["pill_style"] = pill_number
	data["current_volume"] = current_volume
	data["product_name"] = product_name
	data["pill_styles"] = pill_styles
	data["product"] = product
	data["min_volume"] = min_volume
	data["max_volume"] = max_volume
	data["patch_style"] = patch_style
	data["patch_styles"] = patch_styles
	return data

/obj/machinery/plumbing/chemical_press/ui_act(action, params)
	. = ..()
	if(.)
		return
	. = TRUE
	switch(action)
		if("change_pill_style")
			pill_number = clamp(text2num(params["id"]), 1 , PILL_STYLE_COUNT)
		if("change_current_volume")
			current_volume = clamp(text2num(params["volume"]), min_volume, max_volume)
		if("change_product_name")
			product_name = html_encode(params["name"])
		if("change_product")
			product = params["product"]
			if (product == "pill")
				max_volume = max_pill_volume
			else if (product == "patch")
				max_volume = max_patch_volume
			else if (product == "bottle")
				max_volume = max_bottle_volume
			current_volume = clamp(current_volume, min_volume, max_volume)
		if("change_patch_style")
			patch_style = params["patch_style"]
