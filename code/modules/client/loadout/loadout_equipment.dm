//NEW ITEMS ADDED JUST FOR THIS

/obj/item/storage/box/loadout
    name = "equipment box"
    desc = "A box containing your selected loadout equipment"
    illustration = "writing_syndie"

/obj/item/storage/box/loadout/explosives/Initialize(mapload)
    new /obj/item/grenade/plastic/x4(src)
    new /obj/item/grenade/plastic/x4(src)
    new /obj/item/grenade/plastic/x4(src)
    new /obj/item/grenade/plastic/x4(src)

/obj/item/gun/energy/e_gun/mini/heads/royale
    gun_charge = 300
    desc = "It has two settings: Kill and Disable. It isn't very good at either of them, but recharges over time"

/obj/item/gun/energy/plasmacutter/adv/royale
    dead_cell = FALSE
    gun_charge = 100
    force = 10
    desc = "A mining tool capable of expelling concentrated plasma bursts. Not very strong, but good at removing limbs"

/obj/item/reagent_containers/spray/flame
    volume = 50
    list_reagents = list(/datum/reagent/clf3 = 50)
    desc = "A spray bottle, with an unscrewable top. This one came filled with chlorine triflouride"

/obj/item/holo/esword/blue/Initialize(mapload)
	. = ..()
	saber_color = "blue"

/obj/item/holo/esword/purple/Initialize(mapload)
	. = ..()
	saber_color = "purple"

/obj/item/claymore/bone/royale
    block_level = 1
    desc = "Jagged pieces of bone are tied to what looks like a goliaths femur. This one has improved blocking capabilities."

/obj/item/shield/energy/royale
    max_integrity = 25
    block_power = 75
    desc = "An advanced hard-light shield able to reflect lasers, but not very good at blocking physical attacks. Recharges in ten seconds."

/obj/item/book/granter/martial/karate/royale
    pages_to_mastery = 0

/obj/item/melee/curator_whip/royale
    force = 5 //this one actually stings
    desc= "Somewhat eccentric and outdated, but this one actually hurts"

/obj/item/storage/firstaid/royale
    name = "compact medical kit"
    desc = "I hope you've got insurance."
    icon_state = "firstaid-combat"
    item_state = "firstaid-combat"
    skin_type = MEDBOT_SKIN_SYNDI
    w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/firstaid/royale/PopulateContents()
    var/static/items_inside = list(
        /obj/item/healthanalyzer = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/bruise_pack = 1,
		/obj/item/stack/medical/ointment = 1,
        /obj/item/storage/pill_bottle/penacid = 1,
        /obj/item/storage/pill_bottle/happy = 1,
		/obj/item/reagent_containers/hypospray/medipen/atropine = 1)
    generate_items_inside(items_inside,src)

/obj/item/syndie_glue/royale
    uses = 3

/obj/item/clothing/suit/hooded/cloak/goliath/royale
    desc = "A tattered cloak made of goliath leather. Offers well-rounded protection without hindering movement but leaves the legs exposed."
    armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60, "stamina" = 30)
    hoodtype = /obj/item/clothing/head/hooded/cloakhood/goliath/royale

/obj/item/clothing/head/hooded/cloakhood/goliath/royale
    armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60, "stamina" = 30)

/obj/item/clothing/suit/armor/reactive/stealth/royale
    name = "reactive stealth armor"
    reactivearmor_cooldown_duration = 20 SECONDS
    desc = "Stealths the wearer for four seconds and projects a hologram which runs away upon taking damage. Twenty second cooldown"

/obj/item/dice/d20/fate/one_use/stealth/d4
    name = "d4"
    desc = "A die with four sides. The nerd's caltrop."
    icon_state = "d4"
    sides = 4

/obj/item/dice/d20/fate/stealth/d4
    name = "d4"
    desc = "A die with four sides. The nerd's caltrop."
    icon_state = "d4"
    sides = 4

/obj/item/dice/d20/fate/one_use/stealth/d6
    name = "d6"
    desc = "A die with six sides. Basic and serviceable."
    icon_state = "d6"
    sides = 6

/obj/item/dice/d20/fate/stealth/d6
    name = "d6"
    desc = "A die with six sides. Basic and serviceable."
    icon_state = "d6"
    sides = 6

/obj/item/dice/d20/fate/one_use/stealth/d8
    name = "d8"
    desc = "A die with eight sides. It feels... lucky."
    icon_state = "d8"
    sides = 8

/obj/item/dice/d20/fate/stealth/d8
    name = "d8"
    desc = "A die with eight sides. It feels... lucky."
    icon_state = "d8"
    sides = 8

/obj/item/dice/d20/fate/one_use/stealth/d10
    name = "d10"
    desc = "A die with ten sides. Useful for percentages."
    icon_state = "d10"
    sides = 10

/obj/item/dice/d20/fate/stealth/d10
    name = "d10"
    desc = "A die with ten sides. Useful for percentages."
    icon_state = "d10"
    sides = 10

/obj/item/dice/d20/fate/one_use/stealth/d12
    name = "d12"
    desc = "A die with twelve sides. There's an air of neglect about it."
    icon_state = "d12"
    sides = 12

/obj/item/dice/d20/fate/stealth/d12
    name = "d12"
    desc = "A die with twelve sides. There's an air of neglect about it."
    icon_state = "d12"
    sides = 12

/obj/item/storage/pill_bottle/dicefate
    name = "bag of dice"
    desc = "May fate be ever in your favor"
    icon = 'icons/obj/dice.dmi'
    icon_state = "dicebag"
    pill_variance = 0

/obj/item/storage/pill_bottle/dicefate/Initialize(mapload)
    if(prob(25))
        if(prob(25))
            new /obj/item/dice/d20/fate/stealth/d4(src)
        else
            new /obj/item/dice/d20/fate/one_use/stealth/d4(src)
    else
        new /obj/item/dice/d4(src)
    if(prob(16))
        if(prob(16))
            new /obj/item/dice/d20/fate/stealth/d6(src)
        else
            new /obj/item/dice/d20/fate/one_use/stealth/d6(src)
    else
        new /obj/item/dice/d6(src)
    if(prob(12))
        if(prob(12))
            new /obj/item/dice/d20/fate/stealth/d8(src)
        else
            new /obj/item/dice/d20/fate/one_use/stealth/d8(src)
    else
        new /obj/item/dice/d8(src)
    
    if(prob(10))
        if(prob(10))
            new /obj/item/dice/d20/fate/stealth/d10(src)
        else
            new /obj/item/dice/d20/fate/one_use/stealth/d10(src)
    else
        new /obj/item/dice/d10(src)

    if(prob(8))
        if(prob(8))
            new /obj/item/dice/d20/fate/stealth/d12(src)
        else
            new /obj/item/dice/d20/fate/one_use/stealth/d12(src)
    else
        new /obj/item/dice/d12(src)

    if(prob(5))
        if(prob(5))
            new /obj/item/dice/d20/fate/stealth(src)
        else
            new /obj/item/dice/d20/fate/one_use/stealth(src)
    else
        new /obj/item/dice/d20(src)

//RANGED WEAPONS

/datum/gear/equipment
    subtype_path = /datum/gear/equipment
    sort_category = "Combat Equipment (pick two)"

/datum/gear/equipment/stechkin
    display_name = "stechkin"
    path = /obj/item/gun/ballistic/automatic/pistol

/datum/gear/equipment/shotgun
    display_name = "makeshift gun"
    path = /obj/item/gun/ballistic/shotgun/doublebarrel/improvised/sawn
    description = "A short tube that kind of aims a shotgun shell. Comes with one round"

/datum/gear/equipment/sprayfire
    display_name = "ghetto flamethrower"
    path = /obj/item/reagent_containers/spray/flame
    description = "Looks like an ordinary spray bottle to me"

/datum/gear/equipment/ptsd
    display_name = "PTSD"
    path = /obj/item/gun/energy/e_gun/mini/heads/royale

/datum/gear/equipment/plascutter
    display_name = "Plasma Cutter"
    path = /obj/item/gun/energy/plasmacutter/adv/royale


// MELEE WEAPONS


/datum/gear/equipment/holosword/blue
    display_name = "blue holo sword"
    path = /obj/item/holo/esword/blue

/datum/gear/equipment/holosword/green
    display_name = "green holo sword"
    path = /obj/item/holo/esword/red

/datum/gear/equipment/holosword/purple
    display_name = "purple holo sword"
    path = /obj/item/holo/esword/green

/datum/gear/equipment/holosword/red
    display_name = "red holo sword"
    path = /obj/item/holo/esword/red

/datum/gear/equipment/holosword/random
    display_name = "random holo sword"
    path = /obj/item/holo/esword

/datum/gear/equipment/bonesword
    display_name = "bone sword"
    path = /obj/item/claymore/bone/royale

/datum/gear/equipment/spear
    display_name = "metal spear"
    path = /obj/item/spear

/datum/gear/equipment/spear/bone
    display_name = "bone spear"
    path = /obj/item/spear/bonespear

/datum/gear/equipment/spear/bamboo
    display_name = "bamboo spear"
    path = /obj/item/spear/bamboospear

/datum/gear/equipment/eshield
    display_name = "energy shield"
    path = /obj/item/shield/energy/royale

/datum/gear/equipment/romanshield
    display_name = "roman shield"
    path = /obj/item/shield/riot/roman

/datum/gear/equipment/riotshield
    display_name = "riot shield"
    path = /obj/item/shield/riot/tele
    description = "A sturdy lightweight shield that collapses for easy storage, but is unable to block lasers"

/datum/gear/equipment/whip
    display_name = "whip"
    path = /obj/item/melee/curator_whip/royale

/datum/gear/equipment/mop
    display_name = "advanced mop"
    path = /obj/item/mop/advanced
    description = "Just think of all the viscera you will clean up with this! Produces its own water."

/datum/gear/equipment/karate
    display_name = "karate scroll"
    path = /obj/item/book/granter/martial/karate/royale

// UTILITY AND CONSUMABLES

/datum/gear/equipment/explosives
    display_name = "box of explosives"
    path = /obj/item/storage/box/loadout/explosives
    description = "Contains multiple X4 to use in creative ways"

/datum/gear/equipment/bluespace
    display_name = "bluespace crystals"
    path = /obj/item/stack/ore/bluespace_crystal/ten
    description = "Ten bluespace crystals to teleport yourself or people you throw them at somewhere else"

/datum/gear/equipment/cables
    display_name = "cables"
    path = /obj/item/stack/cable_coil

/datum/gear/equipment/implant/adrenal
    display_name = "adrenaline implant"
    path = /obj/item/implanter/adrenalin
    description = "Three bursts of adrenaline for extra speed, stun resistance and a little healing"

/datum/gear/equipment/implant/emp
    display_name = "emp implant"
    path = /obj/item/implanter/emp
    description = "Three EMP bursts to drain energy weapons and cause equipment malfunctions"

/datum/gear/equipment/implant/explosive
    display_name = "explosive implant"
    path = /obj/item/implanter/explosive
    description = "Go out with a bang and take most of your stuff with you to the grave. Go on, have the last laugh."

/datum/gear/equipment/soap
    display_name = "a bar of soap"
    path = /obj/item/soap

//MEDICAL ITEMS

/datum/gear/equipment/medkit
    display_name = "compact medkit"
    path = /obj/item/storage/firstaid/royale

/datum/gear/equipment/survival
    display_name = "survival medipen"
    path = /obj/item/reagent_containers/hypospray/medipen/survival
    description = "A medipen for surviving in the harshest of environments, heals and protects from environmental hazards."

//ARMOR

/datum/gear/equipment/armor
    slot = ITEM_SLOT_OCLOTHING

/datum/gear/equipment/armor/cloak
    display_name = "goliath cloak"
    path = /obj/item/clothing/suit/hooded/cloak/goliath/royale

/datum/gear/equipment/armor/stealth
    display_name = "reactive stealth armor"
    path = /obj/item/clothing/suit/armor/reactive/stealth/royale



// JUST FOR FUN
/datum/gear/equipment/syndicards
    display_name = "syndicate playing cards"
    path = /obj/item/toy/cards/deck/syndicate

/datum/gear/equipment/glue
    display_name = "bottle of super glue"
    path = /obj/item/syndie_glue/royale
    description = "A black market brand of high strength adhesive, rarely sold to the public. This bottle contains three applications, use them well."

/datum/gear/equipment/fate
    display_name = "fateful bag of dice"
    path = /obj/item/storage/pill_bottle/dicefate
    cost = 3000

/datum/gear/equipment/skub
    display_name = "skub"
    path = /obj/item/skub
    cost = 3000

/datum/gear/equipment/bananasword
    display_name = "bananium energy sword"
    path = /obj/item/melee/transforming/energy/sword/bananium
    description = "Honk"
    cost = 5000
