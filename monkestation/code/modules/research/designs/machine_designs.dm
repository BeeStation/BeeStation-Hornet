/datum/design/board/bountypad
	name = "Machine Design (Civilian Bounty Pad)"
	desc = "The circuit board for a Civilian Bounty Pad."
	id = "bounty_pad"
	build_type = PROTOLATHE | IMPRINTER
	materials = list(/datum/material/glass = 1000, /datum/material/copper = 300)
	build_path = /obj/item/circuitboard/machine/bountypad
	category = list ("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO
  
/datum/design/board/liquid_output_pump
	name = "Machine Design (Liquid Output Pump Machine)"
	desc = "The circuit board for a smoke machine."
	id = "liquid_output_pump"
	build_path = /obj/item/circuitboard/machine/liquid_output_pump
	category = list ("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING
