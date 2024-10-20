var baseDir = Environment.CurrentDirectory;

var allFiles = Directory.EnumerateFiles($@"{baseDir}\code", "*.dm", SearchOption.AllDirectories).ToList();
var known = new Dictionary<string, List<KeyValuePair<string, int>>>();

foreach (var file in allFiles)
{
	var fileLines = File.ReadAllLines(file);
	for (var i = 0; i < fileLines.Length; i++)
	{
		var line = fileLines[i];
		if (line.StartsWith("/datum/armor/"))
		{
			var armorName = line.Replace("/datum/armor/", "").Trim();
			if (!known.ContainsKey(armorName))
				known[armorName] = new List<KeyValuePair<string, int>>();
			var knownList = known[armorName];
			knownList.Add(new KeyValuePair<string, int>(file, i));
		}
	}
}

Console.WriteLine($"There are {known.Sum(d => d.Value.Count)} duplicate armor datums.");

var duplicates = new Dictionary<string, List<int>>();
foreach (var (_, entries) in known)
{
	var actuals = entries.Skip(1).ToList();
	foreach (var actual in actuals)
	{
		if (!duplicates.ContainsKey(actual.Key))
			duplicates[actual.Key] = new List<int>();
		duplicates[actual.Key].Add(actual.Value);
	}
}

Console.WriteLine($"There are {duplicates.Count} files to update.");

foreach (var (file, idxes) in duplicates)
{
	var fileContents = File.ReadAllLines(file).ToList();
	foreach (var idx in idxes.OrderByDescending(i => i))
	{
		string line;
		do
		{
			line = fileContents[idx];
			fileContents.RemoveAt(idx);
		}
		while (!String.IsNullOrWhiteSpace(line));
	}
	File.WriteAllLines(file, fileContents);
}
