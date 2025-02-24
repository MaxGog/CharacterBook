using CharacterBook.Interfaces;
using CharacterBook.Services;
using CharacterBook.ViewModels;

using Microsoft.Extensions.Logging;

namespace CharacterBook;

public static class MauiProgram
{
	public static MauiApp CreateMauiApp()
	{
		var builder = MauiApp.CreateBuilder();
		builder
			.UseMauiApp<App>()
			.ConfigureFonts(fonts =>
			{
				fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
				fonts.AddFont("OpenSans-Semibold.ttf", "OpenSansSemibold");
			});

		builder.Services.AddSingleton<ICharacterService, CharacterService>();
		builder.Services.AddSingleton<IImageService, ImageService>();
		builder.Services.AddSingleton<CharacterViewModel>();
		builder.Services.AddSingleton<CharacterEditViewModel>();

#if DEBUG
		builder.Logging.AddDebug();
#endif

		return builder.Build();
	}
}
