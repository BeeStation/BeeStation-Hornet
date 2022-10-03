/obj/machinery/allaccess
	name = "All Access Dispenser"
	desc = "Some people confuse the Head of Personnel with this. Contains fake all access cards to keep the greytide at bay!"
	icon = 'icons/obj/card.dmi'
	icon_state = "aa"
	var/spawnitem = /obj/item/toy/allaccess
	idle_power_usage = 5
	density = FALSE
	circuit = /obj/item/circuitboard/machine/allaccess
	pass_flags = PASSTABLE

/obj/machinery/allaccess/attack_hand(mob/living/user)
	var/output = new spawnitem
	user.put_in_active_hand(output)
	to_chat(user, "<span class='notice'>You take the card out of the dispenser.</span>")

/obj/machinery/allaccess/power_change()
	if(machine_stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if(powered())
			icon_state = initial(icon_state)
			set_machine_stat(machine_stat & ~NOPOWER)
		else
			icon_state = "[initial(icon_state)]-off"
			machine_stat |= NOPOWER

/obj/machinery/allaccess/real
	desc = "Some people confuse the Head of Personnel with this. Contains real All Access!"  // admin spawn for funnies
	spawnitem = /obj/item/card/id/captains_spare
