using System;
using System.Collections.ObjectModel;
using System.Windows.Input;
using System.Threading.Tasks;

using Microsoft.Maui.Controls;

using CharacterBook.Models;
using CharacterBook.Interfaces;
using CharacterBook.Views;

namespace CharacterBook.ViewModels;

public class CharacterViewModel : BaseViewModel
    {
        private readonly ICharacterService _characterService;
        private ObservableCollection<CharacterModel> _characters;
        private CharacterModel _selectedCharacter;
        private string _searchText;

        public CharacterViewModel(ICharacterService characterService)
        {
            _characterService = characterService;
            LoadCharactersCommand = new Command(async () => await LoadCharacters());
            AddCharacterCommand = new Command(async () => await AddCharacter());
            EditCommand = new Command<CharacterModel>(async (character) => await EditCharacter(character));
            DeleteCommand = new Command<CharacterModel>(async (character) => await DeleteCharacter(character));
            ToggleFavoriteCommand = new Command<CharacterModel>(async (character) => await ToggleFavorite(character));
            SearchCommand = new Command(async () => await SearchCharacters());
        }

        public ICommand LoadCharactersCommand { get; }
        public ICommand AddCharacterCommand { get; }
        public ICommand EditCommand { get; }
        public ICommand DeleteCommand { get; }
        public ICommand ToggleFavoriteCommand { get; }
        public ICommand SearchCommand { get; }

        public ObservableCollection<CharacterModel> Characters
        {
            get => _characters ??= new ObservableCollection<CharacterModel>();
            set => SetProperty(ref _characters, value);
        }

        public CharacterModel SelectedCharacter
        {
            get => _selectedCharacter;
            set => SetProperty(ref _selectedCharacter, value);
        }

        public string SearchText
        {
            get => _searchText;
            set
            {
                SetProperty(ref _searchText, value);
                Task.Run(async () => await SearchCharacters());
            }
        }

        private async Task LoadCharacters()
        {
            try
            {
                var characters = await _characterService.GetAllCharacters();
                Characters.Clear();
                foreach (var character in characters)
                {
                    Characters.Add(character);
                }
            }
            catch (Exception ex)
            {
                await Shell.Current.DisplayAlert("Ошибка", ex.Message, "OK");
            }
        }

        private async Task AddCharacter()
        {
            await Shell.Current.GoToAsync(nameof(CharacterEditPage));
        }

        private async Task EditCharacter(CharacterModel character)
        {
            await Shell.Current.GoToAsync(nameof(CharacterEditPage), 
                new Dictionary<string, object>
                {
                    {"characterId", character.Id}
                });
        }

        private async Task DeleteCharacter(CharacterModel character)
        {
            var result = await Shell.Current.DisplayAlert(
                "Подтверждение",
                $"Вы уверены, что хотите удалить персонажа '{character.Name}'?",
                "Да", "Нет");

            if (result)
            {
                try
                {
                    await _characterService.DeleteCharacter(character.Id);
                    Characters.Remove(character);
                }
                catch (Exception ex)
                {
                    await Shell.Current.DisplayAlert("Ошибка", ex.Message, "OK");
                }
            }
        }

        private async Task ToggleFavorite(CharacterModel character)
        {
            try
            {
                character.isFavorite = !character.isFavorite;
                await _characterService.UpdateCharacter(character);
                OnPropertyChanged(nameof(Characters));
            }
            catch (Exception ex)
            {
                await Shell.Current.DisplayAlert("Ошибка", ex.Message, "OK");
            }
        }

        private async Task SearchCharacters()
        {
            try
            {
                var searchText = SearchText?.ToLower();
                //var filteredCharacters = await _characterService.SearchCharacters(searchText);
                Characters.Clear();
                //foreach (var character in filteredCharacters)
                //{
                //    Characters.Add(character);
                //}
            }
            catch (Exception ex)
            {
                await Shell.Current.DisplayAlert("Ошибка", ex.Message, "OK");
            }
        }
    }