#define STANCE_MOBILE 0
#define STANCE_INTERACT 1

/datum/species/grod
	name = "Grod"
	id = SPECIES_GROD
	bodyflag = FLAG_GROD
	sexes = FALSE
	default_color = "#00FF00"
	species_traits = list(AGENDER, NOHUSK, NO_UNDERWEAR, NOEYESPRITES, MUTCOLORS)
	inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	mutant_bodyparts = list("grod_crown")
	default_features = list("mcolor" = "#0F0", "grod_crown" = "Royal")
	offset_features = list(OFFSET_LEFT_HAND = list(-1,-4), OFFSET_RIGHT_HAND = list(2,-4))
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | RACE_SWAP

	stance = STANCE_MOBILE
	var/datum/action/innate/swap_stance/swap_stance

/datum/species/grod/on_species_gain(mob/living/carbon/C)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!swap_stance)
			swap_stance = new
			swap_stance.Grant(C)

		if(!("grod_crown" in H.dna.features)) //TEMPORARY UNTIL BRAIN IS IMPLIMENTED
			H.dna.features["grod_crown"] = "Royal"

/datum/species/grod/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	//C.stop_listening_for_dir_update()

/datum/action/innate/swap_stance
	name = "Swap Stance"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"

/datum/action/innate/swap_stance/Activate()
	if(!isgrod(owner))
		return
	var/mob/living/carbon/human/H = owner
	if(!H.dna.species.stance)
		H.change_number_of_hands(4)
		to_chat(H,"<span class ='warning'>You focus your energy into your additional hands.</span>")
		to_chat(H,"<span class ='warning'>You feel weak and slow.</span>")
		H.dna.species.stance = STANCE_INTERACT
	else
		H.change_number_of_hands(2)
		to_chat(H,"<span class ='warning'>You focus your energy back into your legs.</span>")
		to_chat(H,"<span class ='warning'>The feeling dissipates.</span>")
		H.dna.species.stance = STANCE_MOBILE

/datum/species/grod/get_item_offsets_for_index(var/i)
	switch(i)
		if(3) //odd = left hands
			return list("x" = -1, "y" = 5)
		if(4) //even = right hands
			return list("x" = 1, "y" = 5)
		else
			return

/*/datum/species/grod/get_hand_offsets_for_dir(var/dir, var/hand)
	switch(dir)
*/
