#define INTERDICTION_LENS_RANGE 5

/datum/clockcult/scripture/create_structure/interdiction
	name = "Interdiction Lens"
	desc = "Creates a device that will slow non servants in the area and damage mechanised exosuits. Requires power from a sigil of transmission."
	tip = "Construct interdiction lens to slow down a hostile assault."
	invokation_text = list("Oh great lord...", "may your divinity block the outsiders.")
	invokation_time = 8 SECONDS
	button_icon_state = "Interdiction Lens"
	power_cost = 500
	cogs_required = 4
	summoned_structure = /obj/structure/destructible/clockwork/gear_base/interdiction_lens
	category = SPELLTYPE_STRUCTURES

/obj/structure/destructible/clockwork/gear_base/interdiction_lens
	name = "interdiction lens"
	desc = "A mesmerizing light that flashes to a rhythm that you just can't stop tapping to."
	clockwork_desc = span_brass("A small device which will slow down nearby attackers at a small power cost.")
	icon_state = "interdiction_lens"
	anchored = TRUE
	break_message = span_warning("The interdiction lens breaks into multiple fragments, which gently float to the ground.")
	max_integrity = 150
	minimum_power = 5

	/// If the structure is active
	var/enabled = FALSE
	/// If the structure is currently processing
	var/processing = FALSE
	/// The internal dampening field
	var/datum/proximity_monitor/advanced/dampening_field
	/// The internal dampener
	var/obj/item/borg/projectile_dampen/clockcult/internal_dampener

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/Initialize(mapload)
	. = ..()
	internal_dampener = new()

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/Destroy()
	if(processing)
		STOP_PROCESSING(SSobj, src)
	if(dampening_field)
		QDEL_NULL(dampening_field)
	if(internal_dampener)
		QDEL_NULL(internal_dampener)
	return ..()

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!IS_SERVANT_OF_RATVAR(user))
		return
	if(!anchored)
		balloon_alert(user, "not anchored!")
		return

	// Toggle
	enabled = !enabled
	if(enabled)
		if(!update_power())
			enabled = FALSE
			balloon_alert(user, "not enough power!")
			return

		repowered()
		balloon_alert(user, "enabled!")
	else
		balloon_alert(user, "disabled!")
		depowered()

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/process(delta_time)
	if(!anchored)
		enabled = FALSE
		STOP_PROCESSING(SSobj, src)
		update_icon_state()
		return

	// 5% chance to spawn steam every second
	if(DT_PROB(5, delta_time))
		new /obj/effect/temp_visual/steam_release(get_turf(src))

	// Slow down nearby non-servants
	for(var/mob/living/viewer in viewers(INTERDICTION_LENS_RANGE, src))
		if(!IS_SERVANT_OF_RATVAR(viewer) && use_power(5))
			viewer.apply_status_effect(/datum/status_effect/interdiction)

	// Damage mechs
	for(var/obj/vehicle/sealed/mecha/mech in dview(INTERDICTION_LENS_RANGE, src, SEE_INVISIBLE_MINIMUM))
		if(use_power(5))
			mech.emp_act(EMP_HEAVY)
			mech.take_damage(400 * delta_time)
			do_sparks(4, TRUE, mech)

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/repowered()
	if(enabled)
		// Reenable
		if(!processing)
			START_PROCESSING(SSobj, src)
			processing = TRUE

		// Flavor
		icon_state = "interdiction_lens_active"
		flick("interdiction_lens_recharged", src)

		// Replace dampening field
		if(istype(dampening_field))
			QDEL_NULL(dampening_field)
		dampening_field = new(src, INTERDICTION_LENS_RANGE, TRUE)

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/depowered()
	// Disable processing
	if(processing)
		STOP_PROCESSING(SSobj, src)
		processing = FALSE

	// Flavor
	icon_state = "interdiction_lens"
	flick("interdiction_lens_discharged", src)

	QDEL_NULL(dampening_field)

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/free/use_power(amount)
	return

/obj/structure/destructible/clockwork/gear_base/interdiction_lens/free/check_power(amount)
	if(!linked_transmission_sigil)
		return FALSE
	return TRUE

//Dampening field
/datum/proximity_monitor/advanced/projectile_dampener/clockwork

/datum/proximity_monitor/advanced/projectile_dampener/clockwork/capture_projectile(obj/projectile/projectile)
	if(projectile in tracked)
		return

	// Don't dampen clock cultist projectiles
	if(isliving(projectile.firer))
		var/mob/living/living_target = projectile.firer
		if(IS_SERVANT_OF_RATVAR(living_target))
			return

	SEND_SIGNAL(src, COMSIG_DAMPENER_CAPTURE, projectile)
	tracked += projectile

/obj/item/borg/projectile_dampen/clockcult
	name = "internal clockcult projectile dampener"

/obj/item/borg/projectile_dampen/clockcult/activate_field()
	if(istype(dampening_field))
		QDEL_NULL(dampening_field)
	var/mob/living/silicon/robot/owner = get_host()
	dampening_field = new /datum/proximity_monitor/advanced/projectile_dampener/clockwork(owner, field_radius, TRUE, src)
	RegisterSignal(dampening_field, COMSIG_DAMPENER_CAPTURE,  PROC_REF(dampen_projectile))
	RegisterSignal(dampening_field, COMSIG_DAMPENER_RELEASE,  PROC_REF(restore_projectile))
	owner?.model.allow_riding = FALSE
	active = TRUE

/obj/item/borg/projectile_dampen/clockcult/process_recharge()
	energy = maxenergy

#undef INTERDICTION_LENS_RANGE
