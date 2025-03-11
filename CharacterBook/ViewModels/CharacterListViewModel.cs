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
    private readonly INavigation _navigation;

    public CharacterListViewModel(INavigation navigation, CharacterStorageService storageService = null)
    {
        _navigation = navigation;
        characterStorageService = storageService ?? new CharacterStorageService();
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
        try { Characters = await characterStorageService.GetAllCharactersAsync(); }
        catch (Exception ex) { await Shell.Current.DisplayAlert("Ошибка", ex.Message, "OK"); }
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
        await _navigation.PushAsync(new CharacterDetailPage());
    }

    public async Task EditCharacterAsync(Character character)
    {
        if (_navigation == null)
        {
            await Application.Current.MainPage.DisplayAlert("Ошибка", "Навигация не инициализирована!", "OK");
            return;
        }
        
        await _navigation.PushAsync(new CharacterDetailPage(character));
    }
}