public enum AccountError: Error, Equatable {
    case notLoggedIn
    case menuClosed
}

/// A user of the app.
public struct User: Equatable {
    public let username: String
    public let balance: Int

    public init(username: String, balance: Int) {
        self.username = username
        self.balance = balance
    }
}

/// The signed-in user.
public final class Session {
    public private(set) var user: User?

    public init() { }

    public func logIn(_ user: User) {
        self.user = user
    }
}

/// The menu behind the user's avatar. It must be open to show the user's profile or account.
public final class ProfileMenu {
    enum Item: CaseIterable {
        case profile
        case account
    }

    private let session: Session
    private var items: [Item: String] = [:]

    public init(session: Session) {
        self.session = session
    }

    /// Opens the menu for the signed-in user, and loads each of its items.
    public func open() throws {
        guard let user = session.user else {
            throw AccountError.notLoggedIn
        }
        for item in Item.allCases {
            items[item] = text(of: item, for: user)
        }
    }

    /// The username that the profile shows.
    public func profile() throws -> String {
        guard let username = items[.profile] else {
            throw AccountError.menuClosed
        }
        return username
    }

    /// The balance that the account shows.
    public func account() throws -> String {
        guard let balance = items[.account] else {
            throw AccountError.menuClosed
        }
        return balance
    }

    private func text(of item: Item, for user: User) -> String {
        switch item {
            case .profile: user.username
            case .account: "$\(user.balance)"
        }
    }
}
