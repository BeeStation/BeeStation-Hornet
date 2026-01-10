/datum/action/vampire/targeted/blooddrain
	name = "Thaumaturgy: Blood Drain"
	desc = "Cast a beam of draining magic that saps the vitality of your target to steal their blood and heal yourself."
	button_icon_state = "power_thaumaturgy"
	background_icon_state_on = "tremere_power_on"
	background_icon_state_off = "tremere_power_off"
	power_explanation = "Cast a beam of draining magic that saps the vitality of your target to steal their blood and heal yourself."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 75
	cooldown_time = 10 SECONDS	// Very unlikely to ever last past 10 seconds even if the actual duration is longer. Combat is a fuck.
	target_range = 7
	power_activates_immediately = FALSE
	prefire_message = "Select your target."

	var/datum/status_effect/life_drain/active_effect

/datum/action/vampire/targeted/blooddrain/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/living_owner = owner
	var/mob/living/living_target = target_atom
	check_witnesses(living_target)
	living_owner.face_atom(target_atom)
	living_owner.changeNext_move(CLICK_CD_RANGE)
	living_owner.newtonian_move(get_dir(target_atom, living_owner))

	var/obj/projectile/magic/blood_drain/drain = new(living_owner.loc)
	drain.firer = living_owner
	drain.fired_from = src
	drain.def_zone = ran_zone(living_owner.get_combat_bodyzone())
	drain.preparePixelProjectile(target_atom, living_owner)
	INVOKE_ASYNC(drain, TYPE_PROC_REF(/obj/projectile, fire))

	playsound(living_owner, 'sound/magic/wandodeath.ogg', 60, TRUE)

/datum/action/vampire/targeted/blooddrain/deactivate_power()
	. = ..()
	if(!isnull(active_effect))
		active_effect.end_drain()

/obj/projectile/magic/blood_drain
	name = "vitality draining stream"
	icon_state = "nothing"
	range = 7
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	var/datum/beam/drain_beam

/obj/projectile/magic/blood_drain/fire(angle, atom/direct_target)
	if(!firer)
		CRASH("Projectile [src] fired with no firer") //We don't even want any of the rest of this to play out if we don't have a firer
	drain_beam = firer.Beam(src, icon = 'icons/effects/beam.dmi', icon_state = "lifedrain", time = 10 SECONDS, maxdistance = 7, beam_color = COLOR_RED)
	return ..()

/obj/projectile/magic/blood_drain/on_hit(mob/living/target, blocked, pierce_hit)
	. = ..()
	if(!isliving(target))
		return
	target.apply_status_effect(/datum/status_effect/blood_drain, firer, fired_from)

/obj/projectile/magic/blood_drain/Destroy()
	if(!QDELETED(drain_beam))
		QDEL_NULL(drain_beam)
	return ..()

///
/// Status Effect. Literally copied from life drain spell of wizards, but modified to work with vampires.
///
/datum/status_effect/blood_drain
	id = "blood_drain"
	alert_type = null
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 0.25 SECONDS
	duration = 20 SECONDS
	var/datum/beam/drain_beam
	var/mob/living/carbon/vampire
	var/datum/action/vampire/targeted/blooddrain/spell
	var/blood_drain = 3	 // Amount of blood drained per tick, at 0.25 this is 12 blood per second

/datum/status_effect/blood_drain/on_creation(mob/living/new_owner, mob/living/firer, fired_from, duration_override)
	if(isnull(firer) || isnull(fired_from) || !iscarbon(firer) || !iscarbon(new_owner))
		qdel(src)
		return
	vampire = firer
	spell = fired_from
	spell.active_effect = src
	drain_beam = vampire.Beam(new_owner, icon = 'icons/effects/beam.dmi', icon_state = "blood_drain", time = 22 SECONDS, maxdistance = 7, beam_color = COLOR_RED)
	RegisterSignal(drain_beam, COMSIG_QDELETING, PROC_REF(end_drain))
	new_owner.visible_message(span_warningbold("[vampire] begins draining the life force from [new_owner]!"), span_warningbold("[vampire] is draining your life force! You need to get away from them to stop it!"))
	. = ..()

/datum/status_effect/blood_drain/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/life_drain)

/datum/status_effect/blood_drain/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/life_drain)
	end_drain()

/datum/status_effect/blood_drain/tick()
	if(!iscarbon(owner) || owner.stat > HARD_CRIT) //If they're dead or non-humanoid, this spell fails
		end_drain()
		return
	if(!iscarbon(vampire)) //You never know what might happen with wizards around
		end_drain()
		return

	if(HAS_TRAIT(owner, TRAIT_INCAPACITATED) || owner.stat)
		//If the victim is incapacitated, drain their blood
		owner.blood_volume -= blood_drain
	else
		//If they aren't incapacitated yet, drain only their stamina
		owner.take_overall_damage(0, 0, 7, updating_health = TRUE)

	if(prob(20))
		owner.emote("screams")
		owner.visible_message(span_warningbold("[vampire] absorbs blood from [owner]!"), span_warningbold("It BURNS!"))

	//Vampire heals at a steady rate over the duration of the spell regardless of the victim's state
	vampire.heal_overall_damage(0.5, 0.5, 5, updating_health = TRUE)

	spell.vampiredatum_power.current_vitae += blood_drain * 2	// Vampires get double the blood drained because of balance
	//Weird beam visuals if it isn't redrawn due to the beam sending players into crit
	drain_beam.redrawing()

/datum/status_effect/blood_drain/proc/end_drain()
	SIGNAL_HANDLER
	spell.active_effect = null
	spell.deactivate_power()
	spell.start_cooldown()
	if(QDELING(src))
		return
	if(!QDELETED(drain_beam))
		QDEL_NULL(drain_beam)
	qdel(src)
