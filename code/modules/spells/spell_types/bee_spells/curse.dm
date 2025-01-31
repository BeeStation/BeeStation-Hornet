GLOBAL_VAR_INIT(curse_of_madness_triggered, FALSE)

/proc/curse_of_madness(mob/user, message)
	if(user) //in this case either someone holding a spellbook or a badmin
		to_chat(user, span_warning("You sent a curse of madness with the message \"[message]\"!"))
		message_admins("[ADMIN_LOOKUPFLW(user)] sent a curse of madness with the message \"[message]\"!")
		log_game("[key_name(user)] sent a curse of madness with the message \"[message]\"!")

	GLOB.curse_of_madness_triggered = message // So latejoiners are also afflicted.

	deadchat_broadcast(span_deadsay("A [span_name("Curse of Madness")] has stricken the station, shattering their minds with the awful secret: \"[span_bighypnophrase("[message]")]\""))

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD)
			continue
		var/turf/T = get_turf(H)
		if(T && !is_station_level(T.z))
			continue
		if(H.can_block_magic(MAGIC_RESISTANCE))
			to_chat(H, span_notice("You have a strange feeling for a moment, but then it passes."))
			continue
		if(istype(H.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
			to_chat(H, span_warning("Your protective headgear successfully deflects mind controlling brainwaves!"))
			continue
		give_madness(H, message)

/proc/give_madness(mob/living/carbon/human/H, message)
	H.playsound_local(H,'sound/magic/curse.ogg',40,1)
	to_chat(H, span_reallybighypnophrase("[message]"))
	to_chat(H, span_warning("Your mind shatters!"))
	switch(rand(1,10))
		if(1 to 3)
			H.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_LOBOTOMY)
			H.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_LOBOTOMY)
		if(4 to 6)
			H.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
		if(7 to 8)
			H.gain_trauma_type(BRAIN_TRAUMA_MAGIC, TRAUMA_RESILIENCE_LOBOTOMY)
		if(9 to 10)
			H.gain_trauma_type(BRAIN_TRAUMA_SPECIAL, TRAUMA_RESILIENCE_LOBOTOMY)
