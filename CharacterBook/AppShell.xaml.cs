using CharacterBook.Views;

namespace CharacterBook;

public partial class AppShell : Shell
{
	public AppShell()
	{
		InitializeComponent();

		Routing.RegisterRoute(nameof(MainPage), typeof(MainPage));
		Routing.RegisterRoute(nameof(CharacterDetailPage), typeof(CharacterDetailPage));
	}
}
