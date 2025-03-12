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

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        await ((CharacterListViewModel)BindingContext).LoadCharacters();
    }

    private async void OnCharacterSelection(object sender, SelectionChangedEventArgs e)
    {
		if (e.CurrentSelection != null)
        {
            await ((CharacterListViewModel)BindingContext).EditCharacterAsync((Character)e.CurrentSelection);
            ((ListView)sender).SelectedItem = null;
        }
    }
}

