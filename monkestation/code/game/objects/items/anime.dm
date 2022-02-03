//FOR THE BASE OBJECT//

/obj/item/anime
	name = "anime dermal implant"
	desc = "You should not be seeing this item!"
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "coder"
	var/obj/item/organ/ears/ears = null
	var/obj/item/organ/tail/tail = null

/obj/item/anime/examine(mob/user)
	. = ..()
	. += "Ctrl+Click to adjust the color."

/obj/item/anime/attack_self(mob/living/carbon/human/user)
	var/old_hair_color = user.hair_color
	user.hair_color = sanitize_hexcolor(src.color) //I guess I have to do this fuck living code
	if(ears)
		ears.Insert(user)
	if(tail)
		tail.Insert(user)
	user.hair_color = old_hair_color
	var/turf/location = get_turf(user)
	user.add_splatter_floor(location)
	var/msg = "<span class=danger>You feel the power of God and Anime flow through you! </span>"
	to_chat(user, msg)
	playsound(get_turf(user), 'sound/weapons/circsawhit.ogg', 50, 1)
	qdel(src)

/obj/item/anime/CtrlClick(mob/living/carbon/human/user)
	var/new_color = input(user, "Choose your anime color:", "Anime Color","#"+ears.color) as color|null
	if(new_color)
		src.color = new_color
	. = ..()

//DERMAL IMPLANT SETS//
/obj/item/anime/cat
	name = "anime cat dermal implant"
	desc = "It smells of ammonia"
	icon_state = "cat"
	ears = new /obj/item/organ/ears/cat
	tail = new /obj/item/organ/tail/cat


//ANIME TRAIT SPAWNER//
/obj/item/choice_beacon/anime
	name = "anime dermal implant kit"
	desc = "Summon your spirit animal."
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "anime"

/obj/item/choice_beacon/anime/spawn_option(obj/choice, mob/living/carbon/human/M)//overwrite choice proc so it doesn't drop pod.
	var/obj/new_item = new choice()
	var/msg = "<span class=danger>Your dermal implant box produces your chosen persona.</span>"
	to_chat(M, msg)
	var/list/slots = list (
		"backpack" = ITEM_SLOT_BACKPACK,
		"hands" = ITEM_SLOT_HANDS,
	)
	M.equip_in_one_of_slots(new_item, slots , qdel_on_fail = TRUE)

/obj/item/choice_beacon/anime/generate_display_names()
	var/static/list/anime
	if(!anime)
		anime = list()
		var/list/templist = list(/obj/item/anime/cat //Add to this list if you want your implant to be included in the trait
							)
		for(var/V in templist)
			var/atom/A = V
			anime[initial(A.name)] = A
	return anime
