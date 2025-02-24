namespace CharacterBook.Interfaces;

public interface IImageService
{
    Task<IEnumerable<byte[]>> PickMultipleImagesAsync();
    Task SaveImageAsync(byte[] imageData, string contentType, int characterId);
}