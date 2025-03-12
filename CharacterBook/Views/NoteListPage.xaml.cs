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
    private async void OnNoteSelected(object sender, SelectionChangedEventArgs e)
    {
        if (e.CurrentSelection != null)
        {
            await ((NoteListViewModel)BindingContext).EditNoteAsync((Note)e.CurrentSelection.FirstOrDefault());
            ((ListView)sender).SelectedItem = null;
        }
    }

    private void SearchBarTextChanged(object sender, TextChangedEventArgs e)
    {
    }
}
