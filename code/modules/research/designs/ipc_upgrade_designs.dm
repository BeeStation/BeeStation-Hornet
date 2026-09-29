/datum/design/ipc_upgrade
	name = "Upgrade ( NULL ENTRY )"
	build_type = MECHFAB
	materials = list(/datum/material/glass = 1000, /datum/material/copper = 300)
	construction_time = 75
	category = list(RND_CATEGORY_UPGRADES)
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/ipc_upgrade/repair_nexus
	name = "Repair Nexus"
	id = "repair_nexus"
	desc = "A core upgrade that repairs robotic parts at the cost of energy."
	build_path = /obj/item/ipc_upgrade/repair_nexus
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/plasma = 500, /datum/material/gold = 1000)

/datum/design/ipc_upgrade/emp_shield
	name = "Disposable EMP Shielding"
	id = "emp_shield"
	desc = "A core upgrade that redirects EMP attacks. It will only survive a few attacks, however."
	build_path = /obj/item/ipc_upgrade/emp_shield
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 2000, /datum/material/gold = 1000)

/datum/design/ipc_upgrade/supply_pack
	name = "Supply Pack"
	id = "supply_pack"
	desc = "A utility upgrade that installs a very large storage unit on the back of the user. Uniquely, this can store extra large items."
	build_path = /obj/item/ipc_upgrade/supply_pack
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 500)

/datum/design/ipc_upgrade/part_fab
	name = "Part Fabricator"
	id = "part_fab"
	desc = "A utility upgrade that can fabricate stock parts at will."
	build_path = /obj/item/ipc_upgrade/part_fab
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/silver = 250)

/datum/design/ipc_upgrade/medbeam
	name = "Integrated Revival Beam"
	id = "medbeam"
	desc = "A utility upgrade that allows the user to generate a beam that heals critical injuries. It cannot heal smaller ones, though."
	build_path = /obj/item/ipc_upgrade/medbeam
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 500, /datum/material/silver = 250, /datum/material/diamond = 500)

/datum/design/ipc_upgrade/overclocked_servos
	name = "Overclocked Servos"
	id = "overclocked_servos"
	desc = "A core upgrade that increase the efficiency of movement servos in the user."
	build_path = /obj/item/ipc_upgrade/overclocked_servos
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/gold = 1000, /datum/material/silver = 250, /datum/material/plasma = 500)

/datum/design/ipc_upgrade/tool_speedifier
	name = "Tool Adaptor"
	id = "tool_speedifier"
	desc = "A utility upgrade that allows the user to interface with tools more effectively, increasing their speed."
	build_path = /obj/item/ipc_upgrade/tool_speedifier
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1000, /datum/material/copper = 500)

/datum/design/ipc_upgrade/leap_legs
	name = "Leap Legs"
	id = "leap_legs"
	desc = "A utility upgrade that installs powerful hydraulics that allow to user to launch themselves violently."
	build_path = /obj/item/ipc_upgrade/leap_legs
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/diamond = 500)

/datum/design/ipc_upgrade/ipc_generator
	name = "Isotope Decay Generator"
	id = "ipc_generator"
	desc = "A core upgrade that installs a small RTG in the user, allowing them to generate trace amounts of power."
	build_path = /obj/item/ipc_upgrade/ipc_generator
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/uranium = 1000)

/datum/design/ipc_upgrade/fuel_generator
	name = "Plasmatic Generator"
	id = "fuel_generator"
	desc = "A core upgrade that installs a small plasma generator in the user, allowing them to generate a decent amount of power. Insert plasma material in the designated port on the user to fuel the generator."
	build_path = /obj/item/ipc_upgrade/fuel_generator
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 1000)

/datum/design/ipc_upgrade/vacuum_shielding
	name = "Vacuum Shielding"
	id = "vacuum_shielding"
	desc = "An external upgrade that seals joints, protecting them from a vacuum."
	build_path = /obj/item/ipc_upgrade/vacuum_shielding
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/titanium = 250, /datum/material/silver = 500)

/datum/design/ipc_upgrade/rad_shielding
	name = "Radiation Shielding"
	id = "rad_shielding"
	desc = "An external upgrade that includes lead plating to reduce incoming radiation emissions."
	build_path = /obj/item/ipc_upgrade/rad_shielding
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/titanium = 250, /datum/material/uranium = 1000)

/datum/design/ipc_upgrade/las_armor
	name = "Ablative Plating"
	id = "las_armor"
	desc = "An external upgrade that includes temperature resistant plating, reducing energy weapons and heat based damages."
	build_path = /obj/item/ipc_upgrade/las_armor
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 2000, /datum/material/titanium = 250, /datum/material/silver = 1000)

/datum/design/ipc_upgrade/ken_armor
	name = "Reactive Plating"
	id = "ken_armor"
	desc = "An external upgrade that includes hardened plating, reducing ballistic weapons and kinetic based damages."
	build_path = /obj/item/ipc_upgrade/ken_armor
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/titanium = 1000, /datum/material/uranium = 1000)

/datum/design/ipc_upgrade/cooling_system
	name = "Cooling System"
	id = "cooling_system"
	desc = "An external upgrade that includes advanced cooling devices, reducing overall temperature. Does not protect against heat caused by lack of coolant."
	build_path = /obj/item/ipc_upgrade/cooling_system
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 500, /datum/material/copper = 500)

