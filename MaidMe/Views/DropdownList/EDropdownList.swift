//
//  EDropdownList.swift
//  EDropdownList
//
//  Created by Lucy Nguyen on 11/10/15.
//  Copyright © 2015 econ. All rights reserved.
//
//  This class is used for creating custom dropdown list in iOS.

import UIKit

@objc protocol EdropdownListDelegate {
    func didSelectItem(selectedItem: String, index: Int)
    optional func didTouchDownDropdownList()
}

class EDropdownList: UIView {
    var dropdownButton: UIButton!
    var listTable: UITableView!
    var separatorLine: UIView!
    var arrowImage: UIImageView!
    var downArrow: String? {
        didSet {
            setArrow(downArrow)
        }
    }
    var upArrow: String?
    var superView: AnyObject?
    var valueList: [String]!
    var delegate: EdropdownListDelegate!
    var isShown: Bool = false
    var selectedValue: String!
    var arrowWidth: CGFloat = 16.0
    var arrowHeight: CGFloat = 8.0
    
    var maxHeight: CGFloat = 200.0
    var cellSelectedColor = UIColor.clearColor()
    var textColor = UIColor.blackColor()
    
    var bgColor = UIColor.whiteColor() {
        didSet {
            if (oldValue != bgColor) {
                dropdownButton.backgroundColor = UIColor.blackColor()
            }
        }
    }
    
    var buttonTextAlignment = UIControlContentHorizontalAlignment.Center {
        didSet {
            if (oldValue != buttonTextAlignment) {
                dropdownButton.contentHorizontalAlignment = buttonTextAlignment
            }
        }
    }
    
    var placeHolder: String = "Select" {
        didSet {
            dropdownButton.setTitle(cutString(placeHolder), forState: UIControlState.Normal)
        }
    }
    
    var buttonLeftInset: CGFloat = 0.0 {
        didSet {
            dropdownButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, buttonLeftInset, 0.0, 0.0)
        }
    }
    
    var defaultValue: String = "" {
        didSet {
            dropdownButton.setTitle(defaultValue, forState: UIControlState.Normal)
//            let selectedCellIndexPath = NSIndexPath(forItem: 0, inSection: 0)
//            self.tableView(listTable, didSelectRowAtIndexPath: selectedCellIndexPath)
        }
    }
    
    var fontSize: CGFloat = 16.0 {
        didSet {
            dropdownButton.titleLabel?.font = UIFont(name: CustomFont.quicksanRegular, size: fontSize)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTapGestureForView()
        initArrowImage()
        setupButton()
        setupListTable()
        setupSeparatorLine()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addTapGestureForView()
        initArrowImage()
        setupButton()
        setupListTable()
        setupSeparatorLine()
    }
    
    // MARK: - Create interface.
    
    func addTapGestureForView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(EDropdownList.showHideDropdownList(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    func setupButton() {
        dropdownButton = UIButton(type: UIButtonType.Custom)
        dropdownButton.backgroundColor = bgColor
        dropdownButton.contentHorizontalAlignment = buttonTextAlignment
        dropdownButton.frame = CGRectMake(0, 0, CGRectGetMinX(self.arrowImage.frame), CGRectGetHeight(self.frame))
        dropdownButton.setTitle(cutString(placeHolder), forState: UIControlState.Normal)
        dropdownButton.addTarget(self, action: #selector(EDropdownList.showHideDropdownList(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        dropdownButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, buttonLeftInset, 0.0, 0.0)
        dropdownButton.titleLabel?.font = UIFont(name: CustomFont.quicksanRegular, size: 16.0)
        self.addSubview(self.dropdownButton)
    }
    
    func initArrowImage() {
        arrowImage = UIImageView()
        arrowImage.frame = CGRectMake(CGRectGetWidth(self.frame) - arrowWidth * 2, (CGRectGetHeight(self.frame) - arrowHeight) / 2, arrowWidth, arrowHeight)
        
        // Add the arrow image at the end of the button.
        self.addSubview(arrowImage)
        
        setArrow(downArrow)
    }
    
    func setArrow(image: String?) {
        guard let arrow = image else {
            return
        }
        
        arrowImage.image = UIImage(named: arrow)
    }
    
    func setupListTable() {
        let yLocation = CGRectGetMinY(self.frame) + CGRectGetHeight(dropdownButton.frame)
        
        listTable = UITableView(frame: CGRectMake(CGRectGetMinX(self.frame), yLocation, CGRectGetWidth(self.frame), 0))
        listTable.dataSource = self
        listTable.delegate = self
        listTable.userInteractionEnabled = true
       
        // Disable scrolling the tableview after it reach the top or bottom.
        listTable.bounces = false
    }
    
    func setupSeparatorLine() {
        separatorLine = UIView(frame: CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(listTable.frame), CGRectGetWidth(self.frame), 0.5))
        separatorLine.backgroundColor = UIColor(red: 91.0 / 255.0, green: 194.0 / 255.0, blue: 209.0 / 255.0, alpha: 1)
    }
    
    func updateListTableFrame(yLocation: CGFloat, width: CGFloat) {
        var frame = listTable.frame
        frame.origin.y = yLocation
        frame.size.width = width
        listTable.frame = frame
        
        separatorLine.frame.origin.y = yLocation
        separatorLine.frame.size.width = width
        arrowImage.frame.origin.x = width - arrowWidth * 2
        dropdownButton.frame.size.width = CGRectGetMinX(self.arrowImage.frame)
    }
    
    // MARK: - User setting
    
    func dropdownColor(backgroundColor: UIColor?, selectedColor: UIColor?, textColor: UIColor?) {
        if let bgColor = backgroundColor {
            listTable.backgroundColor = bgColor
        }
        
        if let selectedColor = selectedColor {
            cellSelectedColor = selectedColor
        }
        
        if let textColor = textColor {
            self.textColor = textColor
        }
    }
    
    func dropdownColor(backgroundColor: UIColor, buttonColor: UIColor, selectedColor: UIColor, textColor: UIColor) {
        dropdownColor(backgroundColor, selectedColor: selectedColor, textColor: textColor)
        dropdownButton.backgroundColor = buttonColor
    }
    
    func dropdownColor(backgroundColor: UIColor, buttonBgColor: UIColor, buttonTextColor: UIColor, selectedColor: UIColor? = nil, textColor: UIColor? = nil) {
        dropdownColor(backgroundColor, selectedColor: selectedColor, textColor: textColor)
        dropdownButton.setTitleColor(buttonTextColor, forState: UIControlState.Normal)
        dropdownButton.backgroundColor = buttonBgColor
    }
    
    func setButtonTextColorAndFont(color: UIColor, font: UIFont) {
        dropdownButton.setTitleColor(color, forState: UIControlState.Normal)
        dropdownButton.titleLabel?.font = font
    }
    
    func dropdownMaxHeight(height: CGFloat) {
        maxHeight = height
    }
    func cutString(string: String) -> String{
        if string.characters.count > 15 {
            let subString = string[string.startIndex.advancedBy(0)...string.startIndex.advancedBy(15)]
            return subString + ".."
        } else {
            return string
        }
    }
    func disableSelecting(flag: Bool) {
        self.placeHolder = (flag ? "Not available" : "Select")
        self.userInteractionEnabled = !flag
        self.alpha = (flag ? 0.5 : 1.0)
    }
    
    // MARK: - Action
    
    func showHideDropdownList(sender: AnyObject) {
        if selectedValue != nil {
            dropdownButton.setTitle(cutString(selectedValue), forState: UIControlState.Normal)
        }
        
        hideDropdownList(isShown)
        delegate?.didTouchDownDropdownList?()
    }
    
    func hideDropdownList(isHidden: Bool) {
        if (isHidden && !isShown) || (!isHidden && isShown) {
            return
        }
        
        if !isHidden {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                if let superViewTarget = self.superView {
                    superViewTarget.addSubview(self.listTable)
                    superViewTarget.addSubview(self.separatorLine)
                }
                else {
                    self.superview?.addSubview(self.listTable)
                    self.superview?.addSubview(self.separatorLine)
                }
                
                var height = self.tableviewHeight()
                
                if height > self.maxHeight {
                    height = self.maxHeight
                }
                
                var frame = self.listTable.frame
                frame.size.height = CGFloat(height)
                
                self.listTable.frame = frame
                }, completion: { (animated) -> Void in
                    self.setArrow(self.upArrow)
            })
        }
        else {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                let height = 0
                var frame = self.listTable.frame
                frame.size.height = CGFloat(height)
                
                self.listTable.frame = frame
                }, completion: { (animated) -> Void in
                    self.listTable.removeFromSuperview()
                    self.separatorLine.removeFromSuperview()
                    self.setArrow(self.downArrow)
            })
        }
        
        isShown = !isShown
    }
    
    func reloadList(list: [String]) {
        valueList = list
        listTable.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension EDropdownList: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = valueList?.count
        
        if count > 0 {
            return count!
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        // Set selected background color.
        let colorView = UIView()
        colorView.backgroundColor = UIColor.whiteColor()
        cell.selectedBackgroundView = colorView
        let lineView = UIView()
        lineView.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: 0.5)
        lineView.backgroundColor = UIColor(red: 91.0 / 255.0, green: 194.0 / 255.0, blue: 209.0 / 255.0, alpha: 1)
        cell.addSubview(lineView)
        cell.textLabel?.font = UIFont(name: CustomFont.quicksanRegular,size: fontSize)
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = textColor
        cell.textLabel?.text = valueList?[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        
        if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    func tableviewHeight() -> CGFloat {
        listTable.layoutIfNeeded()
        return listTable.contentSize.height
    }
}

// MARK: - UITableViewDelegate
extension EDropdownList: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Get selected value.
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        selectedValue = selectedCell?.textLabel?.text
        
        // Hide the dropdown table and pass the selected value.
        showHideDropdownList(dropdownButton)
        delegate?.didSelectItem((selectedCell?.textLabel?.text)!, index: indexPath.row)
    }
}

