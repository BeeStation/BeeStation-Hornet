////////////////////////////////////////
///////////Computer Parts///////////////
////////////////////////////////////////

/// Shells
/datum/design/computer_shell/pda
	name = "PDA shell"
	id = "shell_pda"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/copper = 150)
	build_path = /obj/item/modular_computer/tablet/pda
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/computer_shell/tablet
	name = "Tablet Shell"
	id = "shell_tablet"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1500, /datum/material/glass = 1000, /datum/material/copper = 150)
	build_path = /obj/item/modular_computer/tablet
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/computer_shell/laptop
	name = "Laptop Shell"
	id = "shell_laptop"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1000, /datum/material/copper = 150)
	build_path = /obj/item/modular_computer/laptop
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/// HDDs
/datum/design/disk/normal
	name = "Hard Disk Drive"
	id = "hdd_basic"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 400, /datum/material/glass = 100, /datum/material/copper = 150)
	build_path = /obj/item/computer_hardware/hard_drive
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/disk/advanced
	name = "Advanced Hard Disk Drive"
	id = "hdd_advanced"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 800, /datum/material/glass = 200, /datum/material/copper = 300)
	build_path = /obj/item/computer_hardware/hard_drive/advanced
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/disk/super
	name = "Super Hard Disk Drive"
	id = "hdd_super"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 1600, /datum/material/glass = 400, /datum/material/copper = 600)
	build_path = /obj/item/computer_hardware/hard_drive/super
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/disk/cluster
	name = "Cluster Hard Disk Drive"
	id = "hdd_cluster"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 3200, /datum/material/glass = 800, /datum/material/copper = 1000)
	build_path = /obj/item/computer_hardware/hard_drive/cluster
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/disk/small
	name = "Solid State Drive"
	id = "ssd_small"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 800, /datum/material/glass = 200, /datum/material/copper = 200)
	build_path = /obj/item/computer_hardware/hard_drive/small
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/disk/micro
	name = "Micro Solid State Drive"
	id = "ssd_micro"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 400, /datum/material/glass = 100, /datum/material/copper = 150)
	build_path = /obj/item/computer_hardware/hard_drive/micro
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

// Network cards
/datum/design/netcard/basic
	name = "Network Card"
	id = "netcard_basic"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 250, /datum/material/glass = 100, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/network_card
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/netcard/advanced
	name = "Advanced Network Card"
	id = "netcard_advanced"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 500, /datum/material/glass = 200, /datum/material/copper = 200)
	build_path = /obj/item/computer_hardware/network_card/advanced
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/netcard/wired
	name = "Wired Network Card"
	id = "netcard_wired"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 2500, /datum/material/glass = 400, /datum/material/copper = 400)
	build_path = /obj/item/computer_hardware/network_card/wired
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

// No-Relay Network Card
/datum/design/XNetCard
	name = "Experimental Network Card"
	id = "XNetCard"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 200, /datum/material/silver = 100, /datum/material/diamond = 50, /datum/material/bluespace = 25, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/network_card/advanced/norelay
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

// Data disks
/datum/design/portabledrive/basic
	name = "Data Disk"
	id = "portadrive_basic"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 800, /datum/material/copper = 200)
	build_path = /obj/item/computer_hardware/hard_drive/portable
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/portabledrive/advanced
	name = "Advanced Data Disk"
	id = "portadrive_advanced"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 1600, /datum/material/copper = 300)
	build_path = /obj/item/computer_hardware/hard_drive/portable/advanced
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/portabledrive/super
	name = "Super Data Disk"
	id = "portadrive_super"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 3200, /datum/material/copper = 400)
	build_path = /obj/item/computer_hardware/hard_drive/portable/super
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

// Card slots
/datum/design/cardslot
	name = "ID Card Slot"
	id = "cardslot"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 600, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/card_slot
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cardslot2
	name = "Secondary ID Card Slot"
	id = "cardslot2"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 600, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/card_slot/secondary
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE


// Intellicard slot
/datum/design/aislot
	name = "Intellicard Slot"
	id = "aislot"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 600, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/ai_slot
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

// Mini printer
/datum/design/miniprinter
	name = "Miniprinter"
	id = "miniprinter"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 600, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/printer/mini
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/printer
	name = "Printer"
	id = "printer"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 1200, /datum/material/copper = 300)
	build_path = /obj/item/computer_hardware/printer
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

// Camera Component
/datum/design/camera
	name = "Photographic Camera Component"
	id = "comp_camera"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 300, /datum/material/glass = 200)
	build_path = /obj/item/computer_hardware/camera_component
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

// APC Link
/datum/design/APClink
	name = "Area Power Connector"
	id = "APClink"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 2000)
	build_path = /obj/item/computer_hardware/recharger/APC
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

// Batteries
/datum/design/battery/nano
	name = "Tiny Battery"
	id = "bat_nano"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 200)
	build_path = /obj/item/computer_hardware/battery/tiny
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/battery/micro
	name = "Small Battery"
	id = "bat_micro"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 400)
	build_path = /obj/item/computer_hardware/battery/small
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/battery/standard
	name = "Standard Battery"
	id = "bat_normal"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 400)
	build_path = /obj/item/computer_hardware/battery/standard
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/battery/large
	name = "Large Battery"
	id = "bat_advanced"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 800)
	build_path = /obj/item/computer_hardware/battery/large
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/battery/huge
	name = "Extra Large Battery"
	id = "bat_super"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 1600)
	build_path = /obj/item/computer_hardware/battery/huge
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

// Processor unit
/datum/design/cpu
	name = "Processor Board"
	id = "cpu_normal"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 200, /datum/material/copper = 1600)
	build_path = /obj/item/computer_hardware/processor_unit
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cpu/small
	name = "Microprocessor"
	id = "cpu_small"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 100, /datum/material/copper = 800)
	build_path = /obj/item/computer_hardware/processor_unit/small
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cpu/photonic
	name = "Photonic Processor Board"
	id = "pcpu_normal"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 6400, /datum/material/gold = 2000, /datum/material/copper = 800)
	build_path = /obj/item/computer_hardware/processor_unit/photonic
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/cpu/photonic/small
	name = "Photonic Microprocessor"
	id = "pcpu_small"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 3200, /datum/material/gold = 1000, /datum/material/copper = 400)
	build_path = /obj/item/computer_hardware/processor_unit/photonic/small
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

//Antivirus. Now actually a computer part
/datum/design/antivirus1
	name = "Basic Antivirus"
	desc = "Basic Subscription package of NTOS Virus Buster."
	id = "antivirus"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 100, /datum/material/glass = 50, /datum/material/copper = 50)
	build_path = /obj/item/computer_hardware/hard_drive/role/antivirus
	category = list("Computer Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/antivirus2
	name = "Standard Antivirus"
	desc = "Standard Subscription package of NTOS Virus Buster."
	id = "antivirus2"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 150, /datum/material/glass = 100, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/hard_drive/role/antivirus/tier2
	category = list("Computer Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/antivirus3
	name = "Essential Antivirus"
	desc = "Essential Subscription package of NTOS Virus Buster."
	id = "antivirus3"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 200, /datum/material/glass = 150, /datum/material/silver = 60, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/hard_drive/role/antivirus/tier3
	category = list("Computer Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/antivirus4
	name = "Premium Antivirus"
	desc = "Premium Subscription package of NTOS Virus Buster."
	id = "antivirus4"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 200, /datum/material/glass = 200, /datum/material/diamond = 30, /datum/material/bluespace = 30, /datum/material/copper = 100)
	build_path = /obj/item/computer_hardware/hard_drive/role/antivirus/tier4
	category = list("Computer Parts")
	lathe_time_factor = 0.2
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/sensorpackage
	name = "Sensor Package"
	id = "sensorpackage"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 200, /datum/material/glass = 100, /datum/material/gold = 50, /datum/material/silver = 50)
	build_path = /obj/item/computer_hardware/sensorpackage
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/signaler_part
	name = "Integrated Signaler"
	id = "signalpart"
	build_type = IMPRINTER
	materials = list(/datum/material/iron = 400, /datum/material/glass = 100)
	build_path = /obj/item/computer_hardware/radio_card
	category = list("Computer Parts")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE
