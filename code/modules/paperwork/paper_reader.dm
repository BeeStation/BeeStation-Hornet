/obj/item/paper_reader
	name = "electronic paper reader"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_reader"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	pressure_resistance = 0
	max_integrity = 50
	///List for the reading loop
	var/list/to_read = list()
	///Is this in use?
	var/in_use = FALSE

/obj/item/paper_reader/Initialize(mapload)
	. = ..()
	icon_state += "-[pick(list("red", "blue", "green", "grey"))]"
	if(prob(0.1))
		icon_state = "paper_reader-rare"

/obj/item/paper_reader/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(in_use)
		to_read.Cut()
		in_use = FALSE
		balloon_alert(user, "Interrupts the reader.")
		return
	if(istype(target, /obj/item/paper))
		var/obj/item/paper/P = target
		for(var/datum/paper_input/i in P.raw_text_inputs)
			var/text = i.raw_text
			if(text && text != "")
				to_read += text
		in_use = TRUE
		INVOKE_ASYNC(src, PROC_REF(handle_todo))

/obj/item/paper_reader/proc/handle_todo()
	if(!length(to_read) || QDELETED(src))
		in_use = FALSE
		return
	say(strip_html_tags(to_read[1]))
	to_read.Remove(to_read[1])
	sleep(1 SECONDS)
	INVOKE_ASYNC(src, PROC_REF(handle_todo))
