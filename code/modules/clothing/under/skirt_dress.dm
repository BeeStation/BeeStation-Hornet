/obj/item/clothing/under/dress
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	body_parts_covered = CHEST|GROIN
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON
	dying_key = DYE_REGISTRY_JUMPSKIRT
	icon = 'icons/obj/clothing/under/dress.dmi'
	worn_icon = 'icons/mob/clothing/under/dress.dmi'

/obj/item/clothing/under/dress/sundress
	name = "sundress"
	desc = "Makes you want to frolic in a field of daisies."
	icon_state = "sundress"
	item_state = "sundress"

/obj/item/clothing/under/dress/blacktango
	name = "black tango dress"
	desc = "Filled with Latin fire."
	icon_state = "black_tango"
	item_state = "wcoat"

/obj/item/clothing/under/dress/striped
	name = "striped dress"
	desc = "Fashion in space."
	icon_state = "striped_dress"
	item_state = "stripeddress"
	fitted = FEMALE_UNIFORM_FULL

/obj/item/clothing/under/dress/sailor
	name = "sailor dress"
	desc = "Formal wear for a leading lady."
	icon_state = "sailor_dress"
	item_state = "sailordress"

/obj/item/clothing/under/dress/redeveninggown
	name = "red evening gown"
	desc = "Fancy dress for space bar singers."
	icon_state = "red_evening_gown"
	item_state = null

/obj/item/clothing/under/dress/skirt
	name = "black skirt"
	desc = "A black skirt, very fancy!"
	icon_state = "blackskirt"
	item_state = "blackskirt"

/obj/item/clothing/under/dress/skirt/blue
	name = "blue skirt"
	desc = "A blue, casual skirt."
	icon_state = "blueskirt"
	item_state = "b_suit"
	custom_price = 25

/obj/item/clothing/under/dress/skirt/red
	name = "red skirt"
	desc = "A red, casual skirt."
	icon_state = "redskirt"
	item_state = "r_suit"
	custom_price = 25

/obj/item/clothing/under/dress/skirt/purple
	name = "purple skirt"
	desc = "A purple, casual skirt."
	icon_state = "purpleskirt"
	item_state = "p_suit"
	custom_price = 25

/obj/item/clothing/under/dress/skirt/plaid
	name = "red plaid skirt"
	desc = "A preppy red skirt with a white blouse."
	icon_state = "plaid_red"
	item_state = "plaid_red"
	can_adjust = TRUE
	alt_covers_chest = TRUE
	custom_price = 25

/obj/item/clothing/under/dress/skirt/plaid/blue
	name = "blue plaid skirt"
	desc = "A preppy blue skirt with a white blouse."
	icon_state = "plaid_blue"
	item_state = "plaid_blue"

/obj/item/clothing/under/dress/skirt/plaid/purple
	name = "purple plaid skirt"
	desc = "A preppy purple skirt with a white blouse."
	icon_state = "plaid_purple"
	item_state = "plaid_purple"

/obj/item/clothing/under/dress/skirt/plaid/green
	name = "green plaid skirt"
	desc = "A preppy green skirt with a white blouse."
	icon_state = "plaid_green"
	item_state = "plaid_green"

/////////////////
//DONATOR ITEMS//
/////////////////

/obj/item/clothing/under/dress/gown
	name = "wine gown"
	desc = "A classic and stylish wine red dress."
	icon_state = "wine_gown"

/obj/item/clothing/under/dress/gown/teal
	name = "teal gown"
	desc = "A classic and stylish teal dress."
	icon_state = "teal_gown"

/obj/item/clothing/under/dress/gown/midnight
	name = "midnight gown"
	desc = "A classic and stylish velvet dress."
	icon_state = "midnight_gown"

///////////////////
//CODER EX. ITEMS//
///////////////////

/obj/item/clothing/under/dress/skirt/coder
	name = "coder skirt"
	desc = "The best of the best. Many have stood before them, however they were powerful enough to not only wear the (in)famous socks, but to embrace them."
	icon_state = "coderskirt"
	item_state = "plaid_green"

/obj/item/clothing/under/dress/skirt/coder/Initialize()
	. = ..()
	add_emitter(/obj/emitter/coder_sparks, "coder_sparks")
	add_filter("outline", 1, list(type = "outline", size = 1,  color = "#00ff37"))
	desc = "It has a tag on it reading \'Pull request approved by [sanitize(get_top_contrib())]\'."

/obj/item/clothing/under/dress/skirt/coder/equipped(mob/living/carbon/human/H, slot)
	. = ..()
	if(slot == ITEM_SLOT_ICLOTHING)
		H.add_emitter(/obj/emitter/coder_sparks, "coder_sparks_H")
		remove_emitter("coder_sparks")
		if(H.socks == "Coder Socks (Pink)"||H.socks == "Coder Socks (Blue)"||H.socks == "Coder Socks (Trans)") //Just don't question it. Blame BYOND on this one...
			to_chat(H, "<span class='notice'>You suddenly feel like you know how reality works!</span>")
		else
			to_chat(H, "<span class='notice'>You feel like would know how reality works but something's missing...</span>")
			if (prob(50))
				var/list/randomcodersocks = pick(
					"Coder Socks (Pink)",
					"Coder Socks (Blue)",
					"Coder Socks (Trans)",)
				H.socks = randomcodersocks
				to_chat(H, "<span class='warning'>Your socks suddenly changes to a pair of coder socks!</span>")
				to_chat(H, "<span class='notice'>...But now you do!</span>")
				H.update_body()

/obj/item/clothing/under/dress/skirt/coder/dropped(mob/living/carbon/human/H, slot)
	. = ..()
	if(slot != ITEM_SLOT_ICLOTHING)
		H.remove_emitter("coder_sparks_H")
		add_emitter(/obj/emitter/coder_sparks, "coder_sparks")
		to_chat(H, "<span class='notice'>you feel like you're back to reality... that was weird!</span>")
