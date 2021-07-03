GLOBAL_LIST_INIT(hardcoded_gases, list(GAS_O2, GAS_N2, GAS_CO2, GAS_PLASMA)) //the main four gases, which were at one time hardcoded
GLOBAL_LIST_INIT(nonreactive_gases, typecacheof(list(GAS_O2, GAS_N2, GAS_CO2, GAS_PLUOXIUM, GAS_STIMULUM, GAS_NITRYL))) //unable to react amongst themselves

/proc/gas_id2path(id)
	var/list/meta_gas = GLOB.meta_gas_ids
	if(id in meta_gas)
		return id
	for(var/path in meta_gas)
		if(meta_gas[path] == id)
			return path
	return ""

// Listmos 2.0
// aka "auxgm", a send-up of XGM
// it's basically the same architecture as XGM but
// structured differently to make it more convenient for auxmos

// most important compared to TG is that it does away with hardcoded typepaths,
// which lead to problems on the auxmos end anyway.

// second most important is that i hate how breath is handled
// and most basically every other thing in the codebase
// when it comes to hardcoded gas typepaths, so, yeah, go away

GLOBAL_LIST_INIT(gas_data, meta_gas_info_list())

/proc/meta_gas_info_list()
	. = list()
	for(var/gas_path in subtypesof(/datum/gas))
		var/datum/gas/gas = new gas_path // !
		.[gas.id] = gas

/proc/meta_gas_heat_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[initial(gas.id)] = initial(gas.specific_heat)

/proc/meta_gas_name_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[initial(gas.id)] = initial(gas.name)

/proc/meta_gas_visibility_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[initial(gas.id)] = initial(gas.moles_visible)

/proc/meta_gas_overlay_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[initial(gas.id)] = 0 //gotta make sure if(GLOB.meta_gas_overlays[gaspath]) doesn't break
		if(initial(gas.moles_visible) != null)
			.[initial(gas.id)] = new /list(FACTOR_GAS_VISIBLE_MAX)
			for(var/i in 1 to FACTOR_GAS_VISIBLE_MAX)
				.[initial(gas.id)][i] = new /obj/effect/overlay/gas(initial(gas.gas_overlay), i * 255 / FACTOR_GAS_VISIBLE_MAX)

/proc/meta_gas_flags_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[initial(gas.id)] = initial(gas.flags)

/proc/meta_gas_id_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[initial(gas.id)] = initial(gas.id)

/proc/meta_gas_fusion_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[initial(gas.id)] = initial(gas.fusion_power)

/datum/gas
	var/id = ""
	var/specific_heat = 0
	var/name = ""
	var/gas_overlay = "" //icon_state in icons/effects/atmospherics.dmi
	var/moles_visible = null
	var/flags = NONE
	var/fusion_power = 0 //How much the gas accelerates a fusion reaction
	var/rarity = 0 // relative rarity compared to other gases, used when setting up the reactions list.

// If you add or remove gases, update TOTAL_NUM_GASES in the extools code to match! Extools currently expects 14 gas types to exist.

/datum/gas/oxygen
	id = GAS_O2
	specific_heat = 20
	name = "Oxygen"
	rarity = 900

/datum/gas/nitrogen
	id = GAS_N2
	specific_heat = 20
	name = "Nitrogen"
	rarity = 1000

/datum/gas/carbon_dioxide //what the fuck is this?
	id = GAS_CO2
	specific_heat = 30
	name = "Carbon Dioxide"
	rarity = 700

/datum/gas/plasma
	id = GAS_PLASMA
	specific_heat = 200
	name = "Plasma"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE
	flags = GAS_FLAG_DANGEROUS
	rarity = 800

/datum/gas/water_vapor
	id = GAS_H2O
	specific_heat = 40
	name = "Water Vapor"
	gas_overlay = "water_vapor"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 8
	rarity = 500

/datum/gas/hypernoblium
	id = GAS_HYPERNOB
	specific_heat = 2000
	name = "Hyper-noblium"
	gas_overlay = "freon"
	moles_visible = MOLES_GAS_VISIBLE
	flags = GAS_FLAG_DANGEROUS
	rarity = 50

/datum/gas/nitrous_oxide
	id = GAS_NITROUS
	specific_heat = 40
	name = "Nitrous Oxide"
	gas_overlay = "nitrous_oxide"
	moles_visible = MOLES_GAS_VISIBLE * 2
	fusion_power = 10
	flags = GAS_FLAG_DANGEROUS
	rarity = 600

/datum/gas/nitryl
	id = GAS_NITRYL
	specific_heat = 20
	name = "Nitryl"
	gas_overlay = "nitryl"
	moles_visible = MOLES_GAS_VISIBLE
	flags = GAS_FLAG_DANGEROUS
	fusion_power = 16
	rarity = 100

/datum/gas/tritium
	id = GAS_TRITIUM
	specific_heat = 10
	name = "Tritium"
	gas_overlay = "tritium"
	moles_visible = MOLES_GAS_VISIBLE
	flags = GAS_FLAG_DANGEROUS
	fusion_power = 1
	rarity = 300

/datum/gas/bz
	id = GAS_BZ
	specific_heat = 20
	name = "BZ"
	flags = GAS_FLAG_DANGEROUS
	fusion_power = 8
	rarity = 400

/datum/gas/stimulum
	id = GAS_STIMULUM
	specific_heat = 5
	name = "Stimulum"
	fusion_power = 7
	rarity = 1

/datum/gas/pluoxium
	id = GAS_PLUOXIUM
	specific_heat = 80
	name = "Pluoxium"
	fusion_power = -10
	rarity = 200

/datum/gas/miasma
	id = GAS_MIASMA
	specific_heat = 20
	name = "Miasma"
	gas_overlay = "miasma"
	moles_visible = MOLES_GAS_VISIBLE * 60
	rarity = 250

/obj/effect/overlay/gas
	icon = 'icons/effects/atmospherics.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	layer = FLY_LAYER
	appearance_flags = TILE_BOUND
	vis_flags = NONE

/obj/effect/overlay/gas/New(state, alph)
	. = ..()
	icon_state = state
	alpha = alph
