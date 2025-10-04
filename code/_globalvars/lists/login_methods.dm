/proc/init_login_methods()
	var/list/methods = list()
	var/list/method_paths = subtypesof(/datum/external_login_method)
	for(var/datum/external_login_method/method_path as anything in method_paths)
		methods[method_path::id] = new method_path()
	return methods

GLOBAL_LIST_INIT(login_methods, init_login_methods())
GLOBAL_PROTECT(login_methods)
