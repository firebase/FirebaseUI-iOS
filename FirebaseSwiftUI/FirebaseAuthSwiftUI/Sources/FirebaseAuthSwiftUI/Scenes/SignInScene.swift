import SwiftUI

struct SignInScene: Scene {
  @available(iOS 14.0, *)
  var body: some Scene {
        WindowGroup {
            SignIn()
        }
    }
}

struct SignIn: View {
    @State private var email: String = ""
    @State private var password: String = ""
    var actions: [FirebaseUIAction] = []
    
  var body: some View {
      VStack {
          Text("Sign in")
              .font(.largeTitle)
              .padding()

          TextField("Email", text: $email)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .padding()

          SecureField("Password", text: $password)
              .textFieldStyle(RoundedBorderTextFieldStyle())
              .padding()

          Button(action: {
              print("Register button tapped with email: \(email) and password: \(password)")
              // Add registration logic here
          }) {
              Text("Sign in")
                  .font(.headline)
                  .padding()
                  .frame(maxWidth: .infinity)
                  .background(Color.blue)
                  .foregroundColor(.white)
                  .cornerRadius(10)
          }
          .padding()
      }
      .padding()
  }
}
