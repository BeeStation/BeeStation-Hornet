GLOBAL_VAR_INIT(supermatter_cascade, FALSE)

/obj/machinery/power/supermatter_crystal
	var/cascade_allowed = TRUE
	//var/cascade_time = 0
/*
/obj/machinery/power/supermatter_crystal/cascade
	name = "energetic supermatter crystal"
	desc = "A strangely translucent and iridescent crystal. It looks very energetic. It'd be unwise to let it delaminate."
	cascade_allowed = TRUE
	config_bullet_energy = 0.1 //No cheesing it with guns
*/
/obj/machinery/power/supermatter_crystal/proc/create_escape()
	var/turf/T = get_safe_random_station_turf()
	new /obj/singularity/cascade/exit(T)


/obj/machinery/power/supermatter_crystal/proc/cascade()
	if (!cascade_allowed)
		return
	for(var/mob/M in GLOB.player_list)
		to_chat(M, "<span class='boldannounce'>You feel a sudden sense of impending doom. Something's not right.</span>")
		SEND_SOUND(M, 'sound/effects/supermatter.ogg')
		SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "delam", /datum/mood_event/delam)
		if(ishuman(M))
			if(istype(M, /mob/living))
				var/mob/living/carbon/human/H = M
				H.hallucination += max(50, min(300, DETONATION_HALLUCINATION * sqrt(1 / (get_dist(M, src) + 1)) ) )
				var/rads = DETONATION_RADS * sqrt( 1 / (get_dist(H, src) + 1) )
				H.rad_act(rads)
	var/turf/T = get_turf(src)
	T.ChangeTurf(/turf/closed/indestructible/supermatter/wall)
	src.create_escape()
	empulse(src, 50, 100, 150)
	GLOB.supermatter_cascade = TRUE
	supermatter_cascade()
	qdel(src)
	

/proc/supermatter_cascade()
	set waitfor = FALSE
	//cascade_time = world.time + 5 MINUTES
	addtimer(VARSET_CALLBACK(SSticker, force_ending, TRUE), 5 MINUTES)
	sound_to_playing_players('sound/ambience/supermatter_cascade.ogg')
	sleep(100)
	SSshuttle.emergency.cancel(null)
	sleep(50)
	priority_announce("Attention, [station_name()]. A u̢nivér͜sal͝-͢wi͠de ͞EMP͟ ̀has bee̡n d͟etec̕t̀ed͝. ͘M͜any̴ ͘sys̸te̡ms ͞at ͞C͡e͞n̶tC̨o̶m a͏re ͢f́ai͜l͠iǹg or h̷a͟ve ͏failed̛ an̨d m̢a̧ņy pe͟r҉so͞n͘n̡e̵l ͢are ͏d҉e҉ad́.̡ W͞e h̸av͘e d̀e͘tect͏ed sign̴s̵ ͘óf ̷t̷ot͝a҉l̛ immi̴nen͢t r̵e̴a͢lity f͝a͞ilure. ̧However̶, ͜you͝ ̕a͏ŕe ́t҉he͞ on҉l͘y st̵a̴t̨i͟o͘n̸ ͞n̸ear̢ ͞a ̛b͝l͟u̡es̀p͝a͝c̢e̛ ͟r̵if͠t̡ to a ͜shiel̀d͘ed̨ ̨ùn͠i̕ve͢rs͜e͜. Goo̷d ͠lu̷ćk ̸mak͘in͠g͘ it t͡he̵re, ͞c̴rew̢.","*enfra̕l̸ ̸Com^and̡ ҉Em/r͟ge͘n͟c͢y C̴om%$ni̸c̨a͏t̡i-ǹs̨")
	sleep(50)
	for(var/mob/M in GLOB.player_list)
		if(ishuman(M))
			var/datum/antagonist/supermatter_survivalist/survivalist = new
			M.mind.add_antag_datum(survivalist)
	//SSshuttle.registerHostileEnvironment(GLOB.supermatter_cascade)
	return


//