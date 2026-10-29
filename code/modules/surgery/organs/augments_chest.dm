/obj/item/organ/cyberimp/chest
	abstract_type = /obj/item/organ/cyberimp/chest
	name = "cybernetic torso implant"
	desc = "Implants for the organs in your torso."
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	zone = BODY_ZONE_CHEST

/obj/item/organ/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	icon_state = "chest_implant"
	implant_color = COLOR_DARK_LIME
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = FALSE
	var/malfunctioning = FALSE
	slot = ORGAN_SLOT_STOMACH_AID

/obj/item/organ/cyberimp/chest/nutriment/on_life(delta_time, times_fired)
	SHOULD_CALL_PARENT(FALSE)
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
		owner.adjust_nutrition(25 * delta_time)
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

/obj/item/organ/cyberimp/chest/reviver/on_life(delta_time, times_fired)
	SHOULD_CALL_PARENT(FALSE)
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
	var/need_mob_update = FALSE
	if(owner.getOxyLoss())
		need_mob_update += owner.adjustOxyLoss(-5, updating_health = FALSE)
		revive_cost += 5
	if(owner.getBruteLoss())
		need_mob_update += owner.adjustBruteLoss(-2, updating_health = FALSE)
		revive_cost += 40
	if(owner.getFireLoss())
		need_mob_update += owner.adjustFireLoss(-2, updating_health = FALSE)
		revive_cost += 40
	if(owner.getToxLoss())
		need_mob_update += owner.adjustToxLoss(-1, updating_health = FALSE)
		revive_cost += 40
	if(need_mob_update)
		owner.updatehealth()

/obj/item/organ/cyberimp/chest/reviver/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(prob(30/severity))
		to_chat(owner, span_userdanger("You feel a sharp pain in your chest, your reviver implant seems to have shorted out!"))
		owner.Knockdown((3 SECONDS))
		qdel(src)

/obj/item/organ/cyberimp/chest/reviver/syndicate
	organ_flags = ORGAN_ROBOTIC | ORGAN_HIDDEN

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

/obj/item/organ/cyberimp/chest/thrusters/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/jetpack, \
		FALSE, \
		COMSIG_THRUSTER_ACTIVATED, \
		COMSIG_THRUSTER_DEACTIVATED, \
		THRUSTER_ACTIVATION_FAILED, \
		CALLBACK(src, PROC_REF(allow_thrust), 0.01), \
		/datum/effect_system/trail_follow/ion \
	)

/obj/item/organ/cyberimp/chest/thrusters/Remove(mob/living/carbon/M, special, movement_flags)
	if(on)
		deactivate(silent = TRUE)
	..()

/obj/item/organ/cyberimp/chest/thrusters/ui_action_click()
	toggle()

/obj/item/organ/cyberimp/chest/thrusters/proc/toggle(silent = FALSE)
	if(on)
		deactivate()
	else
		activate()

/obj/item/organ/cyberimp/chest/thrusters/proc/activate(silent = FALSE)
	if(on)
		return
	if(organ_flags & ORGAN_FAILING)
		if(!silent)
			to_chat(owner, span_warning("Your thrusters set seems to be broken!"))
		return
	if(SEND_SIGNAL(src, COMSIG_THRUSTER_ACTIVATED, owner) & THRUSTER_ACTIVATION_FAILED)
		return

	on = TRUE
	owner.add_movespeed_modifier(/datum/movespeed_modifier/jetpack/cybernetic)
	if(!silent)
		to_chat(owner, span_notice("You turn your thrusters set on."))
	update_appearance()

/obj/item/organ/cyberimp/chest/thrusters/proc/deactivate(silent = FALSE)
	if(!on)
		return
	SEND_SIGNAL(src, COMSIG_THRUSTER_DEACTIVATED, owner)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/cybernetic)
	if(!silent)
		to_chat(owner, span_notice("You turn your thrusters set off."))
	on = FALSE
	update_appearance()

/obj/item/organ/cyberimp/chest/thrusters/update_icon_state()
	icon_state = "[base_icon_state][on ? "-on" : null]"
	return ..()

/obj/item/organ/cyberimp/chest/thrusters/proc/allow_thrust(num, use_fuel = TRUE)
	if(!on || !owner)
		return FALSE

	var/turf/T = get_turf(owner)
	if(!T) // No more runtimes from being stuck in nullspace.
		return FALSE
		
	if((owner.movement_type & (FLOATING|FLYING)) && owner.has_gravity())
		return FALSE
	// Priority 1: use air from environment.
	var/datum/gas_mixture/environment = T.return_air()
	if(environment && environment.return_pressure() > 30)
		return TRUE

	// Priority 2: use plasma from internal plasma storage.
	// (just in case someone would ever use this implant system to make cyber-alien ops with jetpacks and taser arms)
	if(owner.getPlasma() >= num * 100)
		if(use_fuel)
			owner.adjustPlasma(-num*100)
		return TRUE

	// Priority 3: use internals tank.
	var/datum/gas_mixture/internal_mix = owner.internal?.return_air()
	if(internal_mix && internal_mix.total_moles() > num)
		if(!use_fuel)
			return TRUE
		var/datum/gas_mixture/removed = internal_mix.remove(num)
		if(removed.total_moles() > 0.005)
			T.assume_air(removed)
			return TRUE
		else
			T.assume_air(removed)

	deactivate(silent = TRUE)
	return FALSE
