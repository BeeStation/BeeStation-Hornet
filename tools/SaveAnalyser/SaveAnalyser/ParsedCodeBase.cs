using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace SaveAnalyser
{
	internal class ParsedCodeBase
	{

		public ConcurrentDictionary<string, ParsedDatum> ParsedDatums { get; set; } = new ConcurrentDictionary<string, ParsedDatum>();

		public ParsedDatum GetOrCreate(string datumPath)
		{
			return ParsedDatums.GetOrAdd(datumPath, dPath => {
				ParsedDatum createdDatum = new ParsedDatum(this, dPath);
				ParsedDatums.TryAdd(dPath, createdDatum);
				return createdDatum;
			});
		}

		//Used to get all of the stuff we care about parsing
		//Note that this doesn't handle /datum/tgs_event_handler/impl/var/thing but I don't care
		private static Regex datumPathRegex = new Regex(@"((?:^|\n)((?:\/(?:\w)+)+)(?:\n|\r)+(?:(.|\n|\r)*?))(?=(?:^|\n)(?:\/(:?\w)+)+|$)", RegexOptions.Compiled);
		private static Regex saveSafeRegex = new Regex(@"flags_1\s*=.*SAVE_SAFE_1", RegexOptions.Compiled);

		public void ParseFile(string fileText)
		{
			MatchCollection matches = datumPathRegex.Matches(fileText);
			foreach (Match match in matches)
			{
				string typePath = match.Groups[2].Value;
				if (typePath == "/obj/item/gun/energy/laser/instakill")
					;
				ParsedDatums.AddOrUpdate(typePath,
					path => {
						ParsedDatum createdDatum = new ParsedDatum(this, path);
						Match flag1Match = saveSafeRegex.Match(match.Groups[1].Value);
						if (!flag1Match.Success)
						{
							// Detect overrides
							if (match.Groups[1].Value.Contains("flags_1"))
								createdDatum.AddVar("save_safe", false);
							return createdDatum;
						}
						createdDatum.AddVar("save_safe", true);
						return createdDatum;
					},
					(path, parsedDatum) => {
						Match flag1Match = saveSafeRegex.Match(match.Groups[1].Value);
						if (!flag1Match.Success)
						{
							// Detect overrides
							if (match.Groups[1].Value.Contains("flags_1"))
								parsedDatum.AddVar("save_safe", false);
							return parsedDatum;
						}
						parsedDatum.AddVar("save_safe", true);
						return parsedDatum;
					});
			}
		}

	}
}
