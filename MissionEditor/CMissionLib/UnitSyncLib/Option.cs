#region using

using System;
using System.Collections.Generic;

#endregion

namespace CMissionLib.UnitSyncLib
{
	public enum OptionType
	{
		Undefined = 0,
		Bool = 1,
		List = 2,
		Number = 3,
		String = 4,
		Section = 5
	}

	[Serializable]
	public class Option : ICloneable
	{
		const string Table = "GAME/MODOPTIONS/";

		List<ListOption> listOptions = new List<ListOption>();
		float max = float.MinValue;
		float min = float.MinValue;

		float strMaxLen = 65535;

		public string Default { get; set; }
		public string Description { get; set; }
		public string Key { get; set; }

		public List<ListOption> ListOptions
		{
			get { return listOptions; }
			set { listOptions = value; }
		}

		public float Max
		{
			get { return max; }
			set { max = value; }
		}

		public float Min
		{
			get { return min; }
			set { min = value; }
		}

		public string Name { get; set; }
		public string Scope { get; set; }
		public string Section { get; set; }
		public float Step { get; set; }

		public float StrMaxLen
		{
			get { return strMaxLen; }
			set { strMaxLen = value; }
		}

		public string Style { get; set; }
		public OptionType Type { get; set; }

		#region ICloneable Members

		public object Clone()
		{
			var opt = (Option) MemberwiseClone();
			opt.ListOptions = new List<ListOption>(ListOptions.Count);
			foreach (var option in ListOptions) opt.ListOptions.Add((ListOption) option.Clone());
			return opt;
		}

		#endregion

		public string ConstructLine(string val)
		{
			return Table + Key + "=" + val;
		}

		public bool GetPair(string Value, out string result)
		{
			result = "";
			switch (Type)
			{
				case OptionType.Bool:
					if (Value != "0" && Value != "1") return false;
					result = ConstructLine(Value);
					return true;

				case OptionType.Number:
					double d;
					if (!double.TryParse(Value, out d)) return false;
					if (d < min || d > max) return false;
					result = ConstructLine(Value);
					return true;

				case OptionType.String:
					if (strMaxLen != 0 && Value.Length > strMaxLen) return false;
					result = ConstructLine(Value);
					return true;

				case OptionType.List:
					foreach (var lop in ListOptions)
					{
						if (lop.Key == Value)
						{
							result = ConstructLine(lop.Key);
							return true;
						}
					}
					return false;
			}

			return false;
		}

		public override string ToString()
		{
			var pom = "";
			var typs = "";
			if (Type == OptionType.Number)
			{
				typs = "x";
				pom += " = ";
				if (min != float.MinValue) pom += " >=" + min;
				if (max != float.MaxValue) pom += " <=" + max;
			}
			if (Type == OptionType.List)
			{
				pom += " = ";
				foreach (var lop in ListOptions)
				{
					pom += lop.Key + "-" + lop.Description + " | ";
					typs += lop.Key + "|";
				}
			}
			if (Type == OptionType.Bool) typs += "0|1";
			if (Type == OptionType.String) typs += "s";

			return string.Format("{0}={1}  ({2}{3})", Key, typs, Description, pom);
		}
	}
}