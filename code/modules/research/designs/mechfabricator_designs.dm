//Cyborg
/datum/design/borg_suit
	name = "Cyborg Endoskeleton"
	build_type = MECHFAB
	build_path = /obj/item/robot_suit
	materials = list(/datum/material/iron=15000)
	construction_time = 500
	category = list(RND_CATEGORY_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_CHASSIS)

/datum/design/borg_chest
	name = "Cyborg Torso"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/robot
	materials = list(/datum/material/iron=40000)
	construction_time = 350
	category = list(RND_CATEGORY_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_CHASSIS)

/datum/design/borg_head
	name = "Cyborg Head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/robot
	materials = list(/datum/material/iron=5000)
	construction_time = 350
	category = list(RND_CATEGORY_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_CHASSIS)

/datum/design/borg_l_arm
	name = "Cyborg Left Arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/left/robot
	materials = list(/datum/material/iron=10000)
	construction_time = 200
	category = list(RND_CATEGORY_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_CHASSIS)

/datum/design/borg_r_arm
	name = "Cyborg Right Arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/right/robot
	materials = list(/datum/material/iron=10000)
	construction_time = 200
	category = list(RND_CATEGORY_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_CHASSIS)

/datum/design/borg_l_leg
	name = "Cyborg Left Leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/left/robot
	materials = list(/datum/material/iron=10000)
	construction_time = 200
	category = list(RND_CATEGORY_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_CHASSIS)

/datum/design/borg_r_leg
	name = "Cyborg Right Leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/right/robot
	materials = list(/datum/material/iron=10000)
	construction_time = 200
	category = list(RND_CATEGORY_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_CHASSIS)

//Ripley
/datum/design/ripley_chassis
	name = "Exosuit Chassis (APLU \"Ripley\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/ripley
	materials = list(/datum/material/iron=20000)
	construction_time = 100
	category = list(RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/ripley_torso
	name = "Exosuit Torso (APLU \"Ripley\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_torso
	materials = list(/datum/material/iron=20000,/datum/material/glass = 7500)
	construction_time = 200
	category = list(RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/ripley_left_arm
	name = "Exosuit Left Arm (APLU \"Ripley\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_arm
	materials = list(/datum/material/iron=15000)
	construction_time = 150
	category = list(RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/ripley_right_arm
	name = "Exosuit Right Arm (APLU \"Ripley\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_arm
	materials = list(/datum/material/iron=15000)
	construction_time = 150
	category = list(RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/ripley_left_leg
	name = "Exosuit Left Leg (APLU \"Ripley\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_left_leg
	materials = list(/datum/material/iron=15000)
	construction_time = 150
	category = list(RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/ripley_right_leg
	name = "Exosuit Right Leg (APLU \"Ripley\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/ripley_right_leg
	materials = list(/datum/material/iron=15000)
	construction_time = 150
	category = list(RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_CHASSIS)

//Odysseus
/datum/design/odysseus_chassis
	name = "Exosuit Chassis (\"Odysseus\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/odysseus
	materials = list(/datum/material/iron=20000)
	construction_time = 100
	category = list(RND_CATEGORY_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/odysseus_torso
	name = "Exosuit Torso (\"Odysseus\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_torso
	materials = list(/datum/material/iron=12000)
	construction_time = 180
	category = list(RND_CATEGORY_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/odysseus_head
	name = "Exosuit Head (\"Odysseus\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_head
	materials = list(/datum/material/iron=6000,/datum/material/glass = 10000)
	construction_time = 100
	category = list(RND_CATEGORY_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/odysseus_left_arm
	name = "Exosuit Left Arm (\"Odysseus\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_arm
	materials = list(/datum/material/iron=6000)
	construction_time = 120
	category = list(RND_CATEGORY_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/odysseus_right_arm
	name = "Exosuit Right Arm (\"Odysseus\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_arm
	materials = list(/datum/material/iron=6000)
	construction_time = 120
	category = list(RND_CATEGORY_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/odysseus_left_leg
	name = "Exosuit Left Leg (\"Odysseus\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_left_leg
	materials = list(/datum/material/iron=7000)
	construction_time = 130
	category = list(RND_CATEGORY_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/odysseus_right_leg
	name = "Exosuit Right Leg (\"Odysseus\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/odysseus_right_leg
	materials = list(/datum/material/iron=7000)
	construction_time = 130
	category = list(RND_CATEGORY_ODYSSEUS + RND_SUBCATEGORY_MECHFAB_CHASSIS)

//Gygax
/datum/design/gygax_chassis
	name = "Exosuit Chassis (\"Gygax\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/gygax
	materials = list(/datum/material/iron=20000)
	construction_time = 100
	category = list(RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/gygax_torso
	name = "Exosuit Torso (\"Gygax\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_torso
	materials = list(/datum/material/iron=20000,/datum/material/glass = 10000,/datum/material/gold=2000, /datum/material/silver=2000)
	construction_time = 300
	category = list(RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/gygax_head
	name = "Exosuit Head (\"Gygax\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_head
	materials = list(/datum/material/iron=10000,/datum/material/glass = 5000, /datum/material/gold=2000, /datum/material/silver=2000)
	category = list(RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/gygax_left_arm
	name = "Exosuit Left Arm (\"Gygax\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_arm
	materials = list(/datum/material/iron=15000, /datum/material/gold=1000, /datum/material/silver=1000)
	construction_time = 200
	category = list(RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/gygax_right_arm
	name = "Exosuit Right Arm (\"Gygax\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_arm
	materials = list(/datum/material/iron=15000, /datum/material/gold=1000, /datum/material/silver=1000)
	construction_time = 200
	category = list(RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/gygax_left_leg
	name = "Exosuit Left Leg (\"Gygax\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_left_leg
	materials = list(/datum/material/iron=15000, /datum/material/gold=2000, /datum/material/silver=2000)
	construction_time = 200
	category = list(RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/gygax_right_leg
	name = "Exosuit Right Leg (\"Gygax\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_right_leg
	materials = list(/datum/material/iron=15000, /datum/material/gold=2000, /datum/material/silver=2000)
	construction_time = 200
	category = list(RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/gygax_armor
	name = "Exosuit Armor (\"Gygax\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/gygax_armor
	materials = list(/datum/material/iron=15000,/datum/material/gold=10000, /datum/material/silver=10000, /datum/material/titanium=10000)
	construction_time = 600
	category = list(RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_CHASSIS)

//Durand
/datum/design/durand_chassis
	name = "Exosuit Chassis (\"Durand\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/durand
	materials = list(/datum/material/iron=25000)
	construction_time = 100
	category = list(RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/durand_torso
	name = "Exosuit Torso (\"Durand\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_torso
	materials = list(/datum/material/iron=25000, /datum/material/glass = 10000,/datum/material/silver=10000)
	construction_time = 300
	category = list(RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/durand_head
	name = "Exosuit Head (\"Durand\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_head
	materials = list(/datum/material/iron=10000,/datum/material/glass = 15000,/datum/material/silver=2000)
	construction_time = 200
	category = list(RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/durand_left_arm
	name = "Exosuit Left Arm (\"Durand\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_arm
	materials = list(/datum/material/iron=10000,/datum/material/silver=4000)
	construction_time = 200
	category = list(RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/durand_right_arm
	name = "Exosuit Right Arm (\"Durand\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_arm
	materials = list(/datum/material/iron=10000,/datum/material/silver=4000)
	construction_time = 200
	category = list(RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/durand_left_leg
	name = "Exosuit Left Leg (\"Durand\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_left_leg
	materials = list(/datum/material/iron=15000,/datum/material/silver=4000)
	construction_time = 200
	category = list(RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/durand_right_leg
	name = "Exosuit Right Leg (\"Durand\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_right_leg
	materials = list(/datum/material/iron=15000,/datum/material/silver=4000)
	construction_time = 200
	category = list(RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/durand_armor
	name = "Exosuit Armor (\"Durand\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/durand_armor
	materials = list(/datum/material/iron=30000,/datum/material/uranium=25000,/datum/material/titanium=20000)
	construction_time = 600
	category = list(RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_CHASSIS)

//H.O.N.K
/datum/design/honk_chassis
	name = "Exosuit Chassis (\"H.O.N.K\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/honker
	materials = list(/datum/material/iron=20000)
	construction_time = 100
	category = list(RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/honk_torso
	name = "Exosuit Torso (\"H.O.N.K\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_torso
	materials = list(/datum/material/iron=20000,/datum/material/glass = 10000,/datum/material/bananium=10000)
	construction_time = 300
	category = list(RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/honk_head
	name = "Exosuit Head (\"H.O.N.K\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_head
	materials = list(/datum/material/iron=10000,/datum/material/glass = 5000,/datum/material/bananium=5000)
	construction_time = 200
	category = list(RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/honk_left_arm
	name = "Exosuit Left Arm (\"H.O.N.K\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_left_arm
	materials = list(/datum/material/iron=15000,/datum/material/bananium=5000)
	construction_time = 200
	category = list(RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/honk_right_arm
	name = "Exosuit Right Arm (\"H.O.N.K\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_arm
	materials = list(/datum/material/iron=15000,/datum/material/bananium=5000)
	construction_time = 200
	category = list(RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/honk_left_leg
	name = "Exosuit Left Leg (\"H.O.N.K\")"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/part/honker_left_leg
	materials = list(/datum/material/iron=20000,/datum/material/bananium=5000)
	construction_time = 200
	category = list(RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/honk_right_leg
	name = "Exosuit Right Leg (\"H.O.N.K\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/honker_right_leg
	materials = list(/datum/material/iron=20000,/datum/material/bananium=5000)
	construction_time = 200
	category = list(RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_CHASSIS)


//Phazon
/datum/design/phazon_chassis
	name = "Exosuit Chassis (\"Phazon\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/phazon
	materials = list(/datum/material/iron=20000)
	construction_time = 100
	category = list(RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/phazon_torso
	name = "Exosuit Torso (\"Phazon\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_torso
	materials = list(/datum/material/iron=35000,/datum/material/glass = 10000,/datum/material/plasma=20000)
	construction_time = 300
	category = list(RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_CHASSIS)

//Clarke
/datum/design/clarke_chassis
	name = "Exosuit Chassis (\"Clarke\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/chassis/clarke
	materials = list(/datum/material/iron=20000)
	construction_time = 100
	category = list(RND_CATEGORY_CLARKE + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/clarke_torso
	name = "Exosuit Torso (\"Clarke\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_torso
	materials = list(/datum/material/iron=20000,/datum/material/glass = 7500)
	construction_time = 200
	category = list(RND_CATEGORY_CLARKE + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/clarke_head
	name = "Exosuit Head (\"Clarke\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_head
	materials = list(/datum/material/iron=6000,/datum/material/glass = 10000)
	construction_time = 100
	category = list(RND_CATEGORY_CLARKE + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/clarke_left_arm
	name = "Exosuit Left Arm (\"Clarke\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_left_arm
	materials = list(/datum/material/iron=15000)
	construction_time = 150
	category = list(RND_CATEGORY_CLARKE + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/clarke_right_arm
	name = "Exosuit Right Arm (\"Clarke\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/clarke_right_arm
	materials = list(/datum/material/iron=15000)
	construction_time = 150
	category = list(RND_CATEGORY_CLARKE + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/phazon_head
	name = "Exosuit Head (\"Phazon\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_head
	materials = list(/datum/material/iron=15000,/datum/material/glass = 5000,/datum/material/plasma=10000)
	construction_time = 200
	category = list(RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/phazon_left_arm
	name = "Exosuit Left Arm (\"Phazon\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_arm
	materials = list(/datum/material/iron=20000,/datum/material/plasma=10000)
	construction_time = 200
	category = list(RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/phazon_right_arm
	name = "Exosuit Right Arm (\"Phazon\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_arm
	materials = list(/datum/material/iron=20000,/datum/material/plasma=10000)
	construction_time = 200
	category = list(RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/phazon_left_leg
	name = "Exosuit Left Leg (\"Phazon\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_left_leg
	materials = list(/datum/material/iron=20000,/datum/material/plasma=10000)
	construction_time = 200
	category = list(RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/phazon_right_leg
	name = "Exosuit Right Leg (\"Phazon\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_right_leg
	materials = list(/datum/material/iron=20000,/datum/material/plasma=10000)
	construction_time = 200
	category = list(RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/phazon_armor
	name = "Exosuit Armor (\"Phazon\")"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/part/phazon_armor
	materials = list(/datum/material/iron=25000,/datum/material/plasma=20000,/datum/material/titanium=20000)
	construction_time = 300
	category = list(RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_CHASSIS)

//Exosuit Equipment
/datum/design/ripleyupgrade
	name = "Ripley MK-I to MK-II conversion kit"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/ripleyupgrade
	materials = list(/datum/material/iron=10000,/datum/material/plasma=10000)
	construction_time = 100
	category = list(RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_CHASSIS)

/datum/design/mech_hydraulic_clamp
	name = "Exosuit Engineering (Hydraulic Clamp)"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list(
		RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
	)

/datum/design/mech_drill
	name = "Exosuit Mining (Mining Drill)"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/drill
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list(
		RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
	)

/datum/design/mech_mining_scanner
	name = "Exosuit Engineering (Mining Scanner)"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/mining_scanner
	materials = list(/datum/material/iron=5000,/datum/material/glass = 2500)
	construction_time = 50
	category = list(
		RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
		RND_CATEGORY_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MINING,
	)

/datum/design/mech_extinguisher
	name = "Exosuit Engineering (Extinguisher)"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/extinguisher
	materials = list(/datum/material/iron=10000)
	construction_time = 100
	category = list(
		RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
	)

/datum/design/mech_generator
	name = "Exosuit Module (Plasma Generator)"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/generator
	materials = list(/datum/material/iron=10000,/datum/material/glass = 1000,/datum/material/silver=2000,/datum/material/plasma=5000)
	construction_time = 100
	category = list(
		RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
	)

/datum/design/mech_mousetrap_mortar
	name = "H.O.N.K Weapon (Mousetrap Mortar)"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar
	materials = list(/datum/material/iron=20000,/datum/material/bananium=5000)
	construction_time = 300
	category = list(
		RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_HONK,
		RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_HONK,
	)

/datum/design/mech_banana_mortar
	name = "H.O.N.K Weapon (Banana Mortar)"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar
	materials = list(/datum/material/iron=20000,/datum/material/bananium=5000)
	construction_time = 300
	category = list(
		RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_HONK,
		RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_HONK,
	)

/datum/design/mech_honker
	name = "H.O.N.K Weapon (HoNkER BlAsT 5000)"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/honker
	materials = list(/datum/material/iron=20000,/datum/material/bananium=10000)
	construction_time = 500
	category = list(
		RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_HONK,
		RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_HONK,
	)

/datum/design/mech_punching_glove
	name = "H.O.N.K Weapon (Oingo Boingo Punch-face)"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove
	materials = list(/datum/material/iron=20000,/datum/material/bananium=7500)
	construction_time = 400
	category = list(
		RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_HONK,
		RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_HONK,
	)

/datum/design/mech_radio
	name = "Mech Radio"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/radio
	materials = list(/datum/material/iron=2500)
	construction_time = 100
	category = list(
		RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
	)

/datum/design/mech_air_tank
	name = "Mech Air Tank"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_equipment/air_tank
	materials = list(/datum/material/iron=5000)
	construction_time = 100
	category = list(
		RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
	)

/////////////////////////////////////////
//////////////Borg Upgrades//////////////
/////////////////////////////////////////

/datum/design/borg_upgrade_rename
	name = "Cyborg Upgrade (Rename Board)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rename
	materials = list(/datum/material/iron = 5000)
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ALL)

/datum/design/borg_upgrade_restart
	name = "Cyborg Upgrade (Emergency Reboot Board)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/restart
	materials = list(/datum/material/iron = 20000 , /datum/material/glass = 5000)
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ALL)

/datum/design/borg_upgrade_vtec
	name = "Cyborg Upgrade (VTEC Module)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/vtec
	materials = list(/datum/material/iron= 35000 , /datum/material/glass = 12000 , /datum/material/uranium = 10000)
	construction_time = 80
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ALL)

/datum/design/borg_upgrade_thrusters
	name = "Cyborg Upgrade (Ion Thrusters)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/thrusters
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 6000, /datum/material/plasma = 5000, /datum/material/uranium = 6000)
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ALL)

/datum/design/borg_upgrade_diamonddrill
	name = "Cyborg Upgrade (Diamond Drill)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/ddrill
	materials = list(/datum/material/iron=10000, /datum/material/glass = 6000, /datum/material/diamond = 2000)
	construction_time = 80
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MINING)

/datum/design/borg_upgrade_holding
	name = "Cyborg Upgrade (Ore Satchel of Holding)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/soh
	materials = list(/datum/material/iron = 10000, /datum/material/gold = 2000, /datum/material/uranium = 1000)
	construction_time = 40
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MINING)

/datum/design/borg_upgrade_cutter
	name = "Cyborg Upgrade (Plasma Cutter)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/cutter
	materials = list(/datum/material/iron = 10000, /datum/material/gold = 2000, /datum/material/uranium = 1000)
	construction_time = 40
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MINING)

/datum/design/borg_upgrade_lavaproof
	name = "Cyborg Upgrade (Lavaproof Tracks)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/lavaproof
	materials = list(/datum/material/iron = 10000, /datum/material/plasma = 4000, /datum/material/titanium = 5000)
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MINING)

/datum/design/borg_syndicate_module
	name = "Cyborg Upgrade (Illegal Modules)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/syndicate
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000, /datum/material/diamond = 10000)
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ALL)

/datum/design/borg_transform_clown
	name = "Cyborg Upgrade (Clown Model)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/transform/clown
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000, /datum/material/bananium = 1000)
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ALL)

/datum/design/borg_upgrade_selfrepair
	name = "Cyborg Upgrade (Self-repair)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/selfrepair
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000)
	construction_time = 80
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ALL)

/datum/design/borg_upgrade_expandedsynthesiser
	name = "Cyborg Upgrade (Hypospray Expanded Synthesiser)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/hypospray/expanded
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000, /datum/material/plasma = 8000, /datum/material/uranium = 8000)
	construction_time = 80
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MEDICAL)

/datum/design/borg_upgrade_piercinghypospray
	name = "Cyborg Upgrade (Piercing Hypospray)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/piercing_hypospray
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000, /datum/material/titanium = 5000, /datum/material/diamond = 3000)
	construction_time = 80
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MEDICAL)

/datum/design/borg_upgrade_defibrillator
	name = "Cyborg Upgrade (Defibrillator)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/defib
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 5000, /datum/material/silver = 4000, /datum/material/gold = 3000)
	construction_time = 80
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MEDICAL)

/datum/design/borg_upgrade_surgicalprocessor
	name = "Cyborg Upgrade (Surgical Processor)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/processor
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 4000, /datum/material/silver = 4000)
	construction_time = 40
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MEDICAL)

/datum/design/borg_upgrade_trashofholding
	name = "Cyborg Upgrade (Trash Bag of Holding)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/tboh
	materials = list(/datum/material/gold = 2000, /datum/material/uranium = 1000)
	construction_time = 40
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_JANITOR)

/datum/design/borg_upgrade_advancedmop
	name = "Cyborg Upgrade (Advanced Mop)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/amop
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2000)
	construction_time = 40
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_JANITOR)

/datum/design/borg_upgrade_expand
	name = "Cyborg Upgrade (Expand)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/expand
	materials = list(/datum/material/iron = 200000, /datum/material/titanium = 5000)
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ALL)

/datum/design/boris_ai_controller
	name = "B.O.R.I.S. AI-Cyborg Remote Control"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/ai
	materials = list(/datum/material/iron = 1200, /datum/material/glass = 1500, /datum/material/gold = 200)
	construction_time = 50
	category = list(RND_CATEGORY_MECHFAB_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_CONTROL_INTERFACES)

/datum/design/borg_upgrade_rped
	name = "Cyborg Upgrade (RPED)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/rped
	materials = list(/datum/material/iron = 10000, /datum/material/glass = 5000)
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ENGINEERING)

/datum/design/borg_upgrade_bsrped
	name = "Cyborg Upgrade (BSRPED)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/bsrped
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 5000, /datum/material/silver = 2500)
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ENGINEERING)

/datum/design/borg_upgrade_bslightreplacer
	name = "Cyborg Upgrade (BS Light Replacer)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/bslightreplacer
	materials = list(/datum/material/iron = 1500, /datum/material/silver = 150, /datum/material/glass = 6000, /datum/material/bluespace = 300)
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_JANITOR)

/datum/design/borg_upgrade_circuit_app
	name = "Cyborg Upgrade (Circuit Manipulator)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/circuit_app
	materials = list(/datum/material/iron = 2000, /datum/material/titanium = 500)
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_ENGINEERING)

/datum/design/borg_upgrade_beaker_app
	name = "Cyborg Upgrade (Beaker Storage)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/beaker_app
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2250) //Need glass for the new beaker too
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MEDICAL)

/datum/design/borg_upgrade_pinpointer
	name = "Cyborg Upgrade (Crew pinpointer)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/pinpointer
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500)
	construction_time = 120
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_MEDICAL)

//Misc
/datum/design/mecha_tracking
	name = "Exosuit Tracker (Exosuit Tracking Beacon)"
	build_type = MECHFAB
	build_path =/obj/item/mecha_parts/mecha_tracking
	materials = list(/datum/material/iron=500)
	construction_time = 50
	category = list(
		RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_RIPLEY + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_GYGAX + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_DURAND + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_HONK + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_PHAZON + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
		RND_CATEGORY_CLARKE + RND_SUBCATEGORY_MECHFAB_SUPPORTED_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_MISC,
	)

/datum/design/mecha_tracking_ai_control
	name = "AI Control Beacon"
	build_type = MECHFAB
	build_path = /obj/item/mecha_parts/mecha_tracking/ai_control
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/silver = 200)
	construction_time = 50
	category = list(RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_CONTROL_INTERFACES)

/datum/design/synthetic_flash
	name = "Flash"
	desc = "When a problem arises, SCIENCE is the solution."
	build_type = MECHFAB
	materials = list(/datum/material/iron = 750, /datum/material/glass = 750)
	construction_time = 100
	build_path = /obj/item/assembly/flash/handheld/weak
	category = list(RND_CATEGORY_MECHFAB_CYBORG + RND_SUBCATEGORY_MECHFAB_CYBORG_COMPONENTS)

//MODsuit stuff

/datum/design/mod_shell
	name = "MOD shell"
	desc = "A 'Nakamura Engineering' designed shell for a Modular Suit."
	build_type = MECHFAB
	materials = list(/datum/material/iron = 10000, /datum/material/plasma = 5000)
	construction_time = 25 SECONDS
	build_path = /obj/item/mod/construction/shell
	category = list(RND_CATEGORY_MOD_CONSTRUCTION + RND_SUBCATEGORY_MODUITS_CHASSIS)

/datum/design/mod_helmet
	name = "MOD helmet"
	desc = "A 'Nakamura Engineering' designed helmet for a Modular Suit."
	build_type = MECHFAB
	materials = list(/datum/material/iron = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/helmet
	category = list(RND_CATEGORY_MOD_CONSTRUCTION + RND_SUBCATEGORY_MODUITS_CHASSIS)

// Even without a hat stabilizer, hats can be worn - however, they'll fall off very easily
/obj/item/clothing/head/mod/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/hat_stabilizer, loose_hat = TRUE)

/datum/design/mod_chestplate
	name = "MOD chestplate"
	desc = "A 'Nakamura Engineering' designed chestplate for a Modular Suit."
	build_type = MECHFAB
	materials = list(/datum/material/iron = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/chestplate
	category = list(RND_CATEGORY_MOD_CONSTRUCTION + RND_SUBCATEGORY_MODUITS_CHASSIS)

/datum/design/mod_gauntlets
	name = "MOD gauntlets"
	desc = "'Nakamura Engineering' designed gauntlets for a Modular Suit."
	build_type = MECHFAB
	materials = list(/datum/material/iron = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/gauntlets
	category = list(RND_CATEGORY_MOD_CONSTRUCTION + RND_SUBCATEGORY_MODUITS_CHASSIS)

/datum/design/mod_boots
	name = "MOD boots"
	desc = "'Nakamura Engineering' designed boots for a Modular Suit."
	build_type = MECHFAB
	materials = list(/datum/material/iron = 5000)
	construction_time = 10 SECONDS
	build_path = /obj/item/mod/construction/boots
	category = list(RND_CATEGORY_MOD_CONSTRUCTION + RND_SUBCATEGORY_MODUITS_CHASSIS)

/datum/design/mod_plating
	name = "MOD external plating"
	desc = "External plating for a MODsuit."
	build_type = MECHFAB|PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 3000, /datum/material/plasma = 1000)
	construction_time = 15 SECONDS
	build_path = /obj/item/mod/construction/plating
	category = list(RND_CATEGORY_MOD_CONSTRUCTION + RND_SUBCATEGORY_MODSUITS_PLATING)
	research_icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	research_icon_state = "standard-plating"

/datum/design/mod_plating/New()
	. = ..()
	var/obj/item/mod/construction/plating/armor_type = build_path
	var/datum/mod_theme/theme = GLOB.mod_themes[initial(armor_type.theme)]
	name = "MOD [theme.name] plating"
	desc = "External plating for a MODsuit. [theme.desc]"

/datum/design/mod_plating/civilian
	name = "MOD Civilian Plating"
	build_path = /obj/item/mod/construction/plating/civilian
	materials = list(
		/datum/material/iron = 3000,
		/datum/material/glass = 1500,
		/datum/material/plasma = 1000,
	)
	research_icon_state = "civilian-plating"

/datum/design/mod_plating/engineering
	build_path = /obj/item/mod/construction/plating/engineering
	materials = list(
		/datum/material/iron = 6000,
		/datum/material/gold = 2000,
		/datum/material/glass = 1000,
		/datum/material/plasma = 1000
	)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING
	research_icon_state = "engineering-plating"

/datum/design/mod_plating/atmospheric
	build_path = /obj/item/mod/construction/plating/atmospheric
	materials = list(/datum/material/iron = 6000, /datum/material/titanium = 2000, /datum/material/glass = 1000, /datum/material/plasma = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING
	research_icon_state = "atmospheric-plating"

/datum/design/mod_plating/medical
	build_path = /obj/item/mod/construction/plating/medical
	materials = list(/datum/material/iron = 6000, /datum/material/silver = 2000, /datum/material/glass = 1000, /datum/material/plasma = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
	research_icon_state = "medical-plating"

/datum/design/mod_plating/security
	build_path = /obj/item/mod/construction/plating/security
	materials = list(/datum/material/iron = 6000, /datum/material/uranium = 2000, /datum/material/glass = 1000, /datum/material/plasma = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY
	research_icon_state = "security-plating"

/datum/design/mod_plating/cosmohonk
	build_path = /obj/item/mod/construction/plating/cosmohonk
	materials = list(/datum/material/iron = 6000, /datum/material/bananium = 2000, /datum/material/glass = 1000, /datum/material/plasma = 1000)
	departmental_flags = DEPARTMENTAL_FLAG_SERVICE
	research_icon_state = "cosmohonk-plating"

/datum/design/mod_paint_kit
	name = "MOD paint kit"
	desc = "A paint kit for Modular Suits."
	build_type = MECHFAB|PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/plastic = 500)
	construction_time = 5 SECONDS
	build_path = /obj/item/mod/paint
	category = list(RND_CATEGORY_MODSUITS + RND_SUBCATEGORY_MODSUITS_MISC)

/datum/design/modlink_scryer
	name = "MODlink Scryer"
	desc = "A neck-worn piece of gear that can call with another MODlink-compatible device."
	build_type = MECHFAB
	materials = list(
		/datum/material/iron = 1000,
		/datum/material/gold = 600,
		/datum/material/glass = 600,
	)
	construction_time = 5 SECONDS
	build_path = /obj/item/clothing/neck/link_scryer
	category = list(RND_CATEGORY_MISC)

/datum/design/module
	name = "MOD Module"
	build_type = MECHFAB
	construction_time = 1 SECONDS
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_GENERAL)

/datum/design/module/New()
	. = ..()
	var/obj/item/mod/module/module = build_path
	desc = "[initial(module.desc)] It uses [initial(module.complexity)] complexity."

/datum/design/module/mod_storage
	name = "MOD Module: Storage"
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 500)
	build_path = /obj/item/mod/module/storage
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_storage_expanded
	name = "MOD Module: Expanded Storage"
	materials = list(/datum/material/iron = 5000, /datum/material/uranium = 2000)
	build_path = /obj/item/mod/module/storage/large_capacity
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_visor_medhud
	name = "MOD Module: Medical Visor"
	materials = list(/datum/material/silver = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/visor/medhud
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

/datum/design/module/mod_visor_diaghud
	name = "MOD Module: Diagnostic Visor"
	materials = list(/datum/material/gold = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/visor/diaghud
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SCIENCE)

/datum/design/module/mod_visor_sechud
	name = "MOD Module: Security Visor"
	materials = list(/datum/material/titanium = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/visor/sechud
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SECURITY)

/datum/design/module/mod_visor_meson
	name = "MOD Module: Meson Visor"
	materials = list(/datum/material/uranium = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/visor/meson
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_visor_welding
	name = "MOD Module: Welding Protection"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/welding
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_t_ray
	name = "MOD Module: T-Ray Scanner"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/t_ray
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_health_analyzer
	name = "MOD Module: Health Analyzer"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/health_analyzer
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

/datum/design/module/mod_stealth
	name = "MOD Module: Cloak"
	materials = list(/datum/material/iron = 1000, /datum/material/bluespace = 500)
	build_path = /obj/item/mod/module/stealth
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SECURITY)

/datum/design/module/mod_jetpack
	name = "MOD Module: Ion Jetpack"
	materials = list(/datum/material/iron = 1500, /datum/material/plasma = 1000)
	build_path = /obj/item/mod/module/jetpack
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_magboot
	name = "MOD Module: Magnetic Stabilizator"
	materials = list(/datum/material/iron = 1000, /datum/material/gold = 500)
	build_path = /obj/item/mod/module/magboot
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_mag_harness
	name = "MOD Module: Magnetic Harness"
	materials = list(/datum/material/iron = 1500, /datum/material/silver = 500)
	build_path = /obj/item/mod/module/magnetic_harness
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SECURITY)

/datum/design/module/mod_reinforced_plating
	name = "MOD Module: Reinforced Plating"
	materials = list(/datum/material/iron = 3000, /datum/material/silver = 1200, /datum/material/titanium = 1000, /datum/material/plasma = 500)
	build_path = /obj/item/mod/module/reinforced_plating
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SECURITY)

/datum/design/module/mod_tether
	name = "MOD Module: Emergency Tether"
	materials = list(/datum/material/iron = 1000, /datum/material/silver = 500)
	build_path = /obj/item/mod/module/tether
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_mouthhole
	name = "MOD Module: Eating Apparatus"
	materials = list(/datum/material/iron = 1500)
	build_path = /obj/item/mod/module/mouthhole
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SUPPLY)

/datum/design/module/mod_rad_protection
	name = "MOD Module: Radiation Protection"
	materials = list(/datum/material/iron = 1000, /datum/material/uranium = 1000)
	build_path = /obj/item/mod/module/rad_protection
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_emp_shield
	name = "MOD Module: EMP Shield"
	materials = list(/datum/material/iron = 1000, /datum/material/plasma = 1000)
	build_path = /obj/item/mod/module/emp_shield
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_flashlight
	name = "MOD Module: Flashlight"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/flashlight
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_reagent_scanner
	name = "MOD Module: Reagent Scanner"
	materials = list(/datum/material/glass = 1000)
	build_path = /obj/item/mod/module/reagent_scanner
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

/datum/design/module/mod_gps
	name = "MOD Module: Internal GPS"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/mod/module/gps
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SUPPLY)

/datum/design/module/mod_constructor
	name = "MOD Module: Constructor"
	materials = list(/datum/material/iron = 1000, /datum/material/titanium = 500)
	build_path = /obj/item/mod/module/constructor
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_quick_carry
	name = "MOD Module: Quick Carry"
	materials = list(/datum/material/iron = 1000, /datum/material/titanium = 500)
	build_path = /obj/item/mod/module/quick_carry
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

/datum/design/module/mod_longfall
	name = "MOD Module: Longfall"
	materials = list(/datum/material/iron = 1000)
	build_path = /obj/item/mod/module/longfall
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_thermal_regulator
	name = "MOD Module: Thermal Regulator"
	materials = list(/datum/material/iron = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/thermal_regulator
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_injector
	name = "MOD Module: Injector"
	materials = list(/datum/material/iron = 1000, /datum/material/diamond = 500)
	build_path = /obj/item/mod/module/injector
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

/datum/design/module/mod_bikehorn
	name = "MOD Module: Bike Horn"
	materials = list(/datum/material/plastic = 500, /datum/material/iron = 500)
	build_path = /obj/item/mod/module/bikehorn
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SERVICE)

/datum/design/module/mod_microwave_beam
	name = "MOD Module: Microwave Beam"
	materials = list(/datum/material/iron = 1000, /datum/material/uranium = 500)
	build_path = /obj/item/mod/module/microwave_beam
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SERVICE)

/datum/design/module/mod_waddle
	name = "MOD Module: Waddle"
	materials = list(/datum/material/plastic = 1000, /datum/material/iron = 1000)
	build_path = /obj/item/mod/module/waddle
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SERVICE)

/datum/design/module/mod_clamp
	name = "MOD Module: Crate Clamp"
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/mod/module/clamp
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SUPPLY)

/datum/design/module/mod_drill
	name = "MOD Module: Drill"
	materials = list(/datum/material/silver = 1000, /datum/material/iron = 2000)
	build_path = /obj/item/mod/module/drill
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SUPPLY)

/datum/design/module/mod_orebag
	name = "MOD Module: Ore Bag"
	materials = list(/datum/material/iron = 1500)
	build_path = /obj/item/mod/module/orebag
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SUPPLY)

/datum/design/module/mod_organ_thrower
	name = "MOD Module: Organ Thrower"
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/organ_thrower
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

/datum/design/module/mod_pathfinder
	name = "MOD Module: Pathfinder"
	materials = list(/datum/material/uranium = 1000, /datum/material/iron = 1000)
	build_path = /obj/item/mod/module/pathfinder
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SCIENCE)

/datum/design/module/mod_dna_lock
	name = "MOD Module: DNA Lock"
	materials = list(/datum/material/diamond = 500, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/dna_lock
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

/datum/design/module/mod_plasma_stabilizer
	name = "MOD Module: Plasma Stabilizer"
	materials = list(/datum/material/plasma = 1000, /datum/material/glass = 1000)
	build_path = /obj/item/mod/module/plasma_stabilizer
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/*
/datum/design/module/mod_glove_translator
	name = "MOD Module: Glove Translator"
	materials = list(/datum/material/iron = 750, /datum/material/glass = 500)
	build_path = /obj/item/mod/module/signlang_radio
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_GENERAL)
*/

/datum/design/module/mister_atmos
	name = "MOD Module: Resin Mister"
	materials = list(/datum/material/glass = 1000, /datum/material/titanium = 1500)
	build_path = /obj/item/mod/module/mister/atmos
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

/datum/design/module/mod_holster
	name = "MOD Module: Holster"
	materials = list(/datum/material/iron = 1500, /datum/material/glass = 500)
	build_path = /obj/item/mod/module/holster
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SECURITY)

/datum/design/module/mod_sonar
	name = "MOD Module: Active Sonar"
	materials = list(/datum/material/titanium = 250, /datum/material/glass = 1000, /datum/material/gold = 500, /datum/material/uranium = 250)
	build_path = /obj/item/mod/module/active_sonar
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SECURITY)

/datum/design/module/projectile_dampener
	name = "MOD Module: Projectile Dampener"
	materials = list(/datum/material/iron = 1000, /datum/material/bluespace = 500)
	build_path = /obj/item/mod/module/projectile_dampener
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SECURITY)

/datum/design/module/surgicalprocessor
	name = "MOD Module: Surgical Processor"
	materials = list(/datum/material/titanium = 250, /datum/material/glass = 1000, /datum/material/silver = 1500)
	build_path = /obj/item/mod/module/surgical_processor
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

/datum/design/module/threadripper
	name = "MOD Module: Thread Ripper"
	materials = list(/datum/material/titanium = 250, /datum/material/plastic = 1000, /datum/material/silver = 1500)
	build_path = /obj/item/mod/module/thread_ripper
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

/datum/design/module/defibrillator
	name = "MOD Module: Defibrillator"
	materials = list(/datum/material/titanium = 250, /datum/material/diamond = 1000, /datum/material/silver = 1500)
	build_path = /obj/item/mod/module/defibrillator
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

/*
/datum/design/module/patienttransport
	name = "MOD Module: Patient Transport"
	materials = list(/datum/material/iron = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/mod/module/criminalcapture/patienttransport
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

/datum/design/module/criminalcapture
	name = "MOD Module: Criminal Capture"
	materials = list(/datum/material/iron = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/mod/module/criminalcapture
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SECURITY)
*/

/datum/design/module/statusreadout
	name = "Status Readout Module"
	materials = list(
		/datum/material/iron = 1500,
		/datum/material/glass = 500,
		/datum/material/titanium = 800,
	)
	build_path = /obj/item/mod/module/status_readout
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_MEDICAL)

//MODsuit bepis modules

/datum/design/module/disposal
	name = "MOD Module: Disposal Connector"
	materials = list(/datum/material/iron = 2500, /datum/material/titanium = 1000)
	build_path = /obj/item/mod/module/disposal_connector
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_ENGINEERING)

//MODsuit anomalock modules

/datum/design/module/mod_antigrav
	name = "MOD Module: Anti-Gravity"
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 2000, /datum/material/uranium = 2000)
	build_path = /obj/item/mod/module/anomaly_locked/antigrav
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SCIENCE)

/datum/design/module/mod_teleporter
	name = "MOD Module: Teleporter"
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 2000, /datum/material/bluespace = 2000)
	build_path = /obj/item/mod/module/anomaly_locked/teleporter
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SCIENCE)

/datum/design/module/mod_kinesis
	name = "MOD Module: Kinesis"
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 2000, /datum/material/uranium = 1000, /datum/material/bluespace = 1000)
	build_path = /obj/item/mod/module/anomaly_locked/kinesis
	category = list(RND_CATEGORY_MOD_MODULES + RND_SUBCATEGORY_MODSUIT_MODULES_SCIENCE)

// IPC Replacement Parts

/datum/design/robotic_liver
	name = "Substance Processor"
	build_type = MECHFAB
	build_path = /obj/item/organ/liver/cybernetic/tier2/ipc
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 100
	category = list(RND_CATEGORY_IPC_COMPONENTS)

/datum/design/robotic_eyes
	name = "Basic Robotic Eyes"
	build_type = MECHFAB
	build_path = /obj/item/organ/eyes/robotic
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 2000)
	construction_time = 100
	category = list(RND_CATEGORY_IPC_COMPONENTS)

/datum/design/robotic_tongue
	name = "Robotic Voicebox"
	build_type = MECHFAB
	build_path = /obj/item/organ/tongue/robot
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 100
	category = list(RND_CATEGORY_IPC_COMPONENTS)

/datum/design/robotic_heart
	name = "Coolant Pump"
	build_type = MECHFAB
	build_path = /obj/item/organ/heart/cybernetic/ipc
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2000, /datum/material/silver = 500)
	construction_time = 100
	category = list(RND_CATEGORY_IPC_COMPONENTS)

/datum/design/robotic_stomach
	name = "Micro-cell"
	build_type = MECHFAB
	build_path = /obj/item/organ/stomach/electrical/ipc
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 2000, /datum/material/plasma = 200)
	construction_time = 100
	category = list(RND_CATEGORY_IPC_COMPONENTS)

/datum/design/robotic_ears
	name = "Auditory Sensors"
	build_type = MECHFAB
	build_path = /obj/item/organ/ears/robot
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 100
	category = list(RND_CATEGORY_IPC_COMPONENTS)

/datum/design/power_cord
	name = "Recharging Electronics"
	build_type = MECHFAB
	build_path = /obj/item/organ/cyberimp/arm/power_cord
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 100
	category = list(RND_CATEGORY_IPC_COMPONENTS)

//service modules

/datum/design/borg_upgrade_botany
	name = "Cyborg Speciality (Botany)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/speciality/botany
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000)
	construction_time = 40
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_SERVICE)

/datum/design/borg_upgrade_kitchen
	name = "Cyborg Speciality (Cooking)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/speciality/kitchen
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 500)
	construction_time = 40
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_SERVICE)

/datum/design/borg_upgrade_casino
	name = "Cyborg Speciality (Casino)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/speciality/casino
	materials = list(/datum/material/iron = 2000, /datum/material/gold = 500)
	construction_time = 40
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_SERVICE)

/datum/design/borg_upgrade_party
	name = "Cyborg Speciality (Party)"
	build_type = MECHFAB
	build_path = /obj/item/borg/upgrade/speciality/party
	materials = list(/datum/material/iron = 2000, /datum/material/diamond = 500)
	construction_time = 40
	category = list(RND_CATEGORY_CYBORG_UPGRADE_MODULES + RND_SUBCATEGORY_MECHFAB_CYBORG_MODULES_SERVICE)

/datum/design/clown_car
	name = "Clown Car"
	desc = "A small car that the clown can use to take people around the station in style!"
	build_type = MECHFAB
	build_path = /obj/vehicle/sealed/car/clowncar
	materials = list(/datum/material/iron = 10000, /datum/material/bananium = 5000, /datum/material/plastic = 2000)
	construction_time = 100
	category = list(RND_CATEGORY_EXOSUIT_EQUIPMENT + RND_SUBCATEGORY_MECHFAB_EQUIPMENT_HONK)
