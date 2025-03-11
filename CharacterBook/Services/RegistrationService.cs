using CharacterBook.Services;
using CharacterBook.ViewModels;
using CharacterBook.Views;

namespace CharacterBook.Services;

public static class ServiceRegistration
{
    public static MauiAppBuilder ConfigureViewModels(this MauiAppBuilder mauiAppBuilder)
    {
        mauiAppBuilder.Services.AddSingleton<BaseViewModel>();
        mauiAppBuilder.Services.AddSingleton<CharacterListViewModel>();
        mauiAppBuilder.Services.AddSingleton<CharacterDetailViewModel>();
        
        return mauiAppBuilder;
    }
    public static MauiAppBuilder ConfigureServices(this MauiAppBuilder mauiAppBuilder)
    {
        mauiAppBuilder.Services.AddSingleton<CharacterStorageService>();
        mauiAppBuilder.Services.AddSingleton<NoteStorageService>();
        mauiAppBuilder.Services.AddSingleton<INavigation>(sp => sp.GetRequiredService<INavigation>());
		mauiAppBuilder.Services.AddSingleton<IConnectivity>(Connectivity.Current);
        
        return mauiAppBuilder;
    }

    public static MauiAppBuilder ConfigureViews(this MauiAppBuilder mauiAppBuilder)
    {
        mauiAppBuilder.Services.AddTransient<CharacterDetailPage>();
        mauiAppBuilder.Services.AddTransient<CharacterListPage>();
        
        return mauiAppBuilder;
    }
}
