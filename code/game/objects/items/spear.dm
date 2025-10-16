//spears
/obj/item/spear
	name = "spear"
	desc = "A haphazardly-constructed yet still deadly weapon of ancient design."
	icon_state = "spearglass0"
	base_icon_state = "spearglass"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	item_flags = ISWEAPON
	slot_flags = ITEM_SLOT_BACK

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
	canblock = TRUE
	block_flags = BLOCKING_ACTIVE | BLOCKING_UNBALANCE | BLOCKING_COUNTERATTACK

	var/force_unwielded = 10
	var/force_wielded = 18
	var/block_power_wielded = 25

/datum/armor/item_spear
	fire = 50
	acid = 30

/obj/item/spear/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 100, 70) //decent in a pinch, but pretty bad.
	AddComponent(/datum/component/jousting)
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=18, block_power_wielded=25, icon_wielded="[base_icon_state]1")

/obj/item/spear/update_icon()
	icon_state = "[base_icon_state]0"
	..()

/obj/item/spear/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to sword-swallow \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/spear/CheckParts(list/parts_list)
	var/obj/item/shard/tip = locate() in parts_list
	if(tip)
		if (istype(tip, /obj/item/shard/plasma))
			throwforce = 21
			base_icon_state = "spearplasma"
			AddComponent(/datum/component/two_handed, force_unwielded=11, force_wielded=19, icon_wielded="[base_icon_state]1")
		update_icon()
		parts_list -= tip
		qdel(tip)
	var/obj/item/grenade/G = locate() in parts_list
	if(G)
		var/obj/item/spear/explosive/lance = new /obj/item/spear/explosive(src.loc, G)
		lance.TakeComponent(GetComponent(/datum/component/two_handed))
		lance.throwforce = throwforce
		lance.base_icon_state = base_icon_state
		parts_list -= G
		qdel(src)
	return ..()

/obj/item/spear/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(ISWIELDED(src))
		return ..()
	return FALSE

/obj/item/spear/explosive
	name = "explosive lance"
	base_icon_state = "spearbomb"
	icon_state = "spearbomb0"

	var/obj/item/grenade/explosive = null
	var/war_cry = "AAAAARGH!!!"

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
		base_icon_state = lancePart.base_icon_state
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

/*
 * Bone Spear
 */
/obj/item/spear/bonespear	//Blatant imitation of spear, but made out of bone. Not valid for explosive modification.
	name = "bone spear"
	desc = "A haphazardly-constructed yet still deadly weapon. The pinnacle of modern technology."
	icon_state = "bone_spear0"
	base_icon_state = "bone_spear"
	force = 12
	throwforce = 22
	armour_penetration = 50	//Enhanced armor piercing
	force_unwielded = 12
	force_wielded = 20
	block_power_wielded = 60

/obj/item/spear/bamboospear
	name = "bamboo spear"
	desc = "A haphazardly-constructed bamboo stick with a sharpened tip, ready to poke holes into unsuspecting people."
	icon_state = "bamboo_spear0"
	base_icon_state = "bamboo_spear"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 22
	throw_speed = 4
	embedding = list("armour_block" = 30, "max_damage_mult" = 0.5)
	armour_penetration = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "lacerate", "gore")
	sharpness = SHARP
	bleed_force = BLEED_CUT
