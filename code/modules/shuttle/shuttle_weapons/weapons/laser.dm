//Single Laser

/obj/machinery/shuttle_weapon/laser
	name = "Mounted Laser Cannon"
	projectile_type = /obj/item/projectile/bullet/shuttle/beam/laser
	cooldown = 60
	innaccuracy = 1

/obj/item/wallframe/shuttle_weapon/laser
	name = "Laser Cannon Mount"
	result_path = /obj/machinery/shuttle_weapon/laser

//Triple Laser

/obj/machinery/shuttle_weapon/laser/triple
	name = "Burst Laser MKI"
	cooldown = 80
	innaccuracy = 1
	shots = 3

/obj/item/wallframe/shuttle_weapon/laser/triple
	name = "Burst Laser Mount"
	result_path = /obj/machinery/shuttle_weapon/laser/triple

//Mark 2 Laser

/obj/machinery/shuttle_weapon/laser/triple/mark2
	name = "Burst Laser MKII"
	cooldown = 160
	innaccuracy = 2
	shots = 5

/obj/item/wallframe/shuttle_weapon/laser/triple/mark2
	name = "Burst Laser MKII Mount"
	result_path = /obj/machinery/shuttle_weapon/laser/triple/mark2
