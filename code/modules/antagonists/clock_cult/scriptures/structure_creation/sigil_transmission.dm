/datum/clockcult/scripture/create_structure/sigil_transmission
	name = "Sigil of Transmission"
	desc = "Summons a sigil of transmission, required to power clockwork structures. Will also charge clockwork cyborgs on top of it, and drain power from any objects on it. Requires 2 invokers."
	tip = "Power structures using this."
	invokation_text = list("Oh great holy one...", "your energy...", "the power of the holy light!")
	invokation_time = 5 SECONDS
	invokers_required = 2
	button_icon_state = "Sigil of Transmission"
	power_cost = 100
	summoned_structure = /obj/structure/destructible/clockwork/sigil/transmission
	category = SPELLTYPE_PRESERVATION

/obj/structure/destructible/clockwork/sigil/transmission
	name = "sigil of transmission"
	desc = "A strange sigil, swirling with a yellow light."
	clockwork_desc = span_brass("A glorious sigil used to power Rat'varian structures.")
	icon_state = "sigiltransmission"
	effect_charge_time = 1 SECONDS
	idle_color = "#f1a746"
	invokation_color = "#f5c529"
	success_color = "#f8df8b"
	fail_color = "#f1a746"
	looping = TRUE
	living_only = FALSE // This sigil affects mechs

	/// The clockcult structures that are powered by this sigil
	var/list/linked_structures = list()

/obj/structure/destructible/clockwork/sigil/transmission/Initialize(mapload)
	. = ..()
	for(var/obj/structure/destructible/clockwork/gear_base/gear_base in range(src, SIGIL_TRANSMISSION_RANGE))
		gear_base.linked_transmission_sigil = src
		linked_structures += gear_base
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/sigil/transmission/Destroy()
	for(var/obj/structure/destructible/clockwork/gear_base/gear_base as anything in linked_structures)
		gear_base.unlink_sigil()
	STOP_PROCESSING(SSobj, src)
	return ..()

/*
* Update the power of all linked structures
*/
/obj/structure/destructible/clockwork/sigil/transmission/process()
	for(var/obj/structure/destructible/clockwork/gear_base/gear_base as anything in linked_structures)
		gear_base.update_power()

/obj/structure/destructible/clockwork/sigil/transmission/can_affect(atom/movable/target_atom)
	. = ..()
	if(!.)
		return FALSE

	if(!istype(target_atom, /obj/vehicle/sealed/mecha) && !iscyborg(target_atom) && !ishuman(target_atom))
		return FALSE

/obj/structure/destructible/clockwork/sigil/transmission/apply_effects()
	if(istype(affected_atom, /obj/vehicle/sealed/mecha))
		// Drain the mechs's cell or charge it if the pilot is a servant
		var/obj/vehicle/sealed/mecha/mech = affected_atom
		var/obj/item/stock_parts/cell/mech_cell = mech.cell
		if(!mech_cell)
			return ..()

		var/mob/living/mech_occupant = mech.occupants
		if(IS_SERVANT_OF_RATVAR(mech_occupant))
			if(mech_cell.charge < mech_cell.maxcharge && GLOB.clockcult_power > 40)
				mech.give_power(mech_cell.chargerate)
				GLOB.clockcult_power -= 40
		else
			if(mech_cell.charge > 0)
				mech.use_power(mech_cell.chargerate)
				GLOB.clockcult_power += 20
	else if(iscyborg(affected_atom))
		// Drain the borg's cell or charge it if they are a servant
		var/mob/living/silicon/robot/borg = affected_atom
		var/obj/item/stock_parts/cell/borg_cell = borg.get_cell()
		if(!borg_cell)
			return ..()

		if(IS_SERVANT_OF_RATVAR(borg))
			if(GLOB.clockcult_power >= 40)
				if(borg_cell.charge < borg_cell.maxcharge)
					borg_cell.give(borg_cell.chargerate)
					GLOB.clockcult_power -= 40
		else
			if(borg_cell.charge > borg_cell.chargerate)
				borg_cell.give(-borg_cell.chargerate)
				GLOB.clockcult_power += 40
	else if(ishuman(affected_atom))
		// Drain the target's cells or charge them if they are a servant
		var/mob/living/carbon/human/human_target = affected_atom
		for(var/obj/item in human_target.get_contents())
			var/obj/item/stock_parts/cell/power_cell = item
			if(!power_cell)
				return ..()

			if(IS_SERVANT_OF_RATVAR(human_target))
				if(GLOB.clockcult_power >= 40)
					if(power_cell.charge < power_cell.maxcharge)
						power_cell.give(power_cell.chargerate)
						GLOB.clockcult_power -= 40
			else
				if(power_cell.charge > power_cell.chargerate)
					power_cell.give(-power_cell.chargerate)
					GLOB.clockcult_power += 40
	return ..()
