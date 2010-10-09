﻿using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Windows;
using System.Windows.Media;
using CMissionLib;
using CMissionLib.UnitSyncLib;
using Microsoft.Win32;
using MissionEditor2.Properties;
using Action = System.Action;

namespace MissionEditor2
{
	/// <summary>
	/// Interaction logic for WelcomeWindow.xaml
	/// </summary>
	public partial class WelcomeDialog : Window
	{
		const int version = 25;
		public const string MissionExtension = "mission.xml";

		public static string MissionDialogFilter =
			String.Format("Spring Mission files (*.{0})|*.{0}|Mutator (*.sdz)|*.sdz|All files (*.*)|*.*", MissionExtension);

		public WelcomeDialog()
		{
			InitializeComponent();
			springExeBox.Loaded += (s, ea) => UpdateDialog();
			springExeBox.TextChanged += (s, ea) => UpdateDialog();
		}

		void Hyperlink_Click(object sender, RoutedEventArgs e)
		{
			try
			{
				Process.Start("http://planet-wars.eu/missioneditor/");
			}
			catch {}
		}


		void Window_Loaded(object sender, RoutedEventArgs e)
		{

			mapDetailSlider.Value = Settings.Default.MapDetail;
			mapDetailSlider.ValueChanged += (s, ea) =>
				{
					Settings.Default.MapDetail = (int) ea.NewValue;
					Settings.Default.Save();
				};

			if (!String.IsNullOrEmpty(Settings.Default.SpringPath))
			{
				springExeBox.Text = Settings.Default.SpringPath + "\\spring.exe";
			}
			else
			{
				springExeBox.Text = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles) + "\\Spring\\Spring.exe";
			}

			Utils.InvokeInNewThread(() =>
			{
				try
				{
					using (var client = new WebClient())
					{
						const string latestVersionPath = "http://planet-wars.eu/missioneditor/latest.txt";
						var latestVersion = int.Parse(client.DownloadString(latestVersionPath));
						if (latestVersion > version)
						{
							this.Invoke(() => LinkBox.Visibility = Visibility.Visible);
						}
					}
				}
				catch { }
			});
		}

		void UpdateDialog()
		{
			if (File.Exists(springExeBox.Text))
			{
				NewMissionButton.IsEnabled = true;
				LoadMissionButton.IsEnabled = true;
				// enabled if last saved mission exists
				ContinueMissionButton.IsEnabled = File.Exists(Settings.Default.MissionPath);
				springExeBox.Background = Brushes.LightGreen;
				Settings.Default.SpringPath = Path.GetDirectoryName(springExeBox.Text);
				Settings.Default.Save();
			}
			else
			{
				NewMissionButton.IsEnabled = false;
				LoadMissionButton.IsEnabled = false;
				ContinueMissionButton.IsEnabled = false;
				springExeBox.Background = Brushes.Pink;
			}
		}

		void ReturnMission()
		{
			DialogResult = true;
			Close();
		}

		void NewMissionButton_Click(object sender, RoutedEventArgs e)
		{
			PromptForNewMission();
			ReturnMission();
		}

		public static void AskForExistingMission()
		{
			var missionDialogFilter =
				String.Format("Spring Mission files (*.{0})|*.{0}|Mutator (*.sdz)|*.sdz|All files (*.*)|*.*", MissionExtension);

			var openFileDialog = new OpenFileDialog
				{DefaultExt = MissionExtension, Filter = missionDialogFilter, RestoreDirectory = true};

			if (openFileDialog.ShowDialog() == true)
			{
				LoadExistingMission(openFileDialog.FileName);
			}
		}

		void LoadMissionButton_Click(object sender, RoutedEventArgs e)
		{
			AskForExistingMission();
			ReturnMission();
		}

		void ContinueMissionButton_Click(object sender, RoutedEventArgs e)
		{
			var missionPath = Settings.Default.MissionPath;
			if (File.Exists(missionPath))
			{
				LoadExistingMission(missionPath);
				ReturnMission();
			}
		}


		public static Map LoadMap(UnitSync unitSync, string mapName)
		{
			var map = unitSync.GetMapNoBitmaps(mapName);
			map.Texture = unitSync.GetMapTexture(map, Settings.Default.MapDetail);
			return map;
		}

		public static Mod LoadMod(UnitSync unitSync, string modName)
		{
			return unitSync.GetMod(modName);
		}

		public static void LoadExistingMission(string fileName)
		{
			var loadingDialog = new LoadingDialog();
			loadingDialog.Loaded += (s, e) => Utils.InvokeInNewThread(delegate 
				{
					var mission = Mission.FromFile(fileName);
					loadingDialog.Text = "Scanning";
					using (var unitSync = new UnitSync(Settings.Default.SpringPath))
					{
						loadingDialog.Text = "Loading Map";
						mission.Map = LoadMap(unitSync, mission.MapName);
						loadingDialog.Text = "Loading Mod";
						mission.Mod = LoadMod(unitSync, mission.ModName);
					}

					loadingDialog.Text = "Finalizing";
					mission.RestoreUnitDefs();
					Settings.Default.MissionPath = fileName;
					Settings.Default.Save();
					loadingDialog.Invoke(delegate
						{
							loadingDialog.Close();
							MainWindow.Instance.SavePath = fileName;
							MainWindow.Instance.Mission = mission;
						});
				});
			loadingDialog.ShowDialog();
		}

		public static void PromptForNewMission()
		{
			
			var dialog = new NewMissionDialog();
			dialog.ProgressBar.Visibility = Visibility.Visible;
			Utils.InvokeInNewThread(delegate
				{
					IEnumerable<string> modNames;
					IEnumerable<string> mapNames;
					using (var unitSync = new UnitSync(Settings.Default.SpringPath))
					{
						modNames = unitSync.GetModNames();
						mapNames = unitSync.GetMapNames();
					}
					dialog.Invoke(delegate
						{
							dialog.MapList.ItemsSource = mapNames;
							dialog.ModList.ItemsSource = modNames;
							dialog.ProgressBar.Visibility = Visibility.Hidden;
						});
				});
			if (dialog.ShowDialog() == true)
			{
				MainWindow.Instance.SavePath = null;
				var mapName = (string) dialog.MapList.SelectedItem;
				var gameName = (string) dialog.ModList.SelectedItem;
				var missionName = dialog.NameBox.Text;
				var loadingDialog = new LoadingDialog();

				loadingDialog.Loaded += delegate
					{
						Utils.InvokeInNewThread(delegate
							{
								Mission mission;
								loadingDialog.Text = "Scanning";
								using (var unitSync = new UnitSync(Settings.Default.SpringPath))
								{
									loadingDialog.Text = "Loading Map";
									var map = LoadMap(unitSync, mapName);
									loadingDialog.Text = "Loading Mod";
									var mod = LoadMod(unitSync, gameName);
									mission = new Mission(missionName, mod, map);
								}

								dialog.Invoke(delegate
									{
										MainWindow.Instance.Mission = mission;
										loadingDialog.Close();
									});
							});
					};
				loadingDialog.ShowDialog();
			}
		}

		void springExeButton_Click(object sender, RoutedEventArgs e)
		{
			const string dialogFilter = "Spring Executable (spring.exe)|spring.exe|All files (*.*)|*.*";
			var openFileDialog = new OpenFileDialog
				{DefaultExt = MissionExtension, Filter = dialogFilter, RestoreDirectory = true};
			if (openFileDialog.ShowDialog() == true)
			{
				springExeBox.Text = openFileDialog.FileName;
			}
		}
	}
}