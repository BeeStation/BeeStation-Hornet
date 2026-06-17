#define ORGAN_SLOT_UPGRADE_CORE "ipc_upgrade_core"
#define ORGAN_SLOT_UPGRADE_UTILITY "ipc_upgrade_utility"
#define ORGAN_SLOT_UPGRADE_EXTERNAL "ipc_upgrade_external"

/datum/status_effect/ipc_upgrade/
	id = "ipc upgrade"
	alert_type = null
	var/name = "Generic Upgrade"

	var/slot = ORGAN_SLOT_UPGRADE_CORE
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
	///The actual action, created from action_type
	var/datum/action/innate/ipc_upgrade_action/action
	///The length of the cooldown between activations
	var/cooldown_length = 1 SECONDS

/datum/status_effect/ipc_upgrade/Destroy()
	return ..()

/datum/status_effect/ipc_upgrade/on_apply()
	. = ..()
	if(action_type)
		action = new action_type(src)
		action.Grant(owner)

/datum/status_effect/ipc_upgrade/on_remove()
	if(active)
		deactivate()
	QDEL_NULL(action)

/datum/status_effect/ipc_upgrade/proc/should_process()
	return can_drain_cell(active_power_requirement) && active

/datum/status_effect/ipc_upgrade/proc/can_activate()
	return can_drain_cell(power_requirement) && !active

/datum/status_effect/ipc_upgrade/proc/activate()
	if(!can_activate())
		return
	if(!singleton)
		active = TRUE
	action.start_cooldown(cooldown_length)

/datum/status_effect/ipc_upgrade/proc/deactivate()
	active = FALSE

/datum/status_effect/ipc_upgrade/proc/can_drain_cell(amount, obj/item/organ/stomach/battery/battery)
	if(!battery)
		if(!istype(owner, /mob/living/carbon))
			return FALSE
		if(!istype(owner.get_organ_slot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/battery))
			return FALSE
		battery = owner.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(battery.charge < amount)
		return FALSE
	return TRUE

/datum/status_effect/ipc_upgrade/proc/drain_cell(amount)
	if(!istype(owner, /mob/living/carbon))
		return FALSE
	if(!istype(owner.get_organ_slot(ORGAN_SLOT_STOMACH), /obj/item/organ/stomach/battery))
		return FALSE
	var/obj/item/organ/stomach/battery/battery = owner.get_organ_slot(ORGAN_SLOT_STOMACH)
	if(!can_drain_cell(amount, battery))
		return FALSE
	battery.adjust_charge(-amount)
	return TRUE

/datum/action/innate/ipc_upgrade_action
	name = "Generic Upgrade Action"
	var/datum/status_effect/ipc_upgrade/upgrade = null

/datum/action/innate/ipc_upgrade_action/New(datum/status_effect/ipc_upgrade/new_upgrade)
	..()
	name = "Activate [new_upgrade.name]"
	upgrade = new_upgrade

/datum/action/innate/ipc_upgrade_action/is_available(feedback = FALSE)
	if(!..())
		return FALSE
	if(!upgrade.can_activate() && upgrade.singleton)
		return FALSE
	return TRUE

/datum/action/innate/ipc_upgrade_action/on_activate(mob/user, atom/target)
	if(!upgrade.active)
		upgrade.activate()
	else
		upgrade.deactivate()

/datum/status_effect/ipc_upgrade/repair_nexus
	id = "ipc repair nexus"
	name = "Repair Nexus"
	active_power_requirement = 5
	var/healing_power = 0.5
	action_type = /datum/action/innate/ipc_upgrade_action

/datum/status_effect/ipc_upgrade/repair_nexus/tick(seconds_between_ticks)
	. = ..()
	if(!istype(owner, /mob/living/carbon))
		return
	if(!should_process())
		return
	var/mob/living/carbon/carbon_owner = owner
	var/list/parts = carbon_owner.get_damaged_bodyparts(TRUE, TRUE, required_bodytype = BODYTYPE_ROBOTIC)
	if(!parts.len)
		return
	for(var/obj/item/bodypart/limb in parts)
		if(limb.heal_damage((healing_power / parts.len) * seconds_between_ticks, (healing_power / parts.len) * seconds_between_ticks, required_bodytype = BODYTYPE_ROBOTIC))
			owner.update_damage_overlays()

/datum/status_effect/ipc_upgrade/gun
	id = "ipc gun"
	name = "Generic Gun Upgrade"
	power_requirement = 5
	action_type = /datum/action/innate/ipc_upgrade_action
	var/projectile_type = /obj/projectile/beam/laser
	var/projectile_sound = 'sound/weapons/laser.ogg'
	///The cooldown between shots
	var/firing_length = 1 SECONDS
	COOLDOWN_DECLARE(firing_cooldown)

/datum/status_effect/ipc_upgrade/gun/activate()
	..()
	RegisterSignal(owner, COMSIG_MOB_MIDDLECLICKON, PROC_REF(target))

/datum/status_effect/ipc_upgrade/gun/deactivate()
	..()
	UnregisterSignal(owner, COMSIG_MOB_MIDDLECLICKON)

/datum/status_effect/ipc_upgrade/gun/proc/target(mob/source, atom/target, params)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, firing_cooldown))
		return
	var/obj/projectile/projectile = new projectile_type(get_turf(owner))
	playsound(owner, projectile_sound, 50, TRUE)
	projectile.firer = owner
	projectile.fired_from = src
	projectile.preparePixelProjectile(target, owner, params2list(params))
	projectile.fire(null, target)
	COOLDOWN_START(src, firing_cooldown, firing_length)


/datum/status_effect/ipc_upgrade/gun/charged
	id = "ipc gun charged"
	name = "Generic Charged Gun Upgrade"

	var/last_angle = 0
	var/firing_time = 1 SECONDS
	COOLDOWN_DECLARE(fire_time)

/datum/status_effect/ipc_upgrade/gun/charged/activate()
	..()
	RegisterSignal(owner, COMSIG_MOB_MIDDLECLICKON, PROC_REF(target))

/datum/status_effect/ipc_upgrade/gun/charged/ex_cannon
	id = "ipc gun ex-19"
	name = "Mounted EX-19 Cannon"
	power_requirement = 1000
	projectile_type = /obj/projectile/beam/laser/heavylaser
	projectile_sound = 'sound/weapons/lasercannonfire.ogg'
	firing_length = 5 SECONDS
	firing_time = 5 SECONDS
