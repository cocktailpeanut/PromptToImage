//
//  Share.swift
//  PromptToImage
//
//  Created by hany on 05/12/22.
//

import Foundation
import AppKit

extension SDMainWindowController {
    
    // MARK: - Share

    // draw share menu
    func sharingServicePicker(_ sharingServicePicker: NSSharingServicePicker, sharingServicesForItems items: [Any], proposedSharingServices proposedServices: [NSSharingService]) -> [NSSharingService] {
        
        let btnimage = NSImage(systemSymbolName: "display.and.arrow.down", accessibilityDescription: nil) // item icon
        var share = proposedServices
        if let currentImages = items as? [NSImage] {
            let customService = NSSharingService(title: "Save As...", image: btnimage ?? NSImage(), alternateImage: btnimage, handler: {
                if currentImages.count == 1 {
                    // write single image to file
                    self.displaySavePanel(image:currentImages[0])
                } else if currentImages.count > 1 {
                    // write multiple images to folder
                    self.displaySavePanel(images: currentImages)
                } else {
                    // error!
                }
            })
            share.insert(customService, at: 0)
        }
        
        return share
    }



    // MARK: Save Panel for single image

    // save panel for single image
    func displaySavePanel(image:NSImage) {
        print("displaying save panel for single image")
        let panel = NSSavePanel()
        // suggested file name
        panel.nameFieldStringValue = "image.png"
        // panel strings
        panel.title = "Save image"
        panel.prompt = "Save Image"
        if panel.runModal().rawValue == 1 {
            if let path = panel.url?.path {
                // write to file
                self.writeImageToFile(path: path,
                                      image: image,
                                      format: savefileFormat)
            }
        }
    }
    
    
    // MARK: Save Panel for multiple images

    // open panel for multiple images
    func displaySavePanel(images:[NSImage]) {
        print("displaying open panel for saving multiple images")
        let panel = NSOpenPanel()
        panel.canCreateDirectories = true
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.message = "Select a folder"
        panel.prompt = "Save All Images"
        if panel.runModal().rawValue == 1 {
            //
            self.indindicator.isHidden = false
            self.indindicator.startAnimation(nil)
            self.progrLabel.stringValue = "Saving \(images.count) images..."
            self.speedLabel.isHidden = true
            self.window?.beginSheet(self.progrWin)
            //
            self.saveBtn.isEnabled = false
            
            if let path = panel.url?.path {
                DispatchQueue.global().async {
                    var i = 1
                    for image in images {
                        let proposedfilename = "image\(i).png"
                        self.writeImageToFile(path: "\(path)/\(proposedfilename)",
                                              image: image,
                                              format: savefileFormat)
                        i = i + 1
                    }
                    DispatchQueue.main.async {
                        self.window?.endSheet(self.progrWin)
                        self.saveBtn.isEnabled = true
                    }
                }
            }
            
        }
        
    }



    // MARK: Write To File

    func writeImageToFile(path: String,
                          image: NSImage,
                          format: NSBitmapImageRep.FileType) {
        let imageRep = NSBitmapImageRep(data: image.tiffRepresentation!)
        if let imageData = imageRep?.representation(using: format, properties: [:]) {
            do {
                try imageData.write(to: URL(fileURLWithPath: (path.hasSuffix(".png") ? path : "\(path).png")))
            }catch{ print(error) }
        }
    }


}

