using System.Collections.ObjectModel;
using System.Windows.Input;
using System.Runtime.CompilerServices;
using System.ComponentModel;

using CharacterBook.Models;
using CharacterBook.Views;
using CharacterBook.Services;

namespace CharacterBook.ViewModels;

public class NoteEditorViewModel : INotifyPropertyChanged
{
    private readonly INavigation navigation;
    private readonly NoteStorageService noteStorageService;
    private readonly Editor editor;
    private string content;
    public string id;
    
    public NoteEditorViewModel(INavigation navigation, Editor editor)
    {
        this.navigation = navigation;
        this.editor = editor;
        noteStorageService = new NoteStorageService();
        SaveNoteCommand = new Command(async () => await SaveNoteAsync());
        RemoveNoteCommand = new Command(async () => await RemoveNoteAsync());
    }

    public string Content
    {
        get => content;
        set => SetProperty(ref content, value);
    }

    public ICommand SaveNoteCommand { get; }
    public ICommand RemoveNoteCommand { get; }

    private async Task SaveNoteAsync()
    {
        try
        {
            var note = new Note
            {
                Title = !string.IsNullOrWhiteSpace(Content) ? 
                    Content.Split('\n').FirstOrDefault() ?? "Без названия" : "Без названия",
                Content = Content,
                CreatedAt = DateTime.Now,
                Id = id
            };
            
            await noteStorageService.SaveNoteAsync(note);
            //MessagingCenter.Send(this, "NoteSaved");
            await navigation.PopAsync();
        }
        catch (Exception ex)
        {
            await Application.Current.MainPage.DisplayAlert("Ошибка", $"Не удалось сохранить заметку: {ex.Message}", "OK");
        }
    }

    private async Task RemoveNoteAsync()
    {
        try
        {
            var note = new Note
            {
                Title = !string.IsNullOrWhiteSpace(Content) ? 
                    Content.Split('\n').FirstOrDefault() ?? "Без названия" : "Без названия",
                Content = Content,
                CreatedAt = DateTime.Now,
                Id = id
            };
            
            await noteStorageService.DeleteNoteAsync(note.Id);
            await navigation.PopAsync();
        }
        catch (Exception ex)
        {
            await Application.Current.MainPage.DisplayAlert("Ошибка", $"Не удалось удалить заметку: {ex.Message}", "OK");
        }
    }

    protected void SetProperty<T>(ref T field, T newValue, [CallerMemberName] string propertyName = null)
    {
        field = newValue;
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }

    public event PropertyChangedEventHandler PropertyChanged;
}