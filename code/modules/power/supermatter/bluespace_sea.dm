/turf/closed/indestructible/supermatter/wall
	name = "bluespace sea"
	desc = "It looks as if constantly melting and reforming. It'd probably be a bad idea to touch it."
	icon = 'icons/turf/walls/bluespace.dmi'
	icon_state = "bluespacecrystal1"
	var/next_check=0
	var/list/avail_dirs = list(NORTH,SOUTH,EAST,WEST)
	light_range = 5
	light_power = 2
	light_color="#0066FF"

/turf/closed/indestructible/supermatter/wall/proc/consume(atom/AM)
	if(isliving(AM))
		var/mob/living/user = AM
		user.dust(force = TRUE)
	else if(isobj(AM))
		qdel(AM)

/turf/closed/indestructible/supermatter/wall/New()
	START_PROCESSING(SSobj, src)
	icon_state = "bluespacecrystal[rand(1,3)]"
	var/nturns=pick(0,3)
	if(nturns)
		var/matrix/M = matrix()
		M.Turn(90*nturns)
		transform = M
	. = ..()

/turf/closed/indestructible/supermatter/wall/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

//Stolen, I mean, ported from VGstation
/turf/closed/indestructible/supermatter/wall/process()
	// Only check infrequently.
	if(next_check>world.time)
		return

	// No more available directions? Shut down process().
	if(avail_dirs.len==0)
		STOP_PROCESSING(SSobj, src)
		return 1

	// We're checking, reset the timer.
	next_check = world.time+5 SECONDS

	// Choose a direction.
	var/pdir = pick(avail_dirs)
	avail_dirs -= pdir
	var/turf/T=get_step(src,pdir)
	if(istype(T, /turf/closed/indestructible/supermatter/wall))
		avail_dirs -= pdir
		return

	// EXPAND DONG
	if(isturf(T))
		// This is normally where a growth animation would occur
		spawn(10)
			// Nom.
			for(var/atom/movable/A in T)
				
				if(A)
					if(istype(A, /obj/singularity/cascade/exit))
						for(var/mob/M in GLOB.player_list)
							to_chat(M, "<span class='boldannounce'>All hope is lost, the bluespace rift has closed.</span>")
							SEND_SOUND(M, 'sound/effects/supermatter.ogg')
					if(istype(A,/mob/living))
						qdel(A)
						A = null
					else if(istype(A,/mob)) // Observers, AI cameras.
						continue
					qdel(A)
					A = null
				CHECK_TICK
			T.ChangeTurf(type)
			var/turf/closed/indestructible/supermatter/wall/SM = T
			if(SM.avail_dirs)
				SM.avail_dirs -= get_dir(T, src)

/turf/closed/indestructible/supermatter/wall/attack_hand(mob/user)
	user.visible_message("<span class=\"warning\">\The [user] reaches out and touches \the [src]... And then blinks out of existance.</span>",\
	"<span class=\"danger\">You reach out and touch \the [src]. Everything immediately goes quiet. Your last thought is \"That was not a wise decision.\"</span>",\
	"<span class=\"warning\">You hear an unearthly noise.</span>")
	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)
	src.consume(user)

/turf/closed/indestructible/supermatter/wall/attackby(obj/item/W, mob/user)
	user.visible_message("<span class=\"warning\">\The [user] touches \a [W] to \the [src] as a silence fills the room...</span>",\
		"<span class=\"danger\">You touch \the [W] to \the [src] when everything suddenly goes silent.\"</span>\n<span class=\"notice\">\The [W] flashes into dust as you flinch away from \the [src].</span>",\
		"<span class=\"warning\">Everything suddenly goes silent.</span>")

	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	src.consume(W)

/turf/closed/indestructible/supermatter/wall/Bumped(atom/AM)
	if(istype(AM, /mob/living))
		AM.visible_message("<span class=\"warning\">\The [AM] slams into \the [src] inducing a resonance... \his body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class=\"danger\">You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class=\"warning\">You hear an unearthly noise as a wave of heat washes over you.</span>")
	else
		AM.visible_message("<span class=\"warning\">\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>",\
		"<span class=\"warning\">You hear a loud crack as you are washed with a wave of heat.</span>")

	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	src.consume(AM)

/turf/closed/indestructible/supermatter/wall/attack_ghost(mob/user)
	return

/turf/closed/indestructible/supermatter/wall/singularity_act()
	return

/turf/closed/indestructible/supermatter/wall/no_spread
	avail_dirs = list()