// Eldritch armor. Looks cool, hood lets you cast heretic spells.
/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flash_protect = 2
	clothing_traits = list(TRAIT_ALLOW_HERETIC_CASTING)

/obj/item/clothing/head/hooded/cult_hoodie/eldritch/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	. += "<span class='notice'>Allows you to cast heretic spells while the hood is up.</span>"

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
	armor = list("melee" = 50, "bullet" = 50, "laser" = 50,"energy" = 50, "bomb" = 35, "bio" = 20, "rad" = 20, "fire" = 20, "acid" = 20, "stamina" = 50)

/obj/item/clothing/suit/hooded/cultrobes/eldritch/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	. += "<span class='notice'>Allows you to cast heretic spells while the hood is up.</span>"

// Void cloak. Turns invisible with the hood up, lets you hide stuff.
/obj/item/clothing/head/hooded/cult_hoodie/void
	name = "void hood"
	icon_state = "void_cloak"
	flags_inv = NONE
	flags_cover = NONE
	desc = "Black like tar and doesn't reflect any light. Runic symbols line the outside, with each flash you lose comprehension of what you are seeing."
	item_flags = EXAMINE_SKIP
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30,"energy" = 30, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 30)

/obj/item/clothing/suit/hooded/cultrobes/void
	name = "void cloak"
	desc = "Black like tar and doesn't reflect any light. Runic symbols line the outside, with each flash you lose comprehension of what you are seeing."
	icon_state = "void_cloak"
	item_state = "void_cloak"
	allowed = list(/obj/item/melee/sickly_blade)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/void
	flags_inv = NONE
	// slightly worse than normal cult robes
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30,"energy" = 30, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 30)
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/void_cloak
	alternative_mode = TRUE

/obj/item/clothing/suit/hooded/cultrobes/void/RemoveHood()
	var/mob/living/carbon/carbon_user = loc
	to_chat(carbon_user, "<span class='notice'>The kaleidoscope of colors collapses around you, as the cloak shifts to visibility!</span>")
	item_flags &= ~EXAMINE_SKIP
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/void/MakeHood()
	if(!iscarbon(loc))
		CRASH("[src] attempted to make a hood on a non-carbon thing: [loc]")

	var/mob/living/carbon/carbon_user = loc
	if(IS_HERETIC_OR_MONSTER(carbon_user))
		. = ..()
		to_chat(carbon_user,"<span class='notice'>The light shifts around you making the cloak invisible!</span>")
		item_flags |= EXAMINE_SKIP
		return

	to_chat(carbon_user,"<span class='danger'>You can't force the hood onto your head!</span>")
