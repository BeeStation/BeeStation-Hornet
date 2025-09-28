/// Init this specific atom
/datum/controller/subsystem/atoms/proc/InitAtom(atom/A, from_template = FALSE, list/arguments)
	var/the_type = A.type
	if(QDELING(A))
		BadInitializeCalls[the_type] |= BAD_INIT_QDEL_BEFORE
		return TRUE

	// This is handled and battle tested by dreamchecker. Limit to UNIT_TESTS just in case that ever fails.
	#ifdef UNIT_TESTS
	var/start_tick = world.time
	#endif

	var/result = A.Initialize(arglist(arguments))

	#ifdef UNIT_TESTS
	if(start_tick != world.time)
		BadInitializeCalls[the_type] |= BAD_INIT_SLEPT
	#endif

	var/qdeleted = FALSE

	switch(result)
		if (INITIALIZE_HINT_NORMAL)
			// pass
		if(INITIALIZE_HINT_LATELOAD)
			if(arguments[1]) //mapload
				late_loaders += A
			else
				A.LateInitialize()
		if(INITIALIZE_HINT_QDEL)
			qdel(A)
			return TRUE //Don't need to check anything else since we know it's deleted already
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

/**
 * Called when an atom is created in byond (built in engine proc)
 *
 * Not a lot happens here in SS13 code, as we offload most of the work to the
 * [Intialization](atom.html#proc/Initialize) proc, mostly we run the preloader
 * if the preloader is being used and then call InitAtom of which the ultimate
 * result is that the Intialize proc is called.
 *
 * We also generate a tag here if the DF_USE_TAG flag is set on the atom
 */
/atom/New(loc, ...)
	// Atom creation method that preloads variables at creation
	if(GLOB.use_preloader && src.type == GLOB._preloader_path)//in case the instanciated atom is creating other atoms in New()
		world.preloader_load(src)

	var/do_initialize = SSatoms.initialized
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, FALSE, args))
			//we were deleted
			return

/**
  * The primary method that objects are setup in SS13 with
  *
  * we don't use New as we have better control over when this is called and we can choose
  * to delay calls or hook other logic in and so forth
  *
  * During roundstart map parsing, atoms are queued for intialization in the base atom/New(),
  * After the map has loaded, then Initalize is called on all atoms one by one. NB: this
  * is also true for loading map templates as well, so they don't Initalize until all objects
  * in the map file are parsed and present in the world
  *
  * If you're creating an object at any point after SSInit has run then this proc will be
  * immediately be called from New.
  *
  * mapload: This parameter is true if the atom being loaded is either being intialized during
  * the Atom subsystem intialization, or if the atom is being loaded from the map template.
  * If the item is being created at runtime any time after the Atom subsystem is intialized then
  * it's false.
  *
  * You must always call the parent of this proc, otherwise failures will occur as the item
  * will not be seen as initalized (this can lead to all sorts of strange behaviour, like
  * the item being completely unclickable)
  *
  * You must not sleep in this proc, or any subprocs
  *
  * Any parameters from new are passed through (excluding loc), naturally if you're loading from a map
  * there are no other arguments
  *
  * Must return an [initialization hint](code/__DEFINES/subsystems.html) or a runtime will occur.
  *
  * Note: the following functions don't call the base for optimization and must copypasta handling:
  * * /turf/Initialize
  * * /turf/open/space/Initialize
  */

/atom/proc/Initialize(mapload, ...)
	//SHOULD_NOT_SLEEP(TRUE) //TODO: We shouldn't be sleeping initialize
	SHOULD_CALL_PARENT(TRUE)

	if(flags_1 & INITIALIZED_1)
		stack_trace("Warning: [src]([type]) initialized multiple times!")
	flags_1 |= INITIALIZED_1

	if(loc)
		SEND_SIGNAL(loc, COMSIG_ATOM_CREATED, src) /// Sends a signal that the new atom `src`, has been created at `loc`

	if(greyscale_config && greyscale_colors)
		update_greyscale()

	//atom color stuff
	if(color)
		add_atom_colour(color, FIXED_COLOUR_PRIORITY)

	if (light_system == STATIC_LIGHT && light_power && light_range)
		update_light()

	// apply materials properly from the default custom_materials value
	set_custom_materials(custom_materials)

	if(uses_integrity)
		atom_integrity = max_integrity

	InitializeAIController()

	if(length(smoothing_groups))
		#ifdef UNIT_TESTS
		assert_sorted(smoothing_groups, "[type].smoothing_groups")
		#endif
		SET_BITFLAG_LIST(smoothing_groups)
	if(length(canSmoothWith))
		#ifdef UNIT_TESTS
		assert_sorted(canSmoothWith, "[type].canSmoothWith")
		#endif
		if(canSmoothWith[length(canSmoothWith)] > MAX_S_TURF) //If the last element is higher than the maximum turf-only value, then it must scan turf contents for smoothing targets.
			smoothing_flags |= SMOOTH_OBJ
		SET_BITFLAG_LIST(canSmoothWith)

	return INITIALIZE_HINT_NORMAL

/**
 * Late Intialization, for code that should run after all atoms have run Intialization
 *
 * To have your LateIntialize proc be called, your atoms [Initalization](atom.html#proc/Initialize)
 *  proc must return the hint
 * [INITIALIZE_HINT_LATELOAD](code/__DEFINES/subsystems.html#define/INITIALIZE_HINT_LATELOAD)
 * otherwise you will never be called.
 *
 * useful for doing things like finding other machines on GLOB.machines because you can guarantee
 * that all atoms will actually exist in the "WORLD" at this time and that all their Intialization
 * code has been run
 */
/atom/proc/LateInitialize()
	set waitfor = FALSE
