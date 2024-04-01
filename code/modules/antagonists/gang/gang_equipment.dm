
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

//Maintenance access pass
/obj/item/card/id/pass/maintenance
	name = "maintenance access pass"
	desc = "A small card, that when used on an ID, will grant basic maintenance access."
	access = list(ACCESS_MAINT_TUNNELS)

//Credit storage safe, reputation generator and win condition.
/obj/structure/gang_safe
	name = "Gangster Credit Safe"
	desc = "A small safe used by criminal organizations to store credits, has a small DNA lock."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "gang_safe"
	anchored = FALSE
	density = TRUE
	max_integrity = 350
	damage_deflection = 16
	var/datum/bank_account/gang/account
	var/datum/team/gang/gang

/obj/structure/gang_safe/Destroy()
	remove_gang()
	QDEL_NULL(account)
	return ..()

/obj/structure/gang_safe/deconstruct(disassembled)
	new /obj/item/holochip(loc, account.account_balance / 2)
	new /obj/item/stack/sheet/iron(loc, 5)
	new /obj/item/stack/cable_coil(loc, 3)
	..()


/obj/structure/gang_safe/examine(mob/user)
	. = ..()
	if(gang)
		. += "<span class='notice'>It's owned by the [gang.name] gang.</span>"
	else
		. += "<span class='notice'>It's not owned by anyone!<span>"

/obj/structure/gang_safe/attackby(obj/item/W, mob/user, params)
	if(iscash(W))
		insert_money(W, user)
		return
	return ..()

/obj/structure/gang_safe/interact(mob/user)
	var/datum/antagonist/gang/gangster = user.mind.has_antag_datum(/datum/antagonist/gang)
	if(!gangster)
		to_chat(user, "<span class='warning'>You have no idea how to operate this thing.</span>")
		return FALSE
	else
		if(!account)
			to_chat(user, "<span class='warning'>The [src] doesn't have anything inside!</span>")
			return FALSE
		if(account.account_balance == 0)
			to_chat(user, "<span class='warning'>The [src] doesn't have anything inside!</span>")
			return FALSE
		if(gangster.gang != gang)
			to_chat(user, "<span class='warning'>The DNA lock rejects you the [src] seems to be owned by the [gang.name] gang.</span>")
			return FALSE
		var/amount_to_remove =  FLOOR(input(user, "How much do you want to withdraw? Current Balance: [account.account_balance]", "Withdraw Funds", 5) as num, 1)

		if(!amount_to_remove || amount_to_remove < 0)
			to_chat(user, "<span class='warning'>You're pretty sure that's not how money works.</span>")
			return
		if(get_dist(user, src) > 1)
			to_chat(user, "<span class='warning'>You have moved too far away!</span>")
			return
		if(account.adjust_money(-amount_to_remove))
			var/obj/item/holochip/holochip = new (user.drop_location(), amount_to_remove)
			user.put_in_hands(holochip)
			to_chat(user, "<span class='notice'>You withdraw [amount_to_remove] credits into a holochip.</span>")
			return
		else
			var/difference = amount_to_remove - account.account_balance
			account.bank_card_talk("<span class='warning'>ERROR: The [src] requires [difference] more credit\s to perform that withdrawal.</span>", TRUE)



/obj/structure/gang_safe/proc/insert_money(obj/item/I, mob/user)
	if(!account)
		to_chat(user, "<span class='warning'>[src] doesn't have a linked account to deposit [I] into!</span>")
		return
	var/cash_money = I.get_item_credit_value()
	if(!cash_money)
		to_chat(user, "<span class='warning'>[I] doesn't seem to be worth anything!</span>")
		return

	account.adjust_money(cash_money)
	if(istype(I, /obj/item/stack/spacecash) || istype(I, /obj/item/coin))
		to_chat(user, "<span class='notice'>You stuff [I] into the [src]. It disappears in a small puff of bluespace smoke, adding [cash_money] credits to the safe.</span>")
	else
		to_chat(user, "<span class='notice'>You insert [I] into the [src], adding [cash_money] credits to the safe.</span>")

	to_chat(user, "<span class='notice'>The safe now reports a balance of $[account.account_balance].</span>")
	qdel(I)

/obj/structure/gang_safe/wrench_act(mob/living/user, obj/item/item)
	. = ..()
	default_unfasten_wrench(user, item)
	return TRUE

/obj/structure/gang_safe/proc/register_gang(datum/team/gang/g)
	gang = g
	account = new(gang.name)
	gang.bank_accounts += account
	RegisterSignal(gang,COMSIG_PARENT_QDELETING, PROC_REF(remove_gang))

/obj/structure/gang_safe/proc/remove_gang()
	SIGNAL_HANDLER
	if(gang)
		UnregisterSignal(gang, COMSIG_PARENT_QDELETING)
		gang -= account
		gang = null

/obj/item/sbeacondrop/gang_safe
	desc = "A label on it reads: <i>Warning: Activating this device will send a credit safe to your location</i>."
	droptype = /obj/structure/gang_safe
	var/datum/team/gang/g

/obj/item/sbeacondrop/gang_safe/attack_self(mob/user)
	if(user)
		to_chat(user, "<span class='notice'>Locked In.</span>")
		var/obj/structure/gang_safe/thing = new droptype( user.loc )
		thing.register_gang(g)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)
	return
