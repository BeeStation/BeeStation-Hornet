/// Deaddrop box, cannot be opened until it is released
/obj/item/storage/deaddrop_box
	name = "secured box"
	desc = "A secure box that probably contains a variety of items the \
		average crewmember probably wouldn't want around the station."
	w_class = WEIGHT_CLASS_NORMAL
	// Prevent it from being opened until it is ready to be opened
	obj_flags = INDESTRUCTIBLE
	component_type = /datum/component/storage/concrete/deaddrop

/obj/item/storage/deaddrop_box/proc/unlock()
	// You can now break it to your hearts desire
	obj_flags &= ~INDESTRUCTIBLE
	var/datum/component/storage = GetComponent(/datum/component/storage)
	storage.locked = FALSE

/datum/component/storage/concrete/deaddrop
	locked = TRUE
	can_transfer = FALSE
	emp_shielded = TRUE
	quickdraw = TRUE
