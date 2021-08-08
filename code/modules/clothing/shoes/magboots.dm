/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	var/magboot_state = "magboots"
	var/magpulse = 0
	var/slowdown_active = 2
	permeability_coefficient = 0.05
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 70
	equip_delay_other = 70
	resistance_flags = FIRE_PROOF

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	set src in usr
	if(!can_use(usr))
		return
	attack_self(usr)


/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(magpulse)
		clothing_flags &= ~NOSLIP
		slowdown = SHOES_SLOWDOWN
	else
		clothing_flags |= NOSLIP
		slowdown = slowdown_active
	magpulse = !magpulse
	icon_state = "[magboot_state][magpulse]"
	to_chat(user, "<span class='notice'>You [magpulse ? "enable" : "disable"] the mag-pulse traction system.</span>")
	user.update_inv_shoes()	//so our mob-overlays update
	user.update_gravity(user.has_gravity())
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/shoes/magboots/negates_gravity()
	return isspaceturf(get_turf(src)) ? FALSE : magpulse //We don't mimick gravity on space turfs

/obj/item/clothing/shoes/magboots/examine(mob/user)
	. = ..()
	. += "Its mag-pulse traction system appears to be [magpulse ? "enabled" : "disabled"]."


/obj/item/clothing/shoes/magboots/advance
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "advanced magboots"
	icon_state = "advmag0"
	magboot_state = "advmag"
	slowdown_active = SHOES_SLOWDOWN
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/magboots/syndie
	desc = "Reverse-engineered magnetic boots that have a heavy magnetic pull. Property of Gorlex Marauders."
	name = "blood-red magboots"
	icon_state = "syndiemag0"
	magboot_state = "syndiemag"

/obj/item/clothing/shoes/magboots/commando
	desc = "Military-grade magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "commando magboots"
	icon_state = "advmag0"
	magboot_state = "advmag"
	slowdown_active = SHOES_SLOWDOWN
	armor = list("melee" = 40, "bullet" = 30, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 30, "rad" = 30, "fire" = 90, "acid" = 50, "stamina" = 30)
	clothing_flags = NOSLIP

/obj/item/clothing/shoes/magboots/commando/attack_self(mob/user) //Code for the passive no-slip of the commando magboots to always apply, kind of a shit code solution though.
	if(magpulse)
		slowdown = SHOES_SLOWDOWN
	else
		slowdown = slowdown_active
	magpulse = !magpulse
	icon_state = "[magboot_state][magpulse]"
	to_chat(user, "<span class='notice'>You [magpulse ? "enable" : "disable"] the mag-pulse traction system.</span>")
	user.update_inv_shoes()
	user.update_gravity(user.has_gravity())
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/shoes/magboots/crushing
	desc = "Normal looking magboots that are altered to increase magnetic pull to crush anything underfoot."

/obj/item/clothing/shoes/magboots/crushing/proc/crush(mob/living/user)
	SIGNAL_HANDLER

	if (!isturf(user.loc) || !magpulse)
		return
	var/turf/T = user.loc
	for (var/mob/living/A in T)
		if (A != user && A.lying)
			A.adjustBruteLoss(rand(10,13))
			to_chat(A,"<span class='userdanger'>[user]'s magboots press down on you, crushing you!</span>")
			A.emote("scream")

/obj/item/clothing/shoes/magboots/crushing/attack_self(mob/user)
	. = ..()
	if (magpulse)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED,.proc/crush)
	else
		UnregisterSignal(user,COMSIG_MOVABLE_MOVED)

/obj/item/clothing/shoes/magboots/crushing/equipped(mob/user,slot)
	. = ..()
	if (slot == ITEM_SLOT_FEET && magpulse)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED,.proc/crush)

/obj/item/clothing/shoes/magboots/crushing/dropped(mob/user)
	. = ..()
	UnregisterSignal(user,COMSIG_MOVABLE_MOVED)
