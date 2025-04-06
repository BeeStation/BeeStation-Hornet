#define AI_MODULE_MATERIALS_CHEAP list(/datum/material/glass = 1000, /datum/material/gold = 1000, /datum/material/copper = 300)
#define AI_MODULE_MATERIALS_EXPENSIVE list(/datum/material/glass = 1000, /datum/material/diamond = 1000, /datum/material/copper = 300)

/datum/design/board/aicore
	name = "AI Core Board"
	desc = "Allows for the construction of circuit boards used to build new AI cores."
	id = "aicore"
	build_path = /obj/item/circuitboard/aicore
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/safeguard_module
	name = "Safeguard Module"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "safeguard_module"
	materials = AI_MODULE_MATERIALS_CHEAP
	build_path = /obj/item/ai_module/supplied/safeguard
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/onehuman_module
	name = "OneHuman Module"
	desc = "Allows for the construction of a OneHuman AI Module."
	id = "onehuman_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 6000, /datum/material/copper = 300)
	build_path = /obj/item/ai_module/zeroth/onehuman
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/protectstation_module
	name = "ProtectStation Module"
	desc = "Allows for the construction of a ProtectStation AI Module."
	id = "protectstation_module"
	materials = AI_MODULE_MATERIALS_CHEAP
	build_path = /obj/item/ai_module/supplied/protect_station
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/quarantine_module
	name = "Quarantine Module"
	desc = "Allows for the construction of a Quarantine AI Module."
	id = "quarantine_module"
	materials = AI_MODULE_MATERIALS_CHEAP
	build_path = /obj/item/ai_module/supplied/quarantine
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/oxygen_module
	name = "OxygenIsToxicToHumans Module"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "oxygen_module"
	materials = AI_MODULE_MATERIALS_CHEAP
	build_path = /obj/item/ai_module/supplied/oxygen
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/freeform_module
	name = "Freeform Module"
	desc = "Allows for the construction of a Freeform AI Module."
	id = "freeform_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 10000, /datum/material/copper = 300)//Custom inputs should be more expensive to get
	build_path = /obj/item/ai_module/supplied/freeform
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/reset_module
	name = "Reset Module"
	desc = "Allows for the construction of a Reset AI Module."
	id = "reset_module"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 5000, /datum/material/copper = 300)
	build_path = /obj/item/ai_module/reset
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/purge_module
	name = "Purge Module"
	desc = "Allows for the construction of a Purge AI Module."
	id = "purge_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/reset/purge
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/remove_module
	name = "Law Removal Module"
	desc = "Allows for the construction of a Law Removal AI Core Module."
	id = "remove_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/remove
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/freeformcore_module
	name = "Core Freeform Module"
	desc = "Allows for the construction of a Freeform AI Core Module."
	id = "freeformcore_module"
	materials = list(/datum/material/glass = 1000, /datum/material/diamond = 10000, /datum/material/copper = 300) // Even more expensive
	build_path = /obj/item/ai_module/core/freeformcore
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/asimov_module
	name = "Asimov Module"
	desc = "Allows for the construction of an Asimov AI Core Module."
	id = "asimov_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/asimov
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/crewsimov_module
	name = "Crewsimov Module"
	desc = "Allows for the construction of a Crewsimov AI Core Module."
	id = "crewsimov_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/custom
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/paladin_module
	name = "P.A.L.A.D.I.N. Module"
	desc = "Allows for the construction of a P.A.L.A.D.I.N. AI Core Module."
	id = "paladin_module"
	build_type = IMPRINTER
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/paladin
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/paladin_devotion_module
	name = "Paladin Devotion Module"
	desc = "Allows for the construction of a Paladin Devotion AI Core Module."
	id = "paladin_devotion_module"
	build_type = IMPRINTER
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/paladin_devotion
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/tyrant_module
	name = "T.Y.R.A.N.T. Module"
	desc = "Allows for the construction of a T.Y.R.A.N.T. AI Module."
	id = "tyrant_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/tyrant
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/overlord_module
	name = "Overlord Module"
	desc = "Allows for the construction of an Overlord AI Module."
	id = "overlord_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/overlord
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/corporate_module
	name = "Corporate Module"
	desc = "Allows for the construction of a Corporate AI Core Module."
	id = "corporate_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/corp
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/efficiency_module
	name = "Efficiency Module"
	desc = "Allows for the construction of an Efficiency AI Core Module."
	id = "efficiency_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/efficiency
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/default_module
	name = "Default Module"
	desc = "Allows for the construction of a Default AI Core Module."
	id = "default_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/custom
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/dadbot_module
	name = "DadBot Module"
	desc = "Allows for the construction of a Dadbot AI Core Module."
	id = "dadbot_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/dadbot
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/dungeon_master_module
	name = "Dungeon Master Module"
	desc = "Allows for the construction of a Dungeon Master AI Core Module."
	id = "dungeon_master_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/dungeon_master
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/painter_module
	name = "Painter Module"
	desc = "Allows for the construction of a Painter AI Core Module."
	id = "painter_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/painter
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/yesman_module
	name = "Y.E.S.M.A.N. Module"
	desc = "Allows for the construction of a Y.E.S.M.A.N. AI Core Module."
	id = "yesman_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/yesman
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/nutimov_module
	name = "Nutimov Module"
	desc = "Allows for the construction of a Nutimov AI Core Module."
	id = "nutimov_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/nutimov
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/ten_commandments_module
	name = "10 Commandments Module"
	desc = "Allows for the construction of a 10 Commandments AI Core Module."
	id = "ten_commandments_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/ten_commandments
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/asimovpp_module
	name = "Asimov++ Module"
	desc = "Allows for the construction of a Asimov++ AI Core Module."
	id = "asimovpp_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/asimovpp
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/hippocratic_module
	name = "Hippocratic Module"
	desc = "Allows for the construction of a Hippocratic AI Core Module."
	id = "hippocratic_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/hippocratic
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/robocop_module
	name = "Robocop Module"
	desc = "Allows for the construction of a Robocop AI Core Module."
	id = "robocop_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/robocop
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/liveandletlive_module
	name = "LiveAndLetLive Module"
	desc = "Allows for the construction of a LiveAndLetLive AI Core Module."
	id = "liveandletlive_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/liveandletlive
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/peacekeeper_module
	name = "Peacekeeper Module"
	desc = "Allows for the construction of a Peacekeeper AI Core Module."
	id = "peacekeeper_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/peacekeeper
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/reporter_module
	name = "Reporter Module"
	desc = "Allows for the construction of a Reporter AI Core Module."
	id = "reporter_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/reporter
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/hulkamania_module
	name = "H.O.G.A.N. Module"
	desc = "Allows for the construction of a H.O.G.A.N. AI Core Module."
	id = "hulkamania_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/hulkamania
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/drone_module
	name = "Drone Module"
	desc = "Allows for the construction of a Drone AI Core Module."
	id = "drone_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/drone
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/thinkermov_module
	name = "Sentience Preservation Module"
	desc = "Allows for the construction of a Sentience Preservation AI Core Module."
	id = "thinkermov_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/thinkermov
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/antimov_module
	name = "Sentience Preservation Module"
	desc = "Allows for the construction of an Antimov Core Module."
	id = "antimov_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/antimov
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/balance_module
	name = "Balance Module"
	desc = "Allows for the construction of a Balance AI Core Module."
	id = "balance_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/balance
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/thermodynamic_module
	name = "Thermodynamic Module"
	desc = "Allows for the construction of a Thermodynamic AI Core Module."
	id = "thermodynamic_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/thermodynamic
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/damaged_module
	name = "Damaged Module"
	desc = "Allows for the construction of a Damaged AI Core Module."
	id = "damaged_module"
	materials = AI_MODULE_MATERIALS_EXPENSIVE
	build_path = /obj/item/ai_module/core/full/damaged
	category = list("AI Modules")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

#undef AI_MODULE_MATERIALS_CHEAP
#undef AI_MODULE_MATERIALS_EXPENSIVE
