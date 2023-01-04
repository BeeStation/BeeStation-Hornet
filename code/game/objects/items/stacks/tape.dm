

/obj/item/stack/sticky_tape
	name = "sticky tape"
	singular_name = "sticky tape"
	desc = "Used for sticking to things for sticking said things to people."
	icon = 'icons/obj/tapes.dmi'
	icon_state = "tape"
	var/prefix = "sticky"
	item_flags = NOBLUDGEON
	amount = 5
	max_amount = 5

	var/list/conferred_embed = EMBED_HARMLESS
	var/overwrite_existing = FALSE
	///The tape type you get when ripping off a piece of tape.
	var/obj/tape_gag = /obj/item/clothing/mask/muzzle/tape
	greyscale_config = /datum/greyscale_config/tape
	greyscale_colors = "#B2B2B2#BD6A62"

/obj/item/stack/sticky_tape/Initialize(mapload, new_amount, merge)
	. = ..()
	AddComponent(/datum/component/gags_recolorable)

/obj/item/stack/sticky_tape/attack_hand(mob/user, list/modifiers)
	if(user.get_inactive_held_item() == src)
		if(is_zero_amount(delete_if_zero = TRUE))
			return
		if(!do_after(user, 1 SECONDS))
			return
		var/new_tape_gag = new tape_gag(src)
		user.put_in_hands(new_tape_gag)
		use(1)
		to_chat(user, "span class='notice'You rip off a piece of tape.</span>")
		return TRUE
	return ..()

/obj/item/stack/sticky_tape/examine(mob/user)
	. = ..()
	. += "["<span class='notice'>You could rip a piece off by using an empty hand.</span>"]"

/obj/item/stack/sticky_tape/afterattack(obj/item/I, mob/living/user)
	if(!istype(I))
		return

	if(I.embedding == conferred_embed)
		to_chat(user, "<span class='warning'>[I] is already coated in [src]!</span>")
		return

	user.visible_message("<span class='notice'>[user] begins wrapping [I] with [src].</span>", "<span class='notice'>You begin wrapping [I] with [src].</span>")

	if(do_after(user, 30, target=I))
		I.embedding = conferred_embed
		I.updateEmbedding()
		to_chat(user, "<span class='notice'>You finish wrapping [I] with [src].</span>")
		use(1)
		I.name = "[prefix] [I.name]"

		if(istype(I, /obj/item/grenade))
			var/obj/item/grenade/sticky_bomb = I
			sticky_bomb.sticky = TRUE

/obj/item/stack/sticky_tape/super
	name = "super sticky tape"
	singular_name = "super sticky tape"
	desc = "Quite possibly the most mischevious substance in the galaxy. Use with extreme lack of caution."
	prefix = "super sticky"
	conferred_embed = EMBED_HARMLESS_SUPERIOR
	greyscale_colors = "#4D4D4D#75433F"
	tape_gag = /obj/item/clothing/mask/muzzle/tape/super

/obj/item/stack/sticky_tape/pointy
	name = "pointy tape"
	singular_name = "pointy tape"
	desc = "Used for sticking to things for sticking said things inside people."
	icon_state = "tape_spikes"
	prefix = "pointy"
	conferred_embed = EMBED_POINTY
	greyscale_config = /datum/greyscale_config/tape/spikes
	greyscale_colors = "#E64539#808080#AD2F45"
	tape_gag = /obj/item/clothing/mask/muzzle/tape/pointy

/obj/item/stack/sticky_tape/pointy/super
	name = "super pointy tape"
	singular_name = "super pointy tape"
	desc = "You didn't know tape could look so sinister. Welcome to Space Station 13."
	prefix = "super pointy"
	conferred_embed = EMBED_POINTY_SUPERIOR
	greyscale_colors = "#8C0A00#4F4F4F#300008"
	tape_gag = /obj/item/clothing/mask/muzzle/tape/pointy/super
