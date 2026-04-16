/datum/plant_feature/roots
	species_name = "primum radices"
	name = "roots"
	feature_catagories = PLANT_FEATURE_ROOTS
	trait_type_shortcut = /datum/plant_feature/roots
	genetic_budget = 1
	abstract_type = /datum/plant_feature/roots
	///Where can we pull reagents from
	var/list/access_whitelist = list(/obj/item/plant_tray, /turf/open)
	///What kinda of substrate can we grow in?
	var/compatible_substrate = PLANT_SUBSTRATE_DIRT | PLANT_SUBSTRATE_SAND |  PLANT_SUBSTRATE_CLAY | PLANT_SUBSTRATE_DEBRIS
	///Set to TRUE if you want our desired substrate to have all the ones we're compatible with, instead of one
	var/substrate_strict = FALSE
	///Dialogue for the required substrate
	var/substrate_dialogue = ""

/datum/plant_feature/roots/New(datum/component/plant/_parent)
	. = ..()
	access_whitelist = typecacheof(access_whitelist)
	//Generate compatible substrate dialogue - Semi messy code, whatever
	if(compatible_substrate & PLANT_SUBSTRATE_DIRT)
		substrate_dialogue += "Dirt "
	if(compatible_substrate & PLANT_SUBSTRATE_SAND)
		substrate_dialogue += "Sand "
	if(compatible_substrate & PLANT_SUBSTRATE_CLAY)
		substrate_dialogue += "Clay "
	if(compatible_substrate & PLANT_SUBSTRATE_DEBRIS)
		substrate_dialogue += "Debris "

/datum/plant_feature/roots/setup_parent(_parent, reset_features)
//Reset
	if(parent)
		UnregisterSignal(parent, COMSIG_SEEDS_POLL_ROOT_SUBSTRATE)
	. = ..()
//Pass over
	if(!parent)
		return
	RegisterSignal(parent, COMSIG_SEEDS_POLL_ROOT_SUBSTRATE, PROC_REF(catch_substrate))

/datum/plant_feature/roots/get_scan_dialogue()
	. = ..()
	. += "Compatible Substrate: [substrate_dialogue]\n"

/datum/plant_feature/roots/get_ui_data()
	. = ..()
	. += list(PLANT_DATA("Compatible Substrate", "[substrate_dialogue]"), PLANT_DATA(null, null))

/datum/plant_feature/roots/setup_parent(_parent, reset_features)
	if(parent)
		UnregisterSignal(parent, COMSIG_PLANT_REQUEST_REAGENTS)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent, COMSIG_PLANT_REQUEST_REAGENTS, PROC_REF(setup_reagents))

/datum/plant_feature/roots/associate_seeds(obj/item/plant_seeds/seeds)
	. = ..()
	RegisterSignal(seeds, COMSIG_SEEDS_POLL_ROOT_SUBSTRATE, PROC_REF(catch_substrate))
	RegisterSignal(seeds, COMSIG_ATOM_EXAMINE, PROC_REF(catch_seed_examine))

/datum/plant_feature/roots/proc/catch_seed_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	examine_text += "<span class='notice'>These seeds can be planted in: <b>[substrate_dialogue]</b></span>"

/datum/plant_feature/roots/proc/catch_substrate(datum/source, datum/plant_subtrate/polling_substrate)
	SIGNAL_HANDLER

	if((compatible_substrate == polling_substrate?.substrate_flags) && substrate_strict || (compatible_substrate & polling_substrate?.substrate_flags) && !substrate_strict)
		return TRUE
	if(!compatible_substrate) //If there's no specified substrate stuff, plant it anywhere
		return TRUE

/datum/plant_feature/roots/proc/setup_reagents(datum/source, list/reagent_holders, datum/requestor)
	SIGNAL_HANDLER

	//Roots support needs, but most wont have them
	if(requestor != src && !check_needs())
		return
	var/atom/location = parent.plant_item?.loc
	if(!is_type_in_typecache(location, access_whitelist))
		return
	if(!location?.reagents)
		return
	reagent_holders |= location?.reagents
