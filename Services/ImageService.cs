using SQLite;

using CharacterBook.Models;
using CharacterBook.Data;
using CharacterBook.Interfaces;

namespace CharacterBook.Services;

public class ImageService : IImageService
{
    public async Task<IEnumerable<byte[]>> PickMultipleImagesAsync()
    {
        var customFileType = new FilePickerFileType(
            new Dictionary<DevicePlatform, IEnumerable<string>>
            {
                { DevicePlatform.iOS, new[] { "public.image" } },
                { DevicePlatform.Android, new[] { "image/jpeg", "image/png" } },
                { DevicePlatform.WinUI, new[] { ".jpeg", ".jpg", ".png" } }
            });

        var files = await FilePicker.Default.PickMultipleAsync(new PickOptions
        {
            PickerTitle = "Выберите изображения",
            FileTypes = customFileType
        });

        var images = new List<byte[]>();
        foreach (var file in files)
        {
            using var stream = await file.OpenReadAsync();
            using var memoryStream = new MemoryStream();
            await stream.CopyToAsync(memoryStream);
            images.Add(memoryStream.ToArray());
        }

        return images;
    }

    public async Task SaveImageAsync(byte[] imageData, string contentType, int characterId)
    {
        try
        {
            using var conn = new SQLiteConnection(DatabaseConnectionClass.filePath);
            conn.Insert(new CharacterImage
            {
                CharacterId = characterId,
                Data = imageData,
                ContentType = contentType
            });
        }
        catch (SQLiteException ex)
        {
            throw new Exception($"Ошибка при сохранении изображения: {ex.Message}");
        }
    }
}