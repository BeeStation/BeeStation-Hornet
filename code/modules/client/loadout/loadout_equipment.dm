//NEW ITEMS ADDED JUST FOR THIS

/obj/item/storage/box/loadout
    name = "equipment box"
    desc = "A box containing your selected loadout equipment"
    illustration = "writing_syndie"

/obj/item/gun/energy/e_gun/mini/heads/royale
    gun_charge = 300
    desc = "It has two settings: Kill and Disable. It isn't very good at either of them, but recharges over time"

/obj/item/gun/energy/plasmacutter/adv/royale
    dead_cell = FALSE
    gun_charge = 100
    force = 10
    desc = "A mining tool capable of expelling concentrated plasma bursts. Not very strong, but good at removing limbs"

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
    desc = "May your fate be ever in your favor"
    icon = 'icons/obj/dice.dmi'
    icon_state = "dicebag"
    pill_variance = 0

/obj/item/storage/pill_bottle/dicefate/Initialize(mapload)
    if(prob(25))
        if(prob(25))
            new/obj/item/dice/d20/fate/stealth/d4(src)
        else
            new/obj/item/dice/d20/fate/one_use/stealth/d4(src)
    else
        new /obj/item/dice/d4(src)
    if(prob(16))
        if(prob(16))
            new/obj/item/dice/d20/fate/stealth/d6(src)
        else
            new/obj/item/dice/d20/fate/one_use/stealth/d6(src)
    else
        new /obj/item/dice/d6(src)
    if(prob(12))
        if(prob(12))
            new/obj/item/dice/d20/fate/stealth/d8(src)
        else
            new/obj/item/dice/d20/fate/one_use/stealth/d8(src)
    else
        new /obj/item/dice/d8(src)
    
    if(prob(10))
        if(prob(10))
            new/obj/item/dice/d20/fate/stealth/d10(src)
        else
            new/obj/item/dice/d20/fate/one_use/stealth/d10(src)
    else
        new /obj/item/dice/d10(src)

    if(prob(8))
        if(prob(8))
            new/obj/item/dice/d20/fate/stealth/d12(src)
        else
            new/obj/item/dice/d20/fate/one_use/stealth/d12(src)
    else
        new /obj/item/dice/d12(src)

    if(prob(5))
        if(prob(5))
            new/obj/item/dice/d20/fate/stealth(src)
        else
            new/obj/item/dice/d20/fate/one_use/stealth(src)
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

/datum/gear/equipment/ptsd
    display_name = "PTSD"
    path = /obj/item/gun/energy/e_gun/mini/heads/royale

/datum/gear/equipment/plascutter
    display_name = "Plasma Cutter"
    path = /obj/item/gun/energy/plasmacutter/adv/royale


// MELEE WEAPONS


// UTILITY AND MEDICAL SUPPLIES


// JUST FOR FUN

/datum/gear/equipment/fate
    display_name = "Fateful bag of dice"
    description = "May fate be ever in your favor"

/datum/gear/equipment/bananasword
    display_name = "Bananium Energy Sword"
    path = /obj/item/melee/transforming/energy/sword/bananium
    description = "Honk"
