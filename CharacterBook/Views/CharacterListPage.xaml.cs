using CharacterBook.ViewModels;
using CharacterBook.Models;

namespace CharacterBook.Views;

public partial class CharacterListPage : ContentPage
{
	public CharacterListPage()
	{
		InitializeComponent();
		BindingContext = new CharacterListViewModel(Navigation);
	}

    private async void CharacterSelectionChanged(object sender, SelectionChangedEventArgs e)
    {
		if (e.CurrentSelection != null)
        {
            if (e.CurrentSelection as Character != null)
            {
                await ((CharacterListViewModel)BindingContext).EditCharacterAsync((Character)e.CurrentSelection);
                ((ListView)sender).SelectedItem = null;
            }
        }
    }
}

