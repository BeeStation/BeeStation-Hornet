
/*

Contents:
- Stealth Verbs

*/


/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth()
	if(!suit_user)
		return
	if(stealth)
		cancel_stealth()
	else
		if(cell.charge <= 0)
			to_chat(suit_user, "<span class='warning'>You don't have enough power to enable Stealth!</span>")
			return
		stealth = !stealth
		animate(suit_user, alpha = 50,time = 15)
		suit_user.visible_message("<span class='warning'>[suit_user.name] vanishes into thin air!</span>", \
						"<span class='notice'>You are now mostly invisible to normal detection.</span>")


/obj/item/clothing/suit/space/space_ninja/proc/cancel_stealth()
	if(!suit_user)
		return FALSE
	if(stealth)
		stealth = !stealth
		animate(suit_user, alpha = 255, time = 15)
		suit_user.visible_message("<span class='warning'>[suit_user.name] appears from thin air!</span>", \
						"<span class='notice'>You are now visible.</span>")
		return TRUE
	return TRUE


/obj/item/clothing/suit/space/space_ninja/proc/stealth()
	if(!s_busy)
		toggle_stealth()
	else
		to_chat(suit_user, "<span class='danger'>Stealth does not appear to work!</span>")
