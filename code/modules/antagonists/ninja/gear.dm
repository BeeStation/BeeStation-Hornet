// Caltrops and throwing stars
/obj/item/caltrops
	name = "caltrops"
	desc = "a small spiked object left on the floor to deter pursuers"
	force = 8 // it's a sharp object
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "caltrops"

/obj/item/caltrops/Initialize()
	. = ..()
	AddComponent(/datum/component/caltrop, 20, 20, 100, CALTROP_BYPASS_SHOES)

/obj/item/throwing_star/ninja
	name = "ninja throwing star"
	throwforce = 30
	embedding = list("embedded_pain_multiplier" = 6, "embed_chance" = 100, "embedded_fall_chance" = 0)

// Cloaking devices
/obj/item/shadowcloak/ninja
	name = "ninja cloaking belt"

/obj/item/shadowcloak/ninja/might
	name = "M.I.G.H.T. compatible cloaking belt"
	desc = "A modifed version of the cloaking belt, compatible with the heavier M.I.G.H.T. suit. Has a lower charge capacity."
	max_charge = 150
	charge = 150

/obj/item/shadowcloak/ninja/silence
	name = "SILENCE advanced cloaking belt"
	desc = "An advanced version of the cloaking belt, developed using mime technology. Has a higher charge capacity."
	max_charge = 600
	charge = 600

// Silence baton

/obj/item/melee/classic_baton/contractor_baton/ninja
	name = "ninja baton"
	desc = "A retractable baton. Mutes targets on hit. Can also override doors."
	icon_state = "ninja_baton_0"
	on_icon_state = "ninja_baton_1"
	off_icon_state = "ninja_baton_0"
	on_item_state = "ninja_baton"

/obj/item/restraints/legcuffs/bola/energy/ninja
	name = "ninja energy bola"
	desc = "A specialized hard-light bola designed to ensnare targets and slow pursuers."
	icon_state = "nbola"
	item_state = "nbola"

/obj/item/melee/classic_baton/contractor_baton/ninja/additional_effects_carbon(mob/living/target, mob/living/user)
	. = ..()
	var/mob/living/carbon/C = target
	C.silent += 10

/obj/item/melee/classic_baton/contractor_baton/ninja/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(on && proximity_flag && (isobj(target) || issilicon(target)))
		target.emag_act(user)

/obj/item/storage/box/syndi_kit/ninja
	name = "path of balance"

/obj/item/storage/box/syndi_kit/ninja/PopulateContents()
	new /obj/item/energy_katana(src)
	new /obj/item/shadowcloak/ninja(src)
	new /obj/item/throwing_star/ninja(src)
	new /obj/item/throwing_star/ninja(src)
	new /obj/item/implanter/adrenalin(src)

/obj/item/storage/box/syndi_kit/ninja/speed
	name = "path of speed"

/obj/item/storage/box/syndi_kit/ninja/speed/PopulateContents()
	new /obj/item/energy_katana/dash(src)
	new /obj/item/shadowcloak/ninja(src)
	new /obj/item/implanter/adrenalin(src)

/obj/item/storage/box/syndi_kit/ninja/might
	name = "path of might"

/obj/item/storage/box/syndi_kit/ninja/might/PopulateContents()
	new /obj/item/energy_katana/might(src)
	new /obj/item/shadowcloak/ninja/might(src)
	new /obj/item/clothing/suit/space/space_ninja/might(src)
	new /obj/item/clothing/head/helmet/space/space_ninja/might(src)

/obj/item/storage/box/syndi_kit/ninja/silence
	name = "path of silence"

/obj/item/storage/box/syndi_kit/ninja/silence/PopulateContents()
	new /obj/item/shadowcloak/ninja/silence(src)
	new /obj/item/pen/sleepy(src)
	new /obj/item/melee/classic_baton/contractor_baton/ninja(src)

/obj/item/storage/box/syndi_kit/ninja/wisdom
	name = "path of wisdom"

/obj/item/storage/box/syndi_kit/ninja/wisdom/PopulateContents()
	new /obj/item/shadowcloak/ninja(src)
	new /obj/item/clothing/gloves/space_ninja/wisdom(src)
	new /obj/item/card/emag/bluespace(src)

/obj/item/choice_beacon/ninja
	name = "path beacon"
	desc = "Choose your path wisely, ninja."

/obj/item/choice_beacon/ninja/generate_display_names()
	var/static/list/ninja_item_list
	if(!ninja_item_list)
		ninja_item_list = list()
		var/list/templist = typesof(/obj/item/storage/box/syndi_kit/ninja) //we have to convert type = name to name = type, how lovely!
		for(var/V in templist)
			var/atom/A = V
			ninja_item_list[initial(A.name)] = A
	return ninja_item_list