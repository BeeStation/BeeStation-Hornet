/obj/item/deployable/bot
	name = "deployable bot" //should never be visible
	desc = "if you're seeing this contact coders ASAP"
	dense_deployment = TRUE
	w_class = WEIGHT_CLASS_BULKY
	//All other variables are set within living/simple_animal/bot/MouseDrop()

/*
/obj/item/deployable/bot/deploy(mob/user, atom/location)
	deployed_object.forceMove(location)
	deployed_object.add_fingerprint(user)
	qdel(src)
*/
