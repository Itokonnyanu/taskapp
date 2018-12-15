//
//  ViewController.swift
//  taskapp
//
//  Created by 佐々木　祐太 on 2018/12/10.
//  Copyright © 2018 佐々木　祐太. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
   
    

    @IBOutlet weak var tableView: UITableView!
    
    
    var searchResults: Results<Task>!
    var searchController = UISearchController()

    
    // Realmインスタンスを取得する
    let realm = try! Realm()  
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    //.object(_:)で(_:)内のオブジェクトを配列的な形で全て返してる。
    //メソッドチェーンをしている。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)  // ←追加

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        //これいる？
        searchController = UISearchController(searchResultsController: nil)
        //デリゲートみたいなの
        searchController.searchResultsUpdater = self
        //場所設定
        searchController.searchBar.sizeToFit()
        tableView.tableHeaderView = searchController.searchBar
        //その他設定
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
    
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // segue で画面遷移するに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
    // cellタップで呼ばれる時
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
    // addボタンで呼ばれる時
        } else {
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive {
            
            return searchResults.count
        } else {
            return taskArray.count
        }
        
 
    }
    
    // テーブルビュー上で表示する時の各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //検索バーが起動中か否か
        if searchController.isActive {
         
            let task = searchResults[indexPath.row]
            //データベースからテキストに代入
            cell.textLabel?.text = task.title
            
            //datefomatterを取得
            let formatter = DateFormatter()
            //日付の形式に｀2018-12-12 15:18｀ のような文字列を設定。他の設定の仕方はdatefomatterの使い方を調べて。
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString:String = formatter.string(from: task.date)
            
            //カテゴリーだけの色を変換
            let main_string = dateString + ":    \(task.category)"
            let string_to_color = task.category
            let range = (main_string as NSString).range(of: string_to_color)
            let attribute = NSMutableAttributedString.init(string: main_string)
            //カテゴリーの色を赤色に
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red , range: range)
            //サブタイトルのテキストを設定
            cell.detailTextLabel?.attributedText = attribute
           
        } else {
            // Cellに値を設定する.
            let task = taskArray[indexPath.row]
            //データベースからテキストに代入
            cell.textLabel?.text = task.title
        
            //datefomatterを取得
            let formatter = DateFormatter()
            //日付の形式に｀2018-12-12 15:18｀ のような文字列を設定。他の設定の仕方はdatefomatterの使い方を調べて。
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString:String = formatter.string(from: task.date)
            //カテゴリーだけの色を変換
            let main_string = dateString + "     \(task.category)"
            let string_to_color = task.category
            let range = (main_string as NSString).range(of: string_to_color)
            let attribute = NSMutableAttributedString.init(string: main_string)
            //カテゴリーの色を灰色に
            attribute.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.darkGray , range: range)
            //サブタイトルのテキストを設定
            cell.detailTextLabel?.attributedText = attribute
        
        }
        return cell
    }
    
    // 文字が入力される度に呼ばれる
    func updateSearchResults(for searchController: UISearchController) {
        //大文字小文字に関係しないカテゴリーの検索
        self.searchResults = taskArray.realm?.objects(Task.self).filter(
            "category contains %@", searchController.searchBar.text!)
        self.tableView.reloadData()
     
        }
       
    
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return .delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            // データベースから削除する
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                    
                }
            }
        }
     }
}








