import '../models/personal_best.dart';
import 'local_json_store.dart';

abstract class IPersonalBestRepository {
  Future<List<PersonalBest>> getAll(String playerId);
  Future<List<PersonalBest>> getForDrill(String playerId, String drillCode);
  Future<void> save(PersonalBest pb);
}

class LocalPersonalBestRepository implements IPersonalBestRepository {
  LocalPersonalBestRepository()
      : _store = LocalJsonStore<PersonalBest>(
          key: 'poolos_v2.personal_bests',
          fromJson: PersonalBest.fromJson,
          toJson: (p) => p.toJson(),
        );

  final LocalJsonStore<PersonalBest> _store;

  @override
  Future<List<PersonalBest>> getAll(String playerId) async {
    final all = await _store.readAll();
    return all.where((b) => b.playerId == playerId).toList();
  }

  @override
  Future<List<PersonalBest>> getForDrill(
      String playerId, String drillCode) async {
    final all = await getAll(playerId);
    return all.where((b) => b.drillCode == drillCode).toList();
  }

  @override
  Future<void> save(PersonalBest pb) async {
    final all = await _store.readAll();
    final idx = all.indexWhere((b) =>
        b.playerId == pb.playerId &&
        b.drillCode == pb.drillCode &&
        b.metric == pb.metric);
    if (idx >= 0) {
      // Replace if better.
      if (pb.value > all[idx].value) all[idx] = pb;
    } else {
      all.add(pb);
    }
    await _store.writeAll(all);
  }
}
