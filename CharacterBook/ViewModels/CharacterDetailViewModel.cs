using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Threading.Tasks;
using System.Windows.Input;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

using CharacterBook.Models;
using CharacterBook.Data;

namespace CharacterBook.ViewModels;

public partial class CharacterDetailViewModel : ObservableObject
    {
        [ObservableProperty]
        private Character _character;

        [ObservableProperty]
        private bool _isEditMode;

        [ObservableProperty]
        private string _title;

        public CharacterDetailViewModel(CharacterManager characterManager)
        {
            CharacterManager = characterManager;
            SaveCommand = new AsyncRelayCommand(SaveAsync);
            CancelCommand = new RelayCommand(Cancel);
            DeleteCommand = new AsyncRelayCommand(DeleteAsync);
            ToggleFavoriteCommand = new AsyncRelayCommand(ToggleFavoriteAsync);
        }

        public CharacterManager CharacterManager { get; }
        public AsyncRelayCommand SaveCommand { get; }
        public RelayCommand CancelCommand { get; }
        public AsyncRelayCommand DeleteCommand { get; }
        public AsyncRelayCommand ToggleFavoriteCommand { get; }

        public void Initialize(Character character)
        {
            Character = character ?? new Character();
            IsEditMode = character != null;
            Title = IsEditMode ? "Редактирование персонажа" : "Добавление персонажа";
        }

        private async Task SaveAsync()
        {
            try
            {
                await CharacterManager.UpdateCharacterAsync(Character);
                await Shell.Current.GoToAsync("..");
            }
            catch (Exception ex)
            {
                await Shell.Current.DisplayAlert("Ошибка", ex.Message, "OK");
            }
        }

        private void Cancel()
        {
            Shell.Current.GoToAsync("..");
        }

        private async Task DeleteAsync()
        {
            var result = await Shell.Current.DisplayAlert(
                "Удаление персонажа",
                "Вы уверены, что хотите удалить этого персонажа?",
                "Да",
                "Нет");

            if (result)
            {
                try
                {
                    await CharacterManager.DeleteCharacterAsync(Character.Id);
                    await Shell.Current.GoToAsync("..");
                }
                catch (Exception ex)
                {
                    await Shell.Current.DisplayAlert("Ошибка", ex.Message, "OK");
                }
            }
        }

        private async Task ToggleFavoriteAsync()
        {
            Character.IsFavorite = !Character.IsFavorite;
            await CharacterManager.UpdateCharacterAsync(Character);
        }
    }