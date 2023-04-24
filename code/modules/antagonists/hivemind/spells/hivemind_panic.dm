/obj/effect/proc_holder/spell/targeted/induce_panic
	name = "Induce Panic"
	desc = "We unleash a burst of psionic energy, inducing a debilitating fear in those around us and reducing their combat readiness. We can also briefly affect silicon-based life with this burst."
	panel = "Hivemind Abilities"
	charge_max = 900
	range = 7
	invocation_type = INVOCATION_NONE
	clothes_req = 0
	max_targets = 0
	antimagic_allowed = TRUE
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "panic"

/obj/effect/proc_holder/spell/targeted/induce_panic/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	for(var/mob/living/carbon/human/target in targets)
		if(target.stat == DEAD)
			continue
		target.Jitter(14)
		target.apply_damage(35 + rand(0,15), STAMINA, target.get_bodypart(BODY_ZONE_HEAD))
		if(IS_HIVEHOST(target))
			continue
		if(prob(20))
			var/text = pick(";HELP!","I'm losing control of the situation!!","Get me outta here!")
			target.say(text, forced = "panic")
		var/effect = rand(1,4)
		switch(effect)
			if(1)
				to_chat(target, "<span class='userdanger'>You panic and drop everything to the ground!</span>")
				target.drop_all_held_items()
			if(2)
				to_chat(target, "<span class='userdanger'>You panic and flail around!</span>")
				target.click_random_mob()
				addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, click_random_mob)), 5)
				addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, click_random_mob)), 10)
				addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, click_random_mob)), 15)
				addtimer(CALLBACK(target, TYPE_PROC_REF(/mob, click_random_mob)), 20)
				addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living, Stun), 30), 25)
				target.confused += 10
			if(3)
				to_chat(target, "<span class='userdanger'>You freeze up in fear!</span>")
				target.Stun(30)
			if(4)
				to_chat(target, "<span class='userdanger'>You feel nauseous as dread washes over you!</span>")
				target.Dizzy(15)
				target.apply_damage(30, STAMINA, target.get_bodypart(BODY_ZONE_HEAD))
				target.hallucination += 45

	for(var/mob/living/silicon/target in targets)
		target.Unconscious(50)
