/obj/item/organ/cyberimp/chest
	name = "cybernetic torso implant"
	desc = "Implants for the organs in your torso."
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	zone = BODY_ZONE_CHEST

/obj/item/organ/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	icon_state = "chest_implant"
	implant_color = "#00AA00"
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = FALSE
	var/malfunctioning = FALSE
	slot = ORGAN_SLOT_STOMACH_AID

/obj/item/organ/cyberimp/chest/nutriment/on_life()
	if(synthesizing)
		return

	if(malfunctioning && owner.nutrition >= hunger_threshold)
		synthesizing = TRUE
		to_chat(owner, span_warning("You feel like your insides are burning."))
		owner.adjust_nutrition(-50)
		addtimer(CALLBACK(src, PROC_REF(synth_cool)), 2 MINUTES)

	else if(owner.nutrition <= hunger_threshold)
		synthesizing = TRUE
		to_chat(owner, span_notice("You feel less hungry..."))
		owner.adjust_nutrition(50)
		addtimer(CALLBACK(src, PROC_REF(synth_cool)), 5 SECONDS)

/obj/item/organ/cyberimp/chest/nutriment/proc/synth_cool()
	synthesizing = FALSE

/obj/item/organ/cyberimp/chest/nutriment/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(prob(30/severity))
		malfunctioning = TRUE

/obj/item/organ/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	icon_state = "chest_implant"
	implant_color = "#006607"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY

/obj/item/organ/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness. For the faint of heart!"
	icon_state = "chest_implant"
	implant_color = "#AD0000"
	slot = ORGAN_SLOT_HEART_AID
	var/revive_cost = 0
	var/reviving = FALSE
	COOLDOWN_DECLARE(reviver_cooldown)

/obj/item/organ/cyberimp/chest/reviver/on_life()
	if(reviving)
		switch(owner.stat)
			if(UNCONSCIOUS, HARD_CRIT)
				addtimer(CALLBACK(src, PROC_REF(heal)), 30)
			else
				COOLDOWN_START(src, reviver_cooldown, revive_cost)
				reviving = FALSE
				to_chat(owner, span_notice("Your reviver implant shuts down and starts recharging. It will be ready again in [DisplayTimeText(revive_cost)]."))
		return

	if(!COOLDOWN_FINISHED(src, reviver_cooldown) || owner.suiciding)
		return

	switch(owner.stat)
		if(UNCONSCIOUS, HARD_CRIT)
			revive_cost = 0
			reviving = TRUE
			to_chat(owner, span_notice("You feel a faint buzzing as your reviver implant starts patching your wounds..."))

/obj/item/organ/cyberimp/chest/reviver/proc/heal()
	if(owner.getOxyLoss())
		owner.adjustOxyLoss(-5)
		revive_cost += 5
	if(owner.getBruteLoss())
		owner.adjustBruteLoss(-2)
		revive_cost += 40
	if(owner.getFireLoss())
		owner.adjustFireLoss(-2)
		revive_cost += 40
	if(owner.getToxLoss())
		owner.adjustToxLoss(-1)
		revive_cost += 40

/obj/item/organ/cyberimp/chest/reviver/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(prob(30/severity))
		to_chat(owner, span_userdanger("You feel a sharp pain in your chest, your reviver implant seems to have shorted out!"))
		owner.Knockdown((3 SECONDS))
		Destroy()

/obj/item/organ/cyberimp/chest/reviver/syndicate
	syndicate_implant = TRUE

/obj/item/organ/cyberimp/chest/thrusters
	name = "implantable thrusters set"
	desc = "An implantable set of thruster ports. They use the gas from environment or subject's internals for propulsion in zero-gravity areas. \
	Unlike regular jetpacks, this device has no stabilization system."
	slot = ORGAN_SLOT_THRUSTERS
	icon_state = "imp_jetpack"
	base_icon_state = "imp_jetpack"
	implant_overlay = null
	implant_color = null
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	w_class = WEIGHT_CLASS_NORMAL
	var/on = FALSE
	var/datum/effect_system/trail_follow/ion/ion_trail

/obj/item/organ/cyberimp/chest/thrusters/Insert(mob/living/carbon/M, special = 0, pref_load = FALSE)
	. = ..()
	if(!ion_trail)
		ion_trail = new
	ion_trail.set_up(M)

/obj/item/organ/cyberimp/chest/thrusters/Remove(mob/living/carbon/M, special = 0, pref_load = FALSE)
	if(on)
		toggle(silent = TRUE)
	..()

/obj/item/organ/cyberimp/chest/thrusters/ui_action_click()
	toggle()

/obj/item/organ/cyberimp/chest/thrusters/proc/toggle(silent = FALSE)
	if(!on)
		if((organ_flags & ORGAN_FAILING))
			if(!silent)
				to_chat(owner, span_warning("Your thrusters set seems to be broken!"))
			return 0
		on = TRUE
		if(allow_thrust(THRUST_REQUIREMENT_SPACEMOVE))
			ion_trail.start()
			JETPACK_SPEED_CHECK(owner, MOVESPEED_ID_CYBER_THRUSTER, -1, TRUE)
			RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(move_react))
			if(!silent)
				to_chat(owner, span_notice("You turn your thrusters set on."))
	else
		ion_trail.stop()
		owner.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/cybernetic)
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
		if(!silent)
			to_chat(owner, span_notice("You turn your thrusters set off."))
		on = FALSE
	update_icon()

/obj/item/organ/cyberimp/chest/thrusters/update_icon_state()
	icon_state = "[base_icon_state][on ? "-on" : null]"
	return ..()

/obj/item/organ/cyberimp/chest/thrusters/proc/move_react()
	SIGNAL_HANDLER

	allow_thrust(THRUST_REQUIREMENT_SPACEMOVE)

/obj/item/organ/cyberimp/chest/thrusters/proc/allow_thrust(num, use_fuel = TRUE)
	if(!on || !owner)
		return 0

	var/turf/T = get_turf(owner)
	if(!T) // No more runtimes from being stuck in nullspace.
		return 0
	if((owner.movement_type & (FLOATING|FLYING)) && owner.has_gravity())
		return 0
	// Priority 1: use air from environment.
	var/datum/gas_mixture/environment = T.return_air()
	if(environment && environment.return_pressure() > 30)
		return 1

	// Priority 2: use plasma from internal plasma storage.
	// (just in case someone would ever use this implant system to make cyber-alien ops with jetpacks and taser arms)
	if(owner.getPlasma() >= num*100)
		if(use_fuel)
			owner.adjustPlasma(-num*100)
		return 1

	// Priority 3: use internals tank.
	var/datum/gas_mixture/internal_mix = owner.internal.return_air()
	if(internal_mix && internal_mix.total_moles() > num)
		var/datum/gas_mixture/removed = internal_mix.remove(num)
		if(removed.total_moles() > 0.005)
			T.assume_air(removed)
			ion_trail.generate_effect()

	toggle(silent = TRUE)
	return 0
