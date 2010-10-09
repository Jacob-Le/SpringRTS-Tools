﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Diagnostics;
using CMissionLib;

namespace MissionEditor2
{
    /// <summary>
    /// Interaction logic for UnitIcon.xaml
    /// </summary>
    public partial class UnitIcon : UserControl
    {
        public UnitIcon()
        {
            InitializeComponent();
        }

#if false // does not work when the rotatetransform is applied

        public static DependencyObject GetParentObject(DependencyObject child)
        {
            if (child == null) return null;
            var contentElement = child as ContentElement;
            if (contentElement != null) {
                var parent = ContentOperations.GetParent(contentElement);
                if (parent != null) return parent;
                var fce = contentElement as FrameworkContentElement;
                return fce != null ? fce.Parent : null;
            }
            return VisualTreeHelper.GetParent(child);
        }

        public static T TryFindParent<T>(DependencyObject child)  where T : DependencyObject
        {
            var parentObject = GetParentObject(child);
            if (parentObject == null) return null;
            var parent = parentObject as T;
            return parent ?? TryFindParent<T>(parentObject);
        }



        void onDragDelta(object sender, DragDeltaEventArgs e)
        {
            var item = TryFindParent<ListBoxItem>(this);
            if (item == null) return;
            Canvas.SetLeft(item, Canvas.GetLeft(item) + e.HorizontalChange);
            Canvas.SetTop(item, Canvas.GetTop(item) + e.VerticalChange);
            e.Handled = true;
        }

#endif

        private void onRotateDelta(object sender, DragDeltaEventArgs e)
        {
            var unit = (UnitStartInfo)DataContext;
            var newHeading = unit.Heading + e.HorizontalChange;
            while (newHeading > 360) newHeading = newHeading - 360;
            while (newHeading < 0) newHeading = newHeading + 360;
            unit.Heading = newHeading;
            e.Handled = true;
        }

        public static readonly RoutedEvent UnitRequestedDeleteEvent = EventManager.RegisterRoutedEvent("UnitRequestedDelete", RoutingStrategy.Direct, typeof(UnitEventHandler), typeof(UnitIcon));
        public static readonly RoutedEvent UnitRequestedSetGroupsEvent = EventManager.RegisterRoutedEvent("UnitRequestedSetGroups", RoutingStrategy.Direct, typeof(UnitEventHandler), typeof(UnitIcon));

        public event UnitEventHandler UnitRequestedSetGroups
        {
            add { AddHandler(UnitRequestedSetGroupsEvent, value); }
            remove { RemoveHandler(UnitRequestedSetGroupsEvent, value); }
        }

        public event UnitEventHandler UnitRequestedDelete
        {
            add { AddHandler(UnitRequestedDeleteEvent, value); }
            remove { RemoveHandler(UnitRequestedDeleteEvent, value); }
        }

        void RaiseUnitRequestedDeleteEvent()
        {
            var unitInfo = (UnitStartInfo)DataContext;
            if (unitInfo == null) Debugger.Break();
            var newEventArgs = new UnitEventArgs(unitInfo, UnitRequestedDeleteEvent);
            RaiseEvent(newEventArgs);
        }

        void RaiseUnitRequestedSetGroupsEvent()
        {
            var unitInfo = (UnitStartInfo)DataContext;
            if (unitInfo == null) Debugger.Break();
            var newEventArgs = new UnitEventArgs(unitInfo, UnitRequestedSetGroupsEvent);
            RaiseEvent(newEventArgs);
        }

        private void DeleteItem_Click(object sender, RoutedEventArgs e)
        {
            RaiseUnitRequestedDeleteEvent();
        }

        private void SetGroupsItem_Click(object sender, RoutedEventArgs e)
        {
            RaiseUnitRequestedSetGroupsEvent();
        }

    }

    public class UnitEventArgs : RoutedEventArgs
    {
        public UnitStartInfo UnitInfo { get; set; }
        public UnitEventArgs(UnitStartInfo unitInfo, RoutedEvent routedEvent):base(routedEvent)
        {
            UnitInfo = unitInfo;
        }
    }

    public delegate void UnitEventHandler(object sender, UnitEventArgs e);

}
