////////////////////
/////BODYPARTS/////
////////////////////


/obj/item/bodypart/var/should_draw_bee = FALSE

/mob/living/carbon/proc/draw_bee_parts(undo = FALSE)
	if(!undo)
		for(var/O in bodyparts)
			var/obj/item/bodypart/B = O
			B.should_draw_bee = TRUE
	else
		for(var/O in bodyparts)
			var/obj/item/bodypart/B = O
			B.should_draw_bee = FALSE