/*
Slimecrossing Items
	General items added by the slimecrossing system.
	Collected here for clarity.
*/

//Timefreeze camera - Old Burning Sepia result. Kept in case admins want to spawn it
/obj/item/camera/timefreeze
	name = "sepia-tinted camera"
	desc = "They say a picture is like a moment stopped in time."
	pictures_left = 1
	pictures_max = 1
	var/used = FALSE

/obj/item/camera/timefreeze/afterattack(atom/target, mob/user, flag)
	if(!on || !pictures_left || !isturf(target.loc))
		return
	if(!used) //refilling the film does not refill the timestop
		new /obj/effect/timestop(get_turf(target), 2, 50, list(user))
		used = TRUE
		desc = "This camera has seen better days."
	. = ..()


//Hypercharged slime cell - Charged Yellow
/obj/item/stock_parts/cell/high/slime/hypercharged
	name = "hypercharged slime core"
	desc = "A charged yellow slime extract, infused with even more plasma. It almost hurts to touch."
	rating = 7 //Roughly 1.5 times the original.
	maxcharge = 10000 //5 times the normal one.
	chargerate = 300 //3 times the normal one.

//Barrier cube - Chilling Grey
/obj/item/barriercube
	name = "barrier cube"
	desc = "A compressed cube of slime. When squeezed, it grows to massive size!"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "barriercube"
	w_class = WEIGHT_CLASS_TINY

/obj/item/barriercube/attack_self(mob/user)
	if(locate(/obj/structure/barricade/slime) in get_turf(loc))
		to_chat(user, span_warning("You can't fit more than one barrier in the same space!"))
		return
	to_chat(user, span_notice("You squeeze [src]."))
	var/obj/B = new /obj/structure/barricade/slime(get_turf(loc))
	B.visible_message(span_warning("[src] suddenly grows into a large, gelatinous barrier!"))
	qdel(src)

//Slime barricade - Chilling Grey
/obj/structure/barricade/slime
	name = "gelatinous barrier"
	desc = "A huge chunk of grey slime. Bullets might get stuck in it."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slimebarrier"
	proj_pass_rate = 40
	max_integrity = 60

//Melting Gel Wall - Chilling Metal
/obj/effect/forcefield/slimewall
	name = "solidified gel"
	desc = "A mass of solidified slime gel - completely impenetrable, but it's melting away!"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "slimebarrier_thick"
	can_atmos_pass = ATMOS_PASS_NO
	opacity = TRUE
	initial_duration = 10 SECONDS

//Rainbow barrier - Chilling Rainbow
/obj/effect/forcefield/slimewall/rainbow
	name = "rainbow barrier"
	desc = "Despite others' urgings, you probably shouldn't taste this."
	icon_state = "rainbowbarrier"

//Ice stasis block - Chilling Dark Blue
/obj/structure/ice_stasis
	name = "ice block"
	desc = "A massive block of ice. You can see something vaguely humanoid inside."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "frozen"
	density = TRUE
	max_integrity = 100

/obj/structure/ice_stasis/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/magic/ethereal_exit.ogg', 50, 1)

/obj/structure/ice_stasis/Destroy()
	for(var/atom/movable/M in contents)
		M.forceMove(loc)
	playsound(src, 'sound/effects/glassbr3.ogg', 50, 1)
	return ..()

//Gold capture device - Chilling Gold
/obj/item/capturedevice
	name = "gold capture device"
	desc = "Bluespace technology packed into a roughly egg-shaped device, used to store nonhuman creatures. Can't catch them all, though - it only fits one."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "capturedevice"

/obj/item/capturedevice/attack(mob/living/M, mob/user)
	if(length(contents))
		to_chat(user, span_warning("The device already has something inside."))
		return
	if(!isanimal_or_basicmob(M))
		to_chat(user, span_warning("The capture device only works on simple creatures."))
		return
	if(M.mind)
		INVOKE_ASYNC(src, PROC_REF(offer_entry), M, user)
	else if(!(FACTION_NEUTRAL in M.faction))
		to_chat(user, span_warning("This creature is too aggressive to capture."))
		return
	to_chat(user, span_notice("You store [M] in the capture device."))
	store(M)

/obj/item/capturedevice/proc/offer_entry(mob/living/M, mob/user)
	to_chat(user, span_notice("You offer the device to [M]."))
	if(alert(M, "Would you like to enter [user]'s capture device?", "Gold Capture Device", "Yes", "No") != "Yes")
		to_chat(user, span_warning("[M] refused to enter the device."))
		return
	if(!user.canUseTopic(src, BE_CLOSE) || !user.canUseTopic(M, BE_CLOSE))
		to_chat(user, span_warning("You were too far away from [M]."))
		to_chat(M, span_warning("You were too far away from [user]."))
		return

	to_chat(user, span_notice("You store [M] in the capture device."))
	to_chat(M, span_notice("The world warps around you, and you're suddenly in an endless void, with a window to the outside floating in front of you."))
	store(M, user)

/obj/item/capturedevice/attack_self(mob/user)
	if(contents.len)
		to_chat(user, span_notice("You open the capture device!"))
		release()
	else
		to_chat(user, span_warning("The device is empty..."))

/obj/item/capturedevice/proc/store(var/mob/living/M)
	M.forceMove(src)

/obj/item/capturedevice/proc/release()
	for(var/atom/movable/M in contents)
		M.forceMove(get_turf(loc))

/obj/item/cerulean_slime_crystal
	name = "Cerulean slime poly-crystal"
	desc = "Translucent and irregular, it can duplicate matter on a whim"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "cerulean_item_crystal"
	var/amt = 0

/obj/item/cerulean_slime_crystal/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!istype(target,/obj/item/stack) || !istype(user,/mob/living/carbon) || !proximity_flag)
		return
	var/obj/item/stack/stack_item = target

	if(istype(stack_item,/obj/item/stack/sheet/telecrystal))
		to_chat(user,span_notice("The crystal disappears!"))
		qdel(src)
		return

	stack_item.add(amt)

	qdel(src)
