/datum/xenoartifact_trait
	///Reference to the artifact
	var/datum/component/xenoartifact/parent

	///Acts as a descriptor for when examining - 'reinforced' 'electrified' 'hollow'
	var/material_desc
	///Used when labeler needs a name and trait is too sneaky to have a descriptor when examining.
	var/label_name
	///Something briefly explaining it in inagame terms.
	var/label_desc

	///Asscoiated flags for artifact typing and such
	var/flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	///Other traits this trait wont work with.
	var/list/blacklist_traits = list()
	///How rare is this trait? 100 being common, and 1 being very rare
	var/rarity = XENOA_TRAIT_WEIGHT_COMMON

	///Does this trait reigster targets?
	var/register_targets = TRUE

	///How much time does this trait add to the artifact cooldownm
	var/cooldown = 0 SECONDS

	///What trait priority we use
	var/priority = TRAIT_PRIORITY_ACTIVATOR

	///List of things we've effected. used to automatically reigster & unregister targets. Don't confuse with parent targets, which is things we want to effect
	var/list/targets = list()
	///A distinct list of targets, incorporating overrides
	var/list/focus = list()
	///Extra target range we add to the artifact
	var/extra_target_range = 0

	///Characteristics for deduction
	var/weight = 1 //KG
	var/conductivity = 1 //microsiemens per centimeter - I had to look this up - Don't worry about making this accurate / reasonable

/datum/xenoartifact_trait/New(atom/_parent)
	. = ..()
	parent = _parent
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(remove_parent))
	//Setup trigger signals
	RegisterSignal(parent, XENOA_TRIGGER, PROC_REF(trigger))
	//Appearance
	generate_trait_appearance(parent.parent)
	//Stats
	parent.target_range += extra_target_range

/datum/xenoartifact_trait/Destroy(force, ...)
	. = ..()
	dump_targets()

/datum/xenoartifact_trait/proc/remove_parent(datum/source)
	SIGNAL_HANDLER

	parent = null
	dump_targets()

//Cleanly register an effected target
/datum/xenoartifact_trait/proc/register_target(atom/target, do_trigger = FALSE)
	if(do_trigger)
		trigger(null, priority, target)
	targets += target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(unregister_target_signal), TRUE)
	
//Cleanly unregister an effected target
/datum/xenoartifact_trait/proc/unregister_target(datum/source, do_untrigger = FALSE)
	SIGNAL_HANDLER

	if(do_untrigger) //This will only happen in the event something is unregistered before we can untrigger, which is needed for QDELs
		un_trigger(source, override = source)
	targets -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/datum/xenoartifact_trait/proc/unregister_target_signal(datum/source)
	SIGNAL_HANDLER

	unregister_target(source, TRUE)

/datum/xenoartifact_trait/proc/trigger(datum/source, _priority, atom/override)
	SIGNAL_HANDLER

	. = TRUE
	if(_priority != priority && _priority)
		return FALSE
	if(!register_targets)
		return
	//If we've been given an override
	if(override)
		register_target(override)
	//Otherwise just use the artifact's target list
	else if(length(parent.targets))
		for(var/atom/I in parent.targets)
			register_target(I)
	//Handle focus
	focus = override ? list(override) : targets
	return

//Most traits will handle this on their own
/datum/xenoartifact_trait/proc/un_trigger(atom/override, handle_parent = FALSE)
	//Override
	if(override)
		unregister_target(override)
	//Parent targets, we shouldn't need this casually, only for niche cases
	if(length(parent.targets) && handle_parent)
		for(var/atom/I in parent.targets)
			unregister_target(I)
	//Our targets
	if(length(targets))
		for(var/atom/I in targets)
			unregister_target(I)
	//Handle Focus
	clear_focus()
	return

/datum/xenoartifact_trait/proc/dump_targets()
	for(var/i in targets)
		unregister_target(i, TRUE)

//Call this when you're finished with the focus in the trigger() proc, un_trigger() handles itself
/datum/xenoartifact_trait/proc/clear_focus()
	focus = list()

//If we want this trait to modify the artifact's appearance
/datum/xenoartifact_trait/proc/generate_trait_appearance(atom/target)
	return

///Proc used to compile trait weights into a list
/proc/compile_artifact_weights(path)
	if(!ispath(path))
		return
	var/list/temp = subtypesof(path)
	var/list/weighted = list()
	for(var/datum/xenoartifact_trait/T as() in temp)
		weighted += list((T) = initial(T.rarity)) //The (T) will not work if it is T
	return weighted

///Compile a blacklist of traits from a given flag/s
/proc/compile_artifact_whitelist(var/flags)
	var/list/output = list()
	for(var/datum/xenoartifact_trait/T as() in GLOB.xenoa_all_traits)
		if((initial(T.flags) & flags))
			output += T
	return output
