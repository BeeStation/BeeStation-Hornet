/*
	Expansive Explosive Emmission
	I'm about to blow up, and act like I don't know nobody! AH AH AH AH AH!
*/
/datum/xenoartifact_trait/malfunction/explosion
	label_name = "E.E.E."
	alt_label_name = "Expansive Explosive Emmission"
	label_desc = "Expansive Explosive Emmission: A strange malfunction that causes the Artifact to explode."
	flags = XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	rarity = XENOA_TRAIT_WEIGHT_RARE
	can_pearl = FALSE
	///Max explosion stat
	var/max_explosion = 4
	///Are we exploding?
	var/exploding
	///Ref to the exploding effect
	var/atom/movable/exploding_indicator //We can't use an overlay, becuase it breaks filters, and the overlay filter doesn't animate

/datum/xenoartifact_trait/malfunction/explosion/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	var/obj/obj_parent = component_parent.parent
	//Make the artifact robust so it doesn't destroy itself
	obj_parent.set_armor_rating(BOMB, 500)
	//Build indicator appearance
	exploding_indicator = new()
	exploding_indicator.appearance = mutable_appearance('icons/obj/xenoarchaeology/xenoartifact.dmi', "explosion_warning", plane = LOWEST_EVER_PLANE)
	exploding_indicator.render_target = "[REF(exploding_indicator)]"
	exploding_indicator.vis_flags = VIS_UNDERLAY
	exploding_indicator.appearance_flags = KEEP_APART
	//Get it nearby so we can render it later
	obj_parent.vis_contents += exploding_indicator
	//Register a signal to cancel the process
	RegisterSignal(component_parent, COMSIG_XENOA_CALCIFIED, PROC_REF(cancel_explosion))

/datum/xenoartifact_trait/malfunction/explosion/Destroy(force, ...)
	. = ..()
	QDEL_NULL(exploding_indicator)

/datum/xenoartifact_trait/malfunction/explosion/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!. || exploding)
		return
	var/atom/atom_parent = component_parent.parent
	atom_parent.visible_message("<span class='warning'>The [atom_parent] begins to heat up, it's delaminating!</span>", allow_inside_usr = TRUE)
	exploding = addtimer(CALLBACK(src, PROC_REF(explode)), 30*(component_parent.trait_strength/100) SECONDS, TIMER_STOPPABLE)
	//Fancy effect to alert players
	atom_parent.add_filter("explosion_indicator", 1.1, layering_filter(render_source = exploding_indicator.render_target, blend_mode = BLEND_INSET_OVERLAY))
	atom_parent.add_filter("wave_effect", 5, wave_filter(x = 1, size = 0.6))
	var/filter = atom_parent.get_filter("wave_effect")
	animate(filter, offset = 5, time = 5 SECONDS, loop = -1)
	animate(offset = 0, time = 5 SECONDS)

/datum/xenoartifact_trait/malfunction/explosion/proc/explode()
	var/atom/atom_parent = component_parent.parent
	atom_parent.remove_filter("explosion_indicator")
	atom_parent.remove_filter("wave_effect")
	if(component_parent.calcified) //Just in-case this somehow happens
		return
	explosion(get_turf(component_parent.parent), max_explosion/3*(component_parent.trait_strength/100), max_explosion/2*(component_parent.trait_strength/100), max_explosion*(component_parent.trait_strength/100), max_explosion*(component_parent.trait_strength/100))
	component_parent.calcify()

//Tidy stuff up when we're calcified
/datum/xenoartifact_trait/malfunction/explosion/proc/cancel_explosion()
	SIGNAL_HANDLER

	var/atom/atom_parent = component_parent.parent
	atom_parent.remove_filter("explosion_indicator")
	atom_parent.remove_filter("wave_effect")
	deltimer(exploding)
	UnregisterSignal(component_parent, COMSIG_XENOA_CALCIFIED)
