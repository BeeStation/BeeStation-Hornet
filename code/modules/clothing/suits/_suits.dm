#define FOOTSTEP_COOLDOWN 3	//3 deci-seconds

/obj/item/clothing/suit
	icon = 'icons/obj/clothing/suits.dmi'
	name = "suit"
	var/fire_resist = T0C+100
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)
	slot_flags = ITEM_SLOT_OCLOTHING
	var/blood_overlay_type = "suit"
	var/togglename = null
	var/suittoggled = FALSE
	var/move_sound = null
	var/footstep = 0
	var/mob/listeningTo
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/exo


/obj/item/clothing/suit/worn_overlays(isinhands = FALSE)
	. = list()
	if(!isinhands)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damaged[blood_overlay_type]")
		if(HAS_BLOOD_DNA(src))
			. += mutable_appearance('icons/effects/blood.dmi', "[blood_overlay_type]blood")
		var/mob/living/carbon/human/M = loc
		if(ishuman(M) && M.w_uniform)
			var/obj/item/clothing/under/U = M.w_uniform
			if(istype(U) && U.attached_accessory)
				var/obj/item/clothing/accessory/A = U.attached_accessory
				if(A.above_suit)
					. += U.accessory_overlay

/obj/item/clothing/suit/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_wear_suit()

/obj/item/clothing/suit/proc/on_mob_move()
	SIGNAL_HANDLER

	var/mob/living/carbon/human/H = loc
	if(!istype(H) || H.wear_suit != src)
		return
	if(world.time > footstep)
		playsound(src, pick(move_sound), 100, 1)
		footstep = world.time + FOOTSTEP_COOLDOWN

/obj/item/clothing/suit/equipped(mob/user, slot)
	. = ..()
	//If we dont have move sounds, ignore
	if(!islist(move_sound))
		return
	//Check if we were taken off.
	if(slot != ITEM_SLOT_OCLOTHING)
		if(listeningTo)
			UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
			listeningTo = null
		return
	if(listeningTo == user)
		return
	//Remove old listener
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
	//Add new listener
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/on_mob_move)
	listeningTo = user

/obj/item/clothing/suit/dropped(mob/user)
	. = ..()
	//Remove our listener
	if(listeningTo)
		UnregisterSignal(listeningTo, COMSIG_MOVABLE_MOVED)
		listeningTo = null

/obj/item/clothing/suit/Destroy()
	listeningTo = null
	. = ..()

#undef FOOTSTEP_COOLDOWN
