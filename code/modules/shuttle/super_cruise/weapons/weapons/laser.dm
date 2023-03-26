//Single Laser

/obj/machinery/shuttle_weapon/laser
	name = "Mounted Laser Cannon"
	frame_type = /obj/item/wallframe/shuttle_weapon/laser
	//projectile_type = /obj/item/projectile/bullet/shuttle/beam/laser
	cooldown = 60
	innaccuracy = 1
	strength_rating = 10
	casing_type = /obj/item/ammo_casing/caseless/laser/shuttle
	requires_ammunition = TRUE
	ammo_loader_type = /obj/machinery/ammo_loader/laser

/obj/item/wallframe/shuttle_weapon/laser
	name = "Laser Cannon Mount"
	result_path = /obj/machinery/shuttle_weapon/laser

//Triple Laser

/obj/machinery/shuttle_weapon/laser/triple
	name = "Burst Laser MKI"
	frame_type = /obj/item/wallframe/shuttle_weapon/laser/triple
	cooldown = 80
	innaccuracy = 1
	shots = 3
	strength_rating = 25

/obj/item/wallframe/shuttle_weapon/laser/triple
	name = "Burst Laser Mount"
	result_path = /obj/machinery/shuttle_weapon/laser/triple

//Mark 2 Laser

/obj/machinery/shuttle_weapon/laser/triple/mark2
	name = "Burst Laser MKII"
	frame_type = /obj/item/wallframe/shuttle_weapon/laser/triple/mark2
	cooldown = 160
	innaccuracy = 2
	shots = 3
	strength_rating = 45
	casing_type = /obj/item/ammo_casing/caseless/laser/shuttle/heavy

/obj/item/wallframe/shuttle_weapon/laser/triple/mark2
	name = "Burst Laser MKII Mount"
	result_path = /obj/machinery/shuttle_weapon/laser/triple/mark2
