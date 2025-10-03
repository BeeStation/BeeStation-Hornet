GLOBAL_PROTECT(vv_ghost)
GLOBAL_DATUM_INIT(vv_ghost, /datum/vv_ghost, new) // Fake datum for vv debug_variables() proc. Am I real?

/*
	< What the hell is this vv_ghost? >
		Our view-variables client proc doesn't like to investigate list() instances.
		This means `debug_variables(list_reference)` won't work, because it only wants /datum - but /list is not /datum
		vv_ghost exists to trick the proc, by storing values to bypass /datum restriction of the proc.
		but also, it exists to deliever some special list that isn't possible to get through locate().
	< Can you just do `locate([0x0_list_ref_id])`? >
		Only an ordinary /list is possible to be located through locate()
		First, vv takes values from 'href' texts.
		Of course, we can get ref_id of a special list,
		BUT `locate(ref_id_of_special_list)` returns null. (only ordinary /list works this)
		This is why we need to store 'dmlist_origin_ref', and 'dmlist_varname'
		We locate(dmlist_origin_ref), then access their special list from their var list.
			=> dmlist_holder.vars[dmlist_varname]
	< Summary >
		Two usages exist:
		1. Store a list_ref into this datum, to deliver the list into the vv debugging system.
		2. Store a datum's ref_id with target varname, to deliver the special list into the vv debugging system.
*/

/datum/vv_ghost
	// --- variables for vv special list ---
	/// Ref ID of a thing.
	var/dmlist_origin_ref
	/// which var of the reference you're s eeing
	var/dmlist_varname
	/// instance holder for special list
	var/datum/dmlist_holder

	// --- variable for ordinary lists ---
	/// instance holder for normal list
	var/list_holder

	// --- variable for internal use only ---
	/// a failsafe variable
	var/ready_to_del

/datum/vv_ghost/New()
	var/static/creation_count = 2 // to prevent something bullshit

	if(creation_count)
		creation_count--
		..()
		return

	else
		stack_trace("vv_ghost is not meant to be created more than 2 in the current logic. One for GLOB, one for vv internal")
		ready_to_del = TRUE
		qdel(src)

/datum/vv_ghost/Destroy(force = FALSE)
	if(ready_to_del || force)
		reset()
		return ..()

	stack_trace("Something breaks view-variables debugging tool... Check something.")
	return QDEL_HINT_LETMELIVE

/datum/vv_ghost/proc/mark_special(origin_ref, varname)
	if(dmlist_origin_ref)
		CRASH("vv_ghost has dmlist_origin_ref already: [dmlist_origin_ref]. It can be async issue.")
	if(dmlist_varname)
		CRASH("vv_ghost has dmlist_varname already: [dmlist_varname]. It can be async issue.")
	dmlist_origin_ref = origin_ref
	dmlist_varname = varname

/datum/vv_ghost/proc/mark_list(actual_list)
	if(list_holder)
		CRASH("vv_ghost has list_ref already: [list_holder]. It can be async issue.")
	list_holder = actual_list

/// a proc that delivers values to vv_spectre (internal static one).
/// vv_spectre exists to prevent async error, just in case
/datum/vv_ghost/proc/deliver_special()
	if(GLOB.vv_ghost == src)
		CRASH("This proc isn't meant be called from GLOB one.")

	dmlist_origin_ref = GLOB.vv_ghost.dmlist_origin_ref // = [0x123456]
	dmlist_varname = GLOB.vv_ghost.dmlist_varname // = "vis_contents"
	GLOB.vv_ghost.dmlist_origin_ref = null
	GLOB.vv_ghost.dmlist_varname = null

	var/datum/located = locate(dmlist_origin_ref) // = Clown [0x123456]
	dmlist_holder = located.vars[dmlist_varname] // = Clown.vis_contents
	return dmlist_holder

/// a proc that delivers values to vv_spectre (internal static one).
/// vv_spectre exists to prevent async error, just in case
/datum/vv_ghost/proc/deliver_list()
	if(GLOB.vv_ghost == src)
		CRASH("This proc isn't meant be called from GLOB one.")

	var/return_target = GLOB.vv_ghost.list_holder
	GLOB.vv_ghost.list_holder = null
	return return_target

/datum/vv_ghost/proc/reset()
	dmlist_origin_ref = null
	dmlist_varname = null
	dmlist_holder = null
	list_holder = null
