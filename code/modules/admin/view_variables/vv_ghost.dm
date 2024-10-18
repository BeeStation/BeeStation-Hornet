GLOBAL_DATUM_INIT(vv_ghost, /datum/vv_ghost, new) // Fake datum for vv debug_variables() proc. Am I real?

/*
	< What the hell is this vv_ghost? >
		Our view-variables client proc doesn't like to investigate.
		This means `debug_variables(list_reference)` won't work, because it only wants /datum.
		vv_ghost exists to trick the proc, by storing values to bypass /datum restriction of the proc.
		but also, it exists to deliever some special list that isn't possible to get through locate().
	< Can you just do `locate([0x0_list_ref_id])`? >
		Only an ordinary /list is possible to be located through locate()
		First, vv takes values from 'href' texts.
		Of course, we can get ref_id of a special list,
		BUT `locate(ref_id_of_special_list)` returns null. (only ordinary /list works this)
		This is why we need to store 'special_owner', and 'special_varname'
		We locate(special_owner), then access their special list from their var list.
			=> special_onwer:vars[special_varname]
	< Summary >
		Two usages exist:
		1. Store a list_ref into this datum, to deliver the list into the vv debugging system.
		2. Store a datum's ref_id with target varname, to deliver the special list into the vv debugging system.
*/

/datum/vv_ghost
	// --- variables for vv special list ---
	/// Reference ID of a thing.
	var/special_owner
	/// which var of the reference you're s eeing
	var/special_varname
	/// an actual ref from above (= owner:vars[special_varname])
	var/special_ref // this exists to remember the actual special list reference for a while.


	// --- variable for ordinary lists ---
	/// a list ref that isn't special
	var/list_ref


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

/datum/vv_ghost/proc/mark_special(owner, varname)
	if(special_owner)
		CRASH("vv_ghost has special_owner already: [special_owner]. It can be async issue.")
	if(special_varname)
		CRASH("vv_ghost has special_varname already: [special_varname]. It can be async issue.")
	special_owner = owner
	special_varname = varname

/datum/vv_ghost/proc/mark_list_ref(actual_list)
	if(list_ref)
		CRASH("vv_ghost has list_ref already: [list_ref]. It can be async issue.")
	list_ref = actual_list

/// a proc that delivers values to vv_spectre (internal static one).
/// vv_spectre exists to prevent async error, just in case
/datum/vv_ghost/proc/deliver_special()
	if(GLOB.vv_ghost == src)
		CRASH("This proc isn't meant be called from GLOB one.")

	special_owner = GLOB.vv_ghost.special_owner // = [0x123456]
	special_varname = GLOB.vv_ghost.special_varname // = "vis_contents"
	GLOB.vv_ghost.special_owner = null
	GLOB.vv_ghost.special_varname = null

	special_ref = locate(special_owner) // = Clown [0x123456]
	special_ref = special_ref:vars[special_varname] // = Clown.vis_contents
	return special_ref

/// a proc that delivers values to vv_spectre (internal static one).
/// vv_spectre exists to prevent async error, just in case
/datum/vv_ghost/proc/deliver_list_ref()
	if(GLOB.vv_ghost == src)
		CRASH("This proc isn't meant be called from GLOB one.")

	var/return_target = GLOB.vv_ghost.list_ref
	GLOB.vv_ghost.list_ref = null
	return return_target

/datum/vv_ghost/proc/reset()
	special_owner = special_varname = special_ref = list_ref = null
