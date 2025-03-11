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
    [ObservableProperty]
    private ICommand _selectImageCommand;

    public CharacterDetailViewModel(CharacterManager characterManager, Character character = null)
    {
        CharacterManager = characterManager;
        _character = character ?? new Character();
        _isEditMode = character != null;
        _title = _isEditMode ? "Редактирование персонажа" : "Добавление персонажа";
        
        SaveCommand = new AsyncRelayCommand(SaveAsync);
        CancelCommand = new RelayCommand(Cancel);
        DeleteCommand = new AsyncRelayCommand(DeleteAsync);
        ToggleFavoriteCommand = new AsyncRelayCommand(ToggleFavoriteAsync);
        //SelectImageCommand = new AsyncRelayCommand(SelectImageAsync);
    }

    public CharacterManager CharacterManager { get; }
    public AsyncRelayCommand SaveCommand { get; }
    public RelayCommand CancelCommand { get; }
    public AsyncRelayCommand DeleteCommand { get; }
    public AsyncRelayCommand ToggleFavoriteCommand { get; }
    //public AsyncRelayCommand SelectImageCommand { get; }

    private async Task SaveAsync()
    {
        try
        {
            if (_character == null)
            {
                await Shell.Current.DisplayAlert(
                    "Ошибка",
                    "Персонаж не инициализирован",
                    "OK");
                return;
            }

            await CharacterManager.UpdateCharacterAsync(_character);
            await Shell.Current.GoToAsync("..");
        }
        catch (Exception ex)
        {
            await Shell.Current.DisplayAlert(
                "Ошибка",
                ex.Message,
                "OK");
        }
    }

    /*private async Task SelectImageAsync()
    {
        var file = await FilePicker.Default.PickPhotoAsync();
        if (file != null)
        {
            using var stream = await file.OpenReadAsync();
            var bytes = (await stream.ReadAsync(new byte[stream.Length])).ToArray();
            
            Device.BeginInvokeOnMainThread(() =>
            {
                Character.ImageData = bytes;
                OnPropertyChanged(nameof(Character));
            });
        }
    }*/

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