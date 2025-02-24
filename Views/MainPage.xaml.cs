using System;
using System.Threading.Tasks;

using Microsoft.Maui.Controls;

using CharacterBook.ViewModels;

namespace CharacterBook.Views;

public partial class MainPage : ContentPage
{
	private readonly CharacterViewModel _viewModel;

	public MainPage(CharacterViewModel viewModel)
	{
		InitializeComponent();
		_viewModel = viewModel;
		BindingContext = _viewModel;

		Task.Run(() => _viewModel.LoadCharactersCommand.Execute(null));
	}
}