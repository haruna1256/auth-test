//
//  loginView.swift
//  auth-test
//
//  Created by 川岸遥奈 on 2025/06/02.
//

import SwiftUI

struct LoginView: View {
    // 状態管理用の変数 code を宣言。ログイン時に取得するトークンを格納するため
    @State private var code: String?
    
    var body: some View {
        NavigationView {
            VStack{
                Text("ログイン画面")
                    .font(.title)
                //                コンテンツを中央寄せ
                Spacer()
                
                if let code = self.code{
                    Text("ログイン済み")
                    //                    実際に取得した code（トークン文字列）を表示
                    Text("\(code)")
                }else {
                    Text("未ログイン")
                    //                    カスタムビュー AuthSessionView を呼び出して、ログイン処理
                    AuthSessionView{
                        //                        クロージャとして callbackURL を受け取っています（おそらくOAuthやURLスキームによる認証結果）
                        callbackURL in
                        //                        self は、今の構造体やクラスの中で使っている自分自身
                        //                         self.code = 状態変数 code（@State）の中身
                        //                        認証後に受け取ったURLからトークンを抽出して、code にセット
                        self.code = getCode(callbackURL: callbackURL)
                    }
                }
                Spacer()
            }
        }
    }
    
    //    認証結果で受け取ったURLから トークン（token）を抽出 する関数
    func getCode(callbackURL: URL) -> String? {
        //        デバッグ用にURLを出力
        print(callbackURL)
        
        //        URLを構造的に解析し、クエリパラメータを取り出す
        //        callbackURL は、ログイン後などにアプリが受け取る URL
        //        guard＝早期リターンに使われる
        guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              //              queryItems は、URLの「?以降のパラメータ一覧」を [URLQueryItem] で取り出すプロパティ
              let queryItems = components.queryItems else {
            //            失敗したら nil を返すことでアプリがクラッシュしないように
            return nil
        }
        if let codeValue = queryItems.first(where: { $0.name == "token" })?.value{
            print("Code value:\(codeValue)")
            
//            KeyChain（キーチェーン）は、Appleの提供する安全なデータ保存領域で、ログイントークンやパスワードなどの機密情報を保存する
            saveKeyChain(tag:"authToken",value: codeValue)
//            取得したトークンを返す
            return codeValue
            
        }else{
//            token が見つからない場合は nil
                return nil
            }
            
            
        }
        
    }
    


