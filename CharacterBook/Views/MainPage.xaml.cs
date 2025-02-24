using CharacterBook.Data;
using CharacterBook.ViewModels;

namespace CharacterBook.Views;

public partial class MainPage : ContentPage
{
	CharacterManager characterManager;
	public MainPage()
	{
		InitializeComponent();
		BindingContext = new CharactersViewModel(characterManager);
	}
}

