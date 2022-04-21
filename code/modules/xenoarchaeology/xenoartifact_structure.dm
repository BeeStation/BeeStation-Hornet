/*
    Pretty much a duplicate of the regular item.
    Look at the item for comment documentation, most of the comments here are just artifacts from the copy paste
    Use this file to house the weird off-shoot artifacts. 
*/

/obj/structure/xenoartifact //Most of these values are given to the structure when the structure initializes
    name = "Xenoartifact"
    icon = 'austation/icons/obj/xenoartifact/xenoartifact.dmi'
    icon_state = "map_editor"
    density = TRUE
    
    var/charge = 0 //How much input the artifact is getting from activator traits
    var/charge_req //This isn't a requirement anymore. This just affects how effective the charge is

    var/material //Associated traits & colour
    var/datum/xenoartifact_trait/traits[6] //activation trait, minor 1, minor 2, minor 3, major, malfunction
    var/datum/xenoartifact_trait/touch_desc
    var/special_desc = "The Xenoartifact is made from a" //used for special examine circumstance, science goggles
    var/process_type = ""
    var/code //Used for signaler trait
    var/frequency
    var/datum/radio_frequency/radio_connection
    var/min_desc //Just a holder for examine special_desc from minor traits

    var/max_range = 1
    var/list/true_target = list()
    var/usedwhen //holder for worldtime
    var/cooldown = 8 SECONDS //Time between uses
    var/cooldownmod = 0 //Extra time traits can add to the cooldown

    var/icon_slots[4]
    var/mutable_appearance/icon_overlay

    var/modifier = 0.70 //Buying and selling related
    var/price //default price gets generated if it isn't set by console. This only happens if the artifact spawns outside of that process. 

    var/malfunction_chance //Everytime the artifact is used this increases. When this is successfully proc'd the artifact gains a malfunction and this is lowered. 
    var/malfunction_mod = 1 //How much the chance can change in a sinlge itteration

/obj/structure/xenoartifact/Initialize(mapload, difficulty)
    . = ..()
    material = difficulty

    for(var/datum/xenoartifact_trait/T in traits)
        if(!istype(T, /datum/xenoartifact_trait/minor/dense))
            T.on_init(src)

    var/holdthisplease = pick(1, 2, 3)
    icon_state = "SB[holdthisplease]"//Base
    generate_icon(icon, "SBL[holdthisplease]", material)
    if(pick(1, 1, 0) || icon_slots[1])//Top
        if(!(icon_slots[1])) //Some traits can set this too, it will be set to a code that looks like 9XX
            icon_slots[1] = pick(1, 2, 3)
        generate_icon(icon, "ST[icon_slots[1]]")
        generate_icon(icon, "STL[icon_slots[1]]", material)
        
        if(pick(1, 1, 0) || icon_slots[2])//Bottom
            if(!(icon_slots[2]))
                icon_slots[2] = pick(1, 2, 3)
            generate_icon(icon, "SBTM[icon_slots[2]]")
            generate_icon(icon, "SBTML[icon_slots[2]]", material)

    if(pick(1, 0) || icon_slots[3])//Left
        if(!(icon_slots[3]))
            icon_slots[3] = pick(1, 2)
        generate_icon(icon, "SL[icon_slots[3]]")
        generate_icon(icon, "SLL[icon_slots[3]]", material)

    if(pick(1, 0) || icon_slots[4])//Right
        if(!(icon_slots[4]))
            icon_slots[4] = pick(1, 2)
        generate_icon(icon, "SR[icon_slots[4]]")
        generate_icon(icon, "SRL[icon_slots[4]]", material)

/obj/structure/xenoartifact/examine(mob/user)
    for(var/obj/item/clothing/glasses/science/S in user.contents)
        to_chat(user, "<span class='notice'>[special_desc]</span>")
    . = ..()

/obj/structure/xenoartifact/attack_hand(mob/user)
    . = ..()
    if(process_type == "lit")
        process_type = ""
        set_light(0)
        return
    if(user.a_intent == INTENT_GRAB)
        if(touch_desc)
            touch_desc.on_touch(src, user)
        return
    if(!(manage_cooldown(TRUE)))
        return
    for(var/datum/xenoartifact_trait/T in traits)
        if(charge += EASY*T.on_impact(src, user))
            true_target += list(process_target(user))
            check_charge(user)

/obj/structure/xenoartifact/attackby(obj/item/I, mob/living/user)
    for(var/datum/xenoartifact_trait/T in traits)
        T.on_item(src, user, I)
    if(!(manage_cooldown(TRUE))||user.a_intent == INTENT_HELP||istype(I, /obj/item/xenoartifact_label)||istype(I, /obj/item/xenoartifact_labeler))
        return
    var/impact_activator
    var/burn_activator
    var/msg = I.ignition_effect(src, user)
    for(var/datum/xenoartifact_trait/T in traits)
        if(charge += NORMAL*T.on_impact(src, user, I.force))
            impact_activator = TRUE
        if(msg)
            if(charge += NORMAL*T.on_burn(src, user, I.heat))
                burn_activator = TRUE   
                return    
    if(impact_activator && !burn_activator)
        true_target += list(process_target(user))
        check_charge(user)
    ..()

/obj/structure/xenoartifact/proc/check_charge(mob/user, charge_mod) //Run traits. User is generally passed to use as a fail-safe.
    if(prob(malfunction_chance))
        var/datum/xenoartifact_trait/T = pick(subtypesof(/datum/xenoartifact_trait/malfunction))
        traits[6] = new T
        malfunction_chance = malfunction_chance*0.2
    else    
        malfunction_chance += malfunction_mod

    for(var/atom/M in true_target)
        if(get_dist(src, M) > max_range)   
            true_target -= M
    charge = charge + charge_mod
    if(manage_cooldown(TRUE))//Execution of traits here
        for(var/datum/xenoartifact_trait/minor/T in traits)
            T.activate(src, user, user)
        charge = (charge+charge_req)/1.9 //Not quite an average. Generally produces slightly higher results.     
        for(var/atom/M in true_target)
            create_beam(M)
            for(var/datum/xenoartifact_trait/malfunction/T in traits)
                T.activate(src, M, user)
            for(var/datum/xenoartifact_trait/major/T in traits)
                T.activate(src, M, user)
            if(!(get_trait(/datum/xenoartifact_trait/minor/aura))) //Quick fix for bug that selects multiple targets for noraisin
                break
        manage_cooldown()   
    charge = 0
    true_target = list(null)

/obj/structure/xenoartifact/proc/manage_cooldown(checking = FALSE)
    if(!usedwhen)
        if(!(checking))
            usedwhen = world.time //Should I be using a different measure here?
        return TRUE
    else if(usedwhen + cooldown + cooldownmod < world.time)
        cooldownmod = 0
        usedwhen = null
        return TRUE
    else 
        return FALSE
    
/obj/structure/xenoartifact/proc/get_proximity(range) //Will I really reuse this?
    for(var/mob/living/M in range(range, get_turf(src)))
        if(M.pulling && isliving(M.pulling))
            M = M.pulling
        return M
    return null

/obj/structure/xenoartifact/proc/get_trait(typepath)
    for(var/datum/xenoartifact_trait/T in traits)
        if(istype(T, typepath))
            return T
    return FALSE

/obj/structure/xenoartifact/proc/generate_icon(var/icn, var/icnst = "", colour) //Add extra icon components
    icon_overlay = mutable_appearance(icn, icnst)
    icon_overlay.layer = FLOAT_LAYER
    icon_overlay.appearance_flags = RESET_ALPHA// Not doing this fucks the alpha
    icon_overlay.alpha = alpha//
    if(colour)
        icon_overlay.color = colour
    src.add_overlay(icon_overlay)

/obj/structure/xenoartifact/proc/process_target(atom/target)
    if(!istype(target, /mob/living))
        return target
    var/mob/living/victim = target
    if(victim.pulling && istype(victim.pulling, /mob/living))
        return victim.pulling
    return victim

/obj/structure/xenoartifact/proc/create_beam(atom/target) //Helps show how the artifact is working. Hint stuff.
    var/datum/beam/xenoa_beam/B = new(src.loc, target, time=1.5 SECONDS, beam_icon='austation/icons/obj/xenoartifact/xenoartifact.dmi', beam_icon_state="xenoa_beam", btype=/obj/effect/ebeam/xenoa_ebeam, col = material)
    INVOKE_ASYNC(B, /datum/beam/xenoa_beam.proc/Start)

/obj/structure/xenoartifact/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_SIGNALER)

/obj/structure/xenoartifact/proc/send_signal(var/datum/signal/signal)
    if(!radio_connection||!signal)
        return
    radio_connection.post_signal(src, signal)

/obj/structure/xenoartifact/receive_signal(datum/signal/signal)
    if(!(manage_cooldown(TRUE)) || !signal || signal.data["code"] != code)
        return
    var/mob/living/M = isliving(signal.source.loc) ? signal.source.loc : null
    audible_message("[icon2html(src, hearers(src))] *beep* *beep* *beep*", null, 3)
    playsound(get_turf(src), 'sound/machines/triple_beep.ogg', ASSEMBLY_BEEP_VOLUME, TRUE)
    for(var/datum/xenoartifact_trait/T in traits)
        if(charge += EASY*T.on_signal(src))
            true_target += list(get_proximity(max_range))
            check_charge(M)

/obj/structure/xenoartifact/process(delta_time)
    switch(process_type)
        if("lit")
            true_target = list(get_proximity(max_range))
            charge = NORMAL*traits[1].on_burn(src) 
            if(manage_cooldown(TRUE) && true_target.len >= 1 && get_proximity(max_range))
                set_light(0)
                visible_message("<span class='danger'>The [name] flicks out.</span>")
                check_charge()
                process_type = ""
                return PROCESS_KILL
        if("tick")
            true_target = list(get_proximity(max_range))
            if(manage_cooldown(TRUE))
                charge += NORMAL*traits[1].on_impact(src) 
            if(manage_cooldown(TRUE))
                visible_message("<span class='notice'>The [name] ticks.</span>")
                check_charge()
                if(prob(13))
                    process_type = ""
            charge = 0 //Don't really need to do this but, I am skeptical
        else    
            return PROCESS_KILL

/obj/structure/xenoartifact/Destroy()
    for(var/mob/living/C in contents) //mobs inside only have a 50/50 chance of surviving a collapse.
        if(pick(FALSE, TRUE))
            C.forceMove(get_turf(loc))
        else
            qdel(C)
    qdel(src)
    ..()
