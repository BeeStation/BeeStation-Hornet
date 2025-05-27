/**
 * This element registers to a shitload of signals which can signify "someone attacked me".
 * If anyone does it sends a single "someone attacked me" signal containing details about who done it.
 * This prevents other components and elements from having to register to the same list of a million signals, should be more maintainable in one place.
 */
/datum/element/relay_attackers

/datum/element/relay_attackers/Attach(datum/target)
	. = ..()
	// Boy this sure is a lot of ways to tell us that someone tried to attack us
	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignals(target, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_ATOM_ATTACK_PAW, COMSIG_MOB_ATTACK_ALIEN), PROC_REF(on_attack_generic))
	RegisterSignals(target, list(COMSIG_ATOM_ATTACK_BASIC_MOB, COMSIG_ATOM_ATTACK_ANIMAL), PROC_REF(on_attack_npc))
	RegisterSignal(target, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignal(target, COMSIG_ATOM_HITBY, PROC_REF(on_hitby))
	RegisterSignal(target, COMSIG_ATOM_HULK_ATTACK, PROC_REF(on_attack_hulk))
	RegisterSignal(target, COMSIG_ATOM_ATTACK_MECH, PROC_REF(on_attack_mech))

/datum/element/relay_attackers/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, list(
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_ATOM_ATTACK_BASIC_MOB,
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_MOB_ATTACK_ALIEN,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ATOM_HITBY,
		COMSIG_ATOM_HULK_ATTACK,
		COMSIG_ATOM_ATTACK_MECH,
	))

/datum/element/relay_attackers/proc/on_attackby(atom/target, obj/item/weapon, mob/attacker)
	SIGNAL_HANDLER
	if(weapon.force)
		relay_attacker(target, attacker)

/datum/element/relay_attackers/proc/on_attack_generic(atom/target, mob/living/attacker, list/modifiers)
	SIGNAL_HANDLER
	if(attacker.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK))
		relay_attacker(target, attacker)

/datum/element/relay_attackers/proc/on_attack_npc(atom/target, mob/living/attacker)
	SIGNAL_HANDLER
	if(attacker.melee_damage > 0)
		relay_attacker(target, attacker)

/datum/element/relay_attackers/proc/on_bullet_act(atom/target, obj/projectile/hit_projectile)
	SIGNAL_HANDLER
	if(hit_projectile.nodamage)
		return
	if(!ismob(hit_projectile.firer))
		return
	relay_attacker(target, hit_projectile.firer)

/datum/element/relay_attackers/proc/on_hitby(atom/target, atom/movable/hit_atom, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	if(!isitem(hit_atom))
		return
	var/obj/item/hit_item = hit_atom
	if(!hit_item.throwforce)
		return
	var/mob/thrown_by = hit_item.thrownby?.resolve()
	if(!ismob(thrown_by))
		return
	relay_attacker(target, thrown_by)

/datum/element/relay_attackers/proc/on_attack_hulk(atom/target, mob/attacker)
	SIGNAL_HANDLER
	relay_attacker(target, attacker)

/datum/element/relay_attackers/proc/on_attack_mech(atom/target, obj/vehicle/sealed/mecha/mecha_attacker, mob/living/pilot)
	SIGNAL_HANDLER
	relay_attacker(target, mecha_attacker)

/// Send out a signal identifying whoever just attacked us (usually a mob but sometimes a mech or turret)
/datum/element/relay_attackers/proc/relay_attacker(atom/victim, atom/attacker)
	SEND_SIGNAL(victim, COMSIG_ATOM_WAS_ATTACKED, attacker)
