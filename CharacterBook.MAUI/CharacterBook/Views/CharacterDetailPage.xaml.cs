using CharacterBook.ViewModels;
using CharacterBook.Models;

namespace CharacterBook.Views;

public partial class CharacterDetailPage : ContentPage
{
	private readonly CharacterDetailViewModel viewModel;
	
	public CharacterDetailPage()
	{
		InitializeComponent();
		BindingContext = viewModel = new CharacterDetailViewModel(Navigation);
	}

	public CharacterDetailPage(Character character) : this()
	{
		viewModel.Character = character;
	}
}

