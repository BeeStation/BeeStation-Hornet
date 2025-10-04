//General modules for MODsuits

///Storage - Adds a storage component to the suit.
/obj/item/mod/module/storage
	name = "\improper MOD storage module"
	desc = "What amounts to a series of integrated storage compartments and specialized pockets installed across \
		the surface of the suit, useful for storing various bits and/or bobs."
	icon_state = "storage"
	complexity = 3
	incompatible_modules = list(/obj/item/mod/module/storage, /obj/item/mod/module/plate_compression)
	required_slots = list(ITEM_SLOT_BACK)
	/// Max weight class of items in the storage.
	var/max_w_class = WEIGHT_CLASS_NORMAL
	/// Max combined weight of all items in the storage.
	var/max_combined_w_class = 15
	/// Max amount of items in the storage.
	var/max_items = 7
	/// Is nesting same-size storage items allowed?
	var/big_nesting = FALSE

/obj/item/mod/module/storage/Initialize(mapload)
	. = ..()
	create_storage(max_specific_storage = max_w_class, max_total_storage = max_combined_w_class, max_slots = max_items)
	atom_storage.allow_big_nesting = TRUE
	atom_storage.locked = TRUE

/obj/item/mod/module/storage/on_install()
	var/datum/storage/modstorage = mod.create_storage(max_specific_storage = max_w_class, max_total_storage = max_combined_w_class, max_slots = max_items)
	modstorage.set_real_location(src)
	modstorage.allow_big_nesting = big_nesting
	atom_storage.locked = FALSE
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_OCLOTHING)
	if(istype(suit))
		RegisterSignal(suit, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(on_suit_unequip))

/obj/item/mod/module/storage/on_uninstall(deleting = FALSE)
	var/datum/storage/modstorage = mod.atom_storage
	atom_storage.locked = TRUE
	qdel(modstorage)
	if(!deleting)
		atom_storage.remove_all(get_turf(src))
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_OCLOTHING)
	if(istype(suit))
		UnregisterSignal(suit, COMSIG_ITEM_PRE_UNEQUIP)

/obj/item/mod/module/storage/proc/on_suit_unequip(obj/item/source, force, atom/newloc, no_move, invdrop, silent)
	if(QDELETED(source) || !mod.wearer || newloc == mod.wearer || !mod.wearer.s_store)
		return
	if(!atom_storage?.attempt_insert(mod.wearer.s_store, mod.wearer, override = TRUE))
		balloon_alert(mod.wearer, "storage failed!")
		to_chat(mod.wearer, span_warning("[src] fails to store [mod.wearer.s_store] inside itself!"))
		return
	to_chat(mod.wearer, span_notice("[src] stores [mod.wearer.s_store] inside itself."))
	mod.wearer.temporarilyRemoveItemFromInventory(mod.wearer.s_store)

/obj/item/mod/module/storage/large_capacity
	name = "\improper MOD expanded storage module"
	desc = "Reverse engineered by Nakamura Engineering from Donk Corporation designs, this system of hidden compartments \
		is entirely within the suit, distributing items and weight evenly to ensure a comfortable experience for the user; \
		whether smuggling, or simply hauling."
	icon_state = "storage_large"
	max_combined_w_class = 21
	max_items = 14
	max_w_class = WEIGHT_CLASS_LARGE

/obj/item/mod/module/storage/syndicate
	name = "\improper MOD syndicate storage module"
	desc = "A storage system using nanotechnology developed by Cybersun Industries, these compartments use \
		esoteric technology to compress the physical matter of items put inside of them, \
		essentially shrinking items for much easier and more portable storage."
	icon_state = "storage_syndi"
	max_combined_w_class = 30
	max_items = 21
	max_w_class = WEIGHT_CLASS_LARGE

/obj/item/mod/module/storage/belt
	name = "\improper MOD case storage module"
	desc = "Some concessions had to be made when creating a compressed modular suit core. \
	As a result, Roseus Galactic equipped their suit with a slimline storage case.  \
	If you find this equipped to a standard modular suit, then someone has almost certainly shortchanged you on a proper storage module."
	icon_state = "storage_case"
	complexity = 0
	max_w_class = WEIGHT_CLASS_SMALL
	removable = FALSE
	max_combined_w_class = 21
	max_items = 7
	required_slots = list(ITEM_SLOT_BELT)

/obj/item/mod/module/storage/bluespace
	name = "\improper MOD bluespace storage module"
	desc = "A storage system developed by Nanotrasen, these compartments employ \
		miniaturized bluespace pockets for the ultimate in storage technology; regardless of the weight of objects put inside."
	icon_state = "storage_bluespace"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_combined_w_class = 60
	max_items = 21
	big_nesting = TRUE

///Ion Jetpack - Lets the user fly freely through space using battery charge.
/obj/item/mod/module/jetpack
	name = "\improper MOD ion jetpack module"
	desc = "A series of electric thrusters installed across the suit, this is a module highly anticipated by trainee Engineers. \
		Rather than using gasses for combustion thrust, these jets are capable of accelerating ions using \
		charge from the suit's charge. Some say this isn't Nakamura Engineering's first foray into jet-enabled suits."
	icon_state = "jetpack"
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/jetpack)
	overlay_state_inactive = "module_jetpack"
	overlay_state_active = "module_jetpack_on"
	required_slots = list(ITEM_SLOT_BACK)
	/// Do we stop the wearer from gliding in space.
	var/stabilizers = FALSE
	/// Do we give the wearer a speed buff.
	var/full_speed = FALSE
	/// The ion trail particles left after the jetpack.
	var/datum/effect_system/trail_follow/ion/grav_allowed/ion_trail

/obj/item/mod/module/jetpack/Initialize(mapload)
	. = ..()
	ion_trail = new()
	ion_trail.auto_process = FALSE
	ion_trail.set_up(src)

/obj/item/mod/module/jetpack/Destroy()
	QDEL_NULL(ion_trail)
	return ..()

/obj/item/mod/module/jetpack/on_activation()
	ion_trail.start()
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED,  PROC_REF(move_react))
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_PRE_MOVE,  PROC_REF(pre_move_react))
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_SPACEMOVE,  PROC_REF(spacemove_react))
	if(full_speed)
		mod.wearer.add_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)

/obj/item/mod/module/jetpack/on_deactivation(display_message = TRUE, deleting = FALSE)
	ion_trail.stop()
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(mod.wearer, COMSIG_MOVABLE_SPACEMOVE)
	if(full_speed)
		mod.wearer.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/fullspeed)

/obj/item/mod/module/jetpack/get_configuration()
	. = ..()
	.["stabilizers"] = add_ui_configuration("Stabilizers", "bool", stabilizers)

/obj/item/mod/module/jetpack/configure_edit(key, value)
	switch(key)
		if("stabilizers")
			stabilizers = text2num(value)

/obj/item/mod/module/jetpack/proc/move_react(mob/user)
	SIGNAL_HANDLER

	if(!active)//If jet dont work, it dont work
		return
	if(!isturf(mod.wearer.loc))//You can't use jet in nowhere or from mecha/closet
		return
	if(!(mod.wearer.movement_type & FLOATING) || mod.wearer.buckled)//You don't want use jet in gravity or while buckled.
		return
	if(mod.wearer.pulledby)//You don't must use jet if someone pull you
		return
	if(mod.wearer.throwing)//You don't must use jet if you thrown
		return
	if(user.client && length(user.client.keys_held))//You use jet when press keys. yes.
		allow_thrust()

/obj/item/mod/module/jetpack/proc/pre_move_react(mob/user)
	SIGNAL_HANDLER

	ion_trail.oldposition = get_turf(src)

/obj/item/mod/module/jetpack/proc/spacemove_react(mob/user, movement_dir)
	SIGNAL_HANDLER

	if(active && (stabilizers || movement_dir))
		return COMSIG_MOVABLE_STOP_SPACEMOVE

/obj/item/mod/module/jetpack/proc/allow_thrust()
	if(!drain_power(use_power_cost))
		return
	ion_trail.generate_effect()
	return TRUE

/obj/item/mod/module/jetpack/advanced
	name = "\improper MOD advanced ion jetpack module"
	desc = "An improvement on the previous model of electric thrusters. This one achieves higher speeds through \
		mounting of more jets and a red paint applied on it."
	icon_state = "jetpack_advanced"
	overlay_state_inactive = "module_jetpackadv"
	overlay_state_active = "module_jetpackadv_on"
	full_speed = TRUE

///Status Readout - Puts a lot of information including health, nutrition, fingerprints, temperature to the suit TGUI.
/obj/item/mod/module/status_readout
	name = "\improper MOD status readout module"
	desc = "A once-common module, this technology unfortunately went out of fashion in the safer regions of space; \
		and found new life in the research networks of the Periphery. This particular unit hooks into the suit's spine, \
		capable of capturing and displaying all possible biometric data of the wearer; sleep, nutrition, fitness, fingerprints, \
		and even useful information such as their overall health and wellness. The vitals monitor also comes with a speaker, loud enough \
		to alert anyone nearby that someone has, in fact, died."
	icon_state = "status"
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0.1
	incompatible_modules = list(/obj/item/mod/module/status_readout)
	tgui_id = "status_readout"
	required_slots = list(ITEM_SLOT_BACK)
	/// Does this show damage types, body temp, satiety
	var/display_detailed_vitals = TRUE
	/// Does this show DNA data
	var/display_dna = FALSE
	/// Does this show the round ID and shift time?
	var/display_time = FALSE
	/// Death sound. May or may not be funny. Vareditable at your own risk.
	var/death_sound = 'sound/effects/flatline3.ogg'
	/// Death sound volume. Please be responsible with this.
	var/death_sound_volume = 50

/obj/item/mod/module/status_readout/add_ui_data()
	. = ..()
	.["display_time"] = display_time
	.["shift_time"] = station_time_timestamp()
	.["shift_id"] = GLOB.round_id
	.["health"] = mod.wearer?.health || 0
	.["health_max"] = mod.wearer?.getMaxHealth() || 0
	if(display_detailed_vitals)
		.["loss_brute"] = mod.wearer?.getBruteLoss() || 0
		.["loss_fire"] = mod.wearer?.getFireLoss() || 0
		.["loss_tox"] = mod.wearer?.getToxLoss() || 0
		.["loss_oxy"] = mod.wearer?.getOxyLoss() || 0
		.["body_temperature"] = mod.wearer?.bodytemperature || 0
		.["nutrition"] = mod.wearer?.nutrition || 0
	if(display_dna)
		.["dna_unique_identity"] = mod.wearer ? md5(mod.wearer.dna.unique_identity) : null
		.["dna_unique_enzymes"] = mod.wearer?.dna.unique_enzymes
	.["viruses"] = null
	if(!length(mod.wearer?.diseases))
		return .
	var/list/viruses = list()
	for(var/datum/disease/virus as anything in mod.wearer.diseases)
		var/list/virus_data = list()
		virus_data["name"] = virus.name
		virus_data["type"] = virus.spread_text
		virus_data["stage"] = virus.stage
		virus_data["maxstage"] = virus.max_stages
		virus_data["cure"] = virus.cure_text
		viruses += list(virus_data)
	.["viruses"] = viruses

	return .

/obj/item/mod/module/status_readout/get_configuration()
	. = ..()
	.["display_detailed_vitals"] = add_ui_configuration("Detailed Vitals", "bool", display_detailed_vitals)
	.["display_dna"] = add_ui_configuration("DNA Information", "bool", display_dna)

/obj/item/mod/module/status_readout/configure_edit(key, value)
	switch(key)
		if("display_detailed_vitals")
			display_detailed_vitals = text2num(value)
		if("display_dna")
			display_dna = text2num(value)

/obj/item/mod/module/status_readout/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_LIVING_DEATH, PROC_REF(death_sound))

/obj/item/mod/module/status_readout/on_part_deactivation(deleting)
	UnregisterSignal(mod.wearer, COMSIG_LIVING_DEATH)

/obj/item/mod/module/status_readout/proc/death_sound(mob/living/carbon/human/wearer)
	SIGNAL_HANDLER
	if(death_sound && death_sound_volume)
		playsound(wearer, death_sound, death_sound_volume, FALSE)

///Eating Apparatus - Lets the user eat/drink with the suit on.
/obj/item/mod/module/mouthhole
	name = "\improper MOD eating apparatus module"
	desc = "A favorite by Miners, this modification to the helmet utilizes a nanotechnology barrier infront of the mouth \
		to allow eating and drinking while retaining protection and atmosphere. However, it won't free you from masks, \
		lets pepper spray pass through and it will do nothing to improve the taste of a goliath steak."
	icon_state = "apparatus"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/mouthhole)
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	/// Former flags of the helmet.
	var/former_helmet_flags = NONE
	/// Former visor flags of the helmet.
	var/former_visor_helmet_flags = NONE
	/// Former flags of the mask.
	var/former_mask_flags = NONE
	/// Former visor flags of the mask.
	var/former_visor_mask_flags = NONE

/obj/item/mod/module/mouthhole/on_install()
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(helmet))
		former_helmet_flags = helmet.flags_cover
		former_visor_helmet_flags = helmet.visor_flags_cover
		helmet.flags_cover &= ~(HEADCOVERSMOUTH)
		helmet.visor_flags_cover &= ~(HEADCOVERSMOUTH)
	var/obj/item/clothing/mask = mod.get_part_from_slot(ITEM_SLOT_MASK)
	if(istype(mask))
		former_mask_flags = mask.flags_cover
		former_visor_mask_flags = mask.visor_flags_cover
		mask.flags_cover &= ~(MASKCOVERSMOUTH)
		mask.visor_flags_cover &= ~(MASKCOVERSMOUTH)

/obj/item/mod/module/mouthhole/on_uninstall(deleting = FALSE)
	if(deleting)
		return
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(helmet))
		helmet.flags_cover |= former_helmet_flags
		helmet.visor_flags_cover |= former_visor_helmet_flags
	var/obj/item/clothing/mask = mod.get_part_from_slot(ITEM_SLOT_MASK)
	if(istype(mask))
		mask.flags_cover |= former_mask_flags
		mask.visor_flags_cover |= former_visor_mask_flags

///EMP Shield - Protects the suit from EMPs.
/obj/item/mod/module/emp_shield
	name = "\improper MOD EMP shield module"
	desc = "A field inhibitor installed into the suit, protecting it against feedback such as \
		electromagnetic pulses that would otherwise damage the electronic systems of the suit or it's modules. \
		However, it will take from the suit's power to do so."
	icon_state = "empshield"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/emp_shield)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)

/obj/item/mod/module/emp_shield/on_install()
	mod.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)

/obj/item/mod/module/emp_shield/on_uninstall(deleting = FALSE)
	mod.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)

/obj/item/mod/module/emp_shield/advanced
	name = "\improper MOD advanced EMP shield module"
	desc = "An advanced field inhibitor installed into the suit, protecting it against feedback such as \
		electromagnetic pulses that would otherwise damage the electronic systems of the suit or electronic devices on the wearer, \
		including augmentations. However, it will take from the suit's power to do so."
	complexity = 2

/obj/item/mod/module/emp_shield/advanced/on_part_activation()
	mod.wearer.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)

/obj/item/mod/module/emp_shield/advanced/on_part_deactivation(deleting)
	mod.wearer.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)

///Flashlight - Gives the suit a customizable flashlight.
/obj/item/mod/module/flashlight
	name = "\improper MOD flashlight module"
	desc = "A simple pair of configurable flashlights installed on the left and right sides of the helmet, \
		useful for providing light in a variety of ranges and colors. \
		Some survivalists prefer the color green for their illumination, for reasons unknown."
	icon_state = "flashlight"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/flashlight)
	overlay_state_inactive = "module_light"
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_color = COLOR_WHITE
	light_range = 4
	light_power = 1
	light_on = FALSE
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK)
	/// Charge drain per range amount.
	var/base_power = DEFAULT_CHARGE_DRAIN * 0.1
	/// Minimum range we can set.
	var/min_range = 2
	/// Maximum range we can set.
	var/max_range = 5

/obj/item/mod/module/flashlight/on_activation()
	set_light_flags(light_flags | LIGHT_ATTACHED)
	set_light_on(active)
	active_power_cost = base_power * light_range

/obj/item/mod/module/flashlight/on_deactivation(display_message = TRUE, deleting = FALSE)
	set_light_flags(light_flags & ~LIGHT_ATTACHED)
	set_light_on(active)

/obj/item/mod/module/flashlight/on_process(delta_time)
	active_power_cost = base_power * light_range
	return ..()

/obj/item/mod/module/flashlight/generate_worn_overlay(mutable_appearance/standing)
	. = ..()
	if(!active)
		return
	var/mutable_appearance/light_icon = mutable_appearance(overlay_icon_file, "module_light_on", layer = standing.layer + 0.2)
	light_icon.appearance_flags = RESET_COLOR
	light_icon.color = light_color
	. += light_icon

/obj/item/mod/module/flashlight/get_configuration()
	. = ..()
	.["light_color"] = add_ui_configuration("Light Color", "color", light_color)
	.["light_range"] = add_ui_configuration("Light Range", "number", light_range)

/obj/item/mod/module/flashlight/configure_edit(key, value)
	switch(key)
		if("light_color")
			value = input(usr, "Pick new light color", "Flashlight Color") as color|null
			if(!value)
				return
			if(is_color_dark_with_saturation(value, 50))
				balloon_alert(mod.wearer, "too dark!")
				return
			set_light_color(value)
			mod.wearer.update_clothing(mod.slot_flags)
		if("light_range")
			set_light_range(clamp(value, min_range, max_range))

///Dispenser - Dispenses an item after a time passes.
/obj/item/mod/module/dispenser
	name = "\improper MOD burger dispenser module"
	desc = "A rare piece of technology reverse-engineered from a prototype found in a Donk Corporation vessel. \
		This can draw incredible amounts of power from the suit's cell to create edible organic matter in the \
		palm of the wearer's glove; however, research seemed to have entirely stopped at burgers. \
		Notably, all attempts to get it to dispense Earl Grey tea have failed."
	icon_state = "dispenser"
	module_type = MODULE_USABLE
	complexity = 3
	use_power_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/dispenser)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)
	/// Path we dispense.
	var/dispense_type = /obj/item/food/burger/plain
	/// Time it takes for us to dispense.
	var/dispense_time = 0 SECONDS

/obj/item/mod/module/dispenser/on_use()
	if(dispense_time && !do_after(mod.wearer, dispense_time, target = mod))
		balloon_alert(mod.wearer, "interrupted!")
		return FALSE
	var/obj/item/dispensed = new dispense_type(mod.wearer.loc)
	mod.wearer.put_in_hands(dispensed)
	balloon_alert(mod.wearer, "[dispensed] dispensed")
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)
	drain_power(use_power_cost)
	return dispensed

///Longfall - Nullifies fall damage, removing charge instead.
/obj/item/mod/module/longfall
	name = "\improper MOD longfall module"
	desc = "Useful for protecting both the suit and the wearer, \
		utilizing commonplace systems to convert the possible damage from a fall into kinetic charge, \
		as well as internal gyroscopes to ensure the user's safe falling. \
		Useful for mining, monorail tracks, or even skydiving!"
	icon_state = "longfall"
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/longfall)
	required_slots = list(ITEM_SLOT_FEET)

/obj/item/mod/module/longfall/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_LIVING_Z_IMPACT,  PROC_REF(z_impact_react))

/obj/item/mod/module/longfall/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_LIVING_Z_IMPACT)

/obj/item/mod/module/longfall/proc/z_impact_react(datum/source, levels, turf/fell_on)
	if(!drain_power(use_power_cost*levels))
		return
	new /obj/effect/temp_visual/mook_dust(fell_on)
	mod.wearer.Stun(levels * 1 SECONDS)
	mod.wearer.visible_message(
		span_notice("[mod.wearer] lands on [fell_on] safely, and quite stylishly on [p_their()] feet"),
		span_notice("[src] protects you from the damage!"),
	)
	return NO_Z_IMPACT_DAMAGE

///Thermal Regulator - Regulates the wearer's core temperature.
/obj/item/mod/module/thermal_regulator
	name = "\improper MOD thermal regulator module"
	desc = "Advanced climate control, using an inner body glove interwoven with thousands of tiny, \
		flexible cooling lines. This circulates coolant at various user-controlled temperatures, \
		ensuring they're comfortable; even if there are some that like it hot."
	icon_state = "regulator"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/thermal_regulator)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// The temperature we are regulating to.
	var/temperature_setting = BODYTEMP_NORMAL
	/// Minimum temperature we can set.
	var/min_temp = 293.15
	/// Maximum temperature we can set.
	var/max_temp = 318.15

/obj/item/mod/module/thermal_regulator/get_configuration()
	. = ..()
	.["temperature_setting"] = add_ui_configuration("Temperature", "number", temperature_setting - T0C)

/obj/item/mod/module/thermal_regulator/configure_edit(key, value)
	switch(key)
		if("temperature_setting")
			temperature_setting = clamp(value + T0C, min_temp, max_temp)

/obj/item/mod/module/thermal_regulator/on_active_process(delta_time)
	mod.wearer.adjust_bodytemperature(get_temp_change_amount((temperature_setting - mod.wearer.bodytemperature), 0.08 * delta_time))

///DNA Lock - Prevents people without the set DNA from activating the suit.
/obj/item/mod/module/dna_lock
	name = "\improper MOD DNA lock module"
	desc = "A module which engages with the various locks and seals tied to the suit's systems, \
		enabling it to only be worn by someone corresponding with the user's exact DNA profile; \
		however, this incredibly sensitive module is shorted out by EMPs."
	icon_state = "dnalock"
	module_type = MODULE_USABLE
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/dna_lock, /obj/item/mod/module/eradication_lock)
	cooldown_time = 0.5 SECONDS
	/// The DNA we lock with.
	var/dna = null

/obj/item/mod/module/dna_lock/on_install()
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE,  PROC_REF(on_mod_activation))
	RegisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL,  PROC_REF(on_mod_removal))
	RegisterSignal(mod, COMSIG_ATOM_EMP_ACT,  PROC_REF(on_emp))
	//RegisterSignal(mod, COMSIG_ATOM_EMAG_ACT,  PROC_REF(on_emag))

/obj/item/mod/module/dna_lock/on_uninstall(deleting = FALSE)
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)
	UnregisterSignal(mod, COMSIG_MOD_MODULE_REMOVAL)
	UnregisterSignal(mod, COMSIG_ATOM_EMP_ACT)
	//UnregisterSignal(mod, COMSIG_ATOM_EMAG_ACT)

/obj/item/mod/module/dna_lock/on_use()
	dna = mod.wearer.dna.unique_enzymes
	balloon_alert(mod.wearer, "dna updated")
	drain_power(use_power_cost)

/obj/item/mod/module/dna_lock/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	on_emp(src, severity)

/obj/item/mod/module/dna_lock/proc/dna_check(mob/user)
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/carbon_user = user
	if(!dna  || (carbon_user.has_dna() && carbon_user.dna.unique_enzymes == dna))
		return TRUE
	balloon_alert(user, "dna locked!")
	return FALSE

/obj/item/mod/module/dna_lock/proc/on_emp(datum/source, severity)
	SIGNAL_HANDLER

	dna = null

/obj/item/mod/module/dna_lock/on_emag(datum/source, mob/user, obj/item/card/emag/emag_card)
	..()

	dna = null

/obj/item/mod/module/dna_lock/proc/on_mod_activation(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!dna_check(user))
		return MOD_CANCEL_ACTIVATE

/obj/item/mod/module/dna_lock/proc/on_mod_removal(datum/source, mob/user)
	SIGNAL_HANDLER

	if(!dna_check(user))
		return MOD_CANCEL_REMOVAL

///Plasma Stabilizer - Prevents plasmamen from igniting in the suit
/obj/item/mod/module/plasma_stabilizer
	name = "\improper MOD plasma stabilizer module"
	desc = "This system essentially forms an atmosphere of its own inside the suit, \
		safely ejecting oxygen from the inside and allowing the wearer, a plasmaman, \
		to have their internal plasma circulate around them somewhat like a sauna. \
		This prevents them from self-igniting, and leads to greater comfort overall. \
		The purple glass of the visor seems to be constructed for nostalgic purposes."
	icon_state = "plasma_stabilizer"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/plasma_stabilizer)
	required_slots = list(ITEM_SLOT_HEAD)

/obj/item/mod/module/plasma_stabilizer/generate_worn_overlay(mutable_appearance/standing)
	if (!active)
		return list()
	var/mutable_appearance/visor_overlay = mod.get_visor_overlay(standing)
	visor_overlay.appearance_flags |= RESET_COLOR
	visor_overlay.color = COLOR_VOID_PURPLE
	return list(visor_overlay)

/obj/item/mod/module/plasma_stabilizer/on_equip()
	ADD_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION, REF(src))

/obj/item/mod/module/plasma_stabilizer/on_unequip()
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION, REF(src))

//Finally, https://pipe.miroware.io/5b52ba1d94357d5d623f74aa/mspfa/Nuke%20Ops/Panels/0648.gif can be real:
///Hat Stabilizer - Allows displaying a hat over the MOD-helmet, à la plasmamen helmets.
/obj/item/mod/module/hat_stabilizer
	name = "\improper MOD hat stabilizer module"
	desc = "A simple set of deployable stands, directly atop one's head; \
		these will deploy under a hat to keep it from falling off, allowing them to be worn atop the sealed helmet. \
		You still need to take the hat off your head while the helmet deploys, though. \
		This is a must-have for Nanotrasen Captains, enabling them to show off their authoritative hat even while in their MODsuit."
	icon_state = "hat_holder"
	incompatible_modules = list(/obj/item/mod/module/hat_stabilizer)
	required_slots = list(ITEM_SLOT_HEAD)
	/*Intentionally left inheriting 0 complexity and removable = TRUE;
	even though it comes inbuilt into the Magnate/Corporate MODS and spawns in maints, I like the idea of stealing them*/
	///Currently "stored" hat. No armor or function will be inherited, ONLY the icon.
	var/obj/item/clothing/head/attached_hat
	/// Original cover flags for the MOD helmet, before a hat is placed
	var/former_flags
	var/former_visor_flags

/obj/item/mod/module/hat_stabilizer/on_part_activation()
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(!istype(helmet))
		return
	RegisterSignal(helmet, COMSIG_ATOM_EXAMINE, PROC_REF(add_examine))
	RegisterSignal(helmet, COMSIG_ATOM_ATTACKBY,  PROC_REF(place_hat))
	RegisterSignal(helmet, COMSIG_ATOM_ATTACK_HAND_SECONDARY,  PROC_REF(remove_hat))

/obj/item/mod/module/hat_stabilizer/on_part_deactivation(deleting = FALSE)
	if(deleting)
		return
	if(attached_hat)	//knock off the helmet if its on their head. Or, technically, auto-rightclick it for them; that way it saves us code, AND gives them the bubble
		remove_hat(src, mod.wearer)
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(!istype(helmet))
		return
	UnregisterSignal(helmet, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(helmet, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(helmet, COMSIG_ATOM_ATTACK_HAND_SECONDARY)

/obj/item/mod/module/hat_stabilizer/proc/add_examine(datum/source, mob/user, list/base_examine)
	SIGNAL_HANDLER
	if(attached_hat)
		base_examine += span_notice("There's \a [attached_hat] placed on the helmet. Right-click to remove it.")
	else
		base_examine += span_notice("There's nothing placed on the helmet. Yet.")

/obj/item/mod/module/hat_stabilizer/proc/place_hat(datum/source, obj/item/hitting_item, mob/user)
	SIGNAL_HANDLER
	if(!istype(hitting_item, /obj/item/clothing/head))
		return
	var/obj/item/clothing/hat = hitting_item
	if(!mod.active)
		balloon_alert(user, "suit must be active!")
		return
	if(attached_hat)
		balloon_alert(user, "hat already attached!")
		return
	if(mod.wearer.transferItemToLoc(hitting_item, src, force = FALSE, silent = TRUE))
		attached_hat = hat
		var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
		if(istype(helmet))
			former_flags = helmet.flags_cover
			former_visor_flags = helmet.visor_flags_cover
			helmet.flags_cover |= attached_hat.flags_cover
			helmet.visor_flags_cover |= attached_hat.visor_flags_cover
		balloon_alert(user, "hat attached, right-click to remove")
		mod.wearer.update_clothing(mod.slot_flags)

/obj/item/mod/module/hat_stabilizer/generate_worn_overlay()
	. = ..()
	if(attached_hat)
		. += attached_hat.build_worn_icon(default_layer = ABOVE_BODY_FRONT_LAYER-0.1, default_icon_file = 'icons/mob/clothing/head/default.dmi')

/obj/item/mod/module/hat_stabilizer/proc/remove_hat(datum/source, mob/user)
	SIGNAL_HANDLER
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!attached_hat)
		return
	attached_hat.forceMove(drop_location())
	if(user.put_in_active_hand(attached_hat))
		balloon_alert(user, "hat removed")
	else
		balloon_alert_to_viewers("the hat falls to the floor!")
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(helmet))
		helmet.flags_cover = former_flags
		helmet.visor_flags_cover = former_visor_flags
	attached_hat = null
	mod.wearer.update_clothing(mod.slot_flags)

/obj/item/mod/module/hat_stabilizer/syndicate
	name = "\improper MOD elite hat stabilizer module"
	desc = "A simple set of deployable stands, directly atop one's head; \
		these will deploy under a hat to keep it from falling off, allowing them to be worn atop the sealed helmet. \
		You still need to take the hat off your head while the helmet deploys, though. This is a must-have for \
		Syndicate Operatives and Agents alike, enabling them to continue to style on the opposition even while in their MODsuit."
	complexity = 0
	removable = FALSE
