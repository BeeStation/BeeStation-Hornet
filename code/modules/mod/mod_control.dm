/// MODsuits, trade-off between armor and utility
/obj/item/mod
	name = "Base MOD"
	desc = "You should not see this, yell at a coder!"
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	worn_icon = 'icons/mob/clothing/modsuit/mod_clothing.dmi'

/obj/item/mod/control
	name = "MOD control unit"
	desc = "The control unit of a Modular Outerwear Device, a powered, back-mounted suit that protects against various environments."
	icon_state = "standard-control"
	item_state = "mod_control"
	base_icon_state = "control"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	strip_delay = 10 SECONDS
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0, BLEED = 0)
	actions_types = list(
		/datum/action/item_action/mod/deploy,
		/datum/action/item_action/mod/activate,
		/datum/action/item_action/mod/panel,
		/datum/action/item_action/mod/module,
		/datum/action/item_action/mod/deploy/ai,
		/datum/action/item_action/mod/activate/ai,
		/datum/action/item_action/mod/panel/ai,
		/datum/action/item_action/mod/module/ai,
	)
	resistance_flags = NONE
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	permeability_coefficient = 0.01
	siemens_coefficient = 0.5
	alternate_worn_layer = HANDS_LAYER+0.1 //we want it to go above generally everything, but not hands
	/// The MOD's theme, decides on some stuff like armor and statistics.
	var/datum/mod_theme/theme = /datum/mod_theme
	/// Looks of the MOD.
	var/skin = "standard"
	/// Theme of the MOD TGUI
	var/ui_theme = "ntos"
	/// If the suit is deployed and turned on.
	var/active = FALSE
	/// If the suit wire/module hatch is open.
	var/open = FALSE
	/// If the suit is ID locked.
	var/locked = FALSE
	/// If the suit is malfunctioning.
	var/malfunctioning = FALSE
	/// If the suit is currently activating/deactivating.
	var/activating = FALSE
	/// How long the MOD is electrified for.
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	/// If the suit interface is broken.
	var/interface_break = FALSE
	/// How much module complexity can this MOD carry.
	var/complexity_max = DEFAULT_MAX_COMPLEXITY
	/// How much module complexity this MOD is carrying.
	var/complexity = 0
	/// Power usage of the MOD.
	var/charge_drain = DEFAULT_CHARGE_DRAIN
	/// Slowdown of the MOD when not active.
	var/slowdown_inactive = 1.25
	/// Slowdown of the MOD when active.
	var/slowdown_active = 0.75
	/// How long this MOD takes each part to seal.
	var/activation_step_time = MOD_ACTIVATION_STEP_TIME
	/// Extended description of the theme.
	var/extended_desc
	/// MOD helmet.
	var/obj/item/clothing/head/mod/helmet
	/// MOD chestplate.
	var/obj/item/clothing/suit/mod/chestplate
	/// MOD gauntlets.
	var/obj/item/clothing/gloves/mod/gauntlets
	/// MOD boots.
	var/obj/item/clothing/shoes/mod/boots
	/// MOD core.
	var/obj/item/mod/core/core
	/// List of parts (helmet, chestplate, gauntlets, boots).
	var/list/mod_parts = list()
	/// Modules the MOD should spawn with.
	var/list/initial_modules = list()
	/// Modules the MOD currently possesses.
	var/list/modules = list()
	/// Currently used module.
	var/obj/item/mod/module/selected_module
	/// AI mob inhabiting the MOD.
	var/mob/living/silicon/ai/ai
	/// Delay between moves as AI.
	var/movedelay = 0
	/// Cooldown for AI moves.
	COOLDOWN_DECLARE(cooldown_mod_move)
	/// Person wearing the MODsuit.
	var/mob/living/carbon/human/wearer

/obj/item/mod/control/Initialize(mapload, datum/mod_theme/new_theme, new_skin, obj/item/mod/core/new_core)
	. = ..()
	if(new_theme)
		theme = new_theme
	theme = GLOB.mod_themes[theme]
	extended_desc = theme.extended_desc
	slowdown_inactive = theme.slowdown_inactive
	slowdown_active = theme.slowdown_active
	complexity_max = theme.complexity_max
	ui_theme = theme.ui_theme
	charge_drain = theme.charge_drain
	initial_modules += theme.inbuilt_modules
	wires = new /datum/wires/mod(src)
	if(length(req_access))
		locked = TRUE
	new_core?.install(src)
	helmet = new /obj/item/clothing/head/mod(src)
	helmet.mod = src
	mod_parts += helmet
	chestplate = new /obj/item/clothing/suit/mod(src)
	chestplate.mod = src
	chestplate.allowed = typecacheof(theme.allowed_suit_storage)
	mod_parts += chestplate
	gauntlets = new /obj/item/clothing/gloves/mod(src)
	gauntlets.mod = src
	mod_parts += gauntlets
	boots = new /obj/item/clothing/shoes/mod(src)
	boots.mod = src
	mod_parts += boots
	var/list/all_parts = mod_parts.Copy() + src
	for(var/obj/item/piece as anything in all_parts)
		piece.name = "[theme.name] [piece.name]"
		piece.desc = "[piece.desc] [theme.desc]"
		piece.armor = getArmor(arglist(theme.armor))
		piece.resistance_flags = theme.resistance_flags
		piece.flags_1 |= theme.atom_flags //flags like initialization or admin spawning are here, so we cant set, have to add
		piece.heat_protection = NONE
		piece.cold_protection = NONE
		piece.max_heat_protection_temperature = theme.max_heat_protection_temperature
		piece.min_cold_protection_temperature = theme.min_cold_protection_temperature
		piece.siemens_coefficient = theme.siemens_coefficient
	set_mod_skin(new_skin || theme.default_skin)
	update_speed()
	for(var/obj/item/mod/module/module as anything in initial_modules)
		module = new module(src)
		install(module)
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	RegisterSignal(src, COMSIG_SPEED_POTION_APPLIED, PROC_REF(on_potion))
	movedelay = CONFIG_GET(number/movedelay/run_delay)

/obj/item/mod/control/Destroy()
	if(active)
		STOP_PROCESSING(SSobj, src)
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module, deleting = TRUE)
	var/atom/deleting_atom
	if(!QDELETED(helmet))
		deleting_atom = helmet
		helmet.mod = null
		helmet = null
		mod_parts -= deleting_atom
		qdel(deleting_atom)
	if(!QDELETED(chestplate))
		deleting_atom = chestplate
		chestplate.mod = null
		chestplate = null
		mod_parts -= deleting_atom
		qdel(deleting_atom)
	if(!QDELETED(gauntlets))
		deleting_atom = gauntlets
		gauntlets.mod = null
		gauntlets = null
		mod_parts -= deleting_atom
		qdel(deleting_atom)
	if(!QDELETED(boots))
		deleting_atom = boots
		boots.mod = null
		boots = null
		mod_parts -= deleting_atom
		qdel(deleting_atom)
	if(core)
		QDEL_NULL(core)
	QDEL_NULL(wires)
	return ..()

/obj/item/mod/control/obj_destruction(damage_flag)
	for(var/obj/item/mod/module/module as anything in modules)
		uninstall(module)
	if(ai)
		ai.controlled_equipment = null
		ai.remote_control = null
		for(var/datum/action/action as anything in actions)
			if(action.owner == ai)
				action.Remove(ai)
		new /obj/item/mod/ai_minicard(drop_location(), ai)
	return ..()

/obj/item/mod/control/examine(mob/user)
	. = ..()
	if(active)
		. += "<span class='notice'>Charge: [core ? "[get_charge_percent()]%" : "No core"].</span>"
		. += "<span class='notice'>Selected module: [selected_module || "None"].</span>"
	if(!open && !active)
		. += "<span class='notice'>You could put it on your <b>back</b> to turn it on.</span>"
		. += "<span class='notice'>You could open the cover with a <b>screwdriver</b>.</span>"
	else if(open)
		. += "<span class='notice'>You could close the cover with a <b>screwdriver</b>.</span>"
		. += "<span class='notice'>You could use <b>modules</b> on it to install them.</span>"
		. += "<span class='notice'>You could remove modules with a <b>crowbar</b>.</span>"
		. += "<span class='notice'>You could update the access lock with an <b>ID</b>.</span>"
		. += "<span class='notice'>You could access the wire panel with a <b>wire tool</b>.</span>"
		if(core)
			. += "<span class='notice'>You could remove [core] with a <b>wrench</b>.</span>"
		else
			. += "<span class='notice'>You could use a <b>MOD core</b> on it to install one.</span>"
		if(ai)
			. += "<span class='notice'>You could remove [ai] with an <b>intellicard</b></span>"
		else
			. += "<span class='notice'>You could install an AI with an <b>intellicard</b>.</span>"

/obj/item/mod/control/examine_more(mob/user)
	. = ..()
	. += "<i>[extended_desc]</i>"

/obj/item/mod/control/process(delta_time)
	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--
	if(!get_charge() && active && !activating)
		power_off()
		return PROCESS_KILL
	var/malfunctioning_charge_drain = 0
	if(malfunctioning)
		malfunctioning_charge_drain = rand(1,20)
	subtract_charge((charge_drain + malfunctioning_charge_drain)*delta_time)
	update_charge_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		if(malfunctioning && module.active && DT_PROB(5, delta_time))
			module.on_deactivation(display_message = TRUE)
		module.on_process(delta_time)

/obj/item/mod/control/equipped(mob/user, slot)
	..()
	if(slot == ITEM_SLOT_BACK)
		set_wearer(user)
	else if(wearer)
		unset_wearer()

/obj/item/mod/control/dropped(mob/user)
	. = ..()
	if(wearer)
		unset_wearer()

/obj/item/mod/control/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_BACK)
		return TRUE

/obj/item/mod/control/allow_attack_hand_drop(mob/user)
	if(user != wearer)
		return ..()
	for(var/obj/item/part as anything in mod_parts)
		if(part.loc != src)
			balloon_alert(user, "retract parts first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
			return FALSE

/obj/item/mod/control/MouseDrop(atom/over_object)
	if(usr != wearer || !istype(over_object, /atom/movable/screen/inventory/hand))
		return ..()
	for(var/obj/item/part as anything in mod_parts)
		if(part.loc != src)
			balloon_alert(wearer, "retract parts first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, FALSE, SILENCED_SOUND_EXTRARANGE)
			return
	if(!wearer.incapacitated())
		var/atom/movable/screen/inventory/hand/ui_hand = over_object
		if(wearer.putItemFromInventoryInHandIfPossible(src, ui_hand.held_index))
			add_fingerprint(usr)
			return ..()

/obj/item/mod/control/wrench_act(mob/living/user, obj/item/wrench)
	if(..())
		return TRUE
	if(seconds_electrified && get_charge() && shock(user))
		return TRUE
	if(open)
		if(!core)
			balloon_alert(user, "no core!")
			return TRUE
		balloon_alert(user, "removing core...")
		wrench.play_tool_sound(src, 100)
		if(!wrench.use_tool(src, user, 3 SECONDS) || !open)
			balloon_alert(user, "interrupted!")
			return TRUE
		wrench.play_tool_sound(src, 100)
		balloon_alert(user, "core removed")
		core.forceMove(drop_location())
		update_charge_alert()
		return TRUE
	return ..()

/obj/item/mod/control/screwdriver_act(mob/living/user, obj/item/screwdriver)
	if(..())
		return TRUE
	if(active || activating || ai_controller)
		balloon_alert(user, "deactivate suit first!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MOD_MODULE_REMOVAL, user) & MOD_CANCEL_REMOVAL)
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	balloon_alert(user, "[open ? "closing" : "opening"] cover...")
	screwdriver.play_tool_sound(src, 100)
	if(screwdriver.use_tool(src, user, 1 SECONDS))
		if(active || activating)
			balloon_alert(user, "deactivate suit first!")
		screwdriver.play_tool_sound(src, 100)
		balloon_alert(user, "cover [open ? "closed" : "opened"]")
		open = !open
	else
		balloon_alert(user, "interrupted!")
	return TRUE

/obj/item/mod/control/crowbar_act(mob/living/user, obj/item/crowbar)
	. = ..()
	if(!open)
		balloon_alert(user, "open the cover first!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return FALSE
	if(!allowed(user))
		balloon_alert(user, "insufficient access!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	if(length(modules))
		var/list/removable_modules = list()
		for(var/obj/item/mod/module/module as anything in modules)
			if(!module.removable)
				continue
			removable_modules += module
		var/obj/item/mod/module/module_to_remove = tgui_input_list(user, "Which module to remove?", "Module Removal", removable_modules)
		if(!module_to_remove?.mod)
			return FALSE
		uninstall(module_to_remove)
		module_to_remove.forceMove(drop_location())
		crowbar.play_tool_sound(src, 100)
		return TRUE
	balloon_alert(user, "no modules!")
	playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
	return FALSE

/obj/item/mod/control/attackby(obj/item/attacking_item, mob/living/user, params)
	if(istype(attacking_item, /obj/item/mod/module))
		if(!open)
			balloon_alert(user, "open the cover first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		install(attacking_item, user)
		return TRUE
	else if(istype(attacking_item, /obj/item/mod/core))
		if(!open)
			balloon_alert(user, "open the cover first!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		if(core)
			balloon_alert(user, "core already installed!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return FALSE
		var/obj/item/mod/core/attacking_core = attacking_item
		attacking_core.install(src)
		balloon_alert(user, "core installed")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		update_charge_alert()
		return TRUE
	else if(is_wire_tool(attacking_item) && open)
		wires.interact(user)
		return TRUE
	else if(open && attacking_item.GetID())
		update_access(user, attacking_item.GetID())
		return TRUE
	return ..()

/obj/item/mod/control/get_cell()
	if(!open)
		return
	var/obj/item/stock_parts/cell/cell = get_charge_source()
	if(!istype(cell))
		return
	return cell

/obj/item/mod/control/GetAccess()
	if(ai_controller)
		return req_access.Copy()
	else
		return ..()

/obj/item/mod/control/on_emag(mob/user)
	..()
	locked = !locked
	balloon_alert(user, "suit access [locked ? "locked" : "unlocked"]")

/obj/item/mod/control/emp_act(severity)
	. = ..()
	if(!active || !wearer)
		return
	to_chat(wearer, "<span class='notice'>[severity > 1 ? "Light" : "Strong"] electromagnetic pulse detected!</span>")
	if(. & EMP_PROTECT_CONTENTS)
		return
	selected_module?.on_deactivation(display_message = TRUE)
	wearer.apply_damage(10 / severity, BURN)
	to_chat(wearer, "<span class='danger'>You feel [src] heat up from the EMP, burning you slightly.</span>")
	if(wearer.stat < UNCONSCIOUS && prob(10))
		wearer.emote("scream")

/obj/item/mod/control/on_outfit_equip(mob/living/carbon/human/outfit_wearer, visuals_only, item_slot)
	if(visuals_only)
		set_wearer(outfit_wearer) //we need to set wearer manually since it doesnt call equipped
	quick_activation()

/obj/item/mod/control/doStrip(mob/stripper, mob/owner)
	if(active && !toggle_activate(stripper, force_deactivate = TRUE))
		return
	for(var/obj/item/part as anything in mod_parts)
		if(part.loc == src)
			continue
		conceal(null, part)
	return ..()

/obj/item/mod/control/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file)
	. = ..()
	for(var/obj/item/mod/module/module as anything in modules)
		var/list/module_icons = module.generate_worn_overlay(standing)
		if(!length(module_icons))
			continue
		. += module_icons

/obj/item/mod/control/update_icon_state()
	icon_state = "[skin]-[base_icon_state][active ? "-sealed" : ""]"
	return ..()

/obj/item/mod/control/proc/set_wearer(mob/user)
	wearer = user
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_SET, wearer)
	RegisterSignal(wearer, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	RegisterSignal(src, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(on_unequip))
	update_charge_alert()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_equip()

/obj/item/mod/control/proc/unset_wearer()
	for(var/obj/item/mod/module/module as anything in modules)
		module.on_unequip()
	UnregisterSignal(wearer, list(COMSIG_ATOM_EXITED, COMSIG_PROCESS_BORGCHARGER_OCCUPANT))
	UnregisterSignal(src, COMSIG_ITEM_PRE_UNEQUIP)
	wearer.clear_alert("mod_charge")
	SEND_SIGNAL(src, COMSIG_MOD_WEARER_UNSET, wearer)
	wearer = null

/obj/item/mod/control/proc/on_unequip()
	SIGNAL_HANDLER

	for(var/obj/item/part as anything in mod_parts)
		if(part.loc != src)
			return COMPONENT_ITEM_BLOCK_UNEQUIP

/obj/item/mod/control/proc/update_flags()
	var/list/used_skin = theme.skins[skin]
	for(var/obj/item/clothing/part as anything in mod_parts)
		var/used_category
		if(part == helmet)
			used_category = HELMET_FLAGS
			helmet.alternate_worn_layer = used_skin[HELMET_LAYER]
			helmet.alternate_layer = used_skin[HELMET_LAYER]
		if(part == chestplate)
			used_category = CHESTPLATE_FLAGS
		if(part == gauntlets)
			used_category = GAUNTLETS_FLAGS
		if(part == boots)
			used_category = BOOTS_FLAGS
		var/list/category = used_skin[used_category]
		part.clothing_flags = category[UNSEALED_CLOTHING] || NONE
		part.visor_flags = category[SEALED_CLOTHING] || NONE
		part.flags_inv = category[UNSEALED_INVISIBILITY] || NONE
		part.visor_flags_inv = category[SEALED_INVISIBILITY] || NONE
		part.flags_cover = category[UNSEALED_COVER] || NONE
		part.visor_flags_cover = category[SEALED_COVER] || NONE

/obj/item/mod/control/proc/quick_module(mob/user)
	if(!length(modules))
		return
	var/list/display_names = list()
	var/list/items = list()
	for(var/obj/item/mod/module/module as anything in modules)
		if(module.module_type == MODULE_PASSIVE)
			continue
		display_names[module.name] = REF(module)
		var/image/module_image = image(icon = module.icon, icon_state = module.icon_state)
		if(module == selected_module)
			module_image.underlays += image(icon = 'icons/mob/radial.dmi', icon_state = "module_selected")
		else if(module.active)
			module_image.underlays += image(icon = 'icons/mob/radial.dmi', icon_state = "module_active")
		if(!COOLDOWN_FINISHED(module, cooldown_timer))
			module_image.add_overlay(image(icon = 'icons/mob/radial.dmi', icon_state = "module_cooldown"))
		items += list(module.name = module_image)
	if(!length(items))
		return
	var/radial_anchor = src
	if(istype(user.loc, /obj/effect/dummy/phased_mob))
		radial_anchor = get_turf(user.loc) //they're phased out via some module, anchor the radial on the turf so it may still display
	var/pick = show_radial_menu(user, radial_anchor, items, custom_check = FALSE, require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return
	var/module_reference = display_names[pick]
	var/obj/item/mod/module/picked_module = locate(module_reference) in modules
	if(!istype(picked_module) || user.incapacitated())
		return
	picked_module.on_select()

/obj/item/mod/control/proc/shock(mob/living/user)
	if(!istype(user) || get_charge() < 1)
		return FALSE
	do_sparks(5, TRUE, src)
	var/check_range = TRUE
	return electrocute_mob(user, get_charge_source(), src, 0.7, check_range)

/obj/item/mod/control/proc/install(obj/item/mod/module/new_module, mob/user)
	for(var/obj/item/mod/module/old_module as anything in modules)
		if(is_type_in_list(new_module, old_module.incompatible_modules) || is_type_in_list(old_module, new_module.incompatible_modules))
			if(user)
				balloon_alert(user, "[new_module] incompatible with [old_module]!")
				playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return
	if(is_type_in_list(new_module, theme.module_blacklist))
		if(user)
			balloon_alert(user, "[src] doesn't accept [new_module]!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	var/complexity_with_module = complexity
	complexity_with_module += new_module.complexity
	if(complexity_with_module > complexity_max)
		if(user)
			balloon_alert(user, "[new_module] would make [src] too complex!")
			playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	new_module.forceMove(src)
	modules += new_module
	complexity += new_module.complexity
	new_module.mod = src
	new_module.on_install()
	if(wearer)
		new_module.on_equip()
		var/datum/action/item_action/mod/pinned_module/action = new_module.pinned_to[REF(wearer)]
		if(action)
			action.Grant(wearer)
	if(ai)
		var/datum/action/item_action/mod/pinned_module/action = new_module.pinned_to[REF(ai)]
		if(action)
			action.Grant(ai)
	if(user)
		balloon_alert(user, "[new_module] added")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)

/obj/item/mod/control/proc/uninstall(obj/item/mod/module/old_module, deleting = FALSE)
	modules -= old_module
	complexity -= old_module.complexity
	if(active)
		old_module.on_suit_deactivation(deleting = deleting)
		if(old_module.active)
			old_module.on_deactivation(display_message = !deleting, deleting = deleting)
	old_module.on_uninstall(deleting = deleting)
	QDEL_LIST(old_module.pinned_to)
	old_module.mod = null

/obj/item/mod/control/proc/update_access(mob/user, obj/item/card/id/card)
	if(!allowed(user))
		balloon_alert(user, "insufficient access!")
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return
	req_access = card.access.Copy()
	balloon_alert(user, "access updated")

/obj/item/mod/control/proc/get_charge_source()
	return core?.charge_source()

/obj/item/mod/control/proc/get_charge()
	return core?.charge_amount() || 0

/obj/item/mod/control/proc/get_max_charge()
	return core?.max_charge_amount() || 1 //avoid dividing by 0

/obj/item/mod/control/proc/get_charge_percent()
	return ROUND_UP((get_charge() / get_max_charge()) * 100)

/obj/item/mod/control/proc/add_charge(amount)
	return core?.add_charge(amount) || FALSE

/obj/item/mod/control/proc/subtract_charge(amount)
	return core?.subtract_charge(amount) || FALSE

/obj/item/mod/control/proc/update_charge_alert()
	if(!wearer)
		return
	if(!core)
		wearer.throw_alert("mod_charge", /atom/movable/screen/alert/nocore)
		return
	core.update_charge_alert()

/obj/item/mod/control/proc/update_speed()
	var/list/all_parts = mod_parts + src
	for(var/obj/item/part as anything in all_parts)
		part.slowdown = (active ? slowdown_active : slowdown_inactive) / length(all_parts)
	wearer?.update_equipment_speed_mods()

/obj/item/mod/control/proc/power_off()
	balloon_alert(wearer, "no power!")
	toggle_activate(wearer, force_deactivate = TRUE)

/obj/item/mod/control/proc/set_mod_color(new_color)
	var/list/all_parts = mod_parts.Copy() + src
	for(var/obj/item/part as anything in all_parts)
		part.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		part.add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)
	wearer?.regenerate_icons()

/obj/item/mod/control/proc/set_mod_skin(new_skin)
	skin = new_skin
	var/list/skin_updating = mod_parts.Copy() + src
	var/list/selected_skin = theme.skins[new_skin]
	for(var/obj/item/piece as anything in skin_updating)
		if(selected_skin[MOD_ICON_OVERRIDE])
			piece.icon = selected_skin[MOD_ICON_OVERRIDE]
		if(selected_skin[MOD_WORN_ICON_OVERRIDE])
			piece.worn_icon = selected_skin[MOD_WORN_ICON_OVERRIDE]
		piece.icon_state = "[skin]-[initial(piece.icon_state)]"
	update_flags()
	wearer?.regenerate_icons()

/obj/item/mod/control/proc/on_exit(datum/source, atom/movable/part, direction)
	SIGNAL_HANDLER

	if(part.loc == src)
		return
	if(part == core)
		core.uninstall()
		update_charge_alert()
		return
	if(part.loc == wearer)
		return
	if(part in modules)
		uninstall(part)
		return
	if(part in mod_parts)
		conceal(wearer, part)
		if(active)
			INVOKE_ASYNC(src, PROC_REF(toggle_activate), wearer, TRUE)
		return

/obj/item/mod/control/proc/on_potion(atom/movable/source, obj/item/slimepotion/speed/speed_potion, mob/living/user)
	SIGNAL_HANDLER

	if(slowdown_inactive <= 0)
		to_chat(user, "<span class='warning'>[src] has already been coated with red, that's as fast as it'll go!</span>")
		return SPEED_POTION_STOP
	if(active)
		to_chat(user, "<span class='warning'>It's too dangerous to smear [speed_potion] on [src] while it's on active!</span>")
		return SPEED_POTION_STOP
	to_chat(user, "<span class='notice'>You slather the red gunk over [src], making it faster.</span>")
	set_mod_color("#FF0000")
	slowdown_inactive = 0
	slowdown_active = 0
	update_speed()
	qdel(speed_potion)
	return SPEED_POTION_STOP
