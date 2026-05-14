import 'package:logger/logger.dart';

final _log = Logger();

class ShareService {
  ShareService._();

  /// Partage le lien d'invitation personnalisé
  static Future<void> shareInvite({
    required String inviteCode,
    required String firstName,
  }) async {
    try {
      final text =
          '🚀 Je t\'invite sur Kolyb, l\'app pour les indépendants qui avancent à leur rythme, ensemble.\n\n'
          'Rejoins-moi : kolyb.app/invite/$inviteCode\n\n'
          '"Ton élan, au quotidien." ✨';
      _log.i('ShareService.shareInvite: $text');
      // TODO V2 : intégrer share_plus pour le partage natif
    } catch (e) {
      _log.e('ShareService.shareInvite', error: e);
    }
  }

  /// Partage un texte simple (bilan hebdo, stats, etc.)
  static Future<void> shareText(String text) async {
    try {
      _log.i('ShareService.shareText: $text');
      // TODO V2 : intégrer share_plus pour le partage natif
    } catch (e) {
      _log.e('ShareService.shareText', error: e);
    }
  }
}
