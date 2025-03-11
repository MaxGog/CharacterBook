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

    public NoteListViewModel(INavigation navigation)
    {
        this.navigation = navigation;
        noteStorageService = new NoteStorageService();
        LoadNotesCommand = new Command(async () => await LoadNotesAsync());
        AddNoteCommand = new Command(async () => await AddNoteAsync());
        EditNoteCommand = new Command<Note>(async (note) => await EditNoteAsync(note));

        sortNameCommand = new Command(() => SortedByName());
        sortDateCommand = new Command(() => SortedByDate());
        LoadNotesCommand.Execute(null);
    }

    public ObservableCollection<Note> Notes
    {
        get => notes;
        set => SetProperty(ref notes, value);
    }

    public ICommand LoadNotesCommand { get; }
    public ICommand AddNoteCommand { get; }
    public ICommand EditNoteCommand { get; }

    public ICommand sortNameCommand { get; private set; }
    public ICommand sortDateCommand { get; private set; }

    public async Task LoadNotesAsync()
    {
        try
        {
            var loadedNotes = await noteStorageService.GetAllNotesAsync();
            Notes = new ObservableCollection<Note>(loadedNotes);
        }
        catch (Exception ex)
        {
            await Application.Current.MainPage.DisplayAlert("Ошибка", $"Не удалось загрузить заметки: {ex.Message}", "OK");
        }
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

    protected void SetProperty<T>(ref T field, T newValue, [CallerMemberName] string propertyName = null)
    {
        field = newValue;
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }

    public event PropertyChangedEventHandler PropertyChanged;

    private void SortedByName()
    {
        var sortedBooks = Notes.OrderBy(x => x.Title).ToList();
        Notes = new ObservableCollection<Note>(sortedBooks);
    }
    private void SortedByDate()
    {
        var sortedBooks = Notes.OrderBy(x => x.CreatedAt).ToList();
        Notes = new ObservableCollection<Note>(sortedBooks);
    }
}