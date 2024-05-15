#define REAGENT_AMOUNT_PER_ITEM 20 //The amount of reagents medical items contain, for both application and grinding purposes.

/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'icons/obj/stacks/miscellaneous.dmi'
	amount = 12
	max_amount = 12
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	item_flags = NOBLUDGEON
	cost = 250
	source = /datum/robot_energy_storage/medical
	///What reagent does it apply?
	var/list/reagent
	///Is this for bruises?
	var/heal_brute = FALSE
	///Is this for burns?
	var/heal_burn = FALSE
	///For how long does it stop bleeding?
	var/stop_bleeding = 0
	///How long does it take to apply on yourself?
	var/self_delay = 2 SECONDS

/obj/item/stack/medical/Initialize(mapload, new_amount, merge, mob/user)
	. = ..()
	if(reagent)
		create_reagents(REAGENT_AMOUNT_PER_ITEM)
		reagents.add_reagent_list(reagent)

/obj/item/stack/medical/attack(mob/living/M, mob/user)
	if(!M || !user || (isliving(M) && !M.can_inject(user, TRUE))) //If no mob, user and if we can't inject the mob just return
		return

	if(M.stat == DEAD && !stop_bleeding)
		to_chat(user, "<span class='danger'>\The [M] is dead, you cannot help [M.p_them()]!</span>")
		return

	if(!iscarbon(M) && !isanimal(M))
		to_chat(user, "<span class='danger'>You don't know how to apply \the [src] to [M]!</span>")
		return

	if(M in user.do_afters) //One at a time, please.
		return

	if(isanimal(M))
		var/mob/living/simple_animal/critter = M
		if(!(critter.healable))
			to_chat(user, "<span class='notice'>You cannot use [src] on [M]!</span>")
			return
		if(critter.health == critter.maxHealth)
			to_chat(user, "<span class='notice'>[M] is at full health.</span>")
			return
		if(!heal_brute) //simplemobs can only take brute damage, and can only benefit from items intended to heal it
			to_chat(user, "<span class='notice'>[src] won't help [M] at all.</span>")
			return
		M.heal_bodypart_damage(REAGENT_AMOUNT_PER_ITEM)
		user.visible_message("<span class='green'>[user] applies [src] on [M].</span>", "<span class='green'>You apply [src] on [M].</span>")
		use(1)
		return

	var/datum/task/select_bodyzone_task = user.select_bodyzone(M, FALSE, BODYZONE_STYLE_MEDICAL)
	select_bodyzone_task.continue_with(CALLBACK(src, PROC_REF(do_application), M, user))

/obj/item/stack/medical/proc/do_application(mob/living/M, mob/user, zone_selected)
	if (!zone_selected)
		return
	if (!user.can_interact_with(M, TRUE))
		to_chat(user, "<span class='danger'>You cannot reach [M]!</span>")
		return
	if (!user.can_interact_with(src, TRUE))
		to_chat(user, "<span class='danger'>You cannot reach [src]!</span>")
		return
	if(M.stat == DEAD && !stop_bleeding)
		to_chat(user, "<span class='danger'>\The [M] is dead, you cannot help [M.p_them()]!</span>")
		return
	if(!iscarbon(M))
		to_chat(user, "<span class='danger'>You don't know how to apply \the [src] to [M]!</span>")
		return
	var/obj/item/bodypart/affecting
	var/mob/living/carbon/C = M
	affecting = C.get_bodypart(check_zone(zone_selected))

	if(M in user.do_afters) //One at a time, please.
		return

	if(!affecting) //Missing limb?
		to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(zone_selected)]!</span>")
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
		to_chat(user, "<span class='warning'>[M]'s [parse_zone(zone_selected)] isn't hurt!</span>")
		return

	if((affecting.brute_dam && !affecting.burn_dam && !heal_brute) || (affecting.burn_dam && !affecting.brute_dam && !heal_burn)) //suffer
		to_chat(user, "<span class='warning'>This type of medicine isn't appropriate for this type of wound.</span>")
		return

	if(C == user)
		user.visible_message("<span class='notice'>[user] starts to apply [src] on [user.p_them()]self...</span>", "<span class='notice'>You begin applying [src] on yourself...</span>")
		if(!do_after(user, self_delay, M))
			return
		//After the do_mob to ensure metabolites have had time to process at least one tick.
		if(reagent && (C.reagents.get_reagent_amount(/datum/reagent/metabolite/medicine/styptic_powder) || C.reagents.get_reagent_amount(/datum/reagent/metabolite/medicine/silver_sulfadiazine)))
			to_chat(user, "<span class='warning'>That stuff really hurt! You'll need to wait for the pain to go away before you can apply [src] to your wounds again, maybe someone else can help put it on for you.</span>")
			return

	user.visible_message("<span class='green'>[user] applies [src] on [M].</span>", "<span class='green'>You apply [src] on [M].</span>")
	if(reagent)
		reagents.reaction(M, PATCH, affecting = affecting)
		M.reagents.add_reagent_list(reagent) //Stack size is reduced by one instead of actually removing reagents from the stack.
		C.update_damage_overlays()
	use(1)

/obj/item/stack/medical/on_grind()
	reagents.clear_reagents() //By default grinding returns all contained reagents + grind_results, and for stackable items we only want grind_results
	. = ..()

/obj/item/stack/medical/bruise_pack
	name = "bruise pack"
	singular_name = "bruise pack"
	desc = "A therapeutic gel pack and bandages designed to treat blunt-force trauma."
	icon_state = "brutepack"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_brute = TRUE
	reagent = list(/datum/reagent/medicine/styptic_powder = REAGENT_AMOUNT_PER_ITEM)
	grind_results = list(/datum/reagent/medicine/styptic_powder = REAGENT_AMOUNT_PER_ITEM)

/obj/item/stack/medical/bruise_pack/one
	amount = 1

/obj/item/stack/medical/bruise_pack/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is bludgeoning [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Used to treat those nasty burn wounds."
	icon_state = "ointment"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_burn = TRUE
	reagent = list(/datum/reagent/medicine/silver_sulfadiazine = REAGENT_AMOUNT_PER_ITEM)
	grind_results = list(/datum/reagent/medicine/silver_sulfadiazine = REAGENT_AMOUNT_PER_ITEM)

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
	heal_brute = TRUE //Enables gauze to be used on simplemobs for healing
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
