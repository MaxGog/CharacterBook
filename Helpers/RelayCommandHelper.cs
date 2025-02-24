using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Windows.Input;

using CommunityToolkit.Mvvm;

namespace CharacterBook.Helpers;

public class RelayCommand : ICommand
{
    private readonly Action execute;
    private readonly Func<bool> canExecute;

    public RelayCommand(Action execute)
        : this(execute, null)
    { }

    public RelayCommand(Action execute, Func<bool> canExecute)
    {
        if (execute == null)
            throw new ArgumentNullException(nameof(execute));

        this.execute = execute;
        this.canExecute = canExecute;
        //SimpleCommandManager.AddRaiseCanExecuteChangedAction(ref RaiseCanExecuteChanged);
    }

    ~RelayCommand()
    {
        RemoveCommand();
    }

    public void RemoveCommand()
    {
        SimpleCommandManager.RemoveRaiseCanExecuteChangedAction(RaiseCanExecuteChanged);
    }

    bool ICommand.CanExecute(object parameter)
    {
        return canExecute?.Invoke() ?? true;
    }

    public void Execute(object parameter)
    {
        execute();
        SimpleCommandManager.RefreshCommandStates();
    }

    public void RaiseCanExecuteChanged()
    {
        var handler = CanExecuteChanged;
        handler?.Invoke(this, EventArgs.Empty);
    }

    //private readonly Action RaiseCanExecuteChanged;

    public event EventHandler CanExecuteChanged;
}

public static class SimpleCommandManager
{
    private static List<Action> _raiseCanExecuteChangedActions = new List<Action>();

    public static void AddRaiseCanExecuteChangedAction(ref Action raiseCanExecuteChangedAction)
    {
        _raiseCanExecuteChangedActions.Add(raiseCanExecuteChangedAction);
    }

    public static void RemoveRaiseCanExecuteChangedAction(Action raiseCanExecuteChangedAction)
    {
        _raiseCanExecuteChangedActions.Remove(raiseCanExecuteChangedAction);
    }

    public static void RefreshCommandStates()
    {
        foreach (var action in _raiseCanExecuteChangedActions.ToArray())
        {
            action?.Invoke();
        }
    }
}