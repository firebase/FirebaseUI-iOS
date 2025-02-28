class FirebaseUIAction: Identifiable {

}

protocol AuthState {}

class SigningIn: AuthState {
    // just allow one to be created
  @MainActor static let shared = SigningIn()
    
    // Private initializer to prevent creating multiple instances
    private init() {}
}


class AuthStateChangeAction<T: AuthState>: FirebaseUIAction {
    let callback: (T) -> Void

    init(callback: @escaping (T) -> Void) {
        self.callback = callback
    }

    func matches(state: AuthState) -> Bool {
        return state is T
    }

    func invoke(state: T) {
        callback(state)
    }
}
