using Microsoft.Extensions.Logging;
using CharacterBook.Services;
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
        }).UseMauiCommunityToolkit()
        .ConfigureViewModels()
    	.ConfigureViews()
		.ConfigureServices();
        
#if DEBUG
        builder.Logging.AddDebug();
#endif
        return builder.Build();
    }
}