GLOBAL_VAR_INIT(master_mode, "Loading...") //! Stores the current gamemode. Intentionally invalid placeholder is replaced in Ticker.
GLOBAL_VAR_INIT(secret_force_mode, "secret") //! if this is anything but "secret", the secret rotation will forceably choose this mode
GLOBAL_VAR(common_report) //! Contains common part of roundend report
GLOBAL_VAR(survivor_report) //! Contains shared survivor report for roundend report (part of personal report)


GLOBAL_VAR_INIT(wavesecret, 0) //! meteor mode, delays wave progression, terrible name
GLOBAL_DATUM(start_state, /datum/station_state) //! Used in round-end report

GLOBAL_VAR_INIT(station_goal_selection_open, FALSE) //Stores whether the station goal selection menu is open.
GLOBAL_VAR(selected_station_goal)//Stores the currently selected station goal. Initialized to null by default.

//TODO clear this one up too
GLOBAL_DATUM(cult_narsie, /obj/eldritch/narsie)

///We want reality_smash_tracker to exist only once and be accesable from anywhere.
GLOBAL_DATUM_INIT(reality_smash_track, /datum/reality_smash_tracker, new)
