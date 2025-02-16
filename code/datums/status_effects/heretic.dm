/datum/status_effect/heretic_mark
	id = "heretic_mark"
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	///underlay used to indicate that someone is marked
	var/mutable_appearance/marked_underlay
	///path for the underlay
	var/effect_icon = 'icons/effects/heretic.dmi'
	/// icon state for the underlay
	var/effect_icon_state = "emark_RING_TEMPLATE"

/datum/status_effect/heretic_mark/on_creation(mob/living/new_owner, ...)
	marked_underlay = mutable_appearance(effect_icon, effect_icon_state,BELOW_MOB_LAYER)
	return ..()

/datum/status_effect/heretic_mark/on_apply()
	if(owner.mob_size >= MOB_SIZE_HUMAN)
		owner.add_overlay(marked_underlay)
		owner.update_overlays()
		return TRUE
	return FALSE

/datum/status_effect/heretic_mark/on_remove()
	owner.update_overlays()
	return ..()

/datum/status_effect/heretic_mark/Destroy()
	if(owner)
		owner.cut_overlay(marked_underlay)
	QDEL_NULL(marked_underlay)
	return ..()

/datum/status_effect/heretic_mark/be_replaced()
	owner.underlays -= marked_underlay //if this is being called, we should have an owner at this point.
	..()

/**
  * What happens when this mark gets poppedd
  *
  * Adds actual functionality to each mark
  */
/datum/status_effect/heretic_mark/proc/on_effect()
	SHOULD_CALL_PARENT(TRUE)

	playsound(owner, 'sound/magic/repulse.ogg', 75, TRUE)
	qdel(src) //what happens when this is procced.

//Each mark has diffrent effects when it is destroyed that combine with the mansus grasp effect.
/datum/status_effect/heretic_mark/flesh
	effect_icon_state = "emark1"

/datum/status_effect/heretic_mark/flesh/on_effect()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.add_bleeding(BLEED_CUT)
	return ..()

/datum/status_effect/heretic_mark/ash
	id = "ash_mark"
	effect_icon_state = "emark2"
	///Dictates how much damage and stamina loss this mark will cause.
	var/repetitions = 1

/datum/status_effect/heretic_mark/ash/on_creation(mob/living/new_owner, repetition = 5)
	. = ..()
	src.repetitions = min(1,repetition)

/datum/status_effect/heretic_mark/ash/on_effect()
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.adjustStaminaLoss(6 * repetitions)
		carbon_owner.adjustFireLoss(3 * repetitions)
		for(var/mob/living/carbon/victim in ohearers(1,carbon_owner))
			if(IS_HERETIC(victim))
				continue
			victim.apply_status_effect(type,repetitions-1)
			break
	return ..()

/datum/status_effect/heretic_mark/rust
	effect_icon_state = "emark3"

/datum/status_effect/heretic_mark/rust/on_effect()
	if(!iscarbon(owner))
		return
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		var/static/list/organs_to_damage = list(
			ORGAN_SLOT_BRAIN,
			ORGAN_SLOT_EARS,
			ORGAN_SLOT_EYES,
			ORGAN_SLOT_LIVER,
			ORGAN_SLOT_LUNGS,
			ORGAN_SLOT_STOMACH,
			ORGAN_SLOT_HEART,
		)

		// Roughly 75% of their organs will take a bit of damage
		for(var/organ_slot in organs_to_damage)
			if(prob(75))
				carbon_owner.adjustOrganLoss(organ_slot, 20)

		// And roughly 75% of their items will take a smack, too
		for(var/obj/item/thing in carbon_owner.get_all_gear())
			if(!QDELETED(thing) && prob(75) && !istype(thing, /obj/item/grenade))
				thing.take_damage(100)
	return ..()

/datum/status_effect/heretic_mark/void
	effect_icon_state = "emark4"

/datum/status_effect/heretic_mark/void/on_effect()
	var/turf/open/turfie = get_turf(owner)
	turfie.take_temperature(-40)
	owner.adjust_bodytemperature(-20)
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.silent += 4
	return ..()

/datum/status_effect/flesh_decay
	id = "flesh_decay"
	status_type = STATUS_EFFECT_UNIQUE
	tick_interval = 4 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/flesh_decay

/datum/status_effect/flesh_decay/on_apply()
	ADD_TRAIT(owner, TRAIT_MUTE, TRAIT_FLESH_DECAY)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/flesh_decay_slowdown)
	var/mob/living/carbon/target = owner
	if (!istype(target))
		qdel(src)
		return
	// Add some bleeding so the effect doesn't instantly clear
	target.add_bleeding(BLEED_SCRATCH)
	return TRUE

/datum/status_effect/flesh_decay/on_remove()
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAIT_FLESH_DECAY)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/flesh_decay_slowdown)

/datum/status_effect/flesh_decay/tick()
	// When the target enters soft-crit, then disappear
	if (owner.stat >= SOFT_CRIT)
		qdel(src)
		return
	var/mob/living/carbon/target = owner
	if (!istype(target))
		qdel(src)
		return
	if (!target.is_bleeding())
		qdel(src)
		return
	target.add_bleeding(max(1 - target.get_bleed_rate(), 0))
	target.adjustBruteLoss(1)

/atom/movable/screen/alert/status_effect/flesh_decay
	name = "Flesh Decay"
	desc = "You are affected by a flesh curse, preventing you from speaking and causing damage over time. Apply bandages to prevent the decay!"
	icon_state = "flesh_decay"

/datum/status_effect/corrosion_curse
	id = "corrosion_curse"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	tick_interval = 4 SECONDS

/datum/status_effect/corrosion_curse/on_creation(mob/living/new_owner, ...)
	. = ..()
	to_chat(owner, span_userdanger("Your body starts to break apart!"))

/datum/status_effect/corrosion_curse/tick()
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	if (human_owner.IsSleeping())
		return
	var/chance = rand(0,100)
	var/message = "Coder did fucky wucky U w U"
	switch(chance)
		if(0 to 10)
			message = span_warning("You feel a lump build up in your throat.")
			human_owner.vomit()
		if(20 to 30)
			message = span_warning("You feel feel very well.")
			human_owner.Dizzy(50)
			human_owner.Jitter(50)
		if(30 to 40)
			message = span_warning("You feel a sharp sting in your side.")
			human_owner.adjustOrganLoss(ORGAN_SLOT_LIVER, 5)
		if(40 to 50)
			message = span_warning("You feel pricking around your heart.")
			human_owner.adjustOrganLoss(ORGAN_SLOT_HEART, 5, 90)
		if(50 to 60)
			message = span_warning("You feel your stomach churning.")
			human_owner.adjustOrganLoss(ORGAN_SLOT_STOMACH, 5)
		if(60 to 70)
			message = span_warning("Your eyes feel like they're on fire.")
			human_owner.adjustOrganLoss(ORGAN_SLOT_EYES, 10)
		if(70 to 80)
			message = span_warning("You hear ringing in your hears.")
			human_owner.adjustOrganLoss(ORGAN_SLOT_EARS, 10)
		if(80 to 90)
			message = span_warning("Your ribcage feels tighter.")
			human_owner.adjustOrganLoss(ORGAN_SLOT_LUNGS, 10)
		if(90 to 100)
			message = span_warning("You feel your skull pressing down on your brain.")
			human_owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20, 190)
	if(prob(33)) //so the victim isn't spammed with messages every 3 seconds
		to_chat(human_owner,message)

/datum/status_effect/ghoul
	id = "ghoul"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	examine_text = span_warning("SUBJECTPRONOUN has a blank, catatonic like stare.")
	alert_type = /atom/movable/screen/alert/status_effect/ghoul

/datum/status_effect/ghoul/get_examine_text()
	var/mob/living/carbon/human/H = owner
	var/obscured = H.check_obscured_slots()
	if(!(obscured & ITEM_SLOT_EYES) && !H.glasses) //The examine text is only displayed if the ghoul's eyes are not obscured
		return examine_text

/atom/movable/screen/alert/status_effect/ghoul
	name = "Flesh Servant"
	desc = "You are a Ghoul! A eldritch monster reanimated to serve its master."
	icon_state = "mind_control"

/datum/status_effect/amok
	id = "amok"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 10 SECONDS
	tick_interval = 1 SECONDS

/datum/status_effect/amok/on_apply(mob/living/afflicted)
	. = ..()
	to_chat(owner, span_boldwarning("You feel filled with a rage that is not your own!"))

/datum/status_effect/amok/tick()
	. = ..()
	var/prev_combat_mode = owner.combat_mode
	owner.set_combat_mode(TRUE)

	var/list/mob/living/targets = list()
	for(var/mob/living/potential_target in oview(owner, 1))
		if(IS_HERETIC(potential_target) || potential_target.mind?.has_antag_datum(/datum/antagonist/heretic_monster))
			continue
		targets += potential_target
	if(LAZYLEN(targets))
		owner.log_message(" attacked someone due to the amok debuff.", LOG_ATTACK) //the following attack will log itself
		owner.ClickOn(pick(targets))
	owner.set_combat_mode(prev_combat_mode)

/datum/status_effect/cloudstruck
	id = "cloudstruck"
	status_type = STATUS_EFFECT_REPLACE
	duration = 3 SECONDS
	on_remove_on_mob_delete = TRUE
	///This overlay is applied to the owner for the duration of the effect.
	var/mutable_appearance/mob_overlay

/datum/status_effect/cloudstruck/on_creation(mob/living/new_owner, set_duration)
	if(isnum(set_duration))
		duration = set_duration
	. = ..()

/datum/status_effect/cloudstruck/on_apply()
	mob_overlay = mutable_appearance('icons/effects/heretic.dmi', "cloud_swirl", ABOVE_MOB_LAYER)
	owner.overlays += mob_overlay
	owner.update_icon()
	ADD_TRAIT(owner, TRAIT_BLIND, "cloudstruck")
	return TRUE

/datum/status_effect/cloudstruck/on_remove()
	. = ..()
	if(QDELETED(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_BLIND, "cloudstruck")
	if(owner)
		owner.overlays -= mob_overlay
		owner.update_icon()

/datum/status_effect/cloudstruck/Destroy()
	. = ..()
	QDEL_NULL(mob_overlay)

/datum/status_effect/rust_rite
	id = "rustrite"
	status_type = STATUS_EFFECT_MULTIPLE
	tick_interval = 1 SECONDS
	alert_type = null
	var/atom/target
	VAR_PRIVATE/strength = 1
	// Significant distance to force targets to flee
	var/max_range = 18
	var/tick = 0

/datum/status_effect/rust_rite/Destroy()
	. = ..()
	// Must clear after ..()
	target = null

/datum/status_effect/rust_rite/on_creation(mob/living/new_owner, atom/target, strength = 1)
	if (QDELETED(target) || !target.rust_heretic_act(strength, TRUE))
		qdel(src)
		return FALSE
	. = ..()
	src.target = target
	src.strength = strength
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(target_destroyed))
	new /obj/effect/temp_visual/glowing_rune(get_turf(target))
	if (isliving(target))
		var/mob/living/living_target = target
		living_target.throw_alert("rust_rite", /atom/movable/screen/alert/status_effect/rust_rite)

/datum/status_effect/rust_rite/tick()
	if (get_dist(owner, target) > max_range)
		qdel(src)
		return
	if (owner.stat)
		qdel(src)
		return
	target.rust_heretic_act(strength, FALSE)
	if (tick >= 5)
		playsound(target, get_sfx("hull_creaking"), 60, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		tick = 0

/datum/status_effect/rust_rite/on_remove()
	if (isliving(target))
		var/mob/living/living_target = target
		living_target.clear_alert("rust_rite")

/datum/status_effect/rust_rite/proc/target_destroyed(...)
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/alert/status_effect/rust_rite
	name = "Grasp of Rust"
	desc = "Rust is spreading across the inorganic materials on you, flee from the source of the rust to prevent it from overwhelming you!"
	icon_state = "rust_rite"

/datum/status_effect/ashen_passage
	id = "ashenpassage"
	duration = 12 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/ashen_passage
	show_duration = TRUE
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/ashen_passage/on_apply()
	owner.pass_flags |= PASSDOORS
	owner.status_flags |= GODMODE
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	ADD_TRAIT(owner, TRAIT_IGNORESLOWDOWN, type)
	ADD_TRAIT(owner, TRAIT_NOGUNS, type)
	RegisterSignal(owner, COMSIG_ATOM_BULLET_ACT, PROC_REF(ignore_projectiles))
	RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACK, PROC_REF(cancel_passage))
	RegisterSignal(owner, COMSIG_MOB_ATTACK_HAND, PROC_REF(cancel_passage))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	owner.add_filter("ash_jaunt", 1, layering_filter(icon('icons/effects/weather_effects.dmi', "ash_storm"), blend_mode = BLEND_INSET_OVERLAY))
	playsound(get_turf(owner), 'sound/magic/ethereal_enter.ogg', 50, TRUE, -1)
	return TRUE

/datum/status_effect/ashen_passage/on_remove()
	owner.status_flags &= ~(GODMODE)
	owner.pass_flags &= ~(PASSDOORS)
	owner.invisibility = initial(owner.invisibility)
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, type)
	REMOVE_TRAIT(owner, TRAIT_IGNORESLOWDOWN, type)
	REMOVE_TRAIT(owner, TRAIT_NOGUNS, type)
	UnregisterSignal(owner, COMSIG_ATOM_BULLET_ACT)
	owner.remove_filter("ash_jaunt")
	playsound(get_turf(owner), 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)

/datum/status_effect/ashen_passage/proc/ignore_projectiles(mob/living/source, obj/projectile/P, def_zone)
	SIGNAL_HANDLER
	return BULLET_ACT_FORCE_PIERCE

/datum/status_effect/ashen_passage/proc/cancel_passage(mob/living/source, mob/living/target)
	SIGNAL_HANDLER
	if (!istype(target))
		return
	qdel(src)

/datum/status_effect/ashen_passage/proc/on_move(mob/living/source, turf/old_loc, dir, forced)
	SIGNAL_HANDLER
	var/turf/new_loc = source.loc
	if (!istype(old_loc) || !istype(new_loc))
		return
	if ((locate(/obj/machinery/door) in new_loc) && owner.invisibility != INVISIBILITY_MAXIMUM)
		new /obj/effect/temp_visual/dir_setting/ash_shift/out(old_loc)
		owner.invisibility = INVISIBILITY_MAXIMUM
	if (!(locate(/obj/machinery/door) in new_loc) && owner.invisibility == INVISIBILITY_MAXIMUM)
		new /obj/effect/temp_visual/dir_setting/ash_shift(new_loc)
		owner.invisibility = initial(owner.invisibility)

/atom/movable/screen/alert/status_effect/ashen_passage
	name = "Ashen Passage"
	desc = "You have turned to ash! You can pass through airlocks freely and you are unable to take any damage until you attack a living entity."
	icon_state = "ashen_passage"

/obj/effect/temp_visual/dir_setting/ash_shift
	name = "ash_shift"
	icon = 'icons/mob/mob.dmi'
	icon_state = "ash_shift2"
	duration = 13

/obj/effect/temp_visual/dir_setting/ash_shift/out
	icon_state = "ash_shift"
