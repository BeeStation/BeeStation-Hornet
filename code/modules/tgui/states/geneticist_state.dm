/**
 * tgui state: default_state
 *
 * Checks a number of things -- mostly physical distance for humans
 * and view for robots.
 *
 * Copyright (c) 2025 PowerfulBacon
 * SPDX-License-Identifier: MIT
 */

GLOBAL_DATUM_INIT(geneticist_state, /datum/ui_state/geneticist, new)

/datum/ui_state/geneticist/can_use_topic(src_object, mob/user)
	return user.default_can_use_topic(src_object) && user.mind && HAS_TRAIT(user.mind, TRAIT_GENETICIST)  // Call the individual mob-overridden procs.
