/datum/antagonist/hivemind/proc/add_hive_overlay/(mob/living/carbon/human/target) //for when someone is assimilated, so hive host can keep track properly
	var/mob/living/carbon/human/host = owner.current
	if(is_carbon_member(target))
		var/I = image('icons/misc/hivemind_images.dmi', loc = target, icon_state = "member")
		host.client.images += I

/datum/antagonist/hivemind/proc/add_hive_overlay_probe/(mob/living/carbon/human/target) //for when hive host probes someone who is in another hive
	var/mob/living/carbon/human/host = owner.current
	var/I = image('icons/misc/hivemind_images.dmi', loc = target, icon_state = "enemy")
	host.client.images += I

/datum/antagonist/hivemind/proc/remove_hive_overlay/(mob/living/carbon/human/target)
	var/mob/living/carbon/human/host = owner.current
	for(var/image/I in host.client.images)
		if(I.loc == target && I.icon == 'icons/misc/hivemind_images.dmi')
			host.client.images -= I
			qdel(I)

/datum/antagonist/hivemind/proc/remove_hive_overlay_probe/(mob/living/carbon/human/target)
	var/mob/living/carbon/human/host = owner.current
	for(var/image/I in host.client.images)
		if(I.loc == target && I.icon == 'icons/misc/hivemind_images.dmi' && I.icon_state == "enemy")
			host.client.images -= I
			qdel(I)

/datum/antagonist/hivemind/proc/regain_images()
	var/mob/living/carbon/human/host = owner.current
	for(var/datum/mind/mind as() in hivemembers)
		var/I = image('icons/misc/hivemind_images.dmi', loc = mind.current, icon_state = "member")
		host.client.images += I
