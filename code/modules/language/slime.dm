/datum/language/slime
	name = "Slime"
	desc = "A melodic and complex language spoken by slimes. Some of the notes are inaudible to humans."
	key = "k"
	syllables = list("qr","qrr","xuq","qil","quum","xuqm","vol","xrim","zaoo","qu-uu","qix","qoo","zix")
	special_characters = list("!","*")
	default_priority = 70

	icon_state = "slime"


/datum/language/slime/get_random_name(
	gender,
	name_count,
	syllable_min,
	syllable_max,
	force_use_syllables,
)
	if(force_use_syllables)
		return ..()
	var/name = "[pick(GLOB.oozeling_first_names)] [pick(GLOB.oozeling_last_names)]"
	return name
