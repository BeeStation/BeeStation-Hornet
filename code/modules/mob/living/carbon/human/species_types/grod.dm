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
	mutant_brain = /obj/item/organ/brain/grod
	default_features = list("mcolor" = "#0F0", "grod_crown" = "Crown")
	offset_features = list(OFFSET_LEFT_HAND = list(-1,-4), OFFSET_RIGHT_HAND = list(2,-4))
	changesource_flags = MIRROR_BADMIN | MIRROR_MAGIC | RACE_SWAP
	can_be_defib = FALSE

	stance = STANCE_MOBILE
	var/datum/action/innate/grod/swap_stance/swap_stance
	var/datum/action/innate/grod/crownspider/crownspider

/datum/species/grod/on_species_gain(mob/living/carbon/C)
	. = ..()
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!swap_stance)
			swap_stance = new
			swap_stance.Grant(C)
		if(!crownspider)
			crownspider = new
			crownspider.Grant(C)
		if(!("grod_crown" in H.dna.features)) //TEMPORARY UNTIL BRAIN IS IMPLEMENTED
			H.dna.features["grod_crown"] = H.dna.species.default_features["grod_crown"]

/datum/species/grod/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	if(swap_stance)
		swap_stance.Remove()
	if(crownspider)
		crownspider.Remove()
	//C.stop_listening_for_dir_update()

/datum/action/innate/grod/swap_stance
	name = "Swap Stance"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "drone_vision"

/datum/action/innate/grod/swap_stance/Activate()
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

/datum/action/innate/grod/crownspider
	name = "Detach Crown"
	desc = "Detach your crown from your current body. This should only be done in dire circumstances!"

/datum/action/innate/grod/crownspider/Activate()
	if(!isgrod(owner)) //Stop trying to break shit
		return
	var/mob/living/carbon/human/H = owner
	if(!istype(H.getorganslot(ORGAN_SLOT_BRAIN), /obj/item/organ/brain/grod))
		to_chat(H, "<span class = 'warning'>You dont have a crown! Contact a coder!</span>")
		return
	if(H.incapacitated())
		to_chat(H, "<span class='warning'>You cannot use this ability right now</span>")
		return

	if(alert("Are you sure you wish to leave your current body?",,"Yes", "No") == "No")
		return

	var/datum/mind/M = H.mind
	var/list/organs = H.getorganszone(BODY_ZONE_HEAD, 1)
	var/turf = get_turf(H)

	for(var/obj/item/organ/I in organs)
		I.Remove(H, 1)

	var/mob/living/simple_animal/hostile/crown_spider/crown = new(turf)
	for(var/obj/item/organ/I in organs)
		I.forceMove(crown)
	crown.origin = M
	if(crown.origin)
		crown.origin.active = 1
		crown.origin.transfer_to(crown)
		to_chat(crown, "<span class='warning'>Your consiousness returns to its Crown and you leave your body!</span>")


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

/datum/species/grod/get_custom_icons(part)
	return // placeholder




///////Grod Crown////////
/mob/living/simple_animal/hostile/crown_spider
	name = "Placeholder"
	desc = "Placeholder"
	icon = 'icons/mob/species/grod/crown_spider.dmi'
	icon_state = "crown_spider"
	icon_living = "crown_spider"
	icon_dead = "crown_spider"
	gender = NEUTER
	health = 30
	maxHealth = 30
	melee_damage = 0
	attacktext = "pinches"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("squeaks")
	ventcrawler = VENTCRAWLER_NONE
	color = "#00FF00"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	head_icon = 'icons/mob/species/grod/crown_spider_worn.dmi'
	held_state = "crown_spider"
	var/datum/mind/origin

/mob/living/simple_animal/hostile/crown_spider/AttackingTarget()
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/C = target
		if(C.getorganslot(ORGAN_SLOT_BRAIN))
			to_chat(src, "<span class='userdanger'>A foreign presence repels you from this body. Perhaps you should try to infest another?</span>")
			return
		Infect(target)

/mob/living/simple_animal/hostile/crown_spider/MouseDrop(/mob/living/carbon/target)
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/C = target
		if(C.getorganslot(ORGAN_SLOT_BRAIN))
			to_chat(src, "<span class='userdanger'>A foreign presence repels us from this body. Perhaps we should try to infest another?</span>")
			return
		Infect(target)

/mob/living/simple_animal/hostile/crown_spider/proc/Infect(mob/living/carbon/C)
	if(!origin)
		return
	for(var/obj/item/organ/I in src)
		I.Insert(C, 1)


	origin.transfer_to(C)
	C.key = origin.key
	qdel(src)


//var/datum/action/innate/grod/form_change/form_change

/*/datum/action/innate/grod/form_change
	name = "Form Change"
	desc = "PLACEHOLDER"

/datum/action/innate/grod/form_change/Activate()
	var/mob/living/simple_animal/hostile/crown_spider/L = owner
	for(var/obj/item/organ/I in L)
		if(istype(I, /obj/item/organ/brain/grod))
			var/obj/item/organ/brain/grod/B = I
			if(L.origin)
				L.origin.transfer_to(L)
				L.mind.transfer_to(L)
				B.transfer_identity(L)
			I.forceMove(get_turf(L))*/

