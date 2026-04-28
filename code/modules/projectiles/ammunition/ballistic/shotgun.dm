// Shotgun

/obj/item/ammo_casing/shotgun
	name = "shotgun slug"
	desc = "A gold-tipped 12 gauge lead slug."
	icon_state = "blshell"
	caliber = "shotgun"
	var/high_power = TRUE
	custom_materials = list(/datum/material/iron=4000, /datum/material/gold=2000)
	projectile_type = /obj/projectile/bullet/shotgun_slug

/obj/item/ammo_casing/shotgun/beanbag
	name = "beanbag slug"
	desc = "A less-lethal beanbag slug for riot control."
	icon_state = "bshell"
	high_power = FALSE
	custom_materials = list(/datum/material/iron=4000, /datum/material/copper=2000)
	projectile_type = /obj/projectile/bullet/shotgun_beanbag

/obj/item/ammo_casing/shotgun/incendiary
	name = "incendiary slug"
	desc = "A plasma-tipped shotgun slug."
	icon_state = "ishell"
	high_power = FALSE
	projectile_type = /obj/projectile/bullet/incendiary/shotgun
	custom_materials = list(/datum/material/iron=4000, /datum/material/plasma=2000)

/obj/item/ammo_casing/shotgun/dragonsbreath
	name = "dragonsbreath shell"
	desc = "A plasma-tipped shotgun shell which fires a spread of incendiary pellets."
	icon_state = "ishell2"
	high_power = FALSE
	projectile_type = /obj/projectile/bullet/incendiary/shotgun/dragonsbreath
	pellets = 4
	variance = 35
	custom_materials = list(/datum/material/iron=3000, /datum/material/plasma=3000)

/obj/item/ammo_casing/shotgun/stunslug
	name = "taser slug"
	desc = "A copper-tipped stunning taser slug."
	icon_state = "stunshell"
	custom_materials = list(/datum/material/iron=3000, /datum/material/uranium=2000, /datum/material/copper=2000, /datum/material/diamond=2000)
	projectile_type = /obj/projectile/bullet/shotgun_stunslug

/obj/item/ammo_casing/shotgun/pulseslug
	name = "pulse slug"
	desc = "A copper-tipped delicate device which can be loaded into a shotgun. The primer acts as a button which triggers the gain medium and fires a powerful \
	energy blast. While the heat and power drain limit it to one use, it can still allow an operator to engage targets that ballistic ammunition \
	would have difficulty with."
	icon_state = "pshell"
	projectile_type = /obj/projectile/beam/pulse/shotgun
	custom_materials = list(/datum/material/iron=2000, /datum/material/diamond=3000)

/obj/item/ammo_casing/shotgun/buckshot
	name = "buckshot shell" //seperated into two different types.
	desc = "A bronze-tipped 12 gauge buckshot shell."
	icon_state = "gnshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot
	pellets = 6
	variance = 10
	custom_materials = list(/datum/material/iron=4000, /datum/material/copper=2000)

/obj/item/ammo_casing/shotgun/buckshot/armour_piercing
	name = "armour-piercing buckshot shell"
	desc = "A gold-tipped, armour-piercing 12 gauge buckshot shell."
	icon_state = "gshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_buckshot/armour_piercing
	pellets = 6
	variance = 10

/obj/item/ammo_casing/shotgun/rubbershot
	name = "rubber shot"
	desc = "A gold-tipped shotgun casing filled with densely-packed rubber balls, used to incapacitate crowds from a distance."
	icon_state = "bshell"
	high_power = FALSE
	projectile_type = /obj/projectile/bullet/pellet/shotgun_rubbershot
	pellets = 6
	variance = 15
	custom_materials = list(/datum/material/iron=4000, /datum/material/gold=2000)

/obj/item/ammo_casing/shotgun/incapacitate
	name = "improvised incapacitation shell"
	desc = "A shotgun casing filled with... something. used to incapacitate targets."
	icon_state = "bountyshell"
	high_power = FALSE
	projectile_type = /obj/projectile/bullet/pellet/shotgun_incapacitate
	pellets = 12//double the pellets, but half the stun power of each, which makes this best for just dumping right in someone's face.
	variance = 20
	custom_materials = list(/datum/material/iron=2000 , /datum/material/glass=2000)

/obj/item/ammo_casing/shotgun/improvised
	name = "improvised shell"
	desc = "A shotgun shell improvised from small metal shards. It won't travel as far as a regular shotgun shell, but it will still pack a punch against unarmoured opponents at close ranges."
	icon_state = "improvshell"
	projectile_type = /obj/projectile/bullet/pellet/shotgun_metal
	custom_materials = list(/datum/material/iron=250, /datum/material/glass=250)
	pellets = 6
	variance = 10
	gun_damage = 25

/obj/item/ammo_casing/shotgun/improvised/glasspack
	name = "improvised glass-packed shell"
	desc = "A shotgun shell that's been filled with shards of glass instead of metal pellets."
	projectile_type = /obj/projectile/bullet/pellet/shotgun_glass
	custom_materials = list(/datum/material/iron=100, /datum/material/glass=400)
	pellets = 5
	variance = 15

/obj/item/ammo_casing/shotgun/ion
	name = "ion shell"
	desc = "A gold-tipped advanced shotgun shell which uses a subspace ansible crystal to produce an effect similar to a standard ion rifle. \
	The unique properties of the crystal split the pulse into a spread of individually weaker bolts."
	icon_state = "ionshell"
	projectile_type = /obj/projectile/ion/weak
	pellets = 4
	variance = 35

/obj/item/ammo_casing/shotgun/laserslug
	name = "scatter laser shell"
	desc = "A gold-tipped advanced shotgun shell that uses a micro laser to replicate the effects of a scatter laser weapon in a ballistic package."
	icon_state = "lshell"
	projectile_type = /obj/projectile/beam/weak/shotgun
	pellets = 6
	variance = 35

/obj/item/ammo_casing/shotgun/techshell
	name = "unloaded bluespace shell"
	desc = "A high-tech shotgun shell which can be loaded with materials to produce unique effects."
	icon_state = "cshell"
	projectile_type = null
	custom_materials = list(/datum/material/iron=4000, /datum/material/bluespace=2000)

/obj/item/ammo_casing/shotgun/dart
	name = "shotgun dart"
	desc = "A gold-tipped dart for use in shotguns. Can be injected with up to 30 units of any chemical."
	icon_state = "dtshell"
	high_power = FALSE
	projectile_type = /obj/projectile/bullet/dart
	custom_materials = list(/datum/material/iron=4000, /datum/material/silver=2000)
	var/reagent_amount = 30

/obj/item/ammo_casing/shotgun/dart/Initialize(mapload)
	. = ..()
	create_reagents(reagent_amount, OPENCONTAINER)

/obj/item/ammo_casing/shotgun/dart/attackby()
	return

/obj/item/ammo_casing/shotgun/dart/noreact
	name = "cryostasis shotgun dart"
	desc = "A gold-tipped dart for use in shotguns, using similar technology as cryostatis beakers to keep internal reagents from reacting. Can be injected with up to 10 units of any chemical."
	high_power = FALSE
	icon_state = "cnrshell"
	reagent_amount = 10
	custom_materials = list(/datum/material/iron=4000, /datum/material/diamond=2000)

/obj/item/ammo_casing/shotgun/dart/noreact/Initialize(mapload)
	. = ..()
	ENABLE_BITFIELD(reagents.flags, NO_REACT)

/obj/item/ammo_casing/shotgun/dart/bioterror
	desc = "A shotgun dart filled with deadly toxins."
	high_power = FALSE

/obj/item/ammo_casing/shotgun/dart/bioterror/Initialize(mapload)
	. = ..()
	reagents.add_reagent(/datum/reagent/consumable/ethanol/neurotoxin, 6)
	reagents.add_reagent(/datum/reagent/toxin/spore, 6)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 6) //;HELP OPS IN MAINT
	reagents.add_reagent(/datum/reagent/toxin/coniine, 6)
	reagents.add_reagent(/datum/reagent/toxin/sodium_thiopental, 6)

/obj/item/ammo_casing/shotgun/breacher
	name = "breaching slug"
	desc = "A 12 gauge bronze-tipped anti-material slug. Great for breaching airlocks and windows with minimal shots."
	icon_state = "breacher"
	high_power = FALSE
	projectile_type = /obj/projectile/bullet/shotgun_breaching
	custom_materials = list(/datum/material/iron=4000)

/obj/item/ammo_casing/shotgun/gold
	name = "gold slug"
	desc = "A gold slug. Stronger than a beanbag weaker than a normal slug, but the best at flexing."
	icon_state = "gdshell"
	projectile_type = /obj/projectile/bullet/shotgun_gold
	custom_materials = list(/datum/material/gold=4000)

/obj/item/ammo_casing/shotgun/bronze
	name = "bronze slug"
	desc = "A bronze slug. It acts like a weak beanbag and taser slug combined."
	icon_state = "bzshell"
	projectile_type = /obj/projectile/bullet/shotgun_bronze
	custom_materials = list(/datum/material/copper=4000)

/obj/item/ammo_casing/shotgun/honk
	name = "banana slug"
	desc = "Is this even a real slug? It looks like a banana."
	icon_state = "hkshell"
	projectile_type = /obj/projectile/bullet/shotgun_honk
	custom_materials = list(/datum/material/iron=4000)
