/// Lists for zones and bodyparts to swap and randomize
#define ANOMALY_BIOSCRAMBLER_ZONES list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
#define ANOMALY_BIOSCRAMBLER_ZONE_CHEST typesof(/obj/item/bodypart/chest)
#define ANOMALY_BIOSCRAMBLER_ZONE_HEAD typesof(/obj/item/bodypart/head)
#define ANOMALY_BIOSCRAMBLER_ZONE_L_LEG typesof(/obj/item/bodypart/l_leg)
#define ANOMALY_BIOSCRAMBLER_ZONE_R_LEG typesof(/obj/item/bodypart/r_leg)
#define ANOMALY_BIOSCRAMBLER_ZONE_L_ARM typesof(/obj/item/bodypart/l_arm)
#define ANOMALY_BIOSCRAMBLER_ZONE_R_ARM typesof(/obj/item/bodypart/r_arm)

/obj/effect/anomaly/bioscrambler
	name = "bioscrambler anomaly"
	icon_state = "bioscrambler_anomaly"
	aSignal = /obj/item/assembly/signaler/anomaly/bioscrambler

	COOLDOWN_DECLARE(pulse_cooldown)
	var/pulse_interval = 15 SECONDS

	var/range = 5

/obj/effect/anomaly/bioscrambler/anomalyEffect(delta_time)
	. = ..()

	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_interval)

	bioscrambler_pulse(src, range)

/proc/bioscrambler_pulse(atom/owner, range = 5, ignore_owner = FALSE, message_admins = FALSE)
	var/list/mob/living/carbon/affected = list()
	for(var/mob/living/carbon/target in range(range, owner))
		if(!ignore_owner && target == owner)
			continue
		if(target.run_armor_check(attack_flag = BIO, absorb_text = "Your armor protects you from [owner]!") >= 100)
			continue //We are protected

		// Add target
		affected += target

		// Replace a random limb
		var/picked_zone = pick(ANOMALY_BIOSCRAMBLER_ZONES)
		var/obj/item/bodypart/picked_user_part = target.get_bodypart(picked_zone)
		if(!picked_user_part)
			return
		var/obj/item/bodypart/picked_part
		switch(picked_zone)
			if(BODY_ZONE_HEAD)
				picked_part = pick(ANOMALY_BIOSCRAMBLER_ZONE_HEAD)
			if(BODY_ZONE_CHEST)
				picked_part = pick(ANOMALY_BIOSCRAMBLER_ZONE_CHEST)
			if(BODY_ZONE_L_ARM)
				picked_part = pick(ANOMALY_BIOSCRAMBLER_ZONE_L_ARM)
			if(BODY_ZONE_R_ARM)
				picked_part = pick(ANOMALY_BIOSCRAMBLER_ZONE_R_ARM)
			if(BODY_ZONE_L_LEG)
				picked_part = pick(ANOMALY_BIOSCRAMBLER_ZONE_L_LEG)
			if(BODY_ZONE_R_LEG)
				picked_part = pick(ANOMALY_BIOSCRAMBLER_ZONE_R_LEG)
		var/obj/item/bodypart/new_part = new picked_part()
		new_part.replace_limb(target, TRUE, is_creating = TRUE)
		qdel(picked_user_part)
		target.update_body(TRUE)
		to_chat(target, "<span class='warning'>Something feels different...</span>")
		log_game("[key_name(owner)] has caused a bioscrambler pulse affecting [english_list(affected)].")
		target.log_message("had their [picked_user_part.type] turned into [new_part.type] by a bioscrambling pulse from [owner].", LOG_ATTACK, color="red")

	if(message_admins)
		message_admins("[ADMIN_LOOKUPFLW(owner)] has caused a bioscrambler pulse affecting [english_list(affected)].")

#undef ANOMALY_BIOSCRAMBLER_ZONES
#undef ANOMALY_BIOSCRAMBLER_ZONE_CHEST
#undef ANOMALY_BIOSCRAMBLER_ZONE_HEAD
#undef ANOMALY_BIOSCRAMBLER_ZONE_L_LEG
#undef ANOMALY_BIOSCRAMBLER_ZONE_R_LEG
#undef ANOMALY_BIOSCRAMBLER_ZONE_L_ARM
#undef ANOMALY_BIOSCRAMBLER_ZONE_R_ARM
