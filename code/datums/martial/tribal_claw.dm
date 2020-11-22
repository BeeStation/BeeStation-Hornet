#define BACK_KICK_COMBO "DGH" //tail knockdown idk
#define STOMACH_KNEE_COMBO "HD" //confusion

/datum/martial_art/tribal_claw
    name = "Tribal Claw"
    id = MARTIALART_TRIBALCLAW
    help_verb = /mob/living/carbon/human/proc/tribal_claw_help

/datum/martial_art/tribal_claw/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
    if(findtext(streak,BACK_KICK_COMBO))
        streak = ""
        backKick(A,D)
        return 1 
    if(findtext(streak,STOMACH_KNEE_COMBO))
        streak = ""
        kneeStomach(A,D)
        return 1
    return 0

/datum/martial_art/tribal_claw/proc/backKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsParalyzed())
		log_combat(A, D, "back_kicked (Tribal Claw)")
        A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
        D.visible_message("<span class='warning'>[A] kicks [D] in the back!</span>", \
							"<span class='userdanger'>[A] kicks you in the back, making you stumble and fall!</span>")
        D.Paralyze(20)
	return basic_hit(A,D)

 /datum/martial_art/tribal_claw/proc/kneeStomach(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!D.stat && !D.IsParalyzed())
		log_combat(A, D, "stomach kneed (Sleeping Carp)")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		D.visible_message("<span class='warning'>[A] knees [D] in the stomach!</span>", \
						  "<span class='userdanger'>[A] winds you with a knee in the stomach!</span>")
		D.audible_message("<b>[D]</b> gags!")
		D.losebreath += 3
		D.Stun(40)
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 50, 1, -1)
		return 1
	return basic_hit(A,D)   
