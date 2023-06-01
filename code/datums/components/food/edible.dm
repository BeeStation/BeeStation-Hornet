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
	var/datum/callback/on_consume
	///Last time we checked for food likes
	var/last_check_time
	///The initial reagents of this food when it is made
	var/list/initial_reagents
	///The initial volume of the foods reagents
	var/volume
	///The flavortext for taste
	var/list/tastes
	///The type of atom this creates when the object is microwaved.
	var/microwaved_type

/datum/component/edible/Initialize(list/initial_reagents,
	food_flags = NONE,
	foodtypes = NONE,
	volume = 50,
	eat_time = 10,
	list/tastes,
	list/eatverbs = list("bite","chew","nibble","gnaw","gobble","chomp"),
	bite_consumption = 2,
	microwaved_type,
	junkiness,
	datum/callback/pre_eat,
	datum/callback/on_compost,
	datum/callback/after_eat,
	datum/callback/on_consume
)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ANIMAL, PROC_REF(use_by_animal))
	RegisterSignal(parent, COMSIG_ATOM_CHECKPARTS, PROC_REF(on_craft))
	RegisterSignal(parent, COMSIG_ATOM_CREATEDBY_PROCESSING, PROC_REF(on_processed))
	RegisterSignal(parent, COMSIG_ITEM_MICROWAVE_COOKED, PROC_REF(on_microwave_cooked))
	RegisterSignal(parent, COMSIG_EDIBLE_ON_COMPOST, PROC_REF(compost))

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(use_from_hand))
		RegisterSignal(parent, COMSIG_ITEM_FRIED, PROC_REF(on_fried))
		RegisterSignal(parent, COMSIG_ITEM_MICROWAVE_ACT, PROC_REF(on_microwaved))

		var/obj/item/item = parent
		if (!item.grind_results)
			item.grind_results = list() //If this doesn't already exist, add it as an empty list. This is needed for the grinder to accept it.

	src.bite_consumption = bite_consumption
	src.food_flags = food_flags
	src.foodtypes = foodtypes
	src.initial_reagents = initial_reagents
	src.tastes = tastes
	src.eat_time = eat_time
	src.eatverbs = string_list(eatverbs)
	src.junkiness = junkiness
	src.pre_eat = pre_eat
	src.on_compost = on_compost
	src.after_eat = after_eat
	src.on_consume = on_consume
	src.initial_reagents = string_assoc_list(initial_reagents)
	src.tastes = string_assoc_list(tastes)
	src.microwaved_type = microwaved_type

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
	datum/callback/on_consume
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
	src.on_consume = on_consume

/datum/component/edible/Destroy(force, silent)
	QDEL_NULL(pre_eat)
	QDEL_NULL(on_compost)
	QDEL_NULL(after_eat)
	QDEL_NULL(on_consume)
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

/datum/component/edible/proc/on_fried(fry_object)
	SIGNAL_HANDLER
	var/atom/our_atom = parent
	our_atom.reagents.trans_to(fry_object, our_atom.reagents.total_volume)
	qdel(our_atom)
	return COMSIG_FRYING_HANDLED

///Called when food is created through processing (Usually this means it was sliced). We use this to pass the OG items reagents.
/datum/component/edible/proc/on_processed(datum/source, atom/original_atom, list/chosen_processing_option)
	SIGNAL_HANDLER

	if(!original_atom.reagents)
		return

	var/atom/this_food = parent
	var/reagents_for_slice = chosen_processing_option[TOOL_PROCESSING_AMOUNT]

	this_food.create_reagents(volume) //Make sure we have a reagent container

	original_atom.reagents.trans_to(this_food, reagents_for_slice)

	if(original_atom.name != initial(original_atom.name))
		this_food.name = "slice of [original_atom.name]"
	if(original_atom.desc != initial(original_atom.desc))
		this_food.desc = "[original_atom.desc]"

///Called when food is crafted through a crafting recipe datum.
/datum/component/edible/proc/on_craft(datum/source, list/parts_list, datum/crafting_recipe/food/recipe)
	SIGNAL_HANDLER

	var/atom/this_food = parent

	this_food.reagents.clear_reagents()

	for(var/obj/item/crafted_part in this_food.contents)
		crafted_part.reagents?.trans_to(this_food.reagents, crafted_part.reagents.maximum_volume, CRAFTED_FOOD_INGREDIENT_REAGENT_MODIFIER)

	var/list/objects_to_delete = list()

	// Remove all non recipe objects from the contents
	for(var/content_object in this_food.contents)
		for(var/recipe_object in recipe.real_parts)
			if(istype(content_object, recipe_object))
				continue
		objects_to_delete += content_object

	QDEL_LIST(objects_to_delete)

	for(var/r_id in initial_reagents)
		var/amount = initial_reagents[r_id] * CRAFTED_FOOD_BASE_REAGENT_MODIFIER
		if(r_id == /datum/reagent/consumable/nutriment || r_id == /datum/reagent/consumable/nutriment/vitamin)
			this_food.reagents.add_reagent(r_id, amount, tastes)
		else
			this_food.reagents.add_reagent(r_id, amount)

	SSblackbox.record_feedback("tally", "food_made", 1, type)

/datum/component/edible/proc/on_microwaved(datum/source, obj/machinery/microwave/used_microwave)
	SIGNAL_HANDLER

	var/turf/parent_turf = get_turf(parent)

	if(!microwaved_type)
		new /obj/item/reagent_containers/food/snacks/badrecipe(parent_turf)
		qdel(src)
		return


	var/obj/item/result

	result = new microwaved_type(parent_turf)

	var/efficiency = istype(used_microwave) ? used_microwave.efficiency : 1

	SEND_SIGNAL(result, COMSIG_ITEM_MICROWAVE_COOKED, parent, efficiency)

	SSblackbox.record_feedback("tally", "food_made", 1, result.type)

///Corrects the reagents on the newly cooked food
/datum/component/edible/proc/on_microwave_cooked(datum/source, obj/item/source_item, cooking_efficiency = 1)
	SIGNAL_HANDLER

	var/atom/this_food = parent

	this_food.reagents.clear_reagents()

	source_item.reagents?.trans_to(this_food, source_item.reagents.total_volume)

	for(var/r_id in initial_reagents)
		var/amount = initial_reagents[r_id] * cooking_efficiency * CRAFTED_FOOD_BASE_REAGENT_MODIFIER
		if(r_id == /datum/reagent/consumable/nutriment || r_id == /datum/reagent/consumable/nutriment/vitamin)
			this_food.reagents.add_reagent(r_id, amount, tastes)
		else
			this_food.reagents.add_reagent(r_id, amount)

///Makes sure the thing hasn't been destroyed or fully eaten to prevent eating phantom edibles
/datum/component/edible/proc/IsFoodGone(atom/owner, mob/living/feeder)
	if(QDELETED(owner)|| !(IS_EDIBLE(owner)))
		return TRUE
	if(owner.reagents.total_volume)
		return FALSE
	return TRUE

/// Normal time to forcefeed someone something
#define EAT_TIME_FORCE_FEED (3 SECONDS)

///All the checks for the act of eating itself and
/datum/component/edible/proc/TryToEat(mob/living/eater, mob/living/feeder)

	set waitfor = FALSE // We might end up sleeping here, so we don't want to hold up anything

	var/atom/owner = parent

	if(feeder.a_intent == INTENT_HARM)
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN //Point of no return I suppose

	if(IsFoodGone(owner, feeder))
		return

	if(!CanConsume(eater, feeder))
		return
	var/fullness = eater.nutrition + 10 //The theoretical fullness of the person eating if they were to eat this

	var/time_to_eat = (eater = feeder) ? eat_time : EAT_TIME_FORCE_FEED

	if(eater == feeder)//If you're eating it yourself.
		if(eat_time && !do_after(feeder, time_to_eat, eater, timed_action_flags = food_flags & FOOD_FINGER_FOOD ? IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE : NONE)) //Gotta pass the minimal eat time
			return
		if(IsFoodGone(owner, feeder))
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
			eater.visible_message(
				"<span class='danger'>[feeder] attempts to feed [eater] [parent].</span>", \
				"<span class='userdanger'>[feeder] attempts to feed you [parent].</span>"
			)
			if(eater.is_blind())
				to_chat(eater, "<span class='userdanger'>You feel someone trying to feed you something!</span>")
		else
			eater.visible_message(
				"<span class='warning'>[feeder] cannot force any more of [parent] down [eater]'s throat!</span>", \
				"<span class='warning'>[feeder] cannot force any more of [parent] down your throat!</span>"
			)
			if(eater.is_blind())
				to_chat(eater, "<span class='userdanger'>You're too full to eat what's being fed to you!</span>")
			return
		if(!do_after(feeder, delay = time_to_eat, target = eater)) //Wait 3 seconds before you can feed
			return
		if(IsFoodGone(owner, feeder))
			return
		log_combat(feeder, eater, "fed", owner.reagents.log_list())
		eater.visible_message(
			"<span class='danger'>[feeder] forces [eater] to eat [parent]!</span>", \
			"<span class='userdanger'>[feeder] forces you to eat [parent]!</span>"
		)
		if(eater.is_blind())
			to_chat(eater, "<span class='userdanger'>You're forced to eat something!</span>")

	TakeBite(eater, feeder)

	//If we're not force-feeding, try take another bite
	if(eater == feeder && eat_time)
		INVOKE_ASYNC(src, PROC_REF(TryToEat), eater, feeder)

#undef EAT_TIME_FORCE_FEED

///This function lets the eater take a bite and transfers the reagents to the eater.
/datum/component/edible/proc/TakeBite(mob/living/eater, mob/living/feeder)

	var/atom/owner = parent

	if(!owner?.reagents)
		return FALSE
	if(eater.satiety > -200)
		eater.satiety -= junkiness
	playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	if(!owner.reagents.total_volume)
		return
	SEND_SIGNAL(parent, COMSIG_FOOD_EATEN, eater, feeder, bitecount, bite_consumption)
	var/fraction = min(bite_consumption / owner.reagents.total_volume, 1)
	owner.reagents.trans_to(eater, bite_consumption, transfered_by = feeder, method = INGEST)
	bitecount++
	check_liked(fraction, eater)
	if(!owner.reagents.total_volume)
		on_consume(eater, feeder)

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
/datum/component/edible/proc/CanConsume(mob/living/eater, mob/living/feeder)
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

	on_consume?.Invoke(eater, feeder)

	if(isturf(parent))
		var/turf/T = parent
		T.ScrapeAway(1, CHANGETURF_INHERIT_AIR)
	else
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
