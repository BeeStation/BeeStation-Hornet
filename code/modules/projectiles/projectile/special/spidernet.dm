/obj/item/projectile/bullet/spidernet
	name = "sticky webbing"
	icon_state = "spidernet"
	damage = 0

/obj/item/projectile/bullet/spidernet/on_hit(atom/target, blocked = FALSE)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.Knockdown(4 SECONDS)
	else if(isliving(target)) //we do NOT want to apply this effect to carbons
		var/mob/living/L = target
		L.Immobilize(4 SECONDS)
	return ..()

/obj/item/projectile/bullet/spidernet/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/turf/T = get_turf(target)
		web_tile(T)
	else
		web_tile()
/obj/item/projectile/bullet/spidernet/on_range()
	web_tile()
	..()

/obj/item/projectile/bullet/spidernet/proc/web_tile(var/turf/T)
	if(!T)
		T = get_turf(src)
	var/webs = 0
	for(var/obj/structure/spider/stickyweb/web in T)
		webs++
	if(webs >= MAX_WEBS_PER_TILE)
		return
	else
		new /obj/structure/spider/stickyweb(T)

/obj/item/projectile/bullet/spidernet/prehit_pierce(atom/A)
	if(istype(A, /mob/living/simple_animal/hostile/poison/giant_spider) || istype(A, /obj/structure/spider/stickyweb))
		return PROJECTILE_PIERCE_PHASE
	return ..()

