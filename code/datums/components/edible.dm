/*!

This component makes it possible to make things edible. What this means is that you can take a bite or force someone to take a bite (in the case of items).
These items take a specific time to eat, and can do most of the things our original food items could.

Behavior that's still missing from this component that original food items had that should either be put into seperate components or somewhere else:
	Components:
	Drying component (jerky etc)
	Customizable component (custom pizzas etc)
	Processable component (Slicing and cooking behavior essentialy, making it go from item A to B when conditions are met.)
	Microwavability component
	Frying component

	Misc:
	Something for cakes (You can store things inside)

*/
/datum/component/edible
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///Amount of reagents taken per bite
	var/bite_consumption = 2
	///Amount of bites taken so far
	var/bitecount = 0
	///Flags for food
	var/food_flags = NONE
	///Bitfield of the types of this food
	var/foodtypes = NONE
	///Amount of seconds it takes to eat this food
	var/eat_time = 30
	///Defines how much it lowers someones satiety (Need to eat, essentialy)
	var/junkiness = 0
	///Message to send when eating
	var/list/eatverbs
	///Callback to be ran before you eat something, so you can check if someone *can* eat it.
	var/datum/callback/pre_eat
	///Callback to be ran before composting something, in case you don't want a piece of food to be compostable for some reason.
	var/datum/callback/on_compost
	///Callback to be ran for when you take a bite of something
	var/datum/callback/after_eat
	///Callback to be ran for when you finish eating something
	var/datum/callback/consume_callback
	///Last time we checked for food likes
	var/last_check_time
	///The initial reagents of this food when it is made
	var/list/initial_reagents
	///The initial volume of the foods reagents
	var/volume
	///The flavortext for taste
	var/list/tastes

/datum/component/edible/Initialize(list/initial_reagents,
								food_flags = NONE,
								foodtypes = NONE,
								volume = 50,
								eat_time = 10,
								list/tastes,
								list/eatverbs = list("bite","chew","nibble","gnaw","gobble","chomp"),
								bite_consumption = 2,
								junkiness,
								datum/callback/pre_eat,
								datum/callback/on_compost,
								datum/callback/after_eat,
								datum/callback/consume_callback)

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ANIMAL, PROC_REF(use_by_animal))
	RegisterSignal(parent, COMSIG_EDIBLE_ON_COMPOST, PROC_REF(compost))

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(use_from_hand))

		var/obj/item/item = parent
		if (!item.grind_results)
			item.grind_results = list() //If this doesn't already exist, add it as an empty list. This is needed for the grinder to accept it.

	src.bite_consumption = bite_consumption
	src.food_flags = food_flags
	src.foodtypes = foodtypes
	src.initial_reagents = initial_reagents
	src.tastes = tastes
	src.eat_time = eat_time
	src.eatverbs = eatverbs
	src.junkiness = junkiness
	src.pre_eat = pre_eat
	src.on_compost = on_compost
	src.after_eat = after_eat
	src.consume_callback = consume_callback

	var/atom/owner = parent

	owner.create_reagents(volume, INJECTABLE)

	for(var/rid in initial_reagents)
		var/amount = initial_reagents[rid]
		if(length(tastes) && (rid == /datum/reagent/consumable/nutriment || rid == /datum/reagent/consumable/nutriment/vitamin))
			owner.reagents.add_reagent(rid, amount, tastes.Copy())
		else
			owner.reagents.add_reagent(rid, amount)

/datum/component/edible/InheritComponent(datum/component/C,
	i_am_original,
	list/initial_reagents,
	food_flags = NONE,
	foodtypes = NONE,
	volume = 50,
	eat_time = 30,
	list/tastes,
	list/eatverbs = list("bite","chew","nibble","gnaw","gobble","chomp"),
	bite_consumption = 2,
	datum/callback/pre_eat,
	datum/callback/on_compost,
	datum/callback/after_eat,
	datum/callback/consume_callback
	)

	. = ..()
	src.bite_consumption = bite_consumption
	src.food_flags = food_flags
	src.foodtypes = foodtypes
	src.eat_time = eat_time
	src.eatverbs = eatverbs
	src.junkiness = junkiness
	src.pre_eat = pre_eat
	src.on_compost = on_compost
	src.after_eat = after_eat
	src.consume_callback = consume_callback

/datum/component/edible/Destroy(force, silent)
	QDEL_NULL(pre_eat)
	QDEL_NULL(on_compost)
	QDEL_NULL(after_eat)
	QDEL_NULL(consume_callback)
	return ..()

/datum/component/edible/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(!(food_flags & FOOD_IN_CONTAINER))
		switch (bitecount)
			if (0)
				return
			if(1)
				examine_list += "[parent] was bitten by someone!"
			if(2,3)
				examine_list += "[parent] was bitten [bitecount] times!"
			else
				examine_list += "[parent] was bitten multiple times!"

/datum/component/edible/proc/use_from_hand(obj/item/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER

	return TryToEat(M, user)


///Makes sure the thing hasn't been destroyed or fully eaten to prevent eating phantom edibles
/datum/component/edible/proc/is_food_gone(atom/owner, mob/living/feeder)
	if(QDELETED(owner)|| !(IS_EDIBLE(owner)))
		return TRUE
	if(owner.reagents.total_volume)
		return FALSE
	return TRUE

///All the checks for the act of eating itself and
/datum/component/edible/proc/TryToEat(mob/living/eater, mob/living/feeder)
	set waitfor = FALSE // We might end up sleeping here, so we don't want to hold up anything

	var/atom/owner = parent

	if(feeder.a_intent == INTENT_HARM)
		return

	if(is_food_gone(owner, feeder))
		return

	if(!can_consume(eater, feeder))
		return
	var/fullness = eater.nutrition + 10 //The theoretical fullness of the person eating if they were to eat this

	. = COMPONENT_CANCEL_ATTACK_CHAIN //Point of no return I suppose

	if(eater == feeder)//If you're eating it yourself.
		if(!do_after(feeder, eat_time, eater)) //Gotta pass the minimal eat time
			return
		if(is_food_gone(owner, feeder))
			return
		var/eatverb = pick(eatverbs)
		if(junkiness && eater.satiety < -150 && eater.nutrition > NUTRITION_LEVEL_STARVING + 50 && !HAS_TRAIT(eater, TRAIT_VORACIOUS))
			to_chat(eater, "<span class='warning'>You don't feel like eating any more junk food at the moment!</span>")
			return
		else if(fullness <= 50)
			eater.visible_message("<span class='notice'>[eater] hungrily [eatverb]s \the [parent], gobbling it down!</span>", "<span class='notice'>You hungrily [eatverb] \the [parent], gobbling it down!</span>")
		else if(fullness > 50 && fullness < 150)
			eater.visible_message("<span class='notice'>[eater] hungrily [eatverb]s \the [parent].</span>", "<span class='notice'>You hungrily [eatverb] \the [parent].</span>")
		else if(fullness > 150 && fullness < 500)
			eater.visible_message("<span class='notice'>[eater] [eatverb]s \the [parent].</span>", "<span class='notice'>You [eatverb] \the [parent].</span>")
		else if(fullness > 500 && fullness < 600)
			eater.visible_message("<span class='notice'>[eater] unwillingly [eatverb]s a bit of \the [parent].</span>", "<span class='notice'>You unwillingly [eatverb] a bit of \the [parent].</span>")
		else if(fullness > (600 * (1 + eater.overeatduration / 2000)))	// The more you eat - the more you can eat
			eater.visible_message("<span class='warning'>[eater] cannot force any more of \the [parent] to go down [eater.p_their()] throat!</span>", "<span class='warning'>You cannot force any more of \the [parent] to go down your throat!</span>")
			return
	else //If you're feeding it to someone else.
		if(isbrain(eater))
			to_chat(feeder, "<span class='warning'>[eater] doesn't seem to have a mouth!</span>")
			return
		if(fullness <= (600 * (1 + eater.overeatduration / 1000)))
			eater.visible_message("<span class='danger'>[feeder] attempts to feed [eater] [parent].</span>", \
									"<span class='userdanger'>[feeder] attempts to feed you [parent].</span>")
		else
			eater.visible_message("<span class='warning'>[feeder] cannot force any more of [parent] down [eater]'s throat!</span>", \
									"<span class='warning'>[feeder] cannot force any more of [parent] down your throat!</span>")
			return
		if(!do_after(feeder, target = eater)) //Wait 3 seconds before you can feed
			return
		if(is_food_gone(owner, feeder))
			return
		log_combat(feeder, eater, "fed", owner.reagents.log_list())
		eater.visible_message("<span class='danger'>[feeder] forces [eater] to eat [parent]!</span>", \
									"<span class='userdanger'>[feeder] forces you to eat [parent]!</span>")

	take_bite(eater, feeder)

	//If we're not force-feeding, try take another bite
	if(eater == feeder)
		INVOKE_ASYNC(src, PROC_REF(TryToEat), eater, feeder)


///This function lets the eater take a bite and transfers the reagents to the eater.
/datum/component/edible/proc/take_bite(mob/living/eater, mob/living/feeder)

	var/atom/owner = parent

	if(!owner?.reagents)
		return FALSE
	if(eater.satiety > -200)
		eater.satiety -= junkiness
	playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	if(owner.reagents.total_volume)
		SEND_SIGNAL(parent, COMSIG_FOOD_EATEN, eater, feeder, bitecount, bite_consumption)
		var/fraction = min(bite_consumption / owner.reagents.total_volume, 1)
		owner.reagents.trans_to(eater, bite_consumption, transfered_by = feeder, method = INGEST)
		bitecount++
		if(!owner.reagents.total_volume)
			on_consume(eater, feeder)
		check_liked(fraction, eater)

		//Invoke our after eat callback if it is valid
		if(after_eat)
			after_eat.Invoke(eater, feeder, bitecount)

		return TRUE

///Checks if we can compost something, and handles it
/datum/component/edible/proc/compost(mob/living/user)
	SIGNAL_HANDLER
	if(on_compost && !on_compost.Invoke(user))
		return COMPONENT_EDIBLE_BLOCK_COMPOST

///Checks whether or not the eater can actually consume the food
/datum/component/edible/proc/can_consume(mob/living/eater, mob/living/feeder)
	if(!iscarbon(eater))
		return FALSE
	if(pre_eat && !pre_eat.Invoke(eater, feeder))
		return FALSE
	var/mob/living/carbon/C = eater
	var/covered = ""
	if(C.is_mouth_covered(head_only = 1))
		covered = "headgear"
	else if(C.is_mouth_covered(mask_only = 1))
		covered = "mask"
	if(covered)
		var/who = (isnull(feeder) || eater == feeder) ? "your" : "[eater.p_their()]"
		to_chat(feeder, "<span class='warning'>You have to remove [who] [covered] first!</span>")
		return FALSE
	return TRUE

///Check foodtypes to see if we should send a moodlet
/datum/component/edible/proc/check_liked(fraction, mob/eater)
	if(last_check_time + 50 > world.time)
		return FALSE
	if(!ishuman(eater))
		return FALSE
	var/mob/living/carbon/human/human_eater = eater
	var/obj/item/organ/tongue/tongue = human_eater.getorganslot(ORGAN_SLOT_TONGUE)
	if((foodtypes & BREAKFAST) && world.time - SSticker.round_start_time < STOP_SERVING_BREAKFAST)
		SEND_SIGNAL(human_eater, COMSIG_ADD_MOOD_EVENT, "breakfast", /datum/mood_event/breakfast)
	if(HAS_TRAIT(human_eater, TRAIT_AGEUSIA))
		if(foodtypes & tongue.toxic_food)
			to_chat(human_eater, "<span class='warning'>You don't feel so good...</span>")
			human_eater.adjust_disgust(25 + 30 * fraction)
	else
		if(foodtypes & tongue.toxic_food)
			to_chat(human_eater,"<span class='warning'>What the hell was that thing?!</span>")
			human_eater.adjust_disgust(25 + 30 * fraction)
			SEND_SIGNAL(human_eater, COMSIG_ADD_MOOD_EVENT, "toxic_food", /datum/mood_event/disgusting_food)
		else if(foodtypes & tongue.disliked_food)
			to_chat(human_eater,"<span class='notice'>That didn't taste very good...</span>")
			human_eater.adjust_disgust(11 + 15 * fraction)
			SEND_SIGNAL(human_eater, COMSIG_ADD_MOOD_EVENT, "gross_food", /datum/mood_event/gross_food)
		else if(foodtypes & tongue.liked_food)
			to_chat(human_eater,"<span class='notice'>I love this taste!</span>")
			human_eater.adjust_disgust(-5 + -2.5 * fraction)
			SEND_SIGNAL(human_eater, COMSIG_ADD_MOOD_EVENT, "fav_food", /datum/mood_event/favorite_food)
	last_check_time = world.time

///Delete the item when it is fully eaten
/datum/component/edible/proc/on_consume(mob/living/eater, mob/living/feeder)
	SEND_SIGNAL(parent, COMSIG_FOOD_CONSUMED, eater, feeder)

	consume_callback?.Invoke(eater, feeder)

	to_chat(feeder, "<span class='warning'>There is nothing left of [parent], oh no!</span>")
	qdel(parent)

///Ability to feed food to puppers
/datum/component/edible/proc/use_by_animal(datum/source, mob/user)
	SIGNAL_HANDLER
	var/atom/owner = parent

	if(!isdog(user))
		return
	var/mob/living/L = user
	if(bitecount == 0 || prob(50))
		L.manual_emote("nibbles away at \the [parent].")
	bitecount++
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	L.taste(owner.reagents) // why should carbons get all the fun?
	if(bitecount >= 5)
		var/satisfaction_text = pick("burps from enjoyment.", "yaps for more!", "woofs twice.", "looks at the area where \the [parent] was.")
		L.manual_emote(satisfaction_text)
		qdel(parent)
