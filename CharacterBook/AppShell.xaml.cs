using CharacterBook.Views;

namespace CharacterBook;

public partial class AppShell : Shell
{
	public AppShell()
	{
		InitializeComponent();

		Routing.RegisterRoute(nameof(CharacterListPage), typeof(CharacterListPage));
		Routing.RegisterRoute(nameof(CharacterDetailPage), typeof(CharacterDetailPage));
	}
}
