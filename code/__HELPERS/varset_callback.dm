/// datum may be null, but it does need to be a typed var
#define NAMEOF(datum, X) (#X || ##datum.##X)


/**
 * NAMEOF that actually works in static definitions because src::type requires src to be defined
 */
#define NAMEOF_STATIC(datum, X) (nameof(type::##X))

#define VARSET_LIST_CALLBACK(target, var_name, var_value) CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(___callbackvarset), ##target, ##var_name, ##var_value)
//dupe code because dm can't handle 3 level deep macros
#define VARSET_CALLBACK(datum, var, var_value) CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(___callbackvarset), ##datum, NAMEOF(##datum, ##var), ##var_value)
/// Same as VARSET_CALLBACK, but uses a weakref to the datum.
/// Use this if the timer is exceptionally long.
#define VARSET_WEAK_CALLBACK(datum, var, var_value) CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(___callbackvarset), WEAKREF(##datum), NAMEOF(##datum, ##var), ##var_value)

/proc/___callbackvarset(list_or_datum, var_name, var_value)
	if(length(list_or_datum))
		list_or_datum[var_name] = var_value
		return
	var/datum/D = list_or_datum
	if(IsAdminAdvancedProcCall())
		D.vv_edit_var(var_name, var_value)	//same result generally, unless badmemes
	else
		D.vars[var_name] = var_value
