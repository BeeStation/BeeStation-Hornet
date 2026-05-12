/obj/item/organ/stomach/electrical
	name = "PARENT electric stomach"
	icon_state = "stomach-p"
	desc = "You spawned the parent, dumbass"
	abstract_type = /obj/item/organ/stomach/electrical
	organ_traits = list(TRAIT_NOHUNGER) // We have our own hunger mechanic.
	/// Where the energy of the stomach is stored.
	var/obj/item/stock_parts/cell/cell
	/// Spam limiter for APC interactions.
	var/drain_time = 0
	//Boolean so we can avoid ten morbillion typechecks between Ethereal or IPC
	var/biological = TRUE

/obj/item/organ/stomach/electrical/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell/ethereal(null)
	cell.charge = ETHEREAL_CHARGE_ALMOSTFULL

/obj/item/organ/stomach/electrical/Destroy()
	QDEL_NULL(cell)
	return ..()

/obj/item/organ/stomach/electrical/on_life(delta_time, times_fired)
	. = ..()
	adjust_charge(-ETHEREAL_DISCHARGE_RATE * delta_time)
	handle_charge(owner, delta_time, times_fired)

/obj/item/organ/stomach/electrical/Insert(mob/living/carbon/carbon, special = 0, drop_if_replaced)
	. = ..()
	RegisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(charge))
	RegisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(on_electrocute))

/obj/item/organ/stomach/electrical/Remove(mob/living/carbon/carbon, special = 0, pref_load)
	UnregisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	UnregisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT)

	carbon.clear_alert("ethereal_charge")
	carbon.clear_alert("ethereal_overcharge")

	return ..()

/obj/item/organ/stomach/electrical/handle_hunger_slowdown(mob/living/carbon/human/human)
	human.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hunger, multiplicative_slowdown = (1.5 * (1 - cell.charge / 100)))

/obj/item/organ/stomach/electrical/proc/charge(datum/source, amount, repairs)
	SIGNAL_HANDLER
	adjust_charge(amount / 3.5)

/**Changes the energy of the crystal stomach.
* Args:
* - amount: The change of the energy, in joules.
* Returns: The amount of energy that actually got changed in joules.
**/
/obj/item/organ/stomach/electrical/proc/adjust_charge(amount)
	var/amount_changed = clamp(amount, ETHEREAL_CHARGE_NONE - cell.charge, ETHEREAL_CHARGE_DANGEROUS - cell.charge)
	return cell.change(amount_changed)

/obj/item/organ/stomach/electrical/proc/handle_charge(mob/living/carbon/carbon, delta_time, times_fired)
	var/damage_taken = biological ? TOX : BURN
	switch(cell.charge)
		if(-INFINITY to ETHEREAL_CHARGE_NONE)
			carbon.throw_alert("ethereal_charge", /atom/movable/screen/alert/emptycell/ethereal)
			if(carbon.health > 10.5)
				carbon.apply_damage(0.65, damage_taken, null, null, carbon)
		if(ETHEREAL_CHARGE_NONE to ETHEREAL_CHARGE_LOWPOWER)
			carbon.throw_alert("ethereal_charge", /atom/movable/screen/alert/lowcell/ethereal, 3)
			if(carbon.health > 10.5)
				carbon.apply_damage(0.325 * delta_time, damage_taken, null, null, carbon)
		if(ETHEREAL_CHARGE_LOWPOWER to ETHEREAL_CHARGE_NORMAL)
			carbon.throw_alert("ethereal_charge", /atom/movable/screen/alert/lowcell/ethereal, 2)
		if(ETHEREAL_CHARGE_FULL to ETHEREAL_CHARGE_OVERLOAD)
			carbon.throw_alert("ethereal_overcharge", /atom/movable/screen/alert/ethereal_overcharge, 1)
			carbon.apply_damage(0.2, damage_taken, null, null, carbon)
		if(ETHEREAL_CHARGE_OVERLOAD to ETHEREAL_CHARGE_DANGEROUS)
			carbon.throw_alert("ethereal_overcharge", /atom/movable/screen/alert/ethereal_overcharge, 2)
			carbon.apply_damage(0.325 * delta_time, damage_taken, null, null, carbon)
			if(DT_PROB(5, delta_time)) // 5% each seacond for ethereals to explosively release excess energy if it reaches dangerous levels
				discharge_process(carbon)
		else
			carbon.clear_alert("ethereal_charge")
			carbon.clear_alert("ethereal_overcharge")

/obj/item/organ/stomach/electrical/proc/discharge_process(mob/living/carbon/carbon)
	to_chat(carbon, span_warning("You begin to lose control over your charge!"))
	carbon.visible_message(span_danger("[carbon] begins to spark violently!"))

	var/static/mutable_appearance/overcharge //shameless copycode from lightning spell
	overcharge = overcharge || mutable_appearance('icons/effects/effects.dmi', "electricity", EFFECTS_LAYER)
	carbon.add_overlay(overcharge)

	if(do_after(carbon, 5 SECONDS, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED)))
		if(ishuman(carbon))
			var/mob/living/carbon/human/human = carbon
			if(human.dna?.species)
				//fixed_mut_color is also ethereal color (for some reason)
				carbon.flash_lighting_fx(5, 7, human.dna.species.fixed_mut_color ? human.dna.species.fixed_mut_color : human.dna.features["mcolor"])

		playsound(carbon, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
		carbon.cut_overlay(overcharge)
		// Only a small amount of the energy gets discharged as the zap. The rest dissipates as heat. Keeps the damage and energy from the zap the same regardless of what STANDARD_CELL_CHARGE is.
		var/discharged_energy = -adjust_charge(ETHEREAL_CHARGE_FULL - cell.charge) * min(7500 / STANDARD_CELL_CHARGE, 1)
		tesla_zap(source = carbon, zap_range = 2, power = discharged_energy, cutoff = 1 MEGAWATT, zap_flags = ZAP_OBJ_DAMAGE | ZAP_LOW_POWER_GEN | ZAP_ALLOW_DUPLICATES)
		adjust_charge(ETHEREAL_CHARGE_FULL - discharged_energy)
		carbon.visible_message(span_danger("[carbon] violently discharges energy!"), span_warning("You violently discharge energy!"))

		if(prob(10)) //chance of developing heart disease to dissuade overcharging oneself
			var/datum/disease/D = new /datum/disease/heart_failure
			carbon.ForceContractDisease(D)
			to_chat(carbon, span_userdanger("You're pretty sure you just felt your heart stop for a second there.."))
			carbon.playsound_local(carbon, 'sound/effects/singlebeat.ogg', 100, 0)

		carbon.Paralyze(100)

/obj/item/organ/stomach/electrical/proc/on_electrocute(datum/source, shock_damage, siemens_coeff = 1, flags = NONE)
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
