/// Default backend, used until a user logs in with a self-hosted
/// `user@server.com` identifier and overrides it (see `AuthRepository`,
/// Phase 1). Mirrors Alpine's `environment.apiUrl`.
abstract final class AppConfig {
  static const defaultApiUrl = 'https://api.venta.gg';
}
