#define TAIL_SWEEP_COMBO "DDGH"
#define FACE_SCRATCH_COMBO "HD"
#define TAIL_KNOCKDOWN_COMBO "GDH"

/datum/martial_art/tribal_claw
    name = "Tribal Claw"
    id = MARTIALART_TRIBALCLAW
    help_verb = /mob/living/carbon/human/proc/tribal_claw_help

/datum/martial_art/tribal_claw/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
    if(findtext(streak,TAIL_SWEEP_COMBO))
        streak = ""
        tailSweep(A,D)
        return 1
    if(findtext(streak,FACE_SCRATCH_COMBO))
        streak = ""
        faceScratch(A,D)
        return 1
    if(findtext(streak,TAIL_KNOCKDOWN_COMBO))
        streak = ""
        tailKnockdown(A,D)
        return 1
    return 0

/datum/martial_art/tribal_claw/proc/tailAnimate(mob/living/carbon/human/A)
    set waitfor = FALSE
    for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
        if(!A)
            break
        A.setDir(i)
        

/datum/martial_art/tribal_claw/proc/tailSweep(mob/living/carbon/human/A, mob/living/carbon/human/D)
    A.say("plswork", forced="tribal claw")
    tailAnimate(A)
    var/obj/effect/proc_holder/spell/aoe_turf/repulse/spacedragon/R = new(null)
    var/list/turfs = list()
    for(var/turf/T in range(1,A))
        turfs.Add(T)
    R.cast(turfs)
    log_combat(A, D, "tornado sweeped(Plasma Fist)")
    return 1

/datum/martial_art/tribal_claw/proc/faceScratch(mob/living/carbon/human/A, mob/living/carbon/human/D)
    A.say("plswork", forced="tribal claw")
    log_combat(A, D, "face scratch (Tribal Claw)")
    D.visible_message("<span class='warning'>[A] knees [D] in the stomach!</span>", \
                        "<span class='userdanger'>[A] winds you with a knee in the stomach!</span>")
    D.confused += 5
    D.blur_eyes(10)
    playsound(get_turf(D), 'sound/weapons/slash.ogg', 50, 1, -1)
    return 1 

/datum/martial_art/tribal_claw/proc/tailKnockdown(mob/living/carbon/human/A, mob/living/carbon/human/D)
    A.say("plswork", forced="tribal claw")
    log_combat(A, D, "tail knockdown (Tribal Claw)")
    D.Knockdown(10)
    D.apply_damage(10, BRUTE, pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
    return 1

/datum/martial_art/tribal_claw/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
    add_to_streak("H",D)
    if(check_streak(A,D))
        return 1
    return 0

/datum/martial_art/tribal_claw/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
    add_to_streak("D",D)
    if(check_streak(A,D))
        return 1
    return 0

/datum/martial_art/tribal_claw/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
    add_to_streak("G",D)
    if(check_streak(A,D))
        return 1
    return 0

/mob/living/carbon/human/proc/tribal_claw_help()
    set name = "Recall Teachings"
    set desc = "Remember the martial techniques of the Tribal Claw clan"
    set category = "Tribal Claw"

    to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Tribal Claw...</i></b>")

    to_chat(usr, "<span class='notice'>Tail Sweep</span>: Disarm Disarm Grab Harm. Gonna do something")
    to_chat(usr, "<span class='notice'>Face Scratch</span>: Harm Disarm. Gonna do something else")
    to_chat(usr, "<span class='notice'>Tail Knockdown</span>: Grab Disarm Harm. Gonna do something else")
