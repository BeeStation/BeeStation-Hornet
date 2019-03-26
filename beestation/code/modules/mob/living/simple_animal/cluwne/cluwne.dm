/mob/living/simple_animal/cluwne
    name = "The Cluwne"
    real_name = "The Cluwne"
    desc = "A barely-human monstrosity that pissed off the gods."
    friendly = "bops"
    turns_per_move = 10
    icon = 'beestation/icons/mob/animal.dmi'
    icon_state = "cluwne"
    icon_living = "cluwne"
    icon_dead = "cluwne_dead"
    speak_emote = "sadly honks"
    attack_sound = 'sound/items/bikehorn.ogg'
    loot = list(/obj/effect/decal/cleanable/blood/gibs)
    atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
    minbodytemp = 0
    maxbodytemp = 1500
    maxHealth = 150
    health = 150
    speak = list("HONK! HONK! HONK! HONK!","AAAAAAAAAAAAAAAAAA!!", "KILLMEKILLME!!", "HONK HENK HONK!!")

/mob/living/simple_animal/cluwne/New()
    . = ..()
    playsound(src, 'beestation/sound/misc/honk_echo_distant.ogg', 90, 2) // loud
    var/msg = "Your mind is ripped apart like threads in fabric, everything you've ever known is gone.\n"
    msg += "There is only the <b><i>Honkmother</i></b> now.\n"
    msg += "Honk!\n"
    to_chat(src, msg)

/mob/living/simple_animal/cluwne/emote(act, m_type=1, message = null, intentional = FALSE)
    if(intentional)
        message = "makes a sad honk." //ugly hack to stop animals screaming when crushed :P
        act = "me"
    ..()

/mob/living/simple_animal/cluwne/IsVocal()
    return FALSE