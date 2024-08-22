using System.Text.RegularExpressions;

static string ToSnakeCase(string name)
{
	return Regex.Replace(name, "([a-z])([A-Z])", "$1_$2").ToLower();
}

static void UpdateFile(string filePath, string oldName, string newName)
{
	var text = File.ReadAllText(filePath);
	var updated = Regex.Replace(text, $@"\b{Regex.Escape(oldName)}\(", $"{newName}(", RegexOptions.Multiline);
	if (updated == text)
		return;
	Console.WriteLine($"Updated {oldName} to {newName} in {filePath}");

	File.WriteAllText(filePath, updated);
}

string basePath = "../../../../../code";
string regexPattern = @"^\s*(?:\/\w+)*\/?proc\/((?:[a-z]+[A-Z]+[a-z]*_|[a-z]*[A-Z]+[a-z]+_|[A-Z]+[a-z]+[A-Z]+_)+\w*|\w*_(?:[a-z]+[A-Z]+[a-z]*|[a-z]*[A-Z]+[a-z]+|[A-Z]+[a-z]+[A-Z]+)|[a-z]+[A-Z]+[a-z]*|[a-z]*[A-Z]+[a-z]+|[A-Z]+[a-z]+[A-Z]+)+\(";
string ignoreString = "LINT_PATHNAME_IGNORE";
int minFunctionNameLength = 7;

var files = Directory.EnumerateFiles(basePath, "*.dm", SearchOption.AllDirectories);

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
		if (funcName == "Initialize")
			continue;

		if (!string.IsNullOrEmpty(funcName) && funcName.Length >= minFunctionNameLength)
		{
			string snakeCaseName = ToSnakeCase(funcName);

			Console.ForegroundColor = ConsoleColor.Green;
			Console.WriteLine($"Updating function {funcName} to {snakeCaseName} in {file}");
			Console.ResetColor();

			// Update function references in the entire codebase
			foreach (var refFile in files)
			{
				UpdateFile(refFile, funcName, snakeCaseName);
			}
		}
		else
		{
			Console.ForegroundColor = ConsoleColor.Red;
			Console.WriteLine($"Skipped {funcName}");
			Console.ResetColor();
		}
	}
}
