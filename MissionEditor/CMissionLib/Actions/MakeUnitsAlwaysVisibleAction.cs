﻿using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace CMissionLib.Actions
{
	[DataContract]
	public class MakeUnitsAlwaysVisibleAction : Action
	{
		string group = String.Empty;

		public MakeUnitsAlwaysVisibleAction()
			: base("Make Units Always Visible") {}

		[DataMember]
		public string Group
		{
			get { return group; }
			set
			{
				group = value;
				RaisePropertyChanged("Group");
			}
		}

		public override LuaTable GetLuaTable(Mission mission)
		{
			var map = new Dictionary<string, object>
				{
					{"group", group},
				};
			return new LuaTable(map);
		}
	}
}