/obj/effect/proc_holder/spell/targeted/intent_changer
	name = "Meme Mentality"
	desc = "Targets all people in your view and change their intent into yours, and locks their intent for 15 seconds."
	school = "enchantment"
	charge_type = "recharge"
	charge_max = 45 SECONDS
	cooldown_min = 25 SECONDS
	level_max = 3 // 1 to 4 lvls
	invocation = "NAL'DDARA HEBOA"
	invocation_type = "shout"
	clothes_req = FALSE
	stat_allowed = FALSE

	range = 9
	selection_type = "view"
	max_targets = 0

	action_icon_state = "meme_mentality"
	var/spell_duration = 15 SECONDS
	var/static/processing = FALSE
	var/static/list/current_victims = list()
	var/static/list/victim_duration = list() // key=value doesn't work here.
	var/static/obj/effect/proc_holder/spell/targeted/intent_changer/dummy/dummy = new /obj/effect/proc_holder/spell/targeted/intent_changer/dummy

/obj/effect/proc_holder/spell/targeted/intent_changer/cast(list/targets, mob/user = usr)
	for(var/mob/living/H in targets)
		if(H.anti_magic_check() || H?.mind?.holy_role || HAS_TRAIT(H, TRAIT_WARDED))
			to_chat(H, "<span class='notice'>You notice a holy power protected you from a bizarre urge to change your intent.</span>")
		else
			addtimer(CALLBACK(H, /mob/verb/a_intent_change, user.a_intent, TRUE), 1)
			add_victim(H)


/obj/effect/proc_holder/spell/targeted/intent_changer/proc/add_victim(mob/victim)
	for(var/i in 1 to length(current_victims))
		if(current_victims[i] == victim)
			victim_duration[i] += spell_duration
			return
	current_victims += victim
	victim_duration += spell_duration
	dummy.process_on()

/obj/effect/proc_holder/spell/targeted/intent_changer/proc/free_victim(mob/victim)
	var/current_i = 0
	// `for(var/i in 1 to length(victims))` doesn't work here because you're removing list while accessing it. Don't change this code unless you know it well.
	while(current_i++ < length(current_victims))
		if(current_victims[current_i] == victim)
			victim_duration.Remove(victim_duration[current_i])
			current_victims.Remove(current_victims[current_i])
			REMOVE_TRAIT(victim, TRAIT_INTENT_LOCKED, MAGIC_TRAIT)
			current_i--
	if(!length(current_victims))
		dummy.process_off()

// process() should be seperated. `intent_changer/process` is already used to recharge
// Since we have `current_victims` static, managing it here is easier
/obj/effect/proc_holder/spell/targeted/intent_changer/dummy/process(delta_time)
	if(processing)
		var/current_i = 0
		while(current_i++ < length(current_victims))
			var/mob/living/L = current_victims[current_i]
			if(istype(L, /mob/living))
				ADD_TRAIT(L, TRAIT_INTENT_LOCKED, MAGIC_TRAIT)
				victim_duration[current_i] -= delta_time * 10
				if(victim_duration[current_i] <= 0)
					free_victim(current_victims[current_i])
					current_i--


/obj/effect/proc_holder/spell/targeted/intent_changer/dummy/proc/process_on()
	if(!processing)
		START_PROCESSING(SSfastprocess, src)
		processing = TRUE

/obj/effect/proc_holder/spell/targeted/intent_changer/dummy/proc/process_off()
	if(processing)
		STOP_PROCESSING(SSfastprocess, src)
		processing = FALSE
