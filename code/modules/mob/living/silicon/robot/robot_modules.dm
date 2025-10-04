/***************************************************************************************
 * # robot_modules
 *
 * Deals with the creation and deletion of modules (tools).
 * Assigns modules and traits to a borg with a specific model selected.
 *
 ***************************************************************************************/

/obj/item/robot_model/Initialize(mapload)
	. = ..()
	for(var/i in basic_modules)
		var/obj/item/I = new i(src)
		basic_modules += I
		basic_modules -= i
	for(var/i in emag_modules)
		var/obj/item/I = new i(src)
		emag_modules += I
		emag_modules -= i
	for(var/i in ratvar_modules)
		var/obj/item/I = new i(src)
		ratvar_modules += I
		ratvar_modules -= i

/obj/item/robot_model/Destroy()
	basic_modules.Cut()
	emag_modules.Cut()
	ratvar_modules.Cut()
	modules.Cut()
	added_modules.Cut()
	storages.Cut()
	. = ..()

/obj/item/robot_model/proc/get_usable_modules()
	. = modules.Copy()

/obj/item/robot_model/proc/get_inactive_modules()
	. = list()
	var/mob/living/silicon/robot/robot = loc
	for(var/m in get_usable_modules())
		if(!(m in robot.held_items))
			. += m

/obj/item/robot_model/proc/add_module(obj/item/item, nonstandard, requires_rebuild)
	if(istype(item, /obj/item/stack))
		var/obj/item/stack/sheet_module = item
		if(ispath(sheet_module.source, /datum/robot_energy_storage))
			sheet_module.source = get_or_create_estorage(sheet_module.source)

		if(istype(sheet_module, /obj/item/stack/sheet/rglass/cyborg))
			var/obj/item/stack/sheet/rglass/cyborg/rglass_module = sheet_module
			if(ispath(rglass_module.glasource, /datum/robot_energy_storage))
				rglass_module.glasource = get_or_create_estorage(rglass_module.glasource)

		if(istype(sheet_module.source))
			sheet_module.cost = max(sheet_module.cost, 1) // Must not cost 0 to prevent div/0 errors.
			sheet_module.is_cyborg = TRUE

	if(item.loc != src)
		item.forceMove(src)
	modules += item
	ADD_TRAIT(item, TRAIT_NODROP, CYBORG_ITEM_TRAIT)
	item.mouse_opacity = MOUSE_OPACITY_OPAQUE
	if(nonstandard)
		added_modules += item
	if(requires_rebuild)
		rebuild_modules()

	return item

/obj/item/robot_model/proc/remove_module(obj/item/item, delete_after)
	basic_modules -= item
	modules -= item
	emag_modules -= item
	ratvar_modules -= item
	added_modules -= item
	rebuild_modules()
	if(delete_after)
		qdel(item)

/obj/item/robot_model/proc/rebuild_modules() //builds the usable module list from the modules we have
	var/mob/living/silicon/robot/robot = loc
	var/held_modules = robot.held_items.Copy()
	robot.uneq_all()
	modules = list()

	// Default
	for(var/obj/item/basic_module in basic_modules)
		add_module(basic_module, FALSE, FALSE)
	// Emag
	if(robot.emagged)
		for(var/obj/item/emag_module in emag_modules)
			add_module(emag_module, FALSE, FALSE)
	// Ratvar
	if(IS_SERVANT_OF_RATVAR(robot) && !robot.ratvar)	//It just works :^)
		robot.SetRatvar(TRUE, FALSE)
	if(robot.ratvar)
		for(var/obj/item/ratvar_module in ratvar_modules)
			add_module(ratvar_module, FALSE, FALSE)
	// tbh I have no idea what added_modules are but they are here
	for(var/obj/item/added_module in added_modules)
		add_module(added_module, FALSE, FALSE)

	for(var/held_module in held_modules)
		if(held_module)
			robot.activate_module(held_module)
	if(robot.hud_used)
		robot.hud_used.update_robot_modules_display()

/obj/item/robot_model/proc/respawn_consumable(mob/living/silicon/robot/robot, coeff = 1)
	for(var/datum/robot_energy_storage/st in storages)
		st.energy = min(st.max_energy, st.energy + coeff * st.recharge_rate)

	// Refresh flashes, stun baton charge, energy gun charge
	for(var/obj/item/item in get_usable_modules())
		if(istype(item, /obj/item/assembly/flash))
			var/obj/item/assembly/flash/flash = item
			flash.bulb.charges_left = INFINITY
			flash.burnt_out = FALSE
			flash.update_icon()
		else if(istype(item, /obj/item/melee/baton))
			var/obj/item/melee/baton/stun_baton = item
			stun_baton.cell?.charge = stun_baton.cell.maxcharge
		else if(istype(item, /obj/item/gun/energy))
			var/obj/item/gun/energy/energy_gun = item
			if(!energy_gun.chambered)
				energy_gun.recharge_newshot() //try to reload a new shot.

	robot.toner = robot.tonermax

/obj/item/robot_model/proc/get_or_create_estorage(storage_type)
	return (locate(storage_type) in storages) || new storage_type(src)

/obj/item/robot_model/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/obj/object in modules)
		object.emp_act(severity)
	..()

// --------------------- Transformations
/obj/item/robot_model/proc/transform_to(new_module_type)
	var/mob/living/silicon/robot/robot = loc
	var/obj/item/robot_model/new_model = new new_module_type(robot)
	if(!new_model.be_transformed_to(src))
		qdel(new_model)
		return
	robot.model = new_model
	robot.update_module_innate()
	new_model.rebuild_modules()
	robot.set_modularInterface_theme()
	INVOKE_ASYNC(new_model, PROC_REF(do_transform_animation))
	qdel(src)
	return new_model

/obj/item/robot_model/proc/be_transformed_to(obj/item/robot_model/old_module)
	for(var/i in old_module.added_modules)
		added_modules += i
		old_module.added_modules -= i
	did_feedback = old_module.did_feedback
	return TRUE

/obj/item/robot_model/proc/do_transform_animation()
	var/mob/living/silicon/robot/robot = loc
	if(robot.hat)
		robot.hat.forceMove(get_turf(robot))
		robot.hat = null
	robot.cut_overlays()
	robot.setDir(SOUTH)
	do_transform_delay()

/obj/item/robot_model/proc/do_transform_delay()
	var/mob/living/silicon/robot/robot = loc
	var/prev_lockcharge = robot.lockcharge
	sleep(1)
	flick("[cyborg_base_icon]_transform", robot)
	robot.notransform = TRUE
	robot.SetLockdown(TRUE)
	robot.set_anchored(TRUE)
	robot.logevent("Chassis configuration has been set to [name].")
	sleep(1)
	for(var/i in 1 to 4)
		playsound(robot, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, TRUE, -1)
		sleep(7)
	if(!prev_lockcharge)
		robot.SetLockdown(FALSE)
	robot.setDir(SOUTH)
	robot.set_anchored(FALSE)
	robot.notransform = FALSE
	robot.update_icons()
	robot.notify_ai(NEW_MODEL)
	if(robot.hud_used)
		robot.hud_used.update_robot_modules_display()
	SSblackbox.record_feedback("tally", "cyborg_modules", 1, robot.model)

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The cyborg mob interacting with the menu
 * * old_module The old cyborg's module
 */
/obj/item/robot_model/proc/check_menu(mob/living/silicon/robot/user, obj/item/robot_model/old_module)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(user.model != old_module)
		return FALSE
	return TRUE

// ------------------------------------------ Setting base model modules
// --------------------- Standard
/obj/item/robot_model/standard
	name = "Standard"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/borghypo/epi,
		/obj/item/healthanalyzer,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/extinguisher,
		/obj/item/pickaxe,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/storage/bag/ore/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/soap/nanotrasen,
		/obj/item/borg/cyborghug,
		/obj/item/gps/cyborg,
		/obj/item/instrument/piano_synth)
	emag_modules = list(/obj/item/melee/energy/sword/cyborg)
	ratvar_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/abstraction_crystal,
		/obj/item/clockwork/replica_fabricator,
		/obj/item/stack/sheet/brass/cyborg,
		/obj/item/clockwork/weapon/brass_spear)
	model_select_icon = "standard"
	hat_offset = -3

// --------------------- Clown
/obj/item/robot_model/clown
	name = "Clown"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/toy/crayon/rainbow,
		/obj/item/instrument/bikehorn,
		/obj/item/stamp/clown,
		/obj/item/bikehorn,
		/obj/item/bikehorn/airhorn,
		/obj/item/paint/anycolor,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/soap/nanotrasen,
		/obj/item/pneumatic_cannon/pie/selfcharge/cyborg,
		/obj/item/razor,					//killbait material
		/obj/item/lipstick/purple,
		/obj/item/reagent_containers/spray/waterflower/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/borg/lollipop/clown,
		/obj/item/picket_sign/cyborg,
		/obj/item/reagent_containers/borghypo/clown,
		/obj/item/extinguisher/mini)
	emag_modules = list(
		/obj/item/reagent_containers/borghypo/clown/hacked,
		/obj/item/reagent_containers/spray/waterflower/cyborg/hacked)
	ratvar_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clockwork/weapon/brass_battlehammer)	//honk
	model_select_icon = "service"
	cyborg_base_icon = "clown"
	hat_offset = -2

// --------------------- Engineering
/obj/item/robot_model/engineering
	name = "Engineering"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/borg/charger,
		/obj/item/construction/rcd/borg,
		/obj/item/pipe_dispenser,
		/obj/item/extinguisher,
		/obj/item/weldingtool/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/geiger_counter/cyborg,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/areaeditor/blueprints/cyborg,
		/obj/item/electroadaptive_pseudocircuit,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/stack/cable_coil,
		/obj/item/holosign_creator/atmos)
	emag_modules = list(/obj/item/borg/stun)
	ratvar_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/ocular_warden,
		/obj/item/clock_module/tinkerers_cache,
		/obj/item/clock_module/stargazer,
		/obj/item/clock_module/abstraction_crystal,
		/obj/item/clockwork/replica_fabricator,
		/obj/item/stack/sheet/brass/cyborg)
	cyborg_base_icon = "engineer"
	model_select_icon = "engineer"
	hat_offset = -4

// --------------------- Janitor
/obj/item/robot_model/janitor
	name = "Janitor"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/soap/nanotrasen,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/storage/bag/trash/cyborg,
		/obj/item/melee/flyswatter,
		/obj/item/extinguisher/mini,
		/obj/item/mop/cyborg,
		/obj/item/reagent_containers/cup/bucket,
		/obj/item/paint/paint_remover,
		/obj/item/lightreplacer/cyborg,
		/obj/item/holosign_creator/janibarrier,
		/obj/item/reagent_containers/spray/cyborg/drying_agent,
		/obj/item/reagent_containers/spray/cyborg/plantbgone,
		/obj/item/wirebrush)
	emag_modules = list(
		/obj/item/reagent_containers/spray/cyborg/lube,
		/obj/item/reagent_containers/spray/cyborg/acid)
	ratvar_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/sigil_submission,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/vanguard)
	cyborg_base_icon = "janitor"
	model_select_icon = "janitor"
	hat_offset = -5
	clean_on_move = TRUE

/obj/item/robot_model/janitor/respawn_consumable(mob/living/silicon/robot/robot, coeff = 1)
	. = ..()
	var/obj/item/lightreplacer/light_replacer = locate(/obj/item/lightreplacer) in basic_modules
	if(light_replacer)
		for(var/i in 1 to coeff)
			light_replacer.Charge(robot)

// --------------------- Medical
/obj/item/robot_model/medical
	name = "Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/reagent_containers/borghypo,
		/obj/item/borg/apparatus/container,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/surgical_drapes,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/blood_filter,
		/obj/item/extinguisher/mini,
		/obj/item/rollerbed/robo,
		/obj/item/borg/cyborghug/medical,
		/obj/item/stack/medical/gauze,
		/obj/item/organ_storage,
		/obj/item/borg/lollipop)
	emag_modules = list(/obj/item/reagent_containers/borghypo/hacked)
	ratvar_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/sentinels_compromise,
		/obj/item/clock_module/prosperity_prism,
		/obj/item/clock_module/vanguard)
	cyborg_base_icon = "medical"
	model_select_icon = "medical"
	module_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3

/obj/item/robot_model/medical/be_transformed_to(obj/item/robot_model/old_model)
	var/mob/living/silicon/robot/cyborg = loc
	var/list/medical_icons = list(
		"Qualified Doctor" = image(icon = 'icons/mob/robots.dmi', icon_state = "qualified_doctor"),
		"Machinified Doctor" = image(icon = 'icons/mob/robots.dmi', icon_state = "medical")
	)
	var/medical_robot_icon = show_radial_menu(cyborg, cyborg, medical_icons, custom_check = CALLBACK(src, PROC_REF(check_menu), cyborg, old_model), radius = 42, require_near = TRUE)
	switch(medical_robot_icon)
		if("Machinified Doctor")
			cyborg_base_icon = "medical"
			special_light_key = "medical"
		if("Qualified Doctor")
			cyborg_base_icon = "qualified_doctor"
			special_light_key = "qualified_doctor"
		else
			return FALSE
	. = ..()

// --------------------- Mining
/obj/item/robot_model/miner
	name = "Miner"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/storage/bag/ore/cyborg,
		/obj/item/pickaxe/drill/cyborg,
		/obj/item/shovel,
		/obj/item/borg/charger,
		/obj/item/crowbar/cyborg,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/extinguisher/mini,
		/obj/item/storage/bag/sheetsnatcher/borg,
		/obj/item/gun/energy/recharge/kinetic_accelerator/cyborg,
		/obj/item/gps/cyborg,
		/obj/item/stack/marker_beacon)
	emag_modules = list(/obj/item/borg/stun)
	ratvar_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clock_module/ocular_warden,
		/obj/item/clock_module/sentinels_compromise)
	cyborg_base_icon = "miner"
	model_select_icon = "miner"
	hat_offset = 0
	var/obj/item/t_scanner/adv_mining_scanner/cyborg/mining_scanner //built in memes.

/obj/item/robot_model/miner/be_transformed_to(obj/item/robot_model/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/list/miner_icons = list(
		"Lavaland Miner" = image(icon = 'icons/mob/robots.dmi', icon_state = "miner"),
		"Asteroid Miner" = image(icon = 'icons/mob/robots.dmi', icon_state = "minerOLD"),
		"Spider Miner" = image(icon = 'icons/mob/robots.dmi', icon_state = "spidermin")
	)
	var/miner_robot_icon = show_radial_menu(cyborg, cyborg, miner_icons, custom_check = CALLBACK(src, PROC_REF(check_menu), cyborg, old_module), radius = 42, require_near = TRUE)
	switch(miner_robot_icon)
		if("Lavaland Miner")
			cyborg_base_icon = "miner"
		if("Asteroid Miner")
			cyborg_base_icon = "minerOLD"
			special_light_key = "miner"
		if("Spider Miner")
			cyborg_base_icon = "spidermin"
		else
			return FALSE
	. = ..()

/obj/item/robot_model/miner/rebuild_modules()
	. = ..()
	if(!mining_scanner)
		mining_scanner = new(src)

/obj/item/robot_model/miner/Destroy()
	QDEL_NULL(mining_scanner)
	. = ..()

// --------------------- Peacekeeper
/obj/item/robot_model/peacekeeper
	name = "Peacekeeper"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/cookiesynth,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/harmalarm,
		/obj/item/reagent_containers/borghypo/peace,
		/obj/item/holosign_creator/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/extinguisher,
		/obj/item/reagent_containers/peppercloud_deployer,
		/obj/item/borg/projectile_dampen)
	emag_modules = list(/obj/item/reagent_containers/borghypo/peace/hacked)
	ratvar_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/sigil_submission)
	cyborg_base_icon = "peace"
	model_select_icon = "standard"
	module_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = -2

// --------------------- Service
/obj/item/robot_model/service
	name = "Service"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/pen,
		/obj/item/toy/crayon/spraycan/borg,
		/obj/item/extinguisher/mini,
		/obj/item/hand_labeler/borg,
		/obj/item/razor,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/rsf,
		/obj/item/cookiesynth,
		/obj/item/instrument/piano_synth,
		/obj/item/reagent_containers/dropper,
		/obj/item/lighter,
		/obj/item/borg/apparatus/container/service,
		/obj/item/reagent_containers/borghypo/borgshaker)
	emag_modules = list(/obj/item/reagent_containers/borghypo/borgshaker/hacked)
	ratvar_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clock_module/vanguard,
		/obj/item/clock_module/sigil_submission,
		/obj/item/clock_module/kindle,
		/obj/item/clock_module/sentinels_compromise,
		/obj/item/clockwork/replica_fabricator)
	model_select_icon = "service"
	cyborg_base_icon = "service_m" // display as butlerborg for radial model selection
	special_light_key = "service"
	hat_offset = 0

/obj/item/robot_model/service/respawn_consumable(mob/living/silicon/robot/robot, coeff = 1)
	. = ..()
	var/obj/item/reagent_containers/enzyme_container = locate(/obj/item/reagent_containers/condiment/enzyme) in basic_modules
	enzyme_container?.reagents.add_reagent(/datum/reagent/consumable/enzyme, 2 * coeff)

/obj/item/robot_model/service/be_transformed_to(obj/item/robot_model/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/list/service_icons = list(
		"Waitress" = image(icon = 'icons/mob/robots.dmi', icon_state = "service_f"),
		"Butler" = image(icon = 'icons/mob/robots.dmi', icon_state = "service_m"),
		"Bro" = image(icon = 'icons/mob/robots.dmi', icon_state = "brobot"),
		"Kent" = image(icon = 'icons/mob/robots.dmi', icon_state = "kent"),
		"Tophat" = image(icon = 'icons/mob/robots.dmi', icon_state = "tophat")
	)
	var/service_robot_icon = show_radial_menu(cyborg, cyborg, service_icons, custom_check = CALLBACK(src, PROC_REF(check_menu), cyborg, old_module), radius = 42, require_near = TRUE)
	switch(service_robot_icon)
		if("Waitress")
			cyborg_base_icon = "service_f"
		if("Butler")
			cyborg_base_icon = "service_m"
		if("Bro")
			cyborg_base_icon = "brobot"
		if("Kent")
			cyborg_base_icon = "kent"
			special_light_key = "medical"
			hat_offset = 3
		if("Tophat")
			cyborg_base_icon = "tophat"
			special_light_key = null
			hat_offset = INFINITY //He's already wearing a hat
		else
			return FALSE
	. = ..()

// --------------------- guard
/obj/item/robot_model/guard
	name = "Guardian"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/gun/energy/e_gun/mini/exploration/cyborg,
		/obj/item/reagent_containers/peppercloud_deployer,
		/obj/item/holosign_creator/security,
		/obj/item/storage/bag/ore/cyborg,
		/obj/item/gps/cyborg,
		/obj/item/borg/charger,
		/obj/item/extinguisher/mini,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/borg/lollipop,
		/obj/item/borg/cyborghug)
	emag_modules = list(/obj/item/melee/energy/sword/cyborg)
	ratvar_modules = list(
		/obj/item/clock_module/abscond,
		/obj/item/clockwork/weapon/brass_spear,
		/obj/item/clock_module/ocular_warden,
		/obj/item/clock_module/vanguard)
	cyborg_base_icon = "guard"
	model_select_icon = "guard"
	module_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3

//Aside from bomb and acid, not actually a lot of armor
/datum/armor/cyborg
	melee = 30
	bullet = 30
	laser = 30
	energy = 30
	bomb = 50
	acid = 100

/obj/item/robot_model/guard/be_transformed_to(obj/item/robot_model/old_module)
	var/mob/living/silicon/robot/cyborg = loc
	var/list/guard_icons = list(
		"Traditional" = image(icon = 'icons/mob/robots.dmi', icon_state = "guard"),
		"Treaded" = image(icon = 'icons/mob/robots.dmi', icon_state = "guard_tread"),
		"Borgi" = image(icon = 'icons/mob/robots.dmi', icon_state = "guard_alt")
	)
	var/service_robot_icon = show_radial_menu(cyborg, cyborg, guard_icons, custom_check = CALLBACK(src, PROC_REF(check_menu), cyborg, old_module), radius = 42, require_near = TRUE)
	switch(service_robot_icon)
		if("Traditional")
			cyborg_base_icon = "guard"
		if("Treaded")
			cyborg_base_icon = "guard_tread"
		if("Borgi")
			cyborg_base_icon = "guard_alt"
		else
			return FALSE
	. = ..()

// --------------------- Deathsquad
/obj/item/robot_model/deathsquad
	name = "CentCom"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/melee/baton/loaded,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/shield/riot/tele,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/melee/energy/sword/cyborg,
		/obj/item/gun/energy/pulse/carbine/cyborg,
		/obj/item/clothing/mask/gas/sechailer/cyborg)
	emag_modules = list(/obj/item/gun/energy/laser/cyborg)
	ratvar_modules = list(/obj/item/clock_module/abscond)
	cyborg_base_icon = "centcom"
	model_select_icon = "malf"
	module_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3

// ------------------------------------------ Syndicate
// --------------------- Syndicate Assault
/obj/item/robot_model/syndicate
	name = "Syndicate Assault"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/melee/energy/sword/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg,
		/obj/item/card/emag,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg)
	cyborg_base_icon = "synd_sec"
	model_select_icon = "malf"
	module_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3

/obj/item/robot_model/syndicate/rebuild_modules()
	. = ..()
	var/mob/living/silicon/robot/robot = loc
	robot.faction -= FACTION_SILICON //ai turrets

/obj/item/robot_model/syndicate/remove_module(obj/item/I, delete_after)
	. = ..()
	var/mob/living/silicon/robot/robot = loc
	robot.faction += FACTION_SILICON //ai is your bff now!

// --------------------- Syndicate Medical
/obj/item/robot_model/syndicate_medical
	name = "Syndicate Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/shockpaddles/syndicate/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/surgical_drapes,
		/obj/item/borg/charger,
		/obj/item/weldingtool/cyborg/mini,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/melee/energy/sword/cyborg/saw,
		/obj/item/rollerbed/robo,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/stack/medical/gauze,
		/obj/item/gun/medbeam,
		/obj/item/organ_storage)
	cyborg_base_icon = "synd_medical"
	model_select_icon = "malf"
	module_traits = list(TRAIT_PUSHIMMUNE)
	hat_offset = 3

// --------------------- Syndicate Saboteur
/obj/item/robot_model/saboteur
	name = "Syndicate Saboteur"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/thermal,
		/obj/item/construction/rcd/borg/syndicate,
		/obj/item/pipe_dispenser,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/borg/charger,
		/obj/item/extinguisher,
		/obj/item/weldingtool/cyborg,
		/obj/item/screwdriver/nuke,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/iron/base/cyborg,
		/obj/item/dest_tagger/borg,
		/obj/item/stack/cable_coil,
		/obj/item/card/emag,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/borg_chameleon,
		)
	cyborg_base_icon = "synd_engi"
	model_select_icon = "malf"
	module_traits = list(TRAIT_PUSHIMMUNE, TRAIT_NEGATES_GRAVITY)
	hat_offset = -4
	canDispose = TRUE

// ------------------------------------------ Storages
/datum/robot_energy_storage
	var/name = "Generic energy storage"
	var/max_energy = 30000
	var/recharge_rate = 1000
	var/energy

/datum/robot_energy_storage/New(obj/item/robot_model/robot)
	energy = max_energy
	robot?.storages |= src

/datum/robot_energy_storage/proc/use_charge(amount)
	if(energy >= amount)
		energy -= amount
		return TRUE
	else
		return FALSE

/datum/robot_energy_storage/proc/add_charge(amount)
	energy = min(energy + amount, max_energy)

/datum/robot_energy_storage/metal
	name = "Metal Synthesizer"

/datum/robot_energy_storage/glass
	name = "Glass Synthesizer"

/datum/robot_energy_storage/brass
	name = "Brass Synthesizer"

/datum/robot_energy_storage/wire
	max_energy = 50
	recharge_rate = 2
	name = "Wire Synthesizer"

/datum/robot_energy_storage/medical
	max_energy = 2500
	recharge_rate = 250
	name = "Medical Synthesizer"

/datum/robot_energy_storage/beacon
	max_energy = 30
	recharge_rate = 1
	name = "Marker Beacon Storage"
