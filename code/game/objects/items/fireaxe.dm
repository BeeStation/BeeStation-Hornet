/*
 * Fireaxe
 */
/obj/item/fireaxe  // DEM AXES MAN, marker -Agouri
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	icon_state = "fireaxe0"
	base_icon_state = "fireaxe"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	attack_weight = 3
	force = 5
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("attacks", "chops", "cleaves", "tears", "lacerates", "cuts")
	attack_verb_simple = list("attack", "chop", "cleave", "tear", "lacerate", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT
	max_integrity = 200
	armor_type = /datum/armor/item_fireaxe
	resistance_flags = FIRE_PROOF
	item_flags = ISWEAPON

	var/force_wielded = 24
	var/force_unwielded = 5
	var/block_power_wielded = 25

/datum/armor/item_fireaxe
	fire = 100
	acid = 30

/obj/item/fireaxe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 100, 80, 0 , hitsound) //axes are not known for being precision butchering tools
	AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, block_power_wielded=block_power_wielded, icon_wielded="[base_icon_state]1")

/obj/item/fireaxe/update_icon()
	icon_state = "[base_icon_state]0"
	..()

/obj/item/fireaxe/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] axes [user.p_them()]self from head to toe! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/fireaxe/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(ISWIELDED(src)) //destroys windows, and grilles in one hit
		if(istype(A, /obj/structure/window))
			var/obj/structure/window/W = A
			W.take_damage(200, BRUTE, MELEE, 0)
		else if(istype(A, /obj/machinery/door/window) || istype(A, /obj/structure/windoor_assembly)\
				|| istype(A, /obj/structure/table/glass))
			var/obj/WD = A
			WD.take_damage(80, BRUTE, MELEE, 0) //Destroy glass tables in one hit, windoors in two hits.
		else if(istype(A, /obj/structure/grille))
			var/obj/structure/grille/G = A
			G.take_damage(40, BRUTE, MELEE, 0)

/*
 * Bone Axe
 */
/obj/item/fireaxe/boneaxe  // Blatant imitation of the fireaxe, but made out of bone.
	name = "bone axe"
	desc = "A large, vicious axe crafted out of several sharpened bone plates and crudely tied together. Made of monsters, by killing monsters, for killing monsters."
	base_icon_state = "bone_axe"
	icon_state = "bone_axe0"
	force_wielded = 23
	block_power_wielded = 0
