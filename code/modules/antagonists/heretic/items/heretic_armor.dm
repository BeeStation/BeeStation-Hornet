// Eldritch armor. Looks cool, hood lets you cast heretic spells.
/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flash_protect = 2

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/equipped(mob/user, slot)
	..()
	ADD_TRAIT(user, TRAIT_ALLOW_HERETIC_CASTING, CLOTHING_TRAIT)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/dropped(mob/user)
	..()
	REMOVE_TRAIT(user, TRAIT_ALLOW_HERETIC_CASTING, CLOTHING_TRAIT)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/heretic_focus)

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	item_state = "eldritch_armor"
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS
	allowed = list(/obj/item/melee/sickly_blade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch
	// Slightly better than normal cult robes
	armor = list(MELEE = 50, BULLET = 50, LASER = 50,ENERGY = 50, BOMB = 35, BIO = 20, RAD = 20, FIRE = 20, ACID = 20, STAMINA = 50)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/examine(mob/user)
	. = ..()
	if(qdel_hood)
		return

	// Our hood gains the heretic_focus element.
	. += "<span class='notice'>Allows you to cast heretic spells while the hood is up.</span>"

// Void cloak. Turns invisible with the hood up, lets you hide stuff.
/obj/item/clothing/head/hooded/cult_hoodie/void
	name = "void hood"
	icon_state = "void_cloak"
	flags_inv = NONE
	flags_cover = NONE
	desc = "Black like tar and doesn't reflect any light. Runic symbols line the outside, with each flash you lose comprehension of what you are seeing."
	item_flags = EXAMINE_SKIP
	armor = list(MELEE = 30, BULLET = 30, LASER = 30,ENERGY = 30, BOMB = 15, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 30)

/obj/item/clothing/head/hooded/cult_hoodie/void/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_STRIP, REF(src))

/obj/item/clothing/suit/hooded/cultrobes/void
	name = "void cloak"
	desc = "Black like tar and doesn't reflect any light. Runic symbols line the outside, with each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	item_state = "void_cloak"
	allowed = list(/obj/item/melee/sickly_blade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	flags_inv = NONE
	// slightly worse than normal cult robes
	armor = list(MELEE = 30, BULLET = 30, LASER = 30,ENERGY = 30, BOMB = 15, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 30)
	body_parts_covered = CHEST|GROIN|ARMS
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/void_cloak
	qdel_hood = TRUE

/obj/item/clothing/suit/hooded/cultrobes/void/Initialize(mapload)
	. = ..()
	make_visible()

/obj/item/clothing/suit/hooded/cultrobes/void/RemoveHood()
	// This is before the hood actually goes down
	// We only make it visible if the hood is being moved from up to down
	if(qdel_hood && hood)
		make_visible()
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/void/MakeHood()
	if(!isliving(loc))
		CRASH("[src] attempted to make a hood on a non-living thing: [loc]")

	var/mob/living/wearer = loc
	if(!IS_HERETIC_OR_MONSTER(wearer))
		loc.balloon_alert(loc, "you can't get the hood up!")
		return

	// When we make the hood, that means we're going invisible
	make_invisible()
	return ..()

/// Makes our cloak "invisible". Not the wearer, the cloak itself.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_invisible()
	item_flags |= EXAMINE_SKIP
	ADD_TRAIT(src, TRAIT_NO_STRIP, REF(src))
	RemoveElement(/datum/element/heretic_focus)

	if(isliving(loc))
		loc.balloon_alert(loc, "cloak hidden")
		loc.visible_message("<span class='notice'>Light shifts around [loc], making the cloak around them invisible!</span>")

/// Makes our cloak "visible" again.
/obj/item/clothing/suit/hooded/cultrobes/void/proc/make_visible()
	item_flags &= ~EXAMINE_SKIP
	REMOVE_TRAIT(src, TRAIT_NO_STRIP, REF(src))
	AddElement(/datum/element/heretic_focus)

	if(isliving(loc))
		loc.balloon_alert(loc, "cloak revealed")
		loc.visible_message("<span class=notice>A kaleidoscope of colours collapses around [loc], a cloak appearing suddenly around their person!</span>")
