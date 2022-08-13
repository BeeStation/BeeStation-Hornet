/obj/effect/proc_holder/spell/targeted/intent_changer
	name = "Meme Mentality"
	desc = "Targets all people in your view and change their intent into yours, and locks their intent for 15 seconds."
	school = "enchantment"
	charge_type = "recharge"
	charge_max	= 40 SECONDS
	cooldown_min = 25 SECONDS
	level_max = 3 // 1 to 4 lvls
	invocation = "MORI'GA ISANGHE"
	invocation_type = "shout"
	clothes_req = FALSE
	stat_allowed = FALSE

	range = 7
	selection_type = "view"
	max_targets = 0

	action_icon_state = "telepathy"
	var/spell_duration = 15 SECONDS
	var/static/list/current_victims = list()
	var/static/list/victim_duration = list() // key=value doesn't work here.

/obj/effect/proc_holder/spell/targeted/intent_changer/cast(list/targets, mob/user = usr)
	if(!length(targets))
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return

	for(var/mob/living/carbon/H in targets)
		if(H.anti_magic_check() || H?.mind?.holy_role || HAS_TRAIT(H, TRAIT_WARDED))
			to_chat(H, "<span class='notice'>You notice a holy power protected you from a bizarre urge to change your intent.</span>")
		else
			addtimer(CALLBACK(H, /mob/verb/a_intent_change, user.a_intent, TRUE), 1)
			add_victim(H)

/obj/effect/proc_holder/spell/targeted/intent_changer/process(delta_time)
	..()
	for(var/i in 1 to length(current_victims))
		var/mob/living/L = current_victims[i]
		ADD_TRAIT(L, TRAIT_INTENT_LOCKED, MAGIC_TRAIT)
		victim_duration[i] -= delta_time * 10
		if(victim_duration[i] <= 0)
			free_victim(current_victims[i])


/obj/effect/proc_holder/spell/targeted/intent_changer/proc/add_victim(mob/victim)
	for(var/i in 1 to length(current_victims))
		if(current_victims[i] == victim)
			victim_duration[i] += spell_duration
			return
	current_victims += victim
	victim_duration += spell_duration

/obj/effect/proc_holder/spell/targeted/intent_changer/proc/free_victim(mob/victim)
	for(var/i in 1 to length(current_victims))
		if(current_victims[i] == victim)
			victim_duration.Remove(victim_duration[i])
			current_victims.Remove(current_victims[i])
			REMOVE_TRAIT(victim, TRAIT_INTENT_LOCKED, MAGIC_TRAIT)
