/obj/item/clothing/under/syndicate
	name = "tactical turtleneck"
	desc = "A non-descript and slightly suspicious looking turtleneck with digital camouflage cargo pants."
	icon_state = "syndicate"
	item_state = "bl_suit"
	has_sensor = NO_SENSORS
	armor_type = /datum/armor/under_syndicate
	alt_covers_chest = TRUE
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'


/datum/armor/under_syndicate
	melee = 10
	bio = 10
	fire = 50
	acid = 40
	stamina = 10
	bleed = 25

/obj/item/clothing/under/syndicate/tacticool
	name = "tacticool turtleneck"
	desc = "Just looking at it makes you want to buy an SKS, go into the woods, and -operate-."
	icon_state = "tactifool"
	item_state = "bl_suit"
	armor_type = /datum/armor/syndicate_tacticool


/datum/armor/syndicate_tacticool
	bio = 10
	fire = 50
	acid = 40
	bleed = 10

/obj/item/clothing/under/syndicate/sniper
	name = "Tactical turtleneck suit"
	desc = "A double seamed tactical turtleneck disguised as a civilian grade silk suit. Intended for the most formal operator. The collar is really sharp."
	icon_state = "really_black_suit"
	item_state = "bl_suit"
	can_adjust = FALSE

/obj/item/clothing/under/syndicate/camo
	name = "camouflage fatigues"
	desc = "A green military camouflage uniform."
	icon_state = "camogreen"
	item_state = "g_suit"
	can_adjust = FALSE

/obj/item/clothing/under/syndicate/soviet
	name = "Ratnik 5 tracksuit"
	desc = "Badly translated labels tell you to clean this in Vodka. Great for squatting in."
	icon_state = "trackpants"
	can_adjust = FALSE
	armor_type = /datum/armor/syndicate_soviet
	resistance_flags = NONE


/datum/armor/syndicate_soviet
	melee = 10
	bio = 10
	stamina = 10
	bleed = 15

/obj/item/clothing/under/syndicate/combat
	name = "combat uniform"
	desc = "With a suit lined with this many pockets, you are ready to operate."
	icon_state = "syndicate_combat"
	can_adjust = FALSE

/obj/item/clothing/under/syndicate/rus_army
	name = "advanced military tracksuit"
	desc = "Military grade tracksuits for frontline squatting."
	icon_state = "rus_under"
	can_adjust = FALSE
	armor_type = /datum/armor/syndicate_rus_army
	resistance_flags = NONE


/datum/armor/syndicate_rus_army
	melee = 5
	bio = 10
	stamina = 10
	bleed = 15
