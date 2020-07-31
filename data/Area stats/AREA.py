import csv


data = open('../bicycle_thefts.csv')
lines = data.readlines()
data.close()
columnIndex = -1
filtered = []
for line in lines:
	originalLine = line
	if line[-1] == "\n":
		line = line[:-1]
	parts = line.split(',')
	if columnIndex == -1:
		columnIndex = parts.index("LSOA name")
		filtered.append(originalLine)
	else:
		#if parts[columnIndex] == ("Barking and Dagenham"):
		if "Barking and Dagenham" in parts[columnIndex]:
			filtered.append(originalLine)

data = open("Barking_and_Dagenham.csv","w+")
data.writelines(filtered)
data.close()