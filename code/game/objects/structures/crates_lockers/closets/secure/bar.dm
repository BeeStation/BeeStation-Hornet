/obj/structure/closet/secure_closet/bar
	name = "booze storage"
	req_access = list(ACCESS_BAR)
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	door_anim_time = 0 // no animation
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	can_weld_shut = FALSE

/obj/structure/closet/secure_closet/bar/PopulateContents()
	..()
	for(var/i in 1 to 10)
		new /obj/item/reagent_containers/cup/glass/bottle/beer( src )
	new /obj/item/etherealballdeployer(src)
