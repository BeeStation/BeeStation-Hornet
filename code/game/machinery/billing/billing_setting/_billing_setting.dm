/datum/billing_setting
	var/name = "generic setting"
	var/desc
	/// Which department/s has access to this setting
	var/list/department_ID = list(ACCOUNT_COM_ID)
	/// What kind of UI do we use?
	var/ui_type = BILLING_SETTING_TYPE_NUMBERS

/datum/billing_setting/proc/get_data()
	var/list/data = list("ref" = REF(src), "name" = name, "desc" = desc, "department_ID" = department_ID, "ui_type" = ui_type)
	return data

// Used to store a simple number with an upper and lower
/datum/billing_setting/number
	var/number = 1
	var/upper = 2
	var/lower = 0
	var/step = 1

/datum/billing_setting/number/proc/set_number(_number)
	number = clamp(_number, lower, upper)

/datum/billing_setting/number/get_data()
	. = ..()
	. += list("number" = number, "upper" = upper, "lower" = lower, "step" = step)
