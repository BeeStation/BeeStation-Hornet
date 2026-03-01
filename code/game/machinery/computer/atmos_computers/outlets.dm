/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored
	on = TRUE
	icon_state = "vent_map_siphon_on-3"

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/Initialize(mapload)
	id_tag = CHAMBER_OUTPUT_FROM_ID(chamber_id)
	. = ..()
	//we dont want people messing with these special vents using the air alarm interface
	disconnect_from_area()

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/plasma_output
	name = "plasma tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_PLAS

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/oxygen_output
	name = "oxygen tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_O2

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/nitrogen_output
	name = "nitrogen tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_N2

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/mix_output
	name = "mix tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_MIX

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/nitrous_output
	name = "nitrous oxide tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_N2O

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/carbon_output
	name = "carbon dioxide tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_CO2

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/bz_output
	name = "bz tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_BZ

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/hypernoblium_output
	name = "hypernoblium tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_HYPERNOBLIUM

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/nitrium_output
	name = "nitrium tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_NITRIUM

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/pluoxium_output
	name = "pluoxium tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_PLUOXIUM

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/tritium_output
	name = "tritium tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_TRITIUM

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/water_vapor_output
	name = "water vapor tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_H2O

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/incinerator_output
	name = "incinerator chamber output inlet"
	chamber_id = ATMOS_GAS_MONITOR_INCINERATOR

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/toxins_burn_chamber_output
	name = "toxins burn chamber output inlet"
	chamber_id = ATMOS_GAS_MONITOR_TOXINS_BURN

/obj/machinery/atmospherics/components/unary/vent_pump/siphon/monitored/toxins_freezer_chamber_output
	name = "toxins freezer chamber output inlet"
	chamber_id = ATMOS_GAS_MONITOR_TOXINS_FREEZER

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/monitored
	on = TRUE
	icon_state = "vent_map_siphon_on-3"

// Same as the rest, but bigger volume.
/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/monitored/Initialize(mapload)
	id_tag = CHAMBER_OUTPUT_FROM_ID(chamber_id)
	. = ..()
	//we dont want people messing with these special vents using the air alarm interface
	disconnect_from_area()

/obj/machinery/atmospherics/components/unary/vent_pump/high_volume/siphon/monitored/air_output
	name = "air mix tank output inlet"
	chamber_id = ATMOS_GAS_MONITOR_AIR
