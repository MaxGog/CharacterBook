using CharacterBook.Views;

namespace CharacterBook;

public partial class AppShell : Shell
{
	public AppShell()
	{
		InitializeComponent();

		Routing.RegisterRoute("MainPage", typeof(MainPage));
		Routing.RegisterRoute("CharacterDetailPage", typeof(CharacterDetailPage));
	}
}
