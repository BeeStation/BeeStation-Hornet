#define TAIL_SWEEP_COMBO "DDGH"
#define FACE_SCRATCH_COMBO "HD"
#define JUGULAR_CUT_COMBO "HHG"
#define TAIL_GRAB_COMBO "DHGG"

/datum/martial_art/tribal_claw
    name = "Tribal Claw"
    id = MARTIALART_TRIBALCLAW
    allow_temp_override = FALSE
    help_verb = /mob/living/carbon/human/proc/tribal_claw_help

/datum/martial_art/tribal_claw/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
    if(findtext(streak,TAIL_SWEEP_COMBO))
        streak = ""
        tailSweep(A,D)
        return TRUE
    if(findtext(streak,FACE_SCRATCH_COMBO))
        streak = ""
        faceScratch(A,D)
        return TRUE
    if(findtext(streak,JUGULAR_CUT_COMBO))
        streak = ""
        jugularCut(A,D)
        return TRUE
    if(findtext(streak,TAIL_GRAB_COMBO))
        streak = ""
        tailGrab(A,D)
        return TRUE
    return FALSE

/datum/martial_art/tribal_claw/proc/tailAnimate(mob/living/carbon/human/A)
    set waitfor = FALSE
    for(var/i in GLOB.cardinals)
        if(!A)
            break
        A.setDir(i)

/datum/martial_art/tribal_claw/proc/tailSweep(mob/living/carbon/human/A, mob/living/carbon/human/D)
    log_combat(A, D, "tail sweeped(Tribal Claw)")
    D.visible_message("<span class='warning'>[A] sweeps [D]'s legs with their tail!</span>", \
                        "<span class='userdanger'>[A] sweeps your legs with their tail!</span>")
    tailAnimate(A)
    var/obj/effect/proc_holder/spell/aoe_turf/repulse/spacedragon/R = new
    var/list/turfs = list()
    for(var/turf/T in range(1,A))
        turfs.Add(T)
    R.cast(turfs)
    return

/datum/martial_art/tribal_claw/proc/faceScratch(mob/living/carbon/human/A, mob/living/carbon/human/D)
    var/def_check = D.getarmor(BODY_ZONE_HEAD, "melee")
    log_combat(A, D, "face scratched (Tribal Claw)")
    D.visible_message("<span class='warning'>[A] scratches [D]'s face with their claws!</span>", \
                        "<span class='userdanger'>[A] scratches your face with their claws!</span>")
    D.confused += 5
    D.blur_eyes(5)
    D.apply_damage(10, BRUTE, BODY_ZONE_HEAD, def_check)
    A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
    playsound(get_turf(D), 'sound/weapons/slash.ogg', 50, 1, -1)
    return

/datum/martial_art/tribal_claw/proc/jugularCut(mob/living/carbon/human/A, mob/living/carbon/human/D)
    var/def_check = D.getarmor(BODY_ZONE_HEAD, "melee")
    if((D.health <= D.crit_threshold || (A.pulling == D && A.grab_state >= GRAB_NECK) || D.IsSleeping()))
        log_combat(A, D, "jugular cut (Tribal Claw)")
        D.visible_message("<span class='warning'>[A] cuts [D]'s jugular vein with their claws!</span>", \
                            "<span class='userdanger'>[A] cuts your jugular vein!</span>")
        D.apply_damage(15, BRUTE, BODY_ZONE_HEAD, def_check)
        D.bleed_rate = CLAMP(D.bleed_rate + 20, 0, 30)
        D.apply_status_effect(/datum/status_effect/neck_slice)
        A.do_attack_animation(D, ATTACK_EFFECT_CLAW)
        playsound(get_turf(D), 'sound/weapons/slash.ogg', 50, 1, -1)
    else
        return basic_hit(A,D)

/datum/martial_art/tribal_claw/proc/tailGrab(mob/living/carbon/human/A, mob/living/carbon/human/D)
    log_combat(A, D, "tail grabbed (Tribal Claw)")
    D.visible_message("<span class='warning'>[A] grabs [D] with their tail!</span>", \
                        "<span class='userdanger'>[A] grabs you with their tail!</span>")
    D.grabbedby(A, 1)
    D.Knockdown(5)
    A.setGrabState(GRAB_NECK)
    if(D.silent <= 10)
        D.silent = CLAMP(D.silent + 10, 0, 10)
    return

/datum/martial_art/tribal_claw/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
    add_to_streak("H",D)
    if(check_streak(A,D))
        return TRUE
    return FALSE

/datum/martial_art/tribal_claw/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
    add_to_streak("D",D)
    if(check_streak(A,D))
        return TRUE
    return FALSE

/datum/martial_art/tribal_claw/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
    add_to_streak("G",D)
    if(check_streak(A,D))
        return TRUE
    return FALSE

/mob/living/carbon/human/proc/tribal_claw_help()
    set name = "Recall Teachings"
    set desc = "Remember the martial techniques of the Tribal Claw"
    set category = "Tribal Claw"

    to_chat(usr, "<b><i>You retreat inward and recall the teachings of the Tribal Claw...</i></b>")

    to_chat(usr, "<span class='notice'>Tail Sweep</span>: Disarm Disarm Grab Harm. Pushes everyone around you away and knocks them down.")
    to_chat(usr, "<span class='notice'>Face Scratch</span>: Harm Disarm. Damages your target's head and confuses them for a short time.")
    to_chat(usr, "<span class='notice'>Jugular Cut</span>: Harm Harm Grab. Causes your target to rapidly lose blood, works only if you grab your target by their neck, if they are sleeping, or in critical condition.")
    to_chat(usr, "<span class='notice'>Tail Grab</span>: Disarm Harm Grab Grab. Grabs your target by their neck and makes them unable to talk for a short time.")
