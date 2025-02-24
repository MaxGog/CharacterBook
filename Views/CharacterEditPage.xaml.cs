using System;
using System.Threading.Tasks;
using Microsoft.Maui.Controls;

using CharacterBook.Models;
using CharacterBook.Data;
using CharacterBook.ViewModels;

namespace CharacterBook.Views;

public partial class CharacterEditPage : ContentPage
{
	private readonly CharacterEditViewModel _viewModel;

        public CharacterEditPage(CharacterEditViewModel viewModel)
        {
            InitializeComponent();
            _viewModel = viewModel;
            BindingContext = _viewModel;
        }

        protected override async void OnAppearing()
        {
            base.OnAppearing();
            await _viewModel.InitializeAsync((int?)Shell.Current.RouteParameters["characterId"]);
        }
}