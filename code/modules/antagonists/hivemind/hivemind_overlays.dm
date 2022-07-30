/datum/antagonist/hivemind/proc/add_hive_overlay/(mob/living/carbon/human/target)
	var/mob/living/carbon/human/host = owner.current
	if(is_carbon_member(target))
		var/I = image('icons/misc/hivemind_images.dmi', loc = target, icon_state = "member")
		host.client.images += I

/datum/antagonist/hivemind/proc/add_hive_overlay_probe/(mob/living/carbon/human/target)
	var/mob/living/carbon/human/host = owner.current
	var/I = image('icons/misc/hivemind_images.dmi', loc = target, icon_state = "enemy")
	host.client.images += I

/datum/antagonist/hivemind/proc/remove_hive_overlay/(mob/living/carbon/human/target)
	var/mob/living/carbon/human/host = owner.current
	for(var/image/I in host.client.images)
		if(I.loc == target && I.icon == 'icons/misc/hivemind_images.dmi')
			host.client.images -= I
			qdel(I)
