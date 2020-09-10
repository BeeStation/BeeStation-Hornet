import re
import git
import os
import shutil
import errno
import filecmp
from scandir import scandir, walk

currentpath = os.getcwd()
newincludes = ''
new_file_content = ''
ignore = []

# DME is only the name
def finddme(directory):
    dme = None
    while dme is None:
        for item in os.listdir(directory):
            if '.dme' in item:
                print('Found DME')
                print('File: ' + item)
                dme = currentpath + '\\' + item
                print('Full Path: ' + dme)
                g = input("Is this the correct .dme File? (Y/N)\n")
                if 'n' in g or 'N' in g:
                    dme = None
        if dme is None:
            directory = input("Please specifiy the .dme Directoy \n")
    return dme



def replacement(reading_file, encoding):
    new_file_content = ""
    newreplacements = 0
    previousline = ''


    for line in reading_file:
        stripped_line = line.strip()
        if '#include "code' not in line:
            new_line = stripped_line
            new_file_content += new_line + "\n"


    new_file_content = new_file_content.replace('// END_INCLUDE', newincludes + '// END_INCLUDE')


    reading_file.close()

    writing_file = open(dme, "w", encoding=encoding)
    writing_file.write(new_file_content)
    writing_file.close()



g = input("Load Config? (Y/N)\n")
if g == 'Y' or g == 'y':
    filepath = 'Config.txt'
    with open(filepath) as fp:
        line = fp.readline()
        cnt = 1
        while line:
            line = fp.readline()
            cnt += 1
            if '#' not in line and line != '\n' and line != '':
                if "Exclude" in line:
                    linecleanup = str(line)
                    linecleanup = linecleanup.replace('Exclude:', '')
                    linecleanup = linecleanup.replace('\n', '')
                    linecleanup = linecleanup.replace(' ', '')
                    linecleanup = linecleanup.replace('\\', '')
                    linecleanup = linecleanup.replace('/', '')
                    ignore.append(linecleanup)




g = input("Would you like to update your .dme includes? (Y/N)\n")
if g == 'Y' or g == 'y':

    dme = finddme(currentpath)

    if dme is not None:
        for folderName, subfolders, filenames in os.walk(currentpath + '\\code'):
            for item in filenames:
                if '.dm' in item:
                    if '.dmm' not in item and '.dme' not in item:
                        skip = 0
                        path = folderName
                        path = path.replace(currentpath,'')
                        path = path + '/' + item
                        path = path.replace('/', '\\')
                        path = path[1:]
                        path = '#include "' + path + '"'
                        ignoretest = path.replace('\\', '')
                        ignoretest = ignoretest



                        if len(ignore) >= 1:
                            for each in ignore:
                                if each in ignoretest:
                                    # print('ignore test is ' + ignoretest)
                                    print('Skipping: ' + item + " Matched against filter: " + each)

                                    skip = 1

                        if skip == 0:
                            newincludes = newincludes + path + '\n'


        if newincludes is not None:
            try:
                reading_file = open(dme, "r", encoding="utf8")
                encoding = "utf8"
                replacement(reading_file, encoding)
            except:
                reading_file = open(dme, "r", encoding="ANSI")
                encoding = "ANSI"
                replacement(reading_file, encoding)

            print('DME should be updated! Nice!')


        else:
            print("looks like there's nothing to include? Something broke.")


    else:
        print('dme not found')