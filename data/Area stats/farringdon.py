import csv


data = open('Islington.csv')
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
		columnIndex = parts.index("Location")
		filtered.append(originalLine)
	else:
		#if parts[columnIndex] == ("On or near Farringdon Road"):
		if "On or near Farringdon Road" in parts[columnIndex]:
			filtered.append(originalLine)

data = open("rory.csv","w+")
data.writelines(filtered)
data.close()