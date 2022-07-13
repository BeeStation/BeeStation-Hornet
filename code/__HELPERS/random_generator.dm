#define SAFE_RAND_MAX 11000
// I caluclated most situations using this random value system, and 11000 is the most safe value due to Byond magic.
// otherwise, it can cause some override issue or something like that. I can hard tell how it is though.

/proc/rand_LCM(var/my_rand_seed=0, var/maximum=1, var/numbers_of_return = 1, var/flat = 1)
	// Pseudo random number generating - "Modified" Linear Congruential Method
	// Since I didn't want to touch `rand_seed()` proc, I had to make this.
	// This isn't real Linear Congruential Method.
	/*
	[Usage example]
		rand_LCM([seed], 3): returns 1~3
		rand_LCM([seed], 3, flat=0): returns 0~2
		rand_LCM([seed], 3, numbers_of_return=2, flat=2): returns a list with two of 2~4

	[When should I use this?]
		When you need to make 'consistent' random values, use this.
		using byond random seed is dangerous and you don't know which random system you'll break from it
		So, This one is safe when you want a cheat-proof no re-rolling random values.

		For example, `rand_LCM(234, 10)` will always return 7 during a round
		at a new round, `rand_LCM(234, 10)` will always return 3 during that round
	*/


	var/static/incre = rand(1,SAFE_RAND_MAX)
	var/static/multiplier = rand(1,SAFE_RAND_MAX)
	// This will make each round random

	. = numbers_of_return == 1 ? 0 : list()
	if(my_rand_seed>SAFE_RAND_MAX)
		my_rand_seed %= SAFE_RAND_MAX
		/* Calculation issue:
			`SAFE_RAND_MAX*SAFE_RAND_MAX+SAFE_RAND_MAX=121,011,000`
			if you try to calculate get a mod from a value more than 121,011,000,
			this causes some overflow issue in DM.
		*/
	if(my_rand_seed == 0)
		my_rand_seed = rand(1,SAFE_RAND_MAX)
	for(var/i in 1 to numbers_of_return)
		var/seed_result = (my_rand_seed*multiplier+incre) %maximum +flat
		my_rand_seed = seed_result
		. += seed_result
