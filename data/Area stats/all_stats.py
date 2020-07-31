import csv

data = open('../bicycle_thefts.csv')

borough = ["Camden","Greenwich","Hackney","Hammersmith and Fulham","Islington", "Kensington and Chelsea", "Lambeth", "Lewisham", "Southwark", "Tower Hamlets", "Wandsworth", "Westminster", "Barking and Dagenham", "Barnet", "Bexley", "Bromley", "Croydon", "Ealing", "Enfield", "Haringey", "Harrow", "Havering", "Hillingdon", "Hounslow", "Kingston", "Merton", "Newham", "Redbridge", "Richmond", "Sutton", "Waltham Forest"]

lines = data.readlines()
data.close()
columnIndex = -1
filtered = []
for x in range(0, len(borough)-1, 1):
	for line in lines:
		originalLine = line
		if line[-1] == "\n":
			line = line[:-1]
		parts = line.split(',')
		if columnIndex == -1:
			columnIndex = parts.index("LSOA name")
			filtered.append(originalLine)
		else:
			if borough[x] in parts[columnIndex]:
				filtered.append(originalLine)	
	data = open(borough[x]".csv","w+")
	data.writelines(filtered)
	data.close()

