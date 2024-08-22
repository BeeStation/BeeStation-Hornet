using System.Text.RegularExpressions;

static string ToSnakeCase(string name)
{
	return Regex.Replace(name, "([a-z])([A-Z])", "$1_$2").ToLower();
}

static bool UpdateFile(string filePath, string oldName, string newName)
{
	var text = File.ReadAllText(filePath);
	var updated = Regex.Replace(text, $@"[^/]{Regex.Escape(oldName)}\(", $"{newName}(", RegexOptions.Multiline);
	updated = Regex.Replace(text, $@"_REF\({Regex.Escape(oldName)}\)", @$"REF\({newName}\)", RegexOptions.Multiline);
	if (updated == text)
		return false;
	File.WriteAllText(filePath, updated);
	return true;
}

string basePath = "../../../../../code";
string regexPattern = @"^\s*(?:\/\w+)*\/?proc\/((?:[a-z]+[A-Z]+[a-z]*_|[a-z]*[A-Z]+[a-z]+_|[A-Z]+[a-z]+[A-Z]+_)+\w*|\w*_(?:[a-z]+[A-Z]+[a-z]*|[a-z]*[A-Z]+[a-z]+|[A-Z]+[a-z]+[A-Z]+)|[a-z]+[A-Z]+[a-z]*|[a-z]*[A-Z]+[a-z]+|[A-Z]+[a-z]+[A-Z]+)+\(";
string ignoreString = "LINT_PATHNAME_IGNORE";
int minFunctionNameLength = 7;

var files = Directory.EnumerateFiles(basePath, "*.dm", SearchOption.AllDirectories);

Dictionary<string, string> updatedFunctionNames = new Dictionary<string, string>();

List<string> skippedFunctionNames = new List<string>();


Console.ForegroundColor = ConsoleColor.Yellow;

foreach (var file in files)
{
	// Skip files containing the ignore string
	var fileContent = File.ReadAllText(file);
	if (fileContent.Contains(ignoreString))
		continue;

	var matches = Regex.Matches(fileContent, regexPattern, RegexOptions.Compiled | RegexOptions.Multiline);

	foreach (Match match in matches)
	{
		var funcName = match.Groups[1].Value;

		// Fine... you get the right to live
		if (funcName == "Initialize" || funcName == "Destroy" || funcName == "Entered" || funcName == "Exited" || funcName == "Animate" || funcName == "Replace" || funcName == "Execute")
		{
			skippedFunctionNames.Add(funcName);
			continue;
		}

		if (!string.IsNullOrEmpty(funcName) && funcName.Length >= minFunctionNameLength)
		{
			string snakeCaseName = ToSnakeCase(funcName);
			updatedFunctionNames.TryAdd(funcName, snakeCaseName);
			Console.WriteLine($"Renaming {funcName} to {snakeCaseName}");
		}
		else
		{
			skippedFunctionNames.Add(funcName);
		}
	}
}

Console.ForegroundColor = ConsoleColor.Green;
Parallel.ForEach(files, (file, _, _) => {
	int updates = 0;
	foreach (var update in updatedFunctionNames)
	{
		updates += UpdateFile(file, update.Key, update.Value) ? 1 : 0;
	}
	if (updates > 0)
		Console.WriteLine($"Updating {file}, applied {updates} updates...");
});
Console.ResetColor();

Console.ForegroundColor = ConsoleColor.Red;
Console.WriteLine($"Skipped the following function names due to being too short to reliably rename:");
foreach (var skipped in skippedFunctionNames)
{
	Console.WriteLine(skipped);
}
Console.ResetColor();
