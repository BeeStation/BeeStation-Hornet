/obj/item/holosign_creator
	name = "holographic sign projector"
	desc = "A handy-dandy holographic projector that displays a janitorial sign."
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	item_flags = NOBLUDGEON
	var/sign_name = "sign"
	var/list/signs = list()
	var/max_signs = 10
	var/creation_time = 0 //time to create a holosign in deciseconds.
	var/holosign_type = /obj/structure/holosign/wetsign
	var/holocreator_busy = FALSE //to prevent placing multiple holo barriers at once
	var/ranged = FALSE

/obj/item/holosign_creator/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/holosign_creator/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	afterattack(target, user, proximity_flag)

/obj/item/holosign_creator/afterattack(atom/target, mob/user, flag)
	. = ..()
	if(flag || ranged)
		if(!check_allowed_items(target, 1))
			return
		var/turf/T = get_turf(target)
		var/obj/structure/holosign/H = locate(holosign_type) in T
		if(H)
			to_chat(user, "<span class='notice'>You use [src] to deactivate [H].</span>")
			qdel(H)
		else
			if(!T.is_blocked_turf(TRUE)) //can't put holograms on a tile that has dense stuff
				if(holocreator_busy)
					to_chat(user, "<span class='notice'>[src] is busy creating a hologram.</span>")
					return
				if(length(signs) < max_signs)
					playsound(src.loc, 'sound/machines/click.ogg', 20, 1)
					if(creation_time)
						holocreator_busy = TRUE
						if(!do_after(user, creation_time, target = target))
							holocreator_busy = FALSE
							return
						holocreator_busy = FALSE
						if(length(signs) >= max_signs)
							return
						if(T.is_blocked_turf(TRUE)) //don't try to sneak dense stuff on our tile during the wait.
							return
					H = new holosign_type(get_turf(target), src)
					if(length(signs) == max_signs)
						to_chat(user, "<span class='notice'>You create \a [H] with [src]. It cannot project any more [sign_name]\s!</span>")
					else
						to_chat(user, "<span class='notice'>You create \a [H] with [src]. It can project [max_signs - length(signs)] more [sign_name]\s.</span>")
				else
					to_chat(user, "<span class='notice'>[src] is projecting at max capacity!</span>")

/obj/item/holosign_creator/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/holosign_creator/attack_self(mob/user)
	if(length(signs))
		var/signs_amount = length(signs)
		for(var/H in signs)
			qdel(H)
		to_chat(user, "<span class='notice'>You clear [signs_amount] active [sign_name]\s.</span>")

/obj/item/holosign_creator/examine(mob/user)
	. = ..()
	. += "It has a maximum capacity of [max_signs] [sign_name]\s"
	if(!length(signs))
		. += "It is currently not projecting any [sign_name]\s."
		return
	if(length(signs) < max_signs)
		. += "It is currently projecting [length(signs)] [sign_name]\s."
		return
	if(length(signs) == max_signs)
		. += "It is currently projecting at maximum capacity!"

/obj/item/holosign_creator/janibarrier
	name = "custodial holobarrier projector"
	desc = "A holographic projector that creates hard light wet floor barriers."
	holosign_type = /obj/structure/holosign/barrier/wetsign
	sign_name = "holobarrier"
	custom_price = 200
	creation_time = 20
	max_signs = 12

/obj/item/holosign_creator/security
	name = "security holobarrier projector"
	desc = "A holographic projector that creates holographic security barriers."
	icon_state = "signmaker_sec"
	holosign_type = /obj/structure/holosign/barrier
	sign_name = "holobarrier"
	creation_time = 30
	max_signs = 6

/obj/item/holosign_creator/engineering
	name = "engineering holobarrier projector"
	desc = "A holographic projector that creates holographic engineering barriers."
	icon_state = "signmaker_engi"
	holosign_type = /obj/structure/holosign/barrier/engineering
	sign_name = "holobarrier"
	creation_time = 30
	max_signs = 6

/obj/item/holosign_creator/atmos
	name = "\improper ATMOS holofan projector"
	desc = "A holographic projector that creates holographic barriers that prevent changes in atmosphere conditions."
	icon_state = "signmaker_atmos"
	holosign_type = /obj/structure/holosign/barrier/atmos
	sign_name = "holofan"
	creation_time = 0
	max_signs = 6

/obj/item/holosign_creator/medical
	name = "\improper PENLITE barrier projector"
	desc = "A holographic projector that creates PENLITE holobarriers. Useful during quarantines since they halt those with malicious diseases."
	icon_state = "signmaker_med"
	holosign_type = /obj/structure/holosign/barrier/medical
	sign_name = "holobarrier"
	creation_time = 30
	max_signs = 3

/obj/item/holosign_creator/cyborg
	name = "energy barrier projector"
	desc = "A holographic projector that creates fragile energy fields."
	creation_time = 15
	max_signs = 9
	holosign_type = /obj/structure/holosign/barrier/cyborg
	sign_name = "barrier"
	var/shock = 0

/obj/item/holosign_creator/cyborg/attack_self(mob/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user

		if(shock)
			to_chat(user, "<span class='notice'>You clear all active energy fields, and reset your projector to normal.</span>")
			holosign_type = /obj/structure/holosign/barrier/cyborg
			creation_time = 5
			if(length(signs))
				for(var/H in signs)
					qdel(H)
			shock = 0
			return
		else if(R.emagged&&!shock)
			to_chat(user, "<span class='warning'>You clear all active energy fields, and overload your energy projector!</span>")
			holosign_type = /obj/structure/holosign/barrier/cyborg/hacked
			creation_time = 30
			if(length(signs))
				for(var/H in signs)
					qdel(H)
			shock = 1
			return
		else
			if(length(signs))
				var/signs_amount = length(signs)
				for(var/H in signs)
					qdel(H)
				to_chat(user, "<span class='notice'>You clear [signs_amount] active energy field\s.</span>")
	if(length(signs))
		var/signs_amount = length(signs)
		for(var/H in signs)
			qdel(H)
		to_chat(user, "<span class='notice'>You clear [signs_amount] active energy field\s.</span>")
