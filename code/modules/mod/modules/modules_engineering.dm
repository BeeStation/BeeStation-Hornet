//Engineering modules for MODsuits

///Welding Protection - Makes the helmet protect from flashes and welding.
/obj/item/mod/module/welding
	name = "\improper MOD welding protection module"
	desc = "A module installed into the visor of the suit, this projects a \
		polarized, holographic overlay in front of the user's eyes. It's rated high enough for \
		immunity against extremities such as spot and arc welding, solar eclipses, and handheld flashlights."
	icon_state = "welding"
	complexity = 1
	incompatible_modules = list(/obj/item/mod/module/welding, /obj/item/mod/module/armor_booster)
	overlay_state_inactive = "module_welding"
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)

/obj/item/mod/module/welding/on_part_activation()
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		//this is a screen that displays an image, so flash sensitives can use this to protect against flashes.
		head_cover.flash_protect = FLASH_PROTECTION_WELDER_HYPER_SENSITIVE

/obj/item/mod/module/welding/on_part_deactivation(deleting = FALSE)
	if(deleting)
		return
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		head_cover.flash_protect = initial(head_cover.flash_protect)

///T-Ray Scan - Scans the terrain for undertile objects.
/obj/item/mod/module/t_ray
	name = "\improper MOD t-ray scan module"
	desc = "A module installed into the visor of the suit, allowing the user to use a pulse of terahertz radiation \
		to essentially echolocate things beneath the floor, mostly cables and pipes. \
		A staple of atmospherics work, and counter-smuggling work."
	icon_state = "tray"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/t_ray)
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_EYES|ITEM_SLOT_MASK)
	/// T-ray scan range.
	var/range = 4

/obj/item/mod/module/t_ray/on_active_process(delta_time)
	t_ray_scan(mod.wearer, 0.8 SECONDS, range)

///Magnetic Stability - Gives the user a slowdown but makes them negate gravity and be immune to slips.
/obj/item/mod/module/magboot
	name = "\improper MOD magnetic stability module"
	desc = "These are powerful electromagnets fitted into the suit's boots, allowing users both \
		excellent traction no matter the condition indoors, and to essentially hitch a ride on the exterior of a hull. \
		However, these basic models do not feature computerized systems to automatically toggle them on and off, \
		so numerous users report a certain stickiness to their steps."
	icon_state = "magnet"
	module_type = MODULE_TOGGLE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/magboot, /obj/item/mod/module/atrocinator)
	required_slots = list(ITEM_SLOT_FEET)
	/// Slowdown added onto the suit.
	var/slowdown_active = 0.5

/obj/item/mod/module/magboot/on_install()
	RegisterSignal(mod, COMSIG_MOD_UPDATE_SPEED, PROC_REF(on_update_speed))

/obj/item/mod/module/magboot/on_uninstall(deleting)
	UnregisterSignal(mod, COMSIG_MOD_UPDATE_SPEED)

/obj/item/mod/module/magboot/on_activation()
	ADD_TRAIT(mod.wearer, TRAIT_NEGATES_GRAVITY, REF(src))
	ADD_TRAIT(mod.wearer, TRAIT_NOSLIPWATER, REF(src))
	mod.update_speed()

/obj/item/mod/module/magboot/on_deactivation(display_message = TRUE, deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_NEGATES_GRAVITY, REF(src))
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSLIPWATER, REF(src))
	mod.update_speed()

/obj/item/mod/module/magboot/proc/on_update_speed(datum/source, list/module_slowdowns, prevent_slowdown)
	SIGNAL_HANDLER
	if (!prevent_slowdown && active)
		module_slowdowns += slowdown_active

/obj/item/mod/module/magboot/advanced
	name = "\improper MOD advanced magnetic stability module"
	desc = "These are powerful electromagnets fitted into the suit's boots, allowing users both \
		excellent traction no matter the condition indoors, and to essentially hitch a ride on the exterior of a hull. \
		This advanced model features computerized systems to automatically toggle the magnets on and off as the user steps, \
		allowing them to walk unimpeded."
	removable = FALSE
	complexity = 0
	slowdown_active = 0

///Emergency Tether - Shoots a grappling hook projectile in 0g that throws the user towards it.
/obj/item/mod/module/tether
	name = "\improper MOD emergency tether module"
	desc = "A custom-built grappling-hook powered by a winch capable of hauling the user. \
		While some older models of cargo-oriented grapples have capacities of a few tons, \
		these are only capable of working in zero-gravity environments, a blessing to some Engineers."
	icon_state = "tether"
	module_type = MODULE_ACTIVE
	module_type = MODULE_ACTIVE
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/tether)
	cooldown_time = 1.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/tether/used()
	if(mod.wearer.has_gravity(get_turf(src)))
		balloon_alert(mod.wearer, "too much gravity!")
		playsound(src, 'sound/weapons/gun_dry_fire.ogg', 25, TRUE)
		return FALSE
	return ..()

/obj/item/mod/module/tether/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/projectile/tether = new /obj/projectile/tether(mod.wearer.loc)
	tether.preparePixelProjectile(target, mod.wearer)
	tether.firer = mod.wearer
	playsound(src, 'sound/weapons/batonextend.ogg', 25, TRUE)
	INVOKE_ASYNC(tether, TYPE_PROC_REF(/obj/projectile, fire))
	drain_power(use_power_cost)

/obj/projectile/tether
	name = "tether"
	icon_state = "tether_projectile"
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	damage = 0
	nodamage = TRUE
	range = 10
	hitsound = 'sound/weapons/batonextend.ogg'
	hitsound_wall = 'sound/weapons/batonextend.ogg'
	suppressed = SUPPRESSED_VERY
	hit_threshhold = LATTICE_LAYER
	/// Reference to the beam following the projectile.
	var/line

/obj/projectile/tether/fire(setAngle)
	if(firer)
		line = firer.Beam(src, "line", 'icons/obj/clothing/modsuit/mod_modules.dmi', emissive = FALSE)
	..()

/obj/projectile/tether/on_hit(atom/target)
	. = ..()
	if(firer)
		firer.throw_at(target, 10, 1, firer, FALSE, FALSE, null, MOVE_FORCE_NORMAL, TRUE)

/obj/projectile/tether/Destroy()
	QDEL_NULL(line)
	return ..()

/*
///Radiation Protection - Protects the user from radiation, gives them a geiger counter and rad info in the panel.
/obj/item/mod/module/rad_protection
	name = "\improper MOD radiation protection module"
	desc = "A module utilizing polymers and reflective shielding to protect the user against ionizing radiation; \
		a common danger in space. This comes with software to notify the wearer that they're even in a radioactive area, \
		giving a voice to an otherwise silent killer."
	icon_state = "radshield"
	complexity = 2
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	incompatible_modules = list(/obj/item/mod/module/rad_protection)
	tgui_id = "rad_counter"
	required_slots = list(ITEM_SLOT_HEAD|ITEM_SLOT_MASK, ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING, ITEM_SLOT_GLOVES, ITEM_SLOT_FEET)
	/// Radiation threat level being perceived.
	var/perceived_threat_level

/obj/item/mod/module/rad_protection/on_part_activation()
	AddComponent(/datum/component/geiger_sound)
	ADD_TRAIT(mod.wearer, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK, REF(src))
	RegisterSignal(mod.wearer, COMSIG_IN_RANGE_OF_IRRADIATION, PROC_REF(on_pre_potential_irradiation))
	for(var/obj/item/part in mod.get_parts(all = TRUE))
		ADD_TRAIT(part, TRAIT_RADIATION_PROTECTED_CLOTHING, MOD_TRAIT)

/obj/item/mod/module/rad_protection/on_part_deactivation(deleting = FALSE)
	qdel(GetComponent(/datum/component/geiger_sound))
	REMOVE_TRAIT(mod.wearer, TRAIT_BYPASS_EARLY_IRRADIATED_CHECK, REF(src))
	UnregisterSignal(mod.wearer, COMSIG_IN_RANGE_OF_IRRADIATION)
	for(var/obj/item/part in mod.get_parts(all = TRUE))
		REMOVE_TRAIT(part, TRAIT_RADIATION_PROTECTED_CLOTHING, MOD_TRAIT)

/obj/item/mod/module/rad_protection/add_ui_data()
	. = ..()
	.["is_user_irradiated"] = mod.wearer ? HAS_TRAIT(mod.wearer, TRAIT_IRRADIATED) : FALSE
	.["background_radiation_level"] = perceived_threat_level
	.["health_max"] = mod.wearer?.getMaxHealth() || 0
	.["loss_tox"] = mod.wearer?.getToxLoss() || 0

/obj/item/mod/module/rad_protection/proc/on_pre_potential_irradiation(datum/source, datum/radiation_pulse_information/pulse_information, insulation_to_target)
	SIGNAL_HANDLER

	perceived_threat_level = get_perceived_radiation_danger(pulse_information, insulation_to_target)
	addtimer(VARSET_CALLBACK(src, perceived_threat_level, null), TIME_WITHOUT_RADIATION_BEFORE_RESET, TIMER_UNIQUE | TIMER_OVERRIDE)
*/

///Constructor - Lets you build quicker and create RCD holograms.
/obj/item/mod/module/constructor
	name = "\improper MOD constructor module"
	desc = "This module entirely occupies the wearer's forearm, notably causing conflict with \
		advanced arm servos meant to carry crewmembers. However, it functions as an \
		extremely advanced construction hologram scanner, as well as containing the \
		latest engineering schematics combined with inbuilt memory to help the user build walls."
	icon_state = "constructor"
	module_type = MODULE_USABLE
	complexity = 2
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/constructor, /obj/item/mod/module/quick_carry)
	cooldown_time = 11 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/constructor/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_QUICK_BUILD, REF(src))

/obj/item/mod/module/constructor/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_QUICK_BUILD, REF(src))

/obj/item/mod/module/constructor/on_use()
	rcd_scan(src, fade_time = 10 SECONDS)
	drain_power(use_power_cost)

///Mister - Sprays water over an area.
/obj/item/mod/module/mister
	name = "\improper MOD water mister module"
	desc = "A module containing a mister, able to spray it over areas."
	icon_state = "mister"
	module_type = MODULE_ACTIVE
	complexity = 2
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/reagent_containers/spray/mister
	incompatible_modules = list(/obj/item/mod/module/mister)
	cooldown_time = 0.5 SECONDS
	/// Volume of our reagent holder.
	var/volume = 500

/obj/item/mod/module/mister/Initialize(mapload)
	create_reagents(volume, OPENCONTAINER)
	return ..()

///Resin Mister - Sprays resin over an area.
/obj/item/mod/module/mister/atmos
	name = "\improper MOD resin mister module"
	desc = "An atmospheric resin mister, able to fix up areas quickly."
	device = /obj/item/extinguisher/mini/nozzle/mod
	volume = 250

/obj/item/mod/module/mister/atmos/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/water, volume)

/obj/item/mod/module/mister/atmos/examine(mob/user)
	. = ..()
	. += span_notice("It contains:")
	if (QDELETED(device))
		return
	. += device.examine(user)

/obj/item/mod/module/mister/atmos/on_reagent_change(changetype)
	. = ..()
	if (QDELETED(device))
		return
	device.update_icon()

/obj/item/mod/module/mister/atmos/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/atmostank_upgrade))
		if (QDELETED(device))
			return ..()
		var/obj/item/extinguisher/mini/nozzle/mod/noz = device
		noz.install_upgrade(I, user)
	return ..()

/obj/item/extinguisher/mini/nozzle/mod
	name = "\improper MOD atmospheric mister"
	desc = "An atmospheric resin mister with three modes, mounted as a module."
