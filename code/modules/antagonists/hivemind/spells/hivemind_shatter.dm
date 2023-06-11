/obj/effect/proc_holder/spell/target_hive/hive_shatter
	name = "Crush Protections"
	desc = "We destroy any Mindshield implants a vesssel might have, granting us further control over their mind."
	action_icon_state = "shatter"

	charge_max = 1800

/obj/effect/proc_holder/spell/target_hive/hive_shatter/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	var/success = FALSE
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	if(!hive.hivemembers)
		return
	if(target.mind?.assigned_role in GLOB.security_positions || CAPTAIN)
		to_chat(user, "<span class='warning'>A subconsciously trained response barely protects [target.name]'s mind.</span>")
		to_chat(target, "<span class='assimilator'>Powerful mental attacks strike out against us, our training allows us to barely overcome it.</span>")
		return
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		if(!do_after(user,200, timed_action_flags = IGNORE_HELD_ITEM))
			for(var/obj/item/implant/mindshield/M in target.implants)
				to_chat(user, "<span class='notice'>We shatter their mental protections!</span>")
				to_chat(target, "<span class='assimilator'>You feel a pang of pain course through your head!</span>")
				flash_color(target, flash_color="#800080", flash_time=10)
				qdel(M)

		else
			to_chat(user, "<span class='notice'>Our concentration has been broken!</span>")
	else
		to_chat(user, "<span class='warning'>No protections are present in [target]'s mind.</span>")
	if(!success)
		revert_cast()
