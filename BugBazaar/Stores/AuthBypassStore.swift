import Foundation

private let demoAuthBypassToken = "revyl-demo-token"

enum AuthBypassRole: String {
    case collector
    case support
}

struct AuthBypassSession {
    let name: String
    let email: String
    let role: AuthBypassRole
    let source = "revyl-deeplink"
}

struct AuthBypassStatus {
    enum State { case idle, accepted, rejected }
    var state: State
    var message: String
}

struct AuthBypassLaunchConfig {
    enum Source: String {
        case launchEnv = "launch-env"
        case demoFallback = "demo-fallback"
    }

    let enabled: Bool
    let expectedToken: String
    let source: Source

    static func read() -> AuthBypassLaunchConfig {
        let env = ProcessInfo.processInfo.environment
        let enabled = env["REVYL_AUTH_BYPASS_ENABLED"]
        let token = env["REVYL_AUTH_BYPASS_TOKEN"]
        return AuthBypassLaunchConfig(
            enabled: enabled == nil ? true : enabled == "true",
            expectedToken: token?.isEmpty == false ? token! : demoAuthBypassToken,
            source: token?.isEmpty == false ? .launchEnv : .demoFallback
        )
    }
}

/// Where an accepted auth-bypass link should route. Mirrors the redirect
/// allowlist in the original app's AuthBypassContext.
enum AuthBypassRedirect: String {
    case shop
    case account
    case cart
    case checkout
    case productThree

    static let allowlist: [String: AuthBypassRedirect] = [
        "/": .shop,
        "/shop": .shop,
        "/account": .account,
        "/cart": .cart,
        "/checkout": .checkout,
        "/product/3": .productThree,
    ]

    var label: String {
        switch self {
        case .shop: return "/(tabs)"
        case .account: return "/(tabs)/account"
        case .cart: return "/cart"
        case .checkout: return "/checkout"
        case .productThree: return "/product/3"
        }
    }
}

enum AuthBypassResult {
    case notHandled
    case rejected
    case accepted(AuthBypassRedirect)
}

private let profiles: [AuthBypassRole: AuthBypassSession] = [
    .collector: AuthBypassSession(
        name: "Revyl Test Collector",
        email: "revyl.collector@bugbazaar.test",
        role: .collector
    ),
    .support: AuthBypassSession(
        name: "Revyl Support Agent",
        email: "support.agent@bugbazaar.test",
        role: .support
    ),
]

final class AuthBypassStore: ObservableObject {
    @Published private(set) var session: AuthBypassSession?
    @Published private(set) var status = AuthBypassStatus(
        state: .idle,
        message: "No auth bypass link has been opened. Start the app with launch vars, then open bug-bazaar://revyl-auth."
    )
    let launchConfig = AuthBypassLaunchConfig.read()

    func handleAuthBypassURL(_ url: URL) -> AuthBypassResult {
        guard url.scheme == "bug-bazaar", authBypassPath(url) == "revyl-auth" else {
            return .notHandled
        }

        guard launchConfig.enabled else {
            status = AuthBypassStatus(
                state: .rejected,
                message: "Rejected auth bypass link because REVYL_AUTH_BYPASS_ENABLED is not true."
            )
            return .rejected
        }

        let params = queryItems(url)

        guard singleParam(params, "token") == launchConfig.expectedToken else {
            status = AuthBypassStatus(
                state: .rejected,
                message: "Rejected auth bypass link because the token did not match the launch variable."
            )
            return .rejected
        }

        guard let role = resolveRole(singleParam(params, "role")) else {
            status = AuthBypassStatus(
                state: .rejected,
                message: "Rejected auth bypass link because the role is not allowlisted."
            )
            return .rejected
        }

        guard let redirect = resolveRedirect(singleParam(params, "redirect")) else {
            status = AuthBypassStatus(
                state: .rejected,
                message: "Rejected auth bypass link because the redirect is not allowlisted."
            )
            return .rejected
        }

        let profile = profiles[role]!
        session = profile
        status = AuthBypassStatus(
            state: .accepted,
            message: "Signed in as \(profile.name) and routed to \(redirect.label)."
        )
        return .accepted(redirect)
    }

    func signOut() {
        session = nil
        status = AuthBypassStatus(
            state: .idle,
            message: "Signed out of the Revyl auth bypass demo session."
        )
    }

    private func authBypassPath(_ url: URL) -> String {
        if let host = url.host, !host.isEmpty {
            return host
        }
        return url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    }

    private func queryItems(_ url: URL) -> [URLQueryItem] {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
    }

    private func singleParam(_ items: [URLQueryItem], _ key: String) -> String? {
        guard let value = items.first(where: { $0.name == key })?.value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }

    private func resolveRole(_ raw: String?) -> AuthBypassRole? {
        guard let raw else { return .collector }
        return AuthBypassRole(rawValue: raw)
    }

    private func resolveRedirect(_ raw: String?) -> AuthBypassRedirect? {
        guard let raw else { return .account }
        return AuthBypassRedirect.allowlist[raw]
    }
}
