/datum/objective/download
	name = "download"
	admin_grantable = TRUE

	var/amount = 0

/datum/objective/download/proc/gen_amount_goal()
	target_amount = rand(20,40)
	update_explanation_text()
	return target_amount

/datum/objective/download/update_explanation_text()
	..()
	explanation_text = "Download [target_amount] research node\s."

/datum/objective/download/check_completion()
	var/datum/techweb/checking = new
	for(var/datum/mind/owner as anything in get_owners())
		if(!ismob(owner.current))
			continue
		var/mob/mob_owner = owner.current //Yeah if you get morphed and you eat a quantum tech disk with the RD's latest backup good on you soldier.

		if(ishuman(mob_owner))
			var/mob/living/carbon/human/human_owner = mob_owner
			// Check ninja MODsuit internal tech disk
			if(human_owner.stat != DEAD && istype(human_owner.back, /obj/item/mod/control/pre_equipped/ninja))
				var/obj/item/mod/control/pre_equipped/ninja/ninja_suit = human_owner.back
				if(ninja_suit.internal_techdisk)
					checking.absorb_techdisk(ninja_suit.internal_techdisk)

		for(var/obj/item/disk/tech_disk/disk_in_us in mob_owner.GetAllContents())
			checking.absorb_techdisk(disk_in_us)

	amount = length(checking.researched_nodes)
	qdel(checking)
	return (amount >= target_amount) || ..()

/datum/objective/download/admin_edit(mob/admin)
	var/count = input(admin,"How many nodes ?","Nodes",target_amount) as num|null
	if(count)
		target_amount = count
	update_explanation_text()

/datum/objective/download/get_completion_message()
	var/span = check_completion() ? "grentext" : "redtext"
	return "[explanation_text] <span class='[span]'>[amount] research node\s downloaded!</span>"
