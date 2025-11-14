// Ritual spells which affect the station at large
/// How much threat we need to let these rituals happen on dynamic
#define MINIMUM_THREAT_FOR_RITUALS 100

/datum/spellbook_entry/summon/guns
	name = "Summon Guns"
	desc = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill you. \
		There is a good chance that they will shoot each other first."
	ritual_invocation = "ALADAL DESINARI ODORI'IN TUUR'IS OVOR'E POR"

/datum/spellbook_entry/summon/guns/can_be_purchased()
	// Also must be config enabled
	return !CONFIG_GET(flag/no_summon_guns)

/datum/spellbook_entry/summon/guns/buy_spell(mob/living/carbon/human/user,obj/item/spellbook/book)
	give_guns(user)
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	return ..()

/datum/spellbook_entry/summon/magic
	name = "Summon Magic"
	desc = "Share the wonders of magic with the crew and show them \
		why they aren't to be trusted with it at the same time."
	ritual_invocation = "ALADAL DESINARI ODORI'IN IDO'LEX SPERMITA OVOR'E POR"

/datum/spellbook_entry/summon/magic/can_be_purchased()
	// Also must be config enabled
	return !CONFIG_GET(flag/no_summon_magic)

/datum/spellbook_entry/summon/magic/buy_spell(mob/living/carbon/human/user,obj/item/spellbook/book)
	give_magic(user, 10)
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	return ..()

/datum/spellbook_entry/summon/events
	name = "Summon Events"
	desc = "Give Murphy's law a little push and replace all events with \
		special wizard ones that will confound and confuse everyone. \
		Multiple castings increase the rate of these events."
	cost = 2
	limit = 5 // Each purchase can intensify it.
	ritual_invocation = "ALADAL DESINARI ODORI'IN IDO'LEX MANAG'ROKT OVOR'E POR"

/datum/spellbook_entry/summon/events/can_be_purchased()
	// Also, must be config enabled
	return !CONFIG_GET(flag/no_summon_events)

/datum/spellbook_entry/summon/events/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	summonevents(user)
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	return ..()

/datum/spellbook_entry/summon/curse_of_madness
	name = "Curse of Madness"
	desc = "Curses the station, warping the minds of everyone inside, causing lasting traumas. Warning: this spell can affect you if not cast from a safe distance."
	cost = 4
	locked = TRUE
	ritual_invocation = "ALADAL DESINARI ODORI'IN PORES ENHIDO'LEN MORI MAKA TU"

/datum/spellbook_entry/summon/curse_of_madness/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	var/message = tgui_input_text(user, "Whisper a secret truth to drive your victims to madness", "Whispers of Madness")
	if(!message)
		return FALSE
	curse_of_madness(user, message)
	playsound(user, 'sound/magic/mandswap.ogg', 50, TRUE)
	return ..()

#undef MINIMUM_THREAT_FOR_RITUALS
