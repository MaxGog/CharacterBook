using CharacterBook.ViewModels;

namespace CharacterBook.Views;

public partial class CharacterDetailPage : ContentPage
{
	public CharacterDetailPage()
	{
		InitializeComponent();
		BindingContext = new CharacterDetailViewModel();
	}
}

