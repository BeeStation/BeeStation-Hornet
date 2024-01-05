/*
	Items with this component will act like alien artifatcs
*/

//TODO: Replace all instances of this - Racc
/obj/item/xenoartifact
/datum/component/xenoartifact_pricing ///Pricing component for shipping solution. Consider swapping to cargo after change.
	///Buying and selling related, based on guess qaulity
	var/modifier = 0.5
	///default price gets generated if it isn't set by console. This only happens if the artifact spawns outside of that process
	var/price

/datum/component/xenoartifact_pricing/Initialize(...)
	RegisterSignal(parent, XENOA_CHANGE_PRICE, PROC_REF(update_price))
	..()

/datum/component/xenoartifact_pricing/Destroy(force, silent)
	UnregisterSignal(parent, XENOA_CHANGE_PRICE)
	..()

///Typically used to change internally
/datum/component/xenoartifact_pricing/proc/update_price(datum/source, f_price)
	price = f_price


/datum/component/xenoartifact
	///List of artifact-traits we have : list(PRIORITY = list(trait))
	var/list/artifact_traits = list()
	///Blacklist of components this artifact is currently incompatible with
	var/list/blacklisted_traits = list()

	///What strenght are our traits operating at?
	var/trait_strength = XENOA_TRAIT_STRENGTH_STRONG

	///What type of artifact are we?
	var/datum/component/xenoartifact_material/artifact_type

	///Cooldown logic for uses
	var/use_cooldown = XENOA_GENERIC_COOLDOWN
	var/use_cooldown_timer
	///Cooldown override. If this is true, we're on cooldown
	var/cooldown_override = FALSE

/datum/component/xenoartifact/New(list/raw_args, type, list/traits)
	. = ..()
	//Setup our typing
	artifact_type = type || pick_weight(GLOB.xenoartifact_material_weights)
	artifact_type = new artifact_type()
	//If we're force-generating traits
	if(traits)
		for(var/datum/xenoartifact_trait/T as() in traits)
			//List building
			if(!artifact_traits[T.priority])
				artifact_traits[T.priority] = list()
			//handle adding trait
			T = new T(parent)
			artifact_traits[T.priority] += T
			blacklisted_traits += T.blacklist_traits
			blacklisted_traits += T
	//Otherwise, randomly generate our own traits
	else
		var/list/focus_traits
		//Generate activators
		focus_traits = GLOB.xenoa_activators & artifact_type.get_trait_list()
		build_traits(focus_traits, artifact_type.trait_activators)

		//Generate minors
		focus_traits = GLOB.xenoa_minors & artifact_type.get_trait_list()
		build_traits(focus_traits, artifact_type.trait_minors)

		//Generate majors
		focus_traits = GLOB.xenoa_majors & artifact_type.get_trait_list()
		build_traits(focus_traits, artifact_type.trait_majors)

		//Generate malfunctions
		focus_traits = GLOB.xenoa_malfunctions & artifact_type.get_trait_list()
		build_traits(focus_traits, artifact_type.trait_malfunctions)

///Used to trigger all our traits in order
/datum/component/xenoartifact/proc/trigger(force)
	//Timer logic
	if((use_cooldown_timer || cooldown_override) && !force)
		return
	else if(use_cooldown_timer)
		reset_timer(use_cooldown_timer)
	//Timer setup
	addtimer(CALLBACK(src, PROC_REF(reset_timer), use_cooldown), TIMER_STOPPABLE)
	//Trait triggers
	for(var/i in GLOB.xenoartifact_trait_priorities)
		SEND_SIGNAL(src, XENOA_TRIGGER, i)

/datum/component/xenoartifact/proc/build_traits(list/trait_list, amount)
	for(var/i in 1 to amount)
		//Pick a random trait
		var/datum/xenoartifact_trait/T = pick_weight(trait_list-blacklisted_traits)
		//List building
		if(!artifact_traits[T.priority])
			artifact_traits[T.priority] = list()
		//handle trait adding
		T = new T(parent)
		artifact_traits[T.priority] += T
		blacklisted_traits += T.blacklist_traits
		blacklisted_traits += T
	
//Cooldown finish logic goes here
/datum/component/xenoartifact/proc/reset_timer()
	if(use_cooldown_timer)
		deltimer(use_cooldown_timer)
	use_cooldown_timer = null //Just incase

/datum/component/xenoartifact/proc/get_extra_cooldowns()
	var/time = 0 SECONDS
	for(var/i in artifact_traits)
		for(var/datum/xenoartifact_trait/T as() in artifact_traits[i])
			time += T.cooldown
	return time

///material datums
/datum/component/xenoartifact_material
	var/name = "debugium"
	///What color we associate with this material
	var/material_color = "#ff4800"

	///Trait info, how many of each trait are we allowed
	var/trait_activators = 1
	var/trait_minors = 3
	var/trait_majors = 1
	var/trait_malfunctions = 1

/datum/component/xenoartifact_material/proc/get_trait_list()
	return GLOB.xenoa_all_traits
