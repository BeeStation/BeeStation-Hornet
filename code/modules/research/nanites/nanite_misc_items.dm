/obj/item/nanite_injector
	name = "nanite injector (FOR TESTING)"
	desc = "Injects nanites into the user."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/device.dmi'
	icon_state = "nanite_remote"

/obj/item/nanite_injector/attack_self(mob/user)
	var/cloud_id = tgui_input_number(user, "Input Cloud ID", "Nanite Injector", 1, 99, 1)
	user.AddComponent(/datum/component/nanites, 150, cloud_id)
