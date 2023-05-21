//Command


/obj/item/circuitboard/machine/bsa/back
	name = "bluespace artillery generator (Machine Board)"
	icon_state = "command"
	build_path = /obj/machinery/bsa/back //No freebies!
	req_components = list(
		/obj/item/stock_parts/capacitor/quadratic = 5,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/middle
	name = "bluespace artillery fusor (Machine Board)"
	icon_state = "command"
	build_path = /obj/machinery/bsa/middle
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 20,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/front
	name = "bluespace artillery bore (Machine Board)"
	icon_state = "command"
	build_path = /obj/machinery/bsa/front
	req_components = list(
		/obj/item/stock_parts/manipulator/femto = 5,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/dna_vault
	name = "DNA vault (Machine Board)"
	icon_state = "command"
	build_path = /obj/machinery/dna_vault //No freebies!
	req_components = list(
		/obj/item/stock_parts/capacitor/super = 5,
		/obj/item/stock_parts/manipulator/pico = 5,
		/obj/item/stack/cable_coil = 2)


//Engineering


/obj/item/circuitboard/machine/announcement_system
	name = "announcement system (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/announcement_system
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/autolathe
	name = "autolathe (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/modular_fabricator/autolathe
	req_components = list(
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/grounding_rod
	name = "grounding rod (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/grounding_rod
	req_components = list(/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/telecomms/broadcaster
	name = "subspace broadcaster (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/broadcaster
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/machine/telecomms/bus
	name = "bus mainframe (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/bus
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/machine/telecomms/hub
	name = "hub mainframe (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/hub
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 2)

/obj/item/circuitboard/machine/telecomms/processor
	name = "processor unit (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/processor
	req_components = list(
		/obj/item/stock_parts/manipulator = 3,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/subspace/treatment = 2,
		/obj/item/stock_parts/subspace/analyzer = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/amplifier = 1)

/obj/item/circuitboard/machine/telecomms/receiver
	name = "subspace receiver (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/receiver
	req_components = list(
		/obj/item/stock_parts/subspace/ansible = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/machine/telecomms/relay
	name = "relay mainframe (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/relay
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 2)

/obj/item/circuitboard/machine/telecomms/server
	name = "telecommunication server (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/server
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/machine/telecomms/message_server
	name = "messaging server (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/message_server
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 3)

/obj/item/circuitboard/machine/tesla_coil
	name = "tesla controller (Machine Board)"
	icon_state = "engineering"
	desc = "You can use a screwdriver to switch between Research and Power Generation."
	build_path = /obj/machinery/power/tesla_coil
	req_components = list(/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE

#define PATH_POWERCOIL /obj/machinery/power/tesla_coil/power
#define PATH_RPCOIL /obj/machinery/power/tesla_coil/research

/obj/item/circuitboard/machine/tesla_coil/Initialize(mapload)
	. = ..()
	if(build_path)
		build_path = PATH_POWERCOIL

/obj/item/circuitboard/machine/tesla_coil/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		var/obj/item/circuitboard/new_type
		var/new_setting
		switch(build_path)
			if(PATH_POWERCOIL)
				new_type = /obj/item/circuitboard/machine/tesla_coil/research
				new_setting = "Research"
			if(PATH_RPCOIL)
				new_type = /obj/item/circuitboard/machine/tesla_coil/power
				new_setting = "Power"
		name = initial(new_type.name)
		build_path = initial(new_type.build_path)
		I.play_tool_sound(src)
		to_chat(user, "<span class='notice'>You change the circuitboard setting to \"[new_setting]\".</span>")
	else
		return ..()

/obj/item/circuitboard/machine/tesla_coil/power
	name = "tesla coil (Machine Board)"
	build_path = PATH_POWERCOIL

/obj/item/circuitboard/machine/tesla_coil/research
	name = "tesla corona researcher (Machine Board)"
	build_path = PATH_RPCOIL

#undef PATH_POWERCOIL
#undef PATH_RPCOIL


/obj/item/circuitboard/machine/cell_charger
	name = "cell charger (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/cell_charger
	req_components = list(/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/circulator
	name = "circulator/heat exchanger (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/binary/circulator
	req_components = list()

/obj/item/circuitboard/machine/emitter
	name = "emitter (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/emitter
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/generator
	name = "thermo-electric generator (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/generator
	req_components = list()

/obj/item/circuitboard/machine/ntnet_relay
	name = "NTNet relay (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/ntnet_relay
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/machine/pacman
	name = "PACMAN-type generator (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/port_gen/pacman
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/pacman/super
	name = "SUPERPACMAN-type generator (Machine Board)"
	build_path = /obj/machinery/power/port_gen/pacman/super

/obj/item/circuitboard/machine/pacman/mrs
	name = "MRSPACMAN-type generator (Machine Board)"
	build_path = /obj/machinery/power/port_gen/pacman/mrs

/obj/item/circuitboard/machine/power_compressor
	name = "power compressor (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/compressor
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/manipulator = 6)

/obj/item/circuitboard/machine/power_turbine
	name = "power turbine (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/turbine
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 6)

/obj/item/circuitboard/machine/igniter
	name = "igniter (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/igniter
	req_components = list(
		/obj/item/assembly/igniter = 1
	)

/obj/item/circuitboard/machine/protolathe/department/engineering
	name = "departmental protolathe - engineering (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/rnd/production/protolathe/department/engineering

/obj/item/circuitboard/machine/rad_collector
	name = "radiation collector (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/rad_collector
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/sheet/plasmarglass = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/rtg
	name = "RTG (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/rtg
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/sheet/mineral/uranium = 10) // We have no Pu-238, and this is the closest thing to it.

/obj/item/circuitboard/machine/rtg/advanced
	name = "advanced RTG (Machine Board)"
	build_path = /obj/machinery/power/rtg/advanced
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stack/sheet/mineral/plasma = 5)

/obj/item/circuitboard/machine/shuttle/engine
	name = "thruster (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/shuttle/engine
	req_components = list()

/obj/item/circuitboard/machine/shuttle/engine/plasma
	name = "plasma thruster (Machine Board)"
	build_path = /obj/machinery/shuttle/engine/plasma
	req_components = list(/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/machine/shuttle/engine/void
	name = "void thruster (Machine Board)"
	build_path = /obj/machinery/shuttle/engine/void
	req_components = list(/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/micro_laser/quadultra = 1)

/obj/item/circuitboard/machine/shuttle/heater
	name = "electronic engine heater (Machine Board)"
	build_path = /obj/machinery/atmospherics/components/unary/shuttle/heater
	req_components = list(/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/matter_bin = 1)

/obj/item/circuitboard/machine/plasma_refiner
	name = "plasma refinery (Machine Board)"
	build_path = /obj/machinery/atmospherics/components/unary/plasma_refiner
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/assembly/igniter = 1
	)

/obj/item/circuitboard/machine/scanner_gate
	name = "scanner gate (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/scanner_gate
	req_components = list(
		/obj/item/stock_parts/scanning_module = 3)

/obj/item/circuitboard/machine/smes
	name = "SMES (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/smes
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/cell = 5,
		/obj/item/stock_parts/capacitor = 1)
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high/empty)

/obj/item/circuitboard/machine/techfab/department/engineering
	name = "departmental techfab - engineering (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/rnd/production/techfab/department/engineering

/obj/item/circuitboard/machine/teleporter_hub
	name = "teleporter hub (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/teleport/hub
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 3,
		/obj/item/stock_parts/matter_bin = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/teleporter_station
	name = "teleporter station (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/teleport/station
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/sheet/glass = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/thermomachine
	name = "thermomachine (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/unary/thermomachine/freezer
	var/pipe_layer = PIPING_LAYER_DEFAULT
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/thermomachine/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if(istype(I))
		pipe_layer = (pipe_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (pipe_layer + 1)
		to_chat(user, "<span class='notice'>You change the circuitboard to layer [pipe_layer].</span>")

/obj/item/circuitboard/machine/thermomachine/examine()
	. = ..()
	. += "<span class='notice'>It is set to layer [pipe_layer].</span>"

/obj/item/circuitboard/machine/suit_storage_unit
	name = "Suit Storage Unit (Machine Board)"
	icon_state = "generic"
	build_path = /obj/machinery/suit_storage_unit/
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1)

//Generic


/obj/item/circuitboard/machine/circuit_imprinter
	name = "circuit imprinter (Machine Board)"
	icon_state = "generic"
	build_path = /obj/machinery/rnd/production/circuit_imprinter
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/circuit_imprinter/department
	name = "departmental circuit imprinter (Machine Board)"
	build_path = /obj/machinery/rnd/production/circuit_imprinter/department

/obj/item/circuitboard/machine/holopad
	name = "AI holopad (Machine Board)"
	icon_state = "generic"
	build_path = /obj/machinery/holopad
	req_components = list(/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE //wew lad

/obj/item/circuitboard/machine/launchpad
	name = "bluespace launchpad (Machine Board)"
	icon_state = "generic"
	build_path = /obj/machinery/launchpad
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stock_parts/manipulator = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/paystand
	name = "pay stand (Machine Board)"
	icon_state = "generic"
	build_path = /obj/machinery/paystand
	req_components = list()

/obj/item/circuitboard/machine/protolathe
	name = "protolathe (Machine Board)"
	icon_state = "generic"
	build_path = /obj/machinery/rnd/production/protolathe
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/protolathe/department
	name = "departmental protolathe (Machine Board)"
	build_path = /obj/machinery/rnd/production/protolathe/department

/obj/item/circuitboard/machine/reagentgrinder
	name = "all-in-one grinder (Machine Board)"
	icon_state = "generic"
	build_path = /obj/machinery/reagentgrinder/constructed
	req_components = list(
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/smartfridge
	name = "smartfridge (Machine Board)"
	icon_state = "generic"
	build_path = /obj/machinery/smartfridge
	req_components = list(/obj/item/stock_parts/matter_bin = 1)
	var/static/list/fridges_name_paths = list(/obj/machinery/smartfridge = "plant produce",
		/obj/machinery/smartfridge/food = "food",
		/obj/machinery/smartfridge/drinks = "drinks",
		/obj/machinery/smartfridge/extract = "slimes",
		/obj/machinery/smartfridge/organ = "organs",
		/obj/machinery/smartfridge/chemistry = "chems",
		/obj/machinery/smartfridge/chemistry/virology = "viruses",
		/obj/machinery/smartfridge/disks = "disks")
	needs_anchored = FALSE

/obj/item/circuitboard/machine/smartfridge/Initialize(mapload, new_type)
	if(new_type)
		build_path = new_type
	return ..()

/obj/item/circuitboard/machine/smartfridge/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		var/position = fridges_name_paths.Find(build_path, fridges_name_paths)
		position = (position == fridges_name_paths.len) ? 1 : (position + 1)
		build_path = fridges_name_paths[position]
		to_chat(user, "<span class='notice'>You set the board to [fridges_name_paths[build_path]].</span>")
	else
		return ..()

/obj/item/circuitboard/machine/smartfridge/examine(mob/user)
	. = ..()
	. += "<span class='info'>[src] is set to [fridges_name_paths[build_path]]. You can use a screwdriver to reconfigure it.</span>"


/obj/item/circuitboard/machine/space_heater
	name = "space heater (Machine Board)"
	icon_state = "generic"
	build_path = /obj/machinery/space_heater
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/cable_coil = 3)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/techfab
	name = "techfab (Machine Board)"
	icon_state = "generic"
	build_path = /obj/machinery/rnd/production/techfab
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/techfab/department
	name = "departmental techfab (Machine Board)"
	build_path = /obj/machinery/rnd/production/techfab/department

/obj/item/circuitboard/machine/vendor
	name = "custom vendor (Machine Board)"
	icon_state = "generic"
	desc = "You can turn the \"brand selection\" dial using a screwdriver."
	custom_premium_price = 30
	build_path = /obj/machinery/vending/custom
	req_components = list(/obj/item/vending_refill/custom = 1)

	var/static/list/vending_names_paths = list(
		/obj/machinery/vending/boozeomat = "Booze-O-Mat",
		/obj/machinery/vending/coffee = "Solar's Best Hot Drinks",
		/obj/machinery/vending/snack = "Getmore Chocolate Corp",
		/obj/machinery/vending/cola = "Robust Softdrinks",
		/obj/machinery/vending/cigarette = "ShadyCigs Deluxe",
		/obj/machinery/vending/games = "\improper Good Clean Fun",
		/obj/machinery/vending/autodrobe = "AutoDrobe",
		/obj/machinery/vending/wardrobe/sec_wardrobe = "SecDrobe",
		/obj/machinery/vending/wardrobe/det_wardrobe = "DetDrobe",
		/obj/machinery/vending/wardrobe/medi_wardrobe = "MediDrobe",
		/obj/machinery/vending/wardrobe/engi_wardrobe = "EngiDrobe",
		/obj/machinery/vending/wardrobe/atmos_wardrobe = "AtmosDrobe",
		/obj/machinery/vending/wardrobe/cargo_wardrobe = "CargoDrobe",
		/obj/machinery/vending/wardrobe/robo_wardrobe = "RoboDrobe",
		/obj/machinery/vending/wardrobe/science_wardrobe = "SciDrobe",
		/obj/machinery/vending/wardrobe/hydro_wardrobe = "HyDrobe",
		/obj/machinery/vending/wardrobe/curator_wardrobe = "CuraDrobe",
		/obj/machinery/vending/wardrobe/bar_wardrobe = "BarDrobe",
		/obj/machinery/vending/wardrobe/chef_wardrobe = "ChefDrobe",
		/obj/machinery/vending/wardrobe/jani_wardrobe = "JaniDrobe",
		/obj/machinery/vending/wardrobe/law_wardrobe = "LawDrobe",
		/obj/machinery/vending/wardrobe/chap_wardrobe = "ChapDrobe",
		/obj/machinery/vending/wardrobe/chem_wardrobe = "ChemDrobe",
		/obj/machinery/vending/wardrobe/gene_wardrobe = "GeneDrobe",
		/obj/machinery/vending/wardrobe/viro_wardrobe = "ViroDrobe",
		/obj/machinery/vending/clothing = "ClothesMate",
		/obj/machinery/vending/medical = "NanoMed Plus",
		/obj/machinery/vending/wallmed = "NanoMed",
		/obj/machinery/vending/assist  = "Vendomat",
		/obj/machinery/vending/engivend = "Engi-Vend",
		/obj/machinery/vending/tool = "YouTool",
		/obj/machinery/vending/hydronutrients = "NutriMax",
		/obj/machinery/vending/hydroseeds = "MegaSeed Servitor",
		/obj/machinery/vending/sustenance = "Sustenance Vendor",
		/obj/machinery/vending/dinnerware = "Plasteel Chef's Dinnerware Vendor",
		/obj/machinery/vending/job_disk = "PTech",
		/obj/machinery/vending/robotics = "Robotech Deluxe",
		/obj/machinery/vending/engineering = "Robco Tool Maker",
		/obj/machinery/vending/sovietsoda = "BODA",
		/obj/machinery/vending/security = "SecTech",
		/obj/machinery/vending/modularpc = "Deluxe Silicate Selections",
		/obj/machinery/vending/custom = "Custom Vendor")

/obj/item/circuitboard/machine/vendor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		var/static/list/display_vending_names_paths
		if(!display_vending_names_paths)
			display_vending_names_paths = list()
			for(var/path in vending_names_paths)
				display_vending_names_paths[vending_names_paths[path]] = path
		var/choice =  input(user,"Choose a new brand","Select an Item") as null|anything in display_vending_names_paths
		set_type(display_vending_names_paths[choice])
	else
		return ..()

/obj/item/circuitboard/machine/vendor/proc/set_type(obj/machinery/vending/typepath)
	build_path = typepath
	name = "[vending_names_paths[build_path]] Vendor (Machine Board)"
	req_components = list(initial(typepath.refill_canister) = 1)

/obj/item/circuitboard/machine/vendor/apply_default_parts(obj/machinery/M)
	for(var/typepath in vending_names_paths)
		if(istype(M, typepath))
			set_type(typepath)
			break
	return ..()


/obj/item/circuitboard/machine/vending/donksofttoyvendor
	name = "Donksoft toy vendor (Machine Board)"
	icon_state = "generic"
	build_path = /obj/machinery/vending/donksofttoyvendor
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/vending_refill/donksoft = 1)

/obj/item/circuitboard/machine/vending/syndicatedonksofttoyvendor
	name = "Syndicate Donksoft toy vendor (Machine Board)"
	icon_state = "generic"
	build_path = /obj/machinery/vending/toyliberationstation
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/vending_refill/donksoft = 1)



//Medical


/obj/item/circuitboard/machine/chem_dispenser
	name = "chem dispenser (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/chem_dispenser
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell = 1)
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_dispenser/botany				//probably should be generic but who cares
	name = "minor botanical chem dispenser (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/chem_dispenser/mutagensaltpetersmall
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell = 1)
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high)
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
	name = "Reagent Synthesizer (Abductor Machine Board)"
	icon_state = "abductor_mod"
	build_path = /obj/machinery/chem_dispenser/abductor
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 2,
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/manipulator/femto = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell/bluespace = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_heater
	name = "chemical heater (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/chem_heater
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/chem_master
	name = "ChemMaster 3000 (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/chem_master
	desc = "You can turn the \"mode selection\" dial using a screwdriver."
	req_components = list(
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_master/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		var/new_name = "ChemMaster"
		var/new_path = /obj/machinery/chem_master

		if(build_path == /obj/machinery/chem_master)
			new_name = "CondiMaster"
			new_path = /obj/machinery/chem_master/condimaster

		build_path = new_path
		name = "[new_name] 3000 (Machine Board)"
		to_chat(user, "<span class='notice'>You change the circuit board setting to \"[new_name]\".</span>")
	else
		return ..()

/obj/item/circuitboard/machine/clonepod
	name = "clone pod (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/clonepod
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/clonepod/experimental
	name = "experimental clone pod (Machine Board)"
	build_path = /obj/machinery/clonepod/experimental

/obj/item/circuitboard/machine/clonescanner
	name = "cloning scanner (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/dna_scannernew
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/cryo_tube
	name = "cryotube (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/atmospherics/components/unary/cryo_cell
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 4)

/obj/item/circuitboard/machine/fat_sucker
	name = "lipid extractor (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/fat_sucker
	req_components = list(/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/scalpel = 1)

/obj/item/circuitboard/machine/harvester
	name = "harvester (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/harvester
	req_components = list(/obj/item/stock_parts/micro_laser = 4)

/obj/item/circuitboard/machine/limbgrower
	name = "limb grower (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/limbgrower
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/protolathe/department/medical
	name = "departmental protolathe - medical (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/rnd/production/protolathe/department/medical

/obj/item/circuitboard/machine/sleeper
	name = "sleeper (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/sleeper
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/machine/sleeper/fullupgrade
	name = "Sleeper (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/sleeper/syndie/fullupgrade
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 1,
		/obj/item/stock_parts/manipulator/femto = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/machine/smoke_machine
	name = "smoke machine (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/smoke_machine
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/stasis
	name = "lifeform stasis unit (Machine Board)"
	icon_state = "medical"
	build_path = /obj/machinery/stasis
	req_components = list(
		/obj/item/stack/cable_coil = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/machine/techfab/department/medical
	name = "departmental techfab - medical (Machine Board) "
	icon_state = "medical"
	build_path = /obj/machinery/rnd/production/techfab/department/medical


//Science

/obj/item/circuitboard/machine/circuit_imprinter/department/science
	name = "departmental circuit imprinter - science (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/production/circuit_imprinter/department/science

/obj/item/circuitboard/machine/cyborgrecharger
	name = "cyborg recharger (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/recharge_station
	req_components = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stock_parts/manipulator = 1)
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high)

/obj/item/circuitboard/machine/destructive_analyzer
	name = "destructive analyzer (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/destructive_analyzer
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/machine/experimentor
	name = "E.X.P.E.R.I-MENTOR (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/experimentor
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/machine/mech_recharger
	name = "mechbay recharger (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/mech_bay_recharge_port
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 5)

/obj/item/circuitboard/machine/mechfab
	name = "exosuit fabricator (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/modular_fabricator/exosuit_fab
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/monkey_recycler
	name = "monkey recycler (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/monkey_recycler
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/nanite_chamber
	name = "nanite chamber (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/nanite_chamber
	req_components = list(
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/nanite_program_hub
	name = "nanite program hub (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/nanite_program_hub
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/nanite_programmer
	name = "nanite programmer (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/nanite_programmer
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/machine/processor/slime
	name = "slime processor (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/processor/slime

/obj/item/circuitboard/machine/protolathe/department/science
	name = "departmental protolathe - science (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/production/protolathe/department/science

/obj/item/circuitboard/machine/public_nanite_chamber
	name = "public nanite chamber (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/public_nanite_chamber
	var/cloud_id = 1
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/public_nanite_chamber/multitool_act(mob/living/user)
	var/new_cloud = input("Set the public nanite chamber's Cloud ID (1-100).", "Cloud ID", cloud_id) as num|null
	if(new_cloud == null)
		return
	cloud_id = CLAMP(round(new_cloud, 1), 1, 100)

/obj/item/circuitboard/machine/public_nanite_chamber/examine(mob/user)
	. = ..()
	. += "Cloud ID is currently set to [cloud_id]."


/obj/item/circuitboard/machine/quantumpad
	name = "quantum pad (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/quantumpad
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/rdserver
	name = "R&D server (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/server
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/machine/techfab/department/science
	name = "departmental techfab - science (Machine Board)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/production/techfab/department/science

/obj/item/circuitboard/machine/ecto_sniffer
	name = "Ectoscopic Sniffer (Machine Board)"
	build_path = /obj/machinery/ecto_sniffer
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1)
//Security


/obj/item/circuitboard/machine/protolathe/department/security
	name = "departmental protolathe - security (Machine Board)"
	icon_state = "security"
	build_path = /obj/machinery/rnd/production/protolathe/department/security

/obj/item/circuitboard/machine/recharger
	name = "weapon recharger (Machine Board)"
	icon_state = "security"
	build_path = /obj/machinery/recharger
	req_components = list(/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/techfab/department/security
	name = "departmental techfab - security (Machine Board)"
	icon_state = "security"
	build_path = /obj/machinery/rnd/production/techfab/department/security


//Service


/obj/item/circuitboard/machine/biogenerator
	name = "biogenerator (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/biogenerator
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/chem_dispenser/drinks
	name = "soda dispenser (Machine Board)"
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
	name = "booze dispenser (Machine Board)"
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
	name = "CondiMaster 3000 (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/chem_master/condimaster

/obj/item/circuitboard/machine/deep_fryer
	name = "deep fryer (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/deepfryer
	req_components = list(/obj/item/stock_parts/micro_laser = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/dish_drive
	name = "dish drive (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/dish_drive
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 2)
	var/suction = TRUE
	var/transmit = TRUE
	needs_anchored = FALSE

/obj/item/circuitboard/machine/dish_drive/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Its suction function is [suction ? "enabled" : "disabled"]. Use it in-hand to switch.</span>\n"+\
	"<span class='notice'>Its disposal auto-transmit function is [transmit ? "enabled" : "disabled"]. Alt-click it to switch.</span>"

/obj/item/circuitboard/machine/dish_drive/attack_self(mob/living/user)
	suction = !suction
	to_chat(user, "<span class='notice'>You [suction ? "enable" : "disable"] the board's suction function.</span>")

/obj/item/circuitboard/machine/dish_drive/AltClick(mob/living/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	transmit = !transmit
	to_chat(user, "<span class='notice'>You [transmit ? "enable" : "disable"] the board's automatic disposal transmission.</span>")


/obj/item/circuitboard/machine/gibber
	name = "gibber (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/gibber
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/hydroponics
	name = "hydroponics tray (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/hydroponics/constructable
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/microwave
	name = "microwave (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/microwave
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 2)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/mass_driver
	name = "mass driver (Machine Board)"
	build_path = /obj/machinery/mass_driver
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 1
	)

/obj/item/circuitboard/machine/plantgenes
	name = "plant DNA manipulator (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/plantgenes
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/machine/processor
	name = "food processor (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/processor
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/processor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(build_path == /obj/machinery/processor)
			name = "Slime Processor (Machine Board)"
			build_path = /obj/machinery/processor/slime
			to_chat(user, "<span class='notice'>Name protocols successfully updated.</span>")
		else
			name = "Food Processor (Machine Board)"
			build_path = /obj/machinery/processor
			to_chat(user, "<span class='notice'>Defaulting name protocols.</span>")
	else
		return ..()

/obj/item/circuitboard/machine/protolathe/department/service
	name = "departmental protolathe - service (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/rnd/production/protolathe/department/service

/obj/item/circuitboard/machine/recycler
	name = "recycler (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/recycler
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/seed_extractor
	name = "seed extractor (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/seed_extractor
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/techfab/department/service
	name = "departmental techfab - service (Machine Board)"
	icon_state = "service"
	build_path = /obj/machinery/rnd/production/techfab/department/service


//Supply


/obj/item/circuitboard/machine/techfab/department/cargo
	name = "departmental techfab - cargo (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/rnd/production/techfab/department/cargo

/obj/item/circuitboard/machine/mining_equipment_vendor
	name = "mining equipment vendor (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/vendor/mining
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/matter_bin = 3)

/obj/item/circuitboard/machine/exploration_equipment_vendor
	name = "exploration equipment vendor (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/vendor/exploration
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/matter_bin = 3)


/obj/item/circuitboard/machine/mining_equipment_vendor/golem
	name = "golem ship equipment vendor (Machine Board)"
	build_path = /obj/machinery/vendor/mining/golem

/obj/item/circuitboard/machine/pump
	name = "portable liquid pump (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/power/liquid_pump
	needs_anchored = FALSE
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 2)

/obj/item/circuitboard/machine/ore_redemption
	name = "ore redemption (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/mineral/ore_redemption
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/assembly/igniter = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/ore_silo
	name = "ore silo (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/ore_silo
	req_components = list()

/obj/item/circuitboard/machine/protolathe/department/cargo
	name = "departmental protolathe - cargo (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/rnd/production/protolathe/department/cargo

/obj/item/circuitboard/machine/stacking_machine
	name = "stacking machine (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/mineral/stacking_machine
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 2)

/obj/item/circuitboard/machine/stacking_unit_console
	name = "stacking machine console (Machine Board)"
	icon_state = "supply"
	build_path = /obj/machinery/mineral/stacking_unit_console
	req_components = list(
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 5)

/obj/item/circuitboard/machine/processing_unit
	name = "furnace (Machine Board)"
	build_path = /obj/machinery/mineral/processing_unit
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/assembly/igniter = 1)

/obj/item/circuitboard/machine/processing_unit_console
	name = "furnace console (Machine Board)"
	build_path = /obj/machinery/mineral/processing_unit_console
	req_components = list()


//Misc


/obj/item/circuitboard/machine/abductor
	name = "alien board (Report This)"
	icon_state = "abductor_mod"

/obj/item/circuitboard/machine/abductor/core
	name = "alien board (Void Core)"
	build_path = /obj/machinery/power/rtg/abductor
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/cell/infinite/abductor = 1)
	def_components = list(
		/obj/item/stock_parts/capacitor = /obj/item/stock_parts/capacitor/quadratic,
		/obj/item/stock_parts/micro_laser = /obj/item/stock_parts/micro_laser/quadultra)

/obj/item/circuitboard/machine/chem_dispenser/abductor
	name = "reagent synthesizer (Abductor Machine Board)"
	icon_state = "abductor_mod"
	build_path = /obj/machinery/chem_dispenser/abductor
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/plantgenes/vault
	name = "Plant DNA manipulator (Abductor Machine Board)"
	icon_state = "abductor_mod"
	// It wasn't made by actual abductors race, so no abductor tech here.
	def_components = list(
		/obj/item/stock_parts/manipulator = /obj/item/stock_parts/manipulator/femto,
		/obj/item/stock_parts/micro_laser = /obj/item/stock_parts/micro_laser/quadultra,
		/obj/item/stock_parts/scanning_module = /obj/item/stock_parts/scanning_module/triphasic)

/obj/item/circuitboard/machine/clockwork
	name = "clockwork board (Report This)"
	icon_state = "clock_mod"
