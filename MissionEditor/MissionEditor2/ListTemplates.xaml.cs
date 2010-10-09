﻿using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Shapes;
using CMissionLib;
using CMissionLib.Actions;
using CMissionLib.Conditions;
using Action = CMissionLib.Action;

namespace MissionEditor2
{
	/// <summary>
	/// Here go templates that need to be reloaded each time.
	/// </summary>
	public partial class ListTemplates : UserControl
	{
		public ListTemplates()
		{
			InitializeComponent();
			camera.Width = 50;
			camera.Height = 50;
		}

		void Triggers_ListLoaded(object sender, RoutedEventArgs e)
		{
			var list = (ListBox) e.Source;
			var collection = ((TriggersAction) MainWindow.Instance.CurrentLogic).Triggers;
			list.BindCollection(collection);
		}

		void UnitDefGrid_Loaded(object sender, RoutedEventArgs e)
		{
			var dataGrid = ((UnitDefsGrid)e.Source).Grid;
			var currentLogic = MainWindow.Instance.CurrentLogic;
			ObservableCollection<string> units = null;
			if (currentLogic is UnitCreatedCondition)
			{
				units = ((UnitCreatedCondition)currentLogic).Units;
			}
			else if (currentLogic is UnitFinishedCondition)
			{
				units = ((UnitFinishedCondition)currentLogic).Units;
			}
			else if (currentLogic is LockUnitsAction)
			{
				units = ((LockUnitsAction)currentLogic).Units;
			}
			else if (currentLogic is UnlockUnitsAction)
			{
				units = ((UnlockUnitsAction)currentLogic).Units;
			}

			if (units == null) return;

			foreach (var unit in units.ToArray())
			{
				var unitInfo = MainWindow.Instance.Mission.Mod.UnitDefs.FirstOrDefault(u => u.Name == unit);
				if (unitInfo != null)
				{
					dataGrid.SelectedItems.Add(unitInfo);
				}
			}
			SelectionChangedEventHandler handler = (s, se) =>
				{
					foreach (var item in se.AddedItems)
					{
						units.Add(item.ToString());
					}
					foreach (var item in se.RemovedItems)
					{
						units.Remove(item.ToString());
					}
				};
			dataGrid.SelectionChanged += handler;
			// this needs to be done before "Unloaded" because at that point the items will have been all deselected
			MainWindow.Instance.LogicGrid.SelectionChanged += (s, ea) => dataGrid.SelectionChanged -= handler;
		}


		void PlayersList_Loaded(object sender, RoutedEventArgs e)
		{
			var unitList = (ListBox) e.Source;
			var currentLogic = MainWindow.Instance.CurrentLogic;
			if (currentLogic is UnitCreatedCondition)
			{
				unitList.BindCollection(((UnitCreatedCondition) currentLogic).Players);
			}
			else if (currentLogic is UnitFinishedCondition)
			{
				unitList.BindCollection(((UnitFinishedCondition)currentLogic).Players);
			}
		}

		Canvas flagPole = (Canvas) MainWindow.Vectors.FindResource("flagPole");
		Point poleBase = new Point(0, 0);
		Viewbox camera = (Viewbox) MainWindow.Vectors.FindResource("camera");

		void MarkerPointCanvas_Loaded(object sender, RoutedEventArgs e)
		{
			var currentLogic = MainWindow.Instance.CurrentLogic;
			if (currentLogic is MarkerPointAction)
			{
				var action = (MarkerPointAction) currentLogic;
				var markerCanvas = (Canvas) e.Source;
				markerCanvas.Children.Add(flagPole);
				foreach (var unit in MainWindow.Instance.Mission.AllUnits) markerCanvas.PlaceUnit(unit);
				System.Action refreshPosition = delegate
					{
						Canvas.SetLeft(flagPole, action.X - poleBase.X);
						Canvas.SetTop(flagPole, action.Y - flagPole.Height + poleBase.Y);
					};
				refreshPosition();
				markerCanvas.MouseDown += (s, ea) =>
					{
						var mousePos = ea.GetPosition(markerCanvas);
						action.X = mousePos.X;
						action.Y = mousePos.Y;
						refreshPosition();
					};
				markerCanvas.Unloaded += (s, ea) => markerCanvas.Children.Clear();
			}
			else if (currentLogic is SetCameraPointTargetAction)
			{
				var action = (SetCameraPointTargetAction) currentLogic;
				var markerCanvas = (Canvas) e.Source;
				markerCanvas.Children.Add(camera);
				foreach (var unit in MainWindow.Instance.Mission.AllUnits) markerCanvas.PlaceUnit(unit);
				System.Action refreshPosition = delegate
					{
						Canvas.SetLeft(camera, action.X - poleBase.X);
						Canvas.SetTop(camera, action.Y - flagPole.Height + poleBase.Y);
					};
				markerCanvas.MouseDown += (s, ea) =>
				{
					var mousePos = ea.GetPosition(markerCanvas);
					action.X = mousePos.X;
					action.Y = mousePos.Y;
					refreshPosition();
				};
			}
		}




		void AddCounterButton_Click(object sender, RoutedEventArgs e)
		{
			var dialog = new StringRequest {Title = "Insert counter name."};
			var result = dialog.ShowDialog();
			if (result.HasValue && result.Value) MainWindow.Instance.Mission.Counters.Add(dialog.TextBox.Text);
		}

		void RemoveCounterButton_Click(object sender, RoutedEventArgs e)
		{
			var dialog = new StringRequest {Title = "Insert counter name."};
			var result = dialog.ShowDialog();
			if (result.HasValue && result.Value && !MainWindow.Instance.Mission.Counters.Remove(dialog.TextBox.Text))
			{
				MessageBox.Show("Error: counter " + dialog.TextBox.Text + " does not exist.");
			}
		}
	}
}