//Chain Cannon

/obj/machinery/shuttle_weapon/point_defense
	name = "Hades MKI Chaincannon"
	frame_type = /obj/item/wallframe/shuttle_weapon/point_defense
	projectile_type = /obj/item/projectile/bullet/shuttle/ballistic/point_defense
	cooldown = 80
	innaccuracy = 2
	shots = 8
	shot_time = 1
	strength_rating = 5

/obj/item/wallframe/shuttle_weapon/point_defense
	name = "Hadess MKI Chaincannon Mount"
	result_path = /obj/machinery/shuttle_weapon/point_defense

/obj/machinery/shuttle_weapon/point_defense/upgraded
	name = "Hades MKII Chaincannon"
	frame_type = /obj/item/wallframe/shuttle_weapon/point_defense/upgraded
	cooldown = 140
	innaccuracy = 3
	shots = 14
	strength_rating = 15

/obj/item/wallframe/shuttle_weapon/point_defense/upgraded
	name = "Hadess MKII Chaincannon Mount"
	result_path = /obj/machinery/shuttle_weapon/point_defense/upgraded

//Scatter shot

/obj/machinery/shuttle_weapon/scatter
	name = "Ares Scattershot"
	frame_type = /obj/item/wallframe/shuttle_weapon/scatter
	projectile_type = /obj/item/projectile/bullet/shuttle/ballistic/point_defense
	cooldown = 90
	simultaneous_shots = 8
	miss_chance = 80
	hit_chance = 0
	innaccuracy = 4
	strength_rating = 10

/obj/item/wallframe/shuttle_weapon/scatter
	name = "Ares Scattershot Mount"
	result_path = /obj/machinery/shuttle_weapon/scatter

//Railgun

/obj/machinery/shuttle_weapon/railgun
	name = "Zeus MKI Railgun"
	frame_type = /obj/item/wallframe/shuttle_weapon/railgun
	projectile_type = /obj/item/projectile/bullet/shuttle/ballistic/guass
	cooldown = 160
	innaccuracy = 1
	strength_rating = 70
	hit_chance = 80
	miss_chance = 60

/obj/item/wallframe/shuttle_weapon/railgun
	name = "Zeus MKI Railgun Mount"
	result_path = /obj/machinery/shuttle_weapon/railgun

/obj/machinery/shuttle_weapon/railgun/anti_crew
	name = "Zeus MKII Anti-Personnel Railgun"
	frame_type = /obj/item/wallframe/shuttle_weapon/railgun/anti_crew
	projectile_type = /obj/item/projectile/bullet/shuttle/ballistic/guass/uranium
	cooldown = 180
	innaccuracy = 2
	strength_rating = 90
	hit_chance = 60
	miss_chance = 80

/obj/item/wallframe/shuttle_weapon/railgun/anti_crew
	name = "Zeus MKII Anti-Personnel Railgun Mount"
	result_path = /obj/machinery/shuttle_weapon/railgun/anti_crew
