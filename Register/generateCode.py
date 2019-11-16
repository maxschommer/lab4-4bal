
def repeatNTimes(inputStr, numTimes, delim="", end=""):
	res = [] 
	for i in range(numTimes):
		res.append(inputStr.format(i))
	res = delim.join(res)
	return res + end

def saveToFile(fname, string):
	file = open(fname, 'w')
	file.write(string)
	file.close()