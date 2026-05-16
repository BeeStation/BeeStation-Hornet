/////////////////////////////Harvester/////////////////////////
/mob/living/simple_animal/hostile/construct/harvester
	name = "Harvester"
	real_name = "Harvester"
	desc = "A long, thin construct built to herald Nar'Sie's rise. It'll be all over soon."
	icon_state = "harvester"
	icon_living = "harvester"
	maxHealth = 40
	health = 40
	sight = SEE_MOBS
	melee_damage = 15
	attack_verb_continuous = "butchers"
	attack_verb_simple = "butcher"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	construct_spells = list(
		/datum/action/spell/aoe/area_conversion,
		/datum/action/spell/forcewall/cult,
	)
	playstyle_string = "<B>You are a Harvester. You are incapable of directly killing humans, \
		but your attacks will remove their limbs: Bring those who still cling to this world \
		of illusion back to the Geometer so they may know Truth. Your form and any you are \
		pulling can pass through runed walls effortlessly.</B>"
	can_repair = TRUE


/mob/living/simple_animal/hostile/construct/harvester/Bump(atom/thing)
	. = ..()
	if(!istype(thing, /turf/closed/wall/mineral/cult) || thing == loc)
		return // we can go through cult walls
	var/atom/movable/stored_pulling = pulling
	if(stored_pulling)
		stored_pulling.setDir(get_dir(stored_pulling.loc, loc))
		stored_pulling.forceMove(loc)
	forceMove(thing)

	if(stored_pulling)
		start_pulling(stored_pulling, supress_message = TRUE) //drag anything we're pulling through the wall with us by magic

/mob/living/simple_animal/hostile/construct/harvester/AttackingTarget()
	if(!iscarbon(target))
		return ..()

	var/mob/living/carbon/victim = target
	if(HAS_TRAIT(victim, TRAIT_NODISMEMBER))
		return ..() //ATTACK!

	var/list/parts = list()
	var/strong_limbs = 0
	for(var/obj/item/bodypart/limb as anything in victim.bodyparts)
		if(limb.body_part == HEAD || limb.body_part == CHEST)
			continue
		if(limb.bodypart_flags & BODYPART_UNREMOVABLE)
			parts += limb
		else
			strong_limbs++

	if(!LAZYLEN(parts))
		if(strong_limbs) // they have limbs we can't remove, and no parts we can, attack!
			return ..()
		victim.Paralyze(60)
		visible_message(span_danger("[src] knocks [victim] down!"))
		to_chat(src, span_cultlarge("\"Bring [victim.p_them()] to me.\""))
		return FALSE

	do_attack_animation(victim)
	var/obj/item/bodypart/limb = pick(parts)
	limb.dismember()
	return FALSE

/mob/living/simple_animal/hostile/construct/harvester/Initialize(mapload)
	. = ..()
	var/datum/action/innate/seek_prey/seek = new()
	seek.Grant(src)
	seek.trigger()
