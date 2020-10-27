/obj/item/parachute
	name = "parachute"
	desc = "A one-use parachute. made in form of the backpack. It will deploy automatically when you will fall into the chasm."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "parachute"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/parachute/proc/deploy(var/turf/new_turf)
	if(!isliving(loc))
		return
	var/mob/living/A = loc
	var/mutable_appearance/balloon
	var/mutable_appearance/balloon2
	var/mutable_appearance/balloon3
	A.buckled = 0
	var/obj/effect/extraction_holder/holder_obj = new(A.loc)
	holder_obj.appearance = A.appearance
	A.forceMove(holder_obj)
	A.Stun(160)
	balloon2 = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_expand")
	balloon2.pixel_y = 10
	balloon2.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	holder_obj.add_overlay(balloon2)
	sleep(4)
	balloon = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_balloon")
	balloon.pixel_y = 10
	balloon.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	holder_obj.cut_overlay(balloon2)
	holder_obj.add_overlay(balloon)
	holder_obj.name = A.name
	holder_obj.forceMove(new_turf)
	animate(holder_obj, pixel_z = 10, time = 50)
	sleep(50)
	animate(holder_obj, pixel_z = 15, time = 10)
	sleep(10)
	animate(holder_obj, pixel_z = 10, time = 10)
	sleep(10)
	balloon3 = mutable_appearance('icons/obj/fulton_balloon.dmi', "fulton_retract")
	balloon3.pixel_y = 10
	balloon3.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	holder_obj.cut_overlay(balloon)
	holder_obj.add_overlay(balloon3)
	sleep(4)
	holder_obj.cut_overlay(balloon3)
	animate(holder_obj, pixel_z = 0, time = 5)
	sleep(5)
	A.forceMove(holder_obj.loc)
	qdel(holder_obj)
	qdel(src)