using CharacterBook.Views;

namespace CharacterBook;

public partial class AppShell : Shell
{
	public AppShell()
	{
		InitializeComponent();

		Routing.RegisterRoute(nameof(CharacterEditPage), typeof(CharacterEditPage));
	}

	protected override void OnNavigating(ShellNavigatingEventArgs args)
    {
        base.OnNavigating(args);
        
        // Обработка параметров навигации
        if (args.Source == ShellNavigationSource.PushAsync)
        {
            var parameters = args.State as Dictionary<string, object>;
            if (parameters != null)
            {
                var characterId = parameters.ContainsKey("characterId") 
                    ? (int?)parameters["characterId"] 
                    : null;
                
                if (characterId.HasValue)
                {
                    args.State = new Dictionary<string, object>
                    {
                        { "characterId", characterId.Value }
                    };
                }
            }
        }
    }

    protected override void OnNavigated(ShellNavigatedEventArgs args)
    {
        base.OnNavigated(args);
        
        // Обновление состояния навигации
        if (args.Source != ShellNavigationSource.Pop)
        {
            var currentRoute = CurrentState.Location;
            if (!string.IsNullOrEmpty(currentRoute))
            {
                var routeParts = currentRoute.Split('/');
                var lastPart = routeParts.Last();
                
                if (lastPart == nameof(CharacterEditPage))
                {
                    var parameters = CurrentState.Parameters;
                    if (parameters.ContainsKey("characterId"))
                    {
                        var characterId = (int)parameters["characterId"];
                        // Дополнительная логика при навигации на страницу редактирования
                    }
                }
            }
        }
    }
}
