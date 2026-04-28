
# Template file for your new component

See dcs/flags.dm for detailed explanations

```dm
/datum/component/mycomponent
	//can_transfer = TRUE                   // Must have PostTransfer
	//dupe_mode = COMPONENT_DUPE_ALLOWED    // code/__DEFINES/dcs/flags.dm
	var/myvar

/datum/component/mycomponent/Initialize(myargone, myargtwo)
	if(myargone)
		myvar = myargone
	if(myargtwo)
		send_to_playing_players(myargtwo)

/datum/component/mycomponent/RegisterWithParent()
	// RegisterSignal can take a signal name by itself.
	RegisterSignal(parent, COMSIG_NOT_REAL, PROC_REF(signalproc))

	// or a list of them to assign to another proc 'RegisterSignals()'
	//! if signals are a list, use 'RegisterSignals' with extra s.
	//! if it's a single signal, use 'RegisterSignal' without s
	RegisterSignals(parent, list(COMSIG_NOT_REAL_EITHER, COMSIG_ALMOST_REAL), PROC_REF(otherproc))

/datum/component/mycomponent/UnregisterFromParent()
	// UnregisterSignal has similar behavior
	UnregisterSignal(parent, COMSIG_NOT_REAL)

	// But you can just include all registered signals in one call
	UnregisterSignal(parent, list(
		COMSIG_NOT_REAL,
		COMSIG_NOT_REAL_EITHER,
		COMSIG_ALMOST_REAL,
	))

/datum/component/mycomponent/proc/signalproc(datum/source)
	SIGNAL_HANDLER
	send_to_playing_players("[source] signaled [src]!")

/*
/datum/component/mycomponent/InheritComponent(datum/component/mycomponent/old, i_am_original, list/arguments)
	myvar = old.myvar

	if(i_am_original)
		send_to_playing_players("No parent should have to bury their child")
*/

/*
/datum/component/mycomponent/PreTransfer()
	send_to_playing_players("Goodbye [parent], I'm getting adopted")

/datum/component/mycomponent/PostTransfer()
	send_to_playing_players("Hello my new parent, [parent]! It's nice to meet you!")
*/

/*
/datum/component/mycomponent/CheckDupeComponent(datum/mycomponent/new, myargone, myargtwo)
	if(myargone == myvar)
		return TRUE
*/
```
