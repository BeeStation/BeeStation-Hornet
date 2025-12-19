/obj/item/clothing/under/rank/rnd
	icon = 'icons/obj/clothing/under/rnd.dmi'
	worn_icon = 'icons/mob/clothing/under/rnd.dmi'

/obj/item/clothing/under/rank/rnd/research_director
	name = "research director's jumpsuit"
	desc = "It's a jumpsuit worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "director"
	inhand_icon_state = "w_suit"
	armor_type = /datum/armor/rnd_research_director
	can_adjust = TRUE
	alt_covers_chest = TRUE


/datum/armor/rnd_research_director
	bomb = 10
	bio = 10
	acid = 35
	bleed = 10

/obj/item/clothing/under/rank/rnd/research_director/skirt
	name = "research director's jumpskirt"
	desc = "It's a jumpskirt worn by those with the know-how to achieve the position of \"Research Director\". Its fabric provides minor protection from biological contaminants."
	icon_state = "director_skirt"
	inhand_icon_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	dying_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/rnd/research_director/alt
	desc = "Maybe you'll engineer your own half-man, half-pig creature some day. Its fabric provides minor protection from biological contaminants."
	name = "research director's tan suit"
	icon_state = "rdwhimsy"
	inhand_icon_state = "rdwhimsy"
	armor_type = /datum/armor/research_director_alt
	can_adjust = TRUE
	alt_covers_chest = TRUE


/datum/armor/research_director_alt
	bomb = 10
	bio = 10
	bleed = 10

/obj/item/clothing/under/rank/rnd/research_director/alt/skirt
	name = "research director's tan suitskirt"
	desc = "Maybe you'll engineer your own half-man, half-pig creature some day. Its fabric provides minor protection from biological contaminants."
	icon_state = "rdwhimsy_skirt"
	inhand_icon_state = "rdwhimsy"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	dying_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/rnd/research_director/turtleneck
	desc = "A dark purple turtleneck and tan khakis, for a director with a superior sense of style."
	name = "research director's turtleneck"
	icon_state = "rdturtle"
	inhand_icon_state = "p_suit"
	armor_type = /datum/armor/research_director_turtleneck
	can_adjust = TRUE
	alt_covers_chest = TRUE


/datum/armor/research_director_turtleneck
	bomb = 10
	bio = 10
	bleed = 10

/obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt
	name = "research director's turtleneck skirt"
	desc = "A dark purple turtleneck and tan khaki skirt, for a director with a superior sense of style."
	icon_state = "rdturtle_skirt"
	inhand_icon_state = "p_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	dying_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/rnd/research_director/vest
	desc = "It's made of a special fiber that provides minor protection against biohazards. Though never formally retired, the standard issue Research Director's vest suit is a rare sight."
	name = "research director's vest suit"
	icon_state = "rd_vest"
	inhand_icon_state = "lb_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/rnd/scientist
	desc = "It's made of a special fiber that provides minor protection against explosives. It has markings that denote the wearer as a scientist."
	name = "scientist's jumpsuit"
	icon_state = "toxinswhite"
	inhand_icon_state = "w_suit"
	worn_icon_state = "toxinswhite"
	armor_type = /datum/armor/rnd_scientist


/datum/armor/rnd_scientist
	bomb = 10
	bio = 50
	bleed = 10

/obj/item/clothing/under/rank/rnd/scientist/skirt
	name = "scientist's jumpskirt"
	desc = "It's made of a special fiber that provides minor protection against explosives. It has markings that denote the wearer as a scientist."
	icon_state = "toxinswhite_skirt"
	inhand_icon_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	dying_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/rnd/roboticist
	desc = "It's a slimming black jumpsuit with reinforced seams; great for industrial work."
	name = "roboticist's jumpsuit"
	icon_state = "robotics"
	inhand_icon_state = "robotics"
	resistance_flags = NONE

/obj/item/clothing/under/rank/rnd/roboticist/skirt
	name = "roboticist's jumpskirt"
	desc = "It's a slimming black jumpskirt with reinforced seams; great for industrial work."
	icon_state = "robotics_skirt"
	inhand_icon_state = "robotics"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION_NO_NEW_ICON
	dying_key = DYE_REGISTRY_JUMPSKIRT

/obj/item/clothing/under/rank/rnd/roboticist/retro
	desc = "It's a slimming black jumpsuit with reinforced seams; great for industrial work. Vintage design, modern look, and the gloves are just for show."
	name = "roboticist's retro jumpsuit"
	icon_state = "robotics_retro"
	inhand_icon_state = "robotics"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	female_sprite_flags = FEMALE_UNIFORM_TOP_ONLY
	alternate_worn_layer = GLOVES_LAYER
	can_adjust = FALSE
