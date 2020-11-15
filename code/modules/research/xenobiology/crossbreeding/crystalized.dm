/obj/item/slimecross/crystalized
	name = "crystalized extract"
	desc = "It's crystalline,"
	effect = "adamantine"
	icon_state = "crystalline"
	var/obj/structure/slime_crystal/crystal_type

/obj/item/slimecross/crystalized/attack_hand(mob/user)
	. = ..()
	var/obj/structure/slime_crystal/C = locate() in range(6,src)

	if(C)
		to_chat(user,"<span class='notice'>You can't build crystals that close to each other!</notice>")
		return

	var/user_turf = get_turf(user)
	if(!do_after(user,15 SECONDS,FALSE,user_turf))
		return
	new crystal_type(user_turf)

/obj/item/slimecross/crystalized/grey
	crystal_type = /obj/structure/slime_crystal
	colour = "grey"

/obj/item/slimecross/crystalized/orange
	crystal_type = /obj/structure/slime_crystal
	colour = "orange"

/obj/item/slimecross/crystalized/purple
	crystal_type = /obj/structure/slime_crystal
	colour = "purple"

/obj/item/slimecross/crystalized/blue
	crystal_type = /obj/structure/slime_crystal
	colour = "blue"

/obj/item/slimecross/crystalized/metal
	crystal_type = /obj/structure/slime_crystal
	colour = "metal"

/obj/item/slimecross/crystalized/yellow
	crystal_type = /obj/structure/slime_crystal
	colour = "yellow"

/obj/item/slimecross/crystalized/darkpurple
	crystal_type = /obj/structure/slime_crystal
	colour = "dark purple"

/obj/item/slimecross/crystalized/darkblue
	crystal_type = /obj/structure/slime_crystal
	colour = "dark blue"

/obj/item/slimecross/crystalized/silver
	crystal_type = /obj/structure/slime_crystal
	colour = "silver"

/obj/item/slimecross/crystalized/bluespace
	crystal_type = /obj/structure/slime_crystal
	colour = "bluespace"

/obj/item/slimecross/crystalized/sepia
	crystal_type = /obj/structure/slime_crystal
	colour = "sepia"

/obj/item/slimecross/crystalized/cerulean
	crystal_type = /obj/structure/slime_crystal
	colour = "cerulean"

/obj/item/slimecross/crystalized/pyrite
	crystal_type = /obj/structure/slime_crystal
	colour = "pyrite"

/obj/item/slimecross/crystalized/red
	crystal_type = /obj/structure/slime_crystal
	colour = "red"

/obj/item/slimecross/crystalized/green
	crystal_type = /obj/structure/slime_crystal
	colour = "green"

/obj/item/slimecross/crystalized/pink
	crystal_type = /obj/structure/slime_crystal
	colour = "pink"

/obj/item/slimecross/crystalized/gold
	crystal_type = /obj/structure/slime_crystal
	colour = "gold"

/obj/item/slimecross/crystalized/oil
	crystal_type = /obj/structure/slime_crystal
	colour = "oil"

/obj/item/slimecross/crystalized/black
	crystal_type = /obj/structure/slime_crystal
	colour = "black"

/obj/item/slimecross/crystalized/lightpink
	crystal_type = /obj/structure/slime_crystal
	colour = "light pink"

/obj/item/slimecross/crystalized/adamantine
	crystal_type = /obj/structure/slime_crystal
	colour = "adamantine"

/obj/item/slimecross/crystalized/rainbow
	crystal_type = /obj/structure/slime_crystal
	colour = "rainbow"
