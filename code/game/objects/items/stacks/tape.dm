/obj/item/stack/sticky_tape
	name = "sticky tape"
	singular_name = "sticky tape"
	desc = "Used for sticking to things for sticking said things to people."
	icon = 'icons/obj/tapes.dmi'
	icon_state = "tape_w"
	var/prefix = "sticky"
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON
	amount = 5
	max_amount = 5
	resistance_flags = FLAMMABLE
	var/overwrite_existing = FALSE
	var/chance = 45
	var/fallchance = 5
	var/painchance = 0
	var/painmult = 0
	var/impactmult = 1

/obj/item/stack/sticky_tape/afterattack(obj/item/I, mob/living/user)
	if(!istype(I))
		return

	//if(I.embedding && I.embedding == embeddinginfo)
	//	to_chat(user, "<span class='warning'>[I] is already coated in [src]!</span>")
	//	return

	user.visible_message("<span class='notice'>[user] begins wrapping [I] with [src].</span>", "<span class='notice'>You begin wrapping [I] with [src].</span>")

	if(do_after(user, 30, target=I))
		use(1)

		I.embedding = embedding.setRating(embed_chance = chance, embedded_fall_chance = fallchance, embedded_pain_chance = painchance, embedded_pain_multiplier = painmult, embedded_impact_pain_multiplier = impactmult, embedded_ignore_throwspeed_threshold = TRUE)
		if(I.sharpness == 0)
			I.sharpness = IS_SHARP

		to_chat(user, "<span class='notice'>You finish wrapping [I] with [src].</span>")
		I.name = "[prefix] [I.name]"

		// Need to investigate what the fug point of this is
		//if(istype(I, /obj/item/grenade))
		//	var/obj/item/grenade/sticky_bomb = I
		//	sticky_bomb.sticky = TRUE

/obj/item/stack/sticky_tape/super
	name = "super sticky tape"
	singular_name = "super sticky tape"
	desc = "Quite possibly the most mischevious substance in the galaxy. Use with extreme lack of caution."
	icon_state = "tape_y"
	prefix = "super sticky"
	chance = 100
	fallchance = 0.1
	painchance = 0
	painmult = 0
	impactmult = 1

/obj/item/stack/sticky_tape/pointy
	name = "pointy tape"
	singular_name = "pointy tape"
	desc = "Used for sticking to things for sticking said things inside people."
	icon_state = "tape_evil"
	prefix = "pointy"
	chance = 45
	fallchance = 5
	painchance = 15
	painmult = 2
	impactmult = 4

/obj/item/stack/sticky_tape/pointy/super
	name = "super pointy tape"
	singular_name = "super pointy tape"
	desc = "You didn't know tape could look so sinister. Welcome to Space Station 13."
	icon_state = "tape_spikes"
	prefix = "super pointy"
	chance = 100
	fallchance = 0.1
	painchance = 20
	painmult = 2
	impactmult = 4

/obj/item/stack/sticky_tape/surgical
	name = "surgical tape"
	singular_name = "surgical tape"
	desc = "Made for patching broken bones back together alongside bone gel, not for playing pranks."
	icon_state = "tape_spikes"
	prefix = "surgical"
	chance = 100
	fallchance = 5
	painchance = 15
	painmult = 0
	impactmult = 1
	custom_price = 500
