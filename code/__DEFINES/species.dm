// Sounds used by species for "nasal/lungs" emotes - the DEFAULT being used mainly by humans, lizards, and ethereals becase biology idk

#define SPECIES_DEFAULT_COUGH_SOUND(user) user.gender == FEMALE ? pick(\
				'sound/emotes/female/female_cough_1.ogg',\
				'sound/emotes/female/female_cough_2.ogg',\
				'sound/emotes/female/female_cough_3.ogg') : pick(\
				'sound/emotes/male/male_cough_1.ogg',\
				'sound/emotes/male/male_cough_2.ogg',\
				'sound/emotes/male/male_cough_3.ogg')
#define SPECIES_DEFAULT_GASP_SOUND(user) user.gender == FEMALE ? pick(\
		'sound/emotes/female/gasp_f1.ogg',\
		'sound/emotes/female/gasp_f2.ogg',\
		'sound/emotes/female/gasp_f3.ogg',\
		'sound/emotes/female/gasp_f4.ogg',\
		'sound/emotes/female/gasp_f5.ogg',\
		'sound/emotes/female/gasp_f6.ogg') : pick(\
		'sound/emotes/male/gasp_m1.ogg',\
		'sound/emotes/male/gasp_m2.ogg',\
		'sound/emotes/male/gasp_m3.ogg',\
		'sound/emotes/male/gasp_m4.ogg',\
		'sound/emotes/male/gasp_m5.ogg',\
		'sound/emotes/male/gasp_m6.ogg')
#define SPECIES_DEFAULT_SIGH_SOUND(user) user.gender == FEMALE ? 'sound/emotes/female/female_sigh.ogg' : 'sound/emotes/male/male_sigh.ogg'
#define SPECIES_DEFAULT_SNEEZE_SOUND(user) user.gender == FEMALE ? 'sound/emotes/female/female_sneeze.ogg' : 'sound/emotes/male/male_sneeze.ogg'
#define SPECIES_DEFAULT_SNIFF_SOUND(user) user.gender == FEMALE ? 'sound/emotes/female/female_sniff.ogg' : 'sound/emotes/male/male_sniff.ogg'
