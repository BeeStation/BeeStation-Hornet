/datum/design/bluespace_ass
	name = "Bluespace Posterior"
	desc = "An advanced form of posterior."
	id = "bluespace_ass"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1700, /datum/material/glass = 1350, /datum/material/gold = 500, /datum/material/bluespace = 1000)
	construction_time = 75
	build_path = /obj/item/organ/butt/bluespace
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cyberimp_lighter
	name = "Lighter Arm Implant"
	desc = "A lighter, installed into the subject's arm."
	id = "ci-lighter"
	build_type = PROTOLATHE | MECHFAB
	materials = list (/datum/material/iron = 500, /datum/material/glass = 500, /datum/material/silver = 500)
	construction_time = 100
	build_path = /obj/item/organ/cyberimp/arm/lighter
	category = list("Misc", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE
