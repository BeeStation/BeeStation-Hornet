GLOBAL_LIST_INIT(hardcoded_gases, list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma)) //the main four gases, which were at one time hardcoded

/proc/meta_gas_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/list/gas_info = new(15)
		var/datum/gas/gas = gas_path

		gas_info[META_GAS_SPECIFIC_HEAT] = initial(gas.specific_heat)
		gas_info[META_GAS_NAME] = initial(gas.name)

		gas_info[META_GAS_MOLES_VISIBLE] = initial(gas.moles_visible)
		gas_info[META_GAS_RIG_SHIELDING_POWER] = initial(gas.gasrig_shielding_power)
		gas_info[META_GAS_RIG_SHIELDING_MODIFIER] = initial(gas.gasrig_shielding_modifier)
		if(initial(gas.moles_visible) != null)
			gas_info[META_GAS_OVERLAY] = generate_gas_overlay(gas)

		gas_info[META_GAS_FUSION_POWER] = initial(gas.fusion_power)
		gas_info[META_GAS_DANGER] = initial(gas.dangerous)
		gas_info[META_GAS_ID] = initial(gas.id)
		gas_info[META_GAS_DESC] = initial(gas.desc)
		.[gas_path] = gas_info

/proc/generate_gas_overlay(datum/gas/gas_type)
	var/fill = list()
	for(var/j in 1 to TOTAL_VISIBLE_STATES)
		var/obj/effect/overlay/gas/gas = new (initial(gas_type.gas_overlay), log(4, (j+0.4*TOTAL_VISIBLE_STATES) / (0.35*TOTAL_VISIBLE_STATES)) * 255)
		fill += gas
	return fill

/proc/gas_id2path(id)
	var/list/meta_gas = GLOB.meta_gas_info
	if(id in meta_gas)
		return id
	for(var/path in meta_gas)
		if(meta_gas[path][META_GAS_ID] == id)
			return path
	return ""

/*||||||||||||||/----------\||||||||||||||*\
||||||||||||||||[GAS DATUMS]||||||||||||||||
||||||||||||||||\__________/||||||||||||||||
||||These should never be instantiated. ||||
||||They exist only to make it easier   ||||
||||to add a new gas. They are accessed ||||
||||only by meta_gas_list().            ||||
\*||||||||||||||||||||||||||||||||||||||||*/

/datum/gas
	var/id = ""
	var/specific_heat = 0
	var/name = ""
	///icon_state in icons/effects/atmospherics.dmi
	var/gas_overlay = ""
	var/moles_visible = null
	///currently used by canisters
	var/dangerous = FALSE
	///How much the gas accelerates a fusion reaction
	var/fusion_power = 0
	///How much the gas provides shielding for the Advanced Gas Rig
	var/gasrig_shielding_power = 0
	///The impact on efficiency of shielding this gas has in the Advanced Gas Rig. Should be greater then 0.1
	var/gasrig_shielding_modifier = 1
	/// relative rarity compared to other gases, used when setting up the reactions list.
	var/rarity = 0
	///Can gas of this type can purchased through cargo?
	var/purchaseable = FALSE
	///How does a single mole of this gas sell for? Formula to calculate maximum value is in code\modules\cargo\exports\large_objects.dm.
	var/base_value = 0
	//Description
	var/desc
	///RGB code for use when a generic color representing the gas is needed. Colors taken from contants.ts
	var/primary_color

	///Maximum demand when exporting in MOLES
	var/max_demand = 5000

/datum/gas/oxygen
	id = GAS_O2
	specific_heat = 20
	name = "Oxygen"
	gasrig_shielding_modifier = 3
	rarity = 900
	purchaseable = TRUE
	base_value = 0.2
	desc = "The gas most life forms need to be able to survive. Also an oxidizer."
	primary_color = "#0000ff"

/datum/gas/nitrogen
	id = GAS_N2
	specific_heat = 20
	name = "Nitrogen"
	rarity = 1000
	purchaseable = TRUE
	base_value = 0.1
	desc = "A very common gas that used to pad artificial atmospheres to habitable pressure."
	primary_color = "#ffff00"

/datum/gas/carbon_dioxide //what the fuck is this?
	id = GAS_CO2
	specific_heat = 30
	name = "Carbon Dioxide"
	dangerous = TRUE
	rarity = 700
	purchaseable = TRUE
	base_value = 0.2
	desc = "What the fuck is carbon dioxide?"
	primary_color = COLOR_GRAY

/datum/gas/plasma
	id = GAS_PLASMA
	specific_heat = 200
	name = "Plasma"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE
	gasrig_shielding_power = 2
	gasrig_shielding_modifier = 0.4
	dangerous = TRUE
	rarity = 800
	base_value = 1.5
	desc = "A flammable gas with many other curious properties. Its research is one of NT's primary objective."
	primary_color = "#ffc0cb"

/datum/gas/water_vapor
	id = GAS_WATER_VAPOR
	specific_heat = 40
	name = "Water Vapor"
	gas_overlay = "water_vapor"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 8
	gasrig_shielding_power = 8
	gasrig_shielding_modifier = 0.5
	rarity = 500
	purchaseable = TRUE
	base_value = 0.5
	desc = "Water, in gas form. Makes things slippery."
	primary_color = "#b0c4de"

/datum/gas/hypernoblium
	id = GAS_HYPER_NOBLIUM
	specific_heat = 2000
	name = "Hypernoblium"
	gas_overlay = "freon"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 10
	gasrig_shielding_power = 50
	gasrig_shielding_modifier = 0.1
	rarity = 50
	base_value = 5
	desc = "The most noble gas of them all. High quantities of hyper-noblium actively prevents reactions from occurring."
	primary_color = COLOR_TEAL

/datum/gas/nitrous_oxide
	id = GAS_N2O
	specific_heat = 40
	name = "Nitrous Oxide"
	gas_overlay = "nitrous_oxide"
	moles_visible = MOLES_GAS_VISIBLE * 2
	fusion_power = 10
	gasrig_shielding_modifier = 0.8
	dangerous = TRUE
	rarity = 600
	purchaseable = TRUE
	base_value = 1.5
	desc = "Causes drowsiness, euphoria, and eventually unconsciousness."
	primary_color = "#ffe4c4"

/datum/gas/nitrium
	id = GAS_NITRIUM
	specific_heat = 10
	name = "Nitrium"
	fusion_power = 7
	gasrig_shielding_power = 80
	gas_overlay = "nitrium"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 1
	base_value = 6
	desc = "An experimental performance enhancing gas. Nitrium can have amplified effects as more of it gets into your bloodstream."
	primary_color = "#a52a2a"

/datum/gas/tritium
	id = GAS_TRITIUM
	specific_heat = 10
	name = "Tritium"
	gas_overlay = "tritium"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	fusion_power = 5
	gasrig_shielding_power = 2
	gasrig_shielding_modifier = 6
	rarity = 300
	base_value = 2.5
	desc = "A highly flammable and radioactive gas."
	primary_color = "#32cd32"

/datum/gas/bz
	id = GAS_BZ
	specific_heat = 20
	name = "BZ"
	dangerous = TRUE
	fusion_power = 8
	gasrig_shielding_power = 20
	gasrig_shielding_modifier = 1.5
	rarity = 400
	purchaseable = TRUE
	base_value = 1.5
	desc = "A powerful hallucinogenic nerve agent able to induce cognitive damage."
	primary_color = "#9370db"

/datum/gas/pluoxium
	id = GAS_PLUOXIUM
	specific_heat = 80
	name = "Pluoxium"
	fusion_power = -10
	gasrig_shielding_power = 20
	gasrig_shielding_modifier = 0.6
	rarity = 200
	base_value = 2.5
	desc = "A gas that could supply even more oxygen to the bloodstream when inhaled, without being an oxidizer."
	primary_color = "#7b68ee"

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
