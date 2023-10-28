//
//  LMEmulationController+InGameSettings.swift
//  Limon
//
//  Created by Jarrod Norwell on 10/28/23.
//

import Foundation
import UIKit

extension LMEmulationController {
    fileprivate func reloadInGameSettingsMenu() {
        Task {
            inGameSettingsButton.menu = inGameSettingsMenu()
        }
    }
    
    
    fileprivate func appearanceSubmenu() -> UIMenu {
        func children() -> [UIMenuElement] {
            func children() -> [UIMenuElement] {
                [
                    UIAction(title: "Filled", image: .init(systemName: "drop.fill"), attributes: self.virtualControllerView.appearance == .filled ? [.disabled] : [], handler: { _ in
                        self.virtualControllerView.filled()
                        self.reloadInGameSettingsMenu()
                    }),
                    UIAction(title: "Tinted", image: .init(systemName: "drop.halffull"), attributes: self.virtualControllerView.appearance == .filled ? [] : [.disabled], handler: { _ in
                        self.virtualControllerView.tinted()
                        self.reloadInGameSettingsMenu()
                    })
                ]
            }
            
            func isLatestVersion() -> Bool {
                if #available(iOS 17, *) { true } else { false }
            }
            
            return [
                UIMenu(options: .displayInline, preferredElementSize: .medium, children: children()),
                UIAction(title: "Toggle L, ZL, R, ZR", image: .init(systemName: self.virtualControllerView.bumpersTriggersHidden ? "eye.fill" : "eye.slash.fill"), handler: { _ in
                    self.virtualControllerView.bumpersTriggersHidden ? self.virtualControllerView.showBumpersTriggers() : self.virtualControllerView.hideBumpersTriggers()
                    self.reloadInGameSettingsMenu()
                })
            ]
        }
        
        return .init(title: "Appearance", image: .init(systemName: "paintpalette.fill"), children: children())
    }
    
    fileprivate func multiplayerSubmenu() -> UIMenu {
        func children() -> [UIMenuElement] {
            [
                UIMenu(options: .displayInline, preferredElementSize: .medium, children: [
                    UIAction(title: "Browse Servers", image: .init(systemName: "globe.asia.australia.fill"), attributes: .disabled, handler: { _ in }),
                    UIAction(title: "Direct Connect", image: .init(systemName: "person.line.dotted.person.fill"), handler: { _ in
                        self.citra().pause()
                        self.reloadInGameSettingsMenu()
                        
                        let directConnectController = LMDirectConnectController(.init(systemName: "person.line.dotted.person.fill"), "Direct Connect",
                            "Connect directly to a multiplayer room by entering your nickname along with the room's IP address, port if non-default and password if password protected")
                        directConnectController.modalPresentationStyle = .fullScreen
                        self.present(directConnectController, animated: true)
                    })
                ])
            ]
        }
        
        return .init(title: "Multiplayer", image: .init(systemName: "person.3.fill"), children: children())
    }
    
    fileprivate func screenLayoutsSubmenu() -> UIMenu {
        func children() -> [UIMenuElement] {
            func children() -> [UIMenuElement] {
                let screenLayouts = [
                    (title: "Default", subtitle: "", value: 0),
                    (title: "Single Screen", subtitle: "One large screen, centered", value: 1),
                    (title: "Large Screen", subtitle: "One large screen, one small screen, side by side", value: 2),
                    (title: "Side by Side Screen", subtitle: "Two equal height screens, side by side", value: 3),
                    (title: "Hybrid Screen", subtitle: "One large screen, two small screens, side by side, top to bottom", value: 5),
                    (title: "Mobile Portrait", subtitle: "Same as Default", value: 6),
                    (title: "Mobile Landscape", subtitle: "Same as Default, resized", value: 7)
                ]
                
                return screenLayouts.reduce(into: [UIAction]()) { partialResult, screenLayout in
                    partialResult.append(.init(title: screenLayout.title, subtitle: screenLayout.subtitle, state: self.citra()._layoutOption == screenLayout.value ? .on : .off, handler: { _ in
                        self.citra().setLayoutOption(UInt(screenLayout.value), with: self.screenView.screen.layer as! CAMetalLayer)
                        self.reloadInGameSettingsMenu()
                    }))
                }
            }
            
            return [
                UIMenu(options: .displayInline, preferredElementSize: .medium, children: [
                    UIMenu(title: "Screen Layouts", image: .init(systemName: "rectangle.3.group.fill"), children: children()),
                    UIAction(title: "Swap Screens", image: .init(systemName: "rectangle.2.swap"), handler: { _ in
                        self.citra().swapScreens(self.screenView.screen.layer as! CAMetalLayer)
                    })
                ])
            ]
        }
        
        return .init(title: "Screen Layout", children: children())
    }
    
    fileprivate func statesSubmenu() -> UIMenu {
        func children() -> [UIMenuElement] {
            let states: [(title: String, systemName: String, attributes: UIMenuElement.Attributes, handler: UIActionHandler)] = [
                (title: "Pause", systemName: "pause.fill", attributes: self.citra().isPaused() ? [.disabled] : [], handler: { _ in
                    self.citra().pause()
                    self.reloadInGameSettingsMenu()
                }),
                (title: "Resume", systemName: "play.fill", attributes: self.citra().isPaused() ? [] : [.disabled], handler: { _ in
                    self.citra().resume()
                    self.reloadInGameSettingsMenu()
                }),
                (title: "Stop", systemName: "stop.fill", attributes: [.disabled], handler: { _ in
                    self.citra().stop()
                    self.reloadInGameSettingsMenu()
                })
            ]
            
            return states.reduce(into: [UIAction]()) { partialResult, state in
                partialResult.append(.init(title: state.title, image: .init(systemName: state.systemName), attributes: state.attributes, handler: state.handler))
            }
        }
        
        return .init(options: .displayInline, preferredElementSize: .small, children: children())
    }
    
    func inGameSettingsMenu() -> UIMenu {
        .init(children: [appearanceSubmenu(), multiplayerSubmenu(), screenLayoutsSubmenu(), statesSubmenu()])
    }
}
