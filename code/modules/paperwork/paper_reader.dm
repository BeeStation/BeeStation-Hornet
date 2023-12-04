/obj/item/paper_reader
	name = "eletronic paper reader"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_reader"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	pressure_resistance = 0
	max_integrity = 50
	///TODO list for the reading loop
	var/list/to_read = list()
	///Cooldown for use
	var/read_cooldown = 4 SECONDS
	var/cooldown_timer

/obj/item/paper_reader/Initialize(mapload)
	. = ..()
	icon_state += "-[pick(list("red", "blue", "green", "grey"))]"
	if(prob(0.1))
		icon_state = "paper_reader-rare"

/obj/item/paper_reader/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(cooldown_timer)
		return
	if(istype(target, /obj/item/paper))
		var/obj/item/paper/P = target
		for(var/datum/paper_input/i in P.raw_text_inputs)
			var/text = i.raw_text
			if(text && text != "")
				to_read += text
		INVOKE_ASYNC(src, PROC_REF(handle_todo))
		addtimer(CALLBACK(src, PROC_REF(handle_timer)), read_cooldown, TIMER_STOPPABLE)

/obj/item/paper_reader/proc/handle_timer()
	if(cooldown_timer)
		deltimer(cooldown_timer)
		cooldown_timer = null

/obj/item/paper_reader/proc/handle_todo()
	if(!length(to_read) || QDELETED(src))
		return
	say(strip_html_tags(to_read[1]))
	to_read -= to_read[1]
	sleep(1 SECONDS)
	INVOKE_ASYNC(src, PROC_REF(handle_todo))
