/*
	Porous
	The artifact replaces one random gas with another
*/
/datum/xenoartifact_trait/major/gas
	label_name = "Porous"
	label_desc = "Porous: The artifact seems to contain porous components. Triggering these components will cause the artifact to exchange one gas with another."
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 15
	register_targets = FALSE
	///Possible target gasses
	var/list/target_gasses = list(
		/datum/gas/oxygen = 6,
		/datum/gas/nitrogen = 3,
		/datum/gas/plasma = 1,
		/datum/gas/carbon_dioxide = 1,
		/datum/gas/water_vapor = 3
	)
	///Possible exchange gasses
	var/list/exchange_gasses = list(
		/datum/gas/bz = 3,
		/datum/gas/hypernoblium = 1,
		/datum/gas/plasma = 3,
		/datum/gas/tritium = 2,
		/datum/gas/nitrium = 1
	)
	///Choosen target gas
	var/datum/gas/choosen_target
	///Choosen exchange gas
	var/datum/gas/choosen_exchange
	///Max amount of moles we exchange at once
	var/max_moles = 10

/datum/xenoartifact_trait/major/gas/New(atom/_parent)
	. = ..()
	choosen_target = pick_weight(target_gasses)
	choosen_exchange = pick_weight(exchange_gasses)

/datum/xenoartifact_trait/major/gas/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	setup_generic_item_hint()

/datum/xenoartifact_trait/major/gas/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/turf/open/T = get_turf(component_parent.parent)
	var/datum/gas_mixture/air = T.air
	if(!istype(T) || !air)
		return
	var/moles = min(air.total_moles(choosen_target), max_moles)
	if(!moles)
		return
	SET_MOLES(choosen_target, air, -moles)
	SET_MOLES(choosen_exchange, air, moles)

/datum/xenoartifact_trait/major/gas/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_DETECT("gas analyzer, which will also reveal what gasses the artifact exchanges."))

/datum/xenoartifact_trait/major/gas/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/analyzer))
		to_chat(user, "<span class='warning'>[item] detects [initial(choosen_target.name)] exchanging into [initial(choosen_exchange.name)] \
		at a rate of [max_moles] moles!</span>")
		return ..()
