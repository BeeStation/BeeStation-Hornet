/obj/effect/proc_holder/spell/self/hive_drain
	name = "Repair Protocol"
	desc = "Our many vessels sacrifice a small portion of their mind's vitality to cure us of our physical and mental ailments."

	panel = "Hivemind Abilities"
	charge_max = 600
	clothes_req = 0
	invocation_type = INVOCATION_NONE
	action_icon = 'icons/mob/actions/actions_hive.dmi'
	action_background_icon_state = "bg_hive"
	action_icon_state = "drain"
	human_req = 1
	antimagic_allowed = TRUE

/obj/effect/proc_holder/spell/self/hive_drain/cast(mob/living/carbon/human/user)
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	if(!hive || !hive.hivemembers)
		return
	var/iterations = 0
	var/list/carbon_members = hive.get_carbon_members()
	if(!carbon_members.len)
		return
	if(!user.getBruteLoss() && !user.getFireLoss() && !user.getCloneLoss() && !user.getOrganLoss(ORGAN_SLOT_BRAIN))
		to_chat(user, "<span class='notice'>We cannot heal ourselves any more with this power!</span>")
		revert_cast()
	to_chat(user, "<span class='notice'>We begin siphoning power from our many vessels!</span>")
	while(iterations < 7)
		var/mob/living/carbon/target = pick(carbon_members)
		if(!do_after(user, 15, user, timed_action_flags = IGNORE_HELD_ITEM))
			to_chat(user, "<span class='warning'>Our concentration has been broken!</span>")
			break
		if(!target)
			to_chat(user, "<span class='warning'>We have run out of vessels to drain.</span>")
			break
		if(target.getOrganLoss(ORGAN_SLOT_BRAIN) < 50)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
		if(user.getBruteLoss() > user.getFireLoss())
			user.heal_ordered_damage(5, list(CLONE, BRUTE, BURN))
		else
			user.heal_ordered_damage(5, list(CLONE, BURN, BRUTE))
		if(!user.getBruteLoss() && !user.getFireLoss() && !user.getCloneLoss()) //If we don't have any of these, stop looping
			to_chat(user, "<span class='warning'>We finish our healing.</span>")
			break
		iterations++
	user.setOrganLoss(ORGAN_SLOT_BRAIN, 0)
