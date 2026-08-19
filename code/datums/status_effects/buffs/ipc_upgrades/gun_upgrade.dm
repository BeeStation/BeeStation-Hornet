/datum/status_effect/ipc_upgrade/gun
	id = "ipc gun"
	name = "Generic Gun Upgrade"
	action_type = /datum/action/innate/ipc_upgrade_action/toggleable
	action_icon = "shoulder_gun"
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
	sling(target, params)

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
	return data
