/obj/item/modular_computer/tablet/pda/preset	//This needs to exist or else we can't really have empty PDA shells!
	var/cell_type = /obj/item/computer_hardware/battery/tiny

/obj/item/modular_computer/tablet/pda/preset/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/hard_drive/micro)
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new cell_type)
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/identifier)
	install_component(new /obj/item/computer_hardware/sensorpackage)

	var/obj/item/computer_hardware/hard_drive/hdd = all_components[MC_HDD]
	if(hdd)
		hdd.virus_defense = default_virus_defense
	if(default_disk)
		var/obj/item/computer_hardware/hard_drive/portable/disk = new default_disk(src)
		install_component(disk)

	if(insert_type)
		inserted_item = new insert_type(src)
		// show the inserted item
		update_appearance()

/obj/item/modular_computer/tablet/pda/preset/clown
	name = "clown PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The surface is coated with polytetrafluoroethylene and banana drippings."
	note = "Honk!"
	default_disk = /obj/item/computer_hardware/hard_drive/role/virus/clown
	icon_state = "pda-clown"
	insert_type = /obj/item/toy/crayon/rainbow
	/// List of victims (of a very funny joke, that everyone loves!). Stores references to mobs.
	var/list/slip_victims = list()
	init_ringtone = "honk"
	device_theme = THEME_NTOS_CLOWN_PINK // Give the clown the best theme
	ignore_theme_pref = TRUE

/obj/item/modular_computer/tablet/pda/preset/clown/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 7 SECONDS, NO_SLIP_WHEN_WALKING, CALLBACK(src, PROC_REF(AfterSlip)), 5 SECONDS)

/obj/item/modular_computer/tablet/pda/preset/clown/proc/AfterSlip(mob/living/carbon/human/M)
	if (istype(M) && (M.real_name != saved_identification))
		slip_victims |= REF(M)
		var/obj/item/computer_hardware/hard_drive/role/virus/clown/cart = all_components[MC_HDD_JOB]
		if(istype(cart) && cart.charges < 5)
			cart.charges++
			playsound(src,'sound/machines/ping.ogg',30,TRUE)

/obj/item/modular_computer/tablet/pda/preset/mime
	name = "mime PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The hardware has been modified for compliance with the vows of silence."
	default_disk = /obj/item/computer_hardware/hard_drive/role/virus/mime
	insert_type = /obj/item/toy/crayon/mime
	init_ringer_on = FALSE
	init_ringtone = "silence"

/obj/item/modular_computer/tablet/pda/preset/mime/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/hard_drive/hdd = all_components[MC_HDD]

	if(hdd)
		for(var/datum/computer_file/program/messenger/msg in hdd.stored_files)
			msg.mime_mode = TRUE
			msg.allow_emojis = TRUE

/obj/item/modular_computer/tablet/pda/preset/assistant
	name = "assistant PDA"
	icon_state = "pda-assistant"

/obj/item/modular_computer/tablet/pda/preset/medical
	name = "medical PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	icon_state = "pda-medical"

/obj/item/modular_computer/tablet/pda/preset/paramedic
	name = "paramedic PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	icon_state = "pda-paramedical"

/obj/item/modular_computer/tablet/pda/preset/virologist
	name = "virology PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	icon_state = "pda-virology"

/obj/item/modular_computer/tablet/pda/preset/station_engineer
	name = "engineering PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/engineering
	icon_state = "pda-engineer"

/obj/item/modular_computer/tablet/pda/preset/station_engineer/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/recharger/APC/pda)

/obj/item/modular_computer/tablet/pda/preset/security
	name = "security PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/security
	icon_state = "pda-security"
	default_virus_defense = ANTIVIRUS_NONE

/obj/item/modular_computer/tablet/pda/preset/deputy
	name = "deputy PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/security
	icon_state = "pda-deputy"
	default_virus_defense = ANTIVIRUS_BASIC

/obj/item/modular_computer/tablet/pda/preset/brig_physician
	name = "brig physician PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/brig_physician
	icon_state = "pda-brigphys"
	default_virus_defense = ANTIVIRUS_BASIC

/obj/item/modular_computer/tablet/pda/preset/detective
	name = "detective PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/detective
	icon_state = "pda-detective"
	default_virus_defense = ANTIVIRUS_MEDIUM

/obj/item/modular_computer/tablet/pda/preset/warden
	name = "warden PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/security
	icon_state = "pda-warden"
	default_virus_defense = ANTIVIRUS_MEDIUM

/obj/item/modular_computer/tablet/pda/preset/janitor
	name = "janitor PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/janitor
	icon_state = "pda-janitor"
	init_ringtone = "slip"

/obj/item/modular_computer/tablet/pda/preset/science
	name = "scientist PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/signal/toxins
	icon_state = "pda-science"
	init_ringtone = "boom"

/obj/item/modular_computer/tablet/pda/preset/science/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/radio_card)

/obj/item/modular_computer/tablet/pda/preset/service
	name = "service PDA"
	icon_state = "pda-service"

/obj/item/modular_computer/tablet/pda/preset/heads
	default_disk = /obj/item/computer_hardware/hard_drive/role/head
	icon_state = "pda-heads"
	default_virus_defense = ANTIVIRUS_GOOD

/obj/item/modular_computer/tablet/pda/preset/heads/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/card_slot/secondary)

/obj/item/modular_computer/tablet/pda/preset/heads/head_of_personnel
	name = "head of personnel PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/hop
	icon_state = "pda-hop"

/obj/item/modular_computer/tablet/pda/preset/heads/head_of_personnel/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/pda/preset/heads/head_of_security
	name = "head of security PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/hos
	icon_state = "pda-hos"

/obj/item/modular_computer/tablet/pda/preset/heads/chief_engineer
	name = "chief engineer PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/ce
	icon_state = "pda-ce"

/obj/item/modular_computer/tablet/pda/preset/heads/chief_engineer/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/recharger/APC/pda)

/obj/item/modular_computer/tablet/pda/preset/heads/chief_medical_officer
	name = "chief medical officer PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/cmo
	icon_state = "pda-cmo"

/obj/item/modular_computer/tablet/pda/preset/heads/research_director
	name = "research director PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/rd
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-rd"

/obj/item/modular_computer/tablet/pda/preset/heads/research_director/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/radio_card)

/obj/item/modular_computer/tablet/pda/preset/heads/captain
	name = "captain PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. The internals are modified to be more tough than the usual."
	default_disk = /obj/item/computer_hardware/hard_drive/role/captain
	insert_type = /obj/item/pen/fountain/captain
	icon_state = "pda-captain"
	default_virus_defense = ANTIVIRUS_BEST

/obj/item/modular_computer/tablet/pda/preset/cargo_technician
	name = "cargo technician PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/cargo_technician
	icon_state = "pda-cargo"

/obj/item/modular_computer/tablet/pda/preset/cargo_technician/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/pda/preset/quartermaster
	name = "quartermaster PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/quartermaster
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-qm"
	default_virus_defense = ANTIVIRUS_BASIC

/obj/item/modular_computer/tablet/pda/preset/quartermaster/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/printer/mini)

/obj/item/modular_computer/tablet/pda/preset/shaft_miner
	name = "shaft miner PDA"
	icon_state = "pda-miner"

/obj/item/modular_computer/tablet/pda/preset/exploration_crew
	name = "exploration crew PDA"
	icon_state = "pda-exploration"

/obj/item/modular_computer/tablet/pda/preset/syndicate
	name = "military PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This model is a WGW-XL-NTOS series."
	note = "Congratulations, your -corrupted- has chosen the Thinktronic 5290 WGW-XL-NTOS Series Personal Data Assistant!"
	default_disk = /obj/item/computer_hardware/hard_drive/role/virus/syndicate/military
	saved_identification = "John Doe"
	saved_job = "Citizen"
	icon_state = "pda-syndi"
	messenger_invisible = TRUE
	device_theme = THEME_SYNDICATE
	theme_locked = TRUE
	default_virus_defense = ANTIVIRUS_BEST
	max_hardware_size = WEIGHT_CLASS_SMALL
	cell_type = /obj/item/computer_hardware/battery/large

/obj/item/modular_computer/tablet/pda/preset/syndicate/Initialize(mapload)
	. = ..()
	var/obj/item/computer_hardware/network_card/network_card = all_components[MC_NET]
	if(istype(network_card))
		forget_component(network_card)
		install_component(new /obj/item/computer_hardware/network_card/advanced/norelay)

/obj/item/modular_computer/tablet/pda/preset/chaplain
	name = "chaplain PDA"
	icon_state = "pda-chaplain"
	init_ringtone = "holy"

/obj/item/modular_computer/tablet/pda/preset/lawyer
	name = "lawyer PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/lawyer
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-lawyer"
	init_ringtone = "objection"

/obj/item/modular_computer/tablet/pda/preset/roboticist
	name = "roboticist PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/roboticist
	icon_state = "pda-roboticist"

/obj/item/modular_computer/tablet/pda/preset/curator
	name = "curator PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This model is a WGW-11-NTOS series e-reader."
	note = "Congratulations, your station has chosen the Thinktronic 5290 WGW-11-NTOS Series E-reader and Personal Data Assistant!"
	default_disk = /obj/item/computer_hardware/hard_drive/role/curator
	icon_state = "pda-library"
	insert_type = /obj/item/pen/fountain
	init_ringtone = "silence"
	init_ringer_on = FALSE

/obj/item/modular_computer/tablet/pda/preset/clear
	name = "clear PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This model is a special edition with a transparent case."
	note = "Congratulations, you have chosen the Thinktronic 5230-NTOS Personal Data Assistant Deluxe Special Max Turbo Limited Edition!"
	icon_state = "pda-clear"

/obj/item/modular_computer/tablet/pda/preset/cook
	name = "cook PDA"
	icon_state = "pda-cook"

/obj/item/modular_computer/tablet/pda/preset/bartender
	name = "bartender PDA"
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-bartender"

/obj/item/modular_computer/tablet/pda/preset/atmospheric_technician
	name = "atmospherics PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/atmos
	icon_state = "pda-atmos"

/obj/item/modular_computer/tablet/pda/preset/atmospheric_technician/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/recharger/APC/pda)

/obj/item/modular_computer/tablet/pda/preset/chemist
	name = "chemist PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/chemistry
	icon_state = "pda-chemistry"

/obj/item/modular_computer/tablet/pda/preset/geneticist
	name = "geneticist PDA"
	default_disk = /obj/item/computer_hardware/hard_drive/role/medical
	icon_state = "pda-genetics"

/obj/item/modular_computer/tablet/pda/preset/vip
	name = "fancy PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This model is a gold-plated 5230-NTOS LRP Series, and probably quite expensive."
	note = "Congratulations, you have chosen the Thinktronic 5230-NTOS LRP Series Personal Data Assistant Golden Edition!"
	default_disk = /obj/item/computer_hardware/hard_drive/role/vip
	insert_type = /obj/item/pen/fountain
	icon_state = "pda-gold"
	init_ringtone = "ch-CHING"
	custom_price = 500

/obj/item/modular_computer/tablet/pda/preset/unlicensed
	name = "unlicensed PDA"
	desc = "A shitty knockoff of a portable microcomputer by Thinktronic Systems, LTD. Complete with a cracked operating system."
	note = "Error: Unlicensed software detected. Please contact your supervisor."
	default_disk = /obj/item/computer_hardware/hard_drive/role/maint
	icon_state = "pda-knockoff"

/obj/item/modular_computer/tablet/pda/prisoner
	name = "Prisoner PDA"
	desc = "A portable microcomputer by Thinktronic Systems, LTD. This model is a specially locked down variant for use by prisoners."
	icon_state = "pda-prisoner"

//This is silly
/obj/item/modular_computer/tablet/pda/prisoner/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/hard_drive/inmate)
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery/tiny)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/identifier)
	install_component(new /obj/item/computer_hardware/network_card)
