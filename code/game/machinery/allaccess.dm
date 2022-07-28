/obj/machinery/allaccess
	name = "All Access Dispenser"
	desc = "Some people confuse the Head of Personell with this. Contains fake all access cards to keep the greytide at bay!"
	var/spawnitem = /obj/item/toy/allaccess
	idle_power_usage = 5

/obj/machinery/allaccess/attack_hand(mob/living/user)
	var/output = new spawnitem
	user.put_in_active_hand(output)
	to_chat(user, "<span class='notice'>You take the [output.name] out of the dispenser.")

/obj/machinery/allaccess/real
	desc = "Some people confuse the Head of Personell with this. Contains real All Access!"  // admin spawn for funnies
	spawnitem = /obj/item/card/id/captains_spare
