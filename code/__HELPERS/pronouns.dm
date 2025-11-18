//pronoun procs, for getting pronouns without using the text macros that only work in certain positions
//datums don't have gender, but most of their subtypes do!

/datum/proc/p_they(temp_gender)
	return "it"

/datum/proc/p_They(temp_gender)
	return capitalize(p_they(temp_gender))

/datum/proc/p_their(temp_gender)
	return "its"

/datum/proc/p_Their(temp_gender)
	return capitalize(p_their(temp_gender))

/datum/proc/p_theirs(temp_gender)
	return "its"

/datum/proc/p_Theirs(temp_gender)
	return capitalize(p_theirs(temp_gender))

/datum/proc/p_them(temp_gender)
	return "it"

/datum/proc/p_Them(temp_gender)
	return capitalize(p_them(temp_gender))

/datum/proc/p_have(temp_gender)
	. = "has"

/datum/proc/p_are(temp_gender)
	. = "is"

/datum/proc/p_were(temp_gender)
	. = "was"

/datum/proc/p_do(temp_gender)
	. = "does"

/datum/proc/p_theyve(temp_gender)
	return p_they(temp_gender) + "'" + copytext_char(p_have(temp_gender), 3)

/datum/proc/p_Theyve(temp_gender)
	return p_They(temp_gender) + "'" + copytext_char(p_have(temp_gender), 3)

/datum/proc/p_theyre(temp_gender)
	return p_they(temp_gender) + "'" + copytext_char(p_are(temp_gender), 2)

/datum/proc/p_Theyre(temp_gender)
	return p_They(temp_gender) + "'" + copytext_char(p_are(temp_gender), 2)

/datum/proc/p_s(temp_gender) //is this a descriptive proc name, or what?
	. = "s"

/datum/proc/p_es(temp_gender)
	. = "es"

/datum/proc/p_themselves(temp_gender)
	return "itself"

/datum/proc/plural_s(pluralize)
	switch(copytext_char(pluralize, -2))
		if ("ss")
			return "es"
		if ("sh")
			return "es"
		if ("ch")
			return "es"
		else
			switch(copytext_char(pluralize, -1))
				if("s", "x", "z")
					return "es"
				else
					return "s"

//like clients, which do have gender.
//like clients, which do have gender.
/client/p_they(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	switch(temp_gender)
		if(FEMALE)
			return "she"
		if(MALE)
			return "he"
		else
			return "they"

/client/p_their(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	switch(temp_gender)
		if(FEMALE)
			return "her"
		if(MALE)
			return "his"
		else
			return "their"

/client/p_theirs(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	switch(temp_gender)
		if(FEMALE)
			return "hers"
		if(MALE)
			return "his"
		else
			return "theirs"

/client/p_them(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	switch(temp_gender)
		if(FEMALE)
			return "her"
		if(MALE)
			return "him"
		else
			return "them"

/client/p_have(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		return "have"
	return "has"

/client/p_are(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		return "are"
	return "is"

/client/p_were(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		return "were"
	return "was"

/client/p_do(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender == PLURAL || temp_gender == NEUTER)
		return "do"
	return "does"

/client/p_s(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender != PLURAL && temp_gender != NEUTER)
		return "s"

/client/p_es(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender != PLURAL && temp_gender != NEUTER)
		return "es"

/client/p_themselves(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	switch(temp_gender)
		if(FEMALE)
			return "herself"
		if(MALE)
			return "himself"
		if(PLURAL)
			return "themselves"
		else
			return "itself"

//mobs(and atoms but atoms don't really matter write your own proc overrides) also have gender!
/mob/p_they(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	switch(temp_gender)
		if(FEMALE)
			return "she"
		if(MALE)
			return "he"
		if(PLURAL)
			return "they"
		else
			return "it"

/mob/p_their(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	switch(temp_gender)
		if(FEMALE)
			return "her"
		if(MALE)
			return "his"
		if(PLURAL)
			return "their"
		else
			return "its"

/mob/p_theirs(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	switch(temp_gender)
		if(FEMALE)
			return "hers"
		if(MALE)
			return "his"
		if(PLURAL)
			return "theirs"
		else
			return "its"

/mob/p_them(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	switch(temp_gender)
		if(FEMALE)
			return "her"
		if(MALE)
			return "him"
		if(PLURAL)
			return "them"
		else
			return "it"

/mob/p_have(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "has"
	if(temp_gender == PLURAL)
		. = "have"

/mob/p_are(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "is"
	if(temp_gender == PLURAL)
		. = "are"

/mob/p_were(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "was"
	if(temp_gender == PLURAL)
		. = "were"

/mob/p_do(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "does"
	if(temp_gender == PLURAL)
		. = "do"

/mob/p_s(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender != PLURAL)
		. = "s"

/mob/p_es(temp_gender)
	if(!temp_gender)
		temp_gender = gender
	if(temp_gender != PLURAL)
		. = "es"

//humans need special handling, because they can have their gender hidden
/mob/living/carbon/human/p_they(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_their(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_them(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_have(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_are(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_were(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_do(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_s(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()

/mob/living/carbon/human/p_es(temp_gender)
	var/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if((obscured & ITEM_SLOT_ICLOTHING) && skipface)
		temp_gender = PLURAL
	return ..()
