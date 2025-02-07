using CharacterBook.Views;

namespace CharacterBook;

public partial class AppShell : Shell
{
	public AppShell()
	{
		InitializeComponent();

		Routing.RegisterRoute("ListCharacters", typeof(ListCharacterPage));
		Routing.RegisterRoute("EditCharacter", typeof(EditCharacterPage));
		Routing.RegisterRoute("Settings", typeof(SettingsPage));
	}
}
