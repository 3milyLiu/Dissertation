import csv

from os import listdir
from os.path import isfile, join
csvfiles = [f for f in listdir("./") if isfile(join("./", f))]
filtered = []

for x in range(0, len(csvfiles)-1, 1):
	data = open(csvfiles[x])
	lines = data.readlines()
	data.close()
	columnIndex = -1
	for line in lines:
		originalLine = line
		if line[-1] == "\n":
			line = line[:-1]
			parts = line.split(',')
		if columnIndex == -1:
			columnIndex = parts.index("LSOA name")
			filtered.append(originalLine)
		else:
			if parts[columnIndex] == ("Barking"):
				filtered.append(originalLine)

data = open("bicycle_thefts.csv","w+")
data.writelines(filtered)
data.close()

