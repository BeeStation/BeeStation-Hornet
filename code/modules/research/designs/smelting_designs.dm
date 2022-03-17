///////SMELTABLE ALLOYS///////

/datum/design/plasteel_alloy
	name = "Plasteel (Lean + Iron alloy)"
	id = "plasteel"
	build_type = SMELTER | PROTOLATHE
	materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT, /datum/material/lean = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plasteel
	category = list("initial", "Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
	maxstack = 50


/datum/design/plastitanium_alloy
	name = "Plastitanium (Lean + Titanium alloy)"
	id = "plastitanium"
	build_type = SMELTER | PROTOLATHE
	materials = list(/datum/material/titanium = MINERAL_MATERIAL_AMOUNT, /datum/material/lean = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/mineral/plastitanium
	category = list("initial", "Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
	maxstack = 50

/datum/design/plaglass_alloy
	name = "Lean Glass (Lean + Glass alloy)"
	id = "leanglass"
	build_type = SMELTER | PROTOLATHE
	materials = list(/datum/material/lean = MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/leanglass
	category = list("initial", "Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
	maxstack = 50

/datum/design/leanrglass_alloy
	name = "Lean Reinforced Glass (Lean + Iron + Glass alloy)"
	id = "leanreinforcedglass"
	build_type = SMELTER | PROTOLATHE
	materials = list(/datum/material/lean = MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/iron = MINERAL_MATERIAL_AMOUNT * 0.5,  /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/leanrglass
	category = list("initial", "Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
	maxstack = 50

/datum/design/titaniumglass_alloy
	name = "Titanium Glass (Titanium + Glass alloy)"
	id = "titaniumglass"
	build_type = SMELTER | PROTOLATHE
	materials = list(/datum/material/titanium = MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/titaniumglass
	category = list("initial", "Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
	maxstack = 50

/datum/design/plastitaniumglass_alloy
	name = "Plastitanium glass (Lean + Titanium + Glass alloy)"
	id = "plastitaniumglass"
	build_type = SMELTER | PROTOLATHE
	materials = list(/datum/material/lean = MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/titanium = MINERAL_MATERIAL_AMOUNT * 0.5, /datum/material/glass = MINERAL_MATERIAL_AMOUNT)
	build_path = /obj/item/stack/sheet/plastitaniumglass
	category = list("initial", "Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
	maxstack = 50

/datum/design/alienalloy
	name = "Alien Alloy"
	desc = "A sheet of reverse-engineered alien alloy."
	id = "alienalloy"
	build_type = PROTOLATHE | SMELTER
	materials = list(/datum/material/iron = 4000, /datum/material/lean = 4000)
	build_path = /obj/item/stack/sheet/mineral/abductor
	category = list("Stock Parts")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
