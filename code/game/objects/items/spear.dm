//spears
/obj/item/spear
	icon_state = "spearglass0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	item_flags = ISWEAPON
	slot_flags = ITEM_SLOT_BACK
	block_upgrade_walk = TRUE
	throwforce = 20
	throw_speed = 4
	embedding = list("armour_block" = 60, "max_damage_mult" = 0.5)
	armour_penetration = 10
	custom_materials = list(/datum/material/iron=1150, /datum/material/glass=2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "lacerate", "gore")
	sharpness = SHARP
	bleed_force = BLEED_CUT
	max_integrity = 200
	armor_type = /datum/armor/item_spear
	var/war_cry = "AAAAARGH!!!"
	var/icon_prefix = "spearglass"


/datum/armor/item_spear
	fire = 50
	acid = 30

/obj/item/spear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/butchering, 100, 70) //decent in a pinch, but pretty bad.
	AddComponent(/datum/component/jousting)
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=18, block_power_wielded=25, icon_wielded="[icon_prefix]1")

/obj/item/spear/update_icon()
	icon_state = "[icon_prefix]0"
	..()

/obj/item/spear/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
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
	var/obj/item/grenade/G = locate() in parts_list
	if(G)
		var/obj/item/spear/explosive/lance = new /obj/item/spear/explosive(src.loc, G)
		lance.TakeComponent(GetComponent(/datum/component/two_handed))
		lance.throwforce = throwforce
		lance.icon_prefix = icon_prefix
		parts_list -= G
		qdel(src)
	return ..()

/obj/item/spear/explosive
	name = "explosive lance"
	icon_prefix = "spearbomb"
	icon_state = "spearbomb0"
	var/obj/item/grenade/explosive = null

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/spear/explosive)

/obj/item/spear/explosive/Initialize(mapload, obj/item/grenade/G)
	. = ..()
	set_explosive(G)

/obj/item/spear/explosive/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.say("[war_cry]", forced="spear warcry")
	explosive.forceMove(user)
	explosive.prime()
	user.gib()
	qdel(src)
	return BRUTELOSS

/obj/item/spear/explosive/proc/set_explosive(obj/item/grenade/G)
	if (!G)
		G = new /obj/item/grenade/iedcasing() //For admin-spawned explosive lances
	G.forceMove(src)
	explosive = G
	desc = "A makeshift spear with [G] attached to it"
	update_icon()

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
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.say("[war_cry]", forced="spear warcry")
	explosive.forceMove(user)
	explosive.prime()
	user.gib()
	qdel(src)
	return BRUTELOSS

/obj/item/spear/explosive/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to set your war cry.")

/obj/item/spear/explosive/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		..()
		if(istype(user) && loc == user)
			var/input = tgui_input_text(user,"What do you want your war cry to be? You will shout it when you hit someone in melee. Maximum 50 characters.","Select war cry","",50) // Kept the 50 characther limit since we don't want huge war cries
			if(!input) // no input so we return
				to_chat(user, span_warning("You need to enter something!"))
				return
			if(CHAT_FILTER_CHECK(input)) // check for forbidden words
				to_chat(user, span_warning("Your war cry contains forbidden words."))
				return
			src.war_cry = input

/obj/item/spear/explosive/afterattack(atom/movable/AM, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(ISWIELDED(src))
		user.say("[war_cry]", forced="spear warcry")
		explosive.prime(lanced_by=user)
		qdel(src)

//GREY TIDE
/obj/item/spear/grey_tide
	name = "\improper Grey Tide"
	desc = "Recovered from the aftermath of a revolt aboard Defense Outpost Theta Aegis, in which a seemingly endless tide of Assistants caused heavy casualities among Nanotrasen military forces."
	attack_verb_continuous = list("gores")
	attack_verb_simple = list("gore")
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
	block_upgrade_walk = TRUE
	throwforce = 22
	throw_speed = 4
	embedding = list("armour_block" = 30, "max_damage_mult" = 0.5)
	armour_penetration = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "lacerate", "gore")
	sharpness = SHARP
	bleed_force = BLEED_CUT

/obj/item/spear/bamboospear/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=18, \
				block_power_wielded=25, icon_wielded="[icon_prefix]1")
