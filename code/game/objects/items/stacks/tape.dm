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
	var/chance = 70
	var/fallchance = 0.5
	var/painchance = 0
	var/painmult = 0
	var/impactmult = 0
	var/removalpain = 0
	var/removaltime = 30
	var/blood = 0
	var/warning = 2
	var/taped = 1

/obj/item/stack/sticky_tape/afterattack(obj/item/I, mob/living/user)
	if(!istype(I))
		return

	if(I.embedding.embedded_taped == 1)
		to_chat(user, "<span class='warning'>[I] is already coated in tape!</span>")
		return

	user.visible_message("<span class='notice'>[user] begins wrapping [I] with [src].</span>", "<span class='notice'>You begin wrapping [I] with [src].</span>")

	if(do_after(user, 30, target=I))
		use(1)

		I.embedding = embedding.setRating(embed_chance = chance, embedded_fall_chance = fallchance, embedded_pain_chance = painchance, embedded_pain_multiplier = painmult, embedded_impact_pain_multiplier = impactmult, embedded_unsafe_removal_pain_multiplier = removalpain, embedded_unsafe_removal_time = removaltime, embedded_ignore_throwspeed_threshold = TRUE, embedded_blood = blood, embedded_warning = warning, embedded_taped = taped)

		to_chat(user, "<span class='notice'>You finish wrapping [I] with [src].</span>")
		I.name = "[prefix] [I.name]"

		// Might add this in further on if sticky bombs become OP but I don't like random chance
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
	impactmult = 0
	removalpain = 0
	removaltime = 60
	blood = 0
	warning = 2

/obj/item/stack/sticky_tape/pointy
	name = "pointy tape"
	singular_name = "pointy tape"
	desc = "Used for sticking to things for sticking said things inside people."
	icon_state = "tape_evil"
	prefix = "pointy"
	chance = 70
	fallchance = 0.5
	painchance = 5
	painmult = 2
	impactmult = 1
	blood = 1
	warning = 1

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
	impactmult = 2
	removaltime = 60
	blood = 1
	warning = 1

/obj/item/stack/sticky_tape/surgical
	name = "surgical tape"
	singular_name = "surgical tape"
	desc = "Made for patching broken bones back together alongside bone gel, not for playing pranks."
	icon_state = "tape_spikes"
	prefix = "surgical"
	chance = 70
	fallchance = 0.5
	painchance = 0
	painmult = 0
	impactmult = 0
	blood = 0
	removalpain = 0
	warning = 2
	custom_price = 500
