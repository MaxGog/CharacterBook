using CharacterBook.ViewModels;

namespace CharacterBook.Views;

public partial class CharacterListPage : ContentPage
{
	public CharacterListPage()
	{
		InitializeComponent();
		BindingContext = new CharacterListViewModel();
	}
}

