/datum/vampire_clan/brujah
	name = CLAN_BRUJAH
	description = "Not beholden to the Camarilla and their princes, brujah often form their own communities.<br><br>\
		However, the clan is a fallen clan, still mourning the death of their Carthaginian paradise and decaying from their era of warrior-scholars to the petty rebels common in modernity.<br><br>\
		In ancient times, their original ancestor was victim to diablerie by his hot-headed childer. Now, most brujah descending from this line are similarly anarchistic and wild.<br><br>\
		Rumors of the lost bloodline of 'true' brujah exist, but any evidence is long lost."
	join_icon_state = "brujah"
	join_description = "A clan of mostly rebels, some still show signs of their lost lineage of warrior-poets. They are long split from the camarilla, and often form their own groups.\n\
		<b>DISCIPLINES:</b> Potence, Celerity, Presence"
	default_humanity = 7
	joinable_clan = TRUE

/datum/vampire_clan/brujah/New(datum/antagonist/vampire/owner_datum)
	. = ..()
