#define GLOW_MODE 3
#define LIGHT_MODE 2
#define REMOVE_MODE 1

/*
CONTAINS:
RCD
ARCD
RLD
*/

/obj/item/construction
	name = "not for ingame use"
	desc = "A device used to rapidly build and deconstruct. Reload with iron, plasteel, glass or compressed matter cartridges."
	opacity = FALSE
	density = FALSE
	anchored = FALSE
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	force = 0
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_LARGE
	custom_materials = list(/datum/material/iron=100000)
	req_access_txt = "11"
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50, STAMINA = 0)
	resistance_flags = FIRE_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 100
	var/no_ammo_message = "<span class='warning'>The \'Low Ammo\' light on the device blinks yellow.</span>"
	var/has_ammobar = FALSE	//controls whether or not does update_icon apply ammo indicator overlays
	var/ammo_sections = 10	//amount of divisions in the ammo indicator overlay/number of ammo indicator states
	/// Bitflags for upgrades
	var/upgrade = NONE
	/// Bitflags for banned upgrades
	var/banned_upgrades = NONE
	var/datum/component/remote_materials/silo_mats //remote connection to the silo
	var/silo_link = FALSE //switch to use internal or remote storage

/obj/item/construction/Initialize(mapload)
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)
	if(upgrade & RCD_UPGRADE_SILO_LINK)
		silo_mats = AddComponent(/datum/component/remote_materials, "RCD", FALSE)

/obj/item/construction/examine(mob/user)
	. = ..()
	. += "\A [src]. It currently holds [matter]/[max_matter] matter-units."
	if(upgrade & RCD_UPGRADE_SILO_LINK)
		. += "\A [src]. Remote storage link state: [silo_link ? "[silo_mats.on_hold() ? "ON HOLD" : "ON"]" : "OFF"]."
		if(silo_link && !silo_mats.on_hold() && silo_mats.mat_container)
			. += "\A [src]. Remote connection have iron in equivalent to [silo_mats.mat_container.get_material_amount(/datum/material/iron)/500] rcd units." // 1 matter for 1 floortile, as 4 tiles are produced from 1 iron

/obj/item/construction/Destroy()
	QDEL_NULL(spark_system)
	silo_mats = null
	return ..()

/obj/item/construction/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/rcd_upgrade))
		install_upgrade(W, user)
		return TRUE
	if(insert_matter(W, user))
		return TRUE
	return ..()

/// Installs an upgrade into the RCD checking if it is already installed, or if it is a banned upgrade
/obj/item/construction/proc/install_upgrade(obj/item/rcd_upgrade/rcd_up, mob/user)
	if(rcd_up.upgrade & upgrade)
		to_chat(user, "<span class='warning'>[src] has already installed this upgrade!</span>")
		return
	if(rcd_up.upgrade & banned_upgrades)
		to_chat(user, "<span class='warning'>[src] can't install this upgrade!</span>")
		return
	upgrade |= rcd_up.upgrade
	if((rcd_up.upgrade & RCD_UPGRADE_SILO_LINK) && !silo_mats)
		silo_mats = AddComponent(/datum/component/remote_materials, "RCD", FALSE, FALSE)
	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	qdel(rcd_up)

/// Inserts matter into the RCD allowing it to build
/obj/item/construction/proc/insert_matter(obj/O, mob/user)
	if(iscyborg(user))
		return FALSE
	var/loaded = FALSE
	if(istype(O, /obj/item/rcd_ammo))
		var/obj/item/rcd_ammo/R = O
		var/load = min(R.ammoamt, max_matter - matter)
		if(load <= 0)
			to_chat(user, "<span class='warning'>[src] can't hold any more matter-units!</span>")
			return FALSE
		R.ammoamt -= load
		if(R.ammoamt <= 0)
			qdel(R)
		matter += load
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		loaded = TRUE
	else if(istype(O, /obj/item/stack))
		loaded = loadwithsheets(O, user)
	if(loaded)
		to_chat(user, "<span class='notice'>[src] now holds [matter]/[max_matter] matter-units.</span>")
		update_appearance() //ensures that ammo counters (if present) get updated
	return loaded

/obj/item/construction/proc/loadwithsheets(obj/item/stack/loaded_stack, mob/user)
	var/value = loaded_stack.matter_amount
	if(value <= 0)
		to_chat(user, "<span class='notice'>You can't insert [loaded_stack.name] into [src]!</span>")
		return FALSE
	var/maxsheets = round((max_matter-matter)/value)    //calculate the max number of sheets that will fit in RCD
	if(maxsheets > 0)
		var/amount_to_use = min(loaded_stack.amount, maxsheets)
		loaded_stack.use(amount_to_use)
		matter += value*amount_to_use
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		to_chat(user, "<span class='notice'>You insert [amount_to_use] [loaded_stack.name] sheets into [src]. </span>")
		return TRUE
	to_chat(user, "<span class='warning'>You can't insert any more [loaded_stack.name] sheets into [src]!</span>")
	return FALSE

/obj/item/construction/proc/activate()
	playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)

/obj/item/construction/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	if(prob(20))
		spark_system.start()

/obj/item/construction/proc/useResource(amount, mob/user)
	if(!silo_mats || !silo_link)
		if(matter < amount)
			if(user)
				to_chat(user, no_ammo_message)
			return FALSE
		matter -= amount
		update_icon()
		return TRUE
	else
		var/list/matlist = list(SSmaterials.GetMaterialRef(/datum/material/iron) = 500)
		if(silo_mats.on_hold())
			if(user)
				to_chat(user, "Mineral access is on hold, please contact the quartermaster.")
			return FALSE
		if(!silo_mats.mat_container?.has_materials(matlist, amount))
			if(user)
				to_chat(user, no_ammo_message)
			return FALSE

		silo_mats.mat_container.use_materials(matlist, amount)
		silo_mats.silo_log(src, "consume", -amount, "build", matlist)
		return TRUE

/obj/item/construction/proc/checkResource(amount, mob/user)
	if(!silo_mats || !silo_link)
		. = matter >= amount
	else
		if(silo_mats.on_hold())
			if(user)
				to_chat(user, "Mineral access is on hold, please contact the quartermaster.")
			return FALSE
		. = silo_mats.mat_container?.has_materials(list(SSmaterials.GetMaterialRef(/datum/material/iron) = 500), amount)
	if(!. && user)
		to_chat(user, no_ammo_message)
		if(has_ammobar)
			flick("[icon_state]_empty", src)	//somewhat hacky thing to make RCDs with ammo counters actually have a blinking yellow light
	return .

/obj/item/construction/proc/range_check(atom/A, mob/user)
	if(A.z != user.z)
		return
	if(!(user in viewers(7, get_turf(A))) && !(max_matter == INFINITY)) // debug tool has no max range
		to_chat(user, "<span class='warning'>The \'Out of Range\' light on [src] blinks red.</span>")
		return FALSE
	else
		return TRUE

/obj/item/construction/proc/prox_check(proximity)
	if(proximity)
		return TRUE
	else
		return FALSE

/obj/item/construction/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/construction/rcd
	name = "rapid-construction-device (RCD)"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_price = 150
	max_matter = 160
	slot_flags = ITEM_SLOT_BELT
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	has_ammobar = TRUE
	var/mode = RCD_FLOORWALL
	var/ranged = FALSE
	var/computer_dir = 1
	var/airlock_type = /obj/machinery/door/airlock
	var/airlock_glass = FALSE // So the floor's rcd_act knows how much ammo to use
	var/window_type = /obj/structure/window/fulltile
	var/window_glass = RCD_WINDOW_NORMAL
	var/window_size = RCD_WINDOW_FULLTILE
	var/furnish_type = /obj/structure/chair
	var/furnish_cost = 8
	var/furnish_delay = 10
	var/advanced_airlock_setting = 1 //Set to 1 if you want more paintjobs available
	var/delay_mod = 1
	var/canRturf = FALSE //Variable for R walls to deconstruct them
	/// Integrated airlock electronics for setting access to a newly built airlocks
	var/obj/item/electronics/airlock/airlock_electronics

/obj/item/construction/rcd/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] sets the RCD to 'Wall' and points it down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide..</span>")
	return BRUTELOSS

/obj/item/construction/rcd/verb/toggle_window_glass_verb()
	set name = "RCD : Toggle Window Glass"
	set category = "Object"
	set src in view(1)

	if(!usr.canUseTopic(src, BE_CLOSE))
		return

	toggle_window_glass(usr)

/obj/item/construction/rcd/verb/toggle_window_size_verb()
	set name = "RCD : Toggle Window Size"
	set category = "Object"
	set src in view(1)

	if(!usr.canUseTopic(src, BE_CLOSE))
		return

	toggle_window_size(usr)

/// Toggles the usage of reinforced or normal glass
/obj/item/construction/rcd/proc/toggle_window_glass(mob/user)
	if (window_glass != RCD_WINDOW_REINFORCED)
		set_window_type(user, RCD_WINDOW_REINFORCED, window_size)
		return
	set_window_type(user, RCD_WINDOW_NORMAL, window_size)

/// Toggles the usage of directional or full tile windows
/obj/item/construction/rcd/proc/toggle_window_size(mob/user)
	if (window_size != RCD_WINDOW_DIRECTIONAL)
		set_window_type(user, window_glass, RCD_WINDOW_DIRECTIONAL)
		return
	set_window_type(user, window_glass, RCD_WINDOW_FULLTILE)

/// Sets the window type to be created based on parameters
/obj/item/construction/rcd/proc/set_window_type(mob/user, glass, size)
	window_glass = glass
	window_size = size
	if(window_glass == RCD_WINDOW_REINFORCED)
		if(window_size == RCD_WINDOW_DIRECTIONAL)
			window_type = /obj/structure/window/reinforced
		else
			window_type = /obj/structure/window/reinforced/fulltile
	else
		if(window_size == RCD_WINDOW_DIRECTIONAL)
			window_type = /obj/structure/window
		else
			window_type = /obj/structure/window/fulltile

	to_chat(user, "<span class='notice'>You change \the [src]'s window mode to [window_size] [window_glass] window.</span>")

/obj/item/construction/rcd/proc/toggle_silo_link(mob/user)
	if(silo_mats)
		silo_link = !silo_link
		to_chat(user, "<span class='notice'>You change \the [src]'s storage link state: [silo_link ? "ON" : "OFF"].</span>")
	else
		to_chat(user, "<span class='warning'>\the [src] doesn't have remote storage connection.</span>")

/obj/item/construction/rcd/proc/get_airlock_image(airlock_type)
	var/obj/machinery/door/airlock/proto = airlock_type
	var/ic = initial(proto.icon)
	var/mutable_appearance/MA = mutable_appearance(ic, "closed")
	if(!initial(proto.glass))
		MA.overlays += "fill_closed"
	//Not scaling these down to button size because they look horrible then, instead just bumping up radius.
	return MA

/obj/item/construction/rcd/proc/change_computer_dir(mob/user)
	if(!user)
		return
	var/list/computer_dirs = list(
		"NORTH" = image(icon = 'icons/mob/radial.dmi', icon_state = "cnorth"),
		"EAST" = image(icon = 'icons/mob/radial.dmi', icon_state = "ceast"),
		"SOUTH" = image(icon = 'icons/mob/radial.dmi', icon_state = "csouth"),
		"WEST" = image(icon = 'icons/mob/radial.dmi', icon_state = "cwest")
		)
	var/computerdirs = show_radial_menu(user, src, computer_dirs, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(computerdirs)
		if("NORTH")
			computer_dir = 1
		if("EAST")
			computer_dir = 4
		if("SOUTH")
			computer_dir = 2
		if("WEST")
			computer_dir = 8

/obj/item/construction/rcd/proc/change_airlock_setting(mob/user)
	if(!user)
		return

	var/list/solid_or_glass_choices = list(
		"Solid" = get_airlock_image(/obj/machinery/door/airlock),
		"Glass" = get_airlock_image(/obj/machinery/door/airlock/glass),
		"Windoor" = image(icon = 'icons/mob/radial.dmi', icon_state = "windoor"),
		"Secure Windoor" = image(icon = 'icons/mob/radial.dmi', icon_state = "secure_windoor")
	)

	var/list/solid_choices = list(
		"Standard" = get_airlock_image(/obj/machinery/door/airlock),
		"Public" = get_airlock_image(/obj/machinery/door/airlock/public),
		"Engineering" = get_airlock_image(/obj/machinery/door/airlock/engineering),
		"Atmospherics" = get_airlock_image(/obj/machinery/door/airlock/atmos),
		"Security" = get_airlock_image(/obj/machinery/door/airlock/security),
		"Command" = get_airlock_image(/obj/machinery/door/airlock/command),
		"Medical" = get_airlock_image(/obj/machinery/door/airlock/medical),
		"Research" = get_airlock_image(/obj/machinery/door/airlock/research),
		"Freezer" = get_airlock_image(/obj/machinery/door/airlock/freezer),
		"Science" = get_airlock_image(/obj/machinery/door/airlock/science),
		"Virology" = get_airlock_image(/obj/machinery/door/airlock/virology),
		"Mining" = get_airlock_image(/obj/machinery/door/airlock/mining),
		"Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance),
		"External" = get_airlock_image(/obj/machinery/door/airlock/external),
		"External Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance/external),
		"Airtight Hatch" = get_airlock_image(/obj/machinery/door/airlock/hatch),
		"Maintenance Hatch" = get_airlock_image(/obj/machinery/door/airlock/maintenance_hatch)
	)

	var/list/glass_choices = list(
		"Standard" = get_airlock_image(/obj/machinery/door/airlock/glass),
		"Public" = get_airlock_image(/obj/machinery/door/airlock/public/glass),
		"Engineering" = get_airlock_image(/obj/machinery/door/airlock/engineering/glass),
		"Atmospherics" = get_airlock_image(/obj/machinery/door/airlock/atmos/glass),
		"Security" = get_airlock_image(/obj/machinery/door/airlock/security/glass),
		"Command" = get_airlock_image(/obj/machinery/door/airlock/command/glass),
		"Medical" = get_airlock_image(/obj/machinery/door/airlock/medical/glass),
		"Research" = get_airlock_image(/obj/machinery/door/airlock/research/glass),
		"Science" = get_airlock_image(/obj/machinery/door/airlock/science/glass),
		"Virology" = get_airlock_image(/obj/machinery/door/airlock/virology/glass),
		"Mining" = get_airlock_image(/obj/machinery/door/airlock/mining/glass),
		"Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance/glass),
		"External" = get_airlock_image(/obj/machinery/door/airlock/external/glass),
		"External Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance/external/glass)
	)

	var/airlockcat = show_radial_menu(user, src, solid_or_glass_choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(airlockcat)
		if("Solid")
			if(advanced_airlock_setting == 1)
				var/airlockpaint = show_radial_menu(user, src, solid_choices, radius = 42, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
				if(!check_menu(user))
					return
				switch(airlockpaint)
					if("Standard")
						airlock_type = /obj/machinery/door/airlock
					if("Public")
						airlock_type = /obj/machinery/door/airlock/public
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/engineering
					if("Atmospherics")
						airlock_type = /obj/machinery/door/airlock/atmos
					if("Security")
						airlock_type = /obj/machinery/door/airlock/security
					if("Command")
						airlock_type = /obj/machinery/door/airlock/command
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/medical
					if("Research")
						airlock_type = /obj/machinery/door/airlock/research
					if("Freezer")
						airlock_type = /obj/machinery/door/airlock/freezer
					if("Science")
						airlock_type = /obj/machinery/door/airlock/science
					if("Virology")
						airlock_type = /obj/machinery/door/airlock/virology
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/mining
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance
					if("External")
						airlock_type = /obj/machinery/door/airlock/external
					if("External Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance/external
					if("Airtight Hatch")
						airlock_type = /obj/machinery/door/airlock/hatch
					if("Maintenance Hatch")
						airlock_type = /obj/machinery/door/airlock/maintenance_hatch
				airlock_glass = FALSE
			else
				airlock_type = /obj/machinery/door/airlock
				airlock_glass = FALSE

		if("Glass")
			if(advanced_airlock_setting == 1)
				var/airlockpaint = show_radial_menu(user, src , glass_choices, radius = 42, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
				if(!check_menu(user))
					return
				switch(airlockpaint)
					if("Standard")
						airlock_type = /obj/machinery/door/airlock/glass
					if("Public")
						airlock_type = /obj/machinery/door/airlock/public/glass
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/engineering/glass
					if("Atmospherics")
						airlock_type = /obj/machinery/door/airlock/atmos/glass
					if("Security")
						airlock_type = /obj/machinery/door/airlock/security/glass
					if("Command")
						airlock_type = /obj/machinery/door/airlock/command/glass
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/medical/glass
					if("Research")
						airlock_type = /obj/machinery/door/airlock/research/glass
					if("Science")
						airlock_type = /obj/machinery/door/airlock/science/glass
					if("Virology")
						airlock_type = /obj/machinery/door/airlock/virology/glass
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/mining/glass
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance/glass
					if("External")
						airlock_type = /obj/machinery/door/airlock/external/glass
					if("External Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance/external/glass
				airlock_glass = TRUE
			else
				airlock_type = /obj/machinery/door/airlock/glass
				airlock_glass = TRUE
		if("Windoor")
			airlock_type = /obj/machinery/door/window
			airlock_glass = TRUE
		if("Secure Windoor")
			airlock_type = /obj/machinery/door/window/brigdoor
			airlock_glass = TRUE
		else
			airlock_type = /obj/machinery/door/airlock
			airlock_glass = FALSE

/// Radial menu for choosing the object you want to be created with the furnishing mode
/obj/item/construction/rcd/proc/change_furnishing_type(mob/user)
	if(!user)
		return
	var/static/list/choices = list(
		"Chair" = image(icon = 'icons/mob/radial.dmi', icon_state = "chair"),
		"Stool" = image(icon = 'icons/mob/radial.dmi', icon_state = "stool"),
		"Table" = image(icon = 'icons/mob/radial.dmi', icon_state = "table"),
		"Glass Table" = image(icon = 'icons/mob/radial.dmi', icon_state = "glass_table")
		)
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(choice)
		if("Chair")
			furnish_type = /obj/structure/chair
			furnish_cost = 8
			furnish_delay = 10
		if("Stool")
			furnish_type = /obj/structure/chair/stool
			furnish_cost = 8
			furnish_delay = 10
		if("Table")
			furnish_type = /obj/structure/table
			furnish_cost = 16
			furnish_delay = 20
		if("Glass Table")
			furnish_type = /obj/structure/table/glass
			furnish_cost = 16
			furnish_delay = 20

/obj/item/construction/rcd/proc/rcd_create(atom/A, mob/user)
	var/list/rcd_results = A.rcd_vals(user, src)
	if(!rcd_results)
		return FALSE
	var/delay = rcd_results["delay"] * delay_mod
	var/obj/effect/constructing_effect/rcd_effect = new(get_turf(A), delay, src.mode)
	if(checkResource(rcd_results["cost"], user))
		if(do_after(user, delay, target = A))
			if(checkResource(rcd_results["cost"], user))
				if(A.rcd_act(user, src, rcd_results["mode"]))
					rcd_effect.end_animation()
					useResource(rcd_results["cost"], user)
					activate()
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					return TRUE
	qdel(rcd_effect)

/obj/item/construction/rcd/Initialize(mapload)
	. = ..()
	airlock_electronics = new(src)
	airlock_electronics.name = "Access Control"
	airlock_electronics.holder = src
	GLOB.rcd_list += src
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/construction/rcd/Destroy()
	QDEL_NULL(airlock_electronics)
	GLOB.rcd_list -= src
	. = ..()

/obj/item/construction/rcd/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		mode = RCD_FLOORWALL
		rcd_create(target, user)

/obj/item/construction/rcd/attack_self(mob/user)
	..()
	var/list/choices = list(
		"Airlock" = image(icon = 'icons/mob/radial.dmi', icon_state = "airlock"),
		"Deconstruct" = image(icon= 'icons/mob/radial.dmi', icon_state = "delete"),
		"Grilles & Windows" = image(icon = 'icons/mob/radial.dmi', icon_state = "grillewindow"),
		"Floors & Walls" = image(icon = 'icons/mob/radial.dmi', icon_state = "wallfloor")
	)
	if(upgrade & RCD_UPGRADE_FRAMES)
		choices += list(
		"Machine Frames" = image(icon = 'icons/mob/radial.dmi', icon_state = "machine"),
		"Computer Frames" = image(icon = 'icons/mob/radial.dmi', icon_state = "computer_dir"),
		"Ladders" = image(icon = 'icons/mob/radial.dmi', icon_state = "ladder")
		)
	if(upgrade & RCD_UPGRADE_SILO_LINK)
		choices += list(
		"Silo Link" = image(icon = 'icons/obj/mining.dmi', icon_state = "silo"),
		)
	if(upgrade & RCD_UPGRADE_FURNISHING)
		choices += list(
		"Furnishing" = image(icon = 'icons/mob/radial.dmi', icon_state = "chair")
		)
	if(mode == RCD_AIRLOCK)
		choices += list(
		"Change Access" = image(icon = 'icons/mob/radial.dmi', icon_state = "access"),
		"Change Airlock Type" = image(icon = 'icons/mob/radial.dmi', icon_state = "airlocktype")
		)
	else if(mode == RCD_WINDOWGRILLE)
		choices += list(
		"Change Window Glass" = image(icon = 'icons/mob/radial.dmi', icon_state = "windowtype"),
		"Change Window Size" = image(icon = 'icons/mob/radial.dmi', icon_state = "windowsize")
		)
	else if(mode == RCD_FURNISHING)
		choices += list(
		"Change Furnishing Type" = image(icon = 'icons/mob/radial.dmi', icon_state = "chair")
		)
	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(choice)
		if("Floors & Walls")
			mode = RCD_FLOORWALL
		if("Airlock")
			mode = RCD_AIRLOCK
		if("Deconstruct")
			mode = RCD_DECONSTRUCT
		if("Grilles & Windows")
			mode = RCD_WINDOWGRILLE
		if("Machine Frames")
			mode = RCD_MACHINE
		if("Furnishing")
			mode = RCD_FURNISHING
		if("Computer Frames")
			mode = RCD_COMPUTER
			change_computer_dir(user)
		if("Ladders")
			mode = RCD_LADDER
			return
		if("Change Access")
			airlock_electronics.ui_interact(user)
			return
		if("Change Airlock Type")
			change_airlock_setting(user)
			return
		if("Change Window Glass")
			toggle_window_glass(user)
			return
		if("Change Window Size")
			toggle_window_size(user)
			return
		if("Change Furnishing Type")
			change_furnishing_type(user)
			return
		if("Silo Link")
			toggle_silo_link(user)
			return
		else
			return
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)
	to_chat(user, "<span class='notice'>You change RCD's mode to '[choice]'.</span>")

/obj/item/construction/rcd/proc/target_check(atom/A, mob/user) // only returns true for stuff the device can actually work with
	if((isturf(A) && A.density && mode==RCD_DECONSTRUCT) || (isturf(A) && !A.density) || (istype(A, /obj/machinery/door/airlock) && mode==RCD_DECONSTRUCT) || istype(A, /obj/structure/grille) || (istype(A, /obj/structure/window) && mode==RCD_DECONSTRUCT) || istype(A, /obj/structure/girder || istype(A, /obj/structure/ladder)))
		return TRUE
	else
		return FALSE

/obj/item/construction/rcd/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!prox_check(proximity))
		return
	rcd_create(A, user)

/obj/item/construction/rcd/proc/detonate_pulse()
	audible_message("<span class='danger'><b>[src] begins to vibrate and \
		buzz loudly!</b></span>","<span class='danger'><b>[src] begins \
		vibrating violently!</b></span>")
	// 5 seconds to get rid of it
	addtimer(CALLBACK(src, PROC_REF(detonate_pulse_explode)), 50)

/obj/item/construction/rcd/proc/detonate_pulse_explode()
	explosion(src, 0, 0, 3, 1, flame_range = 1)
	qdel(src)

/obj/item/construction/rcd/update_overlays()
	. = ..()
	if(has_ammobar)
		var/ratio = CEILING((matter / max_matter) * ammo_sections, 1)
		. += "[icon_state]_charge[ratio]"

/obj/item/construction/rcd/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/construction/rcd/borg
	no_ammo_message = "<span class='warning'>Insufficient charge.</span>"
	desc = "A device used to rapidly build walls and floors."
	canRturf = TRUE
	banned_upgrades = RCD_UPGRADE_SILO_LINK
	var/energyfactor = 72


/obj/item/construction/rcd/borg/useResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.use(amount * energyfactor) //borgs get 1.3x the use of their RCDs
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/construction/rcd/borg/checkResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.charge >= (amount * energyfactor)
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/construction/rcd/borg/syndicate
	icon_state = "ircd"
	item_state = "ircd"
	energyfactor = 66

/obj/item/construction/rcd/loaded
	matter = 160

/obj/item/construction/rcd/combat
	name = "industrial RCD"
	icon_state = "ircd"
	item_state = "ircd"
	max_matter = 500
	matter = 500
	canRturf = TRUE
	item_flags = ISWEAPON

/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	w_class = WEIGHT_CLASS_TINY
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_materials = list(/datum/material/iron=12000, /datum/material/glass=8000)
	var/ammoamt = 40

/obj/item/rcd_ammo/large
	custom_materials = list(/datum/material/iron=48000, /datum/material/glass=32000)
	ammoamt = 160


// Ranged RCD
/obj/item/construction/rcd/arcd
	name = "advanced rapid-construction-device (ARCD)"
	desc = "A prototype RCD with ranged capability and extended capacity. Reload with iron, plasteel, glass or compressed matter cartridges."
	max_matter = 300
	matter = 300
	delay_mod = 0.6
	ranged = TRUE
	icon_state = "arcd"
	item_state = "oldrcd"
	has_ammobar = FALSE

/obj/item/construction/rcd/arcd/afterattack(atom/A, mob/user)
	. = ..()
	if(!range_check(A,user))
		return
	if(target_check(A,user))
		user.Beam(A,icon_state="rped_upgrade", time = delay_mod * 5 SECONDS) //5 SECONDS * 0.6 = 3 seconds
	rcd_create(A,user)

/obj/item/construction/rcd/arcd/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	if(ranged && range_check(target, user))
		mode = RCD_FLOORWALL
		rcd_create(target, user)

// RAPID LIGHTING DEVICE
/obj/item/construction/rld
	name = "Rapid Lighting Device (RLD)"
	desc = "A device used to rapidly provide lighting sources to an area. Reload with iron, plasteel, glass or compressed matter cartridges."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rld-5"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	matter = 200
	max_matter = 200
	var/mode = LIGHT_MODE
	slot_flags = ITEM_SLOT_BELT
	actions_types = list(/datum/action/item_action/pick_color)

	var/wallcost = 10
	var/floorcost = 15
	var/launchcost = 5
	var/deconcost = 10

	var/walldelay = 10
	var/floordelay = 10
	var/decondelay = 15

	var/color_choice = null


/obj/item/construction/rld/ui_action_click(mob/user, var/datum/action/A)
	if(istype(A, /datum/action/item_action/pick_color))
		color_choice = tgui_color_picker(user,"","Choose Color",color_choice)
	else
		..()

/obj/item/construction/rld/update_icon_state()
	// "infinite matter/35" from a debug tool will give a big number, but "rld-5" is the maximum
	icon_state = "rld-[min(round(matter/35), 5)]"
	return ..()

/obj/item/construction/rld/attack_self(mob/user)
	..()
	switch(mode)
		if(REMOVE_MODE)
			mode = LIGHT_MODE
			to_chat(user, "<span class='notice'>You change RLD's mode to 'Permanent Light Construction'.</span>")
		if(LIGHT_MODE)
			mode = GLOW_MODE
			to_chat(user, "<span class='notice'>You change RLD's mode to 'Light Launcher'.</span>")
		if(GLOW_MODE)
			mode = REMOVE_MODE
			to_chat(user, "<span class='notice'>You change RLD's mode to 'Deconstruct'.</span>")


/obj/item/construction/rld/proc/checkdupes(var/target)
	. = list()
	var/turf/checking = get_turf(target)
	for(var/obj/machinery/light/dupe in checking)
		if(istype(dupe, /obj/machinery/light))
			. |= dupe


/obj/item/construction/rld/afterattack(atom/A, mob/user)
	. = ..()
	if(!range_check(A,user))
		return
	var/turf/start = get_turf(src)
	switch(mode)
		if(REMOVE_MODE)
			if(istype(A, /obj/machinery/light/))
				if(checkResource(deconcost, user))
					to_chat(user, "<span class='notice'>You start deconstructing [A]...</span>")
					user.Beam(A,icon_state="nzcrentrs_power", time = 15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, decondelay, target = A))
						if(!useResource(deconcost, user))
							return 0
						activate()
						qdel(A)
						return TRUE
				return FALSE
		if(LIGHT_MODE)
			if(iswallturf(A))
				var/turf/closed/wall/W = A
				if(checkResource(floorcost, user))
					to_chat(user, "<span class='notice'>You start building a wall light...</span>")
					user.Beam(A,icon_state="nzcrentrs_power", time = 15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					playsound(src.loc, 'sound/effects/light_flicker.ogg', 50, 0)
					if(do_after(user, floordelay, target = A))
						if(!istype(W))
							return FALSE
						var/list/candidates = list()
						var/turf/open/winner = null
						var/winning_dist = null
						for(var/direction in GLOB.cardinals)
							var/turf/C = get_step(W, direction)
							var/list/dupes = checkdupes(C)
							if(start.CanAtmosPass(C) && !dupes.len)
								candidates += C
						if(!candidates.len)
							to_chat(user, "<span class='warning'>Valid target not found...</span>")
							playsound(src.loc, 'sound/misc/compiler-failure.ogg', 30, 1)
							return FALSE
						for(var/turf/open/O in candidates)
							if(istype(O))
								var/x0 = O.x
								var/y0 = O.y
								var/contender = cheap_hypotenuse(start.x, start.y, x0, y0)
								if(!winner)
									winner = O
									winning_dist = contender
								else
									if(contender < winning_dist) // lower is better
										winner = O
										winning_dist = contender
						activate()
						if(!useResource(wallcost, user))
							return FALSE
						var/light = get_turf(winner)
						var/align = get_dir(winner, A)
						var/obj/machinery/light/L = new /obj/machinery/light(light)
						L.setDir(align)
						L.color = color_choice
						L.light_color = L.color
						return TRUE
				return FALSE

			if(isfloorturf(A))
				var/turf/open/floor/F = A
				if(checkResource(floorcost, user))
					to_chat(user, "<span class='notice'>You start building a floor light...</span>")
					user.Beam(A,icon_state="nzcrentrs_power", time = 15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					playsound(src.loc, 'sound/effects/light_flicker.ogg', 50, 1)
					if(do_after(user, floordelay, target = A))
						if(!istype(F))
							return 0
						if(!useResource(floorcost, user))
							return 0
						activate()
						var/destination = get_turf(A)
						var/obj/machinery/light/floor/FL = new /obj/machinery/light/floor(destination)
						FL.color = color_choice
						FL.light_color = FL.color
						return TRUE
				return FALSE

		if(GLOW_MODE)
			if(useResource(launchcost, user))
				activate()
				to_chat(user, "<span class='notice'>You fire a glowstick!</span>")
				var/obj/item/flashlight/glowstick/G  = new /obj/item/flashlight/glowstick(start)
				G.color = color_choice
				G.light_color = G.color
				G.throw_at(A, 9, 3, user)
				G.on = TRUE
				G.update_brightness()
				return TRUE
			return FALSE

/obj/item/construction/plumbing
	name = "Plumbing Constructor"
	desc = "An expertly modified RCD outfitted to construct plumbing machinery."
	icon_state = "plumberer2"
	icon = 'icons/obj/tools.dmi'
	slot_flags = ITEM_SLOT_BELT

	matter = 200
	max_matter = 200

	///type of the plumbing machine
	var/blueprint = null
	///index, used in the attack self to get the type. stored here since it doesnt change
	var/list/choices = list()
	///index, used in the attack self to get the type. stored here since it doesnt change
	///This list that holds all the plumbing design types the plumberer can construct. Its purpose is to make it easy to make new plumberer subtypes with a different selection of machines.
	var/list/static/plumbing_design_types

	var/list/name_to_type = list()
	///
	var/list/machinery_data = list("cost" = list(), "delay" = list())


/obj/item/construction/plumbing/Initialize(mapload)
	. = ..()
	set_plumbing_designs()


///Set the list of designs this plumbing rcd can make
/obj/item/construction/plumbing/proc/set_plumbing_designs()
	plumbing_design_types = list(
	/obj/machinery/plumbing/input = 5,
	/obj/machinery/plumbing/output = 5,
	/obj/machinery/plumbing/tank = 20,
	/obj/machinery/plumbing/synthesizer = 15,
	/obj/machinery/plumbing/reaction_chamber = 15,
	//Above are the most common machinery which is shown on the first cycle. Keep new additions below THIS line, unless they're probably gonna be needed alot
	/obj/machinery/plumbing/acclimator = 10,
	/obj/machinery/plumbing/disposer = 10,
	/obj/machinery/plumbing/filter = 5,
	/obj/machinery/plumbing/grinder_chemical = 30,
	/obj/machinery/plumbing/splitter = 5
)

/obj/item/construction/plumbing/attack_self(mob/user)
	..()
	if(!choices.len)
		for(var/A in plumbing_design_types)
			var/obj/machinery/plumbing/M = A
			if(initial(M.rcd_constructable))
				choices += list(initial(M.name) = image(icon = initial(M.icon), icon_state = initial(M.icon_state)))
				name_to_type[initial(M.name)] = M
				machinery_data["cost"][A] = initial(M.rcd_cost)
				machinery_data["delay"][A] = initial(M.rcd_delay)

	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return

	blueprint = name_to_type[choice]
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)
	to_chat(user, "<span class='notice'>You change [name]s blueprint to '[choice]'.</span>")

///pretty much rcd_create, but named differently to make myself feel less bad for copypasting from a sibling-type
/obj/item/construction/plumbing/proc/create_machine(atom/A, mob/user)
	if(!machinery_data || !isopenturf(A))
		return FALSE

	if(checkResource(machinery_data["cost"][blueprint], user) && blueprint)
		if(do_after(user, machinery_data["delay"][blueprint], target = A))
			if(checkResource(machinery_data["cost"][blueprint], user) && canPlace(A))
				useResource(machinery_data["cost"][blueprint], user)
				activate()
				playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
				new blueprint (A, FALSE, FALSE)
				return TRUE

/obj/item/construction/plumbing/proc/canPlace(turf/T)
	if(!isopenturf(T))
		return FALSE
	. = TRUE
	for(var/obj/O in T.contents)
		if(O.density) //let's not built ontop of dense stuff, like big machines and other obstacles, it kills my immershion
			return FALSE

/obj/item/construction/plumbing/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!prox_check(proximity))
		return
	if(istype(A, /obj/machinery/plumbing))
		var/obj/machinery/plumbing/P = A
		if(P.anchored)
			to_chat(user, "<span class='warning'>The [P.name] needs to be unanchored!</span>")
			return
		if(do_after(user, 20, target = P))
			P.deconstruct() //Let's not substract matter
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE) //this is just such a great sound effect
	else
		create_machine(A, user)

/obj/item/rcd_upgrade
	name = "RCD advanced design disk"
	desc = "It seems to be empty."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"
	var/upgrade

/obj/item/rcd_upgrade/frames
	desc = "It contains the design for machine frames and computer frames."
	upgrade = RCD_UPGRADE_FRAMES

/obj/item/rcd_upgrade/simple_circuits
	desc = "It contains the design for firelock, air alarm, fire alarm, apc circuits and crap power cells."
	upgrade = RCD_UPGRADE_SIMPLE_CIRCUITS

/obj/item/rcd_upgrade/silo_link
	desc = "It contains direct silo connection RCD upgrade."
	upgrade = RCD_UPGRADE_SILO_LINK

/obj/item/rcd_upgrade/furnishing
	desc = "It contains the design for chairs, stools, tables, and glass tables."
	upgrade = RCD_UPGRADE_FURNISHING

#undef GLOW_MODE
#undef LIGHT_MODE
#undef REMOVE_MODE
