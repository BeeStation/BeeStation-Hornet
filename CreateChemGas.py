import re
import git
import os
import shutil
import errno
import filecmp
from scandir import scandir, walk

currentpath = os.getcwd()
totalchems = ['ignoreignoreignoreignore', ' ']

newincludes = ''
new_file_content = ''
ignore = ['oxygen', 'nitrogen', 'carbon_dioxide', 'plasma', 'water_vapor', 'consumable', 'hypernoblium', 'nitrous_oxide', 'nitryl', 'tritium', 'bz', 'stimulum', 'pluoxium', 'miasma', 'dexalin']


g = input("Would you like to update chem gasses? (Y/N)\n")
if g == 'Y' or g == 'y':
    gaschems = ''
    chemcans = ''
    chemtgui = ''
    color = 0
    containerlist = ''
    totalgasses = 14

    gui = currentpath + '\\tgui\\packages\\tgui\\constants.js'

    canfile = currentpath + '\\code\\modules\\atmospherics\\machinery\\portable\\canister.dm'

    gasfile = currentpath + '\\code\\modules\\atmospherics\\gasmixtures\\gas_types.dm'

    for folderName, subfolders, filenames in os.walk(currentpath + '\\code\\modules\\reagents\\chemistry\\reagents'):
        for item in filenames:
            print('checking ' + str(item))
            if '.dm' in item:
                if '.dmm' not in item and '.dme' not in item:
                    reading_file = open(folderName + '\\' + item, "r", encoding="utf8")
                    encoding = "utf8"

                    for line in reading_file:
                        stripped_line = line.strip()
                        new_line = stripped_line

                        if color == 1:
                            if 'color =' in line:
                                new_line = new_line.replace('color = ', '')
                                gaschems = gaschems + '\n	color = ' + new_line + '\n'
                                color = 0

                            if '/datum' in line or '\n' == line:
                                gaschems = gaschems + '\n'
                                gaschems = gaschems + '\n'
                                color = 0

                        # Was having issues with this - Still probably broken - Was using ss13 merge tool to nuke comments until I fixed
                        if '/datum/reagent/' in line:
                            commentchecker = re.search(r'(.+)//', new_line)
                            if commentchecker is not None:
                                new_line = commentchecker[0]
                                new_line = new_line.replace(' ', '')
                                new_line = new_line.replace('//', '')

                            if '.' not in line and '(' not in line and 'crayon' not in line and 'dexalin' not in line:
                                new_line = re.findall(r'datum.+\/(.+)', new_line)
                                new_line = str(new_line[0])
                                new_line = new_line.replace(' ', '')
                                new_line = new_line.replace('	', '')
                                if new_line not in totalchems:
                                    print('adding ' + new_line)
                                    totalchems.append(new_line)

                                    # new_line = new_line.replace('/datum/chemical_reaction/', '')
                                    # new_line = new_line.replace('/datum/reagent/medicine/', '')
                                    # new_line = new_line.replace('/datum/reagent/drug/', '')
                                    # new_line = new_line.replace('/datum/reagent/consumable/ethanol/', '')
                                    # new_line = new_line.replace('/datum/reagent/consumable/', '')
                                    # new_line = new_line.replace('/datum/reagent/toxin/', '')
                                    # new_line = new_line.replace('/datum/reagent/', '')

                                    if '/' not in new_line:
                                        skip = 0
                                        for each in ignore:
                                            if each == new_line:
                                                skip = 1

                                        if skip == 0:

                                            chemtgui = chemtgui + '  {\n'
                                            chemtgui = chemtgui + "    'id': '" + new_line + "',\n"
                                            chemtgui = chemtgui + "    'name': '" + new_line + "',\n"
                                            chemtgui = chemtgui + "    'label': '" + new_line + "',\n"
                                            chemtgui = chemtgui + "    'color': 'olive',\n"
                                            chemtgui = chemtgui + '  },\n'

                                            containerlist = '		"' + new_line + '" = /obj/machinery/portable_atmospherics/canister/' + new_line + ',\n' + containerlist

                                            gaschems = gaschems + '\n/datum/gas/' + new_line
                                            gaschems = gaschems + '\n	id = "' + new_line + '"'
                                            gaschems = gaschems + '\n	specific_heat = 20'
                                            gaschems = gaschems + '\n	name = "' + new_line + '"'
                                            gaschems = gaschems + '\n	gas_overlay = "plasma_old"'
                                            gaschems = gaschems + '\n	moles_visible = MOLES_GAS_VISIBLE * 60'
                                            gaschems = gaschems + '\n	rarity = 250'
                                            gaschems = gaschems + '\n	chemgas = 1'

                                            chemcans = chemcans + '/obj/machinery/portable_atmospherics/canister/' + new_line
                                            chemcans = chemcans + '\n	name = "' + new_line + ' canister"'
                                            chemcans = chemcans + '\n	desc = "Miasma. Makes you wish your nose were blocked."'
                                            chemcans = chemcans + '\n	icon_state = "miasma"'
                                            chemcans = chemcans + '\n	gas_type = /datum/gas/' + new_line
                                            chemcans = chemcans + '\n	filled = 1'
                                            chemcans = chemcans + '\n'
                                            chemcans = chemcans + '\n'

                                            totalgasses = totalgasses + 1
                                            color = 1
                                else:
                                    print('skipping ' + new_line)
reading_file = open(gasfile, "r", encoding="utf8")

gasfilerebuild = ''
rip = 0
for line in reading_file:

    if rip == 0:
        gasfilerebuild = gasfilerebuild + line
    else:
        if '// END' in line:
            rip = 0
            gasfilerebuild = gasfilerebuild + '\n' + gaschems + '\n' + line

    if '// BEGIN' in line:
        rip = 1
reading_file.close()


# Outputs
f = open(gasfile, "w+")
f.write(gasfilerebuild)
f.close()





reading_file = open(canfile, "r", encoding="utf8")
canfilerebuild = ''
rip = 0
for line in reading_file:
    if rip == 0:
        canfilerebuild = canfilerebuild + line
    else:
        if '// END' in line:
            rip = 0
            canfilerebuild = canfilerebuild + '\n' + chemcans + '\n' + line
    if '// BEGIN' in line:
        rip = 1
reading_file.close()

f = open(canfile, "w+")
f.write(canfilerebuild)
f.close()

reading_file = open(canfile, "r", encoding="utf8")
canfilerebuild = ''
rip = 0
for line in reading_file:
    if rip == 0:
        canfilerebuild = canfilerebuild + line
    else:
        if '// LIST END' in line:
            rip = 0
            canfilerebuild = canfilerebuild + containerlist + line
    if '// LIST BEGIN' in line:
        rip = 1
reading_file.close()

f = open(canfile, "w+")
f.write(canfilerebuild)
f.close()

reading_file = open(gui, "r", encoding="utf8")
canfilerebuild = ''
rip = 0
for line in reading_file:
    if rip == 0:
        canfilerebuild = canfilerebuild + line
    else:
        if '// END' in line:
            rip = 0
            canfilerebuild = canfilerebuild + chemtgui + line
    if '// BEGIN' in line:
        rip = 1
reading_file.close()

f = open(gui, "w+", encoding="utf8")
f.write(canfilerebuild)
f.close()

start = 0





chemreaction = ''
resultsamount = ''
reactions = ''
reactionreqs = ''
build = ''
temp = ''

for folderName, subfolders, filenames in os.walk(currentpath + '\\code\\modules\\reagents\\chemistry\\recipes'):
    for item in filenames:
        if '.dm' in item:
            if '.dmm' not in item and '.dme' not in item:


                print('opening file')
                reading_file = open(folderName + '\\' + item, "r", encoding="utf8")
                encoding = "utf8"

                for line in reading_file:
                    stripped_line = line.strip()

                    new_line = stripped_line

                    if start == 1:
                        if '\n' == line or '/datum/chemical_reaction/' in line:
                            start = 0

                            # handles first block
                            build = build + chemreaction + '\n' + '\n'

                            # Second Block
                            reactionreqs = '/datum/gas_reaction/' + chemname + '/init_reqs()'

                            if temp != '':
                                reactionreqs = reactionreqs + '\n	min_requirements = list(' + reactions + '\n'
                                reactionreqs = reactionreqs + '		' + temp + ')'
                            else:
                                reactionreqs = reactionreqs + '\n	min_requirements = list(' + reactions[:-1] + '\n'
                                reactionreqs = reactionreqs + '	)\n'


                            build = build + reactionreqs + '\n' + '\n'


                            # Third block

                            build = build + '/datum/gas_reaction/' + chemname + '/react(datum/gas_mixture/air, datum/holder)\n'
                            build = build + '	var/remove_air = 0\n'
                            build = build + '	var/cleaned_air = ' + gasfinders[:-3] + '\n'
                            build = build + gasremovers

                            build = build + '	air.adjust_moles(/datum/gas/' + chemname + ', cleaned_air)\n\n'
                            # Push out the entire completed chungus




                            # Reset all vars
                            temp = ''
                            chemname = ''
                            gasfinders = ''
                            reactionreqs = ''
                            reactions = ''

                    if start == 1:
                        if 'required_temp' in line:
                            '"TEMP" = '
                            temp = ''
                            temp = re.search(r'(\d+)', line)
                            temp = temp[0]
                            temp = '"TEMP" = ' + temp


                        if 'required_reagents' in line:
                            requiredsearch = re.findall(r'\/(.+?)\d+', line)
                            # Hm I also need the amount...
                            reactions = ''
                            gasfinders = ''
                            gasremovers = ''
                            for each in requiredsearch:

                                # chemextractor = str(each)
                                # print('searching ' + each)
                                searcher = each

                                chemextractor = re.findall(r'datum.+\/(.+) ', searcher)
                                chemextractor = chemextractor[0]
                                chemextractor = chemextractor.replace(' =','')
                                # print(chemextractor)
                                # chemextractor = chemextractor.replace('datum/chemical_reaction/', '')
                                # chemextractor = chemextractor.replace('datum/reagent/medicine/', '')
                                # chemextractor = chemextractor.replace('datum/reagent/drug/', '')
                                # chemextractor = chemextractor.replace('datum/reagent/consumable/ethanol/', '')
                                # chemextractor = chemextractor.replace('datum/reagent/consumable/', '')
                                # chemextractor = chemextractor.replace('datum/reagent/toxin/', '')
                                # chemextractor = chemextractor.replace('datum/reagent/', '')
                                # chemextractor = chemextractor.replace(' = ', '')

                                number = re.search(r'(\d+)', line)

                                reactions = reactions + '\n		/datum/gas/' + chemextractor + ' = ' + number[0] + ','


                                gasfinders = gasfinders + 'air.get_moles(/datum/gas/' + chemextractor + ') + '

                                gasremovers = gasremovers + '	remove_air = air.get_moles(/datum/gas/' + chemextractor + ')\n'
                                gasremovers = gasremovers + '	air.adjust_moles(/datum/gas/' + chemextractor + ', -remove_air)\n'




                        if 'results' in line:
                            # Should be getting total amount Made
                            resultsamount = re.search(r'(\d+)', line)
                            resultsamount = resultsamount[0]

                            # Should be getting name of chem made - Kinda redundent
                            results = re.search(r'\/(.+?) ', line)
                            results = str(results[0])
                            results = results.replace('/datum/chemical_reaction/', '')
                            results = results.replace('/datum/reagent/medicine/', '')
                            results = results.replace('/datum/reagent/drug/', '')
                            results = results.replace('/datum/reagent/consumable/ethanol/', '')
                            results = results.replace('/datum/reagent/consumable/', '')
                            results = results.replace('/datum/reagent/toxin/', '')
                            results = results.replace('/datum/reagent/', '')
                            # dont think needed




                        if 'required_temp' in line:
                            fug = 1

                    if '/datum/chemical_reaction/' in line:
                        if '.' not in line:

                            new_line = new_line.replace('/datum/chemical_reaction/', '')
                            if new_line in totalchems:
                                # will have name

                                # name = "Black Powder"
                                # id = /datum/reagent/blackpowder
                                # results = list(/datum/reagent/blackpowder = 3)
                                # required_reagents = list(/datum/reagent/saltpetre = 1, /datum/reagent/medicine/charcoal = 1, /datum/reagent/sulfur = 1)


                                if '/' not in new_line:
                                    # print('slash not in new line')
                                    skip = 0
                                    # for each in ignore:
                                    #     if each == new_line:
                                    #         skip = 1

                                    if skip == 0:
                                        # /datum/gas_reaction/miaster	//dry heat sterilization: clears out pathogens in the air
                                        # priority = -10 //after all the heating from fires etc. is done
                                        # name = "Dry Heat Sterilization"
                                        # id = "sterilization"
                                        chemname = new_line
                                        chemreaction = ''
                                        chemreaction = chemreaction + '/datum/gas_reaction/' + new_line + '\n'
                                        chemreaction = chemreaction + "    priority = 1\n"
                                        chemreaction = chemreaction + '    name = "' + new_line + '"\n'
                                        chemreaction = chemreaction + '    id = "' + new_line + '"\n'


                                        start = 1


                                        # containerlist = '		"' + new_line + '" = /obj/machinery/portable_atmospherics/canister/' + new_line + ',\n' + containerlist
                                        #
                                        # gaschems = gaschems + '/datum/gas/' + new_line
                                        # gaschems = gaschems + '\n	id = "' + new_line + '"'
                                        # gaschems = gaschems + '\n	specific_heat = 20'
                                        # gaschems = gaschems + '\n	name = "' + new_line + '"'
                                        # gaschems = gaschems + '\n	gas_overlay = "plasma_old"'
                                        # gaschems = gaschems + '\n	moles_visible = MOLES_GAS_VISIBLE * 60'
                                        # gaschems = gaschems + '\n	rarity = 250'



# print(build)

reactionsfile = currentpath + '\\code\\modules\\atmospherics\\gasmixtures\\reactions.dm'

reading_file = open(reactionsfile, "r", encoding="utf8")
canfilerebuild = ''
rip = 0
for line in reading_file:
    if rip == 0:
        canfilerebuild = canfilerebuild + line
    else:
        if '// END' in line:
            rip = 0
            canfilerebuild = canfilerebuild + build + line

    if '// BEGIN' in line:
        rip = 1
reading_file.close()

# Outputs
f = open(reactionsfile, "w+", encoding="utf8")
f.write(canfilerebuild)
print('should of updated')
f.close()


# used for DLL boy
gaschems = '\n\nTOTAL GASES = ' + str(totalgasses) + '\n'
print(gaschems)


