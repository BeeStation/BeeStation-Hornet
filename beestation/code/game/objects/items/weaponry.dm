// Shank - Makeshift weapon that can embed on throw
/obj/item/melee/shank
	name = "Shank"
	desc = "A crude knife fashioned by wrapping some cable around a glass shard. It looks like it could be thrown with some force.. and stick. Good to throw at someone chasing you"
	icon = 'beestation/icons/obj/items_and_weapons.dmi'
	icon_state = "shank"
	item_state = "shank" //Kind of a placeholder, but im ass with sprites and I doubt someone will notice its a recoloured switchblade :')
	lefthand_file = 'beestation/icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'beestation/icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 8 // 3 more than base glass shard
	throwforce = 8
	throw_speed = 5 //yeets
	armour_penetration = 10 //spear has 10 armour pen, I think its fitting another glass tipped item should have it too
	embedding = list("embedded_pain_multiplier" = 6, "embed_chance" = 40, "embedded_fall_chance" = 5) // Incentive to disengage/stop chasing when stuck
	attack_verb = list("stuck", "shanked")
	w_class = WEIGHT_CLASS_SMALL
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = IS_SHARP

/obj/item/melee/shank/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is slitting [user.p_their()] [pick("wrists", "throat")] with the shank! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return (BRUTELOSS)