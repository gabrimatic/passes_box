import 'dart:math';

class PassphraseGenerator {
  static const _words = [
    'apple', 'brave', 'cloud', 'dance', 'eagle', 'flame', 'green', 'happy',
    'irony', 'joker', 'karma', 'light', 'magic', 'north', 'ocean', 'peace',
    'queen', 'river', 'storm', 'tiger', 'unity', 'vivid', 'water', 'xenon',
    'yacht', 'zebra', 'about', 'above', 'after', 'again', 'agree', 'ahead',
    'alarm', 'album', 'allow', 'alone', 'along', 'aloud', 'angel', 'angry',
    'ankle', 'annex', 'anvil', 'apart', 'arena', 'argue', 'arise', 'arrow',
    'aside', 'asked', 'aspen', 'asset', 'atlas', 'audio', 'avoid', 'awake',
    'awful', 'bacon', 'badge', 'basic', 'beard', 'beast', 'below', 'bench',
    'biome', 'black', 'blank', 'blaze', 'blend', 'block', 'blond', 'bloom',
    'blown', 'board', 'bonus', 'boost', 'bound', 'boxed', 'brain', 'brand',
    'bread', 'break', 'breed', 'brick', 'bride', 'brief', 'bring', 'broad',
    'brook', 'brown', 'brush', 'buddy', 'build', 'burst', 'cabin', 'cable',
    'camel', 'canal', 'candy', 'cargo', 'carry', 'catch', 'cause', 'cedar',
    'chain', 'chair', 'chalk', 'charm', 'chart', 'chase', 'check', 'cheek',
    'cheer', 'chess', 'chest', 'chief', 'child', 'china', 'chord', 'civic',
    'claim', 'clash', 'class', 'clean', 'clear', 'clerk', 'click', 'climb',
    'cling', 'coach', 'coast', 'cobra', 'comet', 'comic', 'coral', 'couch',
    'count', 'court', 'cover', 'craft', 'crane', 'crash', 'crazy', 'cream',
    'creek', 'crime', 'crisp', 'cross', 'crowd', 'crown', 'crush', 'crust',
    'cycle', 'daisy', 'daily', 'debut', 'decay', 'decor', 'depth', 'derby',
    'digit', 'disco', 'diver', 'dodge', 'dolly', 'donor', 'doubt', 'dough',
    'draft', 'drain', 'drama', 'drawl', 'dream', 'drill', 'drink', 'drive',
    'drone', 'drove', 'drums', 'dryer', 'duchy', 'dully', 'dunes', 'dusty',
  ];

  static String generate({int wordCount = 4, String separator = '-'}) {
    final random = Random.secure();
    final selected = List.generate(
      wordCount,
      (_) => _words[random.nextInt(_words.length)],
    );
    return selected.join(separator);
  }
}
