using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace CharacterBook.ViewModels;

public class BaseViewModel : INotifyPropertyChanged
{
    protected void SetProperty<T>(ref T field, T newValue, [CallerMemberName] string propertyName = null)
    {
        field = newValue;
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }

    public event PropertyChangedEventHandler PropertyChanged;
}