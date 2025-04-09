using System.Collections.ObjectModel;
using System.Windows.Input;
using System.Runtime.CompilerServices;
using System.ComponentModel;

using CharacterBook.Models;
using CharacterBook.Views;
using CharacterBook.Services;

namespace CharacterBook.ViewModels;

public class NoteListViewModel : BaseViewModel
{
    private readonly INavigation navigation;
    private readonly NoteStorageService noteStorageService;
    private ObservableCollection<Note> notes;

    public ICommand AddNoteCommand { get; }
    public ICommand EditNoteCommand { get; }
    public ICommand SortCommand { get; private set; }

    public NoteListViewModel(INavigation navigation, NoteStorageService storageService = null)
    {
        this.navigation = navigation;
        noteStorageService = storageService ?? new NoteStorageService();
        Notes = new ObservableCollection<Note>();
        AddNoteCommand = new Command(async () => await AddNoteAsync());
        EditNoteCommand = new Command<Note>(async (note) => await EditNoteAsync(note));
        SortCommand = new Command(sortedBy => SortNotes((string)sortedBy));
    }

    public ObservableCollection<Note> Notes
    {
        get => notes;
        set => SetProperty(ref notes, value);
    }

    public async Task LoadNotesAsync()
    {
        try { Notes = await noteStorageService.GetAllNotesAsync(); }
        catch (Exception ex) { await Application.Current.MainPage.DisplayAlert("Ошибка", $"Не удалось загрузить заметки: {ex.Message}", "OK"); }
    }

    private async Task AddNoteAsync()
    {
        if (navigation == null)
        {
            await Application.Current.MainPage.DisplayAlert("Ошибка", "Навигация не инициализирована!", "OK");
            return;
        }
    
        await navigation.PushAsync(new NoteEditorPage());
    }

    public async Task EditNoteAsync(Note note)
    {
        if (navigation == null)
        {
            await Application.Current.MainPage.DisplayAlert("Ошибка", "Навигация не инициализирована!", "OK");
            return;
        }
        
        await navigation.PushAsync(new NoteEditorPage(note));
    }
    private void SortNotes(string sortedBy)
    {
        switch(sortedBy)
        {
            case "Name":
            {
                var sortedBooks = Notes.OrderBy(x => x.Title).ToList();
                Notes = new ObservableCollection<Note>(sortedBooks);
                break;
            }
            case "Date":
            {
                var sortedBooks = Notes.OrderBy(x => x.CreatedAt).ToList();
                Notes = new ObservableCollection<Note>(sortedBooks);
                break;
            }
        }
        
    }
}