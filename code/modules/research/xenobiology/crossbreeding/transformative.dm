/*
transformative extracts:
	apply a permanent effect to a slime and all of its babies
*/
/obj/item/slimecross/transformative
	name = "transformative extract"
	desc = "It seems to stick to any slime it comes in contact with."
	icon_state = "transformative"
	effect = "transformative"
	var/effect_applied = SLIME_EFFECT_DEFAULT

/obj/item/slimecross/transformative/afterattack(atom/target, mob/user, proximity)
	if(!proximity || !isslime(target))
		return FALSE
	var/mob/living/simple_animal/slime/S = target
	if(S.stat)
		to_chat(user, span_warning("The slime is dead!"))
	if(S.transformeffects & effect_applied)
		to_chat(user,span_warning("This slime already has the [colour] transformative effect applied!"))
		return FALSE
	to_chat(user,span_notice("You apply [src] to [target]."))
	do_effect(S, user)
	S.transformeffects = effect_applied //S.transformeffects |= effect_applied
	qdel(src)

/obj/item/slimecross/transformative/proc/do_effect(mob/living/simple_animal/slime/S, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(S.transformeffects & SLIME_EFFECT_LIGHT_PINK)
		S.remove_from_spawner_menu()
		S.master = null
	if(S.transformeffects & SLIME_EFFECT_METAL)
		S.maxHealth = round(S.maxHealth/1.3)
	if(S.transformeffects & SLIME_EFFECT_BLUESPACE)
		S.remove_verb(/mob/living/simple_animal/slime/proc/teleport)
	if(S.transformeffects & SLIME_EFFECT_PINK)
		var/datum/language_holder/LH = S.get_language_holder()
		LH.selected_language = /datum/language/slime
	if(S.transformeffects & SLIME_EFFECT_SEPIA)
		S.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/transformative_sepia)

/obj/item/slimecross/transformative/grey
	colour = SLIME_TYPE_GREY
	effect_applied = SLIME_EFFECT_GREY
	effect_desc = "Slimes split into one additional slime."

/obj/item/slimecross/transformative/orange
	colour = SLIME_TYPE_ORANGE
	effect_applied = SLIME_EFFECT_ORANGE
	effect_desc = "Slimes will light people on fire when they shock them."

/obj/item/slimecross/transformative/purple
	colour = SLIME_TYPE_PURPLE
	effect_applied = SLIME_EFFECT_PURPLE
	effect_desc = "Slimes will regenerate slowly."

/obj/item/slimecross/transformative/blue
	colour = SLIME_TYPE_BLUE
	effect_applied = SLIME_EFFECT_BLUE
	effect_desc = "Slime will always retain slime of its original colour when splitting."

/obj/item/slimecross/transformative/metal
	colour = SLIME_TYPE_METAL
	effect_applied = SLIME_EFFECT_METAL
	effect_desc = "Slimes will be able to sustain more damage before dying."

/obj/item/slimecross/transformative/metal/do_effect(mob/living/simple_animal/slime/S)
	..()
	S.maxHealth = round(S.maxHealth*1.3)

/obj/item/slimecross/transformative/yellow
	colour = SLIME_TYPE_YELLOW
	effect_applied = SLIME_EFFECT_YELLOW
	effect_desc = "Slimes will gain electric charge faster."

/obj/item/slimecross/transformative/darkpurple
	colour = SLIME_TYPE_DARK_PURPLE
	effect_applied = SLIME_EFFECT_DARK_PURPLE
	effect_desc = "Slime rapidly converts atmospheric plasma to oxygen, healing in the process."

/obj/item/slimecross/transformative/darkblue
	colour = SLIME_TYPE_DARK_BLUE
	effect_applied = SLIME_EFFECT_DARK_BLUE
	effect_desc = "Slimes takes reduced damage from water."

/obj/item/slimecross/transformative/silver
	colour = SLIME_TYPE_SILVER
	effect_applied = SLIME_EFFECT_SILVER
	effect_desc = "Slimes will no longer lose nutrition over time."

/obj/item/slimecross/transformative/bluespace
	colour = SLIME_TYPE_BLUESPACE
	effect_applied = SLIME_EFFECT_BLUESPACE
	effect_desc = "Slimes will teleport to targets when they are at full electric charge."

/obj/item/slimecross/transformative/bluespace/do_effect(mob/living/simple_animal/slime/S, mob/user)
	..()
	S.add_verb(/mob/living/simple_animal/slime/proc/teleport)

/obj/item/slimecross/transformative/sepia
	colour = SLIME_TYPE_SEPIA
	effect_applied = SLIME_EFFECT_SEPIA
	effect_desc = "Slimes move faster."

/obj/item/slimecross/transformative/cerulean
	colour = SLIME_TYPE_CERULEAN
	effect_applied = SLIME_EFFECT_CERULEAN
	effect_desc = "Slime makes another adult rather than splitting, with half the nutrition."

/obj/item/slimecross/transformative/pyrite
	colour = SLIME_TYPE_PYRITE
	effect_applied = SLIME_EFFECT_PYRITE
	effect_desc = "Slime always splits into totally random colors, except rainbow. Can never yield a rainbow slime."

/obj/item/slimecross/transformative/red
	colour = SLIME_TYPE_RED
	effect_applied = SLIME_EFFECT_RED
	effect_desc = "Slimes does 10% more damage when feeding and attacking."

/obj/item/slimecross/transformative/green
	colour = SLIME_TYPE_GREEN
	effect_applied = SLIME_EFFECT_GREEN
	effect_desc = "Grants sentient slimes the ability to become oozelings at will, once."

/obj/item/slimecross/transformative/green/do_effect(mob/living/simple_animal/slime/S)
	..()
	var/datum/action/spell/oozeling_evolve/transform = new(S)
	transform.Grant(S)

/obj/item/slimecross/transformative/pink
	colour = SLIME_TYPE_PINK
	effect_applied = SLIME_EFFECT_PINK
	effect_desc = "Slimes will speak in common rather than in slime."

/obj/item/slimecross/transformative/pink/do_effect(mob/living/simple_animal/slime/S)
	..()
	S.grant_language(/datum/language/common)
	var/datum/language_holder/LH = S.get_language_holder()
	LH.selected_language = /datum/language/common

/obj/item/slimecross/transformative/gold
	colour = SLIME_TYPE_GOLD
	effect_applied = SLIME_EFFECT_GOLD
	effect_desc = "Slime extracts from these will sell for double the price."

/obj/item/slimecross/transformative/oil
	colour = SLIME_TYPE_OIL
	effect_applied = SLIME_EFFECT_OIL
	effect_desc = "Slime douses anything it feeds on in welding fuel."

/obj/item/slimecross/transformative/black
	colour = SLIME_TYPE_BLACK
	effect_applied = SLIME_EFFECT_BLACK
	effect_desc = "Slime is nearly transparent."

/obj/item/slimecross/transformative/lightpink
	colour = SLIME_TYPE_LIGHT_PINK
	effect_applied = SLIME_EFFECT_LIGHT_PINK
	effect_desc = "Slimes may become possessed by supernatural forces."

/obj/item/slimecross/transformative/lightpink/do_effect(mob/living/simple_animal/slime/S, mob/user)
	..()
	SSpoints_of_interest.on_poi_element_added(S)
	S.make_master(user)
	S.set_playable_slime(ROLE_SENTIENCE)

/obj/item/slimecross/transformative/adamantine
	colour = SLIME_TYPE_ADAMANTINE
	effect_applied = SLIME_EFFECT_ADAMANTINE
	effect_desc = "Slimes takes reduced damage from brute attacks."

/obj/item/slimecross/transformative/rainbow
	colour = SLIME_TYPE_RAINBOW
	effect_applied = SLIME_EFFECT_RAINBOW
	effect_desc = "Slime randomly changes color periodically."
