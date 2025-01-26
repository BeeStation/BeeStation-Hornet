//General modules for MODsuits

///Storage - Adds a storage component to the suit.
/obj/item/mod/module/storage
	name = "MOD storage module"
	desc = "What amounts to a series of integrated storage compartments and specialized pockets installed across \
		the surface of the suit, useful for storing various bits, and or bobs."
	icon_state = "storage"
	complexity = 3
	incompatible_modules = list(/obj/item/mod/module/storage, /obj/item/mod/module/plate_compression)
	required_slots = list(ITEM_SLOT_BACK)
	/// The storage component of the module.
	var/datum/component/storage/concrete/storage
	/// Max weight class of items in the storage.
	var/max_w_class = WEIGHT_CLASS_NORMAL
	/// Max combined weight of all items in the storage.
	var/max_combined_w_class = 15
	/// Max amount of items in the storage.
	var/max_items = 7

/obj/item/mod/module/storage/Initialize(mapload)
	. = ..()
	storage = AddComponent(/datum/component/storage/concrete)
	storage.max_w_class = max_w_class
	storage.max_combined_w_class = max_combined_w_class
	storage.max_items = max_items
	storage.allow_big_nesting = TRUE
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, TRUE)

/obj/item/mod/module/storage/on_install()
	var/datum/component/storage/modstorage = mod.AddComponent(/datum/component/storage, storage)
	modstorage.max_w_class = max_w_class
	modstorage.max_combined_w_class = max_combined_w_class
	modstorage.max_items = max_items
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, FALSE)
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_OCLOTHING)
	if(istype(suit))
		RegisterSignal(suit, COMSIG_ITEM_PRE_UNEQUIP, PROC_REF(on_suit_unequip))

/obj/item/mod/module/storage/on_uninstall(deleting = FALSE)
	var/datum/component/storage/modstorage = mod.GetComponent(/datum/component/storage)
	storage.slaves -= modstorage
	qdel(modstorage)
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_OCLOTHING)
	if(istype(suit))
		UnregisterSignal(suit, COMSIG_ITEM_PRE_UNEQUIP)
	if(!deleting)
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_QUICK_EMPTY, drop_location())
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, TRUE)

/obj/item/mod/module/storage/proc/on_suit_unequip(obj/item/source, force, atom/newloc, no_move, invdrop, silent)
	if(QDELETED(source) || !mod.wearer || newloc == mod.wearer || !mod.wearer.s_store)
		return
	to_chat(mod.wearer, span_notice("[src] tries to store [mod.wearer.s_store] inside itself."))
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_INSERT, mod.wearer.s_store, mod.wearer, TRUE)

/obj/item/mod/module/storage/large_capacity
	name = "MOD expanded storage module"
	desc = "Reverse engineered by Nakamura Engineering from Donk Corporation designs, this system of hidden compartments \
		is entirely within the suit, distributing items and weight evenly to ensure a comfortable experience for the user; \
		whether smuggling, or simply hauling."
	icon_state = "storage_large"
	max_combined_w_class = 21
	max_items = 14

/obj/item/mod/module/storage/syndicate
	name = "MOD syndicate storage module"
	desc = "A storage system using nanotechnology developed by Cybersun Industries, these compartments use \
		esoteric technology to compress the physical matter of items put inside of them, \
		essentially shrinking items for much easier and more portable storage."
	icon_state = "storage_syndi"
	max_combined_w_class = 30
	max_items = 21

/obj/item/mod/module/storage/bluespace
	name = "MOD bluespace storage module"
	desc = "A storage system developed by Nanotrasen, these compartments employ \
		miniaturized bluespace pockets for the ultimate in storage technology; regardless of the weight of objects put inside."
	icon_state = "storage_large"
	max_w_class = WEIGHT_CLASS_GIGANTIC
	max_combined_w_class = 60
	max_items = 21


///Ion Jetpack - Lets the user fly freely through space using battery charge.
/obj/item/mod/module/jetpack
	name = "MOD ion jetpack module"
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
	name = "MOD advanced ion jetpack module"
	desc = "An improvement on the previous model of electric thrusters. This one achieves higher speeds through \
		mounting of more jets and a red paint applied on it."
	icon_state = "jetpack_advanced"
	overlay_state_inactive = "module_jetpackadv"
	overlay_state_active = "module_jetpackadv_on"
	full_speed = TRUE

///Status Readout - Puts a lot of information including health, nutrition, fingerprints, temperature to the suit TGUI.
/obj/item/mod/module/status_readout
	name = "MOD status readout module"
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
		.["dna_unique_identity"] = mod.wearer ? md5(mod.wearer.dna.uni_identity) : null
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
	name = "MOD eating apparatus module"
	desc = "A favorite by Miners, this modification to the helmet utilizes a nanotechnology barrier infront of the mouth \
		to allow eating and drinking while retaining protection and atmosphere. However, it won't free you from masks, \
		lets pepper spray pass through and it will do nothing to improve the taste of a goliath steak."
	icon_state = "apparatus"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/mouthhole)
	overlay_state_inactive = "module_apparatus"
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
	name = "MOD EMP shield module"
	desc = "A field inhibitor installed into the suit, protecting it against feedback such as \
		electromagnetic pulses that would otherwise damage the electronic systems of the suit or devices on the wearer. \
		However, it will take from the suit's power to do so. Luckily, your PDA already has one of these."
	icon_state = "empshield"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/emp_shield)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)

/obj/item/mod/module/emp_shield/on_install()
	mod.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)

/obj/item/mod/module/emp_shield/on_uninstall(deleting = FALSE)
	mod.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_WIRES|EMP_PROTECT_CONTENTS)

///Flashlight - Gives the suit a customizable flashlight.
/obj/item/mod/module/flashlight
	name = "MOD flashlight module"
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
	name = "MOD burger dispenser module"
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

///Longfall - Nullifies fall damage, removing charge instead.
/obj/item/mod/module/longfall
	name = "MOD longfall module"
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
	name = "MOD thermal regulator module"
	desc = "Advanced climate control, using an inner body glove interwoven with thousands of tiny, \
		flexible cooling lines. This circulates coolant at various user-controlled temperatures, \
		ensuring they're comfortable; even if they're some that like it hot."
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
	name = "MOD DNA lock module"
	desc = "A module which engages with the various locks and seals tied to the suit's systems, \
		enabling it to only be worn by someone corresponding with the user's exact DNA profile; \
		however, this incredibly sensitive module is shorted out by EMPs. Luckily, cloning has been outlawed."
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
	SIGNAL_HANDLER

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
	name = "MOD plasma stabilizer module"
	desc = "This system essentially forms an atmosphere of its' own inside the suit, \
		safely ejecting oxygen from the inside and allowing the wearer, a plasmaman, \
		to have their internal plasma circulate around them somewhat like a sauna. \
		This prevents them from self-igniting, and leads to greater comfort overall. \
		The purple glass of the visor seems to be constructed for nostalgic purposes."
	icon_state = "plasma_stabilizer"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/plasma_stabilizer)
	overlay_state_inactive = "module_plasma"
	required_slots = list(ITEM_SLOT_HEAD)

/obj/item/mod/module/plasma_stabilizer/on_equip()
	ADD_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION, MOD_TRAIT)

/obj/item/mod/module/plasma_stabilizer/on_unequip()
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSELFIGNITION, MOD_TRAIT)

