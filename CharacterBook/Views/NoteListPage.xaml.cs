using CharacterBook.Models;
using CharacterBook.ViewModels;

namespace CharacterBook.Views;

public partial class NoteListPage : ContentPage
{
	public NoteListPage()
    {
        InitializeComponent();
        BindingContext = new NoteListViewModel(Navigation);
    }

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        await ((NoteListViewModel)BindingContext).LoadNotesAsync();
    }
    private async void OnNoteSelected(object sender, SelectedItemChangedEventArgs e)
    {
        if (e.SelectedItem != null)
        {
            if (e.SelectedItem as Note != null)
            {
                await ((NoteListViewModel)BindingContext).EditNoteAsync((Note)e.SelectedItem);
                ((ListView)sender).SelectedItem = null;
            }
        }
    }

    private void SearchBarTextChanged(object sender, TextChangedEventArgs e)
    {
    }
}
