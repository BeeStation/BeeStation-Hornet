//FOR THE BASE OBJECT//

/obj/item/anime
	name = "anime dermal implant"
	desc = "You should not be seeing this item!"
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "coder"
	var/obj/item/organ/ears/ears = null
	var/obj/item/organ/tail/tail = null
	var/food_likes
	var/food_dislikes
	var/list/weeb_screams
	var/list/weeb_laughs

/obj/item/anime/attack_self(mob/living/carbon/user)
	if(ishuman(user))
		var/mob/living/carbon/human/weeb = user
		var/new_color = input(user, "Choose a new hair color:", "Anime Color","#"+ears.color) as color|null
		if(new_color) //If they DON'T pick a color, then it just defaults to their original hair color.
			src.color = new_color
			weeb.hair_color = sanitize_hexcolor(src.color) //I guess I have to do this fuck living code

		if(ears)
			ears.Insert(weeb)
		if(tail)
			tail.Insert(weeb)
		if(weeb_screams)
			weeb.alternative_screams += weeb_screams
		if(weeb_laughs)
			weeb.alternative_laughs += weeb_laughs
		if(food_likes)
			weeb.dna.species.liked_food = food_likes
		if(food_dislikes)
			weeb.dna.species.disliked_food = food_dislikes
			weeb.dna.species.toxic_food = food_dislikes

		var/turf/location = get_turf(weeb)
		weeb.add_splatter_floor(location)
		var/msg = "<span class=danger>You feel the power of God and Anime flow through you! </span>"
		to_chat(weeb, msg)
		playsound(location, 'sound/weapons/circsawhit.ogg', 50, 1)
		weeb.update_body()
		weeb.update_hair()
		qdel(src)

//DERMAL IMPLANT SETS//
/obj/item/anime/cat
	name = "anime cat dermal implant"
	desc = "It smells of ammonia"
	icon_state = "cat"
	ears = new /obj/item/organ/ears/cat
	tail = new /obj/item/organ/tail/cat
	food_likes = DAIRY | MEAT
	food_dislikes = FRUIT | VEGETABLES | SUGAR
	weeb_screams = list('monkestation/sound/voice/screams/felinid/hiss.ogg','monkestation/sound/voice/screams/felinid/merowr.ogg','monkestation/sound/voice/screams/felinid/scream_cat.ogg')
	weeb_laughs = list('monkestation/sound/voice/laugh/felinid/cat_laugh0.ogg','monkestation/sound/voice/laugh/felinid/cat_laugh1.ogg','monkestation/sound/voice/laugh/felinid/cat_laugh2.ogg','monkestation/sound/voice/laugh/felinid/cat_laugh3.ogg')


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
