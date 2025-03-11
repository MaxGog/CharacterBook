using CharacterBook.ViewModels;

namespace CharacterBook.Views;

public partial class MainPage : ContentPage
{
	public MainPage()
	{
		InitializeComponent();
		BindingContext = new CharactersViewModel();
	}
}

