//
//  authbase.swift
//  auth-test
//
//  Created by 川岸遥奈 on 2025/06/06.
//

import Foundation


//　authから帰ってくる情報
//ユーザー情報を表す構造体
//Codable に準拠することで、JSONとの相互変換が可能
struct UserInfo: Codable {
    
    let email: String
    let name: String
    let provCode: String
    let provUID: String // もし数値が大きすぎてIntに入らない場合はInt64などを検討
    let userId: String
    
    //    JSONのキーとSwiftのプロパティ名をマッピングするための列挙型を定義
    enum CodingKeys: String, CodingKey {
        //        SON側のキー（スネークケース）とSwiftのプロパティ名（キャメルケース）を対応づけ
        case email
        case name
        case provCode = "prov_code"
        case provUID = "prov_uid"
        case userId = "user_id"
    }
    
}

//非同期関数 FetchInfo を定義。AuthSessionViewの処理でユーザー情報を取得し、UserProfile を返す
//エラーが起こる可能性があるため throws をつけてい
func fetchInfo()async throws -> UserInfo {
    //    認証用トークンの定義
    var token = ""
    
//    do {
        //    getKeyChain 関数を使って、Keychain（セキュアなストレージ）から "authToken" を取得
        let getToken = getKeyChain(key: "authToken")
        //        トークンが取得できたかどうか、デバッグ出力
        debugPrint(getToken)
        //        トークンが取得できなければ、空の UserProfile を返して早期リターン
        if getToken == nil {
            return UserInfo(email: "", name: "", provCode: "", provUID: "0", userId: "")
        }
        //        トークンが nil ではないと確定したので、強制アンラップして token に代入
        token = getToken!
//    } catch {
//        debugPrint("failed to get token")
//        return UserInfo(email: "", name: "", provCode: "", provUID: "0", userId: "")
//        
//    }
    do{
        //    取得したトークンをデバッグ出力
        debugPrint(token)
        //        アクセス先のURLを作成
        guard let url = URL(string: "https://authbase-test.kokomeow.com/auth/me") else {
            debugPrint("Invalid URL")
            return UserInfo(email: "", name: "", provCode: "", provUID: "0", userId: "")
        }
        //        URLRequest オブジェクトを作成
        var request = URLRequest(url: url)
        //        リクエストヘッダーに JSON を指定
        //        Authorization にトークンをセット
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        //        非同期で HTTP リクエストを送信し、レスポンスデータとレスポンスメタ情報（使われていない）を受け取る
        let (response,error) = await try URLSession.shared.data(for: request)
        debugPrint(error)
        
        //        JSON を UserProfile 構造体にデコード
        //        デコードに失敗すると catch に飛ぶ
        let decoder = JSONDecoder()
        let userInfo = try decoder.decode(UserInfo.self, from: response)
        print(userInfo)
        return userInfo
        //        ネットワークエラーやデコード失敗時に、ログを出しつつ空の userInfo を返す
    } catch {
        debugPrint("failed to fetch")
        debugPrint(error)
        return UserInfo(email: "", name: "", provCode: "", provUID: "0", userId: "")
    }
}


