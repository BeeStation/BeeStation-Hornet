
/*

Contents:
- Stealth Verbs

*/


/obj/item/clothing/suit/space/space_ninja/proc/toggle_stealth()
	var/mob/living/carbon/human/U = affecting
	if(!U)
		return
	if(stealth)
		cancel_stealth()
	else
		if(cell.charge <= 0)
			to_chat(U, span_warning("You don't have enough power to enable Stealth!"))
			return
		stealth = !stealth
		animate(U, alpha = 50,time = 15)
		U.visible_message(span_warning("[U.name] vanishes into thin air!"), \
						span_notice("You are now mostly invisible to normal detection."))


/obj/item/clothing/suit/space/space_ninja/proc/cancel_stealth()
	var/mob/living/carbon/human/U = affecting
	if(!U)
		return FALSE
	if(stealth)
		stealth = !stealth
		animate(U, alpha = 255, time = 15)
		U.visible_message(span_warning("[U.name] appears from thin air!"), \
						span_notice("You are now visible."))
		return TRUE
	return FALSE


/obj/item/clothing/suit/space/space_ninja/proc/stealth()
	if(!s_busy)
		toggle_stealth()
	else
		to_chat(affecting, span_danger("Stealth does not appear to work!"))
