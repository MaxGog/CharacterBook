import 'package:characterbook/data/models/custom_event_model.dart';
import 'package:characterbook/data/repositories/custom_event_repository.dart';

class CustomEventService {
  final CustomEventRepository _repository;

  CustomEventService(this._repository);

  Future<List<CustomEvent>> getAll() => _repository.getAll();
  Future<void> save(CustomEvent event) => _repository.save(event);
  Future<void> delete(String id) => _repository.delete(id);
  Future<CustomEvent?> getById(String id) async => _repository.getById(id);
}
