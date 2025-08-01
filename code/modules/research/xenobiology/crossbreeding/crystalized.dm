/obj/item/slimecross/crystalline
	name = "crystalline extract"
	desc = "It's crystalline,"
	effect = "crystalline"
	icon_state = "crystalline"
	effect_desc = "Use to place a pylon."
	var/obj/structure/slime_crystal/crystal_type

/obj/item/slimecross/crystalline/attack_self(mob/user)
	. = ..()

	// Check before the progress bar so they don't wait for nothing
	if(locate(/obj/structure/slime_crystal) in range(6,get_turf(user)))
		to_chat(user,span_notice("You can't build crystals that close to each other!"))
		return

	var/user_turf = get_turf(user)

	if(!do_after(user, 15 SECONDS, src))
		return

	// check after in case someone placed a crystal in the meantime (im watching you aramix)
	if(locate(/obj/structure/slime_crystal) in range(6,get_turf(user)))
		to_chat(user,span_notice("You can't build crystals that close to each other!"))
		return

	new crystal_type(user_turf)
	qdel(src)

/obj/item/slimecross/crystalline/grey
	crystal_type = /obj/structure/slime_crystal/grey
	colour = SLIME_TYPE_GREY

/obj/item/slimecross/crystalline/orange
	crystal_type = /obj/structure/slime_crystal/orange
	colour = SLIME_TYPE_ORANGE
	dangerous = TRUE

/obj/item/slimecross/crystalline/purple
	crystal_type = /obj/structure/slime_crystal/purple
	colour = SLIME_TYPE_PURPLE

/obj/item/slimecross/crystalline/blue
	crystal_type = /obj/structure/slime_crystal/blue
	colour = SLIME_TYPE_BLUE

/obj/item/slimecross/crystalline/metal
	crystal_type = /obj/structure/slime_crystal/metal
	colour = SLIME_TYPE_METAL

/obj/item/slimecross/crystalline/yellow
	crystal_type = /obj/structure/slime_crystal/yellow
	colour = SLIME_TYPE_YELLOW

/obj/item/slimecross/crystalline/darkpurple
	crystal_type = /obj/structure/slime_crystal/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE

/obj/item/slimecross/crystalline/darkblue
	crystal_type = /obj/structure/slime_crystal/darkblue
	colour = SLIME_TYPE_DARK_BLUE

/obj/item/slimecross/crystalline/silver
	crystal_type = /obj/structure/slime_crystal/silver
	colour = SLIME_TYPE_SILVER

/obj/item/slimecross/crystalline/bluespace
	crystal_type = /obj/structure/slime_crystal/bluespace
	colour = SLIME_TYPE_BLUESPACE

/obj/item/slimecross/crystalline/sepia
	crystal_type = /obj/structure/slime_crystal/sepia
	colour = SLIME_TYPE_SEPIA

/obj/item/slimecross/crystalline/cerulean
	crystal_type = /obj/structure/slime_crystal/cerulean
	colour = SLIME_TYPE_CERULEAN

/obj/item/slimecross/crystalline/pyrite
	crystal_type = /obj/structure/slime_crystal/pyrite
	colour = SLIME_TYPE_PYRITE

/obj/item/slimecross/crystalline/red
	crystal_type = /obj/structure/slime_crystal/red
	colour = SLIME_TYPE_RED

/obj/item/slimecross/crystalline/green
	crystal_type = /obj/structure/slime_crystal/green
	colour = SLIME_TYPE_GREEN
	dangerous = TRUE

/obj/item/slimecross/crystalline/pink
	crystal_type = /obj/structure/slime_crystal/pink
	colour = SLIME_TYPE_PINK

/obj/item/slimecross/crystalline/gold
	crystal_type = /obj/structure/slime_crystal/gold
	colour = SLIME_TYPE_GOLD

/obj/item/slimecross/crystalline/oil
	crystal_type = /obj/structure/slime_crystal/oil
	colour = SLIME_TYPE_OIL

/obj/item/slimecross/crystalline/black
	crystal_type = /obj/structure/slime_crystal/black
	colour = SLIME_TYPE_BLACK

/obj/item/slimecross/crystalline/lightpink
	crystal_type = /obj/structure/slime_crystal/lightpink
	colour = SLIME_TYPE_LIGHT_PINK

/obj/item/slimecross/crystalline/adamantine
	crystal_type = /obj/structure/slime_crystal/adamantine
	colour = SLIME_TYPE_ADAMANTINE

/obj/item/slimecross/crystalline/rainbow
	crystal_type = /obj/structure/slime_crystal/rainbow
	colour = SLIME_TYPE_RAINBOW
