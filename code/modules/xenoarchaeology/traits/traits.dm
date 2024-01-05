/datum/xenoartifact_trait
	///Reference to the artifact
	var/datum/component/xenoartifact/parent

	///Acts as a descriptor for when examining - 'reinforced' 'electrified' 'hollow'
	var/examine_desc
	///Used when labeler needs a name and trait is too sneaky to have a descriptor when examining.
	var/label_name
	///Something briefly explaining it in inagame terms.
	var/label_desc

	///Asscoiated flags for artifact typing and such
	var/flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT | BANANIUM_TRAIT
	///Other traits this trait wont work with.
	var/list/blacklist_traits = list()
	///How rare is this trait? 100 being common, and 1 being very rare
	var/rarity = 100

	///Does this trait reigster targets?
	var/register_targets = TRUE

	///How much time does this trait add to the artifact cooldownm
	var/cooldown = 0 SECONDS

	///What trait priority we use
	var/priority = TRAIT_PRIORITY_ACTIVATOR

	///List of things we've effected. used to automatically reigster & unregister targets.
	var/list/targets = list()

	///Characteristics for deduction
	var/weight = 0 //KG
	var/conductivity = 0 //microsiemens per centimeter - I had to look this up

/datum/xenoartifact_trait/minor
/datum/xenoartifact_trait/malfunction

/datum/xenoartifact_trait/New(atom/_parent)
	. = ..()
	parent = _parent
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(remove_parent))
	//Setup trigger signals
	RegisterSignal(parent, XENOA_TRIGGER, PROC_REF(trigger))

/datum/xenoartifact_trait/Destroy(force, ...)
	. = ..()
	for(var/atom/A in targets)
		unregister_target(A)

/datum/xenoartifact_trait/proc/remove_parent(datum/source)
	SIGNAL_HANDLER

	parent = null

//Cleanly register an effected target
/datum/xenoartifact_trait/proc/register_target(atom/target, do_trigger = FALSE)
	if(do_trigger)
		trigger(null, priority, target)
	targets += target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(unregister_target), TRUE)
	
//Cleanly unregister an effected target
/datum/xenoartifact_trait/proc/unregister_target(datum/source, do_untrigger = TRUE)
	SIGNAL_HANDLER

	if(do_untrigger) //This will only happen in the event something is unregistered before we can untrigger, which is needed for QDELs
		un_trigger(source)
	targets -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

//A can be passed manually for debug
/datum/xenoartifact_trait/proc/trigger(datum/source, _priority, atom/A)
	SIGNAL_HANDLER

	if(_priority != priority && _priority)
		return
	if(!register_targets)
		return
	//If we've been given an override
	if(A)
		register_target(A)
	//Otherwise just use the artifact's target list
	else if(length(parent.targets))
		for(var/atom/I in parent.targets)
			register_target(I)
	return

//Most traits will handle this on their own
/datum/xenoartifact_trait/proc/un_trigger(atom/A)
	unregister_target(A, FALSE)
	return

/datum/xenoartifact_trait/proc/dump_targets()
	for(var/i in targets)
		unregister_target(i)

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
