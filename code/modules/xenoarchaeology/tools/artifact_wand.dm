//Turns target into artifact, just a debug tool
/obj/item/artifact_wand
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "staffofnothing"
	item_state = "staff"

/obj/item/artifact_wand/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/datum/component/xenoartifact/X = target.GetComponent(/datum/component/xenoartifact)
	if(!X)
		target.AddComponent(/datum/component/xenoartifact, /datum/xenoartifact_material/pearl, null, TRUE, FALSE)

