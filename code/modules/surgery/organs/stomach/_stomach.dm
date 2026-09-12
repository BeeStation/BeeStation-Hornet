//The contant in the rate of reagent transfer on life ticks
#define STOMACH_METABOLISM_CONSTANT 0.5
//Stamina drained per second once nutrition is gone and there is nothing left to digest
#define STARVATION_STAMINA_DRAIN 2

/obj/item/organ/stomach
	name = "stomach"
	icon_state = "stomach"
	visual = FALSE
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_STOMACH
	attack_verb_continuous = list("gores", "squishes", "slaps", "digests")
	attack_verb_simple = list("gore", "squish", "slap", "digest")
	desc = "Onaka ga suite imasu."

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY * 1.15 // ~13 minutes

	low_threshold_passed = span_info("Your stomach flashes with pain before subsiding. Food doesn't seem like a good idea right now.")
	high_threshold_passed = span_warning("Your stomach flares up with constant pain- you can hardly stomach the idea of food right now!")
	high_threshold_cleared = span_info("The pain in your stomach dies down for now, but food still seems unappealing.")
	low_threshold_cleared = span_info("The last bouts of pain in your stomach have died out.")

	food_reagents = list(/datum/reagent/consumable/nutriment/organ_tissue = 5)
	//This is a reagent user and needs more then the 10u from edible component
	reagent_vol = 1000

	///The rate that disgust decays
	var/disgust_metabolism = 1

	///The rate that the stomach will transfer reagents to the body
	var/metabolism_efficiency = 0.05 // the lowest we should go is 0.05

	/// Multiplier for hunger rate
	var/hunger_modifier = 1
	/// Peak movement penalty at zero nutrition
	var/starving_slowdown = 0.6
	/// store owner nutrition last tick
	var/last_nutrition = NUTRITION_LEVEL_FED
	/// Whether we have run dry
	var/in_starvation = FALSE
	/// Whether the stomach's been repaired with surgery and can be fixed again or not
	var/operated = FALSE

/obj/item/organ/stomach/Initialize(mapload)
	. = ..()
	//None edible organs do not get a reagent holder by default
	if(!reagents)
		create_reagents(reagent_vol)

/obj/item/organ/stomach/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	last_nutrition = organ_owner.nutrition

/obj/item/organ/stomach/on_life(delta_time, times_fired)
	. = ..()

	//Manage species digestion
	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/humi = owner
		if(!(organ_flags & ORGAN_FAILING))
			handle_hunger(humi, delta_time, times_fired)

	var/mob/living/carbon/body = owner

	// digest food, sent all reagents that can metabolize to the body
	for(var/datum/reagent/bit as anything in reagents.reagent_list)

		// If the reagent does not metabolize then it will sit in the stomach
		// This has an effect on items like plastic causing them to take up space in the stomach
		if(bit.metabolization_rate <= 0)
			continue

		//Ensure that the the minimum is equal to the metabolization_rate of the reagent if it is higher then the STOMACH_METABOLISM_CONSTANT
		var/rate_min = max(bit.metabolization_rate, STOMACH_METABOLISM_CONSTANT)
		//Do not transfer over more then we have
		var/amount_max = bit.volume

		//If the reagent is part of the food reagents for the organ
		//prevent all the reagents form being used leaving the food reagents
		var/amount_food = food_reagents[bit.type]
		if(amount_food)
			amount_max = max(amount_max - amount_food, 0)

		// Transfer the amount of reagents based on volume with a min amount of 1u
		var/amount = min((round(metabolism_efficiency * amount_max, 0.05) + rate_min) * delta_time, amount_max)

		if(amount <= 0)
			continue

		// transfer the reagents over to the body at the rate of the stomach metabolim
		// this way the body is where all reagents that are processed and react
		// the stomach manages how fast they are feed in a drip style
		reagents.trans_id_to(body, bit.type, amount=amount)

	//Handle disgust
	if(body)
		handle_disgust(body, delta_time, times_fired)

	//If the stomach is not damage exit out
	if(damage < low_threshold)
		return

	//We are checking if we have nutriment in a damaged stomach.
	var/nutri_vol = get_free_nutriment_volume()
	if(!nutri_vol)
		return

	//The stomach is damage has nutriment but low on theshhold, lo prob of vomit
	if(DT_PROB(0.0125 * damage * nutri_vol * nutri_vol, delta_time))
		body.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = damage)
		to_chat(body, span_warning("Your stomach reels in pain as you're incapable of holding down all that food!"))
		return

	// the change of vomit is now high
	if(damage > high_threshold && DT_PROB(0.05 * damage * nutri_vol * nutri_vol, delta_time))
		body.vomit(VOMIT_CATEGORY_DEFAULT, lost_nutrition = damage)
		to_chat(body, span_warning("Your stomach reels in pain as you're incapable of holding down all that food!"))

///Nutriment in the stomach, besides the organ's own food reagents. 0 if empty.
/obj/item/organ/stomach/proc/get_free_nutriment_volume()
	var/datum/reagent/nutri = locate(/datum/reagent/consumable/nutriment) in reagents.reagent_list
	if(!nutri)
		return 0
	var/amount_food = food_reagents[nutri.type]
	return amount_food ? max(nutri.volume - amount_food, 0) : nutri.volume

/obj/item/organ/stomach/proc/handle_hunger(mob/living/carbon/human/human, delta_time, times_fired)
	if(HAS_TRAIT(human, TRAIT_NOHUNGER))
		return //hunger is for BABIES

	//The fucking TRAIT_FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
	if(HAS_TRAIT_FROM(human, TRAIT_FAT, OBESITY))//I share your pain, past coder.
		if(human.overeatduration < (200 SECONDS))
			to_chat(human, span_notice("You feel fit again!"))
			human.remove_traits(list(TRAIT_FAT, TRAIT_OFF_BALANCE_TACKLER), OBESITY)
	else
		if(human.overeatduration >= (200 SECONDS))
			to_chat(human, span_danger("You suddenly feel blubbery!"))
			human.add_traits(list(TRAIT_FAT, TRAIT_OFF_BALANCE_TACKLER), OBESITY)

	// nutrition decrease and satiety
	if (human.nutrition > 0 && human.stat != DEAD)
		// THEY HUNGER
		var/hunger_rate = HUNGER_FACTOR
		var/datum/component/mood/mood = human.GetComponent(/datum/component/mood)
		if(mood && mood.sanity > SANITY_DISTURBED)
			hunger_rate *= max(1 - 0.002 * mood.sanity, 0.5) //0.85 at SANITY_DISTURBED down to 0.7 at SANITY_MAXIMUM
		// Whether we cap off our satiety or move it towards 0
		if(human.satiety > MAX_SATIETY)
			human.satiety = MAX_SATIETY
		else if(human.satiety > 0)
			human.satiety--
		else if(human.satiety < -MAX_SATIETY)
			human.satiety = -MAX_SATIETY
		else if(human.satiety < 0)
			human.satiety++
			if(DT_PROB(round(-human.satiety/77), delta_time))
				human.set_jitter_if_lower(10 SECONDS)
			hunger_rate = 3 * HUNGER_FACTOR
		hunger_rate *= hunger_modifier
		hunger_rate *= human.physiology.hunger_mod
		human.adjust_nutrition(-hunger_rate * delta_time)

	if(human.nutrition > NUTRITION_LEVEL_FULL)
		if(human.overeatduration < 20 MINUTES) //capped so people don't take forever to unfat
			human.overeatduration = min(human.overeatduration + (1 SECONDS * delta_time), 20 MINUTES)
	else
		if(human.overeatduration > 0)
			human.overeatduration = max(human.overeatduration - (2 SECONDS * delta_time), 0) //doubled the unfat rate

	//metabolism change
	var/new_efficiency = 1
	if(human.nutrition <= NUTRITION_LEVEL_FAT && human.nutrition > NUTRITION_LEVEL_FED && human.satiety > SATIETY_WELL_NOURISHED)
		new_efficiency = 1.25
	else if(human.nutrition < NUTRITION_LEVEL_STARVING + 50)
		new_efficiency = 0.8

	if(new_efficiency != human.metabolism_efficiency)
		if(new_efficiency > 1)
			to_chat(human, span_info("Chems seem to burn out of you faster than usual."))
		else if(new_efficiency < 1)
			to_chat(human, span_warning("Chems seem to linger in you longer than usual."))
		else
			to_chat(human, span_info("Your metabolism settles back to its usual pace."))
		human.metabolism_efficiency = new_efficiency

	handle_hunger_slowdown(human)

	switch(human.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			human.throw_alert("nutrition", /atom/movable/screen/alert/fat)
			human.remove_actionspeed_modifier(ACTIONSPEED_ID_SATIETY)
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_FULL)
			human.clear_alert("nutrition")
			human.add_actionspeed_modifier(/datum/actionspeed_modifier/well_fed)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			human.clear_alert("nutrition")
			human.remove_actionspeed_modifier(ACTIONSPEED_ID_SATIETY)
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			human.throw_alert("nutrition", /atom/movable/screen/alert/hungry)
			human.add_actionspeed_modifier(/datum/actionspeed_modifier/starving)
		if(0 to NUTRITION_LEVEL_STARVING)
			human.throw_alert("nutrition", /atom/movable/screen/alert/starving)
			human.add_actionspeed_modifier(/datum/actionspeed_modifier/starving)

	announce_hunger_transitions(human)
	handle_starvation(human, delta_time)
	handle_hunger_pangs(human, delta_time)

/obj/item/organ/stomach/proc/announce_hunger_transitions(mob/living/carbon/human/human)
	var/was = last_nutrition
	last_nutrition = human.nutrition

	if(was >= NUTRITION_LEVEL_FED && human.nutrition < NUTRITION_LEVEL_FED)
		to_chat(human, span_warning("You feel weak with hunger."))
	else if(was < NUTRITION_LEVEL_WELL_FED && human.nutrition >= NUTRITION_LEVEL_WELL_FED)
		to_chat(human, span_info("You feel much better with some food in you."))

///Out of food
/obj/item/organ/stomach/proc/handle_starvation(mob/living/carbon/human/human, delta_time)
	if(human.nutrition > 0 || get_free_nutriment_volume())
		if(in_starvation)
			in_starvation = FALSE
			to_chat(human, span_info("The worst of the weakness passes."))
		return

	if(!in_starvation)
		in_starvation = TRUE
		human.visible_message(
			span_warning("[human] sags, barely able to stay upright!"),
			span_userdanger("You've got nothing left! Your body gives out!"),
		)

	if(!HAS_TRAIT_FROM(human, TRAIT_INCAPACITATED, STAMINA))
		human.adjustStaminaLoss(STARVATION_STAMINA_DRAIN * delta_time)

///Your stomach craves sustenance (no one looks at the HUD)
/obj/item/organ/stomach/proc/handle_hunger_pangs(mob/living/carbon/human/human, delta_time)
	if(human.stat != CONSCIOUS)
		return

	var/growl_chance = 0
	switch(human.nutrition)
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			growl_chance = 0.4
		if(0 to NUTRITION_LEVEL_STARVING)
			growl_chance = 1

	if(growl_chance && DT_PROB(growl_chance, delta_time))
		human.audible_message(
			span_warning("[human]'s stomach growls."),
			hearing_distance = 2,
			self_message = span_warning("Your stomach growls."),
			audible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)

	if(human.nutrition >= NUTRITION_LEVEL_STARVING)
		return

	// Check for any reagents, to skip people who get to zero and then eat
	if(get_free_nutriment_volume())
		return

	// Eat. Your. Food.
	if(DT_PROB(0.3, delta_time))
		human.visible_message(
			span_warning("[human] dry heaves!"),
			span_userdanger("You dry heave, but there's nothing left to bring up!"),
		)

/obj/item/organ/stomach/proc/handle_hunger_slowdown(mob/living/carbon/human/human)
	if(human.nutrition >= NUTRITION_LEVEL_FED)
		human.remove_movespeed_modifier(/datum/movespeed_modifier/visible_hunger)
		return
	human.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/visible_hunger, multiplicative_slowdown = starving_slowdown * (1 - (human.nutrition / NUTRITION_LEVEL_FED)))

/obj/item/organ/stomach/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantstomach

/obj/item/organ/stomach/proc/handle_disgust(mob/living/carbon/human/disgusted, delta_time, times_fired)
	var/old_disgust = disgusted.old_disgust
	var/disgust = disgusted.disgust

	if(disgust)
		var/pukeprob = 2.5 + (0.025 * disgusted.disgust)
		if(disgusted.disgust >= DISGUST_LEVEL_GROSS)
			if(DT_PROB(5, delta_time))
				disgusted.adjust_stutter(2 SECONDS)
				disgusted.adjust_confusion(2 SECONDS)
			if(DT_PROB(5, delta_time) && !disgusted.stat)
				to_chat(disgusted, span_warning("You feel kind of iffy..."))
			disgusted.adjust_jitter(-6 SECONDS)
		if(disgusted.disgust >= DISGUST_LEVEL_VERYGROSS)
			if(DT_PROB(pukeprob, delta_time)) //iT hAndLeS mOrE ThaN PukInG
				disgusted.adjust_confusion(2.5 SECONDS)
				disgusted.adjust_stutter(2 SECONDS)
				disgusted.vomit(VOMIT_CATEGORY_KNOCKDOWN, distance = 0)
				disgusted.adjust_disgust(-50)
			disgusted.set_dizzy_if_lower(10 SECONDS)
		if(disgusted.disgust >= DISGUST_LEVEL_DISGUSTED)
			if(DT_PROB(13, delta_time))
				disgusted.set_eye_blur_if_lower(6 SECONDS) //We need to add more shit down here

		disgusted.adjust_disgust(-0.25 * disgust_metabolism * delta_time)

	// I would consider breaking this up into steps matching the disgust levels
	// But disgust is used so rarely it wouldn't save a significant amount of time, and it makes the code just way worse
	// We're in the same state as the last time we processed, so don't bother
	if(old_disgust == disgust)
		return

	disgusted.old_disgust = disgust
	switch(disgust)
		if(0 to DISGUST_LEVEL_GROSS)
			disgusted.clear_alert("disgust")
			SEND_SIGNAL(disgusted, COMSIG_CLEAR_MOOD_EVENT, "disgust")
		if(DISGUST_LEVEL_GROSS to DISGUST_LEVEL_VERYGROSS)
			disgusted.throw_alert("disgust", /atom/movable/screen/alert/gross)
			SEND_SIGNAL(disgusted, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/gross)
		if(DISGUST_LEVEL_VERYGROSS to DISGUST_LEVEL_DISGUSTED)
			disgusted.throw_alert("disgust", /atom/movable/screen/alert/verygross)
			SEND_SIGNAL(disgusted, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/verygross)
		if(DISGUST_LEVEL_DISGUSTED to INFINITY)
			disgusted.throw_alert("disgust", /atom/movable/screen/alert/disgusted)
			SEND_SIGNAL(disgusted, COMSIG_ADD_MOOD_EVENT, "disgust", /datum/mood_event/disgusted)

/obj/item/organ/stomach/Remove(mob/living/carbon/stomach_owner, special = 0, pref_load = FALSE)
	if(ishuman(stomach_owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.clear_alert("disgust")
		SEND_SIGNAL(human_owner, COMSIG_CLEAR_MOOD_EVENT, "disgust")
		human_owner.clear_alert("nutrition")
		human_owner.remove_movespeed_modifier(/datum/movespeed_modifier/visible_hunger)
		human_owner.remove_actionspeed_modifier(ACTIONSPEED_ID_SATIETY)
		human_owner.metabolism_efficiency = initial(human_owner.metabolism_efficiency)

	return ..()

/obj/item/organ/stomach/fly
	name = "insectoid stomach"
	icon_state = "stomach-x"
	desc = "A mutant stomach designed to handle the unique diet of a flyperson."

/obj/item/organ/stomach/fly/on_life(delta_time, times_fired)
	if(locate(/datum/reagent/consumable) in reagents.reagent_list)
		var/mob/living/carbon/body = owner
		// we do not loss any nutrition as a fly when vomiting out food
		body.vomit(vomit_flags = (MOB_VOMIT_MESSAGE | MOB_VOMIT_FORCE | MOB_VOMIT_HARM), lost_nutrition = 0, distance = 2, purge_ratio = 0.67)
		playsound(get_turf(owner), 'sound/effects/splat.ogg', 50, TRUE)
		body.visible_message(span_danger("[body] vomits on the floor!"), \
					span_userdanger("You throw up on the floor!"))
	return ..()

/obj/item/organ/stomach/bone
	name = "mass of bones"
	desc = "You have no idea what this strange ball of bones does."
	icon_state = "stomach-bone"
	metabolism_efficiency = 0.025 //very bad
	organ_traits = list(TRAIT_NOHUNGER)

/obj/item/organ/stomach/bone/plasmaman
	name = "digestive crystal"
	desc = "A strange crystal that is responsible for metabolizing the unseen energy force that feeds plasmamen."
	icon_state = "stomach-p"
	metabolism_efficiency = 0.06
	organ_traits = null

/obj/item/organ/stomach/cybernetic
	name = "cybernetic stomach"
	icon_state = "stomach-c"
	desc = "A basic device designed to mimic the functions of a human stomach"
	organ_flags = ORGAN_ROBOTIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.5
	metabolism_efficiency = 0.035 // not as good at digestion
	var/emp_vulnerability = 80 //Chance of permanent effects if emp-ed.

/obj/item/organ/stomach/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!COOLDOWN_FINISHED(src, emp_cooldown))
		owner.vomit(vomit_flags = (MOB_VOMIT_MESSAGE | MOB_VOMIT_HARM))
		COOLDOWN_START(src, emp_cooldown, 10 SECONDS)
	if(prob(emp_vulnerability/severity))
		organ_flags |= ORGAN_EMP

/obj/item/organ/stomach/cybernetic/tier2
	name = "upgraded cybernetic stomach"
	icon_state = "stomach-c-u"
	desc = "An electronic device designed to mimic the functions of a human stomach. Handles disgusting food a bit better."
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	disgust_metabolism = 2
	emp_vulnerability = 25
	metabolism_efficiency = 0.07

/obj/item/organ/stomach/diona
	name = "nutrient vessel"
	desc = "A group of plant matter and vines, useful for digestion of light and radiation."
	icon_state = "diona_stomach"

#undef STOMACH_METABOLISM_CONSTANT
#undef STARVATION_STAMINA_DRAIN
