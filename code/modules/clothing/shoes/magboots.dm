/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle. Walking carefully lets the user gain better traction."
	name = "magboots"
	icon_state = "magboots0"
	item_state = "magboots"
	var/magboot_state = "magboots"
	var/magpulse = 0
	var/slowdown_active = 2
	armor_type = /datum/armor/shoes_magboots
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 70
	equip_delay_other = 70
	resistance_flags = FIRE_PROOF

/obj/item/clothing/shoes/magboots/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_FEET)
		update_gravity_trait(user)
	else
		REMOVE_TRAIT(user, TRAIT_NEGATES_GRAVITY, type)

/obj/item/clothing/shoes/magboots/dropped(mob/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_NEGATES_GRAVITY, type)


/datum/armor/shoes_magboots
	bio = 90

/obj/item/clothing/shoes/magboots/verb/toggle()
	set name = "Toggle Magboots"
	set category = "Object"
	set src in usr
	if(!can_use(usr))
		return
	attack_self(usr)


/obj/item/clothing/shoes/magboots/attack_self(mob/living/user)
	if(magpulse)
		clothing_flags &= ~NOSLIP_ALL_WALKING
		clothing_flags &= ~NOSLIP
		slowdown = SHOES_SLOWDOWN
	else
		clothing_flags |= NOSLIP_ALL_WALKING
		clothing_flags |= NOSLIP
		slowdown = slowdown_active
	magpulse = !magpulse
	icon_state = "[magboot_state][magpulse]"
	update_gravity_trait(user)
	user.refresh_gravity()
	user.update_equipment_speed_mods()
	update_action_buttons()

/obj/item/clothing/shoes/magboots/examine(mob/user)
	. = ..()
	. += "Its mag-pulse traction system appears to be [magpulse ? "enabled" : "disabled"]."

///Adds/removes the gravity negation trait from the wearer depending on if the magpulse system is turned on.
/obj/item/clothing/shoes/magboots/proc/update_gravity_trait(mob/user)
	if(magpulse)
		ADD_TRAIT(user, TRAIT_NEGATES_GRAVITY, type)
	else
		REMOVE_TRAIT(user, TRAIT_NEGATES_GRAVITY, type)


/obj/item/clothing/shoes/magboots/advance
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "advanced magboots"
	icon_state = "advmag0"
	magboot_state = "advmag"
	slowdown_active = SHOES_SLOWDOWN
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	investigate_flags = ADMIN_INVESTIGATE_TARGET

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
	armor_type = /datum/armor/magboots_commando
	clothing_flags = NOSLIP


/datum/armor/magboots_commando
	melee = 40
	bullet = 30
	laser = 25
	energy = 25
	bomb = 50
	bio = 30
	rad = 30
	fire = 90
	acid = 50
	stamina = 30
	bleed = 40

/obj/item/clothing/shoes/magboots/commando/attack_self(mob/user)
	. = ..()
	clothing_flags |= NOSLIP

/obj/item/clothing/shoes/magboots/crushing
	desc = "Normal looking magboots that are altered to increase magnetic pull to crush anything underfoot."

/obj/item/clothing/shoes/magboots/crushing/proc/crush(mob/living/user)
	SIGNAL_HANDLER

	if (!isturf(user.loc) || !magpulse)
		return
	var/turf/T = user.loc
	for (var/mob/living/A in T)
		if (A != user && A.body_position == LYING_DOWN)
			A.adjustBruteLoss(rand(10,13))
			to_chat(A,span_userdanger("[user]'s magboots press down on you, crushing you!"))
			INVOKE_ASYNC(A, TYPE_PROC_REF(/mob, emote), "scream")

/obj/item/clothing/shoes/magboots/crushing/attack_self(mob/user)
	. = ..()
	if (magpulse)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED,PROC_REF(crush))
	else
		UnregisterSignal(user,COMSIG_MOVABLE_MOVED)

/obj/item/clothing/shoes/magboots/crushing/equipped(mob/user,slot)
	. = ..()
	if (slot == ITEM_SLOT_FEET && magpulse)
		RegisterSignal(user, COMSIG_MOVABLE_MOVED,PROC_REF(crush))

/obj/item/clothing/shoes/magboots/crushing/dropped(mob/user)
	..()
	UnregisterSignal(user,COMSIG_MOVABLE_MOVED)
