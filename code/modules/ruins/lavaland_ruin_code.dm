//If you're looking for spawners like ash walker eggs, check ghost_role_spawners.dm

/obj/structure/fans/tiny/invisible //For blocking air in ruin doorways
	invisibility = INVISIBILITY_ABSTRACT

//Free Golems

/obj/item/disk/design_disk/golem_shell
	name = "Golem Creation Disk"
	desc = "A gift from the Liberator."
	icon_state = "datadisk1"
	max_blueprints = 1

/obj/item/disk/design_disk/golem_shell/Initialize(mapload)
	. = ..()
	var/datum/design/golem_shell/G = new
	blueprints[1] = G

/datum/design/golem_shell
	name = "Golem Shell Construction"
	desc = "Allows for the construction of a Golem Shell."
	id = "golem"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 40000)
	build_path = /obj/item/golem_shell
	category = list("Imported")

/obj/item/golem_shell
	name = "incomplete free golem shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "The incomplete body of a golem. Add ten sheets of any mineral to finish."
	var/shell_type = /obj/effect/mob_spawn/human/golem
	var/has_owner = FALSE //if the resulting golem obeys someone
	w_class = WEIGHT_CLASS_BULKY

/obj/item/golem_shell/attackby(obj/item/I, mob/user, params)
	..()
	var/static/list/golem_shell_species_types = list(
		/obj/item/stack/sheet/iron	                = /datum/species/golem,
		/obj/item/stack/sheet/mineral/copper        = /datum/species/golem/copper,
		/obj/item/stack/sheet/glass 	            = /datum/species/golem/glass,
		/obj/item/stack/sheet/plasteel 	            = /datum/species/golem/plasteel,
		/obj/item/stack/sheet/mineral/sandstone	    = /datum/species/golem/sand,
		/obj/item/stack/sheet/mineral/plasma	    = /datum/species/golem/plasma,
		/obj/item/stack/sheet/mineral/diamond	    = /datum/species/golem/diamond,
		/obj/item/stack/sheet/mineral/gold	        = /datum/species/golem/gold,
		/obj/item/stack/sheet/mineral/silver	    = /datum/species/golem/silver,
		/obj/item/stack/sheet/mineral/uranium	    = /datum/species/golem/uranium,
		/obj/item/stack/sheet/mineral/bananium	    = /datum/species/golem/bananium,
		/obj/item/stack/sheet/mineral/titanium	    = /datum/species/golem/titanium,
		/obj/item/stack/sheet/mineral/plastitanium	= /datum/species/golem/plastitanium,
		/obj/item/stack/sheet/mineral/abductor	    = /datum/species/golem/alloy,
		/obj/item/stack/sheet/wood	        		= /datum/species/golem/wood,
		/obj/item/stack/ore/bluespace_crystal	    = /datum/species/golem/bluespace,
		/obj/item/stack/medical/gauze	            = /datum/species/golem/cloth,
		/obj/item/stack/sheet/cotton/cloth			= /datum/species/golem/cloth,
		/obj/item/stack/sheet/mineral/adamantine	= /datum/species/golem/adamantine,
		/obj/item/stack/sheet/plastic	            = /datum/species/golem/plastic,
		/obj/item/stack/sheet/brass					= /datum/species/golem/clockwork,
		/obj/item/stack/sheet/bronze				= /datum/species/golem/bronze,
		/obj/item/stack/sheet/cardboard				= /datum/species/golem/cardboard,
		/obj/item/stack/sheet/leather				= /datum/species/golem/leather,
		/obj/item/stack/sheet/bone					= /datum/species/golem/bone,
		/obj/item/stack/sheet/cotton/cloth/durathread			= /datum/species/golem/durathread,
		/obj/item/stack/sheet/cotton/durathread		= /datum/species/golem/durathread,
		/obj/item/stack/sheet/snow					= /datum/species/golem/snow,
		)

	if(istype(I, /obj/item/stack))
		var/obj/item/stack/O = I
		var/species = golem_shell_species_types[O.merge_type]
		if(species)
			if(O.use(10))
				to_chat(user, "You finish up the golem shell with ten sheets of [O].")
				new shell_type(get_turf(src), species, user)
				qdel(src)
			else
				to_chat(user, "You need at least ten sheets to finish a golem.")
		else
			to_chat(user, "You can't build a golem out of this kind of material.")

//made with xenobiology, the golem obeys its creator
/obj/item/golem_shell/servant
	name = "incomplete servant golem shell"
	shell_type = /obj/effect/mob_spawn/human/golem/servant

//Special golem, made by cultists uses soulstones to transfer them into existance

/obj/item/golem_shell/runic
	name = "incomplete runic golem shell"
	desc = "A hollow frame of heavy stone etched with pulsing red runes. It lacks a spark of life."
	icon_state = "construct"

/obj/item/golem_shell/runic/attack_hand(mob/user)
	to_chat(user, span_warning("The shell is far too heavy to lift."))
	return TRUE

/obj/item/golem_shell/runic/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/stack))
		to_chat(user, span_warning("The shell refuses the material you are putting on it.")) // Otherwise they could place metal into it and turn it into a regular golem
		return TRUE
	if(!istype(O, /obj/item/soulstone))
		return ..()
	if(!user || !user.Adjacent(src))
		return TRUE
	if(!IS_CULTIST(user))  // You're not a cultist, why are you even trying to place a soulstone
		to_chat(user, span_warning("The runes refuse to answer your touch."))
		return TRUE
	var/obj/item/soulstone/soulshard = O
	var/mob/living/simple_animal/shade/soul = soulshard.contained_shade
	if(!soul)
		to_chat(user, span_warning("The soulstone is empty. The runes remain dormant."))
		return TRUE
	if(!soul.mind)
		to_chat(user, span_warning("The trapped soul is unstable and cannot inhabit the shell."))
		return TRUE
	var/old_name = replacetext(soul.real_name, "Shade of ", "") // We dont want a golem called "Shade of William"
	user.visible_message(
		span_cult("The runes flare in blood red as the soul is torn from the soulstone and bound into the shell!"))
	var/mob/living/carbon/human/species/golem/blood_cult/golem = new(get_turf(src))
	golem.update_body()
	soul.mind.transfer_to(golem)
	if(!IS_CULTIST(golem)) // Incase they somehow lost their antag datum, we give it again
		golem.mind.add_antag_datum(/datum/antagonist/cult)
	golem.real_name = old_name
	golem.name = old_name
	qdel(soul)
	qdel(soulshard)
	qdel(src) // Full cleanup
	return TRUE
