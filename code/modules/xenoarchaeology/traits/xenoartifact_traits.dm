///Xenoartifact traits, datum-ised
/datum/xenoartifact_trait
	///Acts as a descriptor for when examining. Also used for naming stuff in the labeler. Keep these short.
	var/desc
	///Used when labeler needs a name and trait is too sneaky to have a descriptor when examining.
	var/label_name
	///Something briefly explaining it in IG terms or a pun.
	var/label_desc
	///Asscoiated flags for artifact typing
	var/flags = NONE
	///Other traits the original trait wont work with. Referenced when generating traits.
	var/list/blacklist_traits = list()
	///Weight in trait list, most traits wont change this
	var/weight = 50

//Subtype shenanigahns
/datum/xenoartifact_trait/minor //leave these here for later.

/datum/xenoartifact_trait/major

/datum/xenoartifact_trait/malfunction
	flags = BLUESPACE_TRAIT | PLASMA_TRAIT | URANIUM_TRAIT

/datum/xenoartifact_trait/activator
	///How much an activator trait can output on a standard, modified by the artifacts charge_req and circumstances.
	var/charge
	///which signals trait responds to
	var/list/signals
	///Not used outside of signal handle, please
	var/obj/item/xenoartifact/xenoa

///Proc used to compile trait weights into a list
/proc/compile_artifact_weights(path)
	if(!ispath(path))
		return
	var/list/temp = subtypesof(path)
	var/list/weighted = list()
	for(var/datum/xenoartifact_trait/T as() in temp)
		weighted += list((T) = initial(T.weight))
	return weighted

///Compile a blacklist of traits from a given flag/s
/proc/compile_artifact_blacklist(var/flags)
	var/list/output = list()
	for(var/datum/xenoartifact_trait/T as() in GLOB.xenoa_all_traits)	
		if(!(initial(T.flags) & flags))
			output += T
	return output

//Activator signal shenanignas 
///Passes information into the activator datum to decide if, and how, the artifact activates
/datum/xenoartifact_trait/activator/proc/pass_input(obj/item/xenoartifact/X)
	return

/datum/xenoartifact_trait/activator/on_init(obj/item/xenoartifact/X)
	. = ..()
	if(!X)
		return
	xenoa = X
	for(var/s in signals)
		switch(s) //Translating signal params to vaugely resemble (/obj/item, /mob/living, params)
			if(COMSIG_PARENT_ATTACKBY)
				RegisterSignal(xenoa, COMSIG_PARENT_ATTACKBY, PROC_REF(translate_attackby))
			if(COMSIG_ITEM_ATTACK)
				RegisterSignal(xenoa, COMSIG_ITEM_ATTACK, PROC_REF(translate_attack))
			if(COMSIG_MOVABLE_IMPACT)
				RegisterSignal(xenoa, COMSIG_MOVABLE_IMPACT, PROC_REF(translate_impact))
			if(COMSIG_ITEM_AFTERATTACK)
				RegisterSignal(xenoa, COMSIG_ITEM_AFTERATTACK, PROC_REF(translate_afterattack))
			if(COMSIG_ITEM_PICKUP)
				RegisterSignal(xenoa, COMSIG_ITEM_PICKUP, PROC_REF(translate_pickup))
			if(COMSIG_ITEM_ATTACK_SELF)
				RegisterSignal(xenoa, COMSIG_ITEM_ATTACK_SELF, PROC_REF(translate_attack_self))
			if(XENOA_SIGNAL)
				RegisterSignal(xenoa, XENOA_SIGNAL, PROC_REF(translate_attackby))
	RegisterSignal(xenoa, XENOA_DEFAULT_SIGNAL, PROC_REF(pass_input)) //Signal sent by handles

/datum/xenoartifact_trait/activator/Destroy(force, ...)
	. = ..()
	if(!xenoa)
		return
	for(var/s in signals)
		UnregisterSignal(xenoa, s)
	UnregisterSignal(xenoa, XENOA_DEFAULT_SIGNAL)
	xenoa = null

/datum/xenoartifact_trait/activator/proc/translate_attackby(datum/source, obj/item/thing, mob/user, params)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, thing, user, user)

/datum/xenoartifact_trait/activator/proc/translate_attack_self(datum/source, mob/user, params)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, xenoa, user, user)

/datum/xenoartifact_trait/activator/proc/translate_attack(mob/living/target, mob/living/user)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, xenoa, user, target)

/datum/xenoartifact_trait/activator/proc/translate_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, xenoa, hit_atom, throwingdatum) //Weird order to fix this becuase signals are mean

/datum/xenoartifact_trait/activator/proc/translate_afterattack(atom/target, mob/user, params)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, target, params, user) //Weird order to fix this becuase signals are mean

/datum/xenoartifact_trait/activator/proc/translate_pickup(mob/user, params)
	SEND_SIGNAL(xenoa, XENOA_DEFAULT_SIGNAL, xenoa, params) //Weird order to fix this becuase signals are mean

//End activator
//Declare procs
/datum/xenoartifact_trait/proc/activate(obj/item/xenoartifact/X, atom/target, atom/user, setup = TRUE) //Typical behaviour
	return

/datum/xenoartifact_trait/proc/on_item(obj/item/xenoartifact/X, atom/user, atom/item) //Item hint responses
	return FALSE

///This is better than initialize just for our specific control purposes, definitely not becuase I forgot to use it somehow.
/datum/xenoartifact_trait/proc/on_init(obj/item/xenoartifact/X)
	return

/datum/xenoartifact_trait/proc/on_touch(obj/item/xenoartifact/X, atom/user) //Touch hint
	return FALSE

//Exploration mission GPS trait
/datum/xenoartifact_trait/special/objective
	blacklist_traits = list(/datum/xenoartifact_trait/minor/delicate)

/datum/xenoartifact_trait/special/objective/on_init(obj/item/xenoartifact/X)
	X.AddComponent(/datum/component/gps, "[scramble_message_replace_chars("#########", 100)]", TRUE)
