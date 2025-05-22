/obj/machinery/atmospherics/components/unary/outlet_injector/monitored
	on = TRUE
	volume_rate = MAX_TRANSFER_RATE
	/// The air sensor type this injector is linked to
	var/chamber_id

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/Initialize(mapload)
	id_tag = CHAMBER_INPUT_FROM_ID(chamber_id)
	return ..()

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/layer2
	piping_layer = 2
	icon_state = "inje_map-2"

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/layer4
	piping_layer = 4
	icon_state = "inje_map-4"

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/plasma_input
	name = "plasma tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_PLAS

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/oxygen_input
	name = "oxygen tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_O2

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/nitrogen_input
	name = "nitrogen tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_N2

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/mix_input
	name = "mix tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_MIX

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/nitrous_input
	name = "nitrous oxide tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_N2O

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/air_input
	name = "air mix tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_AIR

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/carbon_input
	name = "carbon dioxide tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_CO2

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/bz_input
	name = "bz tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_BZ

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/hypernoblium_input
	name = "hypernoblium tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_HYPERNOBLIUM

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/atmos/nitrium_input
	name = "nitrium tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_NITRIUM

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/pluoxium_input
	name = "pluoxium tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_PLUOXIUM

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/tritium_input
	name = "tritium tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_TRITIUM

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/water_vapor_input
	name = "water vapor tank input injector"
	chamber_id = ATMOS_GAS_MONITOR_H2O

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/incinerator_input
	name = "incinerator chamber input injector"
	chamber_id = ATMOS_GAS_MONITOR_INCINERATOR

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/toxins_burn_chamber_input
	name = "toxins burn chamber input injector"
	chamber_id = ATMOS_GAS_MONITOR_TOXINS_BURN

/obj/machinery/atmospherics/components/unary/outlet_injector/monitored/toxins_freezer_chamber_input
	name = "toxins freezer chamber input injector"
	chamber_id = ATMOS_GAS_MONITOR_TOXINS_FREEZER
