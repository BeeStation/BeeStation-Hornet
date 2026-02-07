/// Deaddrop box, cannot be opened until it is released
/obj/item/storage/deaddrop_box
	name = "secured box"
	desc = "A secure box that probably contains a variety of items the \
		average crewmember probably wouldn't want around the station. It is \
		exceptionally heavy and hard to carry around."
	icon_state = "safe"
	// This is heavy so that people have to hold it or hide it, making it much easier for other traitors to steal without
	// requiring them to straight up kill and rob them.
	w_class = WEIGHT_CLASS_BULKY
	// Prevent it from being opened until it is ready to be opened
	obj_flags = INDESTRUCTIBLE
	storage_type = /datum/storage/deaddrop

/obj/item/storage/deaddrop_box/proc/unlock()
	// You can now break it to your hearts desire
	obj_flags &= ~INDESTRUCTIBLE
	atom_storage.locked = FALSE
	if (ismob(loc))
		var/mob/person = loc
		to_chat(person, "<span class='notice'>[name] unlocks!</span>")
		// Sound only plays 3 tile range
		playsound(src, 'sound/machines/boltsup.ogg', 40, extrarange = -SOUND_RANGE + 3)

/datum/storage/deaddrop
	locked = TRUE
	emp_shielded = TRUE
	quickdraw = FALSE
	rustle_sound = FALSE
