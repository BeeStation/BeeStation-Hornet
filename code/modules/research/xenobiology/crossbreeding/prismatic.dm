/*
Prismatic extracts:
	Becomes an infinite-use paintbrush.
*/
/obj/item/slimecross/prismatic
	name = "prismatic extract"
	desc = "It's constantly wet with a semi-transparent, colored goo."
	effect = "prismatic"
	effect_desc = "When used it paints whatever it hits."
	icon_state = "prismatic"
	var/paintcolor = "#FFFFFF"

/obj/item/slimecross/prismatic/afterattack(turf/target, mob/user, proximity)
	if(!proximity)
		return
	if(!istype(target) || isspaceturf(target))
		return
	target.add_atom_colour(paintcolor, WASHABLE_COLOUR_PRIORITY)
	playsound(target, 'sound/effects/slosh.ogg', 20, 1)

/obj/item/slimecross/prismatic/grey/
	colour = SLIME_TYPE_GREY
	desc = "It's constantly wet with a pungent-smelling, clear chemical."

/obj/item/slimecross/prismatic/grey/afterattack(turf/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target) && target.color != initial(target.color))
		target.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		playsound(target, 'sound/effects/slosh.ogg', 20, 1)

/obj/item/slimecross/prismatic/orange
	paintcolor = "#FFA500"
	colour = SLIME_TYPE_ORANGE

/obj/item/slimecross/prismatic/purple
	paintcolor = "#B19CD9"
	colour = SLIME_TYPE_PURPLE

/obj/item/slimecross/prismatic/blue
	paintcolor = "#ADD8E6"
	colour = SLIME_TYPE_BLUE

/obj/item/slimecross/prismatic/metal
	paintcolor = "#7E7E7E"
	colour = SLIME_TYPE_METAL

/obj/item/slimecross/prismatic/yellow
	paintcolor = "#FFFF00"
	colour = SLIME_TYPE_YELLOW

/obj/item/slimecross/prismatic/darkpurple
	paintcolor = "#551A8B"
	colour = SLIME_TYPE_DARK_PURPLE

/obj/item/slimecross/prismatic/darkblue
	paintcolor = "#0000FF"
	colour = SLIME_TYPE_DARK_BLUE

/obj/item/slimecross/prismatic/silver
	paintcolor = "#D3D3D3"
	colour = SLIME_TYPE_SILVER

/obj/item/slimecross/prismatic/bluespace
	paintcolor = "#32CD32"
	colour = SLIME_TYPE_BLUESPACE

/obj/item/slimecross/prismatic/sepia
	paintcolor = "#704214"
	colour = SLIME_TYPE_SEPIA

/obj/item/slimecross/prismatic/cerulean
	paintcolor = "#2956B2"
	colour = SLIME_TYPE_CERULEAN

/obj/item/slimecross/prismatic/pyrite
	paintcolor = "#FAFAD2"
	colour = SLIME_TYPE_PYRITE

/obj/item/slimecross/prismatic/red
	paintcolor = "#FF0000"
	colour = SLIME_TYPE_RED

/obj/item/slimecross/prismatic/green
	paintcolor = "#00FF00"
	colour = SLIME_TYPE_GREEN

/obj/item/slimecross/prismatic/pink
	paintcolor = "#FF69B4"
	colour = SLIME_TYPE_PINK

/obj/item/slimecross/prismatic/gold
	paintcolor = "#FFD700"
	colour = SLIME_TYPE_GOLD

/obj/item/slimecross/prismatic/oil
	paintcolor = "#505050"
	colour = SLIME_TYPE_OIL

/obj/item/slimecross/prismatic/black
	paintcolor = "#000000"
	colour = SLIME_TYPE_BLACK

/obj/item/slimecross/prismatic/lightpink
	paintcolor = "#FFB6C1"
	colour = SLIME_TYPE_LIGHT_PINK

/obj/item/slimecross/prismatic/adamantine
	paintcolor = "#008B8B"
	colour = SLIME_TYPE_ADAMANTINE

/obj/item/slimecross/prismatic/rainbow
	paintcolor = "#FFFFFF"
	colour = SLIME_TYPE_RAINBOW

/obj/item/slimecross/prismatic/rainbow/attack_self(mob/user)
	var/newcolor = tgui_color_picker(user, "Choose the slime color:", "Color change",paintcolor)
	if(user.get_active_held_item() != src || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(!newcolor)
		return
	paintcolor = newcolor
