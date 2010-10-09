﻿using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using CMissionLib;
using CMissionLib.Actions;
using CMissionLib.Conditions;

namespace MissionEditor2
{
    class LogicTemplateSelector : DataTemplateSelector
    {
        public override DataTemplate SelectTemplate(object item, DependencyObject container)
        {
            if (DesignerProperties.GetIsInDesignMode(container) || item == null) return null;
            string resourceName = null;

            if (item is ConsoleMessageAction) resourceName = "showConsoleMessageTemplate";
            else if (item is GiveOrdersAction) resourceName = "giveOrdersActionTemplate";
            else if (item is GameStartedCondition) resourceName = "gameStartedConditionTemplate";
            else if (item is TimeCondition) resourceName = "timeConditionTemplate";
            else if (item is GameEndedCondition) resourceName = "gameEndedConditionTemplate";
            else if (item is PlayerDiedCondition) resourceName = "playerDiedConditionTemplate";
            else if (item is VictoryAction) resourceName = "victoryActionTemplate";
            else if (item is DefeatAction) resourceName = "defeatActionTemplate";
            else if (item is GuiMessageAction) resourceName = "guiMessageTemplate";
            else if (item is UnitDestroyedCondition) resourceName = "unitDestroyedTemplate";
            else if (item is DummyCondition || item is DummyAction) resourceName = "dummyTemplate";
            else if (item is SoundAction) resourceName = "soundTemplate";
            else if (item is SunriseAction) resourceName = "sunriseTemplate";
            else if (item is SunsetAction) resourceName = "sunsetTemplate";
            else if (item is ModifyScoreAction) resourceName = "modifyScoreTemplate";
            else if (item is SendScoreAction) resourceName = "sendScoreTemplate";
            else if (item is WaitAction) resourceName = "waitActionTemplate";
            if (resourceName != null) return (DataTemplate)Application.Current.MainWindow.FindResource(resourceName);
            
            // list templates that need to be reloaded
            return (DataTemplate)new ListTemplates().FindResource(item.GetType().Name);
        }
    }
}