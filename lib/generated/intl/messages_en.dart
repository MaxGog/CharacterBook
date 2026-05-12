// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(error) => "Crop error: ${error}";

  static String m1(error) => "Error: ${error}";

  static String m2(name) => "Created from \"${name}\"";

  static String m3(name) => "\"${name}\" exported";

  static String m4(name) => "\"${name}\" imported";

  static String m5(name) => "${name} (character)";

  static String m6(charactersCount, notesCount, racesCount, templatesCount,
          foldersCount) =>
      "Restored: ${charactersCount} char, ${notesCount} notes, ${racesCount} races, ${templatesCount} templ, ${foldersCount} folders";

  static String m7(days) => "${days}d ago";

  static String m8(count) => "${count} fields";

  static String m9(hours) => "${hours}h ago";

  static String m10(error) => "Image error: ${error}";

  static String m11(error) => "Import error: ${error}";

  static String m12(months) => "${months}mo ago";

  static String m13(count) => "+${count}";

  static String m14(name) => "\"${name}\" exported to PDF";

  static String m15(name) => "\"${name}\" imported";

  static String m16(name) => "${name} (race)";

  static String m17(name) => "\"${name}\" exported";

  static String m18(name) => "\"${name}\" imported";

  static String m19(name) => "\"${name}\" exists. Replace?";

  static String m20(years) => "${years}y ago";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "a_to_z": MessageLookupByLibrary.simpleMessage("A-Z"),
        "abilities": MessageLookupByLibrary.simpleMessage("Abilities"),
        "aboutApp": MessageLookupByLibrary.simpleMessage("About"),
        "accentColor": MessageLookupByLibrary.simpleMessage("Accent"),
        "acknowledgements": MessageLookupByLibrary.simpleMessage("Credits"),
        "add_event": MessageLookupByLibrary.simpleMessage("Add event"),
        "add_field": MessageLookupByLibrary.simpleMessage("Add Field"),
        "add_picture": MessageLookupByLibrary.simpleMessage("Add"),
        "add_relationships":
            MessageLookupByLibrary.simpleMessage("Add relationship"),
        "add_tag": MessageLookupByLibrary.simpleMessage("Add"),
        "add_to_calendar":
            MessageLookupByLibrary.simpleMessage("Add to the system calendar"),
        "additional_images": MessageLookupByLibrary.simpleMessage("Extra"),
        "adults": MessageLookupByLibrary.simpleMessage("Adults"),
        "age": MessageLookupByLibrary.simpleMessage("Age"),
        "age_asc": MessageLookupByLibrary.simpleMessage("Age ↑"),
        "age_desc": MessageLookupByLibrary.simpleMessage("Age ↓"),
        "all": MessageLookupByLibrary.simpleMessage("All"),
        "all_tags": MessageLookupByLibrary.simpleMessage("All tags"),
        "another": MessageLookupByLibrary.simpleMessage("Other"),
        "appLanguage": MessageLookupByLibrary.simpleMessage("Language"),
        "app_name": MessageLookupByLibrary.simpleMessage("Characterbook"),
        "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
        "auth_cancelled":
            MessageLookupByLibrary.simpleMessage("Auth cancelled"),
        "auth_client_error":
            MessageLookupByLibrary.simpleMessage("API client error"),
        "auto_cloud_backup_subtitle": MessageLookupByLibrary.simpleMessage(
            "Automatically create a backup to Google Drive when the app starts"),
        "auto_cloud_backup_title":
            MessageLookupByLibrary.simpleMessage("Automatic cloud backup"),
        "avatar_crop_coordinates_error":
            MessageLookupByLibrary.simpleMessage("Bad crop coords"),
        "avatar_crop_error": m0,
        "avatar_crop_save": MessageLookupByLibrary.simpleMessage("Save"),
        "avatar_crop_title":
            MessageLookupByLibrary.simpleMessage("Crop Avatar"),
        "avatar_crop_widget_size_error":
            MessageLookupByLibrary.simpleMessage("Widget size error"),
        "avatar_picker_error": m1,
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "backstory": MessageLookupByLibrary.simpleMessage("Backstory"),
        "backup": MessageLookupByLibrary.simpleMessage("Backup"),
        "backup_creation":
            MessageLookupByLibrary.simpleMessage("Backing up..."),
        "backup_info_description": MessageLookupByLibrary.simpleMessage(
            "Backups are saved as a single JSON file containing all your data.\nCloud storage uses your personal Google Drive. Exported files can be shared and imported on other devices."),
        "backup_info_restore_warning": MessageLookupByLibrary.simpleMessage(
            "Restoring will permanently erase all existing data in the app."),
        "backup_info_title":
            MessageLookupByLibrary.simpleMessage("About backups"),
        "backup_options":
            MessageLookupByLibrary.simpleMessage("Backup options"),
        "backup_to_cloud": MessageLookupByLibrary.simpleMessage("To cloud"),
        "backup_to_file": MessageLookupByLibrary.simpleMessage("To file"),
        "basic_info": MessageLookupByLibrary.simpleMessage("Info"),
        "biography": MessageLookupByLibrary.simpleMessage("Biography"),
        "biology": MessageLookupByLibrary.simpleMessage("Biology"),
        "cache_clearing":
            MessageLookupByLibrary.simpleMessage("Clearing cache..."),
        "calendar": MessageLookupByLibrary.simpleMessage("Calendar"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cannotRelateToItself": MessageLookupByLibrary.simpleMessage(
            "Cannot create relationship with the same character"),
        "changes_saved": MessageLookupByLibrary.simpleMessage("Changes saved"),
        "character": MessageLookupByLibrary.simpleMessage("Character"),
        "character1": MessageLookupByLibrary.simpleMessage("Character 1"),
        "character2": MessageLookupByLibrary.simpleMessage("Character 2"),
        "character_avatar": MessageLookupByLibrary.simpleMessage("Avatar"),
        "character_created_from_template": m2,
        "character_delete_confirm":
            MessageLookupByLibrary.simpleMessage("Delete permanently?"),
        "character_delete_title":
            MessageLookupByLibrary.simpleMessage("Delete?"),
        "character_deleted": MessageLookupByLibrary.simpleMessage("Deleted"),
        "character_duplicated":
            MessageLookupByLibrary.simpleMessage("Duplicated"),
        "character_exported": m3,
        "character_gallery": MessageLookupByLibrary.simpleMessage("Gallery"),
        "character_imported": m4,
        "character_management":
            MessageLookupByLibrary.simpleMessage("Characters"),
        "character_reference":
            MessageLookupByLibrary.simpleMessage("Reference"),
        "character_share_text": m5,
        "characterbookLicense": MessageLookupByLibrary.simpleMessage("License"),
        "characters": MessageLookupByLibrary.simpleMessage("Characters"),
        "characters_and_races":
            MessageLookupByLibrary.simpleMessage("Characters & Races"),
        "checking_dependencies":
            MessageLookupByLibrary.simpleMessage("Checking..."),
        "children": MessageLookupByLibrary.simpleMessage("Children"),
        "choose_character": MessageLookupByLibrary.simpleMessage("Select"),
        "choose_color": MessageLookupByLibrary.simpleMessage("Choose"),
        "choose_race_character":
            MessageLookupByLibrary.simpleMessage("Enter name race"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "close_app": MessageLookupByLibrary.simpleMessage("Close app"),
        "cloud_backup":
            MessageLookupByLibrary.simpleMessage("Cloud backup (Google Drive)"),
        "cloud_backup_characters_error":
            MessageLookupByLibrary.simpleMessage("Character backup error"),
        "cloud_backup_characters_success":
            MessageLookupByLibrary.simpleMessage("Characters backed up"),
        "cloud_backup_error":
            MessageLookupByLibrary.simpleMessage("Backup error"),
        "cloud_backup_full_success":
            MessageLookupByLibrary.simpleMessage("Full backup on Drive"),
        "cloud_backup_not_found":
            MessageLookupByLibrary.simpleMessage("No backups"),
        "cloud_backup_success":
            MessageLookupByLibrary.simpleMessage("Backup created"),
        "cloud_export_error":
            MessageLookupByLibrary.simpleMessage("Drive export error"),
        "cloud_import_error":
            MessageLookupByLibrary.simpleMessage("Drive import error"),
        "cloud_restore_error":
            MessageLookupByLibrary.simpleMessage("Restore error"),
        "cloud_restore_success": m6,
        "colorScheme": MessageLookupByLibrary.simpleMessage("Scheme"),
        "color_blue": MessageLookupByLibrary.simpleMessage("Blue"),
        "color_brown": MessageLookupByLibrary.simpleMessage("Brown"),
        "color_dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "color_green": MessageLookupByLibrary.simpleMessage("Green"),
        "color_grey": MessageLookupByLibrary.simpleMessage("Grey"),
        "color_light_blue": MessageLookupByLibrary.simpleMessage("Light blue"),
        "color_orange": MessageLookupByLibrary.simpleMessage("Orange"),
        "color_pink": MessageLookupByLibrary.simpleMessage("Pink"),
        "color_purple": MessageLookupByLibrary.simpleMessage("Purple"),
        "color_red": MessageLookupByLibrary.simpleMessage("Red"),
        "color_spec": MessageLookupByLibrary.simpleMessage("Spec"),
        "color_spec_2021": MessageLookupByLibrary.simpleMessage("2021"),
        "color_spec_2025": MessageLookupByLibrary.simpleMessage("2025"),
        "color_style": MessageLookupByLibrary.simpleMessage("Style"),
        "color_teal": MessageLookupByLibrary.simpleMessage("Teal"),
        "configureSwipeActions":
            MessageLookupByLibrary.simpleMessage("Configure"),
        "configuring_environment":
            MessageLookupByLibrary.simpleMessage("Configuring..."),
        "continue_text": MessageLookupByLibrary.simpleMessage("Continue"),
        "contrast": MessageLookupByLibrary.simpleMessage("Contrast"),
        "copiedToClipboard":
            MessageLookupByLibrary.simpleMessage("Copied to clipboard"),
        "copied_to_clipboard": MessageLookupByLibrary.simpleMessage("Copied"),
        "copy": MessageLookupByLibrary.simpleMessage("Copy"),
        "copy_character": MessageLookupByLibrary.simpleMessage("Copy"),
        "copy_error": MessageLookupByLibrary.simpleMessage("Copy error"),
        "create": MessageLookupByLibrary.simpleMessage("Create"),
        "createBackup": MessageLookupByLibrary.simpleMessage("Backup"),
        "createRelationship":
            MessageLookupByLibrary.simpleMessage("Create Relationship"),
        "create_character": MessageLookupByLibrary.simpleMessage("Create"),
        "create_first_content":
            MessageLookupByLibrary.simpleMessage("Create a character or race"),
        "create_from_template_tooltip":
            MessageLookupByLibrary.simpleMessage("From template"),
        "create_template": MessageLookupByLibrary.simpleMessage("Create"),
        "create_template_tooltip":
            MessageLookupByLibrary.simpleMessage("Create template"),
        "creatingBackup": MessageLookupByLibrary.simpleMessage("Backing up..."),
        "creating_file":
            MessageLookupByLibrary.simpleMessage("Creating file..."),
        "creating_pdf": MessageLookupByLibrary.simpleMessage("Creating PDF..."),
        "critical_error":
            MessageLookupByLibrary.simpleMessage("Critical error"),
        "critical_error_warning":
            MessageLookupByLibrary.simpleMessage("Some data may be lost"),
        "custom": MessageLookupByLibrary.simpleMessage("custom"),
        "custom_color": MessageLookupByLibrary.simpleMessage("Custom"),
        "custom_event": MessageLookupByLibrary.simpleMessage("Custom event"),
        "custom_fields": MessageLookupByLibrary.simpleMessage("Custom Fields"),
        "custom_fields_editor_subtitle": MessageLookupByLibrary.simpleMessage(
            "Add any custom fields to describe the character"),
        "custom_fields_editor_title":
            MessageLookupByLibrary.simpleMessage("Additional Characteristics"),
        "customize_theme": MessageLookupByLibrary.simpleMessage("Customize"),
        "dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "data_initialization_error":
            MessageLookupByLibrary.simpleMessage("Data init error"),
        "date": MessageLookupByLibrary.simpleMessage("Date"),
        "days_ago": m7,
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "deleteConfirmation":
            MessageLookupByLibrary.simpleMessage("Delete selected?"),
        "deleteRelationshipMessage": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this particular relationships?"),
        "deleteRelationshipTitle":
            MessageLookupByLibrary.simpleMessage("Delete the relationships?"),
        "delete_character": MessageLookupByLibrary.simpleMessage("Delete"),
        "delete_error": MessageLookupByLibrary.simpleMessage("Delete error"),
        "description": MessageLookupByLibrary.simpleMessage("Description"),
        "detailed": MessageLookupByLibrary.simpleMessage("Detailed"),
        "details": MessageLookupByLibrary.simpleMessage("Details"),
        "developer": MessageLookupByLibrary.simpleMessage("Developer"),
        "directedRelationship":
            MessageLookupByLibrary.simpleMessage("Directed relationship"),
        "discard_changes": MessageLookupByLibrary.simpleMessage("Discard"),
        "dnd_tools": MessageLookupByLibrary.simpleMessage("D&D Tools"),
        "done": MessageLookupByLibrary.simpleMessage("Done"),
        "duplicate": MessageLookupByLibrary.simpleMessage("Duplicate"),
        "duplicate_character":
            MessageLookupByLibrary.simpleMessage("Duplicate"),
        "duplicate_error": MessageLookupByLibrary.simpleMessage("Duplicate"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "editRelationship":
            MessageLookupByLibrary.simpleMessage("Edit Relationship"),
        "edit_character": MessageLookupByLibrary.simpleMessage("Edit"),
        "edit_event": MessageLookupByLibrary.simpleMessage("Edit event"),
        "edit_folder": MessageLookupByLibrary.simpleMessage("Edit"),
        "edit_pins": MessageLookupByLibrary.simpleMessage("Edit pins"),
        "edit_race": MessageLookupByLibrary.simpleMessage("Edit"),
        "edit_template": MessageLookupByLibrary.simpleMessage("Edit"),
        "elderly": MessageLookupByLibrary.simpleMessage("Elderly"),
        "empty_file_error": MessageLookupByLibrary.simpleMessage("File empty"),
        "empty_list": MessageLookupByLibrary.simpleMessage("Empty"),
        "enterName": MessageLookupByLibrary.simpleMessage("Enter a name"),
        "enter_age": MessageLookupByLibrary.simpleMessage("Age"),
        "enter_event_title":
            MessageLookupByLibrary.simpleMessage("Enter the event name"),
        "enter_name_character":
            MessageLookupByLibrary.simpleMessage("Enter name character"),
        "enter_race_name": MessageLookupByLibrary.simpleMessage("Race name"),
        "enter_title_note":
            MessageLookupByLibrary.simpleMessage("Enter title note"),
        "enter_title_template":
            MessageLookupByLibrary.simpleMessage("Enter title template"),
        "error": MessageLookupByLibrary.simpleMessage("Error"),
        "error_details": MessageLookupByLibrary.simpleMessage("Details"),
        "error_details_description": MessageLookupByLibrary.simpleMessage(
            "Error during init. Technical info:"),
        "error_loading_notes":
            MessageLookupByLibrary.simpleMessage("Error loading posts"),
        "event_calendar": MessageLookupByLibrary.simpleMessage("Events"),
        "event_description":
            MessageLookupByLibrary.simpleMessage("Description"),
        "event_title": MessageLookupByLibrary.simpleMessage("Title event"),
        "export": MessageLookupByLibrary.simpleMessage("Export"),
        "export_error": MessageLookupByLibrary.simpleMessage("Export error"),
        "export_failed": MessageLookupByLibrary.simpleMessage("Export failed"),
        "export_pdf_settings":
            MessageLookupByLibrary.simpleMessage("PDF settings"),
        "export_success": MessageLookupByLibrary.simpleMessage("PDF ready"),
        "export_timeout": MessageLookupByLibrary.simpleMessage(
            "Export timed out. Try again."),
        "export_to_cloud":
            MessageLookupByLibrary.simpleMessage("Export to cloud"),
        "export_to_file":
            MessageLookupByLibrary.simpleMessage("Export to file"),
        "female": MessageLookupByLibrary.simpleMessage("Female"),
        "field_name": MessageLookupByLibrary.simpleMessage("Field Name"),
        "field_name_hint":
            MessageLookupByLibrary.simpleMessage("e.g. \"Eye color\""),
        "field_removed": MessageLookupByLibrary.simpleMessage("Field removed"),
        "field_value": MessageLookupByLibrary.simpleMessage("Value"),
        "field_value_hint": MessageLookupByLibrary.simpleMessage("Enter value"),
        "fields_asc": MessageLookupByLibrary.simpleMessage("Fields ↑"),
        "fields_count": m8,
        "fields_desc": MessageLookupByLibrary.simpleMessage("Fields ↓"),
        "file_app": MessageLookupByLibrary.simpleMessage("App file"),
        "file_character":
            MessageLookupByLibrary.simpleMessage("File (.character)"),
        "file_pdf": MessageLookupByLibrary.simpleMessage("PDF (.pdf)"),
        "file_pick_error": MessageLookupByLibrary.simpleMessage("File error"),
        "file_race": MessageLookupByLibrary.simpleMessage("Race file (.race)"),
        "file_ready": MessageLookupByLibrary.simpleMessage("Ready"),
        "file_sharing_timeout":
            MessageLookupByLibrary.simpleMessage("File share timeout"),
        "file_word": MessageLookupByLibrary.simpleMessage("Document Word"),
        "finalizing_setup":
            MessageLookupByLibrary.simpleMessage("Finalizing..."),
        "flutterLicense":
            MessageLookupByLibrary.simpleMessage("Flutter License"),
        "folder": MessageLookupByLibrary.simpleMessage("Folder"),
        "folder_color": MessageLookupByLibrary.simpleMessage("Color"),
        "folder_mode": MessageLookupByLibrary.simpleMessage("Folders mode"),
        "folder_name": MessageLookupByLibrary.simpleMessage("Name"),
        "folders": MessageLookupByLibrary.simpleMessage("Folders"),
        "from": MessageLookupByLibrary.simpleMessage("From"),
        "from_template": MessageLookupByLibrary.simpleMessage("From template"),
        "gender": MessageLookupByLibrary.simpleMessage("Gender"),
        "generateNumber": MessageLookupByLibrary.simpleMessage("Generate"),
        "generating": MessageLookupByLibrary.simpleMessage("Generating..."),
        "githubRepo": MessageLookupByLibrary.simpleMessage("GitHub"),
        "grant_permission": MessageLookupByLibrary.simpleMessage("Grant"),
        "grid_view": MessageLookupByLibrary.simpleMessage("Grid"),
        "hive_initialization_error":
            MessageLookupByLibrary.simpleMessage("DB init error"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "home_subtitle":
            MessageLookupByLibrary.simpleMessage("Character & race collection"),
        "hours_ago": m9,
        "image": MessageLookupByLibrary.simpleMessage("Image"),
        "image_picker_error": m10,
        "image_removed": MessageLookupByLibrary.simpleMessage("Image removed"),
        "import": MessageLookupByLibrary.simpleMessage("Import"),
        "import_cancelled": MessageLookupByLibrary.simpleMessage("Cancelled"),
        "import_character": MessageLookupByLibrary.simpleMessage("Import"),
        "import_error": m11,
        "import_failed": MessageLookupByLibrary.simpleMessage("Import failed"),
        "import_from_cloud":
            MessageLookupByLibrary.simpleMessage("Import from cloud"),
        "import_from_file":
            MessageLookupByLibrary.simpleMessage("Import from file"),
        "import_race": MessageLookupByLibrary.simpleMessage("Import"),
        "import_template": MessageLookupByLibrary.simpleMessage("Import"),
        "import_template_tooltip":
            MessageLookupByLibrary.simpleMessage("Import"),
        "information": MessageLookupByLibrary.simpleMessage("Info"),
        "initialization": MessageLookupByLibrary.simpleMessage("Init"),
        "initialization_complete":
            MessageLookupByLibrary.simpleMessage("Init complete"),
        "initialization_error":
            MessageLookupByLibrary.simpleMessage("Init error"),
        "initialization_failed":
            MessageLookupByLibrary.simpleMessage("Init failed"),
        "initialization_progress":
            MessageLookupByLibrary.simpleMessage("Initializing..."),
        "initialization_reset_warning": MessageLookupByLibrary.simpleMessage(
            "Data reset to restore stability"),
        "initialization_success":
            MessageLookupByLibrary.simpleMessage("Init OK"),
        "initialization_timeout":
            MessageLookupByLibrary.simpleMessage("Init timeout"),
        "initialization_timeout_message": MessageLookupByLibrary.simpleMessage(
            "Init timeout. Check connection."),
        "invalid_age": MessageLookupByLibrary.simpleMessage("Invalid age"),
        "items": MessageLookupByLibrary.simpleMessage("items"),
        "just_now": MessageLookupByLibrary.simpleMessage("Just now"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "last_updated": MessageLookupByLibrary.simpleMessage("Updated"),
        "leftSwipeAction": MessageLookupByLibrary.simpleMessage("Left swipe"),
        "licenses": MessageLookupByLibrary.simpleMessage("Licenses"),
        "light": MessageLookupByLibrary.simpleMessage("Light"),
        "list_mode": MessageLookupByLibrary.simpleMessage("List mode"),
        "list_view": MessageLookupByLibrary.simpleMessage("List"),
        "loading_data": MessageLookupByLibrary.simpleMessage("Loading..."),
        "loading_resources": MessageLookupByLibrary.simpleMessage("Loading..."),
        "local_backup":
            MessageLookupByLibrary.simpleMessage("Local backup (file)"),
        "local_backup_error":
            MessageLookupByLibrary.simpleMessage("Backup error"),
        "local_backup_success":
            MessageLookupByLibrary.simpleMessage("Backup created"),
        "local_restore_error":
            MessageLookupByLibrary.simpleMessage("Restore error"),
        "local_restore_success":
            MessageLookupByLibrary.simpleMessage("Restore completed"),
        "low_storage_message": MessageLookupByLibrary.simpleMessage(
            "Low storage may affect the app."),
        "low_storage_warning":
            MessageLookupByLibrary.simpleMessage("Low storage"),
        "main_image": MessageLookupByLibrary.simpleMessage("Main"),
        "male": MessageLookupByLibrary.simpleMessage("Male"),
        "markdown_bold": MessageLookupByLibrary.simpleMessage("Bold"),
        "markdown_bullet_list": MessageLookupByLibrary.simpleMessage("List"),
        "markdown_inline_code":
            MessageLookupByLibrary.simpleMessage("Inline code"),
        "markdown_italic": MessageLookupByLibrary.simpleMessage("Italic"),
        "markdown_numbered_list":
            MessageLookupByLibrary.simpleMessage("Num. list"),
        "markdown_quote": MessageLookupByLibrary.simpleMessage("Quote"),
        "markdown_underline": MessageLookupByLibrary.simpleMessage("Underline"),
        "material_you": MessageLookupByLibrary.simpleMessage("Material You"),
        "material_you_status_generated":
            MessageLookupByLibrary.simpleMessage("Generated colors"),
        "material_you_status_system":
            MessageLookupByLibrary.simpleMessage("System colors"),
        "migration_in_progress":
            MessageLookupByLibrary.simpleMessage("Migrating..."),
        "minutes": MessageLookupByLibrary.simpleMessage("min"),
        "minutes_before": MessageLookupByLibrary.simpleMessage("Remind me for"),
        "months_ago": m12,
        "more_fields": m13,
        "more_options": MessageLookupByLibrary.simpleMessage("More"),
        "my": MessageLookupByLibrary.simpleMessage("My"),
        "my_characters": MessageLookupByLibrary.simpleMessage("My Characters"),
        "name": MessageLookupByLibrary.simpleMessage("Name"),
        "new_character": MessageLookupByLibrary.simpleMessage("New"),
        "new_character_from_template":
            MessageLookupByLibrary.simpleMessage("New from template"),
        "new_event": MessageLookupByLibrary.simpleMessage("New event"),
        "new_folder": MessageLookupByLibrary.simpleMessage("New"),
        "new_note": MessageLookupByLibrary.simpleMessage("New note"),
        "new_race": MessageLookupByLibrary.simpleMessage("New"),
        "new_template": MessageLookupByLibrary.simpleMessage("New"),
        "no_additional_images":
            MessageLookupByLibrary.simpleMessage("No images"),
        "no_characters": MessageLookupByLibrary.simpleMessage("No characters"),
        "no_content": MessageLookupByLibrary.simpleMessage("No content"),
        "no_content_home": MessageLookupByLibrary.simpleMessage("Empty"),
        "no_custom_fields":
            MessageLookupByLibrary.simpleMessage("No custom fields yet"),
        "no_data_for_backup": MessageLookupByLibrary.simpleMessage(
            "No data to back up. Add at least one item (character, note, race, etc.) before exporting."),
        "no_data_found": MessageLookupByLibrary.simpleMessage("No data"),
        "no_description":
            MessageLookupByLibrary.simpleMessage("No description"),
        "no_folder_selected": MessageLookupByLibrary.simpleMessage("No folder"),
        "no_information": MessageLookupByLibrary.simpleMessage("No info"),
        "no_pinned_items": MessageLookupByLibrary.simpleMessage("No pinned"),
        "no_race": MessageLookupByLibrary.simpleMessage("No race"),
        "no_races_created": MessageLookupByLibrary.simpleMessage("No races"),
        "no_templates": MessageLookupByLibrary.simpleMessage("No templates"),
        "none": MessageLookupByLibrary.simpleMessage("None"),
        "not_selected": MessageLookupByLibrary.simpleMessage("Not selected"),
        "nothing_found": MessageLookupByLibrary.simpleMessage("Nothing found"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "operationCompleted": MessageLookupByLibrary.simpleMessage("Completed"),
        "operation_timeout": MessageLookupByLibrary.simpleMessage("Timeout"),
        "optimizing_performance":
            MessageLookupByLibrary.simpleMessage("Optimizing..."),
        "other": MessageLookupByLibrary.simpleMessage("Other"),
        "pdf_creation_failed":
            MessageLookupByLibrary.simpleMessage("PDF failed"),
        "pdf_creation_timeout":
            MessageLookupByLibrary.simpleMessage("PDF creation timeout"),
        "pdf_export_success":
            MessageLookupByLibrary.simpleMessage("PDF exported"),
        "pdf_generation_timeout":
            MessageLookupByLibrary.simpleMessage("PDF generation timeout"),
        "permission_required":
            MessageLookupByLibrary.simpleMessage("Permission required"),
        "personality": MessageLookupByLibrary.simpleMessage("Personality"),
        "pin": MessageLookupByLibrary.simpleMessage("Pin"),
        "pinned": MessageLookupByLibrary.simpleMessage("Pinned"),
        "posts": MessageLookupByLibrary.simpleMessage("Posts"),
        "preparing_services":
            MessageLookupByLibrary.simpleMessage("Preparing..."),
        "preview": MessageLookupByLibrary.simpleMessage("Preview"),
        "processing": MessageLookupByLibrary.simpleMessage("Loading..."),
        "race": MessageLookupByLibrary.simpleMessage("Race"),
        "race_copied": MessageLookupByLibrary.simpleMessage("Copied"),
        "race_delete_confirm":
            MessageLookupByLibrary.simpleMessage("Delete this race?"),
        "race_delete_error_content": MessageLookupByLibrary.simpleMessage(
            "Race in use. Change characters first."),
        "race_delete_error_title":
            MessageLookupByLibrary.simpleMessage("Cannot delete"),
        "race_delete_title":
            MessageLookupByLibrary.simpleMessage("Delete race?"),
        "race_deleted": MessageLookupByLibrary.simpleMessage("Deleted"),
        "race_exported": m14,
        "race_imported": m15,
        "race_management": MessageLookupByLibrary.simpleMessage("Races"),
        "race_share_text": m16,
        "races": MessageLookupByLibrary.simpleMessage("Races"),
        "randomNumberGenerator": MessageLookupByLibrary.simpleMessage("RNG"),
        "ready_to_use": MessageLookupByLibrary.simpleMessage("Ready"),
        "recovery_advice": MessageLookupByLibrary.simpleMessage(
            "Auto-recovery attempted. Reinstall if error persists."),
        "reference_image": MessageLookupByLibrary.simpleMessage("Reference"),
        "related_notes": MessageLookupByLibrary.simpleMessage("Related"),
        "relationshipAlreadyExists": MessageLookupByLibrary.simpleMessage(
            "This relationship already exists"),
        "relationshipDeleted":
            MessageLookupByLibrary.simpleMessage("Relationship deleted"),
        "relationshipName":
            MessageLookupByLibrary.simpleMessage("Relationship Name"),
        "relationships": MessageLookupByLibrary.simpleMessage("Relationships"),
        "reminder": MessageLookupByLibrary.simpleMessage("Reminder"),
        "replace": MessageLookupByLibrary.simpleMessage("Replace"),
        "required_field_error":
            MessageLookupByLibrary.simpleMessage("Required"),
        "restoreData": MessageLookupByLibrary.simpleMessage("Restore"),
        "restore_confirm":
            MessageLookupByLibrary.simpleMessage("Replace all data"),
        "restore_from_cloud":
            MessageLookupByLibrary.simpleMessage("From cloud"),
        "restore_from_file": MessageLookupByLibrary.simpleMessage("From file"),
        "restore_options":
            MessageLookupByLibrary.simpleMessage("Restore options"),
        "restore_warning_message": MessageLookupByLibrary.simpleMessage(
            "All current data will be permanently deleted and replaced by the backup. This action cannot be undone. Continue?"),
        "restore_warning_title":
            MessageLookupByLibrary.simpleMessage("⚠️ Overwrite all data?"),
        "restoringBackup": MessageLookupByLibrary.simpleMessage("Restoring..."),
        "retry_initialization": MessageLookupByLibrary.simpleMessage("Retry"),
        "rightSwipeAction": MessageLookupByLibrary.simpleMessage("Right swipe"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "save_error": MessageLookupByLibrary.simpleMessage("Save error"),
        "save_race": MessageLookupByLibrary.simpleMessage("Save"),
        "save_template": MessageLookupByLibrary.simpleMessage("Save"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "search_characters": MessageLookupByLibrary.simpleMessage("Search..."),
        "search_hint":
            MessageLookupByLibrary.simpleMessage("Search everything..."),
        "search_home": MessageLookupByLibrary.simpleMessage("Search..."),
        "search_race_hint": MessageLookupByLibrary.simpleMessage("Search..."),
        "select": MessageLookupByLibrary.simpleMessage("Selected"),
        "selectBothCharacters":
            MessageLookupByLibrary.simpleMessage("Select both characters"),
        "selectRange": MessageLookupByLibrary.simpleMessage("Select range"),
        "select_character": MessageLookupByLibrary.simpleMessage("Select"),
        "select_folder": MessageLookupByLibrary.simpleMessage("Select"),
        "select_gender_error":
            MessageLookupByLibrary.simpleMessage("Select gender"),
        "select_race": MessageLookupByLibrary.simpleMessage("Select race"),
        "select_race_error":
            MessageLookupByLibrary.simpleMessage("Select race"),
        "select_template": MessageLookupByLibrary.simpleMessage("Select"),
        "select_template_file":
            MessageLookupByLibrary.simpleMessage("Select template file"),
        "service_initialization_error":
            MessageLookupByLibrary.simpleMessage("Service init error"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "share_backup_file":
            MessageLookupByLibrary.simpleMessage("My backup file"),
        "share_character": MessageLookupByLibrary.simpleMessage("Share"),
        "short_name": MessageLookupByLibrary.simpleMessage("Short name"),
        "skip_for_now": MessageLookupByLibrary.simpleMessage("Skip"),
        "standard": MessageLookupByLibrary.simpleMessage("standard"),
        "standard_fields": MessageLookupByLibrary.simpleMessage("Standard"),
        "start_writing": MessageLookupByLibrary.simpleMessage("Write..."),
        "storage_permission_message":
            MessageLookupByLibrary.simpleMessage("Storage access required."),
        "swipeActions": MessageLookupByLibrary.simpleMessage("Swipe actions"),
        "system": MessageLookupByLibrary.simpleMessage("System"),
        "tags": MessageLookupByLibrary.simpleMessage("Tags"),
        "technical_details":
            MessageLookupByLibrary.simpleMessage("Tech details"),
        "template": MessageLookupByLibrary.simpleMessage("Template"),
        "template_delete_confirm":
            MessageLookupByLibrary.simpleMessage("Delete this template?"),
        "template_delete_title":
            MessageLookupByLibrary.simpleMessage("Delete template?"),
        "template_deleted": MessageLookupByLibrary.simpleMessage("Deleted"),
        "template_exists":
            MessageLookupByLibrary.simpleMessage("Template exists"),
        "template_exported": m17,
        "template_imported": m18,
        "template_name_label": MessageLookupByLibrary.simpleMessage("Name"),
        "template_replace_confirm": m19,
        "templates": MessageLookupByLibrary.simpleMessage("Templates"),
        "templates_not_found":
            MessageLookupByLibrary.simpleMessage("No templates"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "time": MessageLookupByLibrary.simpleMessage("Time"),
        "timeout_error": MessageLookupByLibrary.simpleMessage("Timeout"),
        "to": MessageLookupByLibrary.simpleMessage("To"),
        "typeOptional": MessageLookupByLibrary.simpleMessage("Type (optional)"),
        "undo": MessageLookupByLibrary.simpleMessage("Undo"),
        "unknown": MessageLookupByLibrary.simpleMessage("Unknown"),
        "unpin": MessageLookupByLibrary.simpleMessage("Unpin"),
        "unsaved_changes_content":
            MessageLookupByLibrary.simpleMessage("Save changes before exit?"),
        "unsaved_changes_title":
            MessageLookupByLibrary.simpleMessage("Unsaved changes"),
        "use_system_colors":
            MessageLookupByLibrary.simpleMessage("System colors"),
        "use_system_colors_unavailable":
            MessageLookupByLibrary.simpleMessage("Android 12+ only"),
        "usedLibraries": MessageLookupByLibrary.simpleMessage("Libraries"),
        "verifying_integrity":
            MessageLookupByLibrary.simpleMessage("Checking..."),
        "version": MessageLookupByLibrary.simpleMessage("Version"),
        "web_not_supported":
            MessageLookupByLibrary.simpleMessage("Web unsupported"),
        "welcome_message": MessageLookupByLibrary.simpleMessage("Welcome!"),
        "window_manager_initialization_error":
            MessageLookupByLibrary.simpleMessage("Window mgr init error"),
        "word_export_error":
            MessageLookupByLibrary.simpleMessage("Export error Word"),
        "word_export_success":
            MessageLookupByLibrary.simpleMessage("Word export success"),
        "years": MessageLookupByLibrary.simpleMessage("years"),
        "years_ago": m20,
        "young": MessageLookupByLibrary.simpleMessage("Young"),
        "z_to_a": MessageLookupByLibrary.simpleMessage("Z-A")
      };
}
