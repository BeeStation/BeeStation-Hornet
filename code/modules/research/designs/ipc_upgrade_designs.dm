/datum/design/ipc_upgrade
	name = "Upgrade ( NULL ENTRY )"
	build_type = MECHFAB
	materials = list(/datum/material/glass = 1000, /datum/material/copper = 300)
	construction_time = 75
	category = list(RND_CATEGORY_IPC_UPGRADES)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/ipc_upgrade/repair_nexus
	name = "Repair Nexus"
	desc = "A core upgrade that repairs robotic parts at the cost of energy."
	build_path = /obj/item/ipc_upgrade/repair_nexus
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_CORE)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/plasma = 500, /datum/material/gold = 1000)

/datum/design/ipc_upgrade/emp_shield
	name = "Disposable EMP Shielding"
	desc = "A core upgrade that redirects EMP attacks. It will only survive a few attacks, however."
	build_path = /obj/item/ipc_upgrade/emp_shield
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_CORE)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 2000, /datum/material/gold = 1000)

/datum/design/ipc_upgrade/supply_pack
	name = "Supply Pack"
	desc = "A utility upgrade that installs a very large storage unit on the back of the user. Uniquely, this can store extra large items."
	build_path = /obj/item/ipc_upgrade/supply_pack
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_UTILITY)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 500)

/datum/design/ipc_upgrade/part_fab
	name = "Part Fabricator"
	desc = "A utility upgrade that can fabricate stock parts at will."
	build_path = /obj/item/ipc_upgrade/part_fab
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_UTILITY)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/silver = 250)

/datum/design/ipc_upgrade/medbeam
	name = "Integrated Revival Beam"
	desc = "A utility upgrade that allows the user to generate a beam that heals critical injuries. It cannot heal smaller ones, though."
	build_path = /obj/item/ipc_upgrade/medbeam
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_UTILITY)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/silver = 250, /datum/material/diamond = 500)

/datum/design/ipc_upgrade/overclocked_servos
	name = "Overclocked Servos"
	desc = "A core upgrade that increase the efficiency of movement servos in the user."
	build_path = /obj/item/ipc_upgrade/overclocked_servos
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_CORE)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/gold = 1000, /datum/material/silver = 250, /datum/material/plasma = 500)

/datum/design/ipc_upgrade/tool_speedifier
	name = "Tool Adaptor"
	desc = "A utility upgrade that allows the user to interface with tools more effectively, increasing their speed."
	build_path = /obj/item/ipc_upgrade/tool_speedifier
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_UTILITY)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1000, /datum/material/copper = 500)

/datum/design/ipc_upgrade/leap_legs
	name = "Leap Legs"
	desc = "A utility upgrade that installs powerful hydraulics that allow to user to launch themselves violently."
	build_path = /obj/item/ipc_upgrade/leap_legs
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_UTILITY)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/diamond = 500)

/datum/design/ipc_upgrade/ipc_generator
	name = "Isotope Decay Generator"
	desc = "A core upgrade that installs a small RTG in the user, allowing them to generate trace amounts of power."
	build_path = /obj/item/ipc_upgrade/ipc_generator
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_CORE)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/uranium = 1000)

/datum/design/ipc_upgrade/fuel_generator
	name = "Plasmatic Generator"
	desc = "A core upgrade that installs a small plasma generator in the user, allowing them to generate a decent amount of power. Insert plasma material in the designated port on the user to fuel the generator."
	build_path = /obj/item/ipc_upgrade/fuel_generator
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_CORE)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 1000)

/datum/design/ipc_upgrade/vacuum_shielding
	name = "Vacuum Shielding"
	desc = "An external upgrade that seals joints, protecting them from a vacuum."
	build_path = /obj/item/ipc_upgrade/vacuum_shielding
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_EXTERNAL)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/titanium = 250, /datum/material/silver = 500)

/datum/design/ipc_upgrade/rad_shielding
	name = "Radiation Shielding"
	desc = "An external upgrade that includes lead plating to reduce incoming radiation emissions."
	build_path = /obj/item/ipc_upgrade/rad_shielding
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_EXTERNAL)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/titanium = 250, /datum/material/uranium = 1000)

/datum/design/ipc_upgrade/las_armor
	name = "Ablative Plating"
	desc = "An external upgrade that includes temperature resistant plating, reducing energy weapons and heat based damages."
	build_path = /obj/item/ipc_upgrade/las_armor
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_EXTERNAL)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 2000, /datum/material/titanium = 250, /datum/material/silver = 1000)

/datum/design/ipc_upgrade/ken_armor
	name = "Reactive Plating"
	desc = "An external upgrade that includes hardened plating, reducing ballistic weapons and kinetic based damages."
	build_path = /obj/item/ipc_upgrade/ken_armor
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_EXTERNAL)
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/titanium = 1000, /datum/material/uranium = 1000)

/datum/design/ipc_upgrade/cooling_system
	name = "Cooling System"
	desc = "An external upgrade that includes advanced cooling devices, reducing overall temperature. Does not protect against heat caused by lack of coolant."
	build_path = /obj/item/ipc_upgrade/cooling_system
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 500)
	category = list(RND_SUBCATEGORY_IPC_UPGRADES_EXTERNAL)
