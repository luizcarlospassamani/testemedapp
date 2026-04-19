# GOHelp (testemedapp)

Aplicativo iOS SwiftUI para controle hospitalar com Firestore e notificações locais.

## ✅ Abrir no Xcode (macOS)

1. Clone o repositório.
2. Abra **`GOHelp.xcodeproj`** no Xcode.
3. Aguarde o Xcode resolver os pacotes SwiftPM (Firebase).
4. Em **Signing & Capabilities**, selecione seu **Team**.
5. Rode no simulador (ou iPhone).

## Estrutura

- `GOHelp.xcodeproj` projeto iOS pronto para abrir no Xcode
- `GOHelp/` código-fonte do app
  - `App/` inicialização do app e Firebase
  - `Models/` modelos de domínio
  - `ViewModels/` lógica MVVM
  - `Views/` telas SwiftUI
  - `Services/` integração Firestore
  - `Managers/` notificações locais
  - `Resources/Assets.xcassets` assets do app

## Firebase (importante)

1. O projeto já referencia o package:
   - `https://github.com/firebase/firebase-ios-sdk`
2. Produtos usados:
   - `FirebaseCore`
   - `FirebaseFirestore`
3. O arquivo `GOHelp/GoogleService-Info.plist` já está incluído no target.
4. `FirebaseApp.configure()` já está no `GOHelpApp`.

## Observações

- Usuário simples (sem Firebase Auth).
- Persistência no Firestore:
  - `users/{userId}`
  - `patients/{patientId}`
  - `patients/{patientId}/history/{historyId}`
- Notificações locais por paciente com identificadores únicos.
