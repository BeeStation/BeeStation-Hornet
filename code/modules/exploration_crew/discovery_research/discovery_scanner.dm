/obj/item/discovery_scanner
	name = "discovery scanner"
	desc = "A scanner used by scientists to collect research data about unknown artifacts and specimins."
	icon = 'icons/obj/device.dmi'
	icon_state = "discovery"
	inhand_icon_state = "discoveryscanner"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/datum/techweb/linked_techweb

/obj/item/discovery_scanner/Initialize(mapload)
	. = ..()
	if(!linked_techweb)
		linked_techweb = SSresearch.science_tech
	ADD_TRAIT(src, TRAIT_ARTIFACT_IGNORE, GENERIC_ITEM_TRAIT)

/obj/item/discovery_scanner/Destroy()
	linked_techweb = null	//Note: Shouldn't hard del anyway since techwebs don't get deleted, however if they do then troubles will arise and this will need to be changed.
	. = ..()

/obj/item/discovery_scanner/examine(mob/user)
	. = ..()
	. += span_notice("Left-Click on any mob or researchable specimin to scan and gain discovery research points.")
	. += span_notice("[src] has unlimited range.")
	. += span_notice("Science goggles can help detect researchable items.")

/obj/item/discovery_scanner/attack_atom(obj/O, mob/living/user)
	if(istype(O, /obj/machinery/computer/rdconsole))
		to_chat(user, span_notice("You link [src] to [O]."))
		var/obj/machinery/computer/rdconsole/rdconsole = O
		linked_techweb = rdconsole.stored_research
		return
	. = ..()

/obj/item/discovery_scanner/proc/begin_scanning(mob/user, datum/component/discoverable/discoverable)
	to_chat(user, span_notice("You begin scanning [discoverable.parent]..."))
	if(do_after(user, 50, target=get_turf(user), interaction_key = REF(discoverable.parent)))
		discoverable.discovery_scan(linked_techweb, user)
