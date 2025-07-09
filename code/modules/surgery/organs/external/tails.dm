// Note: tails only work in humans. They use human-specific parameters and rely on human code for displaying.

/obj/item/organ/external/tail
	name = "tail"
	desc = "A severed tail. What did you cut this off of?"
	icon_state = "severedtail"

	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_EXTERNAL_TAIL

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail

	dna_block = DNA_TAIL_BLOCK
	restyle_flags = EXTERNAL_RESTYLE_FLESH

	///Does this tail have a wagging sprite, and is it currently wagging?
	var/wag_flags = NONE
	///The original owner of this tail
	var/original_owner //Yay, snowflake code!
	
/obj/item/organ/external/tail/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()
	if(.)
		RegisterSignal(reciever, COMSIG_ORGAN_WAG_TAIL, .proc/wag)
		original_owner ||= WEAKREF(reciever)

		SEND_SIGNAL(reciever, COMSIG_CLEAR_MOOD_EVENT, "tail_lost")
		SEND_SIGNAL(reciever, COMSIG_CLEAR_MOOD_EVENT, "tail_balance_lost")

		if(IS_WEAKREF_OF(reciever, original_owner))
			SEND_SIGNAL(reciever, COMSIG_CLEAR_MOOD_EVENT, "wrong_tail_regained")
		else if(type in reciever.dna.species.external_organs)
			SEND_SIGNAL(reciever, COMSIG_ADD_MOOD_EVENT, "wrong_tail_regained", /datum/mood_event/tail_regained_wrong)

/obj/item/organ/external/tail/Remove(mob/living/carbon/organ_owner, special, moving)
	if(wag_flags & WAG_WAGGING)
		wag(FALSE)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_ORGAN_WAG_TAIL)

	if(type in organ_owner.dna.species.external_organs)
		SEND_SIGNAL(organ_owner, COMSIG_ADD_MOOD_EVENT, "tail_lost", /datum/mood_event/tail_lost)
		SEND_SIGNAL(organ_owner, COMSIG_ADD_MOOD_EVENT, "tail_balance_lost", /datum/mood_event/tail_balance_lost)

/obj/item/organ/external/tail/proc/wag(mob/user, start = TRUE, stop_after = 0)
	if(!(wag_flags & WAG_ABLE))
		return

	if(start)
		start_wag()
		if(stop_after)
			addtimer(CALLBACK(src, .proc/wag, FALSE), stop_after, TIMER_STOPPABLE|TIMER_DELETE_ME)
	else
		stop_wag()
	owner.update_body_parts()

///We need some special behaviour for accessories, wrapped here so we can easily add more interactions later
/obj/item/organ/external/tail/proc/start_wag()
	var/datum/bodypart_overlay/mutant/tail/accessory = bodypart_overlay
	wag_flags |= WAG_WAGGING
	accessory.wagging = TRUE

///We need some special behaviour for accessories, wrapped here so we can easily add more interactions later
/obj/item/organ/external/tail/proc/stop_wag()
	var/datum/bodypart_overlay/mutant/tail/accessory = bodypart_overlay
	wag_flags &= ~WAG_WAGGING
	accessory.wagging = FALSE

///Tail parent type (which is MONKEEEEEEEEEEE by default), with wagging functionality
/datum/bodypart_overlay/mutant/tail
	layers = EXTERNAL_FRONT|EXTERNAL_BEHIND
	feature_key = "tail_monkey"
	var/wagging = FALSE

/datum/bodypart_overlay/mutant/tail/get_base_icon_state()
	return (wagging ? "wagging_" : "") + sprite_datum.icon_state //add the wagging tag if we be wagging

/datum/bodypart_overlay/mutant/tail/get_global_feature_list()
	return GLOB.tails_list

/datum/bodypart_overlay/mutant/tail/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(human.wear_suit && (human.wear_suit.flags_inv & HIDEJUMPSUIT))
		return FALSE
	return TRUE

/obj/item/organ/external/tail/cat
	name = "cat tail"
	desc = "A severed cat tail. Who's wagging now?"
	preference = "feature_human_tail"

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/cat

	wag_flags = WAG_ABLE

	organ_traits = list(TRAIT_LIGHT_LANDING)

///Cat tail bodypart overlay
/datum/bodypart_overlay/mutant/tail/cat
	feature_key = "tail_cat"
	color_source = ORGAN_COLOR_HAIR

/datum/bodypart_overlay/mutant/tail/cat/get_global_feature_list()
	return GLOB.tails_list_human

/obj/item/organ/external/tail/monkey
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/monkey

///Monkey tail bodypart overlay
/datum/bodypart_overlay/mutant/tail/monkey
	color_source = NONE
	feature_key = "tail_monkey"

/obj/item/organ/external/tail/lizard
	name = "lizard tail"
	desc = "A severed lizard tail. Somewhere, no doubt, a lizard hater is very pleased with themselves."
	preference = "feature_lizard_tail"

	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/lizard

	wag_flags = WAG_ABLE
	///A reference to the paired_spines, since for some fucking reason tail spines are tied to the spines themselves.
	var/obj/item/organ/external/spines/paired_spines

/obj/item/organ/external/tail/lizard/Insert(mob/living/carbon/reciever, special, drop_if_replaced)
	. = ..()
	if(.)
		paired_spines = ownerlimb.owner.get_organ_slot(ORGAN_SLOT_EXTERNAL_SPINES)
		paired_spines?.paired_tail = src

/obj/item/organ/external/tail/lizard/Remove(mob/living/carbon/organ_owner, special, moving)
	. = ..()
	if(paired_spines)
		paired_spines.paired_tail = null
		paired_spines = null

/obj/item/organ/external/tail/lizard/start_wag()
	. = ..()

	if(paired_spines)
		var/datum/bodypart_overlay/mutant/spines/accessory = paired_spines.bodypart_overlay
		accessory.wagging = TRUE

/obj/item/organ/external/tail/lizard/stop_wag()
	. = ..()

	if(paired_spines)
		var/datum/bodypart_overlay/mutant/spines/accessory = paired_spines.bodypart_overlay
		accessory.wagging = FALSE

///Lizard tail bodypart overlay datum
/datum/bodypart_overlay/mutant/tail/lizard
	feature_key = "tail_lizard"

/datum/bodypart_overlay/mutant/tail/lizard/get_global_feature_list()
	return GLOB.tails_list_lizard

/obj/item/organ/external/tail/lizard/fake
	name = "fabricated lizard tail"
	desc = "A fabricated severed lizard tail. This one's made of synthflesh. Probably not usable for lizard wine."
