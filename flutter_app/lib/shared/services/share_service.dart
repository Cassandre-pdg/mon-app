import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:share_plus/share_plus.dart';

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
          'Je t\'invite sur Kolyb, l\'app pour les indépendants qui avancent à leur rythme, ensemble.\n\n'
          'Rejoins-moi : kolyb.app/invite/$inviteCode\n\n'
          '"Ton élan, au quotidien."';
      await Share.share(text, subject: 'Rejoins-moi sur Kolyb');
    } catch (e) {
      _log.e('ShareService.shareInvite', error: e);
    }
  }

  /// Partage un texte simple (bilan hebdo, stats, etc.)
  /// [sharePositionOrigin] requis sur iPad/iOS pour positionner le popover natif
  static Future<void> shareText(String text, {Rect? sharePositionOrigin}) async {
    try {
      await Share.share(
        text,
        subject: 'Kolyb',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      _log.e('ShareService.shareText', error: e);
    }
  }
}
