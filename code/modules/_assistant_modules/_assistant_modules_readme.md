# ASSISTANT MODULES:
Assistant modules are modules that can help coding like how _HELPERS procs do.
The difference between those is that assistant modules need to be a form of module because of its behaviour.
While helpers are only a single proc, these modules should be a datum type, and should be an object type individually.

There's only lag checker module currently, but more modules will be added.
i.e. Random Number Generator that uses its own seed and generation instead of DreamMaker dependent.

## lag_checker:
lag checker simply sleeps when you need to sleep() for every period you set.
sample usage exists in `meme.dm` hysteria virus.

1. You need to make a type of the lag checker first.
	You should consider if you're going to create it an individual type or a static type.
	At most cases, you'd want to make it a static.
2. If it's a static type, consider using `start_lag_check()` and `finish_lag_check()`
	these procs will prevent your count to be reset.
3. Consider which one you'll use between `lag_check_reset()` or `check_count_timeout()`
	both basically resets count to 0, but it's case by case when you want to reset the value.
4. put `sleep_lag()` in a loop or a code where it can cause a lot of lag.
	hysteria emote spam is the best example where it can cause the lag.
	voice of god's force-speech is one of questionable parts.

