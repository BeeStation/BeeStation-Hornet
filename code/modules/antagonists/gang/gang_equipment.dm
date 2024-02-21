
//Drug Dispenser

/obj/machinery/chem_dispenser/gang
	icon_state = "minidispenser"
	base_icon_state = "minidispenser"
	working_state = "minidispenser_working"
	nopower_state = "minidispenser_nopower"
	circuit = /obj/item/circuitboard/machine/chem_dispenser/gang
	dispensable_reagents = list(
		/datum/reagent/drug/formaltenamine, //The special gang drug, one of the "win conditions" for getting Reputation.
		/datum/reagent/drug/ketamine,
		/datum/reagent/drug/happiness,
		/datum/reagent/drug/krokodil)
	recharge_amount = 5
	powerefficiency = 0.07 //worse than a standard chem dispenser


/obj/machinery/chem_dispenser/gang/display_beaker()
	var/mutable_appearance/b_o = beaker_overlay || mutable_appearance(icon, "disp_beaker")
	b_o.pixel_y = -4
	b_o.pixel_x = -4
	return b_o

/obj/machinery/chem_dispenser/gang/RefreshParts()
	. = ..()
	var/obj/item/circuitboard/machine/chem_dispenser/gang/board = circuit
	if(board)
		if(board.owner)
			data["owner"] = board.owner
		board.owner = data["owner"]

/obj/item/sbeacondrop/drugs
	desc = "A label on it reads: <i>Warning: Activating this device will send a chemical synthesizer to your location</i>."
	droptype = /obj/machinery/chem_dispenser/gang
	var/datum/team/gang/g

/obj/item/sbeacondrop/drugs/attack_self(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In.</span>")
		var/obj/machinery/chem_dispenser/gang/thing = new droptype( user.loc )
		thing.data["owner"] = g
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return

/obj/item/card/id/pass/maintenance
	name = "maintenance access pass"
	desc = "A small card, that when used on an ID, will grant basic maintenance access."
	access = list(ACCESS_MAINT_TUNNELS)
