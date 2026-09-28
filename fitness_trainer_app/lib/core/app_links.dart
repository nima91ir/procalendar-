/// Links to things that live outside the app.
library;

/// Telegram channel for bug reports and questions, shown in Settings.
///
/// This is an **invite link** (`t.me/+…`), not a public `@username`. Two
/// consequences worth knowing:
///  * It can be revoked or regenerated from Telegram at any time. If that
///    happens, the copy already installed on users' devices keeps pointing at
///    the dead invite until a new build ships.
///  * Anyone who joins can read the channel. If reports are meant to be
///    private, a channel users cannot post in (or a `@username` to message
///    directly) would be better than a group.
///
/// While this is empty the Settings row is hidden, so no user is ever sent to a
/// link that does not exist.
const String supportTelegramUrl = 'https://t.me/+diN--fmvzS44OWFk';

