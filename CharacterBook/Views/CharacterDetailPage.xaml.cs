using CharacterBook.Data;
using CharacterBook.ViewModels;

namespace CharacterBook.Views;

public partial class CharacterDetailPage : ContentPage
{
	private CharacterManager characterManager;
	public CharacterDetailPage()
	{
		InitializeComponent();
		BindingContext = new CharacterDetailViewModel(characterManager);
	}
}

