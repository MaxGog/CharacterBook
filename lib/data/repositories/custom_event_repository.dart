import 'package:characterbook/data/models/custom_event_model.dart';
import 'package:hive/hive.dart';

abstract class CustomEventRepository {
  Future<List<CustomEvent>> getAll();
  Future<void> save(CustomEvent event);
  Future<void> delete(String id);
  Future<CustomEvent?> getById(String id);
}

class CustomEventRepositoryHive implements CustomEventRepository {
  final Box<CustomEvent> box;

  CustomEventRepositoryHive(this.box);

  @override
  Future<List<CustomEvent>> getAll() async => box.values.toList();

  @override
  Future<void> save(CustomEvent event) async => box.put(event.id, event);

  @override
  Future<void> delete(String id) async => box.delete(id);

  @override
  Future<CustomEvent?> getById(String id) async => box.get(id);
}
