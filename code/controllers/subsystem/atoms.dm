#define BAD_INIT_QDEL_BEFORE 1
#define BAD_INIT_DIDNT_INIT 2
#define BAD_INIT_SLEPT 4
#define BAD_INIT_NO_HINT 8

SUBSYSTEM_DEF(atoms)
	name = "Atoms"
	init_order = INIT_ORDER_ATOMS
	flags = SS_NO_FIRE

	var/old_initialized

	/// Is initialized currently changed if yes then this is TRUE otherwise false here so we can prevent old_initialize being overriden by some other value, breaking init code
	var/initialized_changed = 0

	var/list/late_loaders = list()

	var/list/BadInitializeCalls = list()

	///initAtom() adds the atom its creating to this list iff InitializeAtoms() has been given a list to populate as an argument
	var/list/created_atoms

	#ifdef PROFILE_MAPLOAD_INIT_ATOM
	var/list/mapload_init_times = list()
	#endif

	initialized = INITIALIZATION_INSSATOMS

/datum/controller/subsystem/atoms/Initialize(timeofday)
	//Wait until map loading is completed
	if (length(SSmap_generator.executing_generators) > 0)
		to_chat(world, "<span class='boldannounce'>Waiting for [length(SSmap_generator.executing_generators)] map generators...</bold>")
		do
			SSmap_generator.fire()
			sleep(0.5)
		while (length(SSmap_generator.executing_generators) > 0)
		to_chat(world, "<span class='boldannounce'>Map generators completed, initializing atoms.</bold>")

	GLOB.fire_overlay.appearance_flags = RESET_COLOR
	setupGenetics() //to set the mutations' sequence
	initialized = INITIALIZATION_INNEW_MAPLOAD
	InitializeAtoms()
	return ..()

#ifdef PROFILE_MAPLOAD_INIT_ATOM
#define PROFILE_INIT_ATOM_BEGIN(...) var/__profile_stat_time = TICK_USAGE
#define PROFILE_INIT_ATOM_END(atom) mapload_init_times[##atom.type] += TICK_USAGE_TO_MS(__profile_stat_time)
#else
#define PROFILE_INIT_ATOM_BEGIN(...)
#define PROFILE_INIT_ATOM_END(...)
#endif

/datum/controller/subsystem/atoms/proc/InitializeAtoms(list/atoms, list/atoms_to_return)
	if(initialized == INITIALIZATION_INSSATOMS)
		return

	set_tracked_initalized(INITIALIZATION_INNEW_MAPLOAD)

	// This may look a bit odd, but if the actual atom creation runtimes for some reason, we absolutely need to set initialized BACK
	CreateAtoms(atoms, atoms_to_return)
	clear_tracked_initalize()

	#ifdef TESTING
	var/late_loader_len = late_loaders.len
	#endif
	if(late_loaders.len)
		for(var/atom/A as() in late_loaders)
			//I hate that we need this
			if(QDELETED(A))
				continue
			late_loaders -= A //We don't want to call LateInitialize twice in case of stoplag()
			A.LateInitialize()
		testing("Late initialized [late_loader_len] atoms")
		late_loaders.Cut()

	if(created_atoms)
		atoms_to_return += created_atoms
		created_atoms = null

#ifdef PROFILE_MAPLOAD_INIT_ATOM
	var/list/lines = list()
	lines += "Atom Path,Initialisation Time (ms)"
	for (var/atom_type in mapload_init_times)
		var/time = mapload_init_times[atom_type]
		lines += "[atom_type],[time]"
	rustg_file_write(jointext(lines, "\n"), "[GLOB.log_directory]/init_times.csv")
#endif

/// Actually creates the list of atoms. Exists soley so a runtime in the creation logic doesn't cause initalized to totally break
/datum/controller/subsystem/atoms/proc/CreateAtoms(list/atoms, list/atoms_to_return = null)
	if (atoms_to_return)
		LAZYINITLIST(created_atoms)

	var/count
	var/list/mapload_arg = list(TRUE)
	if(atoms)
		count = atoms.len
		for(var/I in 1 to count)
			var/atom/A = atoms[I]
			if(!(A.flags_1 & INITIALIZED_1))
				CHECK_TICK
				PROFILE_INIT_ATOM_BEGIN()
				InitAtom(A, TRUE, mapload_arg)
				PROFILE_INIT_ATOM_END(A)
	else
		count = 0
		for(var/atom/A in world)
			if(!(A.flags_1 & INITIALIZED_1))
				PROFILE_INIT_ATOM_BEGIN()
				InitAtom(A, FALSE, mapload_arg)
				PROFILE_INIT_ATOM_END(A)
				++count
				CHECK_TICK

	testing("Initialized [count] atoms")
	pass(count)

/// Init this specific atom
/datum/controller/subsystem/atoms/proc/InitAtom(atom/A, from_template = FALSE, list/arguments)
	var/the_type = A.type
	if(QDELING(A))
		BadInitializeCalls[the_type] |= BAD_INIT_QDEL_BEFORE
		return TRUE

	var/start_tick = world.time

	var/result = A.Initialize(arglist(arguments))

	if(start_tick != world.time)
		BadInitializeCalls[the_type] |= BAD_INIT_SLEPT

	var/qdeleted = FALSE

	if(result != INITIALIZE_HINT_NORMAL)
		switch(result)
			if(INITIALIZE_HINT_LATELOAD)
				if(arguments[1])	//mapload
					late_loaders += A
				else
					A.LateInitialize()
			if(INITIALIZE_HINT_QDEL)
				qdel(A)
				qdeleted = TRUE
			if(INITIALIZE_HINT_QDEL_FORCE)
				qdel(A, force = TRUE)
				qdeleted = TRUE
			else
				BadInitializeCalls[the_type] |= BAD_INIT_NO_HINT

	if(!A)	//possible harddel
		qdeleted = TRUE
	else if(!(A.flags_1 & INITIALIZED_1))
		BadInitializeCalls[the_type] |= BAD_INIT_DIDNT_INIT
	else
		SEND_SIGNAL(A,COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)
		if(created_atoms && from_template && ispath(the_type, /atom/movable))//we only want to populate the list with movables
			created_atoms += A.GetAllContents()

	return qdeleted || QDELING(A)

/datum/controller/subsystem/atoms/proc/map_loader_begin()
	set_tracked_initalized(INITIALIZATION_INSSATOMS)

/datum/controller/subsystem/atoms/proc/map_loader_stop()
	clear_tracked_initalize()

/// Use this to set initialized to prevent error states where old_initialized is overriden. It keeps happening and it's cheesing me off
/datum/controller/subsystem/atoms/proc/set_tracked_initalized(value)
	if(!initialized_changed)
		old_initialized = initialized
		initialized = value
		initialized_changed = TRUE // who cares how often this gets called important is only that we don't overwrite old_initialize
	else
		stack_trace("We started maploading while we were already maploading. You doing something odd?")

/datum/controller/subsystem/atoms/proc/clear_tracked_initalize()
	initialized_changed = FALSE
	initialized = old_initialized

/datum/controller/subsystem/atoms/Recover()
	initialized = SSatoms.initialized
	if(initialized == INITIALIZATION_INNEW_MAPLOAD)
		InitializeAtoms()
	old_initialized = SSatoms.old_initialized
	BadInitializeCalls = SSatoms.BadInitializeCalls

/datum/controller/subsystem/atoms/proc/setupGenetics()
	var/list/mutations = subtypesof(/datum/mutation)
	shuffle_inplace(mutations)
	for(var/datum/generecipe/GR as() in subtypesof(/datum/generecipe))
		GLOB.mutation_recipes[initial(GR.required)] = initial(GR.result)
	for(var/i in 1 to length(mutations))
		var/path = mutations[i] //byond gets pissy when we do it in one line
		var/datum/mutation/B = new path ()
		B.alias = "Mutation [i]"
		GLOB.all_mutations[B.type] = B
		GLOB.full_sequences[B.type] = generate_gene_sequence(B.blocks)
		GLOB.alias_mutations[B.alias] = B.type
		if(B.locked)
			continue
		if(B.quality == POSITIVE)
			GLOB.good_mutations |= B
		else if(B.quality == NEGATIVE)
			GLOB.bad_mutations |= B
		else if(B.quality == MINOR_NEGATIVE)
			GLOB.not_good_mutations |= B
		CHECK_TICK

/datum/controller/subsystem/atoms/proc/InitLog()
	. = ""
	for(var/path in BadInitializeCalls)
		. += "Path : [path] \n"
		var/fails = BadInitializeCalls[path]
		if(fails & BAD_INIT_DIDNT_INIT)
			. += "- Didn't call atom/Initialize(mapload)\n"
		if(fails & BAD_INIT_NO_HINT)
			. += "- Didn't return an Initialize hint\n"
		if(fails & BAD_INIT_QDEL_BEFORE)
			. += "- Qdel'd in New()\n"
		if(fails & BAD_INIT_SLEPT)
			. += "- Slept during Initialize()\n"

/datum/controller/subsystem/atoms/Shutdown()
	var/initlog = InitLog()
	if(initlog)
		rustg_file_append(initlog, "[GLOB.log_directory]/initialize.log")
