using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SaveAnalyser
{
	internal class ParsedDatum
	{

		public string Typepath { get; }

		public List<string> ReferencedFiles { get; } = new List<string>();

		private ParsedCodeBase attachedCodebase;

		private ParsedDatum? _cachedParent = null;
		public ParsedDatum? Parent
		{
			get
			{
				if (_cachedParent != null)
					return _cachedParent;
				string? parentPath = Typepath.GetParentPath();
				if (parentPath == null)
					return null;
				_cachedParent = attachedCodebase.GetOrCreate(parentPath);
				return _cachedParent;
			}
		}

		public List<ParsedDatum> Children { get; } = new List<ParsedDatum>();

		public Dictionary<string, object> Variables { get; } = new Dictionary<string, object>();

		public ParsedDatum(ParsedCodeBase codebase, string typepath)
		{
			attachedCodebase = codebase;
			Typepath = typepath;
			Parent?.Children.Add(this);
		}

		public object? GetVar(string varName)
		{
			if (Variables.ContainsKey(varName))
				return Variables[varName];
			return Parent?.GetVar(varName);
		}

		public void AddVar(string varName, object varValue)
		{
			if (Variables.ContainsKey(varName))
				Variables[varName] = varValue;
			else
				Variables.Add(varName, varValue);
		}

	}
}
