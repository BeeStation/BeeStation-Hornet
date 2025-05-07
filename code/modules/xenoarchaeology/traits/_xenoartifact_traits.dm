/*
	For laternate versions of traits, that you want as seperate on the labeler, use the format-
	'trait_name Δ' 'trait_name Σ' 'trait_name Ω', for up to three alternates, add more symbols if you have a trait with 4 alts or more
*/

/datum/xenoartifact_trait
	///Reference to the artifact
	var/datum/component/xenoartifact/component_parent

	///Acts as a descriptor for when examining - 'reinforced' 'electrified' 'hollow'
	var/material_desc
	///Used when labeler needs a name and trait is too sneaky to have a descriptor when examining.
	var/label_name
	///Alternate name displayed when hovering
	var/alt_label_name
	///Something briefly explaining it in inagame terms.
	var/label_desc

	///Asscoiated flags for artifact typing and such
	var/flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	///Other traits this trait wont work with.
	var/list/blacklist_traits = list()
	///How rare is this trait? 100 being common, and 1 being very rare
	var/rarity = XENOA_TRAIT_WEIGHT_COMMON

	///Does this trait reigster targets?
	var/register_targets = TRUE

	///How much time does this trait add to the artifact cooldownm
	var/cooldown = 0 SECONDS

	///What trait priority we use
	var/priority = TRAIT_PRIORITY_ACTIVATOR

	///List of things we've effected. used to automatically reigster & unregister targets. Don't confuse with component_parent targets, which is things we want to effect
	var/list/targets = list()
	///A distinct list of targets, incorporating overrides
	var/list/focus = list()
	///Extra target range we add to the artifact
	var/extra_target_range = 0

	///How much extra value does this trait apply to the artifact - It's important this is applied before anyone can use stickers on the artifact
	var/extra_value = 0
	///How many discovery points does this trait give?
	var/discovery_reward = 100

	///Does this trait contribute to calibration
	var/contribute_calibration = TRUE

	///Can this trait be made a pearl? - aka can this trait be used in circuits
	var/can_pearl = TRUE

	///Characteristics for deduction
	var/weight = 1 //KG
	var/conductivity = 1 //microsiemens per centimeter - I had to look this up - Don't worry about making this accurate / reasonable

	///What kind of incompatabilities does this trait have
	var/incompatabilities

/datum/xenoartifact_trait/New(atom/_parent)
	. = ..()
	if(_parent)
		register_parent(_parent)

/datum/xenoartifact_trait/Destroy(force, ...)
	. = ..()
	dump_targets()
	remove_parent(component_parent, FALSE)

//The reason this is a seperate proc is so we can init the trait and swap its artifact component component_parent around
/datum/xenoartifact_trait/proc/register_parent(datum/source)
	component_parent = source
	var/atom/movable/movable = component_parent.parent
	RegisterSignal(component_parent, COMSIG_PARENT_QDELETING, PROC_REF(remove_parent))
	//Setup trigger signals
	RegisterSignal(component_parent, COMSIG_XENOA_TRIGGER, PROC_REF(trigger))
	//If we need to setup signals for pearl stuff
	if(can_pearl)
		RegisterSignal(movable, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(catch_pearl_tool))
		RegisterSignal(movable, COMSIG_MOVABLE_MOVED, PROC_REF(catch_move))
	//Appearance
	if(component_parent.do_texture)
		generate_trait_appearance(component_parent.parent)
	//Stats
	component_parent.target_range += extra_target_range
	movable.custom_price += extra_value

//Remeber to call this before setting a new component_parent
/datum/xenoartifact_trait/proc/remove_parent(datum/source, pensive = TRUE)
	SIGNAL_HANDLER

	//Detach from current component_parent
	if(component_parent)
		remove_hints()
		UnregisterSignal(component_parent, COMSIG_PARENT_QDELETING)
		UnregisterSignal(component_parent, COMSIG_XENOA_TRIGGER)
		var/atom/atom_parent = component_parent.parent
		component_parent.target_range -= extra_target_range
		atom_parent.custom_price -= extra_value
		cut_trait_appearance(component_parent.parent)
		if(can_pearl)
			UnregisterSignal(atom_parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER))
			UnregisterSignal(atom_parent, COMSIG_MOVABLE_MOVED)
	if(pensive)
		qdel(src)
	component_parent = null
	dump_targets()

//Cleanly register an effected target
/datum/xenoartifact_trait/proc/register_target(atom/target, do_trigger = FALSE)
	if(do_trigger)
		trigger(null, priority, target)
	targets += target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(unregister_target_signal), TRUE)

//Cleanly unregister an effected target
/datum/xenoartifact_trait/proc/unregister_target(datum/source, do_untrigger = FALSE)
	SIGNAL_HANDLER

	if(do_untrigger) //This will only happen in the event something is unregistered before we can untrigger, which is needed for QDELs
		un_trigger(source, override = source)
	targets -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/datum/xenoartifact_trait/proc/unregister_target_signal(datum/source)
	SIGNAL_HANDLER

	unregister_target(source, TRUE)

/datum/xenoartifact_trait/proc/trigger(datum/source, _priority, atom/override)
	SIGNAL_HANDLER

	. = TRUE
	if(_priority != priority && _priority)
		return FALSE
	if(!register_targets)
		return
	//If we've been given an override
	if(override)
		register_target(override)
	//Otherwise just use the artifact's target list
	else if(length(component_parent.targets))
		for(var/atom/target in component_parent.targets)
			register_target(target)
	//Handle focus
	focus = override ? list(override) : targets
	return

//Most traits will handle this on their own
/datum/xenoartifact_trait/proc/un_trigger(atom/override, handle_parent = FALSE)
	//Override
	if(override)
		unregister_target(override)
	//Parent targets, we shouldn't need this casually, only for niche cases
	if(length(component_parent.targets) && handle_parent)
		for(var/atom/target in component_parent.targets)
			unregister_target(target)
	//Our targets
	if(length(targets))
		for(var/atom/target in targets)
			unregister_target(target)
	//Handle Focus
	clear_focus()
	return

/datum/xenoartifact_trait/proc/dump_targets()
	for(var/target in targets)
		unregister_target(target, TRUE)

//Call this when you're finished with the focus in the trigger() proc, un_trigger() handles itself
/datum/xenoartifact_trait/proc/clear_focus()
	focus.Cut()
	focus = list()

//If we want this trait to modify the artifact's appearance
/datum/xenoartifact_trait/proc/generate_trait_appearance(atom/target)
	return

/datum/xenoartifact_trait/proc/cut_trait_appearance(atom/target)
	return

/datum/xenoartifact_trait/proc/setup_generic_item_hint()
	RegisterSignal(component_parent.parent, COMSIG_PARENT_ATTACKBY, PROC_REF(hint_translation_type_a))

/datum/xenoartifact_trait/proc/setup_generic_touch_hint()
	RegisterSignal(component_parent.parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(hint_translation_type_b))
	RegisterSignal(component_parent.parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(hint_translation_type_b))

/datum/xenoartifact_trait/proc/remove_hints()
	UnregisterSignal(component_parent.parent, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(component_parent.parent, COMSIG_ATOM_ATTACK_HAND)
	UnregisterSignal(component_parent.parent, COMSIG_PARENT_ATTACKBY)

/datum/xenoartifact_trait/proc/hint_translation_type_a(datum/source, obj/item, mob/living, params)
	SIGNAL_HANDLER

	do_hint(living, item)

/datum/xenoartifact_trait/proc/hint_translation_type_b(datum/source, mob/living)
	SIGNAL_HANDLER

	var/atom/atom_parent = component_parent?.parent
	if(!atom_parent?.density && atom_parent?.loc != living)
		return
	do_hint(living, null)

/datum/xenoartifact_trait/proc/do_hint(mob/user, atom/item)
	//If they have science goggles, or equivilent, they are shown exatcly what trait this is
	if(!user?.can_see_reagents())
		return
	var/atom/atom_parent = component_parent.parent
	if(!isturf(atom_parent.loc))
		atom_parent = atom_parent.loc
	atom_parent.balloon_alert(user, label_name, component_parent.artifact_material.material_color)
	//show_in_chat doesn't work
	to_chat(user, "<span class='notice'>[component_parent.parent] : [label_name]</span>")

/datum/xenoartifact_trait/proc/get_dictionary_hint()
	return list()

//Check the artifact, item, moves to see if we open up for 'pearling'
/datum/xenoartifact_trait/proc/catch_move(datum/source, atom/target, dir)
	SIGNAL_HANDLER

	if(!component_parent.calibrated)
		return
	//Check if we're at our heart location, which is based on our weight-x and conductivity-y
	var/atom/atom_parent = component_parent.parent
	if(!isturf(atom_parent?.loc))
		return
	if(target.x % (weight || target.x || 1) == 0 && target.y % (conductivity || target.y || 1) == 0)
		var/atom/target_loc = atom_parent.loc
		target_loc.visible_message("<span class='warning'>[atom_parent] develops a slight opening!</span>\n<span class='notice'>You could probably use a screwdriver on [atom_parent]!</span>", allow_inside_usr = TRUE)
		//Do effects
		playsound(atom_parent, 'sound/machines/clockcult/ark_damage.ogg', 50, TRUE)

/datum/xenoartifact_trait/proc/catch_pearl_tool(datum/source, mob/living/user, obj/item/I, list/recipes)
	SIGNAL_HANDLER

	if(!component_parent.calibrated)
		return
	var/atom/atom_parent = component_parent.parent
	if(!isturf(atom_parent?.loc))
		return
	if(atom_parent.x % (weight || atom_parent.x || 1) != 0 || atom_parent.y % (conductivity || atom_parent.y || 1) != 0)
		return
	INVOKE_ASYNC(src, PROC_REF(pry_action), user, I)

/datum/xenoartifact_trait/proc/pry_action(mob/living/user, obj/item/I)
	var/atom/movable/movable = component_parent.parent
	to_chat(user, "<span class='warning'>You begin to pry [movable] open with [I].</span>")
	if(do_after(user, 8 SECONDS, movable) && component_parent)
		new /obj/item/sticker/trait_pearl(get_turf(movable), src)
		component_parent?.remove_individual_trait(src) //You never know...
		remove_parent(pensive = FALSE)
	else
		to_chat(user, "<span class='warning'>You reconsider...</span>")

///Particle holder for trait appearances - Throw any extras you want in here
/atom/movable/artifact_particle_holder
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
