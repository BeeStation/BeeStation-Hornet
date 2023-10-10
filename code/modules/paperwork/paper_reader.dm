/obj/item/paper_reader
	name = "eletronic paper reader"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_reader"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	pressure_resistance = 0
	max_integrity = 50

/obj/item/paper_reader/Initialize(mapload)
	. = ..()
	icon_state += "-[pick(list("red", "blue", "green", "grey"))]"
	if(prob(0.1))
		icon_state = "paper_reader-rare"

/obj/item/paper_reader/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /obj/item/paper))
		var/obj/item/paper/P = target
		var/count = 0
		for(var/datum/paper_input/i in P.raw_text_inputs)
			var/text = i.raw_text
			if(text && text != "")
				count += 1
				addtimer(CALLBACK(src, PROC_REF(say_timer), "[html_decode(text)]..."), (0.5 * count) SECONDS)

/obj/item/paper_reader/proc/say_timer(text)
	say(text)
