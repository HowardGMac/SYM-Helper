//
//  SettingsVC.swift
//  SYM-Helper
//

import Cocoa
import Foundation

class SYMSetting: NSObject {
    @objc var name: String
    @objc var tab: String
    
    init(name: String, tab: String) {
        self.name = name
        self.tab  = tab
    }
}

class SettingsVC: NSViewController, NSTextFieldDelegate, NSTextViewDelegate, SendingKbInfoDelegate {
    
    func sendKbInfo(KbInfo: (String, String)) {
        let (whichField, details) = KbInfo
        switch whichField {
        case "errorKb":
            errorKb_TextField.stringValue = details
            errorKb_Button.toolTip = details
        default:
            helpWebsite_TextField.stringValue = details
            helpHyperlink_Button.toolTip = details
        }
        print("[sendKbInfo] KbInfo: \(KbInfo)")
        cancel_Button.isEnabled = true
        ok_Button.isEnabled     = true
    }
    
    var whichTab = ""
    
    @IBOutlet weak var scriptSource_TextField: NSTextField!
    
    // branding
    @IBOutlet weak var bannerImage_TextField: NSTextField!
    @IBOutlet weak var displayText_Switch: NSSwitch!
    @IBOutlet weak var lightIcon_TextField: NSTextField!
    @IBOutlet weak var darkIcon_TextField: NSTextField!
    
    // support
    @IBOutlet weak var teamName_TextField: NSTextField!
    @IBOutlet weak var teamPhone_TextField: NSTextField!
    @IBOutlet weak var teamEmail_TextField: NSTextField!
    @IBOutlet weak var kb_TextField: NSTextField!
    @IBOutlet weak var errorKb_TextField: NSTextField!
    @IBOutlet weak var helpWebsite_Label: NSTextField!
    @IBOutlet weak var helpWebsite_TextField: NSTextField!
    
    @IBOutlet weak var errorKb_Button: NSButton!
    @IBOutlet weak var helpHyperlink_Button: NSButton!
    @IBAction func kbDetails_Action(_ sender: NSButton) {
        
        let details = ( (sender.identifier?.rawValue ?? "unknown") == "errorKb" ? errorKb_TextField.stringValue:helpWebsite_TextField.stringValue )
        
        performSegue(withIdentifier: "KbPopover", sender: ["whichField": sender.identifier?.rawValue ?? "unknown", "details": details])
    }
    
    // prompt for
    @IBOutlet weak var pfu_Switch: NSSwitch!
    @IBOutlet weak var pu_Switch: NSSwitch!
    @IBOutlet weak var pfrn_Switch: NSSwitch!
    @IBOutlet weak var prn_Switch: NSSwitch!
    @IBOutlet weak var pfe_Switch: NSSwitch!
    @IBOutlet weak var pfcn_Switch: NSSwitch!
    @IBOutlet weak var pfat_Switch: NSSwitch!
    @IBOutlet weak var pfr_Switch: NSSwitch!
    @IBOutlet weak var pfb_Switch: NSSwitch!
    @IBOutlet weak var pfd_Switch: NSSwitch!
    @IBOutlet weak var pfc_Switch: NSSwitch!
    @IBOutlet weak var mip_Switch: NSSwitch!
    
    @IBOutlet var buildings_TextField: NSTextView!
    @IBOutlet var departments_TextField: NSTextView!
    
    @IBAction func fetch_Action(_ sender: NSButton) {
        spinner_Progress.startAnimation(self)
        sender.isEnabled = false
        let theRow = settings_TableView.selectedRow
        whichTab = settingsArray[theRow].tab
        ClassicAPI().getAll(endpoint: whichTab) { [self]
            (result: [String:Any]) in
            var allObjects = [String]()
            if let allObjectsDict = result[whichTab] as? [[String:Any]] {
                //                        print("all policies: \(allPolicies)")
                for object in allObjectsDict {
                    let objectName = object["name"] as? String ?? ""
                    if objectName != "" {
                        allObjects.append(objectName)
                    }
                }
                switch whichTab {
                case "buildings":
                    buildings_TextField.string = arrayToList(theArray: allObjects)
                    Settings.shared.dict["buildingsListRaw"] = buildings_TextField.string
                default:
                    departments_TextField.string = arrayToList(theArray: allObjects)
                    Settings.shared.dict["departmentListRaw"] = departments_TextField.string
                }
            } else {
                _ = Alert().display(header: "", message: "Unable to fetch \(whichTab), verify the account has permissions to read \(whichTab)", secondButton: "")
            }
            
            sender.isEnabled = true
            spinner_Progress.stopAnimation(self)
        }
    }
    private func arrayToList(theArray: [String]) -> String {
        var theString = ""
        for object in theArray.sorted() {
            theString = "\(theString)\(object)\n"
        }
        if theString.last == "\n" {
            theString = String(theString.dropLast(1))
        }
        return theString
    }
    
    @IBOutlet weak var cancel_Button: NSButton!
    @IBOutlet weak var ok_Button: NSButton!
    @IBOutlet weak var spinner_Progress: NSProgressIndicator!
    
    @IBOutlet weak var settings_TableView: NSTableView!
    @IBOutlet var settings_AC: NSArrayController!
    @IBOutlet weak var settings_TabView: NSTabView!
    
    var settingsArray = [SYMSetting(name: "Script Source", tab: "scriptSource"),
                         SYMSetting(name: "Branding", tab: "branding"),
                         SYMSetting(name: "Support", tab: "support"),
                         SYMSetting(name: "Prompt For...", tab: "promptFor"),
                         SYMSetting(name: "Buildings", tab: "buildings"),
                         SYMSetting(name: "Departments", tab: "departments")]
    
//    var settingsDict      = [String:Any]()
    
    var currentConfig     = ""
    var validScriptSource = ""
    var promptForDict     = [String:Any]()
    var brandingDict      = [String:Any]()
    var supportDict       = [String:Any]()
    
//    @IBAction func prompt_Action(_ sender: NSButton) {
//        guard let theIdentifier = sender.identifier?.rawValue else {
//            WriteToLog().message(stringOfText: "Unknown prompt/prefill value")
//            return
//        }
//        Settings.shared.dict[theIdentifier] = sender.title
//    }
    @IBAction func switchPrompt_Action(_ sender: NSSwitch) {
//        guard let theIdentifier = sender.identifier?.rawValue else {
//            WriteToLog().message(stringOfText: "Unknown prompt/prefill value")
//            return
//        }
//        Settings.shared.dict[theIdentifier] = sender.state.rawValue
    }
    
    
    @IBAction func resetToDefault(_ sender: Any) {
        scriptSource_TextField.stringValue = defaultScriptSource
    }
    
    @IBAction func cancel_Button(_ sender: Any) {
        dismiss(self)
    }
    
    @IBAction func ok_Button(_ sender: Any) {
        spinner_Progress.startAnimation(self)
        ok_Button.isEnabled = false
        cancel_Button.isEnabled = false
        
//        let theRow = settings_TableView.selectedRow
//        whichTab = settingsArray[theRow].tab
//        let theNotification = Notification(name: Notification.Name(rawValue: "\(whichTab)"), object: NSButton.self)
//        controlTextDidEndEditing(theNotification)
        
        // set branding
        brandingDict["bannerImage"] = bannerImage_TextField.stringValue as Any
        brandingDict["displayText"] = displayText_Switch.state.rawValue as Any
        brandingDict["lightIcon"]   = lightIcon_TextField.stringValue as Any
        brandingDict["darkIcon"]    = darkIcon_TextField.stringValue as Any

        // set support
        supportDict["teamName"]  = teamName_TextField.stringValue as Any
        supportDict["teamPhone"] = teamPhone_TextField.stringValue as Any
        supportDict["teamEmail"] = teamEmail_TextField.stringValue as Any
        supportDict["kb"]        = kb_TextField.stringValue as Any
        supportDict["errorKb"]   = errorKb_TextField.stringValue as Any
        if scriptVersion.0 <= 1 && scriptVersion.1 < 13 {
            supportDict["helpKb"]    = helpWebsite_TextField.stringValue as Any
        } else {
            supportDict["teamWebsite"] = helpWebsite_TextField.stringValue as Any
        }
        
        // set prompt for
        promptForDict["promptForUsername"]      = pfu_Switch.state.rawValue
        promptForDict["prefillUsername"]        = pu_Switch.state.rawValue
        promptForDict["promptForComputerName"]  = pfcn_Switch.state.rawValue
        promptForDict["promptForRealName"]      = pfrn_Switch.state.rawValue
        promptForDict["prefillRealname"]        = prn_Switch.state.rawValue
        promptForDict["promptForEmail"]         = pfe_Switch.state.rawValue
        promptForDict["promptForAssetTag"]      = pfat_Switch.state.rawValue
        promptForDict["promptForRoom"]          = pfr_Switch.state.rawValue
        promptForDict["promptForBuilding"]      = pfb_Switch.state.rawValue
        promptForDict["promptForDepartment"]    = pfd_Switch.state.rawValue
        promptForDict["promptForConfiguration"] = pfc_Switch.state.rawValue
        promptForDict["moveableInProduction"]   = mip_Switch.state.rawValue
        
        print("promptForDict: \(promptForDict)")
        // set buildings
        Settings.shared.dict["buildingsListRaw"] = buildings_TextField.string

        // set departments
        Settings.shared.dict["departmentListRaw"] = departments_TextField.string
        
        print("[viewWillDisappear] settingsDict: \(Settings.shared.dict)")
        print("[viewWillDisappear] set valid script to: \(validScriptSource)")
        
        Settings.shared.dict["scriptSource"] = validScriptSource
        Settings.shared.dict["branding"]     = brandingDict
        Settings.shared.dict["support"]      = supportDict
        Settings.shared.dict["promptFor"]    = promptForDict
        
        if validScriptSource != scriptSource_TextField.stringValue {
            validateScript(notificationName: "ok_Button")
        } else {
            ConfigsSettings().save(theServer: "\(JamfProServer.destination.fqdnFromUrl)", dataType: "settings", data: Settings.shared.dict)
            dismiss(self)
        }
    }

    //  remove?
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        switch keyPath {
        case "selectedObjects":
            if settings_TableView.selectedRowIndexes.count > 0 {
                let theRow = settings_TableView.selectedRow
                whichTab = settingsArray[theRow].tab
//                print("whichTab: \(whichTab)")
                settings_TabView.selectTabViewItem(withIdentifier: whichTab)
            }
        default:
            break
        }
    }
    
    fileprivate func validateScript(notificationName: String) {
        SYMScript().get(scriptURL: scriptSource_TextField.stringValue) { [self]
            (result: String) in
            symScript = result
            print("[Settings] getScript: \(symScript)")
            spinner_Progress.stopAnimation(self)
            if symScript == "" {
                let scriptReply = alert.display(header: "Attention:", message: "Set-Up-Your-Mac script was not found.  Verify the server URL listed in Settings.", secondButton: "Use Anyway")
                if scriptReply == "Use Anyway" {
                    validScriptSource = scriptSource_TextField.stringValue
                    Settings.shared.dict["scriptSource"] = validScriptSource
                    if notificationName != "NSControlTextDidEndEditingNotification" {
                        self.dismiss(self)
                    }
                } else {
                    ok_Button.isEnabled = true
                    cancel_Button.isEnabled = true
                    scriptSource_TextField.stringValue = validScriptSource
                    settings_TableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
                    settings_TabView.selectTabViewItem(withIdentifier: "scriptSource")
                    return
                }
            } else {
                validScriptSource = scriptSource_TextField.stringValue
                Settings.shared.dict["scriptSource"] = validScriptSource
                print("[Settings] set valid script to: \(validScriptSource)")
//                if notificationName != "NSControlTextDidEndEditingNotification" {
//                    self.dismiss(self)
//                }
                if notificationName == "ok_Button" {
                    ConfigsSettings().save(theServer: "\(JamfProServer.destination.fqdnFromUrl)", dataType: "settings", data: Settings.shared.dict)
                    dismiss(self)
                }
            }
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
//        print("[controlTextDidEndEditing] obj: \(obj)")
//        print("[controlTextDidEndEditing] obj.name.rawValue: \(obj.name.rawValue)")
        var whichField = ""
        if let textField = obj.object as? NSTextField {
            whichField = textField.identifier!.rawValue
        } else {
            whichField = obj.name.rawValue
        }
        //
        print("[controlTextDidEndEditing] obj.name.rawValue: \(obj.name.rawValue)")
        print("[controlTextDidEndEditing]        whichField: \(whichField)")

        if whichField == "scriptSource" {
            spinner_Progress.startAnimation(self)
            validateScript(notificationName: whichField)
        }
            
//        if obj.name.rawValue != "NSControlTextDidEndEditingNotification" {
//        }
//        print("brandingDict: \(brandingDict)")
    }
    
    
    
    // for scrolling text fields
    func textDidEndEditing(_ obj: Notification) {
        if let textView = obj.object as? NSTextView {
            switch textView.identifier!.rawValue {
            case "buildings":
                Settings.shared.dict["buildingsListRaw"] = buildings_TextField.string
               
            case "departments":
                Settings.shared.dict["departmentListRaw"] = departments_TextField.string
               
            default:
                break
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "KbPopover" {
            let kbPopoverVC: KbPopoverVC = segue.destinationController as! KbPopoverVC
            kbPopoverVC.delegate = self
            kbPopoverVC.kbInfo = sender as! [String:String]
            
            cancel_Button.isEnabled = false
            ok_Button.isEnabled     = false
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print("currentConfig: \(currentConfig)")
//        print("settingsDict: \(Settings.shared.dict)")
        
        func onOff(whichButton: String) -> Int {
            var buttonState = 1
            if let theState = Settings.shared.dict[whichButton] as? Int {
                buttonState = theState
            } else if let theState = Settings.shared.dict[whichButton] as? String {
                buttonState = ( theState == "true" ) ? 1:0
            }
            return buttonState
        }
        // branding
        brandingDict = ((Settings.shared.dict["branding"] as? [String:Any]) != nil) ? Settings.shared.dict["branding"] as! [String:Any]:["bannerImage":defaultBannerImage, "displayText":defaultDisplayText, "lightIcon":defaultLightIcon, "darkIcon":defaultDarkIcon]
        
        bannerImage_TextField.stringValue = ((brandingDict["bannerImage"] as? String) != nil) ? brandingDict["bannerImage"] as! String:defaultBannerImage
        displayText_Switch.state = NSControl.StateValue(rawValue: (((brandingDict["displayText"] as? Int) != nil) ? (brandingDict["displayText"] as! Int):1))
        lightIcon_TextField.stringValue = ((brandingDict["lightIcon"] as? String) != nil) ? brandingDict["lightIcon"] as! String:defaultLightIcon
        darkIcon_TextField.stringValue = ((brandingDict["darkIcon"] as? String) != nil) ? brandingDict["darkIcon"] as! String:defaultDarkIcon
        
        
        // support
        supportDict = ((Settings.shared.dict["support"] as? [String:Any]) != nil) ? Settings.shared.dict["support"] as! [String:String]:["teamName":defaultTeamName, "teamPhone":defaultTeamPhone, "teamEmail":defaultTeamEmail, "kb":defaultKb, "errorKb":defaultErrorKb, "helpKb":defaultHelpKb, "teamWebsite": defaultTeamWebsite]
        
        teamName_TextField.stringValue  = ((supportDict["teamName"] as? String) != nil) ? supportDict["teamName"] as! String:defaultTeamName
        teamPhone_TextField.stringValue = ((supportDict["teamPhone"] as? String) != nil) ? supportDict["teamPhone"] as! String:defaultTeamPhone
        teamEmail_TextField.stringValue = ((supportDict["teamEmail"] as? String) != nil) ? supportDict["teamEmail"] as! String:defaultTeamEmail
        kb_TextField.stringValue        = ((supportDict["kb"] as? String) != nil) ? supportDict["kb"] as! String:defaultKb
        errorKb_TextField.stringValue   = ((supportDict["errorKb"] as? String) != nil) ? supportDict["errorKb"] as! String:defaultErrorKb

        // prompt for
        if (Settings.shared.dict["promptFor"] as? [String:Any]) == nil {
            pfu_Switch.state  = NSControl.StateValue(rawValue: onOff(whichButton: "promptForUsername"))
            pu_Switch.state   = NSControl.StateValue(rawValue: onOff(whichButton: "prefillUsername"))
            pfcn_Switch.state = NSControl.StateValue(rawValue: onOff(whichButton: "promptForComputerName"))
            pfrn_Switch.state = NSControl.StateValue(rawValue: onOff(whichButton: "promptForRealName"))
            prn_Switch.state  = NSControl.StateValue(rawValue: onOff(whichButton: "prefillRealname"))
            pfe_Switch.state  = NSControl.StateValue(rawValue: onOff(whichButton: "promptForEmail"))
            pfat_Switch.state = NSControl.StateValue(rawValue: onOff(whichButton: "promptForAssetTag"))
            pfr_Switch.state  = NSControl.StateValue(rawValue: onOff(whichButton: "promptForRoom"))
            pfb_Switch.state  = NSControl.StateValue(rawValue: onOff(whichButton: "promptForBuilding"))
            pfd_Switch.state  = NSControl.StateValue(rawValue: onOff(whichButton: "promptForDepartment"))
            pfc_Switch.state  = NSControl.StateValue(rawValue: onOff(whichButton: "promptForConfiguration"))
            mip_Switch.state  = NSControl.StateValue(rawValue: onOff(whichButton: "moveableInProduction"))
        } else {
            print("use new settings")
            promptForDict = Settings.shared.dict["promptFor"] as! [String:Any]
            print("promptForDict: \(promptForDict)")
            pfu_Switch.state = NSControl.StateValue(rawValue:  promptForDict["promptForUsername"] as? Int ?? 1)
            pu_Switch.state = NSControl.StateValue(rawValue:  promptForDict["prefillUsername"] as? Int ?? 1)
            pfcn_Switch.state = NSControl.StateValue(rawValue:  promptForDict["promptForComputerName"] as? Int ?? 1)
            pfrn_Switch.state = NSControl.StateValue(rawValue:  promptForDict["promptForRealName"] as? Int ?? 1)
            prn_Switch.state = NSControl.StateValue(rawValue:  promptForDict["prefillRealname"] as? Int ?? 1)
            pfe_Switch.state = NSControl.StateValue(rawValue:  promptForDict["promptForEmail"] as? Int ?? 1)
            pfat_Switch.state = NSControl.StateValue(rawValue:  promptForDict["promptForAssetTag"] as? Int ?? 1)
            pfr_Switch.state = NSControl.StateValue(rawValue:  promptForDict["promptForRoom"] as? Int ?? 1)
            pfb_Switch.state = NSControl.StateValue(rawValue:  promptForDict["promptForBuilding"] as? Int ?? 1)
            pfd_Switch.state = NSControl.StateValue(rawValue:  promptForDict["promptForDepartment"] as? Int ?? 1)
            pfc_Switch.state = NSControl.StateValue(rawValue:  promptForDict["promptForConfiguration"] as? Int ?? 1)
            mip_Switch.state = NSControl.StateValue(rawValue:  promptForDict["moveableInProduction"] as? Int ?? 1)
        }
        buildings_TextField.string = Settings.shared.dict["buildingsListRaw"] as? String ?? ""
        departments_TextField.string = Settings.shared.dict["departmentListRaw"] as? String ?? ""
        
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        settings_TableView.tableColumns.forEach { (column) in
            column.headerCell.attributedStringValue = NSAttributedString(string: column.title, attributes: [NSAttributedString.Key.font: NSFont.boldSystemFont(ofSize: 16), .paragraphStyle: style])
        }
        
        settings_TableView.delegate     = self
        settings_TableView.dataSource   = self
        
        // script
        scriptSource_TextField.delegate = self
        
        // branding
        bannerImage_TextField.delegate  = self
        lightIcon_TextField.delegate    = self
        darkIcon_TextField.delegate     = self
        
        // support
        teamName_TextField.delegate     = self
        teamPhone_TextField.delegate    = self
        teamEmail_TextField.delegate    = self
        kb_TextField.delegate           = self
        errorKb_TextField.delegate      = self
        helpWebsite_TextField.delegate       = self
        
        // location
        buildings_TextField.delegate    = self
        departments_TextField.delegate  = self
        
        
        settings_AC.add(contentsOf: settingsArray)
        settings_TableView.selectRowIndexes(.init(integer: 0), byExtendingSelection: false)
        whichTab = settingsArray[0].tab
        settings_TabView.selectTabViewItem(withIdentifier: whichTab)
        validScriptSource = Settings.shared.dict["scriptSource"] as? String ?? defaultScriptSource
        
        scriptSource_TextField.stringValue = validScriptSource

        settings_AC.addObserver(self, forKeyPath: "selectedObjects", options: .new, context: nil)

    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
//        print("[viewWillDisappear] settingsDict: \(Settings.shared.dict)")
//        print("[viewWillDisappear] set valid script to: \(validScriptSource)")
//
//        Settings.shared.dict["scriptSource"] = validScriptSource
//        Settings.shared.dict["branding"]     = brandingDict
//        Settings.shared.dict["support"]      = supportDict
//        Settings.shared.dict["promptFor"]    = promptForDict
//        ConfigsSettings().save(theServer: "\(JamfProServer.destination.fqdnFromUrl)", dataType: "settings", data: Settings.shared.dict)
    }
    
}

extension SettingsVC: NSTableViewDataSource, NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let NameCell = "name"
        static let TabCell  = "tab"
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
//            print("numberOfRows: \(policiesArray.count)")
            return settingsArray.count
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if settings_TableView.selectedRowIndexes.count > 0 {
            let theRow = settings_TableView.selectedRow
            whichTab = settingsArray[theRow].tab
            print("whichTab: \(whichTab)")
            print("scriptVersion: \(scriptVersion)")
            
            if whichTab == "support" {
                if scriptVersion.0 <= 1 && scriptVersion.1 < 13 {
                    helpWebsite_Label.stringValue = "Help KB:"
                    helpWebsite_Label.placeholderString = ""
                    helpWebsite_TextField.stringValue    = supportDict["helpKb"] as? String ?? defaultHelpKb
//                    helpWebsite_TextField.stringValue    = ((supportDict["helpKb"] as? String) != nil) ? supportDict["helpKb"] as! String:defaultHelpKb
                } else {
                    helpWebsite_Label.stringValue = "Team website:"
                    helpWebsite_Label.placeholderString = "support.domain.com"
                    helpWebsite_TextField.stringValue   = supportDict["teamWebsite"] as? String ?? defaultTeamWebsite
                }
            }
            
            settings_TabView.selectTabViewItem(withIdentifier: whichTab)
            
        }
    }
    
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
    {
        //        print("tableView: \(tableView)\t\ttableColumn: \(tableColumn)\t\trow: \(row)")
        var newString:String = ""
        if (tableView == settings_TableView)
        {
            let name = settingsArray[row].name
            newString = "\(name)"
        }
        return newString;
    }
}
