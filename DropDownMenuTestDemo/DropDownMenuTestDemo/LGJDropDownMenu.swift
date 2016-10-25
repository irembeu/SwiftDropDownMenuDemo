//
//  LGJDropDownMenu.swift
//  DropDownMenuTestDemo
//
//  Created by 劉光軍 on 2016/10/19.
//  Copyright © 2016年 海涛旅游. All rights reserved.
//

import UIKit


//MARK:- 全局变量
public let kTableViewCellHeight: Int = 43
public let kCollectionViewCellHeight: Int = 100
public let kCollectionViewHeight: Int = 220
public let kTableViewHeight: Int = 300
public let kButtomImageViewHeight: Int = 21

public let kTextColor: UIColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
public let kDetailTextColor: UIColor = UIColor(red: 136/255.0, green: 136/255.0, blue: 136/255.0, alpha: 1)
public let kSepatatorColor: UIColor = UIColor(red: 219/255.0, green: 219/255.0, blue: 219/255.0, alpha: 1)
public let kCellBgColor: UIColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
public let kTextSelectColor: UIColor = UIColor(red: 253/255.0, green: 191/255.0, blue: 44/255.0, alpha: 1)

//MARK:DOPDropDownMenuDataSource
@objc protocol DOPDropDownMenuDataSource : NSObjectProtocol {
    //返回 menu 第column列有多少行
    func menu(dopMenu menu: DOPDropDownMenu, numberOfRowsInColumn column: Int) -> Int
    
    //返回 menu 第column列 每行title
    func menu(dopMenu menu: DOPDropDownMenu, titleForRowAtIndexPath indexPath: DOPIndexPath) -> String
    
    //返回 menu 有多少列, 默认1列
    func numberOfColumnsInMenu(dopMenu menu: DOPDropDownMenu) -> Int
    
    //新增 返回 menu 第column列 每行image
    @objc optional func menu(dopMenu menu: DOPDropDownMenu, imageNameForRowAtIndexPath indexPath: DOPIndexPath) -> String
    
    //新增 detailText, right text
    @objc optional func menu(dopMenu menu: DOPDropDownMenu, detailTextForRowAtIndexPath indexPath: DOPIndexPath) -> String
    
    //新增 当有column列 row行 返回有多少个item, 如果>0, 说明有二级列表, =0 没有二级列表
    @objc optional func menu(dopMenu menu: DOPDropDownMenu, numberOfItemsInRow row:Int, column: Int) -> Int
    
    //新增 当有column列 row行 item项 title 如果都没有可以不实现该协议
    @objc optional func menu(dopMenu menu: DOPDropDownMenu, titleForItemsInRowAtIndexPath indexPath: DOPIndexPath) -> String
    
    //新增 当有column列 row行 item项 image
    @objc optional func menu(dopMenu menu: DOPDropDownMenu, imageNameForItemsInRowAtIndexPath indexPath: DOPIndexPath) -> String
    //新增 当有column列 row行 item项 title
    @objc optional func menu(dopMenu menu: DOPDropDownMenu, detailTextForItemsInRowAtIndexPath indexPath: DOPIndexPath) -> String
}
//MARK:-DOPDropDownMenuDelegate
@objc protocol DOPDropDownMenuDelegate : NSObjectProtocol {
    
    //点击代理, 点击了第column 第row 或者item项, 如果item >= 0
    @objc optional func menu(_ menu: DOPDropDownMenu, didSelectRowAtIndexPath indexPath: DOPIndexPath) -> Void
    //
    @objc optional func menu(_ menu: DOPDropDownMenu, willSelectRowAtIndexPath indexPath: DOPIndexPath) -> IndexPath
}

//MARK:DOPIndexPath
class DOPIndexPath: NSObject {
    var column:Int?
    var row:Int?
    var item:Int?
    
    init(dopColumn: Int, dopRow: Int) {
        column = dopColumn
        row = dopRow
        item = -1
    }
    
    convenience init(dopColumn: Int, dopRow: Int, dopItem: Int) {
        self.init(dopColumn: dopColumn, dopRow: dopRow)
        item = dopItem
    }
    
    static func indexPathWith(col: Int, row: Int) -> DOPIndexPath {
        let indexPath = DOPIndexPath.init(dopColumn: col, dopRow: row)
        return indexPath
    }
    
    static func indexPathWith(col: Int, row: Int, item: Int) -> DOPIndexPath {
        return DOPIndexPath(dopColumn: col, dopRow: row, dopItem: item)
    }
    
}

//MARK:DOPBackgroundCellView
class DOPBackgroundCellView:UIView {
    
    override func draw(_ rect: CGRect) {
        //Drawing code 
        let context: CGContext = UIGraphicsGetCurrentContext()!
        //画一条底部线
        context.setStrokeColor(red: 219.0/255, green: 224.0/255, blue: 228.0/255, alpha: 1);//线条颜色
        context.move(to: CGPoint(x: 0, y: 0))
        context.addLine(to: CGPoint(x: rect.size.width, y: 0))
        context.move(to: CGPoint(x: 0, y: rect.size.height))
        context.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height))
        context.strokePath()
    }
}

//MARK:DropDownMenu
struct dataSourceFlags {
    
    var numberOfRowsInColumn : Int = 1
    var numberOfItemsInRow : Int = 1
    var titleForRowAtIndexPath : Int = 1
    var titleForItemsInRowAtIndexPath : Int = 1
    var imageNameForRowAtIndexPath : Int = 1
    var imageNameForItemsInRowAtIndexPath : Int = 1
    var detailTextForRowAtIndexPath : Int = 1
    var detailTextForItemsInRowAtIndexPath : Int = 1
    
}

//MARK:DOPDropDownMenu
class DOPDropDownMenu: UIView, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var structDataSourceFlags = dataSourceFlags()
    weak var delegate: DOPDropDownMenuDelegate?
    
    var cellStyle: UITableViewCellStyle = .value1 //default value1
    var indicatorColor: UIColor = .black //指示器颜色
    var textColor: UIColor = .black //文字title颜色
    var textSelectedColor: UIColor = kTextSelectColor //文字title选中颜色
    var detailTextColor: UIColor = kDetailTextColor//detailText 文字颜色
    var detailTextFont: UIFont = UIFont.systemFont(ofSize: 11)//font
    var separatorColor: UIColor = kSepatatorColor //分割线颜色
    var fontSize: Int = 14 //字体大小
    var isClickHaveItemValid: Bool = true//当有二级列表item时, 点击row 是否调用点击代理方法
    var isRemainMenuTitle: Bool = true//切换条件时是否更改menu title
    var currentSelectRowArray:NSMutableArray = NSMutableArray() //恢复默认选项用
    
    fileprivate var currentSelectedMenudIndex: Int = -1 //当前选中列
    fileprivate var isShow: Bool = false
    fileprivate var numOfMenu: Int = 1
    fileprivate var origin: CGPoint?
    fileprivate var backGroundView: UIView = UIView()
    fileprivate var leftTableView: UITableView = UITableView() //一级列表
    fileprivate var rightTableView: UITableView = UITableView() //二级列表
    fileprivate var collectionView: UICollectionView?
    //第一个界面collectionView
    fileprivate var buttomImageView: UIImageView = UIImageView() //底部imageView
    fileprivate var bottomShadow: UIView = UIView() //底部阴影
    
    //data source
    fileprivate var array: [String] = [String]()
    //layers array
    fileprivate var titles: [CATextLayer] = [CATextLayer]()
    fileprivate var indicators: [CAShapeLayer] = [CAShapeLayer]()
    fileprivate var bgLayers: [UIView] = [UIView]()
    fileprivate var tableViewHieght: CGFloat = CGFloat(kTableViewHeight)//tableView高度
    //MARK:- init Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(origin: CGPoint, height: CGFloat) {
        
        let screenSize = UIScreen.main.bounds.size
        self.init(frame:CGRect(x: origin.x, y: origin.y, width: screenSize.width, height: height))
        self.origin = origin
        
        //collectionView init
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRect(x:origin.x, y:self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: 0), collectionViewLayout: layout)
        collectionView?.backgroundColor = .white
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.register(HomeCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.size.width-80)/3, height: CGFloat(100))
        
        
        //leftTableView init
        leftTableView = UITableView(frame: CGRect(x:origin.x, y:self.frame.origin.y + self.frame.size.height, width: self.frame.size.width / 2, height: 0), style: .plain)
        leftTableView.rowHeight = CGFloat(kTableViewCellHeight)
        leftTableView.dataSource = self
        leftTableView.delegate = self
        leftTableView.separatorColor = kSepatatorColor
        leftTableView.separatorInset = UIEdgeInsets.zero
        
        //rightTableView init
        rightTableView = UITableView(frame: CGRect(x:origin.x + self.frame.size.width/2, y:self.frame.origin.y + self.frame.size.height, width: self.frame.size.width / 2, height: 0), style: .plain)
        rightTableView.rowHeight = CGFloat(kTableViewCellHeight)
        rightTableView.dataSource = self
        rightTableView.delegate = self
        rightTableView.separatorColor = kSepatatorColor
        rightTableView.separatorInset = UIEdgeInsets.zero
        
        //buttomImageView
        buttomImageView = UIImageView(frame: CGRect(x: origin.x, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: CGFloat(kButtomImageViewHeight)))
        buttomImageView.image = UIImage(named: "icon_chose_bottom")
        
        //self tapped
        self.backgroundColor = UIColor.white
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(menuTapped(paramSender:)))
        self.addGestureRecognizer(tapGesture)
        
        //background init and tapped
        backGroundView = UIView(frame: CGRect(x: origin.x, y: origin.y, width: screenSize.width, height: screenSize.height))
        backGroundView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        backGroundView.isOpaque = false
        let gesture: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backGroundTapped(paramSender:)))
        backGroundView.addGestureRecognizer(gesture)
        
        //add bottom shadow
        let bottomShadow = UIView(frame: CGRect(x: 0, y: self.frame.size.height - 0.5, width: screenSize.width, height: 0.5))
        bottomShadow.backgroundColor = kSepatatorColor
        bottomShadow.isHidden = true
        self.addSubview(bottomShadow)
        self.bottomShadow = bottomShadow
    }
    

    weak var dataSource: DOPDropDownMenuDataSource? {
        
        didSet {
            if (self.dataSource?.responds(to: #selector(DOPDropDownMenuDataSource.menu(dopMenu:numberOfItemsInRow:column:))))! {
                numOfMenu = (self.dataSource?.numberOfColumnsInMenu(dopMenu: self))!
            } else {
                numOfMenu = 1
            }
            
            currentSelectRowArray = NSMutableArray(capacity: numOfMenu)
            
            for _ in 0..<numOfMenu {
                currentSelectRowArray.add(0)
            }
            
            structDataSourceFlags.numberOfRowsInColumn = (self.dataSource?.responds(to: #selector(DOPDropDownMenuDataSource.menu(dopMenu:numberOfRowsInColumn:))))! ? 1 : 0
            structDataSourceFlags.numberOfItemsInRow = (self.dataSource?.responds(to: #selector(DOPDropDownMenuDataSource.menu(dopMenu:numberOfItemsInRow:column:))))! ? 1 : 0
            structDataSourceFlags.titleForRowAtIndexPath = (self.dataSource?.responds(to: #selector(DOPDropDownMenuDataSource.menu(dopMenu:titleForRowAtIndexPath:))))! ? 1 : 0
            structDataSourceFlags.titleForItemsInRowAtIndexPath = (self.dataSource?.responds(to: #selector(DOPDropDownMenuDataSource.menu(dopMenu:titleForItemsInRowAtIndexPath:))))! ? 1 : 0
            structDataSourceFlags.imageNameForRowAtIndexPath = (self.dataSource?.responds(to: #selector(DOPDropDownMenuDataSource.menu(dopMenu:imageNameForRowAtIndexPath:))))! ? 1 : 0
            structDataSourceFlags.imageNameForItemsInRowAtIndexPath = (self.dataSource?.responds(to: #selector(DOPDropDownMenuDataSource.menu(dopMenu:imageNameForItemsInRowAtIndexPath:))))! ? 1 : 0
            structDataSourceFlags.detailTextForRowAtIndexPath = (self.dataSource?.responds(to: #selector(DOPDropDownMenuDataSource.menu(dopMenu:detailTextForRowAtIndexPath:))))! ? 1 : 0
            structDataSourceFlags.detailTextForItemsInRowAtIndexPath = (self.dataSource?.responds(to: #selector(DOPDropDownMenuDataSource.menu(dopMenu:detailTextForItemsInRowAtIndexPath:))))! ? 1 : 0
            
            bottomShadow.isHidden = false
            let textLayerInterval: CGFloat = self.frame.size.width / CGFloat(numOfMenu*2)
            let separatorLineInterval: CGFloat = self.frame.size.width / CGFloat(numOfMenu)
            let bgLayerInterval: CGFloat = self.frame.size.width / CGFloat(numOfMenu)
            
            let tempTitles = NSMutableArray.init(capacity: numOfMenu)
            let tempIndicators = NSMutableArray.init(capacity: numOfMenu)
            let tempBgLayers = NSMutableArray.init(capacity: numOfMenu)
            
            for i in 0..<numOfMenu {
                //bgLayer
                let bgLayerPosition = CGPoint(x: (CGFloat(i)+0.5)*bgLayerInterval, y: self.frame.size.height/2)
                let bglayer = self.createBgLayerWithColor(color: UIColor.white, andPosition: bgLayerPosition)
                self.layer.addSublayer(bglayer)
                tempBgLayers.add(bglayer)
                //title
                let titlePosition = CGPoint(x: (2 * CGFloat(i) + 1)*textLayerInterval, y: self.frame.size.height/2)
                
                var titleString:String
                if !self.isClickHaveItemValid && structDataSourceFlags.numberOfItemsInRow != 0 && (self.dataSource?.menu!(dopMenu: self, numberOfItemsInRow: 0, column: i))! > 0 {
                    titleString = (self.dataSource?.menu!(dopMenu: self, titleForItemsInRowAtIndexPath: DOPIndexPath.indexPathWith(col: i, row: 0, item: 0)))!
                } else {
                    titleString = (self.dataSource?.menu(dopMenu: self, titleForRowAtIndexPath: DOPIndexPath.indexPathWith(col: i, row: 0)))!
                }
                
                let title: CATextLayer = self.createTextLayerWithString(string: titleString, withColor: self.textColor, andPosition: titlePosition)
                self.layer.addSublayer(title)
                tempTitles.add(title)
                //indicator
                let indicator: CAShapeLayer = self.createIndicatorWithColor(color: self.indicatorColor, andPosition: CGPoint(x: (CGFloat(i) + 1) * separatorLineInterval - 10, y: self.frame.size.height / 2))
                self.layer.addSublayer(indicator)
                tempIndicators.add(indicator)
                
                //separator
                if i != numOfMenu - 1 {
                    let separatorPosition: CGPoint = CGPoint(x: CGFloat(ceilf(Float(CGFloat((i+1)*Int(separatorLineInterval)-1)))), y: self.frame.size.height/2)
                    let separator: CAShapeLayer = self.createSeparatorLineWithColor(color: self.separatorColor, andPosition: separatorPosition)
                    self.layer.addSublayer(separator)
                }
            }
            
            titles = tempTitles.copy() as! [CATextLayer]
            indicators = tempIndicators.copy() as! [CAShapeLayer]
            bgLayers = tempBgLayers.copy() as! [UIView]
        }
    }
    
    
    func titleForRowAtIndexPath(indexPath: DOPIndexPath) -> String {
        return (dataSource?.menu(dopMenu: self, titleForRowAtIndexPath: indexPath))!
    }
    
    func reloadData() -> Void {
        self.animateBackGroundView(view: backGroundView, show: false) {
            self.animateTableView(tableView: nil, show: false, complete: { 
                isShow = false
                let VC:UIViewController = self.dataSource as! UIViewController
                self.dataSource = nil
                self.dataSource = VC as? DOPDropDownMenuDataSource
            })
        }
    }
    
    func selectDefalutIndexPath() -> Void {
        self.selectIndexPath(indexPath: DOPIndexPath.indexPathWith(col: 1, row: 2))
    }

    func selectIndexPath(indexPath: DOPIndexPath, triggerDelegate trigger: Bool) -> Void {
        if dataSource == nil || delegate == nil || !(delegate?.responds(to: #selector(DOPDropDownMenuDelegate.menu(_:didSelectRowAtIndexPath:))))! {
            return
        }
        if ((dataSource?.numberOfColumnsInMenu(dopMenu: self))! <= indexPath.column! || (dataSource?.menu(dopMenu: self, numberOfRowsInColumn: indexPath.column!))! <= indexPath.row!) {
            return
        }
        let title: CATextLayer = titles[indexPath.column!]
        
        if indexPath.item! < 0 {
            if !isClickHaveItemValid && (dataSource?.menu!(dopMenu: self, numberOfItemsInRow: indexPath.row!, column: indexPath.column!))! > 0 {
                title.string = dataSource?.menu!(dopMenu: self, titleForItemsInRowAtIndexPath: DOPIndexPath.indexPathWith(col: indexPath.column!, row: !isRemainMenuTitle ? 0 : indexPath.row!, item: 0))
                if trigger {
                    delegate?.menu!(self, didSelectRowAtIndexPath: DOPIndexPath.indexPathWith(col: indexPath.column!, row: indexPath.row!, item: 0))
                }
            } else {
                title.string = dataSource?.menu(dopMenu: self, titleForRowAtIndexPath: DOPIndexPath.indexPathWith(col: indexPath.column!, row: !isRemainMenuTitle ? 0 : indexPath.row!))
                if trigger {
                    delegate?.menu!(self, didSelectRowAtIndexPath: indexPath)
                }
            }
            if currentSelectRowArray.count > indexPath.column! {
                currentSelectRowArray[indexPath.column!] = indexPath.row
            }
            let size: CGSize = self.calculateTitleSizeWithString(string: title.string as! String)
            let sizeWidth: CGFloat = (size.width < (self.frame.size.width / CGFloat(numOfMenu) - 25) ? size.width : self.frame.size.width / CGFloat(numOfMenu - 25))
            title.bounds = CGRect(x: 0, y: 0, width: sizeWidth, height: size.height)
        } else if ((dataSource?.menu!(dopMenu: self, numberOfItemsInRow: indexPath.row!, column: indexPath.column!))! > indexPath.column!) {
            title.string = dataSource?.menu!(dopMenu: self, titleForItemsInRowAtIndexPath: indexPath)
            if trigger {
                delegate?.menu!(self, didSelectRowAtIndexPath: indexPath)
            }
            if currentSelectRowArray.count > indexPath.column! {
                currentSelectRowArray[indexPath.column!] = indexPath.row
            }
            let size = self.calculateTitleSizeWithString(string: title.string as! String)
            let sizeWidth: CGFloat = (size.width < (self.frame.size.width / CGFloat(numOfMenu)) - 25) ? size.width : self.frame.size.width / CGFloat(numOfMenu - 25)
            title.bounds = CGRect(x: 0, y: 0, width: sizeWidth, height: size.height)
        }
    }
    
    func selectIndexPath(indexPath: DOPIndexPath) -> Void {
        self.selectIndexPath(indexPath: indexPath, triggerDelegate:true)
    }
    
    
    //MARK:- gesture handle
    @objc fileprivate func menuTapped(paramSender: UITapGestureRecognizer) -> Void {
        if dataSource == nil {
            return
        }
        let touchPoint = paramSender.location(in: self)
        //calculate index
        let tapIndex:Int = Int(touchPoint.x / (self.frame.size.width / CGFloat(numOfMenu)))
        
        for i in 0..<numOfMenu {
            if i != tapIndex {
                self.animateIndicator(indicator: indicators[i], forward: false, complete: { 
                    self.animateTitle(title: titles[i], show: false, complete: { 
                        
                    })
                })
            }
        }
     
        if tapIndex == 0 && isShow {
            if (self.superview?.subviews.contains(self.leftTableView))! || (self.superview?.subviews.contains(self.rightTableView))! {
                self.animateIdicator(indicator: indicators[currentSelectedMenudIndex], background: backGroundView, tableview: self.leftTableView, title: titles[currentSelectedMenudIndex], forward: false, complete: { 
                    isShow = false
                })
            } else {
                
            }
            self.animateCollectionIdicator(indicator: indicators[currentSelectedMenudIndex], background: backGroundView, collectionView: self.collectionView!, title: titles[currentSelectedMenudIndex], forward: false, complete: {
                currentSelectedMenudIndex = tapIndex
                isShow = false
            })
        } else if tapIndex == 0 && !isShow {
            currentSelectedMenudIndex = tapIndex
//            self.collectionView?.reloadData()
            self.animateCollectionIdicator(indicator: indicators[currentSelectedMenudIndex], background: backGroundView, collectionView: self.collectionView!, title: titles[currentSelectedMenudIndex], forward: true, complete: {
                currentSelectedMenudIndex = tapIndex
                isShow = true
            })
        }
        
        if isShow && tapIndex != 0{
            
            if (self.superview?.subviews.contains(self.collectionView!))! {
                self.animateCollectionIdicator(indicator: indicators[currentSelectedMenudIndex], background: backGroundView, collectionView: self.collectionView!, title: titles[currentSelectedMenudIndex], forward: false, complete: {
                    currentSelectedMenudIndex = tapIndex
                    isShow = false
                })
            } else {
                
            }
            self.animateIdicator(indicator: indicators[currentSelectedMenudIndex], background: backGroundView, tableview: self.leftTableView, title: titles[currentSelectedMenudIndex], forward: false, complete: {
                currentSelectedMenudIndex = tapIndex
                isShow = false
            })
        } else if tapIndex != 0 && !isShow{
            currentSelectedMenudIndex = tapIndex

                self.leftTableView.reloadData()
                if (dataSource != nil) && structDataSourceFlags.numberOfItemsInRow != 0 {
//                    self.rightTableView.reloadData()
                }
                self.animateIdicator(indicator: indicators[tapIndex], background: backGroundView, tableview: self.leftTableView, title: titles[tapIndex], forward: true, complete: {
                    isShow = true
                })
        }
 
    }
    
    @objc fileprivate func backGroundTapped(paramSender: UITapGestureRecognizer) -> Void {
        if (self.superview?.subviews.contains(collectionView!))! {
            self.animateCollectionIdicator(indicator: indicators[currentSelectedMenudIndex], background: backGroundView, collectionView: self.collectionView!, title: titles[currentSelectedMenudIndex], forward: false, complete: { 
                isShow = false
            })
        } else {
            self.animateIdicator(indicator: indicators[currentSelectedMenudIndex], background: backGroundView, tableview: self.leftTableView, title: titles[currentSelectedMenudIndex], forward: false) {
                isShow = false
            }
        }
    }
    
    
    //MARK:- init support
    fileprivate func createBgLayerWithColor(color: UIColor, andPosition position: CGPoint) -> CALayer {
        let layer = CALayer()
        layer.position = position
        layer.bounds = CGRect(x: 0, y: 0, width: self.frame.size.width / CGFloat(numOfMenu), height: self.frame.size.height - 1)
        layer.backgroundColor = color.cgColor
        return layer
    }
    
    
    fileprivate func createIndicatorWithColor(color: UIColor, andPosition point: CGPoint) -> CAShapeLayer {
        let layer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 8, y:0))
        path.addLine(to: CGPoint(x: 4, y: 5))
        path.close()
        
        layer.path = path.cgPath
        layer.lineWidth = 0.8
        layer.fillColor = color.cgColor

        let bound = layer.path?.copy(strokingWithWidth: layer.lineWidth, lineCap: CGLineCap.butt, lineJoin: CGLineJoin.miter, miterLimit: layer.miterLimit)
        layer.bounds = (bound?.boundingBoxOfPath)!
        layer.position = point
        
        return layer
    }
    
    fileprivate func createSeparatorLineWithColor(color: UIColor, andPosition point: CGPoint) -> CAShapeLayer {
        let layer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        path.move(to: CGPoint(x: 160, y: 0))
        path.addLine(to: CGPoint(x: 160, y: 20))
        
        layer.path = path.cgPath
        layer.lineWidth = 1
        layer.strokeColor = color.cgColor
        

        let bound = layer.path?.copy(strokingWithWidth: layer.lineWidth, lineCap: CGLineCap.butt, lineJoin: CGLineJoin.miter, miterLimit: layer.miterLimit)

        layer.bounds = (bound?.boundingBoxOfPath)!
        layer.position = point
        return layer
        
    }
    
    
    fileprivate func createTextLayerWithString(string: String, withColor color: UIColor, andPosition point: CGPoint) -> CATextLayer {
        let size:CGSize = self.calculateTitleSizeWithString(string: string)
        let layer: CATextLayer = CATextLayer()
        let sizeWidth: CGFloat = (size.width < (self.frame.size.width / CGFloat(numOfMenu)) - 25) ? size.width : self.frame.size.width / CGFloat(numOfMenu) - 25
        layer.bounds = CGRect(x: 0, y: 0, width: sizeWidth, height: size.height)
        layer.string = string
        layer.fontSize = CGFloat(fontSize)
        layer.alignmentMode = kCAAlignmentCenter
        layer.truncationMode = kCATruncationEnd
        layer.foregroundColor = color.cgColor
        layer.contentsScale = UIScreen.main.scale
        layer.position = point
        return layer
        
    }
    
    //根据文字计算labelSize
    fileprivate func calculateTitleSizeWithString(string: String) -> CGSize {
        let dic = [NSFontAttributeName:UIFont.systemFont(ofSize: CGFloat(fontSize))]
        let size: CGSize = string.boundingRect(with: CGSize(width: 280, height: 0), options:NSStringDrawingOptions.usesLineFragmentOrigin, attributes: dic, context: nil).size
        return CGSize(width: CGFloat(ceilf(Float(size.width)) + 2), height: size.height)
    }
    
    //MARK:- animation method 
    fileprivate func animateIndicator(indicator: CAShapeLayer, forward:Bool, complete:()->()) -> Void {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.25)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0))
        let anim :CAKeyframeAnimation = CAKeyframeAnimation.init(keyPath: "transform.rotation")
        anim.values = forward ? [0, M_PI] : [M_PI, 0]
        
        if !anim.isRemovedOnCompletion {
            indicator.add(anim, forKey: anim.keyPath)
        } else {
            indicator.add(anim, forKey: anim.keyPath)
            indicator.setValue(anim.values?.last, forKey: anim.keyPath!)
        }
        
        CATransaction.commit()
        
        if forward {
            //展开
            indicator.fillColor = textSelectedColor.cgColor
        } else {
            //收缩
            indicator.fillColor = textColor.cgColor
        }
        complete()
    }
    
    fileprivate func animateBackGroundView(view: UIView, show: Bool, complete:()->()) -> Void {
        
        if show {
            self.superview?.addSubview(view)
            view.superview?.addSubview(self)
            UIView.animate(withDuration: 0.2, animations: { 
                view.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: { 
                view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
                }, completion: { (finished:Bool) in
                    view.removeFromSuperview()
            })
        }
        complete()
    }
    
    fileprivate func animateCollectionView(collectionView: UICollectionView, show: Bool, complete:()->()) -> Void {
        
        if show {
            self.collectionView?.frame = CGRect(x: (self.origin?.x)!, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: 0)
            self.superview?.addSubview(self.collectionView!)
            buttomImageView.frame = CGRect(x: (self.origin?.x)!, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: CGFloat(kButtomImageViewHeight))
            self.superview?.addSubview(buttomImageView)
            
            UIView.animate(withDuration: 0.2) {
                self.collectionView?.frame = CGRect(x: (self.origin?.x)!, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: CGFloat(kCollectionViewHeight))
            }
            self.buttomImageView.frame = CGRect(x: (self.origin?.x)!, y: (self.collectionView?.frame.maxY)!-2, width: self.frame.size.width, height: CGFloat(kButtomImageViewHeight))
        } else {
            UIView.animate(withDuration: 0.2, animations: { 
                self.collectionView?.frame = CGRect(x: (self.origin?.x)!, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: 0)
                self.buttomImageView.frame = CGRect(x: (self.origin?.x)!, y: ((self.collectionView?.frame)?.maxY)!-2, width: self.frame.size.width, height: CGFloat(kButtomImageViewHeight))
                }, completion: { (finished) in
                    self.collectionView?.removeFromSuperview()
                    self.buttomImageView.removeFromSuperview()
            })
        }
        complete()
        
        }
    
    fileprivate func animateTableView(tableView: UITableView?, show: Bool, complete:()->()) -> Void {
        var isHaveItems = false
        if (dataSource != nil) {
            let num: Int = leftTableView.numberOfRows(inSection: 0)
            for i in 0..<num {

                if (dataSource?.menu!(dopMenu: self, numberOfItemsInRow: i, column: currentSelectedMenudIndex
                    ))!  > 0 && structDataSourceFlags.numberOfItemsInRow != 0  {
                    isHaveItems = true
                    break
                }
            }
        }
        if show {
            if isHaveItems {
                leftTableView.frame = CGRect(x: (self.origin?.x)!
                    , y: self.frame.origin.y + self.frame.size.height, width: frame.size.width/2, height: 0)
                rightTableView.frame = CGRect(x: (self.origin?.x)! + self.frame.size.width/2, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width/2, height:0)
                self.superview?.addSubview(leftTableView)
                self.superview?.addSubview(rightTableView)
            } else {
                leftTableView.frame = CGRect(x: (self.origin?.x)!, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: 0)
                rightTableView.frame = CGRect(x: (self.origin?.x)! + self.frame.size.width/2, y: self.frame.origin.y+self.frame.size.height, width: self.frame.size.width/2, height: 0)
                self.superview?.addSubview(leftTableView)
            }
            buttomImageView.frame = CGRect(x: (self.origin?.x)!, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: CGFloat(kButtomImageViewHeight))
            self.superview?.addSubview(buttomImageView)
            
            let num: Int = leftTableView.numberOfRows(inSection: 0)
            let tableViewHeight = CGFloat(num * kTableViewCellHeight) > CGFloat(tableViewHieght + 1) ? tableViewHieght : CGFloat(num * kTableViewCellHeight + 1)
            
            UIView.animate(withDuration: 0.2, animations: { 
                if isHaveItems {
                    self.leftTableView.frame = CGRect(x: (self.origin?.x)!, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width/2, height: tableViewHeight)
                    self.rightTableView.frame = CGRect(x: (self.origin?.x)! + self.frame.size.width/2, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width/2, height: tableViewHeight)
                } else {
                    self.leftTableView.frame = CGRect(x: (self.origin?.x)!, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: tableViewHeight)
                }
                self.buttomImageView.frame = CGRect(x: (self.origin?.x)!, y: (self.leftTableView.frame.maxY)-2, width: self.frame.size.width, height: CGFloat(kButtomImageViewHeight))
            })
            
        } else {
            UIView.animate(withDuration: 0.2, animations: { 
                if isHaveItems {
                    self.leftTableView.frame = CGRect(x: (self.origin?.x)!, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width/2, height: 0)
                    self.rightTableView.frame = CGRect(x: (self.origin?.x)! + self.frame.size.width/2, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width/2, height: 0)
                } else {
                    self.leftTableView.frame = CGRect(x: (self.origin?.x)!, y: self.frame.origin.y + self.frame.size.height, width: self.frame.size.width, height: 0)
                }
                self.buttomImageView.frame = CGRect(x: (self.origin?.x)!, y: ((self.leftTableView.frame).maxY)-2, width: self.frame.size.width, height: CGFloat(kButtomImageViewHeight))
                }, completion: { (finished) in
                    if ((self.rightTableView.superview) != nil) {
                        self.rightTableView.removeFromSuperview()
                    }
                    self.leftTableView.removeFromSuperview()
                    self.buttomImageView.removeFromSuperview()
            })
        }
        
        complete()
    }
    
    fileprivate func animateTitle(title: CATextLayer, show: Bool, complete: ()->()) -> Void {
        let size:CGSize = self.calculateTitleSizeWithString(string: title.string as! String)
        let sizeWidth = size.width < (self.frame.size.width / CGFloat(numOfMenu) - 25) ? size.width : self.frame.size.width / CGFloat(numOfMenu) - 25
        title.bounds = CGRect(x: 0, y: 0, width: sizeWidth, height: size.height)
        if !show {
            title.foregroundColor = textColor.cgColor
        } else {
            title.foregroundColor = textSelectedColor.cgColor
        }
        complete()
    }
    
    fileprivate func animateIdicator(indicator: CAShapeLayer, background:UIView, tableview: UITableView, title: CATextLayer, forward: Bool, complete:()->()) -> Void {
        self.animateIndicator(indicator: indicator, forward: forward) { 
            self.animateTitle(title: title, show: forward, complete: { 
                self.animateBackGroundView(view: background, show: forward, complete: { 
                    self.animateTableView(tableView: tableview, show: forward, complete: { 
                        
                    })
                })
            })
        }
        complete()
    }
    
    fileprivate func animateCollectionIdicator(indicator: CAShapeLayer, background:UIView, collectionView: UICollectionView, title: CATextLayer, forward: Bool, complete:()->()) -> Void {
        self.animateIndicator(indicator: indicator, forward: forward) {
            self.animateTitle(title: title, show: forward, complete: {
                self.animateBackGroundView(view: background, show: forward, complete: {
                    self.animateCollectionView(collectionView: collectionView, show: forward, complete: { 
                        
                    })
                })
            })
        }
        complete()
    }
    
    //MARK:- collectionViewDelegate
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if structDataSourceFlags.numberOfRowsInColumn != 0 {
            return ((self.dataSource?.menu(dopMenu: self, numberOfRowsInColumn: self.currentSelectedMenudIndex)))!
        } else  {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HomeCell
        let bg = DOPBackgroundCellView()
        bg.backgroundColor = .white
        cell.selectedBackgroundView = bg
        cell.titleLabel?.highlightedTextColor = textSelectedColor
        cell.titleLabel?.textColor = textColor
        cell.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        
        if structDataSourceFlags.titleForRowAtIndexPath != 0 {
            cell.titleLabel?.text =  dataSource?.menu(dopMenu: self, titleForRowAtIndexPath: DOPIndexPath.indexPathWith(col: currentSelectedMenudIndex, row: indexPath.row))
            if structDataSourceFlags.imageNameForRowAtIndexPath != 0 {
                let imageName: String = (dataSource?.menu!(dopMenu:self, imageNameForRowAtIndexPath: DOPIndexPath.indexPathWith(col: currentSelectedMenudIndex, row: indexPath.row)))!
                if !imageName.isEmpty {
                    cell.imgView?.image = UIImage(named: imageName)
                } else {
                    cell.imgView?.image = nil
                }
            } else {
                
            }
            let  currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex] as! Int
            if indexPath.row == currentSelectedMenudRow {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .top)
            }
            cell.backgroundColor = kCellBgColor
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.currentSelectRowArray[currentSelectedMenudIndex] = indexPath.row
        let title: CATextLayer = titles[currentSelectedMenudIndex]
        title.string = self.dataSource?.menu(dopMenu: self, titleForRowAtIndexPath: DOPIndexPath.indexPathWith(col: currentSelectedMenudIndex, row: !isRemainMenuTitle ? 0 : indexPath.row))
        animateCollectionIdicator(indicator: indicators[currentSelectedMenudIndex], background: backGroundView, collectionView: self.collectionView!, title: titles[currentSelectedMenudIndex], forward: false) {
            isShow = false
        }
        if self.delegate != nil && (self.delegate?.responds(to: #selector(DOPDropDownMenuDelegate.menu(_:didSelectRowAtIndexPath:))))! {
            self.delegate?.menu!(self, didSelectRowAtIndexPath: DOPIndexPath.indexPathWith(col: currentSelectedMenudIndex, row: indexPath.row))
        } else {
            
        }
    }
    
    //MARK:- tableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.leftTableView == tableView {
            if structDataSourceFlags.numberOfRowsInColumn != 0 {
                return ((self.dataSource?.menu(dopMenu: self, numberOfRowsInColumn: self.currentSelectedMenudIndex)))!
            } else {
                return 0
            }
        } else {
            if structDataSourceFlags.numberOfItemsInRow != 0 {
                let currentSelectedMenudRow: Int = (currentSelectRowArray[currentSelectedMenudIndex] as! Int)
                return (self.dataSource?.menu!(dopMenu: self, numberOfItemsInRow: currentSelectedMenudRow, column: currentSelectedMenudIndex))!
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "DropDownMenuCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: cellStyle, reuseIdentifier: identifier) as UITableViewCell
            let bg = DOPBackgroundCellView()
            bg.backgroundColor = .white
            cell?.selectedBackgroundView = bg
            cell?.textLabel?.highlightedTextColor = textSelectedColor
            cell?.textLabel?.textColor = textColor
            cell?.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
            if structDataSourceFlags.detailTextForRowAtIndexPath != 0 || structDataSourceFlags.detailTextForItemsInRowAtIndexPath != 0 {
                cell?.detailTextLabel?.textColor = detailTextColor
                cell?.detailTextLabel?.font = detailTextFont
            }
        }
        
        if tableView == self.leftTableView {
            if structDataSourceFlags.titleForRowAtIndexPath != 0{
                cell?.textLabel?.text = dataSource?.menu(dopMenu: self, titleForRowAtIndexPath: DOPIndexPath.indexPathWith(col: currentSelectedMenudIndex, row: indexPath.row))
                if structDataSourceFlags.imageNameForRowAtIndexPath != 0{
                    let imageName: String = (dataSource?.menu!(dopMenu: self, imageNameForRowAtIndexPath: DOPIndexPath.indexPathWith(col: currentSelectedMenudIndex, row: indexPath.row)))!
                    if !imageName.isEmpty {
                        cell?.imageView?.image = UIImage(named: imageName)
                    } else {
                        cell?.imageView?.image = nil
                    }
                } else {
                    cell?.imageView?.image = nil
                }
                if structDataSourceFlags.detailTextForItemsInRowAtIndexPath != 0 {
                    let detailText = dataSource?.menu!(dopMenu: self, detailTextForRowAtIndexPath: DOPIndexPath.indexPathWith(col: currentSelectedMenudIndex, row: indexPath.row))
                    cell?.detailTextLabel?.text = detailText
                } else {
                    cell?.detailTextLabel?.text = nil
                }
            } else {
                
            }
            let currentSelectedMenudRow = currentSelectRowArray[currentSelectedMenudIndex] as! Int
            if indexPath.row == currentSelectedMenudRow {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            }
            if structDataSourceFlags.numberOfItemsInRow != 0 && (dataSource?.menu!(dopMenu: self, numberOfItemsInRow: indexPath.row, column: self.currentSelectedMenudIndex))! > 0 {
                cell?.accessoryView = nil
            } else {
                cell?.accessoryView = UIImageView(image: UIImage(named:"icon_chose_arrow_nor"), highlightedImage: UIImage(named:"icon_chose_arrow_sel"))
            }
            cell?.backgroundColor = kCellBgColor
        } else {
            if structDataSourceFlags.detailTextForItemsInRowAtIndexPath != 0 {
                let currentSelectedMenudRow: Int = self.currentSelectRowArray[self.currentSelectedMenudIndex] as! Int
                cell?.textLabel?.text = self.dataSource?.menu!(dopMenu: self, titleForItemsInRowAtIndexPath: DOPIndexPath.indexPathWith(col: self.currentSelectedMenudIndex, row: currentSelectedMenudRow, item: indexPath.row))
                if structDataSourceFlags.imageNameForItemsInRowAtIndexPath != 0 {
                    let imageName: String = (self.dataSource?.menu!(dopMenu: self, imageNameForItemsInRowAtIndexPath: DOPIndexPath.indexPathWith(col: self.currentSelectedMenudIndex, row: currentSelectedMenudRow, item: indexPath.row)))!
                    if !imageName.isEmpty {
                        cell?.imageView?.image = UIImage(named: imageName)
                    } else {
                        cell?.imageView?.image = nil
                    }
                } else {
                    cell?.imageView?.image = nil
                }
                if structDataSourceFlags.detailTextForItemsInRowAtIndexPath != 0 {
                    let detailText: String = (self.dataSource?.menu!(dopMenu: self, detailTextForItemsInRowAtIndexPath: DOPIndexPath.indexPathWith(col: self.currentSelectedMenudIndex, row: currentSelectedMenudRow, item: indexPath.row)))!
                    cell?.detailTextLabel?.text = detailText
                } else {
                    cell?.detailTextLabel?.text = nil
                }
            } else {
                
            }
            
            if cell?.textLabel?.text == String(describing: self.titles[self.currentSelectedMenudIndex]) {
                let currentSelectedMenudRow: Int = self.currentSelectRowArray[currentSelectedMenudIndex] as! Int
                self.leftTableView.selectRow(at: NSIndexPath.init(row: currentSelectedMenudRow, section: 0) as IndexPath, animated: true, scrollPosition: .middle)
                self.rightTableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            }
            
            
            cell?.backgroundColor = .white
            cell?.accessoryView = UIImageView(image: UIImage(named:"icon_chose_arrow_nor"), highlightedImage: UIImage(named:"icon_chose_arrow_sel"))
        }
        return cell!
    }
    
    //MARK:- tableViewDelegate
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if self.delegate != nil && (self.delegate?.responds(to: #selector(DOPDropDownMenuDelegate.menu(_:willSelectRowAtIndexPath:))))! {
            return self.delegate?.menu!(self, willSelectRowAtIndexPath: DOPIndexPath.indexPathWith(col: currentSelectedMenudIndex, row: indexPath.row))
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.leftTableView == tableView {
            let isHaveItem: Bool = self.configMenuWithSelectRow(row: indexPath.row)
            
            let isClickHaveItemValid = self.isClickHaveItemValid ? true : isHaveItem
            
            if isClickHaveItemValid && self.delegate != nil && (self.delegate?.responds(to: #selector(DOPDropDownMenuDelegate.menu(_:didSelectRowAtIndexPath:))))! {
                self.delegate?.menu!(self, didSelectRowAtIndexPath: DOPIndexPath.indexPathWith(col: currentSelectedMenudIndex, row: indexPath.row))
            } else {
                
            }
        } else {
            self.configMenuWithSelectItem(item: indexPath.item)
            if self.delegate != nil && (self.delegate?.responds(to: (#selector(DOPDropDownMenuDelegate.menu(_:didSelectRowAtIndexPath:)))))! {
                let currentSelectedMenudRow: Int = currentSelectRowArray[currentSelectedMenudIndex] as! Int
                self.delegate?.menu!(self, didSelectRowAtIndexPath: DOPIndexPath.indexPathWith(col: currentSelectedMenudIndex, row: currentSelectedMenudRow, item: indexPath.row))
            } else {
                
            }
        }
    }
    
    fileprivate func configMenuWithSelectRow(row: Int) -> Bool {
        self.currentSelectRowArray[currentSelectedMenudIndex] = row
        let title: CATextLayer = titles[currentSelectedMenudIndex]
        if structDataSourceFlags.numberOfItemsInRow != 0 && (self.dataSource?.menu!(dopMenu: self, numberOfItemsInRow: row, column:currentSelectedMenudIndex))! > 0 {
            //有双列表 有item数据
            if isClickHaveItemValid {
                title.string = self.dataSource?.menu(dopMenu: self, titleForRowAtIndexPath: DOPIndexPath.indexPathWith(col:currentSelectedMenudIndex, row: row))
                self.animateTitle(title: title, show: true, complete: { 
                    rightTableView.reloadData()
                })
            } else {
                    rightTableView.reloadData()
            }
            return false
        } else {
            title.string = self.dataSource?.menu(dopMenu: self, titleForRowAtIndexPath: DOPIndexPath.indexPathWith(col: currentSelectedMenudIndex, row: !isRemainMenuTitle ? 0 : row))
            animateIdicator(indicator: indicators[currentSelectedMenudIndex], background: backGroundView, tableview: leftTableView, title: titles[currentSelectedMenudIndex], forward: false, complete: {
                isShow = false
            })
            return true
        }
    }
    
    fileprivate func configMenuWithSelectItem(item: Int) -> Void {
        let title: CATextLayer = titles[currentSelectedMenudIndex]
        let currentSelectedMenudRow: Int = currentSelectRowArray[currentSelectedMenudIndex] as! Int
        title.string = dataSource?.menu!(dopMenu: self, titleForItemsInRowAtIndexPath: DOPIndexPath.indexPathWith(col: currentSelectedMenudIndex, row: currentSelectedMenudRow, item: item))
        self.animateIdicator(indicator: indicators[currentSelectedMenudIndex], background: backGroundView, tableview:
        leftTableView, title: titles[currentSelectedMenudIndex], forward: false) {
            isShow = false
        }
    }
    
}
//MARK:HomeCell -- CollectionViewCell
class HomeCell: UICollectionViewCell {
    
    let width = UIScreen.main.bounds.size.width//获取屏幕宽
    var imgView : UIImageView?//cell上的图片
    var titleLabel:UILabel?//cell上title
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgView = UIImageView(frame: CGRect(x:0, y:0, width:(width-80)/3, height:70))
        self .addSubview(imgView!)
        titleLabel = UILabel(frame: CGRect(x:0, y:imgView!.frame.maxY+5, width:(width-80)/3, height:20))
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
        self .addSubview(titleLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
