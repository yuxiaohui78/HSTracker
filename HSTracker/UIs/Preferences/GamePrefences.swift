//
//  GamePrefences.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 29/02/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation
import MASPreferences

class GamePreferences: NSViewController {

    @IBOutlet weak var hearthstonePath: NSTextField!
    @IBOutlet weak var decksPath: NSTextField!
    @IBOutlet weak var chooseHearthstonePath: NSButton!
    @IBOutlet weak var hstrackerLanguage: NSComboBox!
    @IBOutlet weak var hearthstoneLanguage: NSComboBox!
    @IBOutlet weak var checkImage: NSImageView!
    @IBOutlet weak var autoArchiveArenaDeck: NSButton!
    @IBOutlet weak var autoSelectDecks: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        if Hearthstone.validatedHearthstonePath() {
            hearthstonePath.stringValue = Settings.hearthstonePath
            hearthstonePath.isEnabled = false
            chooseHearthstonePath.isEnabled = false
            checkImage.image = NSImage(named: "check")
        } else {
            checkImage.image = NSImage(named: "error")

            let alert = NSAlert()
            alert.alertStyle = .critical
            // swiftlint:disable line_length
            alert.messageText = NSLocalizedString("Can't find Hearthstone, please select Hearthstone.app", comment: "")
            // swiftlint:enable line_length
            alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
            alert.runModal()
        }

        if let locale = Settings.hsTrackerLanguage,
            let index = Language.hstrackerLanguages.index(of: locale) {
            hstrackerLanguage.selectItem(at: index)
        }
        if let locale = Settings.hearthstoneLanguage,
            let index = Language.hsLanguages.index(of: locale) {
            hearthstoneLanguage.selectItem(at: index)
        }

        autoArchiveArenaDeck.state = Settings.autoArchiveArenaDeck ? NSOnState : NSOffState
        autoSelectDecks.state = Settings.autoDeckDetection ? NSOnState : NSOffState
    }

    @IBAction func choosePath(_ sender: NSButton) {
        let openDialog = NSOpenPanel()

        if sender == chooseHearthstonePath {
            openDialog.delegate = self
            openDialog.canChooseDirectories = false
            openDialog.allowsMultipleSelection = false
            openDialog.allowedFileTypes = ["app"]
            openDialog.nameFieldStringValue = "Hearthstone.app"
            openDialog.title = NSLocalizedString("Please select your Hearthstone app", comment: "")
        }

        if openDialog.runModal() == NSModalResponseOK {
            if let url = openDialog.urls.first {
                if sender == chooseHearthstonePath {
                    let path = url.path
                    hearthstonePath.stringValue = path.replace("/Hearthstone.app", with: "")
                    checkImage.image = NSImage(named: "check")
                    Settings.hearthstonePath = hearthstonePath.stringValue
                }
            }
        }
    }

    @IBAction func checkboxClicked(_ sender: NSButton) {
        if sender == autoArchiveArenaDeck {
            Settings.autoArchiveArenaDeck = autoArchiveArenaDeck.state == NSOnState
        } else if sender == autoSelectDecks {
            Settings.autoDeckDetection = autoSelectDecks.state == NSOnState
        }
    }
}

// MARK: - NSComboBoxDataSource / NSComboBoxDelegatemethods
extension GamePreferences: NSComboBoxDataSource, NSComboBoxDelegate {
    func numberOfItems(in aComboBox: NSComboBox) -> Int {
        if aComboBox == hstrackerLanguage {
            return Language.hstrackerLanguages.count
        } else if aComboBox == hearthstoneLanguage {
            return Language.hearthstoneLanguages.count
        }

        return 0
    }

    func comboBox(_ aComboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        var language: String?
        if aComboBox == hstrackerLanguage {
            language = Language.hstrackerLanguages[index]
        } else if aComboBox == hearthstoneLanguage {
            language = Language.hearthstoneLanguages[index]
        }

        if let language = language {
            let locale = Locale(identifier: language)
            return (locale as NSLocale).displayName(forKey: NSLocale.Key.identifier,
                                                    value: language)!.capitalized
        } else {
            return ""
        }
    }

    func comboBoxSelectionDidChange(_ notification: Notification) {
        if let sender = notification.object as? NSComboBox {
            if sender == hearthstoneLanguage {
                let hearthstone = Language.hsLanguages[hearthstoneLanguage!.indexOfSelectedItem]
                if Settings.hearthstoneLanguage != hearthstone {
                    Settings.hearthstoneLanguage = hearthstone
                }
            } else if sender == hstrackerLanguage {
                let hstracker = Language.hstrackerLanguages[hstrackerLanguage!.indexOfSelectedItem]
                if Settings.hsTrackerLanguage != hstracker {
                    Settings.hsTrackerLanguage = hstracker
                }
            }
        }
    }
}
    // MARK: - NSOpenSavePanelDelegate
extension GamePreferences: NSOpenSavePanelDelegate {
    func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
        if url.path.hasSuffix(".app") {
            return url.lastPathComponent == "Hearthstone.app"
        } else {
            var isDir: ObjCBool = false
            return FileManager.default
                .fileExists(atPath: url.path, isDirectory: &isDir) && isDir.boolValue
        }
    }
}

// MARK: - MASPreferencesViewController
extension GamePreferences: MASPreferencesViewController {
    override var identifier: String? {
        get {
            return "game"
        }
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage? {
        return NSImage(named: NSImageNameAdvanced)
    }
    
    var toolbarItemLabel: String? {
        return NSLocalizedString("Game", comment: "")
    }
}
