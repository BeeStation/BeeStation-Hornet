/// Code for believers.
/// These are station crew members
/datum/antagonist/servant_of_ratvar/believer
	name = "Servant of Rat'var (Believer)"

	counts_towards_total = TRUE

	/// The antag datum of the soul
	var/datum/antagonist/servant_of_ratvar/reebe_soul/soul_parallel

	/// Integration cog insight
	var/datum/action/innate/clockcult/spell/integration_cog/integration_cog_powers

/datum/antagonist/servant_of_ratvar/believer/New()
	. = ..()
	integration_cog_powers = new()

/datum/antagonist/servant_of_ratvar/believer/Destroy()
	qdel(integration_cog_powers)
	. = ..()

/datum/antagonist/servant_of_ratvar/believer/greet()
	if(!owner.current)
		return
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/clockcultalr.ogg', 60, FALSE, pressure_affected = FALSE)
	to_chat(owner.current, "<span class='heavy_brass'><font size='4'>While asleep you were granted a vision...</font></span>")
	to_chat(owner.current, "<span class='brass'>The vision contained an entity known as the Eminence that granted you with knowledge.</span>")
	to_chat(owner.current, "<span class='brass'>In the vision, the Eminence provided insights in how to create mechanical works embued with an arcane power.</span>")
	to_chat(owner.current, "<span class='sevtug'>Use the insights granted to you in order to progress...</span>")
	owner.current.client?.tgui_panel?.give_antagonist_popup("Reciever of the Vision.",
		"While asleep an entity known as the Eminence provided you with visions and forgotten knowledge which allows you to embue mechanical works with an arcane power.\n\
		Use your knowledge to uncover the mysteries of this vision...")

/datum/antagonist/servant_of_ratvar/believer/apply_innate_effects()
	. = ..()
	// When the body dies, the soul goes to Reebe
	RegisterSignal(owner.current, COMSIG_MOB_DEATH, .proc/become_soul)
	RegisterSignal(owner.current, COMSIG_LIVING_REVIVE, .proc/on_revival)
	// Give spell powers
	integration_cog_powers.Grant(owner.current)

/datum/antagonist/servant_of_ratvar/believer/remove_innate_effects()
	// No longer a believer, remove our special effects
	UnregisterSignal(owner.current, COMSIG_MOB_DEATH)
	UnregisterSignal(owner.current, COMSIG_LIVING_REVIVE)
	. = ..()

/// Upon body revival, exit the soul
/datum/antagonist/servant_of_ratvar/believer/proc/on_revival(mob/living/M)
	// No soul parallel
	if (!soul_parallel)
		return
	// Transfer the soul parallel's mind
	M.key = soul_parallel.owner.key
	// Destroy the soul parallel
	qdel(soul_parallel.owner.current)

/// Upon death, have the soul transfered to Reebe
/datum/antagonist/servant_of_ratvar/believer/proc/become_soul(mob/living/M, gibbed)
	// Client died while not logged in, prepare to transfer them to reebe
	if (!M.client)
		//TODO
		return
	// Create a new body
	var/turf/spawn_point = get_turf(pick(GLOB.servant_spawns))
	var/mob/living/carbon/human/H = new(spawn_point)
	M.client.prefs.copy_to(H)
	H.dna.update_dna_identity()
	H.equipOutfit(/datum/outfit/clockcult)
	//Give a new mind
	H.mind_initialize()
	//Give the antag datum
	soul_parallel = H.mind.add_antag_datum(/datum/antagonist/servant_of_ratvar/reebe_soul)
	RegisterSignal(soul_parallel, COMSIG_PARENT_QDELETING, .proc/on_soul_deleted)
	//Take over the body
	H.key = M.key

/// Qdel handling
/datum/antagonist/servant_of_ratvar/believer/proc/on_soul_deleted()
	UnregisterSignal(soul_parallel, COMSIG_PARENT_QDELETING)
	soul_parallel = null
