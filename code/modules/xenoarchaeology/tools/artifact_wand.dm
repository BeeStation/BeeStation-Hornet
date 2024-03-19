//Turns target into artifact, just a debug tool
/obj/item/artifact_wand
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "staffofnothing"
	item_state = "staff"
	///What type of material we're applying
	var/datum/xenoartifact_material/material = /datum/xenoartifact_material/pearl

/obj/item/artifact_wand/interact(mob/user)
	. = ..()
	var/list/possible_materials = subtypesof(/datum/xenoartifact_material)
	material = tgui_input_list(user, "Select artifact material.", "Select Material", possible_materials, /datum/xenoartifact_material/pearl)

/obj/item/artifact_wand/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/datum/component/xenoartifact/X = target.GetComponent(/datum/component/xenoartifact)
	if(!X)
		target.AddComponent(/datum/component/xenoartifact, material, null, TRUE, FALSE)

