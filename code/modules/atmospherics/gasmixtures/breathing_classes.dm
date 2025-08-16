// Breathing classes are, yes, just a list of gases, associated with numbers.
// But they're very simple: pluoxium's status as O2 * 8 is represented here,
// with a single line of code, no hardcoding and special-casing across the codebase.
// Not only that, but they're very general: you could have a negative value
// to simulate asphyxiants, e.g. if I add krypton it could go into the oxygen
// breathing class at -7, simulating krypton narcosis.

/datum/breathing_class
	var/list/gases = null
	var/list/products = null
	var/danger_reagent = null
	var/low_alert_category = "not_enough_oxy"
	var/low_alert_datum =  /atom/movable/screen/alert/not_enough_oxy
	var/high_alert_category = "too_much_oxy"
	var/high_alert_datum =  /atom/movable/screen/alert/too_much_oxy

/datum/breathing_class/proc/get_effective_pp(datum/gas_mixture/breath)
	var/mol = 0
	for(var/gas in gases)
		mol += GET_MOLES(gas,breath) * gases[gas]
	return (mol/breath.total_moles()) * breath.return_pressure()

/datum/breathing_class/oxygen
	gases = list(
		/datum/gas/oxygen = 1,
		/datum/gas/pluoxium = 8,
		/datum/gas/carbon_dioxide = -0.7, // CO2 isn't actually toxic, just an asphyxiant
	)
	products = list(
		/datum/gas/carbon_dioxide = 1,
	)

/datum/breathing_class/plasma
	gases = list(
		/datum/gas/plasma = 1
	)
	products = list(
		/datum/gas/carbon_dioxide = 1
	)
	low_alert_category = "not_enough_tox"
	low_alert_datum = /atom/movable/screen/alert/not_enough_plas
	high_alert_category = "too_much_tox"
	high_alert_datum = /atom/movable/screen/alert/too_much_plas

/proc/breathing_class_list()
	var/list/breathing_classes = list()
	for(var/breathing_class_path in subtypesof(/datum/breathing_class))
		var/datum/breathing_class/class = new breathing_class_path
		breathing_classes[breathing_class_path] = class
	return breathing_classes

GLOBAL_LIST_INIT(breathing_class_info, breathing_class_list())
