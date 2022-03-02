//
//  SQLiteHandler.swift
//  iosApp
//
//  Created by 許景評 on 2021/7/31.
//  Copyright © 2021 許景評. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteHandler {
    var db : OpaquePointer?;
    var path : String = "myDb.sqlite";
    
    init() {
        self.db = createDb();
        self.createTable();
    }
    
    func createDb() -> OpaquePointer?{
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathExtension(path)
        
        var db : OpaquePointer? = nil
        
        if(sqlite3_open(filePath.path, &db) != SQLITE_OK){
            print("creation failed");
            return nil;
        }
        else{
            print("creation successful, path: \(path)")
            return db;
        }
    }
    
    func createTable(){
        let query = "CREATE TABLE IF NOT EXISTS memberInfo(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, account TEXT, password TEXT, gender TEXT, number TEXT);"
        var createTable : OpaquePointer? = nil;
        if(sqlite3_prepare_v2(self.db, query, -1, &createTable, nil) == SQLITE_OK){
            if(sqlite3_step(createTable) == SQLITE_DONE){
                print("tabel creation successful")
            }
            else{
                print("tabel creation failed")
            }
        }
        else{
            print("tabel creation failed")
        }
    }
    
    func select(query: String, colCNT: Int) -> [[String]] {
        var statement: OpaquePointer?
        var result: [[String]] = []
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW{
                var rowResult: [String] = []
                for index in 0...colCNT{
                    let col = sqlite3_column_text(statement, Int32(index))
                    if col != nil{
                        rowResult.append(String(cString: sqlite3_column_text(statement, Int32(index))))
                    }
                }
                result.append(rowResult)
            }
        }
        else{
            print("query not prepared")
        }
        
        sqlite3_finalize(statement)
        return result
    }
    
    func select(query: String, colCNT: Int, values: [String]) -> [[String]] {
        var statement: OpaquePointer?
        var result: [[String]] = []
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            for (index, value) in values.enumerated(){
                sqlite3_bind_text(statement, Int32(index + 1), NSString(string: value).utf8String, -1, nil)
            }
            
            while sqlite3_step(statement) == SQLITE_ROW{
                var rowResult: [String] = []
                for index in 0...colCNT{
                    rowResult.append(String(cString: sqlite3_column_text(statement, Int32(index))))
                }
                result.append(rowResult)
            }
        }
        else{
            print("query not prepared")
        }
        
        sqlite3_finalize(statement)
        return result
    }
    
    func insert(query : String, values : [String]) {
        print("start insertion")
        var statement : OpaquePointer?
        if sqlite3_prepare_v2(self.db, query, -1, &statement, nil) == SQLITE_OK{
            for (index, value) in values.enumerated(){
                sqlite3_bind_text(statement, Int32(index + 1), NSString(string: value).utf8String, -1, nil)
            }
            
            if sqlite3_step(statement) == SQLITE_DONE{
                print("insert successfully")
            }
            else{
                print("insert failed")
            }
        }
        else{
            print("query not prepared")
        }
        
        sqlite3_finalize(statement)
    }
}
