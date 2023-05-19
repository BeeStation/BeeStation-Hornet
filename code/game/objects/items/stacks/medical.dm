/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	amount = 6
	max_amount = 6
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	///How much brute does it heal?
	var/heal_brute = 0
	///How much burn does it heal?
	var/heal_burn = 0
	///For how long does it stop bleeding?
	var/stop_bleeding = 0
	///How long does it take to apply on yourself?
	var/self_delay = 2 SECONDS

/obj/item/stack/medical/attack(mob/living/M, mob/user)
	if(!M || !user || (isliving(M) && !M.can_inject(user, TRUE))) //If no mob, user and if we can't inject the mob just return
		return

	if(M.stat == DEAD && !stop_bleeding)
		to_chat(user, "<span class='danger'>\The [M] is dead, you cannot help [M.p_them()]!</span>")
		return

	if(!iscarbon(M) && !isanimal(M))
		to_chat(user, "<span class='danger'>You don't know how to apply \the [src] to [M]!</span>")
		return

	if(isanimal(M))
		var/mob/living/simple_animal/critter = M
		if(!(critter.healable) || stop_bleeding)
			to_chat(user, "<span class='notice'>You cannot use [src] on [M]!</span>")
			return
		if(critter.health == critter.maxHealth)
			to_chat(user, "<span class='notice'>[M] is at full health.</span>")
			return
		if(heal_brute < DAMAGE_PRECISION)
			to_chat(user, "<span class='notice'>[src] won't help [M] at all.</span>")
			return
		M.heal_bodypart_damage((heal_brute * 0.5), (heal_burn * 0.5)) //half as effective on animals, since it's not made for them
		user.visible_message("<span class='green'>[user] applies [src] on [M].</span>", "<span class='green'>You apply [src] on [M].</span>")
		use(1)
		return

	var/obj/item/bodypart/affecting
	var/mob/living/carbon/C = M
	affecting = C.get_bodypart(check_zone(user.zone_selected))

	if(M in user.do_afters) //One at a time, please.
		return

	if(!affecting) //Missing limb?
		to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
		return

	if(ishuman(C)) //apparently only humans bleed? funky.
		var/mob/living/carbon/human/H = C
		if(stop_bleeding)
			if(!H.bleed_rate)
				to_chat(user, "<span class='warning'>[H] isn't bleeding!</span>")
				return
			if(H.bleedsuppress) //so you can't stack bleed suppression
				to_chat(user, "<span class='warning'>[H]'s bleeding is already bandaged!</span>")
				return
			H.suppress_bloodloss(stop_bleeding)

	if(!IS_ORGANIC_LIMB(affecting))
		to_chat(user, "<span class='warning'>Medicine won't work on a robotic limb!</span>")
		return

	if(!(affecting.brute_dam || affecting.burn_dam))
		to_chat(user, "<span class='warning'>[M]'s [parse_zone(user.zone_selected)] isn't hurt!</span>")
		return

	if((affecting.brute_dam && !affecting.burn_dam && !heal_brute) || (affecting.burn_dam && !affecting.brute_dam && !heal_burn)) //suffer
		to_chat(user, "<span class='warning'>This type of medicine isn't appropriate for this type of wound.</span>")
		return

	if(C == user)
		user.visible_message("<span class='notice'>[user] starts to apply [src] on [user.p_them()]self...</span>", "<span class='notice'>You begin applying [src] on yourself...</span>")
		if(!do_after(user, self_delay, M))
			return

	user.visible_message("<span class='green'>[user] applies [src] on [M].</span>", "<span class='green'>You apply [src] on [M].</span>")

	if(affecting.heal_damage(heal_brute, heal_burn) || stop_bleeding)
		C.update_damage_overlays()
		use(1)

/obj/item/stack/medical/bruise_pack
	name = "bruise pack"
	singular_name = "bruise pack"
	desc = "A therapeutic gel pack and bandages designed to treat blunt-force trauma."
	icon_state = "brutepack"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_brute = 40
	grind_results = list(/datum/reagent/medicine/styptic_powder = 40)

/obj/item/stack/medical/bruise_pack/one
	amount = 1

/obj/item/stack/medical/bruise_pack/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is bludgeoning [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burn wounds."
	icon_state = "ointment"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_burn = 40
	grind_results = list(/datum/reagent/medicine/silver_sulfadiazine = 40)

/obj/item/stack/medical/ointment/one
	amount = 1

/obj/item/stack/medical/ointment/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is squeezing \the [src] into [user.p_their()] mouth! Don't [user.p_they()] know that stuff is toxic?</span>")
	return TOXLOSS

/obj/item/stack/medical/gauze
	name = "medical gauze"
	desc = "A roll of elastic cloth that is extremely effective at stopping bleeding, heals minor bruising."
	icon_state = "gauze"
	stop_bleeding = 1800
	heal_brute = 5 //Reminder that you can not stack healing thus you wait out the 1800 timer.
	max_amount = 12

/obj/item/stack/medical/gauze/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER || I.is_sharp())
		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two gauzes to do this!</span>")
			return
		new /obj/item/stack/sheet/cotton/cloth(user.drop_location())
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
	heal_brute = 0

/obj/item/stack/medical/gauze/adv
	name = "sterilized medical gauze"
	desc = "A roll of elastic sterilized cloth that is extremely effective at stopping bleeding, heals minor wounds and cleans them."
	singular_name = "sterilized medical gauze"
	self_delay = 0.5 SECONDS

/obj/item/stack/medical/gauze/adv/one
	amount = 1

/obj/item/stack/medical/gauze/cyborg
	materials = list()
	is_cyborg = TRUE
	cost = 250
