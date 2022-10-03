/obj/effect/proc_holder/spell/target_hive/hive_compell
	name = "Compell"
	desc = "We forcefully insert a directive into a vessels mind for a limited time, they'll obey anything short of suicide."
	action_icon_state = "empower"

	charge_max = 10 MINUTES

/obj/effect/proc_holder/spell/target_hive/hive_compell/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/human/target = targets[1]
	var/datum/antagonist/hivemind/hive = user.mind.has_antag_datum(/datum/antagonist/hivemind)
	var/success = FALSE
	if(!hive)
		to_chat(user, "<span class='notice'>This is a bug. Error:HIVE1</span>")
		return
	if(!hive.hivemembers)
		return
	var/directive = stripped_input(user, "What objective do you want to give that vessel?", "Objective")

	if(target.mind && target.client && target.stat != DEAD)
		if((!HAS_TRAIT(target, TRAIT_MINDSHIELD)) && !istype(target.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/foilhat))
			if(!IS_HIVEHOST(target) && !IS_WOKEVESSEL(target))
				target.hive_weak_awaken(directive)
				to_chat(user, "<span class='warning'>We successfully overpower their weak psyche!.</span>")
				success = TRUE
			else
				to_chat(user, "<span class='warning'>Complex mental barriers protect [target.name]'s mind.</span>")
		else
			to_chat(user, "<span class='warning'>Powerful technology protects [target.name]'s mind.</span>")
	else
		to_chat(user, "<span class='notice'>We detect no neural activity in this body.</span>")
	if(!success)
		revert_cast()
