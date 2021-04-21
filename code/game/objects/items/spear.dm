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
	throwforce = 20
	throw_speed = 4
	embedding = list("impact_pain_mult" = 3)
	armour_penetration = 10
	custom_materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	sharpness = IS_SHARP
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 30)
	var/war_cry = "AAAAARGH!!!"
	var/icon_prefix = "spearglass"

/obj/item/spear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/butchering, 100, 70) //decent in a pinch, but pretty bad.
	AddComponent(/datum/component/jousting)
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=18, icon_wielded="[icon_prefix]1")

/obj/item/spear/update_icon_state()
	icon_state = "[icon_prefix]0"

/obj/item/spear/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/obj/item/spear/CheckParts(list/parts_list)
	var/obj/item/shard/tip = locate() in parts_list
	if (istype(tip, /obj/item/shard/plasma))
		throwforce = 21
		icon_prefix = "spearplasma"
		AddComponent(/datum/component/two_handed, force_unwielded=11, force_wielded=19, icon_wielded="[icon_prefix]1")
	update_icon()
	qdel(tip)
	..()

/obj/item/spear/explosive
	name = "explosive lance"
	var/obj/item/grenade/explosive = null
	var/wielded = FALSE // track wielded status on item

/obj/item/spear/explosive/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)
	set_explosive(new /obj/item/grenade/iedcasing()) //For admin-spawned explosive lances

/obj/item/spear/explosive/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=18, icon_wielded="spearbomb1")

/// triggered on wield of two handed item
/obj/item/spear/explosive/proc/on_wield(obj/item/source, mob/user)
	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/spear/explosive/proc/on_unwield(obj/item/source, mob/user)
	wielded = FALSE

/obj/item/spear/explosive/update_icon_state()
	icon_state = "spearbomb0"

/obj/item/spear/explosive/proc/set_explosive(obj/item/grenade/G)
	if(explosive)
		QDEL_NULL(explosive)
	G.forceMove(src)
	explosive = G
	desc = "A makeshift spear with [G] attached to it"

/obj/item/spear/explosive/CheckParts(list/parts_list)
	var/obj/item/grenade/G = locate() in parts_list
	if(G)
		var/obj/item/spear/lancePart = locate() in parts_list
		var/datum/component/two_handed/comp_twohand = lancePart.GetComponent(/datum/component/two_handed)
		if(comp_twohand)
			var/lance_wielded = comp_twohand.force_wielded
			var/lance_unwielded = comp_twohand.force_unwielded
			AddComponent(/datum/component/two_handed, force_unwielded=lance_unwielded, force_wielded=lance_wielded)
		throwforce = lancePart.throwforce
		icon_prefix = lancePart.icon_prefix
		parts_list -= G
		parts_list -= lancePart
		set_explosive(G)
		qdel(lancePart)
	..()

/obj/item/spear/explosive/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.say("[war_cry]", forced="spear warcry")
	explosive.forceMove(user)
	explosive.prime()
	user.gib()
	qdel(src)
	return BRUTELOSS

/obj/item/spear/explosive/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to set your war cry.</span>"

/obj/item/spear/explosive/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		..()
		if(istype(user) && loc == user)
			var/input = stripped_input(user,"What do you want your war cry to be? You will shout it when you hit someone in melee.", ,"", 50)
			if(input)
				src.war_cry = input

/obj/item/spear/explosive/afterattack(atom/movable/AM, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(wielded)
		user.say("[war_cry]", forced="spear warcry")
		explosive.forceMove(AM)
		explosive.prime()
		qdel(src)

//GREY TIDE
/obj/item/spear/grey_tide
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Nanotrasen military forces."
	attack_verb = list("gored")
	force=15

/obj/item/spear/grey_tide/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=15, force_wielded=25, icon_wielded="[icon_prefix]1")

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
	icon_state = "bone_spear0"
	name = "bone spear"
	desc = "A haphazardly-constructed yet still deadly weapon. The pinnacle of modern technology."
	force = 12
	throwforce = 22
	armour_penetration = 15				//Enhanced armor piercing

/obj/item/spear/bonespear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=12, force_wielded=20, icon_wielded="bone_spear1")

/obj/item/spear/bonespear/update_icon_state()
	icon_state = "bone_spear0"
