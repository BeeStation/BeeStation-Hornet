/obj/item/organ/stomach/electrical
	name = "PARENT electric stomach"
	icon_state = "stomach-p"
	desc = "You spawned the parent, dumbass"
	abstract_type = /obj/item/organ/stomach/electrical
	organ_traits = list(TRAIT_NOHUNGER) // We have our own hunger mechanic.
	/// Where the energy of the stomach is stored.
	var/obj/item/stock_parts/cell/cell
	/// Charge lost per life.
	var/discharge_rate = 5e-4 * STANDARD_ETHEREAL_CHARGE
	/// Spam limiter for APC interactions.
	var/drain_time = 0
	//Boolean so we can avoid ten morbillion typechecks between Ethereal or IPC
	var/biological = TRUE
	/// Whilst discharging, prevent multiple life() calls
	var/discharging = FALSE
	/// Peak movement penalty for 0 charge remaining
	var/low_charge_slowdown = 1.5
	/// Has it run dry
	var/in_brownout = FALSE

/obj/item/organ/stomach/electrical/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell/ethereal(null)
	cell.charge = ETHEREAL_CHARGE_ALMOSTFULL

/obj/item/organ/stomach/electrical/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/organ/stomach/electrical/on_life(delta_time, times_fired)
	. = ..()
	adjust_charge(-discharge_rate * delta_time)
	handle_charge(owner, delta_time, times_fired)

/obj/item/organ/stomach/electrical/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	RegisterSignal(organ_owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(charge))
	RegisterSignal(organ_owner, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))
	update_powered_organs(organ_owner)

/obj/item/organ/stomach/electrical/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	UnregisterSignal(organ_owner, COMSIG_LIVING_ELECTROCUTE_ACT)

	exit_brownout(organ_owner)
	organ_owner.remove_movespeed_modifier(/datum/movespeed_modifier/low_charge)
	organ_owner.clear_alert(ALERT_ETHEREAL_CHARGE)
	organ_owner.clear_alert(ALERT_ETHEREAL_OVERCHARGE)
	update_powered_organs(organ_owner)

/obj/item/organ/stomach/electrical/proc/charge(datum/source, amount, repairs)
	SIGNAL_HANDLER
	adjust_charge(amount / 3.5)

/**Changes the energy of the electrical stomach.
* Args:
* - amount: The change of the energy, in joules.
* Returns: The amount of energy that actually got changed in joules.
**/
/obj/item/organ/stomach/electrical/proc/adjust_charge(amount)
	var/amount_changed = clamp(amount, ETHEREAL_CHARGE_NONE - cell.charge, ETHEREAL_CHARGE_DANGEROUS - cell.charge)
	return cell.change(amount_changed)

/obj/item/organ/stomach/electrical/proc/handle_charge(mob/living/carbon/carbon, delta_time, times_fired)
	var/damage_taken = biological ? TOX : BURN

	handle_low_charge(carbon)

	switch(cell.charge)
		if(-INFINITY to ETHEREAL_CHARGE_NONE)
			carbon.throw_alert(ALERT_ETHEREAL_CHARGE, /atom/movable/screen/alert/emptycell/ethereal)
		if(ETHEREAL_CHARGE_NONE to ETHEREAL_CHARGE_LOWPOWER)
			carbon.throw_alert(ALERT_ETHEREAL_CHARGE, /atom/movable/screen/alert/lowcell/ethereal, 3)
		if(ETHEREAL_CHARGE_LOWPOWER to ETHEREAL_CHARGE_NORMAL)
			carbon.throw_alert(ALERT_ETHEREAL_CHARGE, /atom/movable/screen/alert/lowcell/ethereal, 2)
		if(ETHEREAL_CHARGE_FULL to ETHEREAL_CHARGE_OVERLOAD)
			carbon.throw_alert(ALERT_ETHEREAL_OVERCHARGE, /atom/movable/screen/alert/ethereal_overcharge, 1)
			carbon.apply_damage(0.2 * delta_time, damage_taken, null, null)
		if(ETHEREAL_CHARGE_OVERLOAD to ETHEREAL_CHARGE_DANGEROUS)
			carbon.throw_alert(ALERT_ETHEREAL_OVERCHARGE, /atom/movable/screen/alert/ethereal_overcharge, 2)
			carbon.apply_damage(0.325 * delta_time, damage_taken, null, null)
			if(!discharging && DT_PROB(5, delta_time)) // 5% each second for ethereals to explosively release excess energy if it reaches dangerous levels
				INVOKE_ASYNC(src, PROC_REF(discharge_process), carbon) //Keep this async
		else
			carbon.clear_alert(ALERT_ETHEREAL_CHARGE)
			carbon.clear_alert(ALERT_ETHEREAL_OVERCHARGE)

/obj/item/organ/stomach/electrical/proc/handle_low_charge(mob/living/carbon/carbon)
	if(cell.charge <= ETHEREAL_CHARGE_NONE)
		enter_brownout(carbon)
	else
		exit_brownout(carbon)

	if(cell.charge >= ETHEREAL_CHARGE_LOWPOWER)
		carbon.remove_movespeed_modifier(/datum/movespeed_modifier/low_charge)
		return
	carbon.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/low_charge, multiplicative_slowdown = low_charge_slowdown * (1 - (cell.charge / ETHEREAL_CHARGE_LOWPOWER)))

/obj/item/organ/stomach/electrical/proc/enter_brownout(mob/living/carbon/carbon)
	if(in_brownout)
		return
	in_brownout = TRUE
	carbon.drop_all_held_items()
	on_brownout_start(carbon)
	update_powered_organs(carbon)

/obj/item/organ/stomach/electrical/proc/exit_brownout(mob/living/carbon/carbon)
	if(!in_brownout)
		return
	in_brownout = FALSE
	on_brownout_end(carbon)
	update_powered_organs(carbon)

/obj/item/organ/stomach/electrical/proc/update_powered_organs(mob/living/carbon/carbon)
	var/obj/item/organ/heart/ethereal/core = carbon?.get_organ_slot(ORGAN_SLOT_HEART)
	if(istype(core))
		core.refresh_light_color(carbon)

/obj/item/organ/stomach/electrical/proc/on_brownout_start(mob/living/carbon/carbon)
	return

/obj/item/organ/stomach/electrical/proc/on_brownout_end(mob/living/carbon/carbon)
	return

/obj/item/organ/stomach/electrical/proc/discharge_process(mob/living/carbon/carbon)
	if(discharging)
		return
	discharging = TRUE

	to_chat(carbon, span_warning("You begin to lose control over your charge!"))
	carbon.visible_message(span_danger("[carbon] begins to spark violently!"))

	var/static/mutable_appearance/overcharge //shameless copycode from lightning spell
	overcharge = overcharge || mutable_appearance('icons/effects/effects.dmi', "electricity", EFFECTS_LAYER)
	carbon.add_overlay(overcharge)

	var/held = do_after(carbon, 5 SECONDS, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED))
	carbon.cut_overlay(overcharge)
	discharging = FALSE
	if(!held)
		return

	if(ishuman(carbon))
		var/mob/living/carbon/human/human = carbon
		if(human.dna?.species)
			//fixed_mut_color is also ethereal color (for some reason)
			carbon.flash_lighting_fx(5, 7, human.dna.species.fixed_mut_color ? human.dna.species.fixed_mut_color : human.dna.features["mcolor"])

	playsound(carbon, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
	var/vented_energy = -adjust_charge(ETHEREAL_CHARGE_FULL - cell.charge)
	var/discharged_energy = vented_energy * min(7500 / STANDARD_CELL_CHARGE, 1)
	tesla_zap(source = carbon, zap_range = 2, power = discharged_energy, cutoff = ETHEREAL_ZAP_CUTOFF, zap_flags = ZAP_MOB_STUN | ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_LOW_POWER_GEN)
	carbon.visible_message(span_danger("[carbon] violently discharges energy!"), span_warning("You violently discharge energy!"))

	if(prob(10)) //chance of developing heart disease to dissuade overcharging oneself
		var/datum/disease/D = new /datum/disease/heart_failure
		carbon.ForceContractDisease(D)
		to_chat(carbon, span_userdanger("You're pretty sure you just felt your heart stop for a second there.."))
		carbon.playsound_local(carbon, 'sound/effects/singlebeat.ogg', 100, 0)

	carbon.Paralyze(100)

// Signal is (shock_damage, source, siemens_coeff, flags)
/obj/item/organ/stomach/electrical/proc/on_electrocute(datum/source, shock_damage, shock_source, siemens_coeff = 1, flags = NONE)
	SIGNAL_HANDLER
	if(flags & SHOCK_ILLUSION)
		return
	if(biological)
		adjust_charge(shock_damage * siemens_coeff * 2)
		to_chat(owner, span_notice("You absorb some of the shock into your body!"))
	else
		to_chat(owner, span_notice("The shock arcs into your torso, and throughout your delicate chassis!"))
	//Lets give ethereals a break, no break for IPCs.

/obj/item/organ/stomach/electrical/ipc
	name = "micro-cell"
	icon_state = "microcell"
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("assault and batteries")
	attack_verb_simple = list("assault and battery")
	desc = "A micro-cell, for IPC use. Do not swallow."
	organ_flags = ORGAN_ROBOTIC
	biological = FALSE
	/// store the previous display
	var/screen_before_brownout

/obj/item/organ/stomach/electrical/ipc/on_brownout_start(mob/living/carbon/carbon)
	if(isnull(carbon.dna))
		return
	screen_before_brownout = carbon.dna.features["ipc_screen"]
	carbon.dna.features["ipc_screen"] = null
	carbon.update_body()

/obj/item/organ/stomach/electrical/ipc/on_brownout_end(mob/living/carbon/carbon)
	if(isnull(carbon.dna))
		return
	carbon.dna.features["ipc_screen"] = screen_before_brownout
	screen_before_brownout = null
	carbon.update_body()

//getter so we don't grab the dead screen
/obj/item/organ/stomach/electrical/ipc/proc/get_true_screen(mob/living/carbon/carbon)
	return in_brownout ? screen_before_brownout : carbon.dna?.features["ipc_screen"]

/obj/item/organ/stomach/electrical/ipc/emp_act(severity)
	. = ..()
	switch(severity)
		if(1)
			to_chat(owner, span_warning("Alert: Heavy EMP Detected. Rebooting power cell to prevent damage."))
		if(2)
			to_chat(owner, span_warning("Alert: EMP Detected. Cycling battery."))

/obj/item/organ/stomach/electrical/ethereal
	name = "biological battery"
	icon_state = "stomach-p" //Welp. At least it's more unique in functionaliy.
	desc = "A crystal-like organ that stores the electric charge of ethereals."

// Snowflake code while organs live in nullspace
/obj/item/organ/stomach/electrical/ethereal/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	adjust_charge(-ETHEREAL_EMP_CHARGE_LOSS / severity)
