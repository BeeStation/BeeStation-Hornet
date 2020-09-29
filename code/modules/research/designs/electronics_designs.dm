
///////////////////////////////////
/////Non-Board Computer Stuff//////
///////////////////////////////////

/datum/design/intellicard
	name = "Intellicard AI Transportation System"
	desc = "Allows for the construction of an intellicard."
	id = "intellicard"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 200, /datum/material/copper = 300)
	build_path = /obj/item/aicard
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/paicard
	name = "Personal Artificial Intelligence Card"
	desc = "Allows for the construction of a pAI Card."
	id = "paicard"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500, /datum/material/copper = 300)
	build_path = /obj/item/paicard
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/ai_cam_upgrade
	name = "AI Surveillance Software Update"
	desc = "A software package that will allow an artificial intelligence to 'hear' from its cameras via lip reading."
	id = "ai_cam_upgrade"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/glass = 5000, /datum/material/gold = 15000, /datum/material/silver = 15000, /datum/material/diamond = 20000, /datum/material/plasma = 10000, /datum/material/copper = 3000)
	build_path = /obj/item/surveillance_upgrade
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

///////////////////////////////////
//////////Nanite Devices///////////
///////////////////////////////////
/datum/design/nanite_remote
	name = "Nanite Remote"
	desc = "Allows for the construction of a nanite remote."
	id = "nanite_remote"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500, /datum/material/copper = 200)
	build_path = /obj/item/nanite_remote
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/nanite_scanner
	name = "Nanite Scanner"
	desc = "Allows for the construction of a nanite scanner."
	id = "nanite_scanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 500, /datum/material/iron = 500, /datum/material/copper = 300)
	build_path = /obj/item/nanite_scanner
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

///////////////////////////////////
//////////Circuit Stuff////////////
///////////////////////////////////
/datum/design/integrated_printer
	name = "Integrated circuit printer"
	desc = "This machine provides all necessary things for circuitry."
	id = "icprinter"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 5000, /datum/material/iron = 10000, /datum/material/copper = 2000)
	build_path = /obj/item/integrated_circuit_printer
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/IC_printer_upgrade_advanced
	name = "Integrated circuit printer upgrade: Advanced Designs"
	desc = "This disk allows for integrated circuit printers to print advanced circuitry designs."
	id = "icupgadv"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 10000, /datum/material/iron = 10000, /datum/material/copper = 4000)
	build_path = /obj/item/disk/integrated_circuit/upgrade/advanced
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/IC_printer_upgrade_clone
	name = "Integrated circuit printer upgrade: Instant Cloning"
	desc = "This disk allows for integrated circuit printers to clone designs instantaneously."
	id = "icupgclo"
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 10000, /datum/material/iron = 10000, /datum/material/copper = 4000)
	build_path = /obj/item/disk/integrated_circuit/upgrade/clone
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE


////////////////////////////////////////
//////////Disk Construction Disks///////
////////////////////////////////////////
/datum/design/design_disk
	name = "Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/copper = 100)
	build_path = /obj/item/disk/design_disk
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/design_disk_adv
	name = "Advanced Design Storage Disk"
	desc = "Produce additional disks for storing device designs."
	id = "design_disk_adv"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/silver=50, /datum/material/copper = 200)
	build_path = /obj/item/disk/design_disk/adv
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/tech_disk
	name = "Technology Data Storage Disk"
	desc = "Produce additional disks for storing technology data."
	id = "tech_disk"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/copper = 100)
	build_path = /obj/item/disk/tech_disk
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/nanite_disk
	name = "Nanite Program Disk"
	desc = "Stores nanite programs."
	id = "nanite_disk"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100, /datum/material/copper = 100)
	build_path = /obj/item/disk/nanite_program
	category = list("Electronics")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
