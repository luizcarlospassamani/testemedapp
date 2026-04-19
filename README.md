# GOHelp (testemedapp)

Aplicativo iOS SwiftUI para controle hospitalar com Firestore e notificações locais.

## Estrutura

- `App/` inicialização do app e Firebase
- `Models/` modelos de domínio
- `ViewModels/` lógica MVVM
- `Views/` telas SwiftUI
- `Services/` integração Firestore
- `Managers/` notificações locais

## Firebase (importante)

1. No Xcode, adicione o package:
   - `https://github.com/firebase/firebase-ios-sdk`
2. Selecione os produtos:
   - `FirebaseCore`
   - `FirebaseFirestore`
3. Arraste `GoogleService-Info.plist` para o projeto e marque o target do app.
4. `FirebaseApp.configure()` já está no `GOHelpApp`.

## Observações

- Usuário simples (sem Firebase Auth).
- Persistência no Firestore:
  - `users/{userId}`
  - `patients/{patientId}`
  - `patients/{patientId}/history/{historyId}`
- Notificações locais por paciente com identificadores únicos.
