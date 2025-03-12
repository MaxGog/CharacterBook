using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Threading.Tasks;
using System.Windows.Input;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

using CharacterBook.Models;
using CharacterBook.Services;

namespace CharacterBook.ViewModels;

public partial class CharacterDetailViewModel : BaseViewModel
{
    private Character _character;
    private bool _isEditMode;
    private string _title;
    private ICommand _selectImageCommand;
    private readonly INavigation _navigation;

    private readonly CharacterStorageService characterStorageService;

    public CharacterDetailViewModel(INavigation navigation, Character character = null, CharacterStorageService storageService = null)
    {
        _navigation = navigation;
        characterStorageService = storageService ?? new CharacterStorageService();
        _character = character ?? new Character();
        _isEditMode = character != null;
        _title = _isEditMode ? "Редактирование персонажа" : "Добавление персонажа";
        
        SaveCommand = new AsyncRelayCommand(SaveAsync);
        CancelCommand = new RelayCommand(Cancel);
        DeleteCommand = new AsyncRelayCommand(DeleteAsync);
        ToggleFavoriteCommand = new AsyncRelayCommand(ToggleFavoriteAsync);
        SelectImageCommand = new AsyncRelayCommand(SelectImageAsync);
    }
    public AsyncRelayCommand SaveCommand { get; }
    public RelayCommand CancelCommand { get; }
    public AsyncRelayCommand DeleteCommand { get; }
    public AsyncRelayCommand ToggleFavoriteCommand { get; }
    public AsyncRelayCommand SelectImageCommand { get; }

    public Character Character
    {
        get => _character;
        set => SetProperty(ref _character, value);
    }

    private async Task SaveAsync()
    {
        try
        {
            await characterStorageService.SaveCharacterAsync(_character);
            await Shell.Current.GoToAsync("..");
        }
        catch (Exception ex)
        {
            await Shell.Current.DisplayAlert("Ошибка при сохранении", ex.Message, "OK");
        }
    }

    private async Task SelectImageAsync()
    {
        var options = new PickOptions
        {
            FileTypes = FilePickerFileType.Images,
            PickerTitle = "Выберите изображение"
        };

        try
        {
            var file = await FilePicker.Default.PickAsync(options);
            if (file != null)
            {
                using var stream = await file.OpenReadAsync();
                var bytes = new byte[stream.Length];
                await stream.ReadExactlyAsync(bytes);
                Character.ImageData = bytes;
            }
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
        var result = await Shell.Current.DisplayAlert("Удаление персонажа", "Вы уверены, что хотите удалить этого персонажа?",
            "Да", "Нет");

        if (result)
        {
            try
            {
                await characterStorageService.DeleteCharacterAsync(Character.Id);
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
        await characterStorageService.UpdateCharacterAsync(Character);
    }
}