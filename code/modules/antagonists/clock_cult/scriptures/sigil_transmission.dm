#define SIGIL_TRANSMISSION_RANGE 4

//==================================//
// !      Sigil of Transmission     ! //
//==================================//
/datum/clockcult/scripture/create_structure/sigil_transmission
	name = "Sigil of Transmission"
	desc = "Summons a sigil of transmission, required to power clockwork structures. Will also charge clockwork cyborgs on top of it, and drain power from objects with power. Requires 2 invokers."
	tip = "Power structures using this."
	button_icon_state = "Sigil of Transmission"
	power_cost = 100
	invokation_time = 50
	invokation_text = list("Oh great holy one...", "your energy...", "the power of the holy light!")
	summoned_structure = /obj/structure/destructible/clockwork/sigil/transmission
	cogs_required = 0
	invokers_required = 2
	category = SPELLTYPE_PRESERVATION

//==========Submission=========
/obj/structure/destructible/clockwork/sigil/transmission
	name = "sigil of transmission"
	desc = "A strange sigil, swirling with a yellow light."
	clockwork_desc = "A glorious sigil used to power Rat'varian structures."
	icon_state = "sigiltransmission"
	effect_stand_time = 10
	idle_color = "#f1a746"
	invokation_color = "#f5c529"
	pulse_color = "#f8df8b"
	fail_color = "#f1a746"
	looping = TRUE		//Lopp while in use!
	living_only = FALSE	//This can affect mechs too!
	var/list/linked_structures

/obj/structure/destructible/clockwork/sigil/transmission/Initialize()
	. = ..()
	linked_structures = list()
	for(var/obj/structure/destructible/clockwork/gear_base/GB in range(src, SIGIL_TRANSMISSION_RANGE))
		GB.link_to_sigil(src)
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/clockwork/sigil/transmission/Destroy()
	STOP_PROCESSING(SSobj, src)
	for(var/obj/structure/destructible/clockwork/gear_base/GB as anything in linked_structures)
		GB.unlink_to_sigil(src)
	. = ..()

//We handle updating power, so you don't have to
/obj/structure/destructible/clockwork/sigil/transmission/process()
	for(var/obj/structure/destructible/clockwork/gear_base/GB as anything in linked_structures)
		if(GB.transmission_sigils[1] == src)	//Make sure we are the master sigil
			GB.update_power()

/obj/structure/destructible/clockwork/sigil/transmission/can_affect(atom/movable/AM)
	return (istype(AM, /obj/mecha) || iscyborg(AM) || ishuman(AM))

/obj/structure/destructible/clockwork/sigil/transmission/apply_effects(atom/movable/AM)
	if(istype(AM, /obj/mecha))
		var/obj/mecha/M = AM
		var/mob/living/O = M.occupant
		var/obj/item/stock_parts/cell/C = M.cell
		if(!C)
			return
		if(O && is_servant_of_ratvar(O))
			if(C.charge < C.maxcharge && GLOB.clockcult_power > 40)
				M.give_power(C.chargerate)
				GLOB.clockcult_power -= 40
		else
			if(C.charge > 0)
				M.use_power(C.chargerate)
				GLOB.clockcult_power += 20
	else if(iscyborg(AM))
		var/mob/living/silicon/robot/R = AM
		var/obj/item/stock_parts/cell/C = R.get_cell()
		if(!C)
			return
		if(is_servant_of_ratvar(R))
			if(GLOB.clockcult_power >= 40)
				if(C.charge < C.maxcharge)
					C.give(C.chargerate)
					GLOB.clockcult_power -= 40
		else
			if(C.charge > C.chargerate)
				C.give(-C.chargerate)
				GLOB.clockcult_power += 40
	else if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		var/list/L = H.get_contents()
		var/applied_charge = FALSE
		for(var/obj/item in L)
			var/obj/item/stock_parts/cell/C = item.get_cell()
			if(C)
				if(is_servant_of_ratvar(H))
					if(GLOB.clockcult_power >= 40)
						if(C.charge < C.maxcharge)
							C.give(C.chargerate)
							applied_charge = TRUE
				else
					if(C.charge > C.chargerate)
						C.give(-C.chargerate)
						GLOB.clockcult_power += 40
		if(applied_charge)
			GLOB.clockcult_power -= 40
