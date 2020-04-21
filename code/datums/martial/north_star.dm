#define STUN_PUNCH "HHHHHHHHHHHH"

/datum/martial_art/north_star
	name = "The North Star"
	id = MARTIALART_NORTHSTAR
	warcry = "AT"
	block_chance = 80 //With throw mode on
	passive_block_chance = 40
	max_streak_length = 12
	var/datum/action/set_war_cry/setwarcry = new/datum/action/set_war_cry()

/datum/martial_art/north_star/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(findtext(streak,STUN_PUNCH))
		streak = ""
		stunPunch(A,D)
		return TRUE
	return FALSE

/datum/martial_art/north_star/teach(mob/living/carbon/human/H, make_temporary=0)
	if(..())
		to_chat(H, "<span class='userdanger'>You know the arts of [name]!</span>")
		to_chat(H, "<span class='danger'>You will now be able to punch and kick at ludicrous speeds!</span>")
		setwarcry.Grant(H)

/datum/martial_art/north_star/on_remove(mob/living/carbon/human/H)
	to_chat(H, "<span class='userdanger'>You suddenly forget the arts of [name]...</span>")
	setwarcry.Remove(H)

/datum/martial_art/north_star/proc/stunPunch(mob/living/carbon/human/A, mob/living/carbon/human/D)
	var/def_check = D.getarmor(BODY_ZONE_HEAD, "melee")
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		log_combat(A, D, "stun punched (North Star)")
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message("<span class='warning'>[A] rapidly punched [D] in the temple!</span>", \
						  "<span class='userdanger'>[A] rapidly punched you in the temple!</span>")
		D.apply_damage(6, A.dna.species.attack_type, BODY_ZONE_HEAD, blocked = def_check)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		D.Knockdown(40)
	return TRUE

/datum/martial_art/north_star/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.changeNext_move(CLICK_CD_RAPID)
	log_combat(A, D, "rapidly punched (North Star)")
	var/def_check = D.getarmor(BODY_ZONE_CHEST, "melee")
	add_to_streak("H",D)
	if(check_streak(A,D))
		return 1
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	A.say(warcry, ignore_spam = TRUE, forced = "north star warcry")
	D.visible_message("<span class='danger'>[A] rapidly punched [D]!</span>", \
					  "<span class='userdanger'>[A] rapidly punched you!</span>")
	D.apply_damage(6, BRUTE, blocked = def_check)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, 1, -1)
	return 1

/datum/action/set_war_cry
	name = "War Cry - Change what you say aloud when you attack unarmed."
	icon_icon = 'icons/obj/clothing/gloves.dmi'
	button_icon_state = "rapid"

/datum/action/set_war_cry/Trigger()
	var/mob/living/carbon/human/H = owner
	var/input = stripped_input(H, "What do you want your battlecry to be? Max length of 6 characters.", ,"", 7)
	if(input)
		H.mind.martial_art.warcry = input 
		to_chat(H, "<span class='notice'>Your new warcry will be [input]</span>")

datum/martial_art/north_star/can_use(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_HULK))
		return FALSE
	return ..()

	// gloves

/obj/item/clothing/gloves/rapid
	name = "Gloves of the North Star"
	desc = "Just looking at these fills you with an urge to beat the shit out of people."
	icon_state = "rapid"
	item_state = "rapid"
	transfer_prints = TRUE
	
/obj/item/clothing/gloves/rapid
	var/datum/martial_art/north_star/style = new

/obj/item/clothing/gloves/rapid/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)

/obj/item/clothing/gloves/rapid/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(SLOT_GLOVES) == src)
		style.remove(H)