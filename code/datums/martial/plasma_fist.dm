#define TORNADO_COMBO "HHD"
#define THROWBACK_COMBO "DHD"
#define PLASMA_COMBO "HDDDH"

/datum/martial_art/plasma_fist
	name = "Plasma Fist"
	id = MARTIALART_PLASMAFIST
	var/nobomb = FALSE
	var/plasma_power = 1 //starts at a 1, 2, 4 explosion.
	var/plasma_increment = 1 //how much explosion power gets added per kill (1 = 1, 2, 4. 2 = 2, 4, 8 and so on)
	var/plasma_cap = 12 //max size explosion level
	display_combos = TRUE

	Move1 = "Tail Sweep: Disarm Disarm Grab Harm. Pushes everyone around you away and knocks them down."
	Move2 = "Tornado Sweep: Harm Harm Disarm. Repulses target and everyone back."
	Move3 = "Throwback: Disarm Harm Disarm. Throws the target and an item at them."
	Move4 = "The Plasma Fist: Harm Disarm Disarm Disarm Harm. Knocks the brain out of the opponent and gibs their body."

/datum/martial_art/plasma_fist/teach(mob/living/holder_living, make_temporary = FALSE)
	if(!nobomb)
		Move5 = "Apotheosis: Use <span class='notice'>The Plasma Fist</span> on yourself. Sends you away in a glorious explosion."
	. = ..()

/datum/martial_art/plasma_fist/proc/check_streak(mob/living/A, mob/living/D)
	if(findtext(streak,TORNADO_COMBO))
		if(A == D)//helps using apotheosis
			return FALSE
		reset_streak()
		Tornado(A,D)
		return TRUE
	if(findtext(streak,THROWBACK_COMBO))
		if(A == D)//helps using apotheosis
			return FALSE
		reset_streak()
		Throwback(A,D)
		return TRUE
	if(findtext(streak,PLASMA_COMBO))
		reset_streak()
		if(A == D && !nobomb)
			Apotheosis(A,D)
		else
			Plasma(A,D)
		return TRUE
	return FALSE

/datum/martial_art/plasma_fist/proc/TornadoAnimate(mob/living/A)
	set waitfor = FALSE
	for(var/i in list(NORTH,SOUTH,EAST,WEST,EAST,SOUTH,NORTH,SOUTH,EAST,WEST,EAST,SOUTH))
		if(!A)
			break
		A.setDir(i)
		playsound(A.loc, 'sound/weapons/punch1.ogg', 15, 1, -1)
		sleep(1)

/datum/martial_art/plasma_fist/proc/Tornado(mob/living/A, mob/living/D)
	A.say("TORNADO SWEEP!", forced="plasma fist")
	TornadoAnimate(A)
	var/datum/action/spell/aoe/repulse/tornado_spell = new(src)
	tornado_spell.on_cast(A, null)
	qdel(tornado_spell)
	log_combat(A, D, "tornado sweeped(Plasma Fist)", name)
	return

/datum/martial_art/plasma_fist/proc/Throwback(mob/living/A, mob/living/D)
	D.visible_message(span_danger("[A] hits [D] with Plasma Punch!"), \
					span_userdanger("You're hit with a Plasma Punch by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
	to_chat(A, span_danger("You hit [D] with Plasma Punch!"))
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	var/atom/throw_target = get_edge_target_turf(D, get_dir(D, get_step_away(D, A)))
	D.throw_at(throw_target, 200, 4,A)
	A.say("HYAH!", forced="plasma fist")
	log_combat(A, D, "threw back (Plasma Fist)", name)
	return

/datum/martial_art/plasma_fist/proc/Plasma(mob/living/A, mob/living/D)
	var/hasclient = D.client ? TRUE : FALSE

	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	playsound(D.loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
	A.say("PLASMA FIST!", forced="plasma fist")
	D.visible_message(span_danger("[A] hits [D] with THE PLASMA FIST TECHNIQUE!"), \
					span_userdanger("You're suddenly hit with THE PLASMA FIST TECHNIQUE by [A]!"), span_hear("You hear a sickening sound of flesh hitting flesh!"), null, A)
	to_chat(A, span_danger("You hit [D] with THE PLASMA FIST TECHNIQUE!"))
	log_combat(A, D, "gibbed (Plasma Fist)", name)
	var/turf/Dturf = get_turf(D)
	D.gib()
	if(nobomb)
		return
	if(!hasclient)
		to_chat(A, "<span class='warning'>Taking this plasma energy for your </span><span class='notice'>Apotheosis</span><span class='warning'> would bring dishonor to the clan!</span>")
		new /obj/effect/temp_visual/plasma_soul(Dturf)//doesn't beam to you, so it just hangs around and poofs.
		return
	else if(plasma_power >= plasma_cap)
		to_chat(A, "<span class='warning'>You cannot power up your </span><span class='notice'>Apotheosis</span><span class='warning'> any more!</span>")
		new /obj/effect/temp_visual/plasma_soul(Dturf)//doesn't beam to you, so it just hangs around and poofs.
	else
		plasma_power += plasma_increment
		to_chat(A, "<span class='nicegreen'>Power increasing! Your </span><span class='notice'>Apotheosis</span><span class='nicegreen'> is now at power level [plasma_power]!</span>")
		new /obj/effect/temp_visual/plasma_soul(Dturf, A)
		var/oldcolor = A.color
		A.color = "#9C00FF"
		flash_color(A, flash_color = "#9C00FF", flash_time = 3 SECONDS)
		animate(A, color = oldcolor, time = 3 SECONDS)


/datum/martial_art/plasma_fist/proc/Apotheosis(mob/living/A, mob/living/D)
	A.say("APOTHEOSIS!!", forced="plasma fist")
	if (ishuman(A))
		var/mob/living/carbon/human/human_attacker = A
		human_attacker.set_species(/datum/species/plasmaman)
		ADD_TRAIT(human_attacker, TRAIT_BOMBIMMUNE, type)
		human_attacker.unequip_everything()
		human_attacker.underwear = "Nude"
		human_attacker.undershirt = "Nude"
		human_attacker.socks = "Nude"
		human_attacker.update_body()
	var/turf/boomspot = get_turf(A)

	//before ghosting to prevent issues
	log_combat(A, A, "triggered final plasma explosion with size [plasma_power], [plasma_power*2], [plasma_power*4] (Plasma Fist)")
	message_admins("[key_name_admin(A)] triggered final plasma explosion with size [plasma_power], [plasma_power*2], [plasma_power*4].")

	to_chat(A, "<span class='userdanger'>The explosion knocks your soul out of your body!</span>")
	A.ghostize(FALSE) //prevents... horrible memes just believe me

	A.apply_damage(rand(50,70), BRUTE)

	addtimer(CALLBACK(src, PROC_REF(Apotheosis_end), A), 6 SECONDS)
	playsound(boomspot, 'sound/weapons/punch1.ogg', 50, TRUE, -1)
	explosion(boomspot,plasma_power,plasma_power*2,plasma_power*4,ignorecap = TRUE)
	plasma_power = 1 //just in case there is any clever way to cause it to happen again

/datum/martial_art/plasma_fist/proc/Apotheosis_end(mob/living/dying)
	REMOVE_TRAIT(dying, TRAIT_BOMBIMMUNE, type)
	if(dying.stat == DEAD)
		return
	dying.death()

/datum/martial_art/plasma_fist/harm_act(mob/living/A, mob/living/D)
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/datum/martial_art/plasma_fist/disarm_act(mob/living/A, mob/living/D)
	add_to_streak("D",D)
	if(check_streak(A,D))
		return TRUE
	if(A == D)//there is no disarming yourself, so we need to let plasma fist user know
		to_chat(A, "<span class='notice'>You have added a disarm to your streak.</span>")
	return FALSE

/datum/martial_art/plasma_fist/grab_act(mob/living/A, mob/living/D)
	add_to_streak("G",D)
	if(check_streak(A,D))
		return TRUE
	return FALSE

/obj/effect/temp_visual/plasma_soul
	name = "plasma energy"
	desc = "Leftover energy brought out from The Plasma Fist."
	icon = 'icons/effects/effects.dmi'
	icon_state = "explosion"
	duration = 3 SECONDS
	var/atom/movable/beam_target

/obj/effect/temp_visual/plasma_soul/Initialize(mapload, _beam_target)
	. = ..()
	beam_target = _beam_target
	if(beam_target)
		var/datum/beam/beam = Beam(beam_target, "plasmabeam", time= 3 SECONDS, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/plasma_fist)
		animate(beam.visuals, alpha = 0, time = 3 SECONDS)
	animate(src, alpha = 0, transform = matrix()*0.5, time = 3 SECONDS)

/obj/effect/temp_visual/plasma_soul/Destroy()
	if(!beam_target)
		visible_message("<span class='notice'>[src] fades away...</span>")
	. = ..()

/obj/effect/ebeam/plasma_fist
	name = "plasma"
	mouse_opacity = MOUSE_OPACITY_ICON
	desc = "Flowing energy."

/datum/martial_art/plasma_fist/nobomb
	name = "Novice Plasma Fist"
	nobomb = TRUE

#undef TORNADO_COMBO
#undef THROWBACK_COMBO
#undef PLASMA_COMBO
