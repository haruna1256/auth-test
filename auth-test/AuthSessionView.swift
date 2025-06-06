//
//  AuthSessionView.swift
//  auth-test
//
//  Created by 川岸遥奈 on 2025/06/02.
//



import SwiftUI
// Appleの認証サービス（ASWebAuthenticationSession など）を使うためのフレームワーク
import AuthenticationServices


// SwiftUIでASWebAuthenticationSession
//（Sign in with Apple などで使われるWeb認証）を使って外部認証フローを開始し、認証が完了するとコールバックURLを処理するカスタムビューを定義
struct AuthSessionView: UIViewControllerRepresentable {
    //    認証成功時に呼ばれるクロージャ（関数）。リダイレクトされたURLが引数として渡される
    var callback: (URL) -> Void
    //    認証を開始するためのURL。ログインページなどに飛ばす
    let authURL = "https://authbase-test.kokomeow.com/auth/oauth/google?ismobile=1"
    //    認証後にリダイレクトされるURLスキーム。
    let customURLScheme = "authbase"
    
    //　Coordinator インスタンスを作成。後で認証画面の表示に必要
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    //    SwiftUIで表示する UIViewController を生成
    func makeUIViewController(context: Context) -> UIViewController {
        //        空のビューコントローラーを作成
        let viewController = UIViewController()
        //        authURL を URL 型に変換。失敗したらそのまま空のコントローラーを返す
        guard let url = URL(string: authURL) else {
            return viewController
        }
        //        認証セッションを作成。指定したURLにアクセスし、認証が成功したらコールバックが呼ばれる
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: customURLScheme) { callbackURL, error in
            //            成功時：リダイレクト先のURLをクロージャに渡す
            if let callbackURL {
                callback(callbackURL)
            } else if let error {
                debugPrint(error.localizedDescription)
                return
            }
        }
        //        認証時にSafariの一時的なセッションを使う
        session.prefersEphemeralWebBrowserSession = true
        //        の画面上にWeb認証画面を表示するかを指定するためのコーディネーターを設定
        session.presentationContextProvider = context.coordinator
        
        
        session.start() // 認証セッション開始、アプリ内ブラウザ起動
        //        空のビューコントローラーを返す（認証用Web UIが重なるため、何も表示しなくてよい）
        return viewController
    }
    //    UIViewControllerRepresentable プロトコルに必要なメソッド。ここでは更新処理がないので空実装
    func updateUIViewController(_: UIViewController, context _: Context) {}
}

//認証画面を表示するウィンドウ（Anchor）を提供するためのクラス
class Coordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
    //    呼び出し元のビュー（AuthSessionView）を保持
    var parent: AuthSessionView
    //    parent を初期化。
    init(parent: AuthSessionView) {
        
        self.parent = parent
    }
    //    認証Web画面を表示するためのウィンドウを返す。
    
    //    UIApplication.shared.connectedScenes から最初のウィンドウを取得。
    func presentationAnchor(for _: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        guard let window = windowScene?.windows.first else {
//            ウィンドウが取得できなかった場合にアプリをクラッシュさせる
            fatalError("No windows in the application")
        }
        return window
    }
}




