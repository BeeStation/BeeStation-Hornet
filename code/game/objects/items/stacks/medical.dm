/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/stack_objects.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	var/heal_brute = 0
	var/heal_burn = 0
	var/stop_bleeding = 0
	var/self_delay = 50
	var/other_delay = 0
	var/repeating = FALSE

/obj/item/stack/medical/attack(mob/living/M, mob/user)
	. = ..()
	try_heal(M, user)


/obj/item/stack/medical/proc/try_heal(mob/living/M, mob/user, silent = FALSE)
	if(!M.can_inject(user, TRUE))
		return
	if(M == user)
		if(!silent)
			user.visible_message("<span class='notice'>[user] starts to apply \the [src] on [user.p_them()]self...</span>", "<span class='notice'>You begin applying \the [src] on yourself...</span>")
		if(!do_mob(user, M, self_delay, extra_checks=CALLBACK(M, /mob/living/proc/can_inject, user, TRUE)))
			return
	else if(other_delay)
		if(!silent)
			user.visible_message("<span class='notice'>[user] starts to apply \the [src] on [M].</span>", "<span class='notice'>You begin applying \the [src] on [M]...</span>")
		if(!do_mob(user, M, other_delay, extra_checks=CALLBACK(M, /mob/living/proc/can_inject, user, TRUE)))
			return

	if(heal(M, user))
		log_combat(user, M, "healed", src.name)
		use(1)
		if(repeating && amount > 0)
			try_heal(M, user, TRUE)

/obj/item/stack/medical/proc/heal(mob/living/M, mob/user)
	return

	if(user)
		if (M != user)
			if (isanimal(M))
				var/mob/living/simple_animal/critter = M
				if (!(critter.healable))
					to_chat(user, "<span class='notice'> You cannot use [src] on [M]!</span>")
					return
				else if (critter.health == critter.maxHealth)
					to_chat(user, "<span class='notice'> [M] is at full health.</span>")
					return
				else if(src.heal_brute < 1)
					to_chat(user, "<span class='notice'> [src] won't help [M] at all.</span>")
					return
			user.visible_message("<span class='green'>[user] applies [src] on [M].</span>", "<span class='green'>You apply [src] on [M].</span>")
		else
			var/t_himself = "itself"
			if(user.gender == MALE)
				t_himself = "himself"
			else if(user.gender == FEMALE)
				t_himself = "herself"
			user.visible_message("<span class='notice'>[user] starts to apply [src] on [t_himself]...</span>", "<span class='notice'>You begin applying [src] on yourself...</span>")
			if(!do_mob(user, M, self_delay, extra_checks=CALLBACK(M, /mob/living/proc/can_inject, user, TRUE)))
				return
			user.visible_message("<span class='green'>[user] applies [src] on [t_himself].</span>", "<span class='green'>You apply [src] on yourself.</span>")


	if(iscarbon(M))
		var/mob/living/carbon/C = M
		affecting = C.get_bodypart(check_zone(user.zone_selected))
		if(!affecting) //Missing limb?
			to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
			return
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(stop_bleeding)
				if(!H.bleedsuppress) //so you can't stack bleed suppression
					H.suppress_bloodloss(stop_bleeding)
		if(affecting.status == BODYPART_ORGANIC) //Limb must be organic to be healed - RR
			if(affecting.heal_damage(heal_brute, heal_burn))
				C.update_damage_overlays()
		else
			to_chat(user, "<span class='notice'>Medicine won't work on a robotic limb!</span>")
	else
		M.heal_bodypart_damage((src.heal_brute/2), (src.heal_burn/2))

	use(1)



/obj/item/stack/medical/bruise_pack
	name = "bruise pack"
	singular_name = "bruise pack"
	desc = "A therapeutic gel pack and bandages designed to treat blunt-force trauma."
	icon_state = "brutepack"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_brute = 40
	self_delay = 20
	grind_results = list(/datum/reagent/medicine/styptic_powder = 10)

/obj/item/stack/medical/bruise_pack/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is bludgeoning [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/stack/medical/gauze
	name = "medical gauze"
	desc = "A roll of elastic cloth that is extremely effective at stopping bleeding, but does not heal wounds."
	gender = PLURAL
	singular_name = "medical gauze"
	icon_state = "gauze"
	stop_bleeding = 1800
	self_delay = 20
	max_amount = 12
	grind_results = list(/datum/reagent/cellulose = 2)


/obj/item/stack/medical/gauze/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER || I.is_sharp())
		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two gauzes to do this!</span>")
			return
		new /obj/item/stack/sheet/cloth(user.drop_location())
		user.visible_message("[user] cuts [src] into pieces of cloth with [I].", \
					 "<span class='notice'>You cut [src] into pieces of cloth with [I].</span>", \
					 "<span class='italics'>You hear cutting.</span>")
		use(2)
	else
		return ..()

/obj/item/stack/medical/gauze/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins tightening \the [src] around [user.p_their()] neck! It looks like [user.p_they()] forgot how to use medical supplies!</span>")
	return OXYLOSS

/obj/item/stack/medical/gauze/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = "A roll of cloth roughly cut from something that can stop bleeding, but does not heal wounds."
	stop_bleeding = 900

/obj/item/stack/medical/gauze/cyborg
	materials = list()
	is_cyborg = 1
	cost = 250

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burn wounds."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_burn = 40
	self_delay = 20
	grind_results = list(/datum/reagent/medicine/silver_sulfadiazine = 10)

/obj/item/stack/medical/ointment/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is squeezing \the [src] into [user.p_their()] mouth! [user.p_do(TRUE)]n't [user.p_they()] know that stuff is toxic?</span>")
	return TOXLOSS

/obj/item/stack/medical/suture
	name = "suture"
	desc = "Sterile sutures used to seal up cuts and lacerations."
	gender = PLURAL
	singular_name = "suture"
	icon_state = "suture"
	self_delay = 30
	other_delay = 10
	amount = 15
	max_amount = 15
	repeating = TRUE
	var/heal_brute = 10
	grind_results = list(/datum/reagent/medicine/spaceacillin = 2)

/obj/item/stack/medical/suture/medicated
	name = "medicated suture"
	icon_state = "suture_purp"
	desc = "A suture infused with drugs that speed up wound healing of the treated laceration."
	heal_brute = 15
	grind_results = list(/datum/reagent/medicine/polypyr = 2)

/obj/item/stack/medical/suture/heal(mob/living/M, mob/user)
	. = ..()
	if(M.stat == DEAD)
		to_chat(user, "<span class='warning'>[M] is dead! You can not help [M.p_them()].</span>")
		return
	if(iscarbon(M))
		return heal_carbon(M, user, heal_brute, 0)
	if(isanimal(M))
		var/mob/living/simple_animal/critter = M
		if (!(critter.healable))
			to_chat(user, "<span class='warning'>You cannot use \the [src] on [M]!</span>")
			return FALSE
		else if (critter.health == critter.maxHealth)
			to_chat(user, "<span class='notice'>[M] is at full health.</span>")
			return FALSE
		user.visible_message("<span class='green'>[user] applies \the [src] on [M].</span>", "<span class='green'>You apply \the [src] on [M].</span>")
		M.heal_bodypart_damage(heal_brute)
		return TRUE

	to_chat(user, "<span class='warning'>You can't heal [M] with the \the [src]!</span>")

/obj/item/stack/medical/mesh
	name = "regenerative mesh"
	desc = "A bacteriostatic mesh used to dress burns."
	gender = PLURAL
	singular_name = "regenerative mesh"
	icon_state = "regen_mesh"
	self_delay = 30
	other_delay = 10
	amount = 15
	max_amount = 15
	repeating = TRUE
	var/heal_burn = 10
	var/is_open = TRUE ///This var determines if the sterile packaging of the mesh has been opened.
	grind_results = list(/datum/reagent/medicine/spaceacillin = 2)

/obj/item/stack/medical/mesh/Initialize()
	..()
	if(amount == max_amount)	 //only seal full mesh packs
		is_open = FALSE
		icon_state = "regen_mesh_closed"


/obj/item/stack/medical/mesh/update_icon()
	if(!is_open)
		return
	. = ..()

/obj/item/stack/medical/mesh/heal(mob/living/M, mob/user)
	. = ..()
	if(M.stat == DEAD)
		to_chat(user, "<span class='warning'>[M] is dead! You can not help [M.p_them()].</span>")
		return
	if(iscarbon(M))
		return heal_carbon(M, user, 0, heal_burn)
	to_chat(user, "<span class='warning'>You can't heal [M] with the \the [src]!</span>")


/obj/item/stack/medical/mesh/try_heal(mob/living/M, mob/user, silent = FALSE)
	if(!is_open)
		to_chat(user, "<span class='warning'>You need to open [src] first.</span>")
		return
	. = ..()

/obj/item/stack/medical/mesh/AltClick(mob/living/user)
	if(!is_open)
		to_chat(user, "<span class='warning'>You need to open [src] first.</span>")
		return
	. = ..()

/obj/item/stack/medical/mesh/attack_hand(mob/user)
	if(!is_open & user.get_inactive_held_item() == src)
		to_chat(user, "<span class='warning'>You need to open [src] first.</span>")
		return
	. = ..()

/obj/item/stack/medical/mesh/attack_self(mob/user)
	if(!is_open)
		is_open = TRUE
		to_chat(user, "<span class='notice'>You open the sterile mesh package.</span>")
		update_icon()
		playsound(src, 'sound/items/poster_ripped.ogg', 20, TRUE)
	. = ..()

	/*
	The idea is for these medical devices to work like a hybrid of the old brute packs and tend wounds,
	they heal a little at a time, have reduced healing density and does not allow for rapid healing while in combat.
	However they provice graunular control of where the healing is directed, this makes them better for curing work-related cuts and scrapes.

	The interesting limb targeting mechanic is retained and i still believe they will be a viable choice, especially when healing others in the field.
	 */

