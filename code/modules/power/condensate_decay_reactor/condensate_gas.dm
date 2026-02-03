/proc/init_condensate_gas()
	var/list/gas_list = list()
	for (var/condensate_gas_path in subtypesof(/datum/condensate_gas))
		var/datum/condensate_gas/condensate_gas = new condensate_gas_path
		gas_list[condensate_gas.gas_path] = condensate_gas
	return gas_list

/datum/condensate_gas
	/// Path of the [/datum/gas] involved with this interaction.
	var/gas_path
	/// Which gas does this decay into? Null if it does not decay
	var/decays_into = null
	/// How fast does this gas decay?
	var/decay_rate = 0.05
	/// What amount is needed before this gas starts to decay?
	var/threshold = 0
	/// How much flux does this gas produce on decay?
	var/decay_flux_mult = 0
	/// How much stability does this gas contribute to the CDR
	var/stability_val = 0

/datum/condensate_gas/nitrium
	gas_path = /datum/gas/nitrium
	decays_into = /datum/gas/tritium
	threshold = 10
	decay_flux_mult = 10
	stability_val = 0.1

/datum/condensate_gas/tritium
	gas_path = /datum/gas/tritium
	decays_into = /datum/gas/plasma
	threshold = 20
	decay_flux_mult = 5
	stability_val = 0.2

/datum/condensate_gas/plasma
	gas_path = /datum/gas/plasma
	decays_into = /datum/gas/bz
	threshold = 100
	decay_flux_mult = 2
	stability_val = 0.5

/datum/condensate_gas/bz
	gas_path = /datum/gas/bz
	decays_into = /datum/gas/nitrous_oxide
	threshold = 200
	decay_flux_mult = 1
	stability_val = 0.75

/datum/condensate_gas/nitrous_oxide
	gas_path = /datum/gas/nitrous_oxide
	decays_into = /datum/gas/oxygen
	threshold = 400
	decay_flux_mult = 1
	stability_val = 0.9

/datum/condensate_gas/oxygen
	gas_path = /datum/gas/oxygen
	decays_into = /datum/gas/water_vapor
	threshold = 1000
	decay_flux_mult = 1
	stability_val = 1

/datum/condensate_gas/water_vapor
	gas_path = /datum/gas/water_vapor
	decays_into = /datum/gas/carbon_dioxide
	threshold = 600
	decay_flux_mult = 5
	stability_val = 2

/datum/condensate_gas/carbon_dioxide
	gas_path = /datum/gas/carbon_dioxide
	decays_into = /datum/gas/nitrogen
	threshold = 100
	decay_flux_mult = 10
	stability_val = 5

/datum/condensate_gas/nitrogen
	gas_path = /datum/gas/nitrogen
	decays_into = /datum/gas/pluoxium
	threshold = 50
	decay_flux_mult = 20
	stability_val = 8

/datum/condensate_gas/pluoxium
	gas_path = /datum/gas/pluoxium
	decays_into = /datum/gas/hypernoblium
	threshold = 10
	decay_flux_mult = 100
	stability_val = 10

/datum/condensate_gas/hypernoblium
	gas_path = /datum/gas/hypernoblium
	stability_val = 100
