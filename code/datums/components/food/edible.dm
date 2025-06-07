/*!

This component makes it possible to make things edible. What this means is that you can take a bite or force someone to take a bite (in the case of items).
These items take a specific time to eat, and can do most of the things our original food items could.

Behavior that's still missing from this component that original food items had that should either be put into seperate components or somewhere else:
	Components:
	Drying component (jerky etc)
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
	///Callback to be ran for when the code check if the food is liked, allowing for unique overrides for special foods like donuts with cops.
	var/datum/callback/check_liked
	///Last time we checked for food likes
	var/last_check_time
	///The initial reagents of this food when it is made
	var/list/initial_reagents
	///The initial volume of the foods reagents
	var/volume
	///The flavortext for taste
	var/list/tastes
	///The type of atom this creates when the object is microwaved.
	var/atom/microwaved_type

/datum/component/edible/Initialize(
	list/initial_reagents,
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
	datum/callback/on_consume,
	datum/callback/check_liked,
	)

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_ANIMAL, PROC_REF(use_by_animal))
	RegisterSignal(parent, COMSIG_ATOM_CHECKPARTS, PROC_REF(on_craft))
	RegisterSignal(parent, COMSIG_ATOM_CREATEDBY_PROCESSING, PROC_REF(on_processed))
	RegisterSignal(parent, COMSIG_ITEM_MICROWAVE_COOKED, PROC_REF(on_microwave_cooked))
	RegisterSignal(parent, COMSIG_FOOD_INGREDIENT_ADDED, PROC_REF(edible_ingredient_added))
	RegisterSignal(parent, COMSIG_EDIBLE_ON_COMPOST, PROC_REF(compost))
	RegisterSignal(parent, COMSIG_FOOD_FEED_ITEM, PROC_REF(feed_to_item))

	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(use_from_hand))
		RegisterSignal(parent, COMSIG_GRILL_FOOD, PROC_REF(GrillFood))
		RegisterSignal(parent, COMSIG_ITEM_MICROWAVE_ACT, PROC_REF(on_microwaved))
		RegisterSignal(parent, COMSIG_ITEM_USED_AS_INGREDIENT,  PROC_REF(used_to_customize))

		var/obj/item/item = parent
		if (!item.grind_results)
			item.grind_results = list() //If this doesn't already exist, add it as an empty list. This is needed for the grinder to accept it.

	src.bite_consumption = bite_consumption
	src.food_flags = food_flags
	src.foodtypes = foodtypes
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
	src.check_liked = check_liked

	var/atom/owner = parent

	owner.create_reagents(volume, INJECTABLE)

	for(var/rid in initial_reagents)
		var/amount = initial_reagents[rid]
		if(length(tastes) && (rid == /datum/reagent/consumable/nutriment || rid == /datum/reagent/consumable/nutriment/vitamin))
			owner.reagents.add_reagent(rid, amount, tastes.Copy())
		else
			owner.reagents.add_reagent(rid, amount)

/datum/component/edible/InheritComponent(
	datum/component/C,
	i_am_original,
	list/initial_reagents,
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
	datum/callback/on_consume,
	datum/callback/check_liked,
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

	var/atom/owner = parent

	var/quality = get_perceived_food_quality(user)
	if(quality > 0)
		var/quality_label = GLOB.food_quality_description[quality]
		examine_list += span_green("You find this meal [quality_label].")
	else if (quality == 0)
		examine_list += span_green("You find this meal edible.")
	else if (quality <= TOXIC_FOOD_QUALITY_THRESHOLD)
		examine_list += span_warning("You find this meal disgusting!")
	else
		examine_list += span_green("You find this meal inedible.")

	var/datum/mind/mind = user.mind
	if(mind && HAS_TRAIT_FROM(owner, TRAIT_FOOD_CHEF_MADE, REF(mind)))
		examine_list += span_green("[owner] was made by you!")

	if(microwaved_type)
		examine_list += "[parent] could be <b>microwaved</b> into [initial(microwaved_type.name)]!"

	if(!(food_flags & FOOD_IN_CONTAINER))
		switch (bitecount)
			if (0)
				return
			if(1)
				examine_list += "[owner] was bitten by someone!"
			if(2,3)
				examine_list += "[owner] was bitten [bitecount] times!"
			else
				examine_list += "[owner] was bitten multiple times!"

/datum/component/edible/proc/use_from_hand(obj/item/source, mob/living/M, mob/living/user)
	SIGNAL_HANDLER

	return TryToEat(M, user)

/datum/component/edible/proc/GrillFood(datum/source, atom/fry_object, grill_time)
	SIGNAL_HANDLER

	var/atom/this_food = parent

	switch(grill_time) //no 0-20 to prevent spam
		if(20 to 30)
			this_food.name = "lightly-grilled [this_food.name]"
			this_food.desc = "[this_food.desc] It's been lightly grilled."
		if(30 to 80)
			this_food.name = "grilled [this_food.name]"
			this_food.desc = "[this_food.desc] It's been grilled."
			foodtypes |= FRIED
		if(80 to 100)
			this_food.name = "heavily grilled [this_food.name]"
			this_food.desc = "[this_food.desc] It's been heavily grilled."
			foodtypes |= FRIED
		if(100 to INFINITY) //grill marks reach max alpha
			this_food.name = "Powerfully Grilled [this_food.name]"
			this_food.desc = "A [this_food.name]. Reminds you of your wife, wait, no, it's prettier!"
			foodtypes |= FRIED

///Called when food is created through processing (Usually this means it was sliced). We use this to pass the OG items reagents.
/datum/component/edible/proc/on_processed(datum/source, atom/original_atom, list/chosen_processing_option)
	SIGNAL_HANDLER

	if(!original_atom.reagents)
		return

	var/atom/this_food = parent

	//Make sure we have a reagent container large enough to fit the original atom's reagents.
	volume = max(volume, ROUND_UP(original_atom.reagents.maximum_volume / chosen_processing_option[TOOL_PROCESSING_AMOUNT]))

	this_food.create_reagents(volume)
	original_atom.reagents.copy_to(this_food, original_atom.reagents.total_volume, 1 / chosen_processing_option[TOOL_PROCESSING_AMOUNT])

	if(original_atom.name != initial(original_atom.name))
		this_food.name = "slice of [original_atom.name]"
	if(original_atom.desc != initial(original_atom.desc))
		this_food.desc = "[original_atom.desc]"

///Called when food is crafted through a crafting recipe datum.
/datum/component/edible/proc/on_craft(datum/source, list/parts_list, datum/crafting_recipe/food/recipe)
	SIGNAL_HANDLER

	var/atom/this_food = parent

	for(var/obj/item/food/crafted_part in parts_list)
		if(!crafted_part.reagents)
			continue

		this_food.reagents.maximum_volume += crafted_part.reagents.maximum_volume
		crafted_part.reagents.trans_to(this_food.reagents, crafted_part.reagents.maximum_volume)

	this_food.reagents.maximum_volume = ROUND_UP(this_food.reagents.maximum_volume) // Just because I like whole numbers for this.

	SSblackbox.record_feedback("tally", "food_made", 1, type)

/datum/component/edible/proc/on_microwaved(datum/source, obj/machinery/microwave/used_microwave)
	SIGNAL_HANDLER

	var/turf/parent_turf = get_turf(parent)

	if(!microwaved_type)
		new /obj/item/food/badrecipe(parent_turf)
		qdel(parent)
		return

	var/obj/item/result

	result = new microwaved_type(parent_turf)

	var/efficiency = istype(used_microwave) ? used_microwave.efficiency : 1

	SEND_SIGNAL(result, COMSIG_ITEM_MICROWAVE_COOKED, parent, efficiency)

	SSblackbox.record_feedback("tally", "food_made", 1, result.type)
	qdel(parent)
	return COMPONENT_SUCCESFUL_MICROWAVE

///Corrects the reagents on the newly cooked food
/datum/component/edible/proc/on_microwave_cooked(datum/source, obj/item/source_item, cooking_efficiency = 1)
	SIGNAL_HANDLER

	var/atom/this_food = parent

	source_item.reagents?.trans_to(this_food, source_item.reagents.total_volume)

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

	if(feeder.combat_mode)
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN //Point of no return I suppose

	if(IsFoodGone(owner, feeder))
		return

	if(!CanConsume(eater, feeder))
		return
	var/fullness = eater.nutrition + 10 //The theoretical fullness of the person eating if they were to eat this

	var/time_to_eat = (eater == feeder) ? eat_time : EAT_TIME_FORCE_FEED

	if(eater == feeder)//If you're eating it yourself.
		if(eat_time && !do_after(feeder, time_to_eat, eater, timed_action_flags = food_flags & FOOD_FINGER_FOOD ? IGNORE_USER_LOC_CHANGE | IGNORE_TARGET_LOC_CHANGE : NONE)) //Gotta pass the minimal eat time
			return
		if(IsFoodGone(owner, feeder))
			return
		var/eatverb = pick(eatverbs)

		if(junkiness && eater.satiety < -150 && eater.nutrition > NUTRITION_LEVEL_STARVING + 50 && !HAS_TRAIT(eater, TRAIT_VORACIOUS))
			to_chat(eater, span_warning("You don't feel like eating any more junk food at the moment!"))
			return
		else if(fullness <= 50)
			eater.visible_message(span_notice("[eater] hungrily [eatverb]s \the [parent], gobbling it down!"), span_notice("You hungrily [eatverb] \the [parent], gobbling it down!"))
		else if(fullness > 50 && fullness < 150)
			eater.visible_message(span_notice("[eater] hungrily [eatverb]s \the [parent]."), span_notice("You hungrily [eatverb] \the [parent]."))
		else if(fullness > 150 && fullness < 500)
			eater.visible_message(span_notice("[eater] [eatverb]s \the [parent]."), span_notice("You [eatverb] \the [parent]."))
		else if(fullness > 500 && fullness < 600)
			eater.visible_message(span_notice("[eater] unwillingly [eatverb]s a bit of \the [parent]."), span_notice("You unwillingly [eatverb] a bit of \the [parent]."))
		else if(fullness > (600 * (1 + eater.overeatduration / (4000 SECONDS))))	// The more you eat - the more you can eat
			eater.visible_message(span_warning("[eater] cannot force any more of \the [parent] to go down [eater.p_their()] throat!"), span_warning("You cannot force any more of \the [parent] to go down your throat!"))
			return

	else //If you're feeding it to someone else.
		if(isbrain(eater))
			to_chat(feeder, span_warning("[eater] doesn't seem to have a mouth!"))
			return
		if(fullness <= (600 * (1 + eater.overeatduration / (2000 SECONDS))))
			eater.visible_message(
				span_danger("[feeder] attempts to feed [eater] [parent]."), \
				span_userdanger("[feeder] attempts to feed you [parent].")
			)
			if(eater.is_blind())
				to_chat(eater, span_userdanger("You feel someone trying to feed you something!"))
		else
			eater.visible_message(
				span_warning("[feeder] cannot force any more of [parent] down [eater]'s throat!"), \
				span_warning("[feeder] cannot force any more of [parent] down your throat!")
			)
			if(eater.is_blind())
				to_chat(eater, span_userdanger("You're too full to eat what's being fed to you!"))
			return
		if(!do_after(feeder, delay = time_to_eat, target = eater)) //Wait 3 seconds before you can feed
			return
		if(IsFoodGone(owner, feeder))
			return
		log_combat(feeder, eater, "fed", owner.reagents.log_list(), important = FALSE)
		eater.visible_message(
			span_danger("[feeder] forces [eater] to eat [parent]!"), \
			span_userdanger("[feeder] forces you to eat [parent]!")
		)
		if(eater.is_blind())
			to_chat(eater, span_userdanger("You're forced to eat something!"))

	TakeBite(eater, feeder)

	//If we're not force-feeding, try take another bite
	if(eater == feeder && eat_time)
		INVOKE_ASYNC(src, PROC_REF(TryToEat), eater, feeder)

#undef EAT_TIME_FORCE_FEED

///This function lets the eater take a bite and transfers the reagents to the eater.
/datum/component/edible/proc/TakeBite(mob/living/eater, mob/living/feeder)

	var/atom/owner = parent

	if(!owner?.reagents)
		stack_trace("[eater] failed to bite [owner], because [owner] had no reagents.")
		return FALSE
	if(eater.satiety > -200)
		eater.satiety -= junkiness
	playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	if(!owner.reagents.total_volume)
		return
	SEND_SIGNAL(parent, COMSIG_FOOD_EATEN, eater, feeder, bitecount, bite_consumption)

	//Give a buff when the dish is hand-crafted and unbitten
	if(bitecount == 0)
		apply_buff(eater)

	var/fraction = min(bite_consumption / owner.reagents.total_volume, 1)
	owner.reagents.trans_to(eater, bite_consumption, transfered_by = feeder, methods = INGEST)
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
		to_chat(feeder, span_warning("You have to remove [who] [covered] first!"))
		return FALSE
	return TRUE

///Applies food buffs according to the crafting complexity
/datum/component/edible/proc/apply_buff(mob/eater)
	var/buff
	var/recipe_complexity = get_recipe_complexity()
	if(recipe_complexity == 0)
		return
	var/obj/item/food/food = parent
	if(!isnull(food.crafted_food_buff))
		buff = food.crafted_food_buff
	else
		buff = pick_weight(GLOB.food_buffs[recipe_complexity])
	if(!isnull(buff))
		var/mob/living/living_eater = eater
		var/timeout = recipe_complexity
		var/strength = recipe_complexity
		living_eater.apply_status_effect(buff, timeout, strength)

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
			to_chat(human_eater, span_warning("You don't feel so good..."))
			human_eater.adjust_disgust(25 + 30 * fraction)
		return // Later checks are irrelevant if you have ageusia


	var/food_quality = get_perceived_food_quality(eater)
	if(food_quality <= TOXIC_FOOD_QUALITY_THRESHOLD)
		to_chat(human_eater,span_warning("What the hell was that thing?!"))
		human_eater.adjust_disgust(25 + 30 * fraction)
		SEND_SIGNAL(human_eater, COMSIG_ADD_MOOD_EVENT, "toxic_food", /datum/mood_event/disgusting_food)
	else if(food_quality < 0)
		to_chat(human_eater,span_notice("That didn't taste very good..."))
		human_eater.adjust_disgust(11 + 15 * fraction)
		SEND_SIGNAL(human_eater, COMSIG_ADD_MOOD_EVENT, "gross_food", /datum/mood_event/gross_food)
	else if(food_quality > 0)
		food_quality = min(food_quality, FOOD_QUALITY_TOP)
		var/event = GLOB.food_quality_events[food_quality]
		human_eater.adjust_disgust(-5 + -2 * food_quality * fraction)
		var/quality_label = GLOB.food_quality_description[food_quality]
		to_chat(human_eater, span_notice("That's \an [quality_label] meal."))
		SEND_SIGNAL(human_eater, COMSIG_ADD_MOOD_EVENT, "quality_food", event)
	last_check_time = world.time

/// Get the complexity of the crafted food
/datum/component/edible/proc/get_recipe_complexity()
	if(!HAS_TRAIT(parent, TRAIT_FOOD_CHEF_MADE) || !istype(parent, /obj/item/food))
		return 0 // It is factory made. Soulless.
	var/obj/item/food/food = parent
	return food.crafting_complexity

/// Get food quality adjusted according to eater's preferences
/datum/component/edible/proc/get_perceived_food_quality(mob/living/carbon/human/eater)
	var/food_quality = get_recipe_complexity()

	if(check_liked) //Callback handling; use this as an override for special food like donuts
		var/special_reaction = check_liked.Invoke(eater)
		switch(special_reaction) //return early for special foods
			if(FOOD_LIKED)
				return LIKED_FOOD_QUALITY_CHANGE
			if(FOOD_DISLIKED)
				return DISLIKED_FOOD_QUALITY_CHANGE
			if(FOOD_TOXIC)
				return TOXIC_FOOD_QUALITY_THRESHOLD

	var/obj/item/organ/tongue/tongue = eater.getorganslot(ORGAN_SLOT_TONGUE)
	if(ishuman(eater))
		if(count_matching_foodtypes(foodtypes, tongue?.toxic_food)) //if the food is toxic, we don't care about anything else
			return TOXIC_FOOD_QUALITY_THRESHOLD
		if(HAS_TRAIT(eater, TRAIT_AGEUSIA)) //if you can't taste it, it doesn't taste good
			return 0

	food_quality += DISLIKED_FOOD_QUALITY_CHANGE * count_matching_foodtypes(foodtypes, tongue?.disliked_food)
	food_quality += LIKED_FOOD_QUALITY_CHANGE * count_matching_foodtypes(foodtypes, tongue?.liked_food)

	return food_quality

/// Get the number of matching food types in provided bitfields
/datum/component/edible/proc/count_matching_foodtypes(bitfield_one, bitfield_two)
	var/count = 0
	var/matching_bits = bitfield_one & bitfield_two
	while (matching_bits > 0)
		if (matching_bits & 1)
			count++
		matching_bits >>= 1
	return count

///Delete the item when it is fully eaten
/datum/component/edible/proc/on_consume(mob/living/eater, mob/living/feeder)
	SEND_SIGNAL(parent, COMSIG_FOOD_CONSUMED, eater, feeder)

	on_consume?.Invoke(eater, feeder)

	to_chat(feeder, span_warning("There is nothing left of [parent], oh no!"))
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

///Ability to feed food to items?
/datum/component/edible/proc/feed_to_item(datum/source, atom/movable/eater)
	SIGNAL_HANDLER

	if(bitecount == 0 || prob(50))
		eater.visible_message("[eater] nibbles away at \the [parent].", allow_inside_usr = TRUE)
	bitecount++
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	if(bitecount >= 5)
		var/satisfaction_text = pick("burps from enjoyment.", "looks at the area where \the [parent] was.")
		eater.visible_message("[eater] [satisfaction_text]", allow_inside_usr = TRUE)
		qdel(parent)

///Response to being used to customize something
/datum/component/edible/proc/used_to_customize(datum/source, atom/customized)
	SIGNAL_HANDLER

	SEND_SIGNAL(customized, COMSIG_FOOD_INGREDIENT_ADDED, src)

///Response to an edible ingredient being added to parent.
/datum/component/edible/proc/edible_ingredient_added(datum/source, datum/component/edible/ingredient)
	SIGNAL_HANDLER

	var/datum/component/edible/E = ingredient
	if (LAZYLEN(E.tastes))
		tastes = tastes.Copy()
		for (var/t in E.tastes)
			tastes[t] += E.tastes[t]
	foodtypes |= E.foodtypes
