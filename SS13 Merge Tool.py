import re
import git
import os
import shutil
import errno
import filecmp
from scandir import scandir, walk

currentpath = os.getcwd()
folderName = ''
subfolders = ''
filenames = ''
ignore = []
master = []
readconfig = 1
replacements = 0

def replacement(reading_file, encoding):
    new_file_content = ""
    newreplacements = 0
    previousline = ''

    if 'regex' not in var1 and 'linebreakdestroyer' != var1 and 'doublelinebreakdestroyer' != var1:
        for line in reading_file:
            stripped_line = line.strip()

            new_line = stripped_line.replace(var1, var2)

            if new_line != stripped_line:
                newreplacements = newreplacements + 1

            new_file_content += new_line + "\n"

    if 'linebreakdestroyer' == var1:
        for line in reading_file:
            stripped_line = line.strip()
            new_line = stripped_line

            if new_line == '':
                newreplacements = newreplacements + 1
            else:
                new_file_content += new_line + "\n"

    if 'doublelinebreakdestroyer' == var1:
        for line in reading_file:
            stripped_line = line.strip()
            new_line = stripped_line

            if previousline == '' and new_line == '':
                newreplacements = newreplacements + 1
            else:
                new_file_content += new_line

            previousline = new_line

    if 'regex' in var1:
        for line in reading_file:
            stripped_line = line
            regextouse = var1.replace('regex', '')
            stufftoremove = re.findall(rf'{regextouse}', stripped_line)

            if stufftoremove is not None and str(stufftoremove) != '' and len(stufftoremove) >=1:
                for remove in stufftoremove:
                    new_line = stripped_line.replace(remove, var2)
            else:
                new_line = stripped_line

            if new_line != stripped_line:
                newreplacements = newreplacements + 1

            new_file_content += new_line

    reading_file.close()

    writing_file = open(folderName + '\\' + each, "w", encoding=encoding)
    writing_file.write(new_file_content)
    writing_file.close()
    return newreplacements


readconfig = input("Would you like to run the automation - Make sure you've taken a backup, and have updated Config.txt (Y/N) ")
if 'y' in readconfig or 'Y' in readconfig:
    path = input("Please provide the full directory path of the folder you'd like to run against (Currently only folders)")


    filepath = 'Config.txt'
    with open(filepath) as fp:
        line = fp.readline()
        cnt = 1
        while line:
            line = fp.readline()
            cnt += 1
            if '#' not in line and line != '\n' and line != '':

                if 'Replace' in line:
                    replaceextractor = re.findall(r'"(.*?)"', line)
                    if replaceextractor is not None:

                        var1 = str(replaceextractor[0])
                        var2 = str(replaceextractor[1])

                        for folderName, subfolders, filenames in os.walk(path):
                            for each in filenames:
                                if '.txt' in each or '.json' in each or '.dme' in each or '.yml' in each or '.dm' in each:
                                    if '.dmm' not in each and '.dmi' not in each:
                                        try:
                                            reading_file = open(folderName + '\\' + each, "r", encoding="utf8")
                                            encoding = "utf8"
                                            replacements = replacements + replacement(reading_file, encoding)
                                        except:
                                            reading_file = open(folderName + '\\' + each, "r", encoding="ANSI")
                                            encoding = "ANSI"
                                            replacements = replacements + replacement(reading_file, encoding)

                        print('Finished Replace Process')


        print("\n\nReplacements Made: " + str(replacements))




