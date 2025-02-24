using Microsoft.Extensions.Logging;
using CharacterBook.Data;
using CharacterBook.ViewModels;
using CommunityToolkit.Maui;

namespace CharacterBook;
public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder.UseMauiApp<App>().ConfigureFonts(fonts =>
        {
            fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
            fonts.AddFont("OpenSans-Semibold.ttf", "OpenSansSemibold");
        }).UseMauiCommunityToolkit();
        builder.Services.AddSingleton<CharacterContext>();
        builder.Services.AddSingleton<CharacterManager>();
        builder.Services.AddSingleton<CharactersViewModel>();
        builder.Services.AddSingleton<CharacterDetailViewModel>();
#if DEBUG
        builder.Logging.AddDebug();
#endif
        return builder.Build();
    }
}