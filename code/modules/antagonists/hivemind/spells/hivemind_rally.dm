/obj/effect/proc_holder/spell/targeted/hive_rally
	name = "Hive Rythms"
	desc = "We send out a burst of psionic energy, invigorating us and nearby awakened vessels, removing any stuns."
	panel = "Hivemind Abilities"
	charge_max = 3000
	range = 7
	invocation_type = "none"
	clothes_req = 0
	max_targets = 0
	include_user = 1
	antimagic_allowed = TRUE
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "rally"

/obj/effect/proc_holder/spell/targeted/hive_rally/cast(list/targets, mob/living/user = usr)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!targets)
		to_chat(user, "<span class='notice'>Nobody is in sight, it'd be a waste to do that now.</span>")
		revert_cast()
		return
	var/list/victims = list()
	for(var/mob/living/target in targets)
		if(IS_HIVEHOST(target))
			victims += target
		var/datum/mind/mind = target.mind
		if(mind in hive.avessels)
			victims += target
		flash_color(target, flash_color="#800080", flash_time=10)
	for(var/mob/living/carbon/affected in victims)
		to_chat(affected, "<span class='assimilator'>Otherworldly strength flows through us!</span>")
		affected.SetSleeping(0)
		affected.SetUnconscious(0)
		affected.SetStun(0)
		affected.SetKnockdown(0)
		affected.SetImmobilized(0)
		affected.SetParalyzed(0)
		affected.adjustStaminaLoss(-200)
