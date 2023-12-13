/**
 * # Component
 *
 * The component datum
 *
 * A component should be a single standalone unit
 * of functionality, that works by receiving signals from it's parent
 * object to provide some single functionality (i.e a slippery component)
 * that makes the object it's attached to cause people to slip over.
 * Useful when you want shared behaviour independent of type inheritance
 */
/datum/component
	/**
	  * Defines how duplicate existing components are handled when added to a datum
	  *
	  * See [COMPONENT_DUPE_*][COMPONENT_DUPE_ALLOWED] definitions for available options
	  */
	var/dupe_mode = COMPONENT_DUPE_HIGHLANDER

	/**
	  * The type to check for duplication
	  *
	  * `null` means exact match on `type` (default)
	  *
	  * Any other type means that and all subtypes
	  */
	var/dupe_type

	/// The datum this components belongs to
	var/datum/parent

	/**
	  * Only set to true if you are able to properly transfer this component
	  *
	  * At a minimum [RegisterWithParent][/datum/component/proc/RegisterWithParent] and [UnregisterFromParent][/datum/component/proc/UnregisterFromParent] should be used
	  *
	  * Make sure you also implement [PostTransfer][/datum/component/proc/PostTransfer] for any post transfer handling
	  */
	var/can_transfer = FALSE

/**
 * Create a new component.
 *
 * Additional arguments are passed to [Initialize()][/datum/component/proc/Initialize]
 *
 * Arguments:
 * * datum/P the parent datum this component reacts to signals from
 */
/datum/component/New(list/raw_args)
	parent = raw_args[1]
	var/list/arguments = raw_args.Copy(2)
	if(Initialize(arglist(arguments)) == COMPONENT_INCOMPATIBLE)
		stack_trace("Incompatible [type] assigned to a [parent.type]! args: [json_encode(arguments)]")
		qdel(src, TRUE, TRUE)
		CRASH("Incompatible [type] assigned to a [parent.type]! args: [json_encode(arguments)]")

	_JoinParent(parent)

/**
 * Called during component creation with the same arguments as in new excluding parent.
 *
 * Do not call `qdel(src)` from this function, `return COMPONENT_INCOMPATIBLE` instead
 */
/datum/component/proc/Initialize(...)
	return

/**
 * Properly removes the component from `parent` and cleans up references
 *
 * Arguments:
 * * force - makes it not check for and remove the component from the parent
 * * silent - deletes the component without sending a [COMSIG_COMPONENT_REMOVING] signal
 */
/datum/component/Destroy(force=FALSE, silent=FALSE)
	if(!force && parent)
		_RemoveFromParent()
	if(parent && !silent)
		SEND_SIGNAL(parent, COMSIG_COMPONENT_REMOVING, src)
	parent = null
	return ..()

/**
 * Internal proc to handle behaviour of components when joining a parent
 */
/datum/component/proc/_JoinParent()
	var/datum/P = parent
	//lazy init the parent's dc list
	var/list/dc = P.datum_components
	if(!dc)
		P.datum_components = dc = list()

	//set up the typecache
	var/our_type = type
	for(var/I in _GetInverseTypeList(our_type))
		var/test = dc[I]
		if(test)	//already another component of this type here
			var/list/components_of_type
			if(!length(test))
				components_of_type = list(test)
				dc[I] = components_of_type
			else
				components_of_type = test
			if(I == our_type)	//exact match, take priority
				var/inserted = FALSE
				for(var/J in 1 to components_of_type.len)
					var/datum/component/C = components_of_type[J]
					if(C.type != our_type) //but not over other exact matches
						components_of_type.Insert(J, I)
						inserted = TRUE
						break
				if(!inserted)
					components_of_type += src
			else	//indirect match, back of the line with ya
				components_of_type += src
		else	//only component of this type, no list
			dc[I] = src

	RegisterWithParent()

/**
 * Internal proc to handle behaviour when being removed from a parent
 */
/datum/component/proc/_RemoveFromParent()
	var/datum/parent = src.parent
	var/list/parents_components = parent.datum_components
	for(var/I in _GetInverseTypeList())
		var/list/components_of_type = parents_components[I]

		if(length(components_of_type)) //
			var/list/subtracted = components_of_type - src

			if(subtracted.len == 1) //only 1 guy left
				parents_components[I] = subtracted[1] //make him special
			else
				parents_components[I] = subtracted

		else //just us
			parents_components -= I

	if(!parents_components.len)
		parent.datum_components = null

	UnregisterFromParent()

/**
 * Register the component with the parent object
 *
 * Use this proc to register with your parent object
 *
 * Overridable proc that's called when added to a new parent
 */
/datum/component/proc/RegisterWithParent()
	return

/**
 * Unregister from our parent object
 *
 * Use this proc to unregister from your parent object
 *
 * Overridable proc that's called when removed from a parent
 * *
 */
/datum/component/proc/UnregisterFromParent()
	return

/**
 * Register to listen for a signal from the passed in target
 *
 * This sets up a listening relationship such that when the target object emits a signal
 * the source datum this proc is called upon, will receive a callback to the given proctype
 * Use PROC_REF(procname), TYPE_PROC_REF(type,procname) or GLOBAL_PROC_REF(procname) macros to validate the passed in proc at compile time.
 * PROC_REF for procs defined on current type or it's ancestors, TYPE_PROC_REF for procs defined on unrelated type and GLOBAL_PROC_REF for global procs.
 * Return values from procs registered must be a bitfield
 *
 * Arguments:
 * * datum/target The target to listen for signals from
 * * signal_type A signal name
 * * proctype The proc to call back when the signal is emitted
 * * override If a previous registration exists you must explicitly set this
 */
/datum/proc/RegisterSignal(datum/target, signal_type, proctype, override = FALSE)
	if(QDELETED(src) || QDELETED(target))
		return

	if (islist(signal_type))
		var/static/list/known_failures = list()
		var/list/signal_type_list = signal_type
		var/message = "([target.type]) is registering [signal_type_list.Join(", ")] as a list, the older method. Change it to RegisterSignals."

		if (!(message in known_failures))
			known_failures[message] = TRUE
			stack_trace("[target] [message]")

		RegisterSignals(target, signal_type, proctype, override)
		return

	var/list/procs = (signal_procs ||= list())
	var/list/target_procs = (procs[target] ||= list())
	var/list/lookup = (target.comp_lookup ||= list())

	if(!override && target_procs[signal_type])
		var/override_message = "[signal_type] overridden. Use override = TRUE to suppress this warning.\nTarget: [target] ([target.type]) Proc: [proctype]"
		// I need to split singals into their own logs eventually
		//log_signal(override_message)
		stack_trace(override_message)

	target_procs[signal_type] = proctype
	var/list/looked_up = lookup[signal_type]

	if(isnull(looked_up)) // Nothing has registered here yet
		lookup[signal_type] = src
	else if(looked_up == src) // We already registered here
		return
	else if(!length(looked_up)) // One other thing registered here
		lookup[signal_type] = list((looked_up) = TRUE, (src) = TRUE)
	else // Many other things have registered here
		looked_up[src] = TRUE

/// Registers multiple signals to the same proc.
/datum/proc/RegisterSignals(datum/target, list/signal_types, proctype, override = FALSE)
	if(!islist(signal_types))
		stack_trace("[target] called RegisterSignals() with non-list signal: [signal_types]")
		RegisterSignal(target, signal_types, proctype, override)
		return
	for (var/signal_type in signal_types)
		RegisterSignal(target, signal_type, proctype, override)

/**
 * Stop listening to a given signal from target
 *
 * Breaks the relationship between target and source datum, removing the callback when the signal fires
 *
 * Doesn't care if a registration exists or not
 *
 * Arguments:
 * * datum/target Datum to stop listening to signals from
 * * sig_typeor_types Signal string key or list of signal keys to stop listening to specifically
 */
/datum/proc/UnregisterSignal(datum/target, sig_type_or_types)
	var/list/lookup = target.comp_lookup
	if(!signal_procs || !signal_procs[target] || !lookup)
		return
	if(!islist(sig_type_or_types))
		sig_type_or_types = list(sig_type_or_types)
	for(var/sig in sig_type_or_types)
		if(!signal_procs[target][sig])
			if(!istext(sig))
				stack_trace("We're unregistering with something that isn't a valid signal \[[sig]\], you fucked up")
			continue
		switch(length(lookup[sig]))
			if(2)
				lookup[sig] = (lookup[sig]-src)[1]
			if(1)
				stack_trace("[target] ([target.type]) somehow has single length list inside comp_lookup")
				if(src in lookup[sig])
					lookup -= sig
					if(!length(lookup))
						target.comp_lookup = null
						break
			if(0)
				if(lookup[sig] != src)
					continue
				lookup -= sig
				if(!length(lookup))
					target.comp_lookup = null
					break
			else
				lookup[sig] -= src

	signal_procs[target] -= sig_type_or_types
	if(!signal_procs[target].len)
		signal_procs -= target

/datum/component/proc/InheritComponent(datum/component/C, i_am_original)
	return

/datum/component/proc/CheckDupeComponent(datum/component/C, ...)
	return

/datum/component/proc/PreTransfer()
	return

/datum/component/proc/PostTransfer()
	return COMPONENT_INCOMPATIBLE //Do not support transfer by default as you must properly support it

/datum/component/proc/_GetInverseTypeList(our_type = type)
	//we can do this one simple trick
	var/current_type = parent_type
	. = list(our_type, current_type)
	//and since most components are root level + 1, this won't even have to run
	while (current_type != /datum/component)
		current_type = type2parent(current_type)
		. += current_type

/datum/proc/_SendSignal(sigtype, list/arguments)
	var/target = comp_lookup[sigtype]
	if(!length(target))
		var/datum/listening_datum = target
		return NONE | call(listening_datum, listening_datum.signal_procs[src][sigtype])(arglist(arguments))
	. = NONE
	// This exists so that even if one of the signal receivers unregisters the signal,
	// all the objects that are receiving the signal get the signal this final time.
	// AKA: No you can't cancel the signal reception of another object by doing an unregister in the same signal.
	var/list/queued_calls = list()
	for(var/datum/listening_datum as anything in target)
		queued_calls[listening_datum] = listening_datum.signal_procs[src][sigtype]
	for(var/datum/listening_datum as anything in queued_calls)
		. |= call(listening_datum, queued_calls[listening_datum])(arglist(arguments))

/datum/proc/GetComponent(datum/component/c_type)
	RETURN_TYPE(c_type)
	if(initial(c_type.dupe_mode) == COMPONENT_DUPE_ALLOWED || initial(c_type.dupe_mode) == COMPONENT_DUPE_SELECTIVE)
		stack_trace("GetComponent was called to get a component of which multiple copies could be on an object. This can easily break and should be changed. Type: \[[c_type]\]")
	var/list/dc = datum_components
	if(!dc)
		return null
	. = dc[c_type]
	if(length(.))
		return .[1]

/datum/proc/GetExactComponent(datum/component/c_type)
	RETURN_TYPE(c_type)
	if(initial(c_type.dupe_mode) == COMPONENT_DUPE_ALLOWED || initial(c_type.dupe_mode) == COMPONENT_DUPE_SELECTIVE)
		stack_trace("GetComponent was called to get a component of which multiple copies could be on an object. This can easily break and should be changed. Type: \[[c_type]\]")
	var/list/dc = datum_components
	if(!dc)
		return null
	var/datum/component/C = dc[c_type]
	if(C)
		if(length(C))
			C = C[1]
		if(C.type == c_type)
			return C
	return null

/datum/proc/GetComponents(c_type)
	var/list/components = datum_components?[c_type]
	if(!components)
		return list()
	return islist(components) ? components : list(components)

/datum/proc/_AddComponent(list/raw_args)
	var/new_type = raw_args[1]
	var/datum/component/nt = new_type

	if(QDELING(src))
		CRASH("Attempted to add a new component of type \[[nt]\] to a qdeleting parent of type \[[type]\]!")

	var/dm = initial(nt.dupe_mode)
	var/dt = initial(nt.dupe_type)

	var/datum/component/old_comp
	var/datum/component/new_comp

	if(ispath(nt))
		if(nt == /datum/component)
			CRASH("[nt] attempted instantiation!")
	else
		new_comp = nt
		nt = new_comp.type

	raw_args[1] = src

	if(dm != COMPONENT_DUPE_ALLOWED && dm != COMPONENT_DUPE_SELECTIVE)
		if(!dt)
			old_comp = GetExactComponent(nt)
		else
			old_comp = GetComponent(dt)
		if(old_comp)
			switch(dm)
				if(COMPONENT_DUPE_UNIQUE)
					if(!new_comp)
						new_comp = new nt(raw_args)
					if(!QDELETED(new_comp))
						old_comp.InheritComponent(new_comp, TRUE)
						QDEL_NULL(new_comp)
				if(COMPONENT_DUPE_HIGHLANDER)
					if(!new_comp)
						new_comp = new nt(raw_args)
					if(!QDELETED(new_comp))
						new_comp.InheritComponent(old_comp, FALSE)
						QDEL_NULL(old_comp)
				if(COMPONENT_DUPE_UNIQUE_PASSARGS)
					if(!new_comp)
						var/list/arguments = raw_args.Copy(2)
						arguments.Insert(1, null, TRUE)
						old_comp.InheritComponent(arglist(arguments))
					else
						old_comp.InheritComponent(new_comp, TRUE)
		else if(!new_comp)
			new_comp = new nt(raw_args) // There's a valid dupe mode but there's no old component, act like normal
	else if(dm == COMPONENT_DUPE_SELECTIVE)
		var/list/arguments = raw_args.Copy()
		arguments[1] = new_comp
		var/make_new_component = TRUE
		for(var/datum/component/existing_component as anything in GetComponents(new_type))
			if(existing_component.CheckDupeComponent(arglist(arguments)))
				make_new_component = FALSE
				QDEL_NULL(new_comp)
				break
		if(!new_comp && make_new_component)
			new_comp = new nt(raw_args)
	else if(!new_comp)
		new_comp = new nt(raw_args) // Dupes are allowed, act like normal

	if(!old_comp && !QDELETED(new_comp)) // Nothing related to duplicate components happened and the new component is healthy
		SEND_SIGNAL(src, COMSIG_COMPONENT_ADDED, new_comp)
		return new_comp
	return old_comp

/datum/proc/_LoadComponent(list/arguments)
	. = GetComponent(arguments[1])
	if(!.)
		return _AddComponent(arguments)

/datum/component/proc/RemoveComponent()
	if(!parent)
		return
	var/datum/old_parent = parent
	PreTransfer()
	_RemoveFromParent()
	parent = null
	SEND_SIGNAL(old_parent, COMSIG_COMPONENT_REMOVING, src)

/datum/proc/TakeComponent(datum/component/target)
	if(!target || target.parent == src)
		return
	if(target.parent)
		target.RemoveComponent()
	target.parent = src
	var/result = target.PostTransfer()
	switch(result)
		if(COMPONENT_INCOMPATIBLE)
			var/c_type = target.type
			qdel(target)
			CRASH("Incompatible [c_type] transfer attempt to a [type]!")

	if(target == AddComponent(target))
		target._JoinParent()

/datum/proc/TransferComponents(datum/target)
	var/list/dc = datum_components
	if(!dc)
		return
	var/comps = dc[/datum/component]
	if(islist(comps))
		for(var/datum/component/I in comps)
			if(I.can_transfer)
				target.TakeComponent(I)
	else
		var/datum/component/C = comps
		if(C.can_transfer)
			target.TakeComponent(comps)

/datum/component/ui_host()
	return parent
