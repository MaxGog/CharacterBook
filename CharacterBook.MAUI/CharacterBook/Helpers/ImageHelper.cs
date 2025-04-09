using System.IO;
using Microsoft.Maui.Graphics;
using CommunityToolkit.Maui.Converters;

namespace CharacterBook.Helpers;

public static class ImageConvector
{
    /*public static async Task<byte[]> ImageSourceToByteArray(ImageSource imageSource)
    {
        if (imageSource == null)
            throw new ArgumentNullException(nameof(imageSource));

        var streamImageSource = imageSource as StreamImageSource;
        if (!(imageSource is StreamImageSource))
            throw new ArgumentException("Только StreamImageSource поддерживается");

        await using var ms = new MemoryStream();
        await streamImageSource.Stream(ms);
        return ms.ToArray();
    }

    public static ImageSource ByteArrayToImage(byte[] bytes)
    {
        if (bytes == null || bytes.Length == 0)
            throw new ArgumentException("Invalid byte array");

        return ImageSource.FromStream(() => new MemoryStream(bytes));
    }*/
}