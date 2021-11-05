//spears
/obj/item/spear
	icon_state = "spearglass0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	block_upgrade_walk = 1
	throwforce = 20
	throw_speed = 4
	embedding = list("armour_block" = 60)
	armour_penetration = 10
	materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharpness = IS_SHARP
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30, "stamina" = 0)
	var/war_cry = "AAAAARGH!!!"
	var/icon_prefix = "spearglass"

/obj/item/spear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/butchering, 100, 70) //decent in a pinch, but pretty bad.
	AddComponent(/datum/component/jousting)
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=18, block_power_wielded=25, icon_wielded="[icon_prefix]1")

/obj/item/spear/update_icon()
	icon_state = "[icon_prefix]0"
	..()

/obj/item/spear/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/spear/CheckParts(list/parts_list)
	var/obj/item/shard/tip = locate() in parts_list
	if(tip)
		if (istype(tip, /obj/item/shard/plasma))
			throwforce = 21
			icon_prefix = "spearplasma"
			AddComponent(/datum/component/two_handed, force_unwielded=11, force_wielded=19, icon_wielded="[icon_prefix]1")
		update_icon()
		parts_list -= tip
		qdel(tip)
	return ..()

//GREY TIDE
/obj/item/spear/grey_tide
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Nanotrasen military forces."
	attack_verb = list("gored")
	force=15

/obj/item/spear/grey_tide/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=15, force_wielded=25, block_power_wielded=25, icon_wielded="[icon_prefix]1")

/obj/item/spear/grey_tide/afterattack(atom/movable/AM, mob/living/user, proximity)
	. = ..()
	if(!proximity)
		return
	user.faction |= "greytide([REF(user)])"
	if(isliving(AM))
		var/mob/living/L = AM
		if(istype (L, /mob/living/simple_animal/hostile/illusion))
			return
		if(!L.stat && prob(50))
			var/mob/living/simple_animal/hostile/illusion/M = new(user.loc)
			M.faction = user.faction.Copy()
			M.Copy_Parent(user, 100, user.health/2.5, 12, 30)
			M.GiveTarget(L)

/*
 * Bone Spear
 */
/obj/item/spear/bonespear	//Blatant imitation of spear, but made out of bone. Not valid for explosive modification.
	icon_prefix = "bone_spear"
	icon_state = "bone_spear0"
	name = "bone spear"
	desc = "A haphazardly-constructed yet still deadly weapon. The pinnacle of modern technology."
	force = 12
	throwforce = 22
	armour_penetration = 15				//Enhanced armor piercing

/obj/item/spear/bonespear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=12, force_wielded=20, block_power_wielded=25, icon_wielded="[icon_prefix]1")

/obj/item/spear/bamboospear
	icon_prefix = "bamboo_spear"
	icon_state = "bamboo_spear0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "bamboo spear"
	desc = "A haphazardly-constructed bamboo stick with a sharpened tip, ready to poke holes into unsuspecting people."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	block_upgrade_walk = 1
	throwforce = 22
	throw_speed = 4
	embedding = list("armour_block" = 30)
	armour_penetration = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "tore", "gored")
	sharpness = IS_SHARP

/obj/item/spear/bamboospear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=18, \
				block_power_wielded=25, icon_wielded="[icon_prefix]1")
