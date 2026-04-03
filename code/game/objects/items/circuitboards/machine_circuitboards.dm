//Command

/obj/item/circuitboard/machine/bsa/back
	name = "Bluespace Artillery Generator"
	icon_state = "command"
	build_path = /obj/machinery/bsa/back //No freebies!
	req_components = list(
		/obj/item/stock_parts/capacitor/quadratic = 5,
		/obj/item/stack/cable_coil = 2,
	)

/obj/item/circuitboard/machine/bsa/middle
	name = "Bluespace Artillery Fusor"
	icon_state = "command"
	build_path = /obj/machinery/bsa/middle
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 10,
		/obj/item/stack/cable_coil = 2,
	)

/obj/item/circuitboard/machine/bsa/front
	name = "Bluespace Artillery Bore"
	icon_state = "command"
	build_path = /obj/machinery/bsa/front
	req_components = list(
		/obj/item/stock_parts/manipulator/femto = 5,
		/obj/item/stack/cable_coil = 2,
	)

/obj/item/circuitboard/machine/dna_vault
	name = "DNA vault"
	icon_state = "command"
	build_path = /obj/machinery/dna_vault //No freebies!
	req_components = list(
		/obj/item/stock_parts/capacitor/super = 5,
		/obj/item/stock_parts/manipulator/pico = 5,
		/obj/item/stack/cable_coil = 2,
	)

//Engineering

/obj/item/circuitboard/machine/announcement_system
	name = "Announcement System"
	icon_state = "engineering"
	build_path = /obj/machinery/announcement_system
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/machine/autolathe
	name = "Autolathe"
	icon_state = "engineering"
	build_path = /obj/machinery/modular_fabricator/autolathe
	req_components = list(
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/machine/grounding_rod
	name = "Grounding Rod"
	icon_state = "engineering"
	build_path = /obj/machinery/power/energy_accumulator/grounding_rod
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/telecomms/broadcaster
	name = "Subspace Broadcaster"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/broadcaster
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/micro_laser = 2,
	)

/obj/item/circuitboard/machine/telecomms/bus
	name = "Bus Mainframe"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/bus
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1,
	)

/obj/item/circuitboard/machine/telecomms/hub
	name = "Hub Mainframe"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/hub
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 2,
	)

/obj/item/circuitboard/machine/telecomms/processor
	name = "Processor Unit"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/processor
	req_components = list(
		/obj/item/stock_parts/manipulator = 3,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/subspace/treatment = 2,
		/obj/item/stock_parts/subspace/analyzer = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/amplifier = 1,
	)

/obj/item/circuitboard/machine/telecomms/receiver
	name = "Subspace Receiver"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/receiver
	req_components = list(
		/obj/item/stock_parts/subspace/ansible = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/machine/telecomms/relay
	name = "Relay Mainframe"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/relay
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 2,
	)

/obj/item/circuitboard/machine/telecomms/server
	name = "Telecommunication Server"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/server
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1,
	)

/obj/item/circuitboard/machine/telecomms/message_server
	name = "Messaging Server"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/message_server
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 3,
	)

/obj/item/circuitboard/machine/tesla_coil
	name = "Tesla Coil"
	desc = "You can use a screwdriver to switch between Research and Power Generation."
	icon_state = "engineering"
	build_path = /obj/machinery/power/energy_accumulator/tesla_coil
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/tesla_coil/screwdriver_act(mob/living/user, obj/item/screwdriver)
	if(build_path == /obj/machinery/power/energy_accumulator/tesla_coil)
		name = "Tesla Corona Analyzer [name_extension]"
		build_path = /obj/machinery/power/energy_accumulator/tesla_coil/research

		to_chat(user, span_notice("You change the circuitboard setting to \"Research\"."))
	else
		name = "Tesla Coil [name_extension]"
		build_path = /obj/machinery/power/energy_accumulator/tesla_coil

		to_chat(user, span_notice("You change the circuitboard setting to \"Power\"."))

	screwdriver.play_tool_sound(src)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/circuitboard/machine/tesla_coil/research
	name = "Tesla Corona Analyzer"
	build_path = /obj/machinery/power/energy_accumulator/tesla_coil/research

/obj/item/circuitboard/machine/cell_charger
	name = "Cell Charger"
	icon_state = "engineering"
	build_path = /obj/machinery/cell_charger
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/circulator
	name = "Circulator/Heat Exchanger"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/binary/circulator

/obj/item/circuitboard/machine/emitter
	name = "Emitter"
	icon_state = "engineering"
	desc = "You can change its laser configuration with a screwdriver"
	build_path = /obj/machinery/power/emitter
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/emitter/drill
	name = "Drilling Emitter"
	icon_state = "engineering"
	desc = "You can change its modulator with a screwdriver"
	build_path = /obj/machinery/power/emitter/drill
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/emitter/screwdriver_act(mob/living/user, obj/item/tool)
	if(build_path == /obj/machinery/power/emitter)
		name = "Drilling Emitter [name_extension]"
		build_path = /obj/machinery/power/emitter/drill
		to_chat(user, span_notice("You change the Emitter's laser configuration to: [span_italics("DRILL")]"))
	else
		name = "Emitter [name_extension]"
		build_path = /obj/machinery/power/emitter
		to_chat(user, span_notice("You change the Emitter's laser configuration to: [span_italics("NORMAL")]"))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/circuitboard/machine/generator
	name = "Thermo-Electric Generator"
	icon_state = "engineering"
	build_path = /obj/machinery/power/generator

/obj/item/circuitboard/machine/ntnet_relay
	name = "NTNet Relay"
	icon_state = "engineering"
	build_path = /obj/machinery/ntnet_relay
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 1,
	)

/obj/item/circuitboard/machine/pacman
	name = "PACMAN-type Generator"
	icon_state = "engineering"
	build_path = /obj/machinery/power/port_gen/pacman
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/pacman/super
	name = "SUPERPACMAN-type Generator"
	build_path = /obj/machinery/power/port_gen/pacman/super

/obj/item/circuitboard/machine/pacman/mrs
	name = "MRSPACMAN-type Generator"
	build_path = /obj/machinery/power/port_gen/pacman/mrs

/obj/item/circuitboard/machine/power_compressor
	name = "Power Compressor"
	icon_state = "engineering"
	build_path = /obj/machinery/power/compressor
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/manipulator = 6,
	)

/obj/item/circuitboard/machine/power_turbine
	name = "Power Turbine"
	icon_state = "engineering"
	build_path = /obj/machinery/power/turbine
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 6,
	)

/obj/item/circuitboard/machine/igniter
	name = "Igniter"
	icon_state = "engineering"
	build_path = /obj/machinery/igniter
	req_components = list(
		/obj/item/assembly/igniter = 1,
	)

/obj/item/circuitboard/machine/protolathe/department/engineering
	name = "Departmental Protolathe - Engineering"
	icon_state = "engineering"
	build_path = /obj/machinery/rnd/production/protolathe/department/engineering

/obj/item/circuitboard/machine/rtg
	name = "RTG"
	icon_state = "engineering"
	build_path = /obj/machinery/power/rtg
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/sheet/mineral/uranium = 10, // We have no Pu-238, and this is the closest thing to it.
	)

/obj/item/circuitboard/machine/rtg/advanced
	name = "Advanced RTG"
	build_path = /obj/machinery/power/rtg/advanced
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stack/sheet/mineral/plasma = 5,
	)

/obj/item/circuitboard/machine/shuttle/engine
	name = "Thruster"
	icon_state = "engineering"
	build_path = /obj/machinery/shuttle/engine

/obj/item/circuitboard/machine/shuttle/engine/plasma
	name = "Plasma Thruster"
	build_path = /obj/machinery/shuttle/engine/plasma
	req_components = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/machine/shuttle/engine/void
	name = "Void Thruster"
	build_path = /obj/machinery/shuttle/engine/void
	req_components = list(
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/micro_laser/quadultra = 1,
	)

/obj/item/circuitboard/machine/shuttle/heater
	name = "Electronic Engine Heater"
	build_path = /obj/machinery/atmospherics/components/unary/shuttle/heater
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/matter_bin = 1,
	)

/obj/item/circuitboard/machine/plasma_refiner
	name = "Plasma Refinery"
	build_path = /obj/machinery/atmospherics/components/unary/plasma_refiner
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/assembly/igniter = 1,
	)

/obj/item/circuitboard/machine/scanner_gate
	name = "Scanner Gate"
	icon_state = "engineering"
	build_path = /obj/machinery/scanner_gate
	req_components = list(
		/obj/item/stock_parts/scanning_module = 3,
	)

/obj/item/circuitboard/machine/smes
	name = "SMES"
	icon_state = "engineering"
	build_path = /obj/machinery/power/smes
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/matter_bin = 5,
		/obj/item/stock_parts/capacitor = 1,
	)

/obj/item/circuitboard/machine/techfab/department/engineering
	name = "Departmental Techfab - Engineering"
	icon_state = "engineering"
	build_path = /obj/machinery/rnd/production/techfab/department/engineering

/obj/item/circuitboard/machine/teleporter_hub
	name = "Teleporter Hub"
	icon_state = "engineering"
	build_path = /obj/machinery/teleport/hub
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 3,
		/obj/item/stock_parts/matter_bin = 1,
	)
	def_components = list(
		/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial,
	)

/obj/item/circuitboard/machine/teleporter_station
	name = "Teleporter Station"
	icon_state = "engineering"
	build_path = /obj/machinery/teleport/station
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/sheet/glass = 1,
	)
	def_components = list(
		/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial,
	)

/obj/item/circuitboard/machine/thermomachine
	name = "Thermomachine"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/unary/thermomachine
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	var/pipe_layer = PIPING_LAYER_DEFAULT

/obj/item/circuitboard/machine/thermomachine/multitool_act(mob/living/user, obj/item/tool)
	pipe_layer = (pipe_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (pipe_layer + 1)
	to_chat(user, span_notice("You change the circuitboard to layer [pipe_layer]."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/circuitboard/machine/thermomachine/examine()
	. = ..()
	. += span_info("It is set to layer [pipe_layer].")

/obj/item/circuitboard/machine/suit_storage_unit
	name = "Suit Storage Unit"
	icon_state = "generic"
	build_path = /obj/machinery/suit_storage_unit/
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/machine/shieldwallgen
	name = "Shield-Wall Generator"
	icon_state = "engineering"
	build_path = /obj/machinery/power/shieldwallgen
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/sheet/plasmaglass = 1,
		/obj/item/stack/cable_coil = 5,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/shieldwallgen/atmos
	name = "Atmospheric Holofield Generator"
	build_path = /obj/machinery/power/shieldwallgen/atmos

/obj/item/circuitboard/machine/shieldwallgen/atmos/strong
	name = "High Power Atmospheric Holofield Generator"
	build_path = /obj/machinery/power/shieldwallgen/atmos/strong
	req_components = list(
		/obj/item/stock_parts/manipulator/nano = 2,
		/obj/item/stock_parts/micro_laser/high = 2,
		/obj/item/stock_parts/capacitor/adv = 2,
		/obj/item/stack/sheet/plasmaglass = 1,
		/obj/item/stack/cable_coil = 5,
	)

//Generic

/obj/item/circuitboard/machine/circuit_imprinter
	name = "Circuit Imprinter"
	icon_state = "generic"
	build_path = /obj/machinery/rnd/production/circuit_imprinter
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/reagent_containers/cup/beaker = 2,
	)

/obj/item/circuitboard/machine/circuit_imprinter/department
	name = "Departmental Circuit Imprinter"
	build_path = /obj/machinery/rnd/production/circuit_imprinter/department

/obj/item/circuitboard/machine/holopad
	name = "AI Holopad"
	icon_state = "generic"
	build_path = /obj/machinery/holopad
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
	)
	needs_anchored = FALSE //wew lad

/obj/item/circuitboard/machine/launchpad
	name = "Bluespace Launchpad"
	icon_state = "generic"
	build_path = /obj/machinery/launchpad
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stock_parts/manipulator = 1,
	)
	def_components = list(
		/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial,
	)

/obj/item/circuitboard/machine/paystand
	name = "Pay Stand"
	icon_state = "generic"
	build_path = /obj/machinery/paystand

/obj/item/circuitboard/machine/protolathe
	name = "Protolathe"
	icon_state = "generic"
	build_path = /obj/machinery/rnd/production/protolathe
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/cup/beaker = 2,
	)

/obj/item/circuitboard/machine/protolathe/department
	name = "Departmental Protolathe"
	build_path = /obj/machinery/rnd/production/protolathe/department

/obj/item/circuitboard/machine/reagentgrinder
	name = "All-In-One Grinder"
	icon_state = "generic"
	build_path = /obj/machinery/reagentgrinder/constructed
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/smartfridge
	name = "Smartfridge"
	icon_state = "generic"
	build_path = /obj/machinery/smartfridge
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
	)
	needs_anchored = FALSE
	var/static/list/fridges_name_paths = list(
		/obj/machinery/smartfridge = "plant produce",
		/obj/machinery/smartfridge/food = "food",
		/obj/machinery/smartfridge/drinks = "drinks",
		/obj/machinery/smartfridge/extract = "slimes",
		/obj/machinery/smartfridge/organ = "organs",
		/obj/machinery/smartfridge/chemistry = "chems",
		/obj/machinery/smartfridge/chemistry/virology = "viruses",
		/obj/machinery/smartfridge/disks = "disks",
	)
	var/is_special_type = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/circuitboard/machine/smartfridge)

/obj/item/circuitboard/machine/smartfridge/apply_default_parts(obj/machinery/smartfridge/M)
	build_path = M.base_build_path
	if(!fridges_name_paths.Find(build_path))
		name = "[initial(M.name)]" //if it's a unique type, give it a unique name.
		is_special_type = TRUE
	return ..()

/obj/item/circuitboard/machine/smartfridge/screwdriver_act(mob/living/user, obj/item/tool)
	if (is_special_type)
		return
	var/position = fridges_name_paths.Find(build_path, fridges_name_paths)
	position = (position == length(fridges_name_paths)) ? 1 : (position + 1)
	build_path = fridges_name_paths[position]
	to_chat(user, span_notice("You set the board to [fridges_name_paths[build_path]]."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/circuitboard/machine/smartfridge/examine(mob/user)
	. = ..()
	if(is_special_type)
		return
	. += span_info("[src] is set to [fridges_name_paths[build_path]]. You can use a screwdriver to reconfigure it.")

/obj/item/circuitboard/machine/dehydrator
	name = "Dehydrator"
	build_path = /obj/machinery/smartfridge/drying
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/portable_thermomachine
	name = "Portable Thermomachine"
	icon_state = "generic"
	build_path = /obj/machinery/portable_thermomachine
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stack/cable_coil = 3,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/techfab
	name = "Techfab"
	icon_state = "generic"
	build_path = /obj/machinery/rnd/production/techfab
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/cup/beaker = 2,
	)

/obj/item/circuitboard/machine/techfab/department
	name = "Departmental Techfab"
	build_path = /obj/machinery/rnd/production/techfab/department

/obj/item/circuitboard/machine/vendor
	name = "Custom Vendor"
	icon_state = "generic"
	desc = "You can turn the \"brand selection\" dial using a screwdriver."
	custom_premium_price = 25
	build_path = /obj/machinery/vending/custom
	req_components = list(
		/obj/item/vending_refill/custom = 1,
	)

	/// Assoc list (machine name = machine typepath) of all vendors that can be chosen when the circuit is screwdrivered
	var/static/list/valid_vendor_names_paths

/obj/item/circuitboard/machine/vendor/Initialize(mapload)
	. = ..()
	if(length(valid_vendor_names_paths))
		return

	valid_vendor_names_paths = list()
	for(var/obj/machinery/vending/vendor_type as anything in subtypesof(/obj/machinery/vending))
		if(vendor_type::refill_canister)
			valid_vendor_names_paths[vendor_type::name] = vendor_type

/obj/item/circuitboard/machine/vendor/screwdriver_act(mob/living/user, obj/item/tool)
	var/choice = tgui_input_list(user, "Choose a new brand", "Select an Item", sort_list(valid_vendor_names_paths))
	if(isnull(choice) || QDELETED(src))
		return
	set_type(valid_vendor_names_paths[choice])
	return TOOL_ACT_TOOLTYPE_SUCCESS

/**
 * Sets circuitboard details based on the vending machine type to create
 *
 * Arguments
 * * obj/machinery/vending/typepath - the vending machine type to create
*/
/obj/item/circuitboard/machine/vendor/proc/set_type(obj/machinery/vending/typepath)
	build_path = typepath
	name = "[typepath::name] Vendor"
	req_components = list(initial(typepath.refill_canister) = 1)

/obj/item/circuitboard/machine/vendor/apply_default_parts(obj/machinery/machine)
	set_type(machine.type)
	return ..()

/obj/item/circuitboard/machine/vending/donksofttoyvendor
	name = "Donksoft Toy Vendor"
	icon_state = "generic"
	build_path = /obj/machinery/vending/donksofttoyvendor
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/vending_refill/donksoft = 1,
	)

/obj/item/circuitboard/machine/vending/syndicatedonksofttoyvendor
	name = "Syndicate Donksoft Toy Vendor"
	icon_state = "generic"
	build_path = /obj/machinery/vending/toyliberationstation
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/vending_refill/donksoft = 1,
	)

/obj/item/circuitboard/machine/fax
	name = "Fax Machine"
	build_path = /obj/machinery/fax
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

//Medical

/obj/item/circuitboard/machine/chem_dispenser
	name = "Chem Dispenser"
	icon_state = "medical"
	build_path = /obj/machinery/chem_dispenser
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell = 1,
	)
	def_components = list(
		/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_dispenser/botany //probably should be generic but who cares
	name = "Minor Botanical Chem Dispenser"
	icon_state = "service"
	build_path = /obj/machinery/chem_dispenser/mutagensaltpetersmall
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell = 1,
	)
	def_components = list(
		/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_dispenser/fullupgrade
	build_path = /obj/machinery/chem_dispenser/fullupgrade
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 2,
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/manipulator/femto = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell/bluespace = 1,
	)

/obj/item/circuitboard/machine/chem_dispenser/mutagensaltpeter
	build_path = /obj/machinery/chem_dispenser/mutagensaltpeter
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 2,
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/manipulator/femto = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell/bluespace = 1,
	)

/obj/item/circuitboard/machine/chem_dispenser/abductor
	name = "Reagent Synthesizer"
	name_extension = "(Abductor Machine Board)"
	icon_state = "abductor_mod"
	build_path = /obj/machinery/chem_dispenser/abductor
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 2,
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/manipulator/femto = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell/bluespace = 1,
	)
	def_components = list(
		/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_heater
	name = "Chemical Heater"
	icon_state = "medical"
	build_path = /obj/machinery/chem_heater
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/machine/chem_master
	name = "ChemMaster 3000"
	icon_state = "medical"
	build_path = /obj/machinery/chem_master
	desc = "You can turn the \"mode selection\" dial using a screwdriver."
	req_components = list(
		/obj/item/reagent_containers/cup/beaker = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	def_components = list(
		/obj/item/reagent_containers/cup/beaker = /obj/item/reagent_containers/cup/beaker/large,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_master/screwdriver_act(mob/living/user, obj/item/tool)
	var/new_name = "ChemMaster"
	var/new_path = /obj/machinery/chem_master

	if(build_path == /obj/machinery/chem_master)
		new_name = "CondiMaster"
		new_path = /obj/machinery/chem_master/condimaster

	build_path = new_path
	name = "[new_name] 3000"
	to_chat(user, span_notice("You change the circuit board setting to \"[new_name]\"."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/circuitboard/machine/clonepod
	name = "Clone Pod"
	icon_state = "medical"
	build_path = /obj/machinery/clonepod
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/cup/beaker = 2,
	)

/obj/item/circuitboard/machine/clonepod/experimental
	name = "Experimental Clone Pod"
	build_path = /obj/machinery/clonepod/experimental

/obj/item/circuitboard/machine/clonescanner
	name = "Cloning Scanner"
	icon_state = "medical"
	build_path = /obj/machinery/dna_scannernew
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2,
	)

/obj/item/circuitboard/machine/cryo_tube
	name = "Cryotube"
	icon_state = "medical"
	build_path = /obj/machinery/cryo_cell
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 4,
	)

/obj/item/circuitboard/machine/fat_sucker
	name = "Lipid Extractor"
	icon_state = "medical"
	build_path = /obj/machinery/fat_sucker
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/scalpel = 1,
	)

/obj/item/circuitboard/machine/harvester
	name = "Harvester"
	icon_state = "medical"
	build_path = /obj/machinery/harvester
	req_components = list(
		/obj/item/stock_parts/micro_laser = 4,
	)

/obj/item/circuitboard/machine/limbgrower
	name = "Limb Grower"
	icon_state = "medical"
	build_path = /obj/machinery/limbgrower
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/reagent_containers/cup/beaker = 2,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/machine/protolathe/department/medical
	name = "Departmental Protolathe - Medical"
	icon_state = "medical"
	build_path = /obj/machinery/rnd/production/protolathe/department/medical

/obj/item/circuitboard/machine/sleeper
	name = "Sleeper"
	icon_state = "medical"
	build_path = /obj/machinery/sleeper
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 2,
	)

/obj/item/circuitboard/machine/sleeper/fullupgrade
	build_path = /obj/machinery/sleeper/syndie/fullupgrade
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 1,
		/obj/item/stock_parts/manipulator/femto = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 2,
	)

/obj/item/circuitboard/machine/smoke_machine
	name = "Smoke Machine"
	icon_state = "medical"
	build_path = /obj/machinery/smoke_machine
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/stasis
	name = "Lifeform Stasis Unit"
	icon_state = "medical"
	build_path = /obj/machinery/stasis
	req_components = list(
		/obj/item/stack/cable_coil = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/capacitor = 1,
	)

/obj/item/circuitboard/machine/techfab/department/medical
	name = "Departmental Techfab - Medical"
	icon_state = "medical"
	build_path = /obj/machinery/rnd/production/techfab/department/medical

//Science

/obj/item/circuitboard/machine/circuit_imprinter/department/science
	name = "Departmental Circuit Imprinter - Science"
	icon_state = "science"
	build_path = /obj/machinery/rnd/production/circuit_imprinter/department/science

/obj/item/circuitboard/machine/cyborgrecharger
	name = "Cyborg Recharger"
	icon_state = "science"
	build_path = /obj/machinery/recharge_station
	req_components = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stock_parts/manipulator = 1,
	)
	def_components = list(
		/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high,
	)

/obj/item/circuitboard/machine/destructive_analyzer
	name = "Destructive Analyzer"
	icon_state = "science"
	build_path = /obj/machinery/rnd/destructive_analyzer
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
	)


/obj/item/circuitboard/machine/mech_recharger
	name = "Mechbay Recharger"
	icon_state = "science"
	build_path = /obj/machinery/mech_bay_recharge_port
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 5,
	)

/obj/item/circuitboard/machine/mechfab
	name = "Exosuit Fabricator"
	icon_state = "science"
	build_path = /obj/machinery/modular_fabricator/exosuit_fab
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/machine/monkey_recycler
	name = "Monkey Recycler"
	icon_state = "science"
	build_path = /obj/machinery/monkey_recycler
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/nanite_chamber
	name = "Nanite Chamber"
	icon_state = "science"
	build_path = /obj/machinery/nanite_chamber
	req_components = list(
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/item/circuitboard/machine/nanite_program_hub
	name = "Nanite Program Hub"
	icon_state = "science"
	build_path = /obj/machinery/nanite_program_hub
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/item/circuitboard/machine/nanite_programmer
	name = "Nanite Programmer"
	icon_state = "science"
	build_path = /obj/machinery/nanite_programmer
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/scanning_module = 1,
	)

/obj/item/circuitboard/machine/processor/slime
	name = "Slime Processor"
	icon_state = "science"
	build_path = /obj/machinery/processor/slime

/obj/item/circuitboard/machine/protolathe/department/science
	name = "Departmental Protolathe - Science"
	icon_state = "science"
	build_path = /obj/machinery/rnd/production/protolathe/department/science

/obj/item/circuitboard/machine/public_nanite_chamber
	name = "Public Nanite Chamber"
	icon_state = "science"
	build_path = /obj/machinery/public_nanite_chamber
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1,
	)
	var/cloud_id = 1

/obj/item/circuitboard/machine/public_nanite_chamber/multitool_act(mob/living/user)
	var/new_cloud = tgui_input_number(user, "Set the public nanite chamber's Cloud ID (1-100).", "Cloud ID", cloud_id, max_value = 100, min_value = 1)
	if(isnull(new_cloud))
		return
	cloud_id = new_cloud
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/circuitboard/machine/public_nanite_chamber/examine(mob/user)
	. = ..()
	. += span_info("Cloud ID is currently set to [cloud_id].")

/obj/item/circuitboard/machine/quantumpad
	name = "Quantum Pad"
	icon_state = "science"
	build_path = /obj/machinery/quantumpad
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
	)
	def_components = list(
		/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial,
	)

/obj/item/circuitboard/machine/rdserver
	name = "R&D Server"
	icon_state = "science"
	build_path = /obj/machinery/rnd/server
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 1,
	)

/obj/item/circuitboard/machine/rdserver/oldstation
	name = "Ancient R&D Server"
	build_path = /obj/machinery/rnd/server/oldstation

/obj/item/circuitboard/machine/rdserver/golem
	name = "Ancient R&D Server"
	build_path = /obj/machinery/rnd/server/golem

/obj/item/circuitboard/machine/techfab/department/science
	name = "Departmental Techfab - Science"
	icon_state = "science"
	build_path = /obj/machinery/rnd/production/techfab/department/science

/obj/item/circuitboard/machine/ecto_sniffer
	name = "Ectoscopic Sniffer"
	build_path = /obj/machinery/ecto_sniffer
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
	)

//Security

/obj/item/circuitboard/machine/protolathe/department/security
	name = "Departmental Protolathe - Security"
	icon_state = "security"
	build_path = /obj/machinery/rnd/production/protolathe/department/security

/obj/item/circuitboard/machine/recharger
	name = "Weapon Recharger"
	icon_state = "security"
	build_path = /obj/machinery/recharger
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/techfab/department/security
	name = "Departmental Techfab - Security"
	icon_state = "security"
	build_path = /obj/machinery/rnd/production/techfab/department/security

//Service

/obj/item/circuitboard/machine/photobooth
	name = "Photobooth"
	icon_state = "service"
	build_path = /obj/machinery/photobooth
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)

/obj/item/circuitboard/machine/photobooth/security
	name = "Security Photobooth"
	icon_state = "security"
	build_path = /obj/machinery/photobooth/security

/obj/item/circuitboard/machine/biogenerator
	name = "Biogenerator"
	icon_state = "service"
	build_path = /obj/machinery/biogenerator
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1,
	)

/obj/item/circuitboard/machine/chem_dispenser/drinks
	name = "Soda Dispenser"
	icon_state = "service"
	build_path = /obj/machinery/chem_dispenser/drinks

/obj/item/circuitboard/machine/chem_dispenser/drinks/fullupgrade
	build_path = /obj/machinery/chem_dispenser/drinks/fullupgrade
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 2,
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/manipulator/femto = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell/bluespace = 1,
	)

/obj/item/circuitboard/machine/chem_dispenser/drinks/beer
	name = "Booze Dispenser"
	icon_state = "service"
	build_path = /obj/machinery/chem_dispenser/drinks/beer

/obj/item/circuitboard/machine/chem_dispenser/drinks/beer/fullupgrade
	build_path = /obj/machinery/chem_dispenser/drinks/beer/fullupgrade
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 2,
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/manipulator/femto = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell/bluespace = 1,
	)

/obj/item/circuitboard/machine/chem_master/condi
	name = "CondiMaster 3000"
	icon_state = "service"
	build_path = /obj/machinery/chem_master/condimaster

/obj/item/circuitboard/machine/deep_fryer
	name = "Deep Fryer"
	icon_state = "service"
	build_path = /obj/machinery/deepfryer
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/griddle
	name = "Griddle"
	icon_state = "service"
	build_path = /obj/machinery/griddle
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/oven
	name = "Oven"
	icon_state = "service"
	build_path = /obj/machinery/oven
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/dish_drive
	name = "dish drive"
	icon_state = "service"
	build_path = /obj/machinery/dish_drive
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 2,
	)
	needs_anchored = FALSE
	var/suction = TRUE
	var/transmit = TRUE

/obj/item/circuitboard/machine/dish_drive/examine(mob/user)
	. = ..()
	. += span_info("Its suction function is [suction ? "enabled" : "disabled"]. Use it in-hand to switch.")
	. += span_info("Its disposal auto-transmit function is [transmit ? "enabled" : "disabled"]. <b>Alt-click</b> it to switch.")

/obj/item/circuitboard/machine/dish_drive/attack_self(mob/living/user)
	suction = !suction
	to_chat(user, span_notice("You [suction ? "enable" : "disable"] the board's suction function."))

/obj/item/circuitboard/machine/dish_drive/AltClick(mob/living/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	transmit = !transmit
	to_chat(user, span_notice("You [transmit ? "enable" : "disable"] the board's automatic disposal transmission."))

/obj/item/circuitboard/machine/gibber
	name = "Gibber"
	icon_state = "service"
	build_path = /obj/machinery/gibber
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/hydroponics
	name = "Hydroponics Tray"
	icon_state = "service"
	build_path = /obj/machinery/hydroponics/constructable
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/microwave
	name = "Microwave"
	icon_state = "service"
	build_path = /obj/machinery/microwave
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 2,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/mass_driver
	name = "Mass Driver"
	build_path = /obj/machinery/mass_driver
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 1,
	)

/obj/item/circuitboard/machine/plantgenes
	name = "Plant DNA Manipulator"
	icon_state = "service"
	build_path = /obj/machinery/plantgenes
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/scanning_module = 1,
	)

/obj/item/circuitboard/machine/processor
	name = "food processor"
	icon_state = "service"
	build_path = /obj/machinery/processor
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/processor/screwdriver_act(mob/living/user, obj/item/tool)
	if(build_path == /obj/machinery/processor)
		name = "Slime Processor [name_extension]"
		build_path = /obj/machinery/processor/slime
		to_chat(user, span_notice("Name protocols successfully updated."))
	else
		name = "Food Processor [name_extension]"
		build_path = /obj/machinery/processor
		to_chat(user, span_notice("Defaulting name protocols."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/circuitboard/machine/protolathe/department/service
	name = "Departmental Protolathe - Service"
	icon_state = "service"
	build_path = /obj/machinery/rnd/production/protolathe/department/service

/obj/item/circuitboard/machine/recycler
	name = "Recycler"
	icon_state = "service"
	build_path = /obj/machinery/recycler
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/seed_extractor
	name = "Seed Extractor"
	icon_state = "service"
	build_path = /obj/machinery/seed_extractor
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/techfab/department/service
	name = "Departmental Techfab - Service"
	icon_state = "service"
	build_path = /obj/machinery/rnd/production/techfab/department/service

//Supply

/obj/item/circuitboard/machine/techfab/department/cargo
	name = "Departmental Techfab - Cargo"
	icon_state = "supply"
	build_path = /obj/machinery/rnd/production/techfab/department/cargo

/obj/item/circuitboard/machine/mining_equipment_vendor
	name = "Mining Equipment Vendor"
	icon_state = "supply"
	build_path = /obj/machinery/gear_requisition/mining
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/matter_bin = 3,
	)

/obj/item/circuitboard/machine/exploration_equipment_vendor
	name = "Exploration Equipment Vendor"
	icon_state = "supply"
	build_path = /obj/machinery/gear_requisition/exploration
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/matter_bin = 3,
	)


/obj/item/circuitboard/machine/mining_equipment_vendor/golem
	name = "Golem Ship Equipment Vendor"
	build_path = /obj/machinery/gear_requisition/mining/golem

/obj/item/circuitboard/machine/pump
	name = "Portable Liquid Pump"
	icon_state = "supply"
	build_path = /obj/machinery/power/liquid_pump
	needs_anchored = FALSE
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 2,
	)

/obj/item/circuitboard/machine/ore_redemption
	name = "Ore Redemption"
	icon_state = "supply"
	build_path = /obj/machinery/mineral/ore_redemption
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/assembly/igniter = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/ore_silo
	name = "Ore Silo"
	icon_state = "supply"
	build_path = /obj/machinery/ore_silo

/obj/item/circuitboard/machine/protolathe/department/cargo
	name = "Departmental Protolathe - Cargo"
	icon_state = "supply"
	build_path = /obj/machinery/rnd/production/protolathe/department/cargo

/obj/item/circuitboard/machine/stacking_machine
	name = "Stacking Machine"
	icon_state = "supply"
	build_path = /obj/machinery/mineral/stacking_machine
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 2,
	)

/obj/item/circuitboard/machine/stacking_unit_console
	name = "Stacking Machine Console"
	icon_state = "supply"
	build_path = /obj/machinery/mineral/stacking_unit_console
	req_components = list(
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 5,
	)

/obj/item/circuitboard/machine/processing_unit
	name = "Furnace"
	build_path = /obj/machinery/mineral/processing_unit
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/assembly/igniter = 1,
	)

/obj/item/circuitboard/machine/processing_unit_console
	name = "Furnace Console"
	build_path = /obj/machinery/mineral/processing_unit_console

//Misc

/obj/item/circuitboard/machine/sheetifier
	name = "Sheet-Meister 2000"
	icon_state = "supply"
	build_path = /obj/machinery/sheetifier
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 2,
	)

/obj/item/circuitboard/machine/abductor
	name = "alien board (Report This)"
	icon_state = "abductor_mod"

/obj/item/circuitboard/machine/abductor/core
	name = "alien board"
	name_extension = "(Void Core)"
	build_path = /obj/machinery/power/rtg/abductor
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/cell/infinite/abductor = 1,
	)
	def_components = list(
		/obj/item/stock_parts/capacitor = /obj/item/stock_parts/capacitor/quadratic,
		/obj/item/stock_parts/micro_laser = /obj/item/stock_parts/micro_laser/quadultra,
	)

/obj/item/circuitboard/machine/plantgenes/vault
	name = "Plant DNA manipulator"
	name_extension = "(Abductor Machine Board)"
	icon_state = "abductor_mod"
	// It wasn't made by actual abductors race, so no abductor tech here.
	def_components = list(
		/obj/item/stock_parts/manipulator = /obj/item/stock_parts/manipulator/femto,
		/obj/item/stock_parts/micro_laser = /obj/item/stock_parts/micro_laser/quadultra,
		/obj/item/stock_parts/scanning_module = /obj/item/stock_parts/scanning_module/triphasic,
	)
