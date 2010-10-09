﻿using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace CMissionLib.Actions
{
	[DataContract]
	public class SetCameraPointTargetAction : Action
	{
		public SetCameraPointTargetAction(double x, double y)
			: base("Map Camera")
		{
			Text = String.Empty;
			this.Y = y;
			this.X = x;
		}

		[DataMember]
		public double Y { get; set; }

		[DataMember]
		public double X { get; set; }

		[DataMember]
		public string Text { get; set; }


		public override LuaTable GetLuaTable(Mission mission)
		{
			var map = new Dictionary<string, object>
				{
					{"x", mission.ToIngameX(X)},
					{"y", mission.ToIngameY(Y)},
				};
			return new LuaTable(map);
		}
	}
}