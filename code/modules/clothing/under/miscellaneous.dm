/obj/item/clothing/under/misc/pj
	name = "\improper PJs"
	desc = "A comfy set of sleepwear, for taking naps or being lazy instead of working."

/obj/item/clothing/under/misc/pj/red
	icon_state = "red_pyjamas"
	item_color = "red_pyjamas"
	item_state = "w_suit"
	can_adjust = FALSE

/obj/item/clothing/under/misc/pj/blue
	icon_state = "blue_pyjamas"
	item_color = "blue_pyjamas"
	item_state = "w_suit"
	can_adjust = FALSE

/obj/item/clothing/under/misc/patriotsuit
	name = "Patriotic Suit"
	desc = "Motorcycle not included."
	icon_state = "ek"
	item_state = "ek"
	item_color = "ek"
	can_adjust = FALSE

/obj/item/clothing/under/misc/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	item_state = "b_suit"
	item_color = "mailman"

/obj/item/clothing/under/misc/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	item_state = "p_suit"
	item_color = "psyche"

/obj/item/clothing/under/misc/vice_officer
	name = "vice officer's jumpsuit"
	desc = "It's the standard issue pretty-boy outfit, as seen on Holo-Vision."
	icon_state = "vice"
	item_state = "gy_suit"
	item_color = "vice"
	can_adjust = FALSE

/obj/item/clothing/under/misc/adminsuit
	name = "administrative cybernetic jumpsuit"
	icon_state = "syndicate"
	item_state = "bl_suit"
	item_color = "syndicate"
	desc = "A cybernetically enhanced jumpsuit used for administrative duties."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100,"energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	can_adjust = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/under/misc/burial
	name = "burial garments"
	desc = "Traditional burial garments from the early 22nd century."
	icon_state = "burial"
	item_state = "burial"
	item_color = "burial"
	can_adjust = FALSE
	has_sensor = NO_SENSORS

/obj/item/clothing/under/misc/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	item_state = "lb_suit"
	item_color = "overalls"
	can_adjust = FALSE
	custom_price = 20

/obj/item/clothing/under/misc/assistantformal
	name = "assistant's formal uniform"
	desc = "An assistant's formal-wear. Why an assistant needs formal-wear is still unknown."
	icon_state = "assistant_formal"
	item_state = "gy_suit"
	item_color = "assistant_formal"
	can_adjust = FALSE

/obj/item/clothing/under/plasmaman
	name = "plasma envirosuit"
	desc = "A special containment suit that allows plasma-based lifeforms to exist safely in an oxygenated environment, and automatically extinguishes them in a crisis. Despite being airtight, it's not spaceworthy."
	icon_state = "plasmaman"
	item_state = "plasmaman"
	item_color = "plasmaman"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 95, "acid" = 95)
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	can_adjust = FALSE
	strip_delay = 80
	resistance_flags = FIRE_PROOF
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 5
	envirosealed = TRUE


/obj/item/clothing/under/plasmaman/examine(mob/user)
	. = ..()
	. += "<span class='notice'>There are [extinguishes_left] extinguisher charges left in this suit.</span>"

/obj/item/clothing/under/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.on_fire)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message("<span class='warning'>[H]'s suit automatically extinguishes [H.p_them()]!</span>","<span class='warning'>Your suit automatically extinguishes you.</span>")
			H.ExtinguishMob()
			new /obj/effect/particle_effect/water(get_turf(H))
	return 0

/obj/item/clothing/under/plasmaman/attackby(obj/item/E, mob/user, params)
	..()
	if (istype(E, /obj/item/extinguisher_refill))
		if (extinguishes_left == 5)
			to_chat(user, "<span class='notice'>The inbuilt extinguisher is full.</span>")
			return
		else
			extinguishes_left = 5
			to_chat(user, "<span class='notice'>You refill the suit's built-in extinguisher, using up the cartridge.</span>")
			qdel(E)
			return

/obj/item/extinguisher_refill
	name = "envirosuit extinguisher cartridge"
	desc = "A cartridge loaded with a compressed extinguisher mix, used to refill the automatic extinguisher on plasma envirosuits."
	icon_state = "plasmarefill"
	icon = 'icons/obj/device.dmi'

/obj/item/clothing/under/misc/durathread
	name = "durathread jumpsuit"
	desc = "A jumpsuit made from durathread, its resilient fibres provide some protection to the wearer."
	icon_state = "durathread"
	item_state = "durathread"
	item_color = "durathread"
	can_adjust = FALSE
	armor = list("melee" = 10, "laser" = 10, "fire" = 40, "acid" = 10, "bomb" = 5)
