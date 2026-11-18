/datum/status_effect/ipc_upgrade/emp_shield
	id = "ipc emp shield"
	name = "Disposable EMP Shielding"
	item_type = /obj/item/ipc_upgrade/emp_shield
	var/remaining_pulses = 5 // you get 5 emps before this stops working

/datum/status_effect/ipc_upgrade/emp_shield/on_apply()
	. = ..()
	owner.AddElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)

/datum/status_effect/ipc_upgrade/emp_shield/on_remove()
	. = ..()
	owner.RemoveElement(/datum/element/empprotection, EMP_PROTECT_SELF|EMP_PROTECT_CONTENTS)

/datum/status_effect/ipc_upgrade/emp_shield/emp_act(severity)
	. = ..()
	if(remaining_pulses <= 0)
		to_chat(owner, span_warningbold("Your [src] has been fried! You are no longer protected from EMP attacks!"))
		do_sparks(2, FALSE, owner)
		qdel(src)
	remaining_pulses -= 1
