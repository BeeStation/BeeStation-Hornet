#define COOLDOWN_STUN 1200
#define COOLDOWN_DAMAGE 600
#define COOLDOWN_MEME 300
#define COOLDOWN_NONE 100

/obj/item/organ/vocal_cords //organs that are activated through speech with the :x/MODE_KEY_VOCALCORDS channel
	name = "vocal cords"
	icon_state = "appendix"
	zone = BODY_ZONE_PRECISE_MOUTH
	slot = ORGAN_SLOT_VOICE
	gender = PLURAL
	decay_factor = 0	//we don't want decaying vocal cords to somehow matter or appear on scanners since they don't do anything damaged
	healing_factor = 0
	var/list/spans = null

/obj/item/organ/vocal_cords/proc/can_speak_with() //if there is any limitation to speaking with these cords
	return TRUE

/obj/item/organ/vocal_cords/proc/speak_with(message) //do what the organ does
	return

/obj/item/organ/vocal_cords/proc/handle_speech(message) //actually say the message
	owner.say(message, spans = spans, sanitize = FALSE)

/obj/item/organ/adamantine_resonator
	name = "adamantine resonator"
	desc = "Fragments of adamantine exist in all golems, stemming from their origins as purely magical constructs. These are used to \"hear\" messages from their leaders."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_ADAMANTINE_RESONATOR
	icon_state = "adamantine_resonator"

/obj/item/organ/vocal_cords/adamantine
	name = "adamantine vocal cords"
	desc = "When adamantine resonates, it causes all nearby pieces of adamantine to resonate as well. Adamantine golems use this to broadcast messages to nearby golems."
	actions_types = list(/datum/action/item_action/organ_action/use/adamantine_vocal_cords)
	icon_state = "adamantine_cords"

/datum/action/item_action/organ_action/use/adamantine_vocal_cords/Trigger()
	if(!IsAvailable())
		return
	var/message = input(owner, "Resonate a message to all nearby golems.", "Resonate")
	if(QDELETED(src) || QDELETED(owner) || !message)
		return
	owner.say(".x[message]")

/obj/item/organ/vocal_cords/adamantine/handle_speech(message)
	var/msg = "<span class='resonate'><span class='name'>[owner.real_name]</span> <span class='message'>resonates, \"[message]\"</span></span>"
	for(var/m in GLOB.player_list)
		if(iscarbon(m))
			var/mob/living/carbon/C = m
			if(C.getorganslot(ORGAN_SLOT_ADAMANTINE_RESONATOR))
				to_chat(C, msg)
		if(isobserver(m))
			var/link = FOLLOW_LINK(m, owner)
			to_chat(m, "[link] [msg]")

//Colossus drop, forces the listeners to obey certain commands
/obj/item/organ/vocal_cords/colossus
	name = "divine vocal cords"
	desc = "They carry the voice of an ancient god."
	icon_state = "voice_of_god"
	actions_types = list(/datum/action/item_action/organ_action/colossus)
	var/next_command = 0
	var/cooldown_mod = 1
	var/base_multiplier = 1
	spans = list("colossus","yell")

/datum/action/item_action/organ_action/colossus
	name = "Voice of God"
	var/obj/item/organ/vocal_cords/colossus/cords = null

/datum/action/item_action/organ_action/colossus/New()
	..()
	cords = target

/datum/action/item_action/organ_action/colossus/IsAvailable()
	if(world.time < cords.next_command)
		return FALSE
	if(!owner)
		return FALSE
	if(isliving(owner))
		var/mob/living/L = owner
		if(!L.can_speak_vocal())
			return FALSE
	if(check_flags & AB_CHECK_CONSCIOUS)
		if(owner.stat)
			return FALSE
	return TRUE

/datum/action/item_action/organ_action/colossus/Trigger()
	. = ..()
	if(!IsAvailable())
		if(world.time < cords.next_command)
			to_chat(owner, "<span class='notice'>You must wait [DisplayTimeText(cords.next_command - world.time)] before Speaking again.</span>")
		return
	var/command = input(owner, "Speak with the Voice of God", "Command")
	if(QDELETED(src) || QDELETED(owner))
		return
	if(!command)
		return
	owner.say(".x[command]")

/obj/item/organ/vocal_cords/colossus/can_speak_with()
	if(world.time < next_command)
		to_chat(owner, "<span class='notice'>You must wait [DisplayTimeText(next_command - world.time)] before Speaking again.</span>")
		return FALSE
	if(!owner)
		return FALSE
	if(!owner.can_speak_vocal())
		to_chat(owner, "<span class='warning'>You are unable to speak!</span>")
		return FALSE
	return TRUE

/obj/item/organ/vocal_cords/colossus/handle_speech(message)
	playsound(get_turf(owner), 'sound/magic/clockwork/invoke_general.ogg', 300, 1, 5)
	return //voice of god speaks for us

/obj/item/organ/vocal_cords/colossus/speak_with(message)
	var/cooldown = voice_of_god(uppertext(message), owner, spans, base_multiplier)
	next_command = world.time + (cooldown * cooldown_mod)

//////////////////////////////////////
///////////VOICE OF GOD///////////////
//////////////////////////////////////

/proc/voice_of_god(message, mob/living/user, list/span_list, base_multiplier = 1, include_speaker = FALSE, message_admins = TRUE)
	var/cooldown = 0

	if(!user || !user.can_speak() || user.stat)
		return 0 //no cooldown

	var/log_message = uppertext(message)
	if(!span_list || !span_list.len)
		if(iscultist(user))
			span_list = list("narsiesmall")
		else if (is_servant_of_ratvar(user))
			span_list = list("ratvar")
		else
			span_list = list()

	user.say(message, spans = span_list, sanitize = FALSE)

	message = lowertext(message)
	var/list/mob/living/listeners = list()
	for(var/mob/living/L in get_hearers_in_view(8, user))
		if(L.can_hear() && !L.anti_magic_check(FALSE, TRUE) && L.stat != DEAD)
			if(L == user && !include_speaker)
				continue
			if(ishuman(L))
				var/mob/living/carbon/human/H = L
				if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
					continue
			listeners += L

	if(!listeners.len)
		cooldown = COOLDOWN_NONE
		return cooldown

	var/power_multiplier = base_multiplier

	if(user.mind)
		//Chaplains are very good at speaking with the voice of god
		if(user.mind.assigned_role == "Chaplain")
			power_multiplier *= 2
		//Command staff has authority
		if(user.mind.assigned_role in GLOB.command_positions)
			power_multiplier *= 1.4
		//Why are you speaking
		if(user.mind.assigned_role == "Mime")
			power_multiplier *= 0.5

	//Cultists are closer to their gods and are more powerful, but they'll give themselves away
	if(iscultist(user))
		power_multiplier *= 2
	else if (is_servant_of_ratvar(user))
		power_multiplier *= 2

	//Try to check if the speaker specified a name or a job to focus on
	var/list/specific_listeners = list()
	var/found_string = null

	//Get the proper job titles
	message = get_full_job_name(message)

	for(var/V in listeners)
		var/mob/living/L = V
		var/datum/antagonist/devil/devilinfo = is_devil(L)
		if(devilinfo && findtext(message, devilinfo.truename))
			var/start = findtext(message, devilinfo.truename)
			listeners = list(L) //Devil names are unique.
			power_multiplier *= 5 //if you're a devil and god himself addressed you, you fucked up
			//Cut out the name so it doesn't trigger commands
			message = copytext(message, 0, start)+copytext(message, start + length(devilinfo.truename), length(message) + 1)
			break
		else if(dd_hasprefix(message, L.real_name))
			specific_listeners += L //focus on those with the specified name
			//Cut out the name so it doesn't trigger commands
			found_string = L.real_name

		else if(dd_hasprefix(message, L.first_name()))
			specific_listeners += L //focus on those with the specified name
			//Cut out the name so it doesn't trigger commands
			found_string = L.first_name()

		else if(L.mind && L.mind.assigned_role && dd_hasprefix(message, L.mind.assigned_role))
			specific_listeners += L //focus on those with the specified job
			//Cut out the job so it doesn't trigger commands
			found_string = L.mind.assigned_role

	if(specific_listeners.len)
		listeners = specific_listeners
		power_multiplier *= (1 + (1/specific_listeners.len)) //2x on a single guy, 1.5x on two and so on
		message = copytext(message, 0, 1)+copytext(message, 1 + length(found_string), length(message) + 1)

	var/static/regex/stun_words = regex("stop|wait|stand still|hold on|halt")
	var/static/regex/knockdown_words = regex("drop|fall|trip|knockdown")
	var/static/regex/sleep_words = regex("sleep|slumber|rest")
	var/static/regex/vomit_words = regex("vomit|throw up|sick")
	var/static/regex/silence_words = regex("shut up|silence|be silent|ssh|quiet|hush")
	var/static/regex/hallucinate_words = regex("see the truth|hallucinate")
	var/static/regex/wakeup_words = regex("wake up|awaken")
	var/static/regex/heal_words = regex("live|heal|survive|mend|life|heroes never die")
	var/static/regex/hurt_words = regex("die|suffer|hurt|pain|death")
	var/static/regex/bleed_words = regex("bleed|there will be blood")
	var/static/regex/burn_words = regex("burn|ignite")
	var/static/regex/hot_words = regex("heat|hot|hell")
	var/static/regex/cold_words = regex("cold|cool down|chill|freeze")
	var/static/regex/repulse_words = regex("shoo|go away|leave me alone|begone|flee|fus ro dah|get away|repulse")
	var/static/regex/attract_words = regex("come here|come to me|get over here|attract")
	var/static/regex/whoareyou_words = regex("who are you|say your name|state your name|identify")
	var/static/regex/saymyname_words = regex("say my name|who am i|whoami")
	var/static/regex/knockknock_words = regex("knock knock")
	var/static/regex/statelaws_words = regex("state laws|state your laws")
	var/static/regex/move_words = regex("move|walk")
	var/static/regex/left_words = regex("left|west|port")
	var/static/regex/right_words = regex("right|east|starboard")
	var/static/regex/up_words = regex("up|north|fore")
	var/static/regex/down_words = regex("down|south|aft")
	var/static/regex/walk_words = regex("slow down")
	var/static/regex/run_words = regex("run")
	var/static/regex/helpintent_words = regex("help|hug")
	var/static/regex/disarmintent_words = regex("disarm")
	var/static/regex/grabintent_words = regex("grab")
	var/static/regex/harmintent_words = regex("harm|fight|punch")
	var/static/regex/throwmode_words = regex("throw|catch")
	var/static/regex/flip_words = regex("flip|rotate|revolve|roll|somersault")
	var/static/regex/speak_words = regex("speak|say something")
	var/static/regex/getup_words = regex("get up")
	var/static/regex/sit_words = regex("sit")
	var/static/regex/stand_words = regex("stand")
	var/static/regex/dance_words = regex("dance")
	var/static/regex/jump_words = regex("jump")
	var/static/regex/salute_words = regex("salute")
	var/static/regex/deathgasp_words = regex("play dead")
	var/static/regex/clap_words = regex("clap|applaud")
	var/static/regex/honk_words = regex("ho+nk") //hooooooonk
	var/static/regex/multispin_words = regex("like a record baby|right round")

	var/i = 0
	//STUN
	if(findtext(message, stun_words))
		cooldown = COOLDOWN_STUN
		for(var/V in listeners)
			var/mob/living/L = V
			L.Stun(60 * power_multiplier)

	//KNOCKDOWN
	else if(findtext(message, knockdown_words))
		cooldown = COOLDOWN_STUN
		for(var/V in listeners)
			var/mob/living/L = V
			L.Paralyze(60 * power_multiplier)

	//SLEEP
	else if((findtext(message, sleep_words)))
		cooldown = COOLDOWN_STUN
		for(var/mob/living/carbon/C in listeners)
			C.Sleeping(40 * power_multiplier)

	//VOMIT
	else if((findtext(message, vomit_words)))
		cooldown = COOLDOWN_STUN
		for(var/mob/living/carbon/C in listeners)
			C.vomit(10 * power_multiplier, distance = power_multiplier)

	//SILENCE
	else if((findtext(message, silence_words)))
		cooldown = COOLDOWN_STUN
		for(var/mob/living/carbon/C in listeners)
			if(user.mind && (user.mind.assigned_role == "Curator" || user.mind.assigned_role == "Mime"))
				power_multiplier *= 3
			C.silent += (10 * power_multiplier)

	//HALLUCINATE
	else if((findtext(message, hallucinate_words)))
		cooldown = COOLDOWN_MEME
		for(var/mob/living/carbon/C in listeners)
			new /datum/hallucination/delusion(C, TRUE, null,150 * power_multiplier,0)

	//WAKE UP
	else if((findtext(message, wakeup_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.SetSleeping(0)

	//HEAL
	else if((findtext(message, heal_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.heal_overall_damage(10 * power_multiplier, 10 * power_multiplier)

	//BRUTE DAMAGE
	else if((findtext(message, hurt_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.apply_damage(15 * power_multiplier, def_zone = BODY_ZONE_CHEST)

	//BLEED
	else if((findtext(message, bleed_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/mob/living/carbon/human/H in listeners)
			H.bleed_rate += (5 * power_multiplier)

	//FIRE
	else if((findtext(message, burn_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.adjust_fire_stacks(1 * power_multiplier)
			L.IgniteMob()

	//HOT
	else if((findtext(message, hot_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.adjust_bodytemperature(50 * power_multiplier)

	//COLD
	else if((findtext(message, cold_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.adjust_bodytemperature(-50 * power_multiplier)

	//REPULSE
	else if((findtext(message, repulse_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			var/throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(L, user)))
			L.throw_at(throwtarget, 3 * power_multiplier, 1 * power_multiplier)

	//ATTRACT
	else if((findtext(message, attract_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/L = V
			L.throw_at(get_step_towards(user,L), 3 * power_multiplier, 1 * power_multiplier)

	//WHO ARE YOU?
	else if((findtext(message, whoareyou_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			var/text = ""
			if(is_devil(L))
				var/datum/antagonist/devil/devilinfo = is_devil(L)
				text = devilinfo.truename
			else
				text = L.real_name
			addtimer(CALLBACK(L, /atom/movable/proc/say, text), 5 * i)
			i++

	//SAY MY NAME
	else if((findtext(message, saymyname_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			addtimer(CALLBACK(L, /atom/movable/proc/say, user.name), 5 * i)
			i++

	//KNOCK KNOCK
	else if((findtext(message, knockknock_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			addtimer(CALLBACK(L, /atom/movable/proc/say, "Who's there?"), 5 * i)
			i++

	//STATE LAWS
	else if((findtext(message, statelaws_words)))
		cooldown = COOLDOWN_STUN
		for(var/mob/living/silicon/S in listeners)
			S.statelaws(force = 1)

	//MOVE
	else if((findtext(message, move_words)))
		cooldown = COOLDOWN_MEME
		var/direction
		if(findtext(message, up_words))
			direction = NORTH
		else if(findtext(message, down_words))
			direction = SOUTH
		else if(findtext(message, left_words))
			direction = WEST
		else if(findtext(message, right_words))
			direction = EAST
		for(var/iter in 1 to 5 * power_multiplier)
			for(var/V in listeners)
				var/mob/living/L = V
				addtimer(CALLBACK(GLOBAL_PROC, .proc/_step, L, direction? direction : pick(GLOB.cardinals)), 10 * (iter - 1))

	//WALK
	else if((findtext(message, walk_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.m_intent != MOVE_INTENT_WALK)
				L.toggle_move_intent()

	//RUN
	else if((findtext(message, run_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.m_intent != MOVE_INTENT_RUN)
				L.toggle_move_intent()

	//HELP INTENT
	else if((findtext(message, helpintent_words)))
		cooldown = COOLDOWN_MEME
		for(var/mob/living/carbon/human/H in listeners)
			addtimer(CALLBACK(H, /mob/verb/a_intent_change, INTENT_HELP), i * 2)
			addtimer(CALLBACK(H, /mob/proc/click_random_mob), i * 2)
			i++

	//DISARM INTENT
	else if((findtext(message, disarmintent_words)))
		cooldown = COOLDOWN_MEME
		for(var/mob/living/carbon/human/H in listeners)
			addtimer(CALLBACK(H, /mob/verb/a_intent_change, INTENT_DISARM), i * 2)
			addtimer(CALLBACK(H, /mob/proc/click_random_mob), i * 2)
			i++

	//GRAB INTENT
	else if((findtext(message, grabintent_words)))
		cooldown = COOLDOWN_MEME
		for(var/mob/living/carbon/human/H in listeners)
			addtimer(CALLBACK(H, /mob/verb/a_intent_change, INTENT_GRAB), i * 2)
			addtimer(CALLBACK(H, /mob/proc/click_random_mob), i * 2)
			i++

	//HARM INTENT
	else if((findtext(message, harmintent_words)))
		cooldown = COOLDOWN_MEME
		for(var/mob/living/carbon/human/H in listeners)
			addtimer(CALLBACK(H, /mob/verb/a_intent_change, INTENT_HARM), i * 2)
			addtimer(CALLBACK(H, /mob/proc/click_random_mob), i * 2)
			i++

	//THROW/CATCH
	else if((findtext(message, throwmode_words)))
		cooldown = COOLDOWN_MEME
		for(var/mob/living/carbon/C in listeners)
			C.throw_mode_on()

	//FLIP
	else if((findtext(message, flip_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			L.emote("flip")

	//SPEAK
	else if((findtext(message, speak_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			addtimer(CALLBACK(L, /atom/movable/proc/say, pick_list_replacements(BRAIN_DAMAGE_FILE, "brain_damage")), 5 * i)
			i++

	//GET UP
	else if((findtext(message, getup_words)))
		cooldown = COOLDOWN_DAMAGE //because stun removal
		for(var/V in listeners)
			var/mob/living/L = V
			L.set_resting(FALSE)
			L.SetAllImmobility(0)

	//SIT
	else if((findtext(message, sit_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			for(var/obj/structure/chair/chair in get_turf(L))
				chair.buckle_mob(L)
				break

	//STAND UP
	else if((findtext(message, stand_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			if(L.buckled && istype(L.buckled, /obj/structure/chair))
				L.buckled.unbuckle_mob(L)

	//DANCE
	else if((findtext(message, dance_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			addtimer(CALLBACK(L, /mob/living/.proc/emote, "dance"), 5 * i)
			i++

	//JUMP
	else if((findtext(message, jump_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			if(prob(25))
				addtimer(CALLBACK(L, /atom/movable/proc/say, "HOW HIGH?!!"), 5 * i)
			addtimer(CALLBACK(L, /mob/living/.proc/emote, "jump"), 5 * i)
			i++

	//SALUTE
	else if((findtext(message, salute_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			addtimer(CALLBACK(L, /mob/living/.proc/emote, "salute"), 5 * i)
			i++

	//PLAY DEAD
	else if((findtext(message, deathgasp_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			addtimer(CALLBACK(L, /mob/living/.proc/emote, "deathgasp"), 5 * i)
			i++

	//PLEASE CLAP
	else if((findtext(message, clap_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			addtimer(CALLBACK(L, /mob/living/.proc/emote, "clap"), 5 * i)
			i++

	//HONK
	else if((findtext(message, honk_words)))
		cooldown = COOLDOWN_MEME
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(user), 'sound/items/bikehorn.ogg', 300, 1), 25)
		if(user.mind?.assigned_role == "Clown")
			for(var/mob/living/carbon/C in listeners)
				C.slip(140 * power_multiplier)
			cooldown = COOLDOWN_MEME

	//RIGHT ROUND
	else if((findtext(message, multispin_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/L = V
			L.SpinAnimation(speed = 10, loops = 5)

	//CITADEL CHANGES
	//ORGASM
	else if((findtext(message, orgasm_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/carbon/human/H = V
			
			if(H.client && H.client.prefs && H.client.prefs.cit_toggles & HYPNO) // probably a redundant check but for good measure
				H.mob_climax(forced_climax=TRUE)

	//DAB
	else if((findtext(message, dab_words)))
		cooldown = COOLDOWN_DAMAGE
		for(var/V in listeners)
			var/mob/living/M = V
			M.say("*dab")

	//SNAP
	else if((findtext(message, snap_words)))
		cooldown = COOLDOWN_MEME
		for(var/V in listeners)
			var/mob/living/M = V
			M.say("*snap")

	//BWOINK
	else if((findtext(message, bwoink_words)))
		cooldown = COOLDOWN_MEME
		addtimer(CALLBACK(GLOBAL_PROC, .proc/playsound, get_turf(user), 'sound/effects/adminhelp.ogg', 300, 1), 25)
	//END CITADEL CHANGES

	else
		cooldown = COOLDOWN_NONE

	if(message_admins)
		message_admins("[ADMIN_LOOKUPFLW(user)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
	log_game("[key_name(user)] has said '[log_message]' with a Voice of God, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
	SSblackbox.record_feedback("tally", "voice_of_god", 1, log_message)

	return cooldown


//Heavily modified voice of god code
/obj/item/organ/vocal_cords/velvet
	name = "Velvet chords"
	desc = "The voice spoken from these just make you want to drift off, sleep and obey."
	icon_state = "velvet_chords"
	actions_types = list(/datum/action/item_action/organ_action/velvet)
	spans = list("velvet")

/datum/action/item_action/organ_action/velvet
	name = "Velvet chords"
	var/obj/item/organ/vocal_cords/velvet/cords = null

/datum/action/item_action/organ_action/velvet/New()
	..()
	cords = target

/datum/action/item_action/organ_action/velvet/IsAvailable()
	return TRUE

/datum/action/item_action/organ_action/velvet/Trigger()
	. = ..()
	var/command = input(owner, "Speak in a sultry tone", "Command")
	if(QDELETED(src) || QDELETED(owner))
		return
	if(!command)
		return
	owner.say(".x[command]")

/obj/item/organ/vocal_cords/velvet/can_speak_with()
	return TRUE

/obj/item/organ/vocal_cords/velvet/handle_speech(message) //actually say the message
	owner.say(message, spans = spans, sanitize = FALSE)
	velvetspeech(message, owner, 1)

//////////////////////////////////////
///////////FermiChem//////////////////
//////////////////////////////////////
//Removed span_list from input arguments.
/proc/velvetspeech(message, mob/living/user, base_multiplier = 1, message_admins = FALSE, debug = FALSE)

	if(!user || !user.can_speak() || user.stat)
		return 0 //no cooldown

	var/log_message = message

	//FIND THRALLS
	message = lowertext(message)
	var/list/mob/living/listeners = list()
	for(var/mob/living/L in get_hearers_in_view(8, user))
		if(L.can_hear() && !L.anti_magic_check(FALSE, TRUE) && L.stat != DEAD)
			if(L.has_status_effect(/datum/status_effect/chem/enthrall))//Check to see if they have the status
				var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)//Check to see if pet is on cooldown from last command and if the master is right
				if(E.master != user)
					continue
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
						continue

				if (E.cooldown > 0)//If they're on cooldown you can't give them more commands.
					continue
				listeners += L

	if(!listeners.len)
		return 0

	//POWER CALCULATIONS

	var/power_multiplier = base_multiplier

	// Not sure I want to give extra power to anyone at the moment...? We'll see how it turns out
	if(user.mind)
		//Chaplains are very good at indoctrinating
		if(user.mind.assigned_role == "Chaplain")
			power_multiplier *= 1.2
		//Command staff has authority
		if(user.mind.assigned_role in GLOB.command_positions)
			power_multiplier *= 1.1
		//Why are you speaking
		if(user.mind.assigned_role == "Mime")
			power_multiplier *= 0.5

	//Cultists are closer to their gods and are better at indoctrinating
	if(iscultist(user))
		power_multiplier *= 1.2
	else if (is_servant_of_ratvar(user))
		power_multiplier *= 1.2
	else if (is_devil(user))//The devil is supposed to be seductive, right?
		power_multiplier *= 1.2

	//range = 0.5 - 1.4~
	//most cases = 1

	//Try to check if the speaker specified a name or a job to focus on
	var/list/specific_listeners = list()
	var/found_string = null

	//Get the proper job titles
	message = get_full_job_name(message)

	for(var/V in listeners)
		var/mob/living/L = V
		if(dd_hasprefix(message, L.real_name))
			specific_listeners += L //focus on those with the specified name
			//Cut out the name so it doesn't trigger commands
			found_string = L.real_name
			power_multiplier += 0.5

		else if(dd_hasprefix(message, L.first_name()))
			specific_listeners += L //focus on those with the specified name
			//Cut out the name so it doesn't trigger commands
			found_string = L.first_name()
			power_multiplier += 0.5

		else if(L.mind && L.mind.assigned_role && dd_hasprefix(message, L.mind.assigned_role))
			specific_listeners += L //focus on those with the specified job
			//Cut out the job so it doesn't trigger commands
			found_string = L.mind.assigned_role
			power_multiplier += 0.25

	if(specific_listeners.len)
		listeners = specific_listeners
		//power_multiplier *= (1 + (1/specific_listeners.len)) //Put this is if it becomes OP, power is judged internally on a thrall, so shouldn't be nessicary.
		message = copytext(message, 0, 1)+copytext(message, 1 + length(found_string), length(message) + 1)//I have no idea what this does

	var/obj/item/organ/tongue/T = user.getorganslot(ORGAN_SLOT_TONGUE)
	if (T.name == "fluffy tongue") //If you sound hillarious, it's hard to take you seriously. This is a way for other players to combat/reduce their effectiveness.
		power_multiplier *= 0.75

	if(debug == TRUE)
		to_chat(world, "[user]'s power is [power_multiplier].")

	//Mixables
	var/static/regex/enthral_words = regex("relax|obey|love|serve|so easy|ara ara")
	var/static/regex/reward_words = regex("good boy|good girl|good pet|good job|splendid|jolly good|bloody brilliant")
	var/static/regex/punish_words = regex("bad boy|bad girl|bad pet|bad job|spot of bother|gone and done it now|blast it|buggered it up")
	//phase 0
	var/static/regex/saymyname_words = regex("say my name|who am i|whoami")
	var/static/regex/wakeup_words = regex("revert|awaken|snap|attention")
	//phase1
	var/static/regex/petstatus_words = regex("how are you|what is your status|are you okay")
	var/static/regex/silence_words = regex("shut up|silence|be silent|ssh|quiet|hush")
	var/static/regex/speak_words = regex("talk to me|speak")
	var/static/regex/antiresist_words = regex("unable to resist|give in|stop being difficult")//useful if you think your target is resisting a lot
	var/static/regex/resist_words = regex("resist|snap out of it|fight")//useful if two enthrallers are fighting
	var/static/regex/forget_words = regex("forget|muddled|awake and forget")
	var/static/regex/attract_words = regex("come here|come to me|get over here|attract")
	//phase 2
	var/static/regex/orgasm_words = regex("cum|orgasm|climax|squirt|heyo") //wah, lewd
	var/static/regex/awoo_words = regex("howl|awoo|bark")
	var/static/regex/nya_words = regex("nya|meow|mewl")
	var/static/regex/sleep_words = regex("sleep|slumber|rest")
	var/static/regex/strip_words = regex("strip|derobe|nude|at ease|suit off")
	var/static/regex/walk_words = regex("slow down|walk")
	var/static/regex/run_words = regex("run|speed up")
	var/static/regex/liedown_words = regex("lie down")
	var/static/regex/knockdown_words = regex("drop|fall|trip|knockdown|kneel|army crawl")
	//phase 3
	var/static/regex/statecustom_words = regex("state triggers|state your triggers")
	var/static/regex/custom_words = regex("new trigger|listen to me")
	var/static/regex/custom_words_words = regex("speak|echo|shock|cum|kneel|strip|trance")//What a descriptive name!
	var/static/regex/custom_echo = regex("obsess|fills your mind|loop")
	var/static/regex/instill_words = regex("feel|entice|overwhel")
	var/static/regex/recognise_words = regex("recognise me|did you miss me?")
	var/static/regex/objective_words = regex("new objective|obey this command|unable to resist|compulsed|word from hq")
	var/static/regex/heal_words = regex("live|heal|survive|mend|life|pets never die|heroes never die")
	var/static/regex/stun_words = regex("stop|wait|stand still|hold on|halt")
	var/static/regex/hallucinate_words = regex("get high|hallucinate|trip balls")
	var/static/regex/hot_words = regex("heat|hot|hell")
	var/static/regex/cold_words = regex("cold|cool down|chill|freeze")
	var/static/regex/getup_words = regex("get up|hop to it")
	var/static/regex/pacify_words = regex("docile|complaisant|friendly|pacifist")
	var/static/regex/charge_words = regex("charge|oorah|attack")

	var/distancelist = list(2,2,1.5,1.3,1.15,1,0.8,0.6,0.5,0.25)

	//CALLBACKS ARE USED FOR MESSAGES BECAUSE SAY IS HANDLED AFTER THE PROCESSING.

	//Tier 1
	//ENTHRAL mixable (works I think)
	if(findtext(message, enthral_words))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			power_multiplier *= distancelist[get_dist(user, V)+1]
			if(L == user)
				continue
			if(length(message))
				E.enthrallTally += (power_multiplier*(((length(message))/200) + 1)) //encourage players to say more than one word.
			else
				E.enthrallTally += power_multiplier*1.25 //thinking about it, I don't know how this can proc
			if(E.lewd)
				addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='nicegreen'><i><b>[E.enthrallGender] is so nice to listen to.</b></i></span>"), 5)
			E.cooldown += 1

	//REWARD mixable works
	if(findtext(message, reward_words))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			power_multiplier *= distancelist[get_dist(user, V)+1]
			if(L == user)
				continue
			if (E.lewd)
				addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='love'>[E.enthrallGender] has praised me!!</span>"), 5)
				if(HAS_TRAIT(L, TRAIT_MASO))
					E.enthrallTally -= power_multiplier
					E.resistanceTally += power_multiplier
					E.cooldown += 1
			else
				addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='nicegreen'><b><i>I've been praised for doing a good job!</b></i></span>"), 5)
			E.resistanceTally -= power_multiplier
			E.enthrallTally += power_multiplier
			var/descmessage = "<span class='love'><i>[(E.lewd?"I feel so happy! I'm a good pet who [E.enthrallGender] loves!":"I did a good job!")]</i></span>"
			SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "enthrallpraise", /datum/mood_event/enthrallpraise, descmessage)
			E.cooldown += 1

	//PUNISH mixable  works
	else if(findtext(message, punish_words))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			var/descmessage = "[(E.lewd?"I've failed [E.enthrallGender]... What a bad, bad pet!":"I did a bad job...")]"
			if(L == user)
				continue
			if (E.lewd)
				if(HAS_TRAIT(L, TRAIT_MASO))
					if(ishuman(L))
						var/mob/living/carbon/human/H = L
						H.adjust_arousal(3*power_multiplier,maso = TRUE)
					descmessage += "And yet, it feels so good..!</span>" //I don't really understand masco, is this the right sort of thing they like?
					E.enthrallTally += power_multiplier
					E.resistanceTally -= power_multiplier
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='love'>I've let [E.enthrallGender] down...!</b></span>"), 5)
				else
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='warning'>I've let [E.enthrallGender] down...</b></span>"), 5)
			else
				addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='warning'>I've failed [E.master]...</b></span>"), 5)
				E.resistanceTally += power_multiplier
				E.enthrallTally += power_multiplier
				E.cooldown += 1
			SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "enthrallscold", /datum/mood_event/enthrallscold, descmessage)
			E.cooldown += 1



	//teir 0
	//SAY MY NAME works
	if((findtext(message, saymyname_words)))
		for(var/V in listeners)
			var/mob/living/carbon/C = V
			var/datum/status_effect/chem/enthrall/E = C.has_status_effect(/datum/status_effect/chem/enthrall)
			REMOVE_TRAIT(C, TRAIT_MUTE, "enthrall")
			C.silent = 0
			if(E.lewd)
				addtimer(CALLBACK(C, /atom/movable/proc/say, "[E.enthrallGender]"), 5)
			else
				addtimer(CALLBACK(C, /atom/movable/proc/say, "[E.master]"), 5)

	//WAKE UP
	else if((findtext(message, wakeup_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			L.SetSleeping(0)//Can you hear while asleep?
			switch(E.phase)
				if(0)
					E.phase = 3
					E.status = null
					user.emote("snap")
					if(E.lewd)
						addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='big warning'>The snapping of your [E.enthrallGender]'s fingers brings you back to your enthralled state, obedient and ready to serve.</b></span>"), 5)
					else
						addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='big warning'>The snapping of [E.master]'s fingers brings you back to being under their influence.</b></span>"), 5)
					to_chat(user, "<span class='notice'><i>You wake up [L]!</i></span>")

	//tier 1

	//PETSTATUS i.e. how they are
	else if((findtext(message, petstatus_words)))
		for(var/V in listeners)
			var/mob/living/carbon/human/H = V
			var/datum/status_effect/chem/enthrall/E = H.has_status_effect(/datum/status_effect/chem/enthrall)
			REMOVE_TRAIT(H, TRAIT_MUTE, "enthrall")
			var/speaktrigger = ""
			//phase
			switch(E.phase)
				if(0)
					continue
				if(1)
					addtimer(CALLBACK(H, /atom/movable/proc/say, "I feel happy being with you."), 5)
					continue
				if(2)
					speaktrigger += "[(E.lewd?"I think I'm in love with you... ":"I find you really inspirational, ")]" //'
				if(3)
					speaktrigger += "[(E.lewd?"I'm devoted to being your pet":"I'm commited to following your cause!")]! "
				if(4)
					speaktrigger += "[(E.lewd?"You are my whole world and all of my being belongs to you, ":"I cannot think of anything else but aiding your cause, ")] "//Redflags!!

			//mood
			var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
			switch(mood.sanity)
				if(SANITY_GREAT to INFINITY)
					speaktrigger += "I'm beyond elated!! " //did you mean byond elated? hohoho
				if(SANITY_NEUTRAL to SANITY_GREAT)
					speaktrigger += "I'm really happy! "
				if(SANITY_DISTURBED to SANITY_NEUTRAL)
					speaktrigger += "I'm a little sad, "
				if(SANITY_UNSTABLE to SANITY_DISTURBED)
					speaktrigger += "I'm really upset, "
				if(SANITY_CRAZY to SANITY_UNSTABLE)
					speaktrigger += "I'm about to fall apart without you! "
				if(SANITY_INSANE to SANITY_CRAZY)
					speaktrigger += "Hold me, please.. "

			//Withdrawal
			switch(E.withdrawalTick)
				if(10 to 36) //denial
					speaktrigger += "I missed you, "
				if(36 to 66) //barganing
					speaktrigger += "I missed you, but I knew you'd come back for me! "
				if(66 to 90) //anger
					speaktrigger += "I couldn't take being away from you like that, "
				if(90 to 140) //depression
					speaktrigger += "I was so scared you'd never come back, "
				if(140 to INFINITY) //acceptance
					speaktrigger += "I'm hurt that you left me like that... I felt so alone... "

			//hunger
			switch(H.nutrition)
				if(0 to NUTRITION_LEVEL_STARVING)
					speaktrigger += "I'm famished, please feed me..! "
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					speaktrigger += "I'm so hungry... "
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					speaktrigger += "I'm hungry, "
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					speaktrigger += "I'm sated, "
				if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
					speaktrigger += "I've a full belly! "
				if(NUTRITION_LEVEL_FULL to INFINITY)
					speaktrigger += "I'm fat... "

			//health
			switch(H.health)
				if(100 to INFINITY)
					speaktrigger += "I feel fit, "
				if(80 to 99)
					speaktrigger += "I ache a little bit, "
				if(40 to 80)
					speaktrigger += "I'm really hurt, "
				if(0 to 40)
					speaktrigger += "I'm in a lot of pain, help! "
				if(-INFINITY to 0)
					speaktrigger += "I'm barely concious and in so much pain, please help me! "
			//toxin
			switch(H.getToxLoss())
				if(10 to 30)
					speaktrigger += "I feel a bit queasy... "
				if(30 to 60)
					speaktrigger += "I feel nauseous... "
				if(60 to INFINITY)
					speaktrigger += "My head is pounding and I feel like I'm going to be sick... "
			//oxygen
			if (H.getOxyLoss() >= 25)
				speaktrigger += "I can't breathe! "
			//blind
			if (HAS_TRAIT(H, TRAIT_BLIND))
				speaktrigger += "I can't see! "
			//deaf..?
			if (HAS_TRAIT(H, TRAIT_DEAF))//How the heck you managed to get here I have no idea, but just in case!
				speaktrigger += "I can barely hear you! "
			//And the brain damage. And the brain damage. And the brain damage. And the brain damage. And the brain damage.
			switch(H.getOrganLoss(ORGAN_SLOT_BRAIN))
				if(20 to 40)
					speaktrigger += "I have a mild head ache, "
				if(40 to 80)
					speaktrigger += "I feel disorentated and confused, "
				if(80 to 120)
					speaktrigger += "My head feels like it's about to explode, "
				if(120 to 160)
					speaktrigger += "You are the only thing keeping my mind sane, "
				if(160 to INFINITY)
					speaktrigger += "I feel like I'm on the brink of losing my mind, "

			//collar
			if(istype(H.wear_neck, /obj/item/clothing/neck/petcollar) && E.lewd)
				speaktrigger += "I love the collar you gave me, "
			//End
			if(E.lewd)
				speaktrigger += "[E.enthrallGender]!"
			else
				speaktrigger += "[user.first_name()]!"
			//say it!
			addtimer(CALLBACK(H, /atom/movable/proc/say, "[speaktrigger]"), 5)
			E.cooldown += 1

	//SILENCE
	else if((findtext(message, silence_words)))
		for(var/mob/living/carbon/C in listeners)
			var/datum/status_effect/chem/enthrall/E = C.has_status_effect(/datum/status_effect/chem/enthrall)
			power_multiplier *= distancelist[get_dist(user, C)+1]
			if (E.phase >= 3) //If target is fully enthralled,
				ADD_TRAIT(C, TRAIT_MUTE, "enthrall")
			else
				C.silent += ((10 * power_multiplier) * E.phase)
			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, C, "<span class='notice'>You are unable to speak!</b></span>"), 5)
			to_chat(user, "<span class='notice'><i>You silence [C].</i></span>")
			E.cooldown += 3

	//SPEAK
	else if((findtext(message, speak_words)))//fix
		for(var/mob/living/carbon/C in listeners)
			var/datum/status_effect/chem/enthrall/E = C.has_status_effect(/datum/status_effect/chem/enthrall)
			REMOVE_TRAIT(C, TRAIT_MUTE, "enthrall")
			C.silent = 0
			E.cooldown += 3
			to_chat(user, "<span class='notice'><i>You [(E.lewd?"allow [C] to speak again":"encourage [C] to speak again")].</i></span>")


	//Antiresist
	else if((findtext(message, antiresist_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			E.status = "Antiresist"
			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='big warning'>Your mind clouds over, as you find yourself unable to resist!</b></span>"), 5)
			E.statusStrength = (1 * power_multiplier * E.phase)
			E.cooldown += 15//Too short? yes, made 15
			to_chat(user, "<span class='notice'><i>You frustrate [L]'s attempts at resisting.</i></span>")

	//RESIST
	else if((findtext(message, resist_words)))
		for(var/mob/living/carbon/C in listeners)
			var/datum/status_effect/chem/enthrall/E = C.has_status_effect(/datum/status_effect/chem/enthrall)
			power_multiplier *= distancelist[get_dist(user, C)+1]
			E.deltaResist += (power_multiplier)
			E.owner_resist()
			E.cooldown += 2
			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, C, "<span class='notice'>You are spurred into resisting from [user]'s words!'</b></span>"), 5)
			to_chat(user, "<span class='notice'><i>You spark resistance in [C].</i></span>")

	//FORGET (A way to cancel the process)
	else if((findtext(message, forget_words)))
		for(var/mob/living/carbon/C in listeners)
			var/datum/status_effect/chem/enthrall/E = C.has_status_effect(/datum/status_effect/chem/enthrall)
			if(E.phase == 4)
				addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, C, "<span class='warning'>You're unable to forget about [(E.lewd?"the dominating presence of [E.enthrallGender]":"[E.master]")]!</b></span>"), 5)
				continue
			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, C, "<span class='warning'>You wake up, forgetting everything that just happened. You must've dozed off..? How embarassing!</b></span>"), 5)
			C.Sleeping(50)
			switch(E.phase)
				if(1 to 2)
					E.phase = -1
					to_chat(C, "<span class='big warning'>You have no recollection of being enthralled by [E.master]!</b></span>")
					to_chat(user, "<span class='notice'><i>You revert [C] back to their state before enthrallment.</i></span>")
				if(3)
					E.phase = 0
					E.cooldown = 0
					if(E.lewd)
						addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, C, "<span class='big warning'>You revert to yourself before being enthralled by your [E.enthrallGender], with no memory of what happened.</b></span>"), 5)
					else
						addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, C, "<span class='big warning'>You revert to who you were before, with no memory of what happened with [E.master].</b></span>"), 5)
					to_chat(user, "<span class='notice'><i>You put [C] into a sleeper state, ready to turn them back at the snap of your fingers.</i></span>")

	//ATTRACT
	else if((findtext(message, attract_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			L.throw_at(get_step_towards(user,L), 3 * power_multiplier, 1 * power_multiplier)
			E.cooldown += 3
			addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='notice'>You are drawn towards [user]!</b></span>"), 5)
			to_chat(user, "<span class='notice'><i>You draw [L] towards you!</i></span>")


	//teir 2

	/* removed for now
	//ORGASM
	else if((findtext(message, orgasm_words)))
		for(var/V in listeners)
			var/mob/living/carbon/human/H = V
			var/datum/status_effect/chem/enthrall/E = H.has_status_effect(/datum/status_effect/chem/enthrall)
			if(E.phase > 1)
				if(E.lewd) // probably a redundant check but for good measure
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, H, "<span class='love'>Your [E.enthrallGender] pushes you over the limit, overwhelming your body with pleasure.</b></span>"), 5)
					H.mob_climax(forced_climax=TRUE)
					H.SetStun(20)
					E.resistanceTally = 0 //makes resistance 0, but resets arousal, resistance buildup is faster unaroused (massively so).
					E.enthrallTally += power_multiplier
					E.cooldown += 6
				else
					H.throw_at(get_step_towards(user,H), 3 * power_multiplier, 1 * power_multiplier)
	*/


	//awoo
	else if((findtext(message, awoo_words)))
		for(var/V in listeners)
			var/mob/living/carbon/human/H = V
			var/datum/status_effect/chem/enthrall/E = H.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(2 to INFINITY)
					H.say("*awoo")
					E.cooldown += 1

	//Nya
	else if((findtext(message, nya_words)))
		for(var/V in listeners)
			var/mob/living/carbon/human/H = V
			var/datum/status_effect/chem/enthrall/E = H.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(2 to INFINITY)
					playsound(get_turf(H), pick('sound/effects/meow1.ogg', 'modular_citadel/sound/voice/nya.ogg'), 50, 1, -1) //I'm very tempted to write a Fermis clause that makes them merowr.ogg if it's me. But, I also don't think snowflakism is okay. I would've gotten away for it too, if it wern't for my morals.
					H.emote("me", EMOTE_VISIBLE, "lets out a nya!")
					E.cooldown += 1

	//SLEEP
	else if((findtext(message, sleep_words)))
		for(var/mob/living/carbon/C in listeners)
			var/datum/status_effect/chem/enthrall/E = C.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(2 to INFINITY)
					C.Sleeping(45 * power_multiplier)
					E.cooldown += 10
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, C, "<span class='notice'>Drowsiness suddenly overwhelms you as you fall asleep!</b></span>"), 5)
					to_chat(user, "<span class='notice'><i>You send [C] to sleep.</i></span>")

	//STRIP
	else if((findtext(message, strip_words)))
		for(var/V in listeners)
			var/mob/living/carbon/human/H = V
			var/datum/status_effect/chem/enthrall/E = H.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(2 to INFINITY)
					var/items = H.get_contents()
					for(var/obj/item/W in items)
						if(W == H.wear_suit)
							H.dropItemToGround(W, TRUE)
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, H, "<span class='[(E.lewd?"love":"warning")]'>Before you can even think about it, you quickly remove your clothes in response to [(E.lewd?"your [E.enthrallGender]'s command'":"[E.master]'s directive'")].</b></span>"), 5)
					E.cooldown += 10

	//WALK
	else if((findtext(message, walk_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(2 to INFINITY)
					if(L.m_intent != MOVE_INTENT_WALK)
						L.toggle_move_intent()
						E.cooldown += 1
						addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='notice'>You slow down to a walk.</b></span>"), 5)
						to_chat(user, "<span class='notice'><i>You encourage [L] to slow down.</i></span>")

	//RUN
	else if((findtext(message, run_words)))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(2 to INFINITY)
					if(L.m_intent != MOVE_INTENT_RUN)
						L.toggle_move_intent()
						E.cooldown += 1
						addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='notice'>You speed up into a jog!</b></span>"), 5)
						to_chat(user, "<span class='notice'><i>You encourage [L] to pick up the pace!</i></span>")

	//LIE DOWN
	else if(findtext(message, liedown_words))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(2 to INFINITY)
					L.lay_down()
					E.cooldown += 10
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "[(E.lewd?"<span class='love'>You eagerly lie down!":"<span class='notice'>You suddenly lie down!")]</b></span>"), 5)
					to_chat(user, "<span class='notice'><i>You encourage [L] to lie down.</i></span>")

	//KNOCKDOWN
	else if(findtext(message, knockdown_words))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(2 to INFINITY)
					L.Knockdown(30 * power_multiplier * E.phase)
					E.cooldown += 8
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='notice'>You suddenly drop to the ground!</b></span>"), 5)
					to_chat(user, "<span class='notice'><i>You encourage [L] to drop down to the ground.</i></span>")

	//tier3

	//STATE TRIGGERS
	else if((findtext(message, statecustom_words)))//doesn't work
		for(var/V in listeners)
			var/mob/living/carbon/C = V
			var/datum/status_effect/chem/enthrall/E = C.has_status_effect(/datum/status_effect/chem/enthrall)
			if (E.phase == 3)
				var/speaktrigger = ""
				C.emote("me", EMOTE_VISIBLE, "whispers something quietly.")
				if (get_dist(user, C) > 1)//Requires user to be next to their pet.
					to_chat(user, "<span class='warning'>You need to be next to your pet to hear them!</b></span>")
					continue
				for (var/trigger in E.customTriggers)
					speaktrigger += "[trigger], "
				to_chat(user, "<b>[C]</b> whispers, \"<i>[speaktrigger] are my triggers.</i>\"")//So they don't trigger themselves!
				addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, C, "<span class='notice'>You whisper your triggers to [(E.lewd?"Your [E.enthrallGender]":"[E.master]")].</span>"), 5)


	//CUSTOM TRIGGERS
	else if((findtext(message, custom_words)))
		for(var/V in listeners)
			var/mob/living/carbon/human/H = V
			var/datum/status_effect/chem/enthrall/E = H.has_status_effect(/datum/status_effect/chem/enthrall)
			if(E.phase == 3)
				if (get_dist(user, H) > 1)//Requires user to be next to their pet.
					to_chat(user, "<span class='warning'>You need to be next to your pet to give them a new trigger!</b></span>")
					continue
				if(!E.lewd)
					to_chat(user, "<span class='warning'>[H] seems incapable of being implanted with triggers.</b></span>")
					continue
				else
					user.emote("me", EMOTE_VISIBLE, "puts their hands upon [H.name]'s head and looks deep into their eyes, whispering something to them.")
					user.SetStun(1000)//Hands are handy, so you have to stay still
					H.SetStun(1000)
					if (E.mental_capacity >= 5)
						var/trigger = html_decode(stripped_input(user, "Enter the trigger phrase", MAX_MESSAGE_LEN))
						var/custom_words_words_list = list("Speak", "Echo", "Shock", "Cum", "Kneel", "Strip", "Trance", "Cancel")
						var/trigger2 = input(user, "Pick an effect", "Effects") in custom_words_words_list
						trigger2 = lowertext(trigger2)
						if ((findtext(trigger2, custom_words_words)))
							if (trigger2 == "speak" || trigger2 == "echo")
								var/trigger3 = html_decode(stripped_input(user, "Enter the phrase spoken. Abusing this to self antag is bannable.", MAX_MESSAGE_LEN))
								E.customTriggers[trigger] = list(trigger2, trigger3)
								log_game("FERMICHEM: [H] has been implanted by [user] with [trigger], triggering [trigger2], to send [trigger3].")
								if(findtext(trigger3, "admin"))
									message_admins("FERMICHEM: [user] maybe be trying to abuse MKUltra by implanting by [H] with [trigger], triggering [trigger2], to send [trigger3].")
							else
								E.customTriggers[trigger] = trigger2
								log_game("FERMICHEM: [H] has been implanted by [user] with [trigger], triggering [trigger2].")
							E.mental_capacity -= 5
							addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, H, "<span class='notice'>[(E.lewd?"your [E.enthrallGender]":"[E.master]")] whispers you a new trigger.</span>"), 5)
							to_chat(user, "<span class='notice'><i>You sucessfully set the trigger word [trigger] in [H]</i></span>")
						else
							to_chat(user, "<span class='warning'>Your pet looks at you confused, it seems they don't understand that effect!</b></span>")
					else
						to_chat(user, "<span class='warning'>Your pet looks at you with a vacant blase expression, you don't think you can program anything else into them</b></span>")
					user.SetStun(0)
					H.SetStun(0)

	//CUSTOM ECHO
	else if((findtext(message, custom_echo)))
		for(var/V in listeners)
			var/mob/living/carbon/human/H = V
			var/datum/status_effect/chem/enthrall/E = H.has_status_effect(/datum/status_effect/chem/enthrall)
			if(E.phase == 3)
				if (get_dist(user, H) > 1)//Requires user to be next to their pet.
					to_chat(user, "<span class='warning'>You need to be next to your pet to give them a new echophrase!</b></span>")
					continue
				if(!E.lewd)
					to_chat(user, "<span class='warning'>[H] seems incapable of being implanted with an echoing phrase.</b></span>")
					continue
				else
					user.emote("me", EMOTE_VISIBLE, "puts their hands upon [H.name]'s head and looks deep into their eyes, whispering something to them.")
					user.SetStun(1000)//Hands are handy, so you have to stay still
					H.SetStun(1000)
					var/trigger = stripped_input(user, "Enter the loop phrase", MAX_MESSAGE_LEN)
					var/customSpan = list("Notice", "Warning", "Hypnophrase", "Love", "Velvet")
					var/trigger2 = input(user, "Pick the style", "Style") in customSpan
					trigger2 = lowertext(trigger2)
					E.customEcho = trigger
					E.customSpan = trigger2
					user.SetStun(0)
					H.SetStun(0)
					to_chat(user, "<span class='notice'><i>You sucessfully set an echoing phrase in [H]</i></span>")

	//CUSTOM OBJECTIVE
	else if((findtext(message, objective_words)))
		for(var/V in listeners)
			var/mob/living/carbon/human/H = V
			var/datum/status_effect/chem/enthrall/E = H.has_status_effect(/datum/status_effect/chem/enthrall)
			if(E.phase == 3)
				if (get_dist(user, H) > 1)//Requires user to be next to their pet.
					to_chat(user, "<span class='warning'>You need to be next to your pet to give them a new objective!</b></span>")
					continue
				else
					user.emote("me", EMOTE_VISIBLE, "puts their hands upon [H.name]'s head and looks deep into their eyes, whispering something to them.'")
					user.SetStun(1000)//So you can't run away!
					H.SetStun(1000)
					if (E.mental_capacity >= 200)
						var/datum/objective/brainwashing/objective = stripped_input(user, "Add an objective to give your pet.", MAX_MESSAGE_LEN)
						if(!LAZYLEN(objective))
							to_chat(user, "<span class='warning'>You can't give your pet an objective to do nothing!</b></span>")
							continue
						//Pets don't understand harm
						objective = replacetext(lowertext(objective), "kill", "hug")
						objective = replacetext(lowertext(objective), "murder", "cuddle")
						objective = replacetext(lowertext(objective), "harm", "snuggle")
						objective = replacetext(lowertext(objective), "decapitate", "headpat")
						objective = replacetext(lowertext(objective), "strangle", "meow at")
						objective = replacetext(lowertext(objective), "suicide", "self-love")
						message_admins("[H] has been implanted by [user] with the objective [objective].")
						log_game("FERMICHEM: [H] has been implanted by [user] with the objective [objective] via MKUltra.")
						addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, H, "<span class='notice'>[(E.lewd?"Your [E.enthrallGender]":"[E.master]")] whispers you a new objective.</span>"), 5)
						brainwash(H, objective)
						E.mental_capacity -= 200
						to_chat(user, "<span class='notice'><i>You sucessfully give an objective to [H]</i></span>")
					else
						to_chat(user, "<span class='warning'>Your pet looks at you with a vacant blasé expression, you don't think you can program anything else into them</b></span>")
					user.SetStun(0)
					H.SetStun(0)

	//INSTILL
	else if((findtext(message, instill_words)))
		for(var/V in listeners)
			var/mob/living/carbon/human/H = V
			var/datum/status_effect/chem/enthrall/E = H.has_status_effect(/datum/status_effect/chem/enthrall)
			if(E.phase >= 3 && E.lewd)
				var/instill = stripped_input(user, "Instill an emotion in [H].", MAX_MESSAGE_LEN)
				to_chat(H, "<i>[instill]</i>")
				to_chat(user, "<span class='notice'><i>You sucessfully instill a feeling in [H]</i></span>")
				log_game("FERMICHEM: [H] has been instilled by [user] with [instill] via MKUltra.")
				E.cooldown += 1

	//RECOGNISE
	else if((findtext(message, recognise_words)))
		for(var/V in listeners)
			var/mob/living/carbon/human/H = V
			var/datum/status_effect/chem/enthrall/E = H.has_status_effect(/datum/status_effect/chem/enthrall)
			if(E.phase > 1)
				if(user.ckey == E.enthrallID && user.real_name == E.master.real_name)
					E.master = user
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, H, "<span class='nicegreen'>[(E.lewd?"You hear the words of your [E.enthrallGender] again!! They're back!!":"You recognise the voice of [E.master].")]</b></span>"), 5)
					to_chat(user, "<span class='notice'><i>[H] looks at you with sparkling eyes, recognising you!</i></span>")

	//I dunno how to do state objectives without them revealing they're an antag

	//HEAL (maybe make this nap instead?)
	else if(findtext(message, heal_words))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(3)//Tier 3 only
					E.status = "heal"
					E.statusStrength = (5 * power_multiplier)
					E.cooldown += 5
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='notice'>You begin to lick your wounds.</b></span>"), 5)
					L.Stun(15 * power_multiplier)
					to_chat(user, "<span class='notice'><i>[L] begins to lick their wounds.</i></span>")

	//STUN
	else if(findtext(message, stun_words))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(3 to INFINITY)
					L.Stun(40 * power_multiplier)
					E.cooldown += 8
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='notice'>Your muscles freeze up!</b></span>"), 5)
					to_chat(user, "<span class='notice'><i>You cause [L] to freeze up!</i></span>")

	//HALLUCINATE
	else if(findtext(message, hallucinate_words))
		for(var/V in listeners)
			var/mob/living/carbon/C = V
			var/datum/status_effect/chem/enthrall/E = C.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(3 to INFINITY)
					new /datum/hallucination/delusion(C, TRUE, null,150 * power_multiplier,0)
					to_chat(user, "<span class='notice'><i>You send [C] on a trip.</i></span>")

	//HOT
	else if(findtext(message, hot_words))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(3 to INFINITY)
					L.adjust_bodytemperature(50 * power_multiplier)//This seems nuts, reduced it, but then it didn't do anything, so I reverted it.
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='notice'>You feel your metabolism speed up!</b></span>"), 5)
					to_chat(user, "<span class='notice'><i>You speed [L]'s metabolism up!</i></span>")

	//COLD
	else if(findtext(message, cold_words))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(3 to INFINITY)
					L.adjust_bodytemperature(-50 * power_multiplier)
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='notice'>You feel your metabolism slow down!</b></span>"), 5)
					to_chat(user, "<span class='notice'><i>You slow [L]'s metabolism down!</i></span>")

	//GET UP
	else if(findtext(message, getup_words))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(3 to INFINITY)//Tier 3 only
					if(L.resting)
						L.lay_down() //aka get up
					L.SetStun(0)
					L.SetKnockdown(0)
					L.SetUnconscious(0) //i said get up i don't care if you're being tased
					E.cooldown += 10 //This could be really strong
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='notice'>You jump to your feet from sheer willpower!</b></span>"), 5)
					to_chat(user, "<span class='notice'><i>You spur [L] to their feet!</i></span>")

	//PACIFY
	else if(findtext(message, pacify_words))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(3)//Tier 3 only
					E.status = "pacify"
					E.cooldown += 10
					addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, L, "<span class='notice'>You feel like never hurting anyone ever again.</b></span>"), 5)
					to_chat(user, "<span class='notice'><i>You remove any intent to harm from [L]'s mind.</i></span>")

	//CHARGE
	else if(findtext(message, charge_words))
		for(var/V in listeners)
			var/mob/living/L = V
			var/datum/status_effect/chem/enthrall/E = L.has_status_effect(/datum/status_effect/chem/enthrall)
			switch(E.phase)
				if(3)//Tier 3 only
					E.statusStrength = 2* power_multiplier
					E.status = "charge"
					E.cooldown += 10
					to_chat(user, "<span class='notice'><i>You rally [L], leading them into a charge!</i></span>")

	if(message_admins || debug)//Do you want this in?
		message_admins("[ADMIN_LOOKUPFLW(user)] has said '[log_message]' with a Velvet Voice, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
	log_game("FERMICHEM: [key_name(user)] ckey: [user.key] has said '[log_message]' with a Velvet Voice, affecting [english_list(listeners)], with a power multiplier of [power_multiplier].")
	SSblackbox.record_feedback("tally", "fermi_chem", 1, "Times people have spoken with a velvet voice")
	//SSblackbox.record_feedback("tally", "Velvet_voice", 1, log_message) If this is on, it fills the thing up and OOFs the server

	return


#undef COOLDOWN_STUN
#undef COOLDOWN_DAMAGE
#undef COOLDOWN_MEME
#undef COOLDOWN_NONE
