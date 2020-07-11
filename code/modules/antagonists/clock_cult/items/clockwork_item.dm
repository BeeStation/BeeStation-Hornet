/obj/item/clockwork
	name = "Clockcult Item"
	desc = "The base item for clockcult, please contact coders."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "rare_pepe"
	w_class = WEIGHT_CLASS_SMALL
	var/clockwork_desc = "A fabled artifact from beyond the stars. Contains concentrated meme essence." //Shown to clockwork cultists instead of the normal description

/obj/item/clockwork/examine(mob/user)
	if(is_servant_of_ratvar(user))
		. = clockwork_desc
	else
		. = desc
	. += "[gender == PLURAL ? "They are" : "It is"] a [weightclass2text(w_class)] item."
