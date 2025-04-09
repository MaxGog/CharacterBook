using CharacterBook.Models;
using CharacterBook.ViewModels;

namespace CharacterBook.Views;

public partial class NoteEditorPage : ContentPage
{
    private readonly NoteEditorViewModel viewModel;
	public NoteEditorPage()
    {
        InitializeComponent();
        BindingContext = viewModel = new NoteEditorViewModel(Navigation, noteEditor);
    }
    public NoteEditorPage(Note note) : this()
    {
        viewModel.Content = note.Content;
        //viewModel.Title = note.Title;
        viewModel.id = note.Id;
    }
}

