//Antag modules for MODsuits

///Armor Booster - Grants your suit more armor and speed in exchange for EVA protection.
/obj/item/mod/module/armor_booster
	name = "\improper MOD armor booster module"
	desc = "A retrofitted series of retractable armor plates, allowing the suit to function as essentially power armor, \
		giving the user incredible protection against conventional firearms, or everyday attacks in close-quarters. \
		However, the additional plating cannot deploy alongside parts of the suit used for vacuum sealing, \
		so this extra armor provides zero ability for extravehicular activity while deployed."
	icon_state = "armor_booster"
	module_type = MODULE_TOGGLE
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/armor_booster, /obj/item/mod/module/welding)
	overlay_state_inactive = "module_armorbooster_off"
	overlay_state_active = "module_armorbooster_on"
	use_mod_colors = TRUE
	mask_worn_overlay = TRUE
	/// Whether or not this module removes pressure protection.
	var/remove_pressure_protection = TRUE
	/// Slowdown added to the control unit while this module is disabled
	var/space_slowdown = 0.5
	/// Armor values added to the suit parts.
	var/datum/armor/armor_mod = /datum/armor/mod_module_armor_boost
	/// List of parts of the suit that are spaceproofed, for giving them back the pressure protection.
	var/list/spaceproofed = list()

/obj/item/mod/module/armor_booster/no_speedbost
	space_slowdown = 0

/datum/armor/mod_module_armor_boost
	melee = 25
	bullet = 30
	laser = 15
	energy = 15

/obj/item/mod/module/armor_booster/on_part_activation()
	RegisterSignal(mod, COMSIG_MOD_UPDATE_SPEED, PROC_REF(on_update_speed))
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		head_cover.flash_protect = FLASH_PROTECTION_WELDER
	mod.update_speed()

/obj/item/mod/module/armor_booster/on_part_deactivation(deleting = FALSE)
	if(deleting)
		return
	UnregisterSignal(mod, COMSIG_MOD_UPDATE_SPEED)
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD) || mod.get_part_from_slot(ITEM_SLOT_MASK) || mod.get_part_from_slot(ITEM_SLOT_EYES)
	if(istype(head_cover))
		head_cover.flash_protect = initial(head_cover.flash_protect)
	mod.update_speed()

/obj/item/mod/module/armor_booster/on_activation()
	playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	balloon_alert(mod.wearer, "armor boosted, EVA lost")
	/*
	var/datum/mod_part/head_cover = mod.get_part_datum_from_slot(ITEM_SLOT_HEAD) || mod.get_part_datum_from_slot(ITEM_SLOT_MASK) || mod.get_part_datum_from_slot(ITEM_SLOT_EYES)
	if(head_cover)
		RegisterSignal(mod, COMSIG_MOD_PART_SEALED, PROC_REF(seal_helmet))
		seal_helmet(mod, head_cover)
	*/
	for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
		part.set_armor(part.get_armor().add_other_armor(armor_mod))
		if(!remove_pressure_protection || !isclothing(part))
			continue
		var/obj/item/clothing/clothing_part = part
		if(clothing_part.clothing_flags & STOPSPRESSUREDAMAGE)
			clothing_part.clothing_flags &= ~STOPSPRESSUREDAMAGE
			spaceproofed[clothing_part] = TRUE
	mod.update_speed()

/obj/item/mod/module/armor_booster/on_deactivation(display_message = TRUE, deleting = FALSE)
	if(!deleting)
		playsound(src, 'sound/mecha/mechmove03.ogg', 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		balloon_alert(mod.wearer, "armor retracts, EVA ready")
	/*
	var/datum/mod_part/head_cover = mod.get_part_datum_from_slot(ITEM_SLOT_HEAD) || mod.get_part_datum_from_slot(ITEM_SLOT_MASK) || mod.get_part_datum_from_slot(ITEM_SLOT_EYES)
	if(head_cover)
		UnregisterSignal(mod, COMSIG_MOD_PART_SEALED)
	*/
	for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
		part.set_armor(part.get_armor().subtract_other_armor(armor_mod))
		if(!remove_pressure_protection || !isclothing(part))
			continue
		var/obj/item/clothing/clothing_part = part
		if(spaceproofed[clothing_part])
			clothing_part.clothing_flags |= STOPSPRESSUREDAMAGE
	mod.update_speed()
	spaceproofed = list()

/obj/item/mod/module/armor_booster/proc/on_update_speed(datum/source, list/module_slowdowns, prevent_slowdown)
	SIGNAL_HANDLER
	if (!active)
		module_slowdowns += space_slowdown

/obj/item/mod/module/armor_booster/generate_worn_overlay(mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	overlay_state_active = "[initial(overlay_state_active)]-[mod.skin]"
	return ..()

/*
/obj/item/mod/module/armor_booster/proc/seal_helmet(datum/source, datum/mod_part/part)
	var/datum/mod_part/head_cover = mod.get_part_datum_from_slot(ITEM_SLOT_HEAD) || mod.get_part_datum_from_slot(ITEM_SLOT_MASK) || mod.get_part_datum_from_slot(ITEM_SLOT_EYES)
	if(part != head_cover)
		return
	if(part.sealed)
		ADD_TRAIT(mod.wearer, TRAIT_HEAD_INJURY_BLOCKED, REF(src))
	else
		REMOVE_TRAIT(mod.wearer, TRAIT_HEAD_INJURY_BLOCKED, REF(src))
*/

/obj/item/mod/module/armor_booster/on_install()
	RegisterSignal(mod, COMSIG_MOD_GET_VISOR_OVERLAY, PROC_REF(on_visor_overlay))

/obj/item/mod/module/armor_booster/on_uninstall(deleting)
	UnregisterSignal(mod, COMSIG_MOD_GET_VISOR_OVERLAY)

/obj/item/mod/module/armor_booster/proc/on_visor_overlay(datum/source,  mutable_appearance/standing, list/overrides)
	SIGNAL_HANDLER
	if (active)
		overrides += mutable_appearance(overlay_icon_file, "module_armorbooster_visor-[mod.skin]", layer = standing.layer + 0.1)

///Energy Shield - Gives you a rechargeable energy shield that nullifies attacks.
/obj/item/mod/module/energy_shield
	name = "\improper MOD energy shield module"
	desc = "A personal, protective forcefield typically seen in military applications. \
		This advanced deflector shield is essentially a scaled down version of those seen on starships, \
		and the power cost can be an easy indicator of this. However, it is capable of blocking nearly any incoming attack, \
		though with its low amount of separate charges, the user remains mortal."
	icon_state = "energy_shield"
	complexity = 3
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_power_cost = DEFAULT_CHARGE_DRAIN * 2
	incompatible_modules = list(/obj/item/mod/module/energy_shield)
	required_slots = list(ITEM_SLOT_BACK)
	/// Max charges of the shield.
	var/max_charges = 3
	/// The time it takes for the first charge to recover.
	var/recharge_start_delay = 20 SECONDS
	/// How much time it takes for charges to recover after they started recharging.
	var/charge_increment_delay = 1 SECONDS
	/// How much charge is recovered per recovery.
	var/charge_recovery = 1
	/// Whether or not this shield can lose multiple charges.
	var/lose_multiple_charges = FALSE
	/// The item path to recharge this shielkd.
	var/recharge_path
	/// The icon file of the shield.
	var/shield_icon_file = 'icons/effects/effects.dmi'
	/// The icon_state of the shield.
	var/shield_icon = "shield-red"
	/// Charges the shield should start with.
	var/charges

/obj/item/mod/module/energy_shield/Initialize(mapload)
	. = ..()
	charges = max_charges

/obj/item/mod/module/energy_shield/on_part_activation()
	mod.AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_start_delay, charge_increment_delay = charge_increment_delay, \
	charge_recovery = charge_recovery, lose_multiple_charges = lose_multiple_charges, recharge_path = recharge_path, starting_charges = charges, shield_icon_file = shield_icon_file, shield_icon = shield_icon)
	RegisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS,  PROC_REF(shield_reaction))

/obj/item/mod/module/energy_shield/on_part_deactivation(deleting = FALSE)
	var/datum/component/shielded/shield = mod.GetComponent(/datum/component/shielded)
	charges = shield.current_integrity
	qdel(shield)
	UnregisterSignal(mod.wearer, COMSIG_HUMAN_CHECK_SHIELDS)

/obj/item/mod/module/energy_shield/proc/shield_reaction(mob/living/carbon/human/owner, atom/movable/hitby, damage = 0, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0)
	if(SEND_SIGNAL(mod, COMSIG_ITEM_HIT_REACT, owner, hitby, attack_text, 0, damage, attack_type) & COMPONENT_HIT_REACTION_BLOCK)
		drain_power(use_power_cost)
		return SHIELD_BLOCK
	return NONE

/obj/item/mod/module/energy_shield/wizard
	name = "\improper MOD battlemage shield module"
	desc = "The caster wielding this spell gains a visible barrier around them, channeling arcane power through \
		specialized runes engraved onto the surface of the suit to generate a wall of force. \
		This shield can perfectly nullify attacks ranging from high-caliber rifles to magic missiles, \
		though can also be drained by more mundane attacks. It will not protect the caster from social ridicule."
	icon_state = "battlemage_shield"
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0 //magic
	use_power_cost = DEFAULT_CHARGE_DRAIN * 0 //magic too
	max_charges = 15
	recharge_start_delay = 0 SECONDS
	charge_recovery = 8
	shield_icon_file = 'icons/obj/magic.dmi'
	shield_icon = "mageshield"
	recharge_path = /obj/item/wizard_armour_charge
	required_slots = list()

///Magic Nullifier - Protects you from magic.
/obj/item/mod/module/anti_magic
	name = "\improper MOD magic nullifier module"
	desc = "A series of obsidian rods installed into critical points around the suit, \
		vibrated at a certain low frequency to enable them to resonate. \
		This creates a low-range, yet strong, magic nullification field around the user, \
		aided by a full replacement of the suit's normal coolant with holy water. \
		Spells will spall right off this field, though it'll do nothing to help others believe you about all this."
	icon_state = "magic_nullifier"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/anti_magic)
	required_slots = list(ITEM_SLOT_BACK)

/obj/item/mod/module/anti_magic/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_ANTIMAGIC, REF(src))
	ADD_TRAIT(mod.wearer, TRAIT_HOLY, REF(src))

/obj/item/mod/module/anti_magic/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_ANTIMAGIC, REF(src))
	REMOVE_TRAIT(mod.wearer, TRAIT_HOLY, REF(src))

/obj/item/mod/module/anti_magic/wizard
	name = "\improper MOD magic neutralizer module"
	desc = "The caster wielding this spell gains an invisible barrier around them, channeling arcane power through \
		specialized runes engraved onto the surface of the suit to generate anti-magic field. \
		The field will neutralize all magic that comes into contact with the user. \
		It will not protect the caster from social ridicule."
	icon_state = "magic_neutralizer"
	required_slots = list()

/obj/item/mod/module/anti_magic/wizard/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_ANTIMAGIC_NO_SELFBLOCK, REF(src))

/obj/item/mod/module/anti_magic/wizard/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_ANTIMAGIC_NO_SELFBLOCK, REF(src))

///Insignia - Gives you a skin specific stripe.
/obj/item/mod/module/insignia
	name = "\improper MOD insignia module"
	desc = "Despite the existence of IFF systems, radio communique, and modern methods of deductive reasoning involving \
		the wearer's own eyes, colorful paint jobs remain a popular way for different factions in the galaxy to display who \
		they are. This system utilizes a series of tiny moving paint sprayers to both apply and remove different \
		color patterns to and from the suit."
	icon_state = "insignia"
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/insignia)
	overlay_state_inactive = "module_insignia"
	mask_worn_overlay = TRUE

/obj/item/mod/module/insignia/generate_worn_overlay(mutable_appearance/standing)
	overlay_state_inactive = "[initial(overlay_state_inactive)]-[mod.skin]"
	. = ..()
	for(var/mutable_appearance/appearance as anything in .)
		appearance.color = color

/obj/item/mod/module/insignia/commander
	color = "#4980a5"

/obj/item/mod/module/insignia/security
	color = "#b30d1e"

/obj/item/mod/module/insignia/engineer
	color = "#e9c80e"

/obj/item/mod/module/insignia/medic
	color = "#ebebf5"

/obj/item/mod/module/insignia/janitor
	color = "#7925c7"

/obj/item/mod/module/insignia/clown
	color = "#ff1fc7"

/obj/item/mod/module/insignia/chaplain
	color = "#f0a00c"

/obj/item/mod/module/noslip
	name = "\improper MOD anti slip module"
	desc = "These are a modified variant of standard magnetic boots, utilizing piezoelectric crystals on the soles. \
		The two plates on the bottom of the boots automatically extend and magnetize as the user steps; \
		a pull that's too weak to offer them the ability to affix to a hull, but just strong enough to \
		protect against the fact that you didn't read the wet floor sign. Honk Co. has come out numerous times \
		in protest of these modules being legal."
	icon_state = "noslip"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.1
	incompatible_modules = list(/obj/item/mod/module/noslip)
	required_slots = list(ITEM_SLOT_FEET)

/obj/item/mod/module/noslip/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_NOSLIPWATER, REF(src))

/obj/item/mod/module/noslip/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_NOSLIPWATER, REF(src))

///Flamethrower - Launches fire across the area.
/obj/item/mod/module/flamethrower
	name = "\improper MOD flamethrower module"
	desc = "A custom-manufactured flamethrower, used to burn through your path. Burn well."
	icon_state = "flamethrower"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CHARGE_DRAIN * 3
	incompatible_modules = list(/obj/item/mod/module/flamethrower)
	cooldown_time = 2.5 SECONDS
	overlay_state_inactive = "module_flamethrower"
	overlay_state_active = "module_flamethrower_on"
	required_slots = list(ITEM_SLOT_OCLOTHING|ITEM_SLOT_ICLOTHING)

/obj/item/mod/module/flamethrower/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/obj/projectile/flame = new /obj/projectile/bullet/incendiary/backblast/flamethrower(mod.wearer.loc)
	flame.preparePixelProjectile(target, mod.wearer)
	flame.firer = mod.wearer
	playsound(src, 'sound/items/modsuit/flamethrower.ogg', 75, TRUE)
	INVOKE_ASYNC(flame, TYPE_PROC_REF(/obj/projectile, fire))
	drain_power(use_power_cost)

/obj/projectile/bullet/incendiary/backblast/flamethrower
	range = 6

///Power kick - Lets the user launch themselves at someone to kick them.
/obj/item/mod/module/power_kick
	name = "\improper MOD power kick module"
	desc = "This module uses high-power myomer to generate an incredible amount of energy, transferred into the power of a kick."
	icon_state = "power_kick"
	module_type = MODULE_ACTIVE
	removable = FALSE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/power_kick)
	cooldown_time = 5 SECONDS
	required_slots = list(ITEM_SLOT_FEET)
	/// Damage on kick.
	var/damage = 20
	/// The wound bonus of the kick.
	var/wounding_power = 35
	/// How long we knockdown for on the kick.
	var/knockdown_time = 2 SECONDS

/obj/item/mod/module/power_kick/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	mod.wearer.visible_message(span_warning("[mod.wearer] starts charging a kick!"), \
		blind_message = span_hear("You hear a charging sound."))
	playsound(src, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	balloon_alert(mod.wearer, "you start charging...")
	animate(mod.wearer, 0.3 SECONDS, pixel_z = 16, flags = ANIMATION_RELATIVE|SINE_EASING|EASE_OUT)
	addtimer(CALLBACK(mod.wearer, TYPE_PROC_REF(/atom, SpinAnimation), 3, 2), 0.3 SECONDS)
	if(!do_after(mod.wearer, 1 SECONDS, target = mod))
		animate(mod.wearer, 0.2 SECONDS, pixel_z = -16, flags = ANIMATION_RELATIVE|SINE_EASING|EASE_IN)
		return
	animate(mod.wearer)
	drain_power(use_power_cost)
	playsound(src, 'sound/items/modsuit/loader_launch.ogg', 75, TRUE)
	var/angle = get_angle(mod.wearer, target) + 180
	mod.wearer.transform = mod.wearer.transform.Turn(angle)
	RegisterSignal(mod.wearer, COMSIG_MOVABLE_IMPACT, PROC_REF(on_throw_impact))
	mod.wearer.throw_at(target, range = 7, speed = 2, thrower = mod.wearer, spin = FALSE, callback = CALLBACK(src, PROC_REF(on_throw_end), mod.wearer, -angle))

/obj/item/mod/module/power_kick/proc/on_throw_end(mob/user, angle)
	if(!user)
		return
	user.transform = user.transform.Turn(angle)
	animate(user, 0.2 SECONDS, pixel_z = -16, flags = ANIMATION_RELATIVE|SINE_EASING|EASE_IN)

/obj/item/mod/module/power_kick/proc/on_throw_impact(mob/living/source, atom/target, datum/thrownthing/thrownthing)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	if(!mod?.wearer)
		return
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_damage(damage, BRUTE, mod.wearer.get_combat_bodyzone(target)/*, wound_bonus = wounding_power*/)
		living_target.Knockdown(knockdown_time)
	else if(target.uses_integrity)
		target.take_damage(damage, BRUTE, MELEE)
	else
		return
	mod.wearer.do_attack_animation(target, ATTACK_EFFECT_SMASH)

///Chameleon - lets the suit disguise as any item that would fit on that slot.
/obj/item/mod/module/chameleon
	name = "\improper MOD chameleon module"
	desc = "A module using chameleon technology to disguise the MOD control unit as another backpack. Only works when the suit is deactivated."
	icon_state = "chameleon"
	module_type = MODULE_USABLE
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/chameleon)
	cooldown_time = 0.5 SECONDS
	allow_flags = MODULE_ALLOW_INACTIVE
	/// A list of all the items the suit can disguise as.
	var/list/possible_disguises = list()
	/// The path of the item we're disguised as.
	var/obj/item/current_disguise

/obj/item/mod/module/chameleon/on_install()
	var/list/all_disguises = sort_list(subtypesof(get_path_by_slot(mod.slot_flags)), GLOBAL_PROC_REF(cmp_typepaths_asc))
	for(var/clothing_path in all_disguises)
		var/obj/item/clothing = clothing_path
		if(!initial(clothing.icon_state))
			continue
		var/chameleon_item_name = "[initial(clothing.name)] ([initial(clothing.icon_state)])"
		possible_disguises[chameleon_item_name] = clothing_path

/obj/item/mod/module/chameleon/on_uninstall(deleting = FALSE)
	if(current_disguise)
		return_look()
	possible_disguises = null

/obj/item/mod/module/chameleon/used()
	if(mod.active || mod.activating)
		balloon_alert(mod.wearer, "unit active!")
		return FALSE
	return ..()

/obj/item/mod/module/chameleon/on_use()
	if(current_disguise)
		return_look()
		return
	var/picked_name = tgui_input_list(mod.wearer, "Select look to change into", "Chameleon Settings", possible_disguises)
	if(!possible_disguises[picked_name] || mod.active || mod.activating)
		return
	current_disguise = possible_disguises[picked_name]
	update_look()

/obj/item/mod/module/chameleon/proc/update_look()
	mod.name = initial(current_disguise.name)
	mod.desc = initial(current_disguise.desc)
	mod.icon_state = initial(current_disguise.icon_state)
	mod.icon = initial(current_disguise.icon)
	mod.worn_icon = initial(current_disguise.worn_icon)
	mod.alternate_worn_layer = initial(current_disguise.alternate_worn_layer)
	mod.lefthand_file = initial(current_disguise.lefthand_file)
	mod.righthand_file = initial(current_disguise.righthand_file)
	mod.worn_icon_state = initial(current_disguise.worn_icon_state)
	mod.item_state = initial(current_disguise.item_state)
	mod.wearer.update_clothing(mod.slot_flags)
	RegisterSignal(mod, COMSIG_MOD_ACTIVATE, PROC_REF(return_look))

/obj/item/mod/module/chameleon/proc/return_look()
	mod.name = "[mod.theme.name] [initial(mod.name)]"
	mod.desc = "[initial(mod.desc)] [mod.theme.desc]"
	mod.update_icon_state()
	var/list/mod_skin = mod.theme.variants[mod.skin]
	mod.icon = mod_skin[MOD_ICON_OVERRIDE] || 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	mod.worn_icon = mod_skin[MOD_WORN_ICON_OVERRIDE] || 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	mod.lefthand_file = initial(mod.lefthand_file)
	mod.righthand_file = initial(mod.righthand_file)
	mod.worn_icon_state = null
	mod.item_state = null
	mod.wearer.update_clothing(mod.slot_flags)
	current_disguise = null
	UnregisterSignal(mod, COMSIG_MOD_ACTIVATE)

///Plate Compression - Compresses the suit to normal size
/obj/item/mod/module/plate_compression
	name = "\improper MOD plate compression module"
	desc = "A module that keeps the suit in a very tightly fit state, lowering the overall size. \
		Due to the pressure on all the parts, typical storage modules do not fit."
	icon_state = "plate_compression"
	complexity = 2
	incompatible_modules = list(/obj/item/mod/module/plate_compression, /obj/item/mod/module/storage)
	/// The size we set the suit to.
	var/new_size = WEIGHT_CLASS_NORMAL
	/// The suit's size before the module is installed.
	var/old_size

/obj/item/mod/module/plate_compression/on_install()
	old_size = mod.w_class
	mod.w_class = new_size

/obj/item/mod/module/plate_compression/on_uninstall(deleting = FALSE)
	mod.w_class = old_size
	old_size = null
	if(!mod.loc)
		return
	var/datum/storage/holding_storage = mod.loc.atom_storage
	if(!holding_storage || holding_storage.max_specific_storage >= mod.w_class)
		return
	mod.forceMove(drop_location())

/obj/item/mod/module/demoralizer
	name = "\improper MOD psi-echo demoralizer module"
	desc = "One incredibly morbid member of the RND team at Roseus Galactic posed a question to her colleagues. \
	'I desire the power to scar my enemies mentally as I murder them. Who will stop me implementing this in our next project?' \
	And thus the Psi-Echo Demoralizer Device was reluctantly invented. The future of psychological warfare, today!"
	icon_state = "brain_hurties"
	complexity = 0
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.1
	removable = FALSE
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	var/datum/proximity_monitor/advanced/demoraliser/demoralizer

/obj/item/mod/module/demoralizer/on_part_activation()
	var/datum/demoralise_moods/module/mood_category = new()
	demoralizer = new(mod.wearer, 7, TRUE, mood_category)

/obj/item/mod/module/demoralizer/on_part_deactivation(deleting = FALSE)
	QDEL_NULL(demoralizer)

/obj/item/mod/module/infiltrator
	name = "\improper MOD infiltration core programs module"
	desc = "The primary stealth systems operating within the suit. Utilizing electromagnetic signals, \
		the wearer simply cannot be observed closely, or heard clearly by those around them.\
		It also contains some dampening systems to help protect a user from blows to the head."
	icon_state = "infiltrator"
	complexity = 0
	removable = FALSE
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0
	incompatible_modules = list(/obj/item/mod/module/infiltrator, /obj/item/mod/module/armor_booster, /obj/item/mod/module/welding)
	required_slots = list(ITEM_SLOT_FEET, ITEM_SLOT_HEAD, ITEM_SLOT_OCLOTHING)

/obj/item/mod/module/infiltrator/on_install()
	mod.item_flags |= EXAMINE_SKIP

/obj/item/mod/module/infiltrator/on_uninstall(deleting = FALSE)
	mod.item_flags &= ~EXAMINE_SKIP

/obj/item/mod/module/infiltrator/on_part_activation()
	ADD_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, MOD_TRAIT)
	ADD_TRAIT(mod.wearer, TRAIT_UNKNOWN, MOD_TRAIT)
	RegisterSignal(mod.wearer, COMSIG_TRY_MODIFY_SPEECH, PROC_REF(on_speech_modification))
	//var/obj/item/organ/tongue/user_tongue = mod.wearer.get_organ_slot(ORGAN_SLOT_TONGUE)
	//user_tongue.temp_say_mod = "states"
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(head_cover))
		head_cover.flash_protect = FLASH_PROTECTION_WELDER_HYPER_SENSITIVE

/obj/item/mod/module/infiltrator/on_part_deactivation(deleting = FALSE)
	REMOVE_TRAIT(mod.wearer, TRAIT_SILENT_FOOTSTEPS, MOD_TRAIT)
	REMOVE_TRAIT(mod.wearer, TRAIT_UNKNOWN, MOD_TRAIT)
	UnregisterSignal(mod.wearer, COMSIG_TRY_MODIFY_SPEECH)
	//var/obj/item/organ/tongue/user_tongue = mod.wearer.get_organ_slot(ORGAN_SLOT_TONGUE)
	//user_tongue.temp_say_mod = initial(user_tongue.temp_say_mod)
	if(deleting)
		return
	var/obj/item/clothing/head_cover = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(istype(head_cover))
		head_cover.flash_protect = initial(head_cover.flash_protect)

/obj/item/mod/module/infiltrator/proc/on_speech_modification(datum/source)
	SIGNAL_HANDLER
	if(!mod.active)
		return
	//Prevent speech modifications if the suit is active
	return PREVENT_MODIFY_SPEECH
