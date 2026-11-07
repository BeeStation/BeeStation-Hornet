GLOBAL_LIST_INIT(admin_objective_list, generate_admin_objective_list())

// Ideally this would be all of them but laziness and unusual subtypes
/proc/generate_admin_objective_list()
	var/list/allowed_types = list()
	for(var/datum/objective/objective as anything in valid_subtypesof(/datum/objective))
		if(!objective::admin_grantable)
			continue
		allowed_types[objective::name] = objective

	return sort_list(allowed_types, GLOBAL_PROC_REF(cmp_typepaths_asc))

//Created by admin tools
/datum/objective/custom
	name = "custom"
	admin_grantable = TRUE

/datum/objective/custom/admin_edit(mob/admin)
	var/input = tgui_input_text(admin, "Custom objective:", "Objective", explanation_text)
	if(!input) // no input so we return
		to_chat(admin, span_warning("You need to enter something!"))
		return
	explanation_text = input
