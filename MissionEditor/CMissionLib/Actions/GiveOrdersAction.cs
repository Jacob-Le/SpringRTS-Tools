﻿using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Runtime.Serialization;

namespace CMissionLib.Actions
{
	[DataContract]
	public class GiveOrdersAction : Action
	{
		ObservableCollection<string> groups = new ObservableCollection<string>();
		ObservableCollection<IOrder> orders;

		public GiveOrdersAction()
			: this(new ObservableCollection<IOrder>()) {}

		public GiveOrdersAction(IEnumerable<IOrder> orders)
			: base("Give Orders")
		{
			this.orders = new ObservableCollection<IOrder>(orders);
		}

		[DataMember]
		public ObservableCollection<IOrder> Orders
		{
			get { return orders; }
			set
			{
				orders = value;
				RaisePropertyChanged("Orders");
			}
		}

		[DataMember]
		public ObservableCollection<string> Groups
		{
			get { return groups; }
			set
			{
				groups = value;
				RaisePropertyChanged("Groups");
			}
		}

		public override LuaTable GetLuaTable(Mission mission)
		{
			var map = new Dictionary<string, object>
				{
					{"orders", new LuaTable(orders.Select(o => o.GetLuaMap(mission)).ToArray())},
					{"groups", new LuaTable(groups)}
				};
			return new LuaTable(map);
		}
	}
}