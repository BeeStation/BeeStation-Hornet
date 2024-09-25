/obj/item/slimecross/gentle
	name = "gentle extract"
	desc = "It pulses slowly, as if breathing."
	effect = "gentle"
	effect_desc = "Use to activate minor effect, Alt-click to activate major effect."
	icon_state = "gentle"
	var/extract_type
	var/obj/item/slime_extract/extract
	COOLDOWN_DECLARE(use_cooldown)
	var/cooldown = 5 //This is in seconds

/obj/item/slimecross/gentle/Initialize(mapload)
	..()
	extract = new extract_type(src.loc)
	visible_message("<span class='notice'>[src] glows and pulsates softly.</span>")
	extract.name = name
	extract.desc = desc
	extract.icon = icon
	extract.icon_state = icon_state
	extract.color = color
	extract.forceMove(src)

/obj/item/slimecross/gentle/attack_self(mob/living/carbon/user)
	if(preactivate_core(user))
		COOLDOWN_START(src, use_cooldown, extract.activate(user, user.dna.species, SLIME_ACTIVATE_MINOR))

/obj/item/slimecross/gentle/AltClick(mob/living/carbon/user, obj/item/I)
	if(preactivate_core(user))
		COOLDOWN_START(src, use_cooldown, extract.activate(user, user.dna.species, SLIME_ACTIVATE_MAJOR))

/obj/item/slimecross/gentle/proc/preactivate_core(mob/living/carbon/user)
	if(user.incapacitated() || !iscarbon(user))
		return FALSE
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, "<span class='notice'>[src] isn't ready yet!</span>")
		return FALSE
	COOLDOWN_START(src, use_cooldown, 10 SECONDS) //This will be overwritten depending on exact activation, but prevents bypassing cooldowns on extracts with a do_after.
	return TRUE

/obj/item/slimecross/gentle/grey
	extract_type = /obj/item/slime_extract/grey
	colour = "grey"

/obj/item/slimecross/gentle/orange
	extract_type = /obj/item/slime_extract/orange
	colour = "orange"

/obj/item/slimecross/gentle/purple
	extract_type = /obj/item/slime_extract/purple
	colour = "purple"

/obj/item/slimecross/gentle/blue
	extract_type = /obj/item/slime_extract/blue
	colour = "blue"

/obj/item/slimecross/gentle/metal
	extract_type = /obj/item/slime_extract/metal
	colour = "metal"

/obj/item/slimecross/gentle/yellow
	extract_type = /obj/item/slime_extract/yellow
	colour = "yellow"

/obj/item/slimecross/gentle/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	colour = "dark purple"

/obj/item/slimecross/gentle/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	colour = "dark blue"

/obj/item/slimecross/gentle/silver
	extract_type = /obj/item/slime_extract/silver
	colour = "silver"

/obj/item/slimecross/gentle/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	colour = "bluespace"

/obj/item/slimecross/gentle/sepia
	extract_type = /obj/item/slime_extract/sepia
	colour = "sepia"

/obj/item/slimecross/gentle/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	colour = "cerulean"

/obj/item/slimecross/gentle/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	colour = "pyrite"

/obj/item/slimecross/gentle/red
	extract_type = /obj/item/slime_extract/red
	colour = "red"

/obj/item/slimecross/gentle/green
	extract_type = /obj/item/slime_extract/green
	colour = "green"

/obj/item/slimecross/gentle/pink
	extract_type = /obj/item/slime_extract/pink
	colour = "pink"

/obj/item/slimecross/gentle/gold
	extract_type = /obj/item/slime_extract/gold
	colour = "gold"

/obj/item/slimecross/gentle/oil
	extract_type = /obj/item/slime_extract/oil
	colour = "oil"

/obj/item/slimecross/gentle/black
	extract_type = /obj/item/slime_extract/black
	colour = "black"

/obj/item/slimecross/gentle/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	colour = "light pink"

/obj/item/slimecross/gentle/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	colour = "adamantine"

/obj/item/slimecross/gentle/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	colour = "rainbow"
