/// How much toxin damage we deal * intensity per second
#define RADIATION_TOX_DAMAGE_PER_INTENSITY 0.01
/// The maximum amount of toxin damage dealt per second
#define RADIATION_MAX_TOX_DAMAGE 0.5

#define RADIATION_GLOW_THRESHOLD 20
#define RADIATION_ALERT_THRESHOLD 20
#define RADIATION_MUTATE_THRESHOLD 75
#define RADIATION_BURN_THRESHOLD 75

#define RADIATION_BURN_SPLOTCH_DAMAGE 11
#define RADIATION_BURN_INTERVAL_MIN (30 SECONDS)
#define RADIATION_BURN_INTERVAL_MAX (60 SECONDS)

/// How much our intensity decreases per second if we have TRAIT_RAD_HEALER
#define RAD_HEALER_DECREASE_PER_SECOND 0.5

// Showers process on SSmachines
#define RADIATION_CLEAN_IMMUNITY_TIME (SSMACHINES_DT + (1 SECONDS))

/// This atom is irradiated, and will glow green.
/// Humans will take toxin damage until all their toxin damage is cleared.
/datum/component/irradiated
	dupe_mode = COMPONENT_DUPE_UNIQUE

	/// The time we were irradiated
	var/beginning_of_irradiation
	/// Our radiation intensity
	var/intensity = 1
	/// Are we currently attempting to burn our target?
	var/trying_to_burn = FALSE

	COOLDOWN_DECLARE(clean_cooldown)
	COOLDOWN_DECLARE(last_tox_damage)
	COOLDOWN_DECLARE(irradiated_mutation)

/datum/component/irradiated/Initialize(intensity)
	if (!CAN_IRRADIATE(parent))
		return COMPONENT_INCOMPATIBLE

	// This isn't incompatible, it's just wrong
	if (HAS_TRAIT(parent, TRAIT_RADIMMUNE))
		qdel(src)
		return

	src.intensity = intensity

	ADD_TRAIT(parent, TRAIT_IRRADIATED, REF(src))

	beginning_of_irradiation = world.time

	if (ishuman(parent))
		START_PROCESSING(SSobj, src)
	else
		QDEL_IN(src, 30 SECONDS)
		create_glow()

/datum/component/irradiated/RegisterWithParent()
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_GEIGER_COUNTER_SCAN, PROC_REF(on_geiger_counter_scan))
	RegisterSignal(parent, COMSIG_LIVING_HEALTHSCAN, PROC_REF(on_healthscan))

/datum/component/irradiated/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_GEIGER_COUNTER_SCAN,
		COMSIG_LIVING_HEALTHSCAN,
	))

/datum/component/irradiated/Destroy(force)
	var/atom/movable/parent_movable = parent
	if (istype(parent_movable))
		parent_movable.remove_filter("rad_glow")

	var/mob/living/carbon/human/human_parent = parent
	if (istype(human_parent))
		human_parent.clear_alert(ALERT_IRRADIATED)

	REMOVE_TRAIT(parent, TRAIT_IRRADIATED, REF(src))

	STOP_PROCESSING(SSobj, src)

	return ..()

/datum/component/irradiated/InheritComponent(datum/component/irradiated/old_component)
	intensity += old_component.intensity

/datum/component/irradiated/process(delta_time)
	if (!ishuman(parent))
		return PROCESS_KILL

	if (HAS_TRAIT(parent, TRAIT_RADIMMUNE))
		qdel(src)
		return PROCESS_KILL

	if (intensity <= 0)
		qdel(src)
		return PROCESS_KILL

	var/mob/living/carbon/human/human_parent = parent

	if (intensity >= RADIATION_GLOW_THRESHOLD)
		create_glow()
	else if(human_parent.get_filter("rad_glow"))
		human_parent.remove_filter("rad_glow")

	if (intensity >= RADIATION_ALERT_THRESHOLD)
		human_parent.throw_alert(ALERT_IRRADIATED, /atom/movable/screen/alert/irradiated)
	else if(human_parent.has_alert(ALERT_IRRADIATED))
		human_parent.clear_alert(ALERT_IRRADIATED)

	if (should_halt_effects(human_parent))
		return

	if (human_parent.stat != DEAD)
		human_parent.dna?.species?.handle_radiation(human_parent, intensity, delta_time)

	if (HAS_TRAIT(human_parent, TRAIT_RADHEALER))
		intensity = max(intensity - RAD_HEALER_DECREASE_PER_SECOND * delta_time, 0)

	if (intensity >= RADIATION_BURN_THRESHOLD && !trying_to_burn)
		start_burn_splotch_timer()

	if(intensity >= RADIATION_MUTATE_THRESHOLD && COOLDOWN_FINISHED(src, irradiated_mutation) && DT_PROB(5, delta_time))
		mutate_human_parent(human_parent)

	var/damage = min(RADIATION_TOX_DAMAGE_PER_INTENSITY * intensity * delta_time, RADIATION_MAX_TOX_DAMAGE)
	if(!HAS_TRAIT(human_parent, TRAIT_TOXIMMUNE))
		human_parent.adjustToxLoss(damage)
	else
		human_parent.adjustFireLoss(damage)

/datum/component/irradiated/proc/adjust_intensity(amount)
	intensity = clamp(intensity + amount, 0, 100)

/datum/component/irradiated/proc/should_halt_effects(mob/living/carbon/human/target)
	if (HAS_TRAIT(target, TRAIT_STASIS))
		return TRUE

	if (HAS_TRAIT(target, TRAIT_HALT_RADIATION_EFFECTS))
		return TRUE

	if (!COOLDOWN_FINISHED(src, clean_cooldown))
		return TRUE

	return FALSE

/datum/component/irradiated/proc/mutate_human_parent(mob/living/carbon/human/human_parent)
	COOLDOWN_START(src, irradiated_mutation, rand(45, 120) SECONDS)
	if(prob(75)) //usually a mutation, sometimes a total appearance change instead
		human_parent.easy_random_mutate()
	else
		human_parent.random_mutate_unique_features()
		human_parent.random_mutate_unique_identity()

/datum/component/irradiated/proc/start_burn_splotch_timer()
	trying_to_burn = TRUE
	addtimer(CALLBACK(src, PROC_REF(give_burn_splotches)), rand(RADIATION_BURN_INTERVAL_MIN, RADIATION_BURN_INTERVAL_MAX), TIMER_STOPPABLE)

/datum/component/irradiated/proc/give_burn_splotches()
	trying_to_burn = FALSE

	// This shouldn't be possible, but just in case.
	if (QDELETED(src))
		return

	if (intensity < RADIATION_BURN_THRESHOLD)
		return

	start_burn_splotch_timer()

	var/mob/living/carbon/human/human_parent = parent

	if (should_halt_effects(parent))
		return

	var/obj/item/bodypart/affected_limb = human_parent.get_bodypart(ran_zone(probability = 0))
	human_parent.visible_message(
		span_boldwarning("[human_parent]'s [affected_limb.plaintext_zone] bubbles unnaturally, then bursts into blisters!"),
		span_boldwarning("Your [affected_limb.plaintext_zone] bubbles unnaturally, then bursts into blisters!"),
	)

	if(human_parent.is_blind())
		to_chat(human_parent, span_boldwarning("Your [affected_limb.plaintext_zone] feels like it's bubbling, then burns like hell!"))

	human_parent.apply_damage(RADIATION_BURN_SPLOTCH_DAMAGE, BURN, affected_limb)
	playsound(human_parent, 'sound/effects/wounds/sizzle1.ogg', 50, vary = TRUE)

/datum/component/irradiated/proc/create_glow()
	var/atom/movable/parent_movable = parent
	if (!istype(parent_movable))
		return

	parent_movable.add_filter("rad_glow", 2, list("type" = "outline", "color" = "#39ff1430", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(start_glow_loop), parent_movable), rand(0.1 SECONDS, 1.9 SECONDS)) // Things should look uneven

/datum/component/irradiated/proc/start_glow_loop(atom/movable/parent_movable)
	var/filter = parent_movable.get_filter("rad_glow")
	if (!filter)
		return

	animate(filter, alpha = 110, time = 1.5 SECONDS, loop = -1)
	animate(alpha = 40, time = 2.5 SECONDS)

/datum/component/irradiated/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER

	if (!(clean_types & CLEAN_TYPE_RADIATION))
		return NONE

	if (isitem(parent))
		qdel(src)
		return

	COOLDOWN_START(src, clean_cooldown, RADIATION_CLEAN_IMMUNITY_TIME)

/datum/component/irradiated/proc/on_geiger_counter_scan(datum/source, mob/user, obj/item/geiger_counter/geiger_counter)
	SIGNAL_HANDLER

	if (isliving(source))
		to_chat(user, span_bolddanger("[icon2html(geiger_counter, user)] Subject is irradiated. Contamination traces back to roughly [DisplayTimeText(world.time - beginning_of_irradiation, 5)] ago. Current radiation levels: [round(intensity)]%."))
	else
		// In case the green wasn't obvious enough...
		to_chat(user, span_bolddanger("[icon2html(geiger_counter, user)] Target is irradiated."))

	return COMSIG_GEIGER_COUNTER_SCAN_SUCCESSFUL

/datum/component/irradiated/proc/on_healthscan(datum/source, list/render_list, advanced, mob/user, mode, tochat)
	SIGNAL_HANDLER

	if(advanced)
		render_list += "<span class='alert ml-1'>Subject is irradiated. Contamination traces back to roughly [DisplayTimeText(world.time - beginning_of_irradiation, 5)] ago. Current radiation levels: [round(intensity)]%.</span><br>"
	else
		render_list += "<span class='alert ml-1'>Subject is irradiated. Supply antiradiation.</span><br>"

/atom/movable/screen/alert/irradiated
	name = "Irradiated"
	desc = "You're irradiated! Seek medicine and stand under a shower to halt the incoming damage."
	icon_state = ALERT_IRRADIATED

#undef RADIATION_TOX_DAMAGE_PER_INTENSITY
#undef RADIATION_MAX_TOX_DAMAGE
#undef RADIATION_GLOW_THRESHOLD
#undef RADIATION_ALERT_THRESHOLD
#undef RADIATION_BURN_THRESHOLD
#undef RADIATION_BURN_SPLOTCH_DAMAGE
#undef RADIATION_BURN_INTERVAL_MIN
#undef RADIATION_BURN_INTERVAL_MAX
#undef RAD_HEALER_DECREASE_PER_SECOND
#undef RADIATION_CLEAN_IMMUNITY_TIME
