/obj/item/slimecross/crystalline
	name = "crystalline extract"
	desc = "It's crystalline,"
	effect = "crystalline"
	icon_state = "crystalline"
	effect_desc = "Use to place a pylon."
	var/obj/structure/slime_crystal/crystal_type

/obj/item/slimecross/crystalline/attack_self(mob/user)
	. = ..()

	var/obj/structure/slime_crystal/C = locate(/obj/structure/slime_crystal) in range(6,get_turf(user))

	if(C)
		to_chat(user,"<span class='notice'>You can't build crystals that close to each other!</span>")
		return

	var/user_turf = get_turf(user)

	if(!do_after(user,15 SECONDS,FALSE,user_turf))
		return

	new crystal_type(user_turf)
	qdel(src)

/obj/item/slimecross/crystalline/grey
	crystal_type = /obj/structure/slime_crystal/grey
	colour = "grey"

/obj/item/slimecross/crystalline/orange
	crystal_type = /obj/structure/slime_crystal/orange
	colour = "orange"

/obj/item/slimecross/crystalline/purple
	crystal_type = /obj/structure/slime_crystal/purple
	colour = "purple"

/obj/item/slimecross/crystalline/blue
	crystal_type = /obj/structure/slime_crystal/blue
	colour = "blue"

/obj/item/slimecross/crystalline/metal
	crystal_type = /obj/structure/slime_crystal/metal
	colour = "metal"

/obj/item/slimecross/crystalline/yellow
	crystal_type = /obj/structure/slime_crystal/yellow
	colour = "yellow"

/obj/item/slimecross/crystalline/darkpurple
	crystal_type = /obj/structure/slime_crystal/darkpurple
	colour = "dark purple"

/obj/item/slimecross/crystalline/darkblue
	crystal_type = /obj/structure/slime_crystal/darkblue
	colour = "dark blue"

/obj/item/slimecross/crystalline/silver
	crystal_type = /obj/structure/slime_crystal/silver
	colour = "silver"

/obj/item/slimecross/crystalline/bluespace
	crystal_type = /obj/structure/slime_crystal/bluespace
	colour = "bluespace"

/obj/item/slimecross/crystalline/sepia
	crystal_type = /obj/structure/slime_crystal/sepia
	colour = "sepia"

/obj/item/slimecross/crystalline/cerulean
	crystal_type = /obj/structure/slime_crystal/cerulean
	colour = "cerulean"

/obj/item/slimecross/crystalline/pyrite
	crystal_type = /obj/structure/slime_crystal/pyrite
	colour = "pyrite"

/obj/item/slimecross/crystalline/red
	crystal_type = /obj/structure/slime_crystal/red
	colour = "red"

/obj/item/slimecross/crystalline/green
	crystal_type = /obj/structure/slime_crystal/green
	colour = "green"

/obj/item/slimecross/crystalline/pink
	crystal_type = /obj/structure/slime_crystal/pink
	colour = "pink"

/obj/item/slimecross/crystalline/gold
	crystal_type = /obj/structure/slime_crystal/gold
	colour = "gold"

/obj/item/slimecross/crystalline/oil
	crystal_type = /obj/structure/slime_crystal/oil
	colour = "oil"

/obj/item/slimecross/crystalline/black
	crystal_type = /obj/structure/slime_crystal/black
	colour = "black"

/obj/item/slimecross/crystalline/lightpink
	crystal_type = /obj/structure/slime_crystal/lightpink
	colour = "light pink"

/obj/item/slimecross/crystalline/adamantine
	crystal_type = /obj/structure/slime_crystal/adamantine
	colour = "adamantine"

/obj/item/slimecross/crystalline/rainbow
	crystal_type = /obj/structure/slime_crystal/rainbow
	colour = "rainbow"
