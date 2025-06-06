//
//  keychain.swift
//  auth-test
//
//  Created by 川岸遥奈 on 2025/06/04.
//

//基本的な機能や便利なAPIを使うために必要な宣言
import Foundation


//引数：
//tag：保存する際の識別子（文字列）
//value：保存するデータ（文字列）
//戻り値：保存が成功したかどうか（true / false）
func saveKeyChain(tag: String, value: String) -> Bool{
    //    valueをUTF-8のデータ型（Data）に変換
    //    変換できなければ失敗して終了
    guard let data = value.data(using: .utf8) else {
        return false
    }
    //    keychainに保存するqueryの定義
    let saveQuery: [String: Any] = [
        kSecClass               as String:  kSecClassKey,//kSecClassKey: 「鍵」データとして保存
        kSecAttrApplicationTag  as String: tag,//kSecAttrApplicationTag: タグ（識別子）を指定
        kSecValueData           as String: data//kSecValueData: 保存するデータ本体
    ]
    
    //    既に同じタグのデータがあるかどうか調べるための検索クエリ
    let searchQuery: [String: Any] = [
        kSecClass               as String: kSecClassKey,
        kSecAttrApplicationTag  as String: tag,
        kSecReturnData          as String: true    //アイテムの属性情報も返してほしいと指定する
    ]
    
    //    検索実行
    //    上のクエリでKeyChainを検索 = searchQuery as
    //    結果のステータスコードを matchingstatus に代入
    //    CFDictionary は Appleの低レベルAPIで使われる辞書（キーと値のセット）。
    //    Swift の [String: Any] を Core Foundation（低レベルAPI）とやり取りするために使う
    let matchingStatus = SecItemCopyMatching(searchQuery as CFDictionary, nil)
    
    //    実際に保存する時の成功／失敗を入れる変数
    var itemAddStatus: OSStatus
    
    //    保存先のタグが存在しない場合
    if matchingStatus == errSecItemNotFound {
        //        新規保存
        //        saveQuery を元に保存
        itemAddStatus = SecItemAdd(saveQuery as CFDictionary, nil)
        
        //        既にデータが存在していた場合
    }else if matchingStatus == errSecSuccess{
        //        古いデータを削除してから保存し直す
        if SecItemDelete(saveQuery as CFDictionary) == errSecSuccess {
            print("削除成功")
        }else {
            print("削除失敗")
        }
        //        保存を行う
        itemAddStatus = SecItemAdd(saveQuery as CFDictionary, nil)
        
    }else{
        //        保存失敗
        return false
    }
    
    //    保存に成功したかのチェック
    if itemAddStatus == errSecSuccess {
        print("正常終了")
    }else{
        return false
    }
    
    return true
}

//引数 tag（文字列）を受け取り、キーチェーンからそのタグのアイテムを削除
func deleteKeyChain(tag: String) -> Bool {
    
//    tag に一致するデータを検索・削除するためのクエリ
    let saveQuery: [String: Any] = [
        kSecClass               as String:  kSecClassKey,//kSecClassKey: 「鍵」データとして保存
        kSecAttrApplicationTag  as String: tag,//kSecAttrApplicationTag: タグ（識別子）を指定
    ]
    let searchQuery:[String:Any] = [
        kSecClass               as String : kSecClassKey,
        kSecAttrApplicationTag  as String : tag,
        kSecReturnAttributes    as String : true
    ]
    
    //    検索実行
    let matchingstatus = SecItemCopyMatching( searchQuery as CFDictionary, nil)
//    データの存在チェック
    if matchingstatus == errSecItemNotFound {
        return false
    } else if matchingstatus == errSecSuccess {
        //存在する場合は削除して true を返す
        if SecItemDelete(saveQuery as CFDictionary) == errSecSuccess{
            return true
        }else{
            return false
        }
        
    }else{
        return false
    }
    
}

//データを取得
//key に対応するデータ（String）を取り出す関数
func getKeyChain(key: String) -> String? {
//    取得に必要な情報（データ＋属性）を要求
    let searchQuery:[String:Any] = [
        kSecClass               as String : kSecClassKey,
        kSecAttrApplicationTag  as String : key,
        kSecReturnData          as String : kCFBooleanTrue as Any,
        kSecReturnAttributes    as String : true
    ]
//    検索結果を受け取るための変数
    var item: AnyObject?
//    Keychain に対してクエリを実行し、該当するアイテムを取得
//    成功すれば item にデータが入り、status は errSecSuccess になる
    let status = SecItemCopyMatching(searchQuery as CFDictionary, &item)
//    取得に失敗した場合（データが存在しない、権限エラーなど）は nil
    guard status == errSecSuccess else {
        return nil
    }
//    取得した item を NSDictionary にキャスト。Keychain API は結果を辞書として返してくることが多い
    let d = item as? NSDictionary
    
//    v_Data というキーから実際のデータ部分を取り出し、それを Data 型として取得できるかをチェック
    guard let d = item as? NSDictionary,
              let keyData = d["v_Data"] as? Data,
              let value = String(data: keyData, encoding: .utf8) else {
            print("KeyChainからの取得に失敗しました。データの変換に失敗した可能性があります。")
            return nil
        }
        return value
    
}
