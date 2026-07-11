

#define LOW_POWER_THRESHOLD 250

//TODO: add emp_act
//TODO: leap legs (needs finishing)
//TODO: cooling system
//TODO: stock parts fabricator
//TODO: disposable EMP shield
//TODO: make IPCs shutdown when battery runs out //probably done
//TODO: System Underclocker: allows IPCs to stay standing with no power (for some sort of drawback)
//TODO: Upgrade circuit control??
//TODO: Upgrade circuit actions
//TODO: IPC law module / emag working on IPC //not this pr
//TODO: SPRITES!!
//TODO: test action runtime (signal overriding)
//TODO: improve charge cannon
//TODO: fix armor not applying
//TODO: subdermal ID
//TODO: look into deactivate() returning proper values, as it passes them into action on_deactivate()
//TODO: refactor nutrition so it I dont have to copy paste the status effect 4 times
//TODO: action sprite for ex-cannon

//not so sure about making a global proc for this TODO: fix this warning
proc/get_ipc_upgrade_by_slot(list/datum/status_effect/effects, slot) as /datum/status_effect/ipc_upgrade
	if(!effects)
		return
	for(var/datum/status_effect/ipc_upgrade/upgrade in effects)
		if(upgrade.slot == slot)
			return upgrade

/datum/status_effect/ipc_upgrade/
	id = "ipc upgrade"
	alert_type = null
	on_remove_on_mob_delete = TRUE

	var/name = "Generic Upgrade"
	///What slot this occupies. Only one upgrade per slot.
	var/slot = UPGRADE_CORE
	///Passive power requirement
	var/active_power_requirement = 0
	///Activation power requirement
	var/power_requirement = 0
	///Whether this upgrade should activate once and reset (rather than making active = TRUE)
	var/singleton = FALSE
	///Whether this should process or not
	var/active = FALSE
	///The type of ipc_upgrade_action this upgrade uses, can be null for no action
	var/action_type = null
	///What the action icon_state will be. Does nothing if action_type is not specified
	var/action_icon = null
	///The actual action, created from action_type
	var/datum/action/innate/ipc_upgrade_action/action
	///The length of the cooldown between activations
	var/cooldown_length = 1 SECONDS

	var/overlay_file = 'icons/obj/ipc_upgrade_worn.dmi'
	///A nullable list containing the overlays to add
	var/upgrade_overlays = null

	var/list/mutable_appearance/mut_appearances = list()

/datum/status_effect/ipc_upgrade/on_apply()
	. = ..()
	if(action_type)
		action = new action_type(src)
		if(action_icon)
			action.button_icon_state = action_icon
		action.Grant(owner)
	if(upgrade_overlays && overlay_file)
		for(var/overlay in upgrade_overlays)
			var/mut_appearance = mutable_appearance(overlay_file, overlay, CALCULATE_MOB_OVERLAY_LAYER(upgrade_overlays[overlay]))
			mut_appearances += mut_appearance
			owner.add_overlay(mut_appearance)
		owner.update_appearance(UPDATE_ICON)
	RegisterSignal(owner, COMSIG_ATOM_EMP_ACT, PROC_REF(emp_act))

/datum/status_effect/ipc_upgrade/on_remove()
	if(active)
		deactivate()
	for(var/mutable_appearance/mut_appearance in mut_appearances)
		owner.cut_overlay(mut_appearance)
	QDEL_NULL(action)
	QDEL_LIST(mut_appearances)

/datum/status_effect/ipc_upgrade/tick(seconds_between_ticks)
	if(!should_process())
		return FALSE
	if(drain_cell(active_power_requirement * seconds_between_ticks))
		return TRUE
	to_chat(owner, span_notice("The [name] runs out of power!"))
	playsound(owner, 'sound/machines/apc/PowerDown_001.ogg', 10)
	if(action)
		action.deactivate(owner)
	deactivate()

/datum/status_effect/ipc_upgrade/proc/should_process()
	return active

/datum/status_effect/ipc_upgrade/proc/can_activate()
	return !active && can_drain_cell(power_requirement + active_power_requirement)

/datum/status_effect/ipc_upgrade/proc/toggle(atom/target)
	if(!active)
		activate()
	else
		deactivate()

/datum/status_effect/ipc_upgrade/proc/activate(atom/target)
	if(!can_activate())
		playsound(owner, 'sound/machines/buzz-sigh.ogg', 10)
		to_chat(owner, span_notice("[name] failed to activate!"))
		return FALSE
	if(!singleton)
		active = TRUE
	if(action)
		action.start_cooldown(cooldown_length)
	on_activate(target)
	return TRUE

/// Called by activate(). target can and will be null, sometimes even for targeted upgrades.
/datum/status_effect/ipc_upgrade/proc/on_activate(atom/target)
	return

/datum/status_effect/ipc_upgrade/proc/deactivate()
	if(!active)
		return
	active = FALSE
	on_deactivate()

/datum/status_effect/ipc_upgrade/proc/on_deactivate()
	return

/datum/status_effect/ipc_upgrade/proc/can_drain_cell(amount, obj/item/organ/stomach/battery/battery)
	if(!amount)
		return TRUE
	if(!battery)
		if(!istype(owner, /mob/living/carbon))
			return FALSE
		if(!istype(owner.get_organ_slot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/battery))
			return FALSE
		battery = owner.get_organ_slot(ORGAN_SLOT_STOMACH)
	if((battery.charge - LOW_POWER_THRESHOLD) < amount)
		return FALSE
	return TRUE

/datum/status_effect/ipc_upgrade/proc/drain_cell(amount)
	if(!amount)
		return TRUE
	if(!iscarbon(owner))
		return FALSE
	if(!istype(owner.get_organ_slot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/battery))
		return FALSE
	var/obj/item/organ/stomach/battery/battery = owner.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!can_drain_cell(amount, battery))
		return FALSE
	battery.adjust_charge(-amount)
	return TRUE

/datum/status_effect/ipc_upgrade/proc/emp_act(severity, protection)
	SIGNAL_HANDLER
	return

/datum/status_effect/ipc_upgrade/ui_data()
	var/list/data = list()
	data["name"] = name
	data["power_req"] = power_requirement
	data["active_power_req"] = active_power_requirement
	return data

/datum/action/innate/ipc_upgrade_action
	name = "Generic Upgrade Action"
	button_icon = 'icons/hud/actions/actions_silicon.dmi'
	var/datum/status_effect/ipc_upgrade/upgrade = null

/datum/action/innate/ipc_upgrade_action/New(datum/status_effect/ipc_upgrade/new_upgrade)
	..()
	name = "Activate [new_upgrade.name]"
	enable_text = "Activated [new_upgrade.name]!"
	disable_text = "Deactivated [new_upgrade.name]!"
	upgrade = new_upgrade

/datum/action/innate/ipc_upgrade_action/is_available(feedback = FALSE)
	if(!..())
		return FALSE
	if(upgrade.active)
		return TRUE
	if(!upgrade.can_activate())
		return FALSE
	return TRUE

/datum/action/innate/ipc_upgrade_action/toggleable
	toggleable = TRUE

/datum/action/innate/ipc_upgrade_action/toggleable/on_activate(mob/user, atom/target)
	. = ..()
	if(!upgrade.active)
		return upgrade.activate(target)
	return FALSE

/datum/action/innate/ipc_upgrade_action/toggleable/on_deactivate(mob/user, atom/target)
	. = ..()
	if(upgrade.active)
		return upgrade.deactivate()
	return FALSE

/datum/action/innate/ipc_upgrade_action/toggleable/update_button(atom/movable/screen/movable/action_button/button, status_only, force)
	if(upgrade.action_icon)
		button_icon_state = upgrade.active ? "[upgrade.action_icon]_on" : "[upgrade.action_icon]_off"
	return ..()

/datum/action/innate/ipc_upgrade_action/targeted
	requires_target = TRUE
	toggleable = FALSE

/datum/action/innate/ipc_upgrade_action/targeted/on_activate(mob/user, atom/target)
	..()
	return upgrade.activate(target)

/datum/status_effect/ipc_upgrade/repair_nexus
	id = "ipc repair nexus"
	name = "Repair Nexus"
	active_power_requirement = 15
	var/healing_power = 0.5
	action_icon = "repair_nexus"
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable

/datum/status_effect/ipc_upgrade/repair_nexus/tick(seconds_between_ticks)
	if(!..())
		return FALSE
	if(!iscarbon(owner))
		return FALSE
	var/mob/living/carbon/carbon_owner = owner
	var/list/parts = carbon_owner.get_damaged_bodyparts(TRUE, TRUE, required_bodytype = BODYTYPE_ROBOTIC)
	if(!parts.len)
		return FALSE
	for(var/obj/item/bodypart/limb in parts)
		if(limb.heal_damage((healing_power / parts.len) * seconds_between_ticks, (healing_power / parts.len) * seconds_between_ticks, required_bodytype = BODYTYPE_ROBOTIC))
			owner.update_damage_overlays()

/datum/status_effect/ipc_upgrade/emp_shield
	id = "ipc emp shield"
	name = "Disposable EMP Shielding"
	var/remaining_pulses = 5 // you get 5 emps before this stops working

/datum/status_effect/ipc_upgrade/emp_shield/on_apply()
	. = ..()
	owner.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)

/datum/status_effect/ipc_upgrade/emp_shield/on_remove()
	. = ..()
	owner.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)

/datum/status_effect/ipc_upgrade/emp_shield/emp_act(severity)
	. = ..()
	if(remaining_pulses <= 0)
		to_chat(owner, span_warningbold("Your [name] has been fried! You are no longer protected from EMP attacks."))
		do_sparks(2, FALSE, owner)
		qdel(src)
	remaining_pulses -= 1

/datum/movespeed_modifier/supply_pack
	multiplicative_slowdown = 1.75

/datum/storage/supply_pack
	max_specific_storage = WEIGHT_CLASS_GIGANTIC
	max_total_storage = 70
	max_slots = 10

/obj/item/storage/supply_pack
	name = "supply pack"
	desc = "A gargantuan storage pack fused to the carrier's torso."
	icon = 'icons/obj/storage/backpack.dmi'
	icon_state = "backpack"
	slot_flags = ITEM_SLOT_BACK
	storage_type = /datum/storage/supply_pack

/datum/status_effect/ipc_upgrade/supply_pack
	id = "ipc supply pack"
	name = "Supply Pack"
	slot = UPGRADE_UTILITY
	var/obj/item/storage/supply_pack/pack

/datum/status_effect/ipc_upgrade/supply_pack/on_apply()
	. = ..()
	pack = new
	pack.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	ADD_TRAIT(pack, TRAIT_NODROP, UPGRADE_TRAIT)

	if(!owner.dropItemToGround(owner.get_item_by_slot(ITEM_SLOT_BACK), TRUE))
		return FALSE
	owner.equip_to_slot_if_possible(pack, ITEM_SLOT_BACK)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/supply_pack)

/datum/status_effect/ipc_upgrade/supply_pack/on_remove()
	. = ..()
	pack.emptyStorage()
	QDEL_NULL(pack)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/supply_pack)

/datum/status_effect/ipc_upgrade/deployable
	id = "ipc deployable"
	name = "Generic Deployable Upgrade"
	slot = UPGRADE_UTILITY
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable
	var/obj/item/to_deploy
	var/obj/item/to_deploy_typepath = /obj/item

/datum/status_effect/ipc_upgrade/deployable/on_apply()
	. = ..()
	to_deploy = new to_deploy_typepath()
	to_deploy.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	ADD_TRAIT(to_deploy, TRAIT_NODROP, UPGRADE_TRAIT)

/datum/status_effect/ipc_upgrade/deployable/on_remove()
	QDEL_NULL(to_deploy)
	. = ..()

/datum/status_effect/ipc_upgrade/deployable/activate(atom/target)
	if(!ishuman(owner))
		return FALSE
	var/mob/living/carbon/human/human = owner
	if(!owner.dropItemToGround(human.get_active_held_item(), FALSE))
		to_chat(owner, span_notice("Something is preventing the upgrade from deploying!"))
		return FALSE
	if(!..())
		return FALSE
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, TRUE)
	owner.put_in_hand(to_deploy, human.active_hand_index)

/datum/status_effect/ipc_upgrade/deployable/deactivate()
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, TRUE)
	to_deploy.moveToNullspace()
	. = ..()

/obj/item/blood_drive
	name = "blood drive"
	desc = "An experimental piece of weaponry, this sword extracts blood and uses it to repair a robotic user. Sadly, it does not work on the dead."
	icon_state = "blood_drive"
	inhand_icon_state = "blood_drive"
	worn_icon_state = "blood_drive"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	force = 15
	throwforce = 10
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ISWEAPON
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	block_power = 10
	canblock = TRUE

	block_flags = BLOCKING_ACTIVE | BLOCKING_PROJECTILE
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_DEEP_WOUND
	max_integrity = 200
	resistance_flags = FIRE_PROOF

/obj/item/blood_drive/Initialize(mapload)
	. = ..()
	create_reagents(50)

/obj/item/blood_drive/attack(mob/living/target_mob, mob/living/user, params)
	if(..())
		return TRUE
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		return
	if(iscarbon(target_mob) && target_mob.stat != DEAD)
		var/mob/living/carbon/carbon_mob = target_mob
		carbon_mob.transfer_blood_to(src, force / 2, TRUE)

	user.adjustBruteLoss(FLOOR(-src.reagents.total_volume, 1))
	user.adjustFireLoss(FLOOR(-src.reagents.total_volume * 0.25, 1)) //less effective at healing burn
	reagents.clear_reagents()

/datum/status_effect/ipc_upgrade/deployable/blood_drive
	id = "ipc deployable blood drive"
	name = "Integrated Blood Drive"
	active_power_requirement = 5
	slot = UPGRADE_UTILITY
	action_icon = "blood_drive"
	to_deploy_typepath = /obj/item/blood_drive

/datum/status_effect/ipc_upgrade/deployable/medbeam
	id = "ipc deployable medbeam"
	name = "Integrated Revival Beam"
	active_power_requirement = 40
	slot = UPGRADE_UTILITY
	action_icon = "medbeam"
	to_deploy_typepath = /obj/item/gun/medbeam/weak

/datum/status_effect/ipc_upgrade/deployable/medbeam/should_process()
	var/obj/item/gun/medbeam/weak/medgun = to_deploy
	return ..() && medgun.active

/datum/movespeed_modifier/overclocked_servos
	multiplicative_slowdown = -0.35

/datum/status_effect/ipc_upgrade/overclocked_servos
	id = "ipc overclocked servos"
	name = "Overclocked Servos"
	slot = UPGRADE_UTILITY
	active_power_requirement = 25
	action_icon = "overclocked_servos"
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable

/datum/status_effect/ipc_upgrade/overclocked_servos/on_activate(atom/target)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/overclocked_servos)

/datum/status_effect/ipc_upgrade/overclocked_servos/on_deactivate()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/overclocked_servos)

/datum/status_effect/ipc_upgrade/tool_speedifier
	id = "ipc tool adaptor"
	name = "Tool Adaptor"
	slot = UPGRADE_UTILITY
	active_power_requirement = 15
	action_icon = "tool_speedifier"
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable

/datum/status_effect/ipc_upgrade/tool_speedifier/on_activate(atom/target)
	owner.tool_proficiency *= 0.5

/datum/status_effect/ipc_upgrade/tool_speedifier/on_deactivate()
	owner.tool_proficiency /= 0.5

/datum/status_effect/ipc_upgrade/leap_legs
	id = "ipc leap legs"
	name = "Leap Legs"
	power_requirement = 100
	cooldown_length = 10 SECONDS
	singleton = TRUE
	action_type = /datum/action/innate/ipc_upgrade_action/targeted

//TODO: make you go horizontal when leaping. Also, add a hardstun maybe?
/datum/status_effect/ipc_upgrade/leap_legs/on_activate(atom/target)
	if(!target)
		return
	playsound(owner, 'sound/items/modsuit/loader_charge.ogg', 75, TRUE)
	if(!do_after(owner, 1 SECONDS, owner))
		return
	playsound(owner, 'sound/items/modsuit/loader_launch.ogg', 75, TRUE)
	owner.throw_at(target, 5, 1, spin = FALSE)

/datum/status_effect/ipc_upgrade/ipc_generator
	id = "ipc rtg generator"
	name = "Isotope Decay Generator"
	var/power_generation = 5
	action_icon = "generator"
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable

/datum/status_effect/ipc_upgrade/ipc_generator/tick(seconds_between_ticks)
	if(!should_process())
		return
	if(!iscarbon(owner))
		return
	if(!istype(owner.get_organ_slot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/battery))
		return
	if(!can_generate())

		return
	var/obj/item/organ/stomach/battery/battery = owner.get_organ_slot(ORGAN_SLOT_STOMACH)
	battery.adjust_charge(power_generation * seconds_between_ticks)

/datum/status_effect/ipc_upgrade/ipc_generator/proc/can_generate()
	return TRUE

/datum/status_effect/ipc_upgrade/ipc_generator/fuel_generator
	id = "ipc fuel generator"
	name = "Plasmatic Generator"
	power_generation = 10
	action_icon = "generator"
	var/fuel_consumption = 50
	var/datum/component/material_container/materials

/datum/status_effect/ipc_upgrade/ipc_generator/fuel_generator/on_apply()
	. = ..()
	materials = owner._AddComponent(list(/datum/component/material_container, list(/datum/material/plasma), MINERAL_MATERIAL_AMOUNT * MAX_STACK_SIZE / 2, allowed_types = /obj/item/stack))

/datum/status_effect/ipc_upgrade/ipc_generator/fuel_generator/on_remove()
	. = ..()
	qdel(materials)

/datum/status_effect/ipc_upgrade/ipc_generator/fuel_generator/can_generate()
	if(!materials.use_amount_mat(fuel_consumption, /datum/material/plasma))
		return FALSE
	return TRUE

/datum/status_effect/ipc_upgrade/trait
	id = "ipc trait"
	name = "Generic Trait Upgrade"
	var/trait

/datum/status_effect/ipc_upgrade/trait/on_apply()
	. = ..()
	ADD_TRAIT(owner, trait, UPGRADE_TRAIT)

/datum/status_effect/ipc_upgrade/trait/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, trait, UPGRADE_TRAIT)

/datum/status_effect/ipc_upgrade/trait/vacuum_shielding
	id = "ipc vacuum shield"
	name = "Vacuum Shielding"
	slot = UPGRADE_EXTERNAL
	trait = TRAIT_RESISTLOWPRESSURE

/datum/status_effect/ipc_upgrade/trait/rad_shielding
	id = "ipc rad shield"
	name = "Radiation Shielding"
	slot = UPGRADE_EXTERNAL
	trait = TRAIT_RADIMMUNE

/datum/status_effect/ipc_upgrade/armor
	id = "ipc armor"
	name = "Generic Armor"
	var/armor

/datum/status_effect/ipc_upgrade/armor/on_apply()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.physio_armor.add_other_armor(armor)

/datum/status_effect/ipc_upgrade/armor/on_remove()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.physio_armor.subtract_other_armor(armor)

/datum/status_effect/ipc_upgrade/armor/las_armor
	id = "ipc las armor"
	name = "Ablative Plating"
	upgrade_overlays = list("armor" = UNIFORM_LAYER)
	slot = UPGRADE_EXTERNAL
	armor = /datum/armor/refractive_armor

/datum/status_effect/ipc_upgrade/armor/ken_armor
	id = "ipc ken armor"
	name = "Reactive Plating"
	upgrade_overlays = list("armor" = UNIFORM_LAYER)
	slot = UPGRADE_EXTERNAL
	armor = /datum/armor/hardening_armor

/datum/status_effect/ipc_upgrade/gun
	id = "ipc gun"
	name = "Generic Gun Upgrade"
	power_requirement = 0
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable
	slot = UPGRADE_UTILITY
	var/projectile_type = /obj/projectile/beam/laser
	var/projectile_sound = 'sound/weapons/laser.ogg'
	///The cooldown between shots
	var/firing_length = 1 SECONDS
	var/overrides_click = FALSE
	var/firing_power_requirement = 0 //This way, power is only used if the gun successfully fires.
	COOLDOWN_DECLARE(firing_cooldown)

/datum/status_effect/ipc_upgrade/gun/on_activate(atom/target)
	if(overrides_click)
		return
	RegisterSignal(owner, COMSIG_MOB_MIDDLECLICKON, PROC_REF(target))

/datum/status_effect/ipc_upgrade/gun/on_deactivate()
	UnregisterSignal(owner, COMSIG_MOB_MIDDLECLICKON)

/datum/status_effect/ipc_upgrade/gun/proc/target(mob/source, atom/target, params)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, firing_cooldown))
		return
	sling(source, target, params)

/datum/status_effect/ipc_upgrade/gun/proc/sling(atom/target, params)
	if(!drain_cell(firing_power_requirement))
		playsound(owner, 'sound/weapons/gun_dry_fire.ogg', 50)
		return
	var/obj/projectile/projectile = new projectile_type(get_turf(owner))
	playsound(owner, projectile_sound, 50, TRUE)
	projectile.firer = owner
	projectile.fired_from = src
	projectile.preparePixelProjectile(target, owner, params2list(params))
	projectile.fire(null, target)
	COOLDOWN_START(src, firing_cooldown, firing_length)

/datum/status_effect/ipc_upgrade/gun/ui_data()
	var/list/data = ..()
	data["power_req"] = firing_power_requirement

/datum/status_effect/ipc_upgrade/gun/charged
	id = "ipc gun charged"
	name = "Generic Charged Gun Upgrade"
	overrides_click = TRUE
	var/firing_time = 1 SECONDS
	var/datum/looping_sound/charge_cannon/charging_sound
	COOLDOWN_DECLARE(fire_time)

/datum/status_effect/ipc_upgrade/gun/charged/on_apply()
	. = ..()
	charging_sound = new(owner)

/datum/status_effect/ipc_upgrade/gun/charged/on_activate(atom/target)
	//TODO: look into more robust methods than this
	if(!owner.client)
		return
	RegisterSignal(owner.client, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(on_mouse_down))
	RegisterSignal(owner.client, COMSIG_CLIENT_MOUSEUP, PROC_REF(on_mouse_up))

/datum/status_effect/ipc_upgrade/gun/charged/on_deactivate()
	//TODO: possible bug, if you ghost while you have this status effect you will still have this signal attached.
	UnregisterSignal(owner.client, COMSIG_CLIENT_MOUSEDOWN)
	UnregisterSignal(owner.client, COMSIG_CLIENT_MOUSEUP)

/datum/status_effect/ipc_upgrade/gun/charged/proc/on_mouse_down(client/source, atom/target, location, control, params)
	SIGNAL_HANDLER
	var/list/p2l = params2list(params)
	if(p2l["button"] != "middle")
		return
	charging_sound.start()
	COOLDOWN_START(src, fire_time, firing_time)

/datum/status_effect/ipc_upgrade/gun/charged/proc/on_mouse_up(client/source, atom/target, location, control, params)
	SIGNAL_HANDLER
	var/list/p2l = params2list(params)
	if(p2l["button"] != "middle")
		return
	charging_sound.stop()
	if(!COOLDOWN_FINISHED(src, fire_time))
		return
	sling(target, params)

/datum/status_effect/ipc_upgrade/gun/charged/ex_cannon
	id = "ipc gun ex-19"
	name = "Mounted EX-19 Cannon"
	firing_power_requirement = 175
	projectile_type = /obj/projectile/beam/laser/heavylaser
	projectile_sound = 'sound/weapons/lasercannonfire.ogg'
	firing_length = 2 SECONDS
	firing_time = 3 SECONDS
	upgrade_overlays = list("ex_cannon" = FRONT_MUTATIONS_LAYER, "ex_cannon_b" = BODY_BEHIND_LAYER)
