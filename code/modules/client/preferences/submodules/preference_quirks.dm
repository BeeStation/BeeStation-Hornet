/datum/preferences/proc/GetQuirkBalance()
	// TODO tgui-prefs
	/*var/bal = 0
	for(var/V in all_quirks)
		var/datum/quirk/T = SSquirks.quirks[V]
		bal -= initial(T.value)
	return bal*/
	return 0

/datum/preferences/proc/GetPositiveQuirkCount()
	/*. = 0
	for(var/q in all_quirks)
		if(SSquirks.quirk_points[q] > 0)
			.++*/
	return 0

/datum/preferences/proc/validate_quirks()
	//if(GetQuirkBalance() < 0)
	//	all_quirks = list()
	return
