using System;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using System.Windows.Input;
using Microsoft.Maui.Controls;

using CharacterBook.Models;
using CharacterBook.Data;
using CharacterBook.Interfaces;

namespace CharacterBook.ViewModels;

public class CharacterEditViewModel : BaseViewModel
{
    private readonly ICharacterService _characterService;
    private readonly IImageService _imageService;
    private CharacterModel _character;
    private ObservableCollection<ImageSource> _images;

    public CharacterEditViewModel(ICharacterService characterService, IImageService imageService)
    {
        _characterService = characterService;
        _imageService = imageService;
        _images = new ObservableCollection<ImageSource>();
        
        PickImagesCommand = new Command(async () => await PickImagesAsync());
        SaveCommand = new Command(async () => await SaveAsync());
    }

    public string Name
    {
        get => _character.Name;
        set => SetProperty(ref _character.Name, value);
    }

    public string Gender
    {
        get => _character.Gender;
        set => SetProperty(ref _character.Gender, value);
    }

    public string Age
    {
        get => _character.Age;
        set => SetProperty(ref _character.Age, value);
    }

    public string Race
    {
        get => _character.Race;
        set => SetProperty(ref _character.Race, value);
    }

    public string Description
    {
        get => _character.Description;
        set => SetProperty(ref _character.Description, value);
    }

    public ObservableCollection<ImageSource> Images
    {
        get => _images;
        set => SetProperty(ref _images, value);
    }

    public ICommand PickImagesCommand { get; }
    public ICommand SaveCommand { get; }

    public async Task InitializeAsync(int? characterId = null)
    {
        try
        {
            if (characterId.HasValue)
            {
                _character = await _characterService.GetCharacter(characterId.Value);
                await LoadImages();
            }
            else
            {
                _character = new CharacterModel
                {
                    CreateDateTime = DateTime.UtcNow
                };
            }
        }
        catch (Exception ex)
        {
            await Shell.Current.DisplayAlert("Ошибка", ex.Message, "OK");
        }
    }

    private async Task PickImagesAsync()
    {
        try
        {
            var images = await _imageService.PickMultipleImagesAsync();
            foreach (var image in images)
            {
                Images.Add(ImageSource.FromStream(() => new MemoryStream(image)));
            }
        }
        catch (Exception ex)
        {
            await Shell.Current.DisplayAlert("Ошибка", ex.Message, "OK");
        }
    }

    private async Task SaveAsync()
    {
        try
        {
            if (_character.Id == 0)
            {
                await _characterService.AddCharacter(_character);
            }
            else
            {
                await _characterService.UpdateCharacter(_character);
            }

            foreach (var image in Images)
            {
                using var stream = image.GetStream();
                using var memoryStream = new MemoryStream();
                await stream.CopyToAsync(memoryStream);
                await _imageService.SaveImageAsync(memoryStream.ToArray(), 
                    "image/jpeg", _character.Id);
            }

            await Shell.Current.GoToAsync("..");
        }
        catch (Exception ex)
        {
            await Shell.Current.DisplayAlert("Ошибка", ex.Message, "OK");
        }
    }

    private async Task LoadImages()
    {
        try
        {
            var images = await _characterService.GetCharacterImages(_character.Id);
            Images.Clear();
            foreach (var image in images)
            {
                Images.Add(ImageSource.FromStream(() => new MemoryStream(image.Data)));
            }
        }
        catch (Exception ex)
        {
            await Shell.Current.DisplayAlert("Ошибка", ex.Message, "OK");
        }
    }
}