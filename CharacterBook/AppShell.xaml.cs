using CharacterBook.Views;

namespace CharacterBook;

public partial class AppShell : Shell
{
	public AppShell()
	{
		InitializeComponent();

		Routing.RegisterRoute(nameof(CharacterListPage), typeof(CharacterListPage));
		Routing.RegisterRoute(nameof(CharacterDetailPage), typeof(CharacterDetailPage));

		Routing.RegisterRoute(nameof(NoteListPage), typeof(NoteListPage));
		Routing.RegisterRoute(nameof(NoteEditorPage), typeof(NoteEditorPage));
	}
}
