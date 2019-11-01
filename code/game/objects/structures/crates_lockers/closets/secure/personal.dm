/obj/structure/closet/secure_closet/personal
	desc = "It's a secure locker for personnel. The first card swiped gains control."
	name = "personal closet"
	req_access = list(ACCESS_ALL_PERSONAL_LOCKERS)
	var/registered_name = null

/obj/structure/closet/secure_closet/personal/examine(mob/user)
	..()
	if(registered_name)
		to_chat(user, "<span class='notice'>The display reads, \"Owned by [registered_name]\".</span>")

/obj/structure/closet/secure_closet/personal/check_access(obj/item/card/id/I)
	. = ..()
	if(!I || !istype(I))
		return
	if(registered_name == I.registered_name)
		return TRUE

/obj/structure/closet/secure_closet/personal/PopulateContents()
	..()
	if(prob(50))
		new /obj/item/storage/backpack/duffelbag(src)
	if(prob(50))
		new /obj/item/storage/backpack(src)
	else
		new /obj/item/storage/backpack/satchel(src)
	new /obj/item/radio/headset( src )

/obj/structure/closet/secure_closet/personal/patient
	name = "patient's closet"

/obj/structure/closet/secure_closet/personal/patient/PopulateContents()
	new /obj/item/clothing/under/color/white(src)
	new /obj/item/clothing/shoes/sneakers/white(src)

/obj/structure/closet/secure_closet/personal/cabinet
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50

/obj/structure/closet/secure_closet/personal/cabinet/PopulateContents()
	new /obj/item/storage/backpack/satchel/leather/withwallet( src )
	new /obj/item/instrument/piano_synth(src)
	new /obj/item/radio/headset( src )

/obj/structure/closet/secure_closet/personal/attackby(obj/item/W, mob/user, params)
	var/obj/item/card/id/I = W.GetID()
	if(!I || !istype(I))
		return ..()
	if(!can_lock(user, FALSE)) //Can't do anything if there isn't a lock!
		return
	if(I.registered_name && !registered_name)
		to_chat(user, "<span class='notice'>You claim [src].</span>")
		registered_name = I.registered_name
	else
		..()

/obj/structure/closet/secure_closet/personal/handle_lock_addition() //If lock construction is successful we don't care what access the electronics had, so we override it
	if(..())
		req_access = list(ACCESS_ALL_PERSONAL_LOCKERS)
		lockerelectronics.accesses = req_access

/obj/structure/closet/secure_closet/personal/handle_lock_removal()
	if(..())
		registered_name = null
