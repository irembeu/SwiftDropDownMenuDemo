//
//  ViewController.swift
//  DropDownMenuTestDemo
//
//  Created by 劉光軍 on 2016/10/19.
//  Copyright © 2016年 海涛旅游. All rights reserved.
//

import UIKit

class ViewController: UIViewController,DOPDropDownMenuDataSource, DOPDropDownMenuDelegate {

//    var classifys: [String] = ["美食","电影","酒店"]
    let cates: [String] = ["自助餐","快餐","火锅","日韩料理","西餐","烧烤小吃"]
    let movices: [String] = ["内地剧","港台剧","英美剧"]
    let hotels: [String] = ["经济酒店","商务酒店","连锁酒店","度假酒店","公寓酒店"]
    let allSorts: [String] = ["全部分类","跟团游","自由行","极致日本","签证","当地玩乐"]
    let sorts = ["排序", "默认排序", "价格由低到高", "价格由高到低", "出发时间升序", "出发时间降序", "行程天数升序", "行程天数降序"]
    var sifts: [String] = ["出发地", "目的地", "线路玩法"]
    let imgArr: [String] = ["ic_filter_category_0", "ic_filter_category_1", "ic_filter_category_2", "ic_filter_category_3", "ic_filter_category_4", "ic_filter_category_5"]

    var dopMenu : DOPDropDownMenu = DOPDropDownMenu()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "DOPDropDownMenu测试"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "重新加载", style: .plain, target: self, action: #selector(menuReloadData))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "选择特定", style: .plain, target: self, action: #selector(selectIndexPathAction))
        
        dopMenu = DOPDropDownMenu(origin: CGPoint(x: 0, y: 64), height: 44)
        dopMenu.dataSource = self
        dopMenu.delegate = self
        self.view.addSubview(dopMenu)
        
        dopMenu.selectDefalutIndexPath()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK:- 代理
    func numberOfColumnsInMenu(dopMenu menu: DOPDropDownMenu) -> Int {
        return 3
    }
    
    func menu(dopMenu menu: DOPDropDownMenu, numberOfRowsInColumn column: Int) -> Int {
        if column == 0 {
            return allSorts.count
        } else if column == 1 {
            return sifts.count
        } else {
            return sorts.count
        }
    }
    
    func menu(dopMenu menu: DOPDropDownMenu, titleForRowAtIndexPath indexPath: DOPIndexPath) -> String {
        if indexPath.column == 0 {
            return allSorts[indexPath.row!]
        } else if indexPath.column == 1 {
            return sifts[indexPath.row!]
        } else {
            return sorts[indexPath.row!]
        }
    }
    
    //new datasource
    func menu(dopMenu menu: DOPDropDownMenu, imageNameForRowAtIndexPath indexPath: DOPIndexPath) -> String {
        if indexPath.column == 1 {
            if let num = indexPath.row {
                return "ic_filter_category_\(num)"
            }
            
        } else if indexPath.column == 0 {
            return imgArr[indexPath.row!]
        }
        return ""
    }
    
    func menu(dopMenu menu: DOPDropDownMenu, imageNameForItemsInRowAtIndexPath indexPath: DOPIndexPath) -> String {
        if indexPath.column == 0 {
            if let num = indexPath.row {
                return "ic_filter_category_\(num)"
            }
        }
        return ""
    }
    
    func menu(dopMenu menu: DOPDropDownMenu, detailTextForRowAtIndexPath indexPath: DOPIndexPath) -> String {
        return String()
    }
    
    func menu(dopMenu menu: DOPDropDownMenu, detailTextForItemsInRowAtIndexPath indexPath: DOPIndexPath) -> String {
        return String()
    }
    
    func menu(dopMenu menu: DOPDropDownMenu, numberOfItemsInRow row: Int, column: Int) -> Int {
        if column == 1 {
            if row == 0 {
                return cates.count
            } else if row == 1 {
                return movices.count
            } else if row == 2 {
                return hotels.count
            }
        }
        return 0
    }
    
    func menu(dopMenu menu: DOPDropDownMenu, titleForItemsInRowAtIndexPath indexPath: DOPIndexPath) -> String {
        if indexPath.column == 1 {
            if indexPath.row == 0 {
                return cates[indexPath.item!]
            } else if indexPath.row == 1 {
                return movices[indexPath.item!]
            } else if indexPath.row == 2 {
                return hotels[indexPath.item!]
            }
        }
        return "没有"
    }
    
    func menu(_ menu: DOPDropDownMenu, didSelectRowAtIndexPath indexPath: DOPIndexPath) {
        if indexPath.item! > 0 {
            print("点击了第\(indexPath.column)列 - 第\(indexPath.row)行 - 第\(indexPath.item)项")
        } else {
            print("点击了第\(indexPath.column)列 - 第\(indexPath.row)行")
        }
    }
    
    
    //MARK:- 点击事件响应方法
    
    func menuReloadData() -> Void {
        sifts = ["出发地", "目的地"]
        dopMenu.reloadData()
    }
    
    func selectIndexPathAction() -> Void {
        dopMenu.selectIndexPath(indexPath: DOPIndexPath.indexPathWith(col: 0, row: 2, item: 2))
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

