/obj/item/xenoartifact_labeler
    name = "Xenoartifact Labeler"
    icon = 'austation/icons/obj/xenoartifact/xenoartifact_tech.dmi'
    icon_state = "xenoartifact_labeler"
    desc = "A tool scientists use to label their alien bombs."
    throw_speed = 3
    throw_range = 5
    w_class = WEIGHT_CLASS_TINY

    var/list/activator = list(null) //Checked trait
    var/list/activator_traits = list() //Display names

    var/list/minor_trait = list(null, null, null)
    var/list/minor_traits = list()

    var/list/major_trait = list(null)
    var/list/major_traits = list()

    var/list/malfunction = list(null)
    var/list/malfunction_list = list()  

    var/list/info_list = list() //trait dialogue essentially

    var/sticker_name //Name artifacts something pretty
    var/list/sticker_traits = list()//passed down to sticker

/obj/item/xenoartifact_labeler/Initialize()
    . = ..()
    get_trait_list_desc(activator_traits, /datum/xenoartifact_trait/activator) //I forgot why this is alone here. Once again, I'd rather not change shit now.

/obj/item/xenoartifact_labeler/interact(mob/user)
    //ui_interact(user, "XenoartifactLabeler")
    ..()

/obj/item/xenoartifact_labeler/ui_interact(mob/user, datum/tgui/ui)
    ui = SStgui.try_update_ui(user, src, ui)
    if(!ui)
        ui = new(user, src, "XenoartifactLabeler")
        ui.open()

/obj/item/xenoartifact_labeler/ui_data(mob/user)
    var/list/data = list()
    data["activator"] = activator
    data["activator_traits"] = get_trait_list_desc(activator_traits, /datum/xenoartifact_trait/activator)

    data["minor_trait"] = minor_trait
    data["minor_traits"] = get_trait_list_desc(minor_traits, /datum/xenoartifact_trait/minor)

    data["major_trait"] = major_trait
    data["major_traits"] = get_trait_list_desc(major_traits, /datum/xenoartifact_trait/major)

    data["malfunction"] = malfunction
    data["malfunction_list"] = get_trait_list_desc(malfunction_list, /datum/xenoartifact_trait/malfunction)

    data["info_list"] = info_list

    return data

/obj/item/xenoartifact_labeler/ui_act(action, params)
    if(..())
        return

    if(action == "print_traits")
        create_label(sticker_name)

    if(action == "change_print_name")
        sticker_name = params["name"]

    trait_toggle(action, "activator", activator_traits, activator)
    trait_toggle(action, "minor", minor_traits, minor_trait)
    trait_toggle(action, "major", major_traits, major_trait)
    trait_toggle(action, "malfunction", malfunction_list, malfunction)

    . = TRUE
    update_icon()

/obj/item/xenoartifact_labeler/proc/get_trait_list_desc(list/traits, trait_type)//Get a list of all the specified trait types names, actually
    for(var/T in typesof(trait_type))
        var/datum/xenoartifact_trait/X = new T
        if(X.desc && !(X.desc in traits) && !(X.label_name))
            traits += list(X.desc)
        else if(X.label_name && !(X.label_name in traits)) //For cases where the trait doesn't have a desc or is tool cool to use one
            traits += list(X.label_name)
    return traits

/obj/item/xenoartifact_labeler/proc/look_for(list/place, culprit) //This isn't really needed but, It's easier to use as a function. What does this even do?
    for(var/X in place)
        if(X == culprit)
            return TRUE
    return FALSE

/obj/item/xenoartifact_labeler/afterattack(atom/target, mob/user)
    ..()
    var/obj/item/xenoartifact_label/P = create_label(sticker_name)
    if(!P.afterattack(target, user)) //In the circumstance the sticker fails, usually means you're doing something you shouldn't be
        qdel(P)

/obj/item/xenoartifact_labeler/proc/create_label(new_name)
    var/obj/item/xenoartifact_label/P = new(get_turf(src))
    if(new_name)
        P.name = new_name
        P.set_name = TRUE
    P.trait_list = sticker_traits
    P.info = activator+minor_trait+major_trait
    return P

/obj/item/xenoartifact_labeler/proc/trait_toggle(action, toggle_type, var/list/trait_list, var/list/active_trait_list)
    var/datum/xenoartifact_trait/description_holder
    var/new_trait
    for(var/T in trait_list)
        new_trait = desc2datum(T)
        description_holder = new new_trait
        if(action == "assign_[toggle_type]_[T]")
            if(!look_for(active_trait_list, T))
                active_trait_list += list(T)
                info_list += description_holder.label_desc
                sticker_traits += new_trait
            else
                active_trait_list -= list(T)
                info_list -= description_holder.label_desc
                sticker_traits -= new_trait

/obj/item/xenoartifact_labeler/proc/desc2datum(udesc) //This is just a hacky way of getting the info from a datum using its desc becuase I wrote this last and it's not heartbreaking
    for(var/T in typesof(/datum/xenoartifact_trait))
        var/datum/xenoartifact_trait/X = new T
        if((udesc == X.desc)||(udesc == X.label_name))
            return T
    return "[udesc]: There's no known information on [udesc]!."

// Not to be confused with labeler
/obj/item/xenoartifact_label
    icon = 'austation/icons/obj/xenoartifact/xenoartifact_sticker.dmi'
    icon_state = "sticker_star"
    name = "Xenoartifact Label"
    desc = "An adhesive label describing the characteristics of a Xenoartifact."
    var/info = "" 
    var/set_name = FALSE

    var/mutable_appearance/sticker_overlay

    var/list/trait_list = list() //List of traits used to compare and generate modifier.

/obj/item/xenoartifact_label/Initialize()
    icon_state = "sticker_[pick("star", "box", "tri", "round")]"
    var/sticker_state = "[icon_state]_small"
    sticker_overlay = mutable_appearance(icon, sticker_state)
    sticker_overlay.layer = FLOAT_LAYER
    sticker_overlay.appearance_flags = RESET_ALPHA
    sticker_overlay.appearance_flags = RESET_COLOR
    ..()
    
/obj/item/xenoartifact_label/afterattack(atom/target, mob/user)
    for(var/obj/item/xenoartifact_label/L in target.contents)
        target.name = name //You can update the name but, you should only really get one chance to slueth the traits
        return FALSE
    if(istype(target, /mob/living))
        to_chat(target, "<span class='notice'>[user] sticks a [src] to you.</span>")
        add_sticker(target)
        addtimer(CALLBACK(src, .proc/remove_sticker, target), 15 SECONDS)
        return TRUE
    else if(istype(target, /obj/item/xenoartifact)||istype(target, /obj/structure/xenoartifact))
        var/obj/item/xenoartifact/X = target
        calculate_modifier(X)
        add_sticker(X)
        if(set_name)
            X.name = name
        if(info)
            var/textinfo = list2text(info)
            X.desc = "[X.desc] There's a sticker attached, it says-\n[textinfo]"
        return TRUE
    
/obj/item/xenoartifact_label/proc/add_sticker(mob/target)
    target.add_overlay(sticker_overlay)
    forceMove(target)

/obj/item/xenoartifact_label/proc/remove_sticker(mob/target) //Peels off
    target.cut_overlay(sticker_overlay)
    forceMove(get_turf(target))

/obj/item/xenoartifact_label/proc/calculate_modifier(obj/item/xenoartifact/X) //Modifier based off preformance of slueth. To:Do revisit this, complexity would be nice
    var/datum/xenoartifact_trait/trait
    var/datum/component/xenoartifact_pricing/xenop = X.GetComponent(/datum/component/xenoartifact_pricing)
    if(!xenop)
        return
    for(var/T in trait_list)
        trait = new T
        if(X.get_trait(trait))
            xenop.modifier += 0.15 
        else
            xenop.modifier -= 0.35

/obj/item/xenoartifact_label/proc/list2text(list/listo) //list2params acting weird. Probably already a function for this.
    var/text = ""
    for(var/X in listo)
        if(X)
            text = "[text] [X]\n"
    return text

/obj/item/xenoartifact_labeler/debug
    name = "Xenoartifact Debug Labeler"      
    desc = "Use to create specific Xenoartifacts" 

/obj/item/xenoartifact_labeler/debug/afterattack(atom/target, mob/user)
    return

/obj/item/xenoartifact_labeler/debug/create_label(new_name)
    var/obj/item/xenoartifact/A = new(get_turf(src.loc), DEBUGIUM)
    say("Created [A] at [A.loc]")
    A.charge_req = 100
    A.malfunction_mod = 0
    A.malfunction_chance = 0
    var/C = 1
    for(var/X in sticker_traits)
        say(X)
        A.traits[C] = new X
        A.traits[C].on_init(A)
        C = C + 1
