using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SaveAnalyser
{
	internal static class StringExtensions
	{

		public static string? GetParentPath(this string typepath)
		{
			if (typepath == "/datum")
				return null;
			int lastIndexOf = typepath.LastIndexOf('/');
			if (lastIndexOf <= 0)
			{
				return "/datum";
			}
			return typepath.Substring(0, lastIndexOf);
		}

	}
}
