/*
Slimecrossing Items
	General items added by the slimecrossing system.
	Collected here for clarity.
*/

//Rewind camera - I'm already Burning Sepia
/obj/item/camera/rewind
	name = "sepia-tinted camera"
	desc = "They say a picture is like a moment stopped in time."
	pictures_left = 1
	pictures_max = 1
	can_customise = FALSE
	default_picture_name = "A nostalgic picture"

/datum/saved_bodypart
	var/obj/item/bodypart/old_part
	var/bodypart_type
	var/brute_dam
	var/burn_dam

/datum/saved_bodypart/New(obj/item/bodypart/part)
	old_part = part
	bodypart_type = part.type
	brute_dam = part.brute_dam
	burn_dam = part.burn_dam

/mob/living/carbon/proc/apply_saved_bodyparts(list/datum/saved_bodypart/parts)
	var/list/dont_chop = list()
	for(var/zone in parts)
		var/datum/saved_bodypart/saved_part = parts[zone]
		var/obj/item/bodypart/already = get_bodypart(zone)
		if(QDELETED(saved_part.old_part))
			saved_part.old_part = new saved_part.bodypart_type
		if(!already || already != saved_part.old_part)
			saved_part.old_part.replace_limb(src, TRUE)
		saved_part.old_part.heal_damage(INFINITY, INFINITY, null, FALSE)
		saved_part.old_part.receive_damage(saved_part.brute_dam, saved_part.burn_dam, wound_bonus=CANT_WOUND)
		dont_chop[zone] = TRUE
	for(var/_part in bodyparts)
		var/obj/item/bodypart/part = _part
		if(dont_chop[part.body_zone])
			continue
		part.drop_limb(TRUE)

/mob/living/carbon/proc/save_bodyparts()
	var/list/datum/saved_bodypart/ret = list()
	for(var/_part in bodyparts)
		var/obj/item/bodypart/part = _part
		var/datum/saved_bodypart/saved_part = new(part)

		ret[part.body_zone] = saved_part
	return ret

/obj/item/camera/rewind/afterattack(atom/target, mob/user, flag)
	. |= AFTERATTACK_PROCESSED_ITEM

	if(!on || !pictures_left || !isturf(target.loc))
		return .

	if(user == target)
		to_chat(user, "<span class = 'notice'>You take a selfie!</span>")
	else
		to_chat(user, "<span class = 'notice'>You take a photo with [target]!</span>")
		to_chat(target, "<span class = 'notice'>[user] takes a photo with you!</span>")
	to_chat(target, span_boldnotice("You'll remember this moment forever!"))

	target.AddComponent(/datum/component/dejavu, 2)
	return . | ..()



//Timefreeze camera - Old Burning Sepia result. Kept in case admins want to spawn it
/obj/item/camera/timefreeze
	name = "sepia-tinted camera"
	desc = "They say a picture is like a moment stopped in time."
	pictures_left = 1
	pictures_max = 1

/obj/item/camera/timefreeze/afterattack(atom/target, mob/user, flag)
	. |= AFTERATTACK_PROCESSED_ITEM

	if(!on || !pictures_left || !isturf(target.loc))
		return .
	new /obj/effect/timestop(get_turf(target), 2, 50, list(user))
	return . | ..()

//Hypercharged slime cell - Charged Yellow
/obj/item/stock_parts/cell/emproof/slime/hypercharged // monke edit: make hypercharged slime cells EMP-proof, by changing their parent from cell/high to cell/emproof
	name = "hypercharged slime core"
	desc = "A charged yellow slime extract, infused with plasma. It almost hurts to touch. Its organic nature makes it immune to EMPs."
	rating = 7
	maxcharge = 50000
	chargerate = 2500

//Barrier cube - Chilling Grey
/obj/item/barriercube
	name = "barrier cube"
	desc = "A compressed cube of slime. When squeezed, it grows to massive size!"
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "barriercube"
	w_class = WEIGHT_CLASS_TINY

/obj/item/barriercube/attack_self(mob/user)
	if(locate(/obj/structure/barricade/slime) in get_turf(loc))
		to_chat(user, "<span class = 'warning'>You can't fit more than one barrier in the same space!</span>")
		return
	to_chat(user, "<span class = 'notice'>You squeeze [src].</span>")
	var/obj/B = new /obj/structure/barricade/slime(get_turf(loc))
	B.visible_message("<span class = 'warning'>[src] suddenly grows into a large, gelatinous barrier!</span>")
	qdel(src)

//Slime barricade - Chilling Grey
/obj/structure/barricade/slime
	name = "gelatinous barrier"
	desc = "A huge chunk of grey slime. Bullets might get stuck in it."
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "slimebarrier"
	proj_pass_rate = 40
	max_integrity = 60

//Melting Gel Wall - Chilling Metal
/obj/effect/forcefield/slimewall
	name = "solidified gel"
	desc = "A mass of solidified slime gel - completely impenetrable, but it's melting away!"
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
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
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "frozen"
	density = TRUE
	max_integrity = 100
	armor_type = /datum/armor/structure_ice_stasis

/datum/armor/structure_ice_stasis
	melee = 30
	bullet = 50
	laser = -50
	energy = -50
	fire = -80
	acid = 30

/obj/structure/ice_stasis/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/magic/ethereal_exit.ogg', 50, TRUE)

/obj/structure/ice_stasis/Destroy()
	for(var/atom/movable/M in contents)
		M.forceMove(loc)
	playsound(src, 'sound/effects/glassbr3.ogg', 50, TRUE)
	return ..()

//Gold capture device - Chilling Gold
/obj/item/capturedevice
	name = "gold capture device"
	desc = "Bluespace technology packed into a roughly egg-shaped device, used to store nonhuman creatures. Can't catch them all, though - it only fits one."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/xenobiology/slimecrossing.dmi'
	icon_state = "capturedevice"

/obj/item/capturedevice/attack(mob/living/pokemon, mob/user)
	if(length(contents))
		to_chat(user, "<span class = 'warning'>The device already has something inside.</span>")
		return
	if(!isanimal_or_basicmob(pokemon))
		to_chat(user, "<span class = 'warning'>The capture device only works on simple creatures.</span>")
		return
	if(pokemon.mind)
		to_chat(user, "<span class = 'notice'>You offer the device to [pokemon].</span>")
		if(tgui_alert(pokemon, "Would you like to enter [user]'s capture device?", "Gold Capture Device", list("Yes", "No")) == "Yes")
			if(user.can_perform_action(src) && user.can_perform_action(pokemon))
				to_chat(user, "<span class = 'notice'>You store [pokemon] in the capture device.</span>")
				to_chat(pokemon, "<span class = 'notice'>The world warps around you, and you're suddenly in an endless void, with a window to the outside floating in front of you.</span>")
				store(pokemon, user)
			else
				to_chat(user, "<span class = 'warning'>You were too far away from [pokemon].</span>")
				to_chat(pokemon, "<span class = 'warning'>You were too far away from [user].</span>")
		else
			to_chat(user, "<span class = 'warning'>[pokemon] refused to enter the device.</span>")
			return
	else if(!(FACTION_NEUTRAL in pokemon.faction))
		to_chat(user, "<span class = 'warning'>This creature is too aggressive to capture.</span>")
		return
	to_chat(user, "<span class = 'notice'>You store [pokemon] in the capture device.</span>")
	store(pokemon)

/obj/item/capturedevice/attack_self(mob/user)
	if(contents.len)
		to_chat(user, "<span class = 'notice'>You open the capture device!</span>")
		release()
	else
		to_chat(user, "<span class = 'warning'>The device is empty...</span>")

/obj/item/capturedevice/proc/store(mob/living/M)
	M.forceMove(src)

/obj/item/capturedevice/proc/release()
	for(var/atom/movable/M in contents)
		M.forceMove(get_turf(loc))
