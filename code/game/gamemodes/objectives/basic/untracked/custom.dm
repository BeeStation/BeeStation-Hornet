//Created by admin tools
/datum/objective/custom
	name = "custom"

/datum/objective/custom/admin_edit(mob/admin)
	var/expl = tgui_input_text(admin, "Custom objective:", "Objective", explanation_text)
	if(!expl) // no input so we return
		to_chat(admin, span_warning("You need to enter something!"))
		return
	explanation_text = expl

//Ideally this would be all of them but laziness and unusual subtypes
/proc/generate_admin_objective_list()
	GLOB.admin_objective_list = list()

	var/list/allowed_types = sort_list(list(
		/datum/objective/assassinate,
		/datum/objective/maroon,
		/datum/objective/debrain,
		/datum/objective/protect,
		/datum/objective/destroy,
		/datum/objective/hijack,
		/datum/objective/escape,
		/datum/objective/survive,
		/datum/objective/martyr,
		/datum/objective/steal,
		/datum/objective/download,
		/datum/objective/nuclear,
		/datum/objective/capture,
		/datum/objective/absorb,
		/datum/objective/custom
	),/proc/cmp_typepaths_asc)

	for(var/datum/objective/X as() in allowed_types)
		GLOB.admin_objective_list[initial(X.name)] = X
