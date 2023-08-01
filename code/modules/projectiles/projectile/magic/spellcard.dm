/obj/projectile/spellcard
	name = "enchanted card"
	desc = "A piece of paper enchanted to give it extreme durability and stiffness, along with edges sharp enough to slice anyone unfortunate enough to get hit by a charged one."
	icon_state = "spellcard"
	damage_type = BRUTE
	damage = 2

/obj/projectile/spellcard/New(loc, spell_level)
	. = ..()
	damage += spell_level
