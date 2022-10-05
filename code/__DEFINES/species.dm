// Sounds used by species for "nasal/lungs" emotes - the DEFAULT being used mainly by humans, lizards, and ethereals becase biology idk

#define SPECIES_DEFAULT_COUGH_SOUND(user) user.gender == FEMALE ? pick(\
				'code/datums/emote_sounds/emotes/female/female_cough_1.ogg',\
				'code/datums/emote_sounds/emotes/female/female_cough_2.ogg',\
				'code/datums/emote_sounds/emotes/female/female_cough_3.ogg') : pick(\
				'code/datums/emote_sounds/emotes/male/male_cough_1.ogg',\
				'code/datums/emote_sounds/emotes/male/male_cough_2.ogg',\
				'code/datums/emote_sounds/emotes/male/male_cough_3.ogg')
#define SPECIES_DEFAULT_GASP_SOUND(user) user.gender == FEMALE ? pick(\
		'code/datums/emote_sounds/emotes/female/gasp_f1.ogg',\
		'code/datums/emote_sounds/emotes/female/gasp_f2.ogg',\
		'code/datums/emote_sounds/emotes/female/gasp_f3.ogg',\
		'code/datums/emote_sounds/emotes/female/gasp_f4.ogg',\
		'code/datums/emote_sounds/emotes/female/gasp_f5.ogg',\
		'code/datums/emote_sounds/emotes/female/gasp_f6.ogg') : pick(\
		'code/datums/emote_sounds/emotes/male/gasp_m1.ogg',\
		'code/datums/emote_sounds/emotes/male/gasp_m2.ogg',\
		'code/datums/emote_sounds/emotes/male/gasp_m3.ogg',\
		'code/datums/emote_sounds/emotes/male/gasp_m4.ogg',\
		'code/datums/emote_sounds/emotes/male/gasp_m5.ogg',\
		'code/datums/emote_sounds/emotes/male/gasp_m6.ogg')
#define SPECIES_DEFAULT_SIGH_SOUND(user) user.gender == FEMALE ? 'code/datums/emote_sounds/emotes/female/female_sigh.ogg' : 'code/datums/emote_sounds/emotes/male/male_sigh.ogg'
#define SPECIES_DEFAULT_SNEEZE_SOUND(user) user.gender == FEMALE ? 'code/datums/emote_sounds/emotes/female/female_sneeze.ogg' : 'code/datums/emote_sounds/emotes/male/male_sneeze.ogg'
#define SPECIES_DEFAULT_SNIFF_SOUND(user) user.gender == FEMALE ? 'code/datums/emote_sounds/emotes/female/female_sniff.ogg' : 'code/datums/emote_sounds/emotes/male/male_sniff.ogg'
