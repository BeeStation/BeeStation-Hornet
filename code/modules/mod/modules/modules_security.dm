//Security modules for MODsuits

///Cloaking - Lowers the user's visibility, can be interrupted by being touched or attacked.
/obj/item/mod/module/stealth
	name = "MOD prototype cloaking module"
	desc = "A complete retrofitting of the suit, this is a form of visual concealment tech employing esoteric technology \
		to bend light around the user, as well as mimetic materials to make the surface of the suit match the \
		surroundings based off sensor data. For some reason, this tech is rarely seen."
	icon_state = "cloak"
	module_type = MODULE_TOGGLE
	complexity = 4
	active_power_cost = DEFAULT_CHARGE_DRAIN * 2
	use_power_cost = DEFAULT_CHARGE_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/stealth)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// Whether or not the cloak turns off on bumping.
	var/bumpoff = TRUE
	/// The alpha applied when the cloak is on.
	var/stealth_alpha = 50

/obj/item/mod/module/stealth/on_activation()
	if(bumpoff)
		RegisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP, PROC_REF(unstealth))
	RegisterSignal(mod.wearer, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(on_unarmed_attack))
	RegisterSignal(mod.wearer, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignals(mod.wearer, list(COMSIG_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED), PROC_REF(unstealth))
	animate(mod.wearer, alpha = stealth_alpha, time = 1.5 SECONDS)
	drain_power(use_power_cost)

/obj/item/mod/module/stealth/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(bumpoff)
		UnregisterSignal(mod.wearer, COMSIG_LIVING_MOB_BUMP)
	UnregisterSignal(mod.wearer, list(COMSIG_HUMAN_MELEE_UNARMED_ATTACK, COMSIG_ITEM_ATTACK, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_BULLET_ACT, COMSIG_ATOM_HITBY, COMSIG_ATOM_HULK_ATTACK, COMSIG_ATOM_ATTACK_PAW, COMSIG_CARBON_CUFF_ATTEMPTED))
	animate(mod.wearer, alpha = 255, time = 1.5 SECONDS)

/obj/item/mod/module/stealth/proc/unstealth(datum/source)
	SIGNAL_HANDLER

	to_chat(mod.wearer, span_warning("[src] gets discharged from contact!"))
	do_sparks(2, TRUE, src)
	drain_power(use_power_cost)
	deactivate()

/obj/item/mod/module/stealth/proc/on_unarmed_attack(datum/source, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return
	unstealth(source)

/obj/item/mod/module/stealth/proc/on_bullet_act(datum/source, obj/projectile/projectile)
	SIGNAL_HANDLER

	if(projectile.nodamage)
		return
	unstealth(source)

/obj/item/mod/module/stealth/ninja
	name = "MOD advanced cloaking module"
	desc = "The latest in stealth technology, this module is a definite upgrade over previous versions. \
		The field has been tuned to be even more responsive and fast-acting, with enough stability to \
		continue operation of the field even if the user bumps into others. \
		The power draw has been reduced drastically, making this perfect for activities like \
		standing near sentry turrets for extended periods of time."
	icon_state = "cloak_ninja"
	bumpoff = FALSE
	stealth_alpha = 20
	active_power_cost = DEFAULT_CHARGE_DRAIN
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	cooldown_time = 3 SECONDS

///Magnetic Harness - Automatically puts guns in your suit storage when you drop them.
/obj/item/mod/module/magnetic_harness
	name = "MOD magnetic harness module"
	desc = "Based off old TerraGov harness kits, this magnetic harness automatically attaches dropped guns back to the wearer."
	icon_state = "mag_harness"
	complexity = 2
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/magnetic_harness)
	required_slots = list(ITEM_SLOT_OCLOTHING)
	/// Time before we activate the magnet.
	var/magnet_delay = 0.8 SECONDS
	/// The typecache of all guns we allow.
	var/static/list/guns_typecache
	/// The guns already allowed by the modsuit chestplate.
	var/list/already_allowed_guns = list()

/obj/item/mod/module/magnetic_harness/Initialize(mapload)
	. = ..()
	if(!guns_typecache)
		guns_typecache = typecacheof(list(/obj/item/gun/ballistic, /obj/item/gun/energy, /obj/item/gun/grenadelauncher, /obj/item/gun/chem, /obj/item/gun/syringe))

/obj/item/mod/module/magnetic_harness/on_install()
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_OCLOTHING)
	if(!istype(suit))
		return
	already_allowed_guns = guns_typecache & suit.allowed
	suit.allowed |= guns_typecache

/obj/item/mod/module/magnetic_harness/on_uninstall(deleting = FALSE)
	if(deleting)
		return
	var/obj/item/clothing/suit = mod.get_part_from_slot(ITEM_SLOT_OCLOTHING)
	if(!istype(suit))
		return
	suit.allowed -= (guns_typecache - already_allowed_guns)

/obj/item/mod/module/magnetic_harness/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(check_dropped_item))

/obj/item/mod/module/magnetic_harness/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_MOB_UNEQUIPPED_ITEM)

/obj/item/mod/module/magnetic_harness/proc/check_dropped_item(datum/source, obj/item/dropped_item, force, new_location)
	SIGNAL_HANDLER

	if(!is_type_in_typecache(dropped_item, guns_typecache))
		return
	if(new_location != get_turf(src))
		return
	addtimer(CALLBACK(src, PROC_REF(pick_up_item), dropped_item), magnet_delay)

/obj/item/mod/module/magnetic_harness/proc/pick_up_item(obj/item/item)
	if(!isturf(item.loc) || !item.Adjacent(mod.wearer))
		return
	if(!mod.wearer.equip_to_slot_if_possible(item, ITEM_SLOT_SUITSTORE, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	playsound(src, 'sound/items/modsuit/magnetic_harness.ogg', 50, TRUE)
	balloon_alert(mod.wearer, "[item] reattached")
	drain_power(use_power_cost)

/*
///Pepper Shoulders - When hit, reacts with a spray of pepper spray around the user.
/obj/item/mod/module/pepper_shoulders
	name = "MOD pepper shoulders module"
	desc = "A module that attaches two pepper sprayers on shoulders of a MODsuit, reacting to touch with a spray around the user."
	icon_state = "pepper_shoulder"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/pepper_shoulders)
	cooldown_time = 5 SECONDS
	overlay_state_inactive = "module_pepper"
	overlay_state_use = "module_pepper_used"
	required_slots = list(ITEM_SLOT_OCLOTHING)

/obj/item/mod/module/pepper_shoulders/on_part_activation()
	RegisterSignal(mod.wearer, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(on_check_block))

/obj/item/mod/module/pepper_shoulders/on_part_deactivation(deleting = FALSE)
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS)

/obj/item/mod/module/pepper_shoulders/on_use()
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)
	var/datum/reagents/capsaicin_holder = new(10)
	capsaicin_holder.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 10)
	var/datum/effect_system/smoke_spread/chem/quick/smoke = new
	smoke.set_up(capsaicin_holder, 1, get_turf(src))
	smoke.start()

/obj/item/mod/module/pepper_shoulders/proc/on_check_shields()
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return
	if(!check_power(use_power_cost))
		return
	mod.wearer.visible_message(span_warning("[src] reacts to the attack with a smoke of pepper spray!"), span_notice("Your [src] releases a cloud of pepper spray!"))
	used()

*/

///Holster - Instantly holsters any not huge gun.
/obj/item/mod/module/holster
	name = "MOD holster module"
	desc = "Based off typical storage compartments, this system allows the suit to holster a \
		standard firearm across its surface and allow for extremely quick retrieval. \
		While some users prefer the chest, others the forearm for quick deployment, \
		some law enforcement prefer the holster to extend from the thigh."
	icon_state = "holster"
	module_type = MODULE_USABLE
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/holster)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	required_slots = list(ITEM_SLOT_OCLOTHING|ITEM_SLOT_GLOVES|ITEM_SLOT_FEET)
	/// Gun we have holstered.
	var/obj/item/gun/holstered

/obj/item/mod/module/holster/on_use()
	if(!holstered)
		var/obj/item/gun/holding = mod.wearer.get_active_held_item()
		if(!holding)
			balloon_alert(mod.wearer, "nothing to holster!")
			return
		if(!istype(holding) || holding.w_class > WEIGHT_CLASS_BULKY)
			balloon_alert(mod.wearer, "it doesn't fit!")
			return
		if(mod.wearer.transferItemToLoc(holding, src, force = FALSE, silent = TRUE))
			holstered = holding
			balloon_alert(mod.wearer, "weapon holstered")
			playsound(src, 'sound/weapons/empty.ogg', 100, TRUE)
	else if(mod.wearer.put_in_active_hand(holstered, forced = FALSE, ignore_animation = TRUE))
		balloon_alert(mod.wearer, "weapon drawn")
		playsound(src, 'sound/weapons/empty.ogg', 100, TRUE)
	else
		balloon_alert(mod.wearer, "holster full!")

/obj/item/mod/module/holster/on_uninstall(deleting = FALSE)
	if(holstered)
		holstered.forceMove(drop_location())

/obj/item/mod/module/holster/Exited(atom/movable/gone, direction)
	if(gone == holstered)
		holstered = null
	return ..()

/obj/item/mod/module/holster/Destroy()
	QDEL_NULL(holstered)
	return ..()
