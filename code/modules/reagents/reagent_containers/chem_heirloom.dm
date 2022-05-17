//Chemist's heirloom

/obj/item/reagent_containers/glass/chem_heirloom
    name = "Hard locked bottle of"
    desc = "A hard locked bottle of"
    volume = 100
    spillable = FALSE
    reagent_flags = NONE
    
/obj/item/reagent_containers/glass/chem_heirloom/Initialize(mapload, vol)
    ..()
    var/datum/reagent/R = get_random_reagent_id()
    name ="[name] [initial(R.name)]"
    reagents.add_reagent(R)

    var/datum/component/heirloom/H = GetComponent(/datum/component/heirloom)
    desc = H ? "The [H.family_name] family's long-cherished wish is to open this bottle and get its chemical outside. Can you make that wish come true?" : "[desc] [R.name]."

/obj/item/reagent_containers/glass/chem_heirloom/afterattack(obj/target, mob/user, proximity)
    return

/obj/item/reagent_containers/glass/chem_heirloom/attackby(obj/item/I, mob/user, params)
    return
