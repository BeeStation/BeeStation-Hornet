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

	///How much time does this trait add to the artifact cooldownm
	var/cooldown = 0 SECONDS

	///What trait priority we use
	var/priority = TRAIT_PRIORITY_ACTIVATOR

	///List of things we've effected. used to automatically reigster & unregister targets.
	var/list/targets = list()

	///Characteristics for deduction
	var/weight = 0
	var/conductivity = 0

/datum/xenoartifact_trait/minor
/datum/xenoartifact_trait/major
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
		trigger(target)
	targets += target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(unregister_target))
	
//Cleanly unregister an effected target
/datum/xenoartifact_trait/proc/unregister_target(datum/source, do_untrigger = TRUE)
	SIGNAL_HANDLER

	if(do_untrigger) //This will only happen in the event something is unregistered before we can untrigger, which is needed for QDELs
		un_trigger(source)
	targets -= source

/datum/xenoartifact_trait/proc/trigger(atom/A, _priority)
	SIGNAL_HANDLER

	if(_priority != priority)
		return
	register_target(A)
	return

/datum/xenoartifact_trait/proc/un_trigger(atom/A)
	unregister_target(A, FALSE)
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
