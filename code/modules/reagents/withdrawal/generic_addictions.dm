///Opiods
/datum/addiction/opiods
	name = "opiod"
	withdrawal_stage_messages = list("I feel aches in my bodies..", "I need some pain relief...", "It aches all over...I need some opiods!")

/datum/addiction/opiods/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(DT_PROB(10, delta_time))
		affected_carbon.emote("yawn")

/datum/addiction/opiods/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(STATUS_EFFECT_HIGHBLOODPRESSURE)

/datum/addiction/opiods/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(affected_carbon.disgust < DISGUST_LEVEL_DISGUSTED && DT_PROB(7.5, delta_time))
		affected_carbon.adjust_disgust(12.5 * delta_time)


/datum/addiction/opiods/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.remove_status_effect(STATUS_EFFECT_HIGHBLOODPRESSURE)
	affected_carbon.set_disgust(affected_carbon.disgust * 0.5) //half their disgust to help

///Stimulants

/datum/addiction/stimulants
	name = "stimulant"
	withdrawal_stage_messages = list("You feel a bit tired...You could really use a pick me up.", "You are getting a bit woozy...", "So...Tired...")

/datum/addiction/stimulants/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.add_actionspeed_modifier(/datum/actionspeed_modifier/stimulants)

/datum/addiction/stimulants/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(STATUS_EFFECT_WOOZY)

/datum/addiction/stimulants/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.add_movespeed_modifier(MOVESPEED_ID_STIMULANTS, TRUE, 100, override=TRUE, multiplicative_slowdown=1, movetypes=GROUND)

/datum/addiction/stimulants/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.remove_actionspeed_modifier(ACTIONSPEED_ID_STIMULANTS)
	affected_carbon.remove_status_effect(STATUS_EFFECT_WOOZY)
	affected_carbon.remove_movespeed_modifier(MOVESPEED_ID_STIMULANTS)

///Alcohol
/datum/addiction/alcohol
	name = "alcohol"
	withdrawal_stage_messages = list("I could use a drink...", "Maybe the bar is still open?..", "God I need a drink!")

/datum/addiction/alcohol/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.Jitter(5 * delta_time)

/datum/addiction/alcohol/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.Jitter(10 * delta_time)
	affected_carbon.hallucination = max(5 SECONDS, affected_carbon.hallucination)

/datum/addiction/alcohol/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.Jitter(15 * delta_time)
	affected_carbon.hallucination = max(5 SECONDS, affected_carbon.hallucination)
	if(DT_PROB(4, delta_time))
		if(!HAS_TRAIT(affected_carbon, TRAIT_ANTICONVULSANT))
			affected_carbon.apply_status_effect(STATUS_EFFECT_SEIZURE)

/datum/addiction/hallucinogens
	name = "hallucinogen"
	withdrawal_stage_messages = list("I feel so empty...", "I wonder what the machine elves are up to?..", "I need to see the beautiful colors again!!")

/datum/addiction/hallucinogens/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_carbon.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.add_filter("hallucinogen_wave", 10, wave_filter(300, 300, 3, 0, WAVE_SIDEWAYS))
	game_plane_master_controller.add_filter("hallucinogen_blur", 10, angular_blur_filter(0, 0, 3))


/datum/addiction/hallucinogens/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.apply_status_effect(/datum/status_effect/trance, 40 SECONDS, TRUE)

/datum/addiction/hallucinogens/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	var/atom/movable/plane_master_controller/game_plane_master_controller = affected_carbon.hud_used.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter("hallucinogen_blur")
	game_plane_master_controller.remove_filter("hallucinogen_wave")
	affected_carbon.remove_status_effect(/datum/status_effect/trance, 40 SECONDS, TRUE)

/datum/addiction/maintenance_drugs
	name = "maintenance drug"
	withdrawal_stage_messages = list("", "", "")

/datum/addiction/maintenance_drugs/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.hal_screwyhud = SCREWYHUD_HEALTHY

/datum/addiction/maintenance_drugs/withdrawal_stage_1_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	if(DT_PROB(7.5, delta_time))
		affected_carbon.emote("growls")

/datum/addiction/maintenance_drugs/withdrawal_enters_stage_2(mob/living/carbon/affected_carbon)
	. = ..()
	if(!ishuman(affected_carbon))
		return
	var/mob/living/carbon/human/affected_human = affected_carbon
	if(affected_human.gender == MALE)
		to_chat(affected_human, "<span class='warning'>Your chin itches.</span>")
		affected_human.facial_hair_style = "Beard (Full)"
		affected_human.update_hair()
	//Only like gross food
	affected_human.dna?.species.liked_food = GROSS
	affected_human.dna?.species.disliked_food = NONE
	affected_human.dna?.species.toxic_food = ~GROSS

/datum/addiction/maintenance_drugs/withdrawal_enters_stage_3(mob/living/carbon/affected_carbon)
	. = ..()
	if(!ishuman(affected_carbon))
		return

	to_chat(affected_carbon, "<span class='warning'>You feel yourself adapt to the darkness.</span>")
	var/mob/living/carbon/human/affected_human = affected_carbon

	var/obj/item/organ/eyes/empowered_eyes = affected_human.getorgan(/obj/item/organ/eyes)
	if(empowered_eyes)
		ADD_TRAIT(affected_human, TRAIT_NIGHT_VISION, "maint_drug_addiction")
		empowered_eyes?.refresh()

/datum/addiction/maintenance_drugs/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	if(!ishuman(affected_carbon))
		return
	var/mob/living/carbon/human/affected_human = affected_carbon
	var/turf/T = get_turf(affected_human)
	var/lums = T.get_lumcount()
	if(lums > 0.5)
		SEND_SIGNAL(affected_human, COMSIG_ADD_MOOD_EVENT, "too_bright", /datum/mood_event/bright_light)
		affected_human.dizziness = min(40, affected_human.dizziness + 3)
		affected_human.confused = (min(affected_human.confused + (0.5 * delta_time), 20))
	else
		SEND_SIGNAL(affected_carbon, COMSIG_CLEAR_MOOD_EVENT, "too_bright")

/datum/addiction/maintenance_drugs/end_withdrawal(mob/living/carbon/affected_carbon)
	. = ..()
	affected_carbon.hal_screwyhud = SCREWYHUD_NONE
	if(!ishuman(affected_carbon))
		return
	var/mob/living/carbon/human/affected_human = affected_carbon
	affected_human.dna?.species.liked_food = initial(affected_human.dna?.species.liked_food)
	affected_human.dna?.species.disliked_food = initial(affected_human.dna?.species.disliked_food)
	affected_human.dna?.species.toxic_food = initial(affected_human.dna?.species.toxic_food)
	REMOVE_TRAIT(affected_human, TRAIT_NIGHT_VISION, "maint_drug_addiction")
	var/obj/item/organ/eyes/eyes = affected_human.getorgan(/obj/item/organ/eyes)
	eyes.refresh()

///Nicotine
/datum/addiction/nicotine
	name = "nicotine"
	addiction_relief_treshold = MIN_NICOTINE_ADDICTION_REAGENT_AMOUNT //much less because your intake is probably from ciggies
	withdrawal_stage_messages = list("Feel like having a smoke...", "Getting antsy. Really need a smoke now.", "I can't take it! Need a smoke NOW!")

	medium_withdrawal_moodlet = /datum/mood_event/nicotine_withdrawal_moderate
	severe_withdrawal_moodlet = /datum/mood_event/nicotine_withdrawal_severe

/datum/addiction/nicotine/withdrawal_enters_stage_1(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.Jitter(5 * delta_time)

/datum/addiction/nicotine/withdrawal_stage_2_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.Jitter(10 * delta_time)
	if(DT_PROB(10, delta_time))
		affected_carbon.emote("cough")

/datum/addiction/nicotine/withdrawal_stage_3_process(mob/living/carbon/affected_carbon, delta_time)
	. = ..()
	affected_carbon.Jitter(15 * delta_time)
	if(DT_PROB(15, delta_time))
		affected_carbon.emote("cough")
