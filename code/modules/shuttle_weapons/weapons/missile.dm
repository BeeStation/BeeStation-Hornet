/obj/machinery/shuttle_weapon/missile
	name = "Centaur I Missile Launcher"
	weapon_desc = "A large tubular missile launcher that fires low powered missiles with a long reload time."
	icon_state = "missile_left"
	projectile_type = /obj/item/projectile/bullet/shuttle/missile/mini
	cooldown = 180
	innaccuracy = 1

/obj/machinery/shuttle_weapon/missile/tri
	name = "Centaur II Missile Tubes"
	weapon_desc = "A redesigned version of the Centaur I that fires 3 small yield payloads with a poor accuracy."
	projectile_type = /obj/item/projectile/bullet/shuttle/missile/mini
	cooldown = 250
	innaccuracy = 3
	shots = 3

/obj/machinery/shuttle_weapon/missile/breach
	name = "Minotaur Breaching Missile Launcher"
	weapon_desc = "A launcher that houses a missile with a heavy payload designed for breaching hull."
	projectile_type = /obj/item/projectile/bullet/shuttle/missile/breach
	cooldown = 220
	innaccuracy = 2

/obj/machinery/shuttle_weapon/missile/breach
	name = "Prometheus Incediary Missile Launcher"
	weapon_desc = "A powerful rocket designed to ignite fires and injure crew on a targetted vessel."
	projectile_type = /obj/item/projectile/bullet/shuttle/missile/fire
	cooldown = 200
	innaccuracy = 3
