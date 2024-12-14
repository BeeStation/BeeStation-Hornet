/**
 * ## Basic Projectile spell
 *
 * Simply fires specified projectile type the direction the caster is facing.
 *
 * Behavior could / should probably be unified with pointed projectile spells
 * and aoe projectile spells in the future.
 */
/datum/action/spell/basic_projectile
	/// How far we try to fire the basic projectile. Blocked by dense objects.
	var/projectile_range = 7
	/// The projectile type fired at all people around us
	var/obj/projectile/projectile_type = /obj/projectile/magic/aoe/magic_missile

/datum/action/spell/basic_projectile/on_cast(mob/user, atom/target)
	. = ..()
	var/turf/target_turf = get_turf(user)
	for(var/i in 1 to projectile_range - 1)
		var/turf/next_turf = get_step(target_turf, user.dir)
		if(next_turf.density)
			break
		target_turf = next_turf

	fire_projectile(target_turf, user)

/datum/action/spell/basic_projectile/proc/fire_projectile(atom/target, atom/caster)
	var/obj/projectile/to_fire = new projectile_type()
	to_fire.preparePixelProjectile(target, caster)
	to_fire.fire()
