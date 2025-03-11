using System.Collections.ObjectModel;

using CharacterBook.Models;
using CharacterBook.Services;
using CharacterBook.Views;

namespace CharacterBook.ViewModels;

public class CharacterListViewModel : BaseViewModel
{
    private readonly CharacterStorageService characterStorageService;
    private ObservableCollection<Character> _characters;
    private string _searchText;
    private Character _selectedCharacter;

    public CharacterListViewModel()
    {
        Characters = new ObservableCollection<Character>();
        LoadCharactersCommand = new Command(async () => await LoadCharacters());
        AddCommand = new Command(async () => await AddCharacter());
        SearchCommand = new Command<string>(SearchCharacters);
    }

    public ObservableCollection<Character> Characters
    {
        get => _characters;
        set => SetProperty(ref _characters, value);
    }

    public string SearchText
    {
        get => _searchText;
        set
        {
            SetProperty(ref _searchText, value);
            SearchCharacters(value);
        }
    }

    public Command LoadCharactersCommand { get; }
    public Command AddCommand { get; }
    public Command<string> SearchCommand { get; }

    private async Task LoadCharacters()
    {
        try
        {
            var characters = await characterStorageService.GetAllCharactersAsync();
            Characters = new ObservableCollection<Character>(characters);
        }
        catch (Exception ex)
        {
            await Shell.Current.DisplayAlert("Ошибка", ex.Message, "OK");
        }
    }

    private void SearchCharacters(string searchText)
    {
        if (string.IsNullOrWhiteSpace(searchText))
        {
            LoadCharacters();
            return;
        }

        var filtered = Characters.Where(c => 
            c.Name.ToLower().Contains(searchText.ToLower()) ||
            c.Description.ToLower().Contains(searchText.ToLower())).ToList();

        Characters = new ObservableCollection<Character>(filtered);
    }

    private async Task AddCharacter()
    {
        await Shell.Current.GoToAsync(nameof(CharacterDetailPage));
    }
}